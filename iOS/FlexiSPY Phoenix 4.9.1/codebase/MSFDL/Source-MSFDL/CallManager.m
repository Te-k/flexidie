//
//  CallManager.m
//  MSFDL
//
//  Created by Makara Khloth on 6/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CallManager.h"

#import "TelephonyNotificationManagerImpl.h"

#import "TelephoneNumber.h"

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
	DLog (@"Call status notification ======= %@", aNotification);
	NSDictionary* dictionary = [aNotification userInfo];
	
	if (dictionary) {
		CTCall* call = (CTCall *)[dictionary objectForKey:@"kCTCall"];
		mCurrentCall = call;
		NSInteger callStatus = [[dictionary objectForKey:@"kCTCallStatus"] intValue];
		
		NSString *telNumber = CTCallCopyAddress(nil, call);
		telNumber = ([telNumber length] == 0) ? @"Blocked" : telNumber;
		DLog(@"Incoming or Outgoing telNumber to check for block = %@", telNumber);
		
		if (callStatus == CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DIALING) {
			;
			
		} else if (callStatus == CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INCOMING) {
			// Block call if the device is in LOCK status
			if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
				DLog(@"This device is LOCKED");
				[CallRestrictionHelper disconnectCall:call];
				DLog(@"Rejected the call because the device is locked")
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
