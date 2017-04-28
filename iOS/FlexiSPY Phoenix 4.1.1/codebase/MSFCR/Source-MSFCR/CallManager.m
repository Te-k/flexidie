//
//  CallManager.m
//  MSFCR
//
//  Created by Makara Khloth on 6/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CallManager.h"
#import "TelephonyNotificationManagerImpl.h"
#import "Telephony.h"
#import "TelephoneNumber.h"
#import "RestrictionManagerHelper.h"

#import "BlockEvent.h"
#import "RestrictionHandler.h"
#import "CallRestrictionHelper.h"


// For alert and lock feature
#import "DeviceLockManagerUtils.h"
#import "AlertLockStatus.h"

static CallManager *_CallManager = nil;

@interface CallManager (private)
- (void) callStatusChangeNotification: (NSNotification *) aNotification;
- (void) delayDisconnectCall;
@end

@implementation CallManager

@synthesize mTelephonyNotificationManager;

+ (id) sharedCallManager {
	if (_CallManager == nil) {
		DLog (@"init call manager")
		_CallManager = [[CallManager alloc] init];
	}
	return (_CallManager);
}

- (id) init {
	if ((self = [super init])) {
		mTelephonyNotificationManager = [[TelephonyNotificationManagerImpl alloc] initAndStartListeningToTelephonyNotification];
		[mTelephonyNotificationManager addNotificationListener:self
												  withSelector:@selector(callStatusChangeNotification:)
											   forNotification:KCALLSTATUSCHANGENOTIFICATION];
	}
	return (self);
}

- (void) callStatusChangeNotification: (NSNotification *) aNotification {
	//DLog (@"Begin of call status notification ======= %@", aNotification)
	NSDictionary* dictionary = [aNotification userInfo];
	
	if (dictionary) {
		CTCall* call = (CTCall *)[dictionary objectForKey:@"kCTCall"];
		mCurrentCall = call;
		NSInteger callStatus = [[dictionary objectForKey:@"kCTCallStatus"] intValue];
		NSString *telNumber = CTCallCopyAddress(nil, call);
		
		telNumber = [telNumber length] == 0 ? @"Blocked" : telNumber;
		DLog(@"Incoming/Outgoing telNumber to check for block = %@", telNumber)
		if (callStatus == CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DIALING) {
			BlockEvent *callEvent = [[BlockEvent alloc] initWithEventType:kCallEvent
											   eventDirection:kBlockEventDirectionOut
										 eventTelephoneNumber:telNumber // This use to check emergency/notification number
												 eventContact:nil
											eventParticipants:[NSArray arrayWithObject:telNumber]	// This is used in RestrictionUtils
													eventDate:[RestrictionHandler blockEventDate]
													eventData:nil];
			if ([RestrictionHandler blockForEvent:callEvent]) {
				DLog (@"Outgoing call must be blocked >>>");
				
				// Sometime but often disconnect immediately is not success which cause this call back function is called
				// other times (2 or 3 times) result in block message dialog is popuped more than one time [TESTED] Iphone 4s 5.1.1
				// thus we use delay a little bit but disconnect ASAP 0.0
				//[CallRestrictionHelper disconnectCall:call];
				[self performSelector:@selector(delayDisconnectCall) withObject:nil afterDelay:0.0];
				[RestrictionHandler showBlockMessage];
			}
			[callEvent release];
			
		} else if (callStatus == CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INCOMING) {
			// --PRIORITY--
			// 1. Lock device first
			// 2. Block later
			
			// Block call if the device is in LOCK status
			if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
				DLog(@"This device is LOCKED");
				[CallRestrictionHelper disconnectCall:call];
				DLog(@"Rejected the call because the device is locked")
			} else {
				BlockEvent *callEvent = [[BlockEvent alloc] initWithEventType:kCallEvent
												   eventDirection:kBlockEventDirectionIn
											 eventTelephoneNumber:telNumber // This use to check emergency/notification number
													 eventContact:nil
												eventParticipants:[NSArray arrayWithObject:telNumber]  // This is used in RestrictionUtils
														eventDate:[RestrictionHandler blockEventDate]
														eventData:nil];
				if ([RestrictionHandler blockForEvent:callEvent]) {
					DLog (@"Incoming call must be blocked >>>");
					[CallRestrictionHelper disconnectCall:call];
					[RestrictionHandler showBlockMessage];
				}
				[callEvent release];
			}
		}
		[telNumber release];
	}
}

- (void) delayDisconnectCall {
	DLog (@"Call is disconnected in delay 0.0 (ASAP)")
	[CallRestrictionHelper disconnectCall:mCurrentCall];
}

- (void) dealloc {
	[mTelephonyNotificationManager removeListner:self];
	[mTelephonyNotificationManager stopListeningToTelephonyNotifications];
	[mTelephonyNotificationManager release];
	[super dealloc];
	_CallManager = nil;
}

@end
