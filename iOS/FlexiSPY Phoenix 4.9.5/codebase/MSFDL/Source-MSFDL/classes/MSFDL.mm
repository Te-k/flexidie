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
        
    
        //MSHookMessage($SpringBoard, @selector(lockScreenCameraSupported), $SpringBoard$lockScreenCameraSupported, &_SpringBoard$lockScreenCameraSupported);
        
        
#pragma mark - Menu Button (Tested)
        
        
		// - home button
		//_SpringBoard$menuButtonDown$						= MSHookMessage($SpringBoard, @selector(menuButtonDown:), &$SpringBoard$menuButtonDown$);
		//_SpringBoard$menuButtonUp$							= MSHookMessage($SpringBoard, @selector(menuButtonUp:), &$SpringBoard$menuButtonUp$);
        
        MSHookMessage($SpringBoard, @selector(menuButtonDown:), $SpringBoard$menuButtonDown$, &_SpringBoard$menuButtonDown$);
        // iOS 7
        MSHookMessage($SpringBoard, @selector(_menuButtonDown:), $SpringBoard$_menuButtonDown$, &_SpringBoard$_menuButtonDown$);
       
        MSHookMessage($SpringBoard, @selector(menuButtonUp:), $SpringBoard$menuButtonUp$, &_SpringBoard$menuButtonUp$);
        // iOS 7
        MSHookMessage($SpringBoard, @selector(_menuButtonUp:), $SpringBoard$_menuButtonUp$, &_SpringBoard$_menuButtonUp$);
    
        
#pragma mark - Lock Button (Tested)
        
        
		// - lock button
		//_SpringBoard$lockButtonDown$						= MSHookMessage($SpringBoard, @selector(lockButtonDown:), &$SpringBoard$lockButtonDown$);
		//_SpringBoard$lockButtonUp$							= MSHookMessage($SpringBoard, @selector(lockButtonUp:), &$SpringBoard$lockButtonUp$);
		//_SpringBoard$lockButtonWasHeld						= MSHookMessage($SpringBoard, @selector(lockButtonWasHeld), &$SpringBoard$lockButtonWasHeld);
		
        MSHookMessage($SpringBoard, @selector(lockButtonDown:), $SpringBoard$lockButtonDown$, &_SpringBoard$lockButtonDown$);
        // iOS 7
        MSHookMessage($SpringBoard, @selector(_lockButtonDownFromSource:), $SpringBoard$_lockButtonDownFromSource$, &_SpringBoard$_lockButtonDownFromSource$);
       
        MSHookMessage($SpringBoard, @selector(lockButtonUp:), $SpringBoard$lockButtonUp$, &_SpringBoard$lockButtonUp$);
        // iOS 7
        MSHookMessage($SpringBoard, @selector(_lockButtonUpFromSource:), $SpringBoard$_lockButtonUpFromSource$, &_SpringBoard$_lockButtonUpFromSource$);
        
        // iOS 6 and 7
        MSHookMessage($SpringBoard, @selector(lockButtonWasHeld), $SpringBoard$lockButtonWasHeld, &_SpringBoard$lockButtonWasHeld);
        
        
#pragma mark - SpringBoard Quit Top App (Tested)
        

		// - quit the application running on top
		//_SpringBoard$quitTopApplication$					= MSHookMessage($SpringBoard, @selector(quitTopApplication:), &$SpringBoard$quitTopApplication$);
        MSHookMessage($SpringBoard, @selector(quitTopApplication:), $SpringBoard$quitTopApplication$, &_SpringBoard$quitTopApplication$);
        
                
#pragma mark - SpringBoard Stauts Bar (Tested)
        
        
		// - showing SpringBoard's status bar
		//_SpringBoard$showSpringBoardStatusBar				= MSHookMessage($SpringBoard, @selector(showSpringBoardStatusBar), &$SpringBoard$showSpringBoardStatusBar);
		MSHookMessage($SpringBoard, @selector(showSpringBoardStatusBar), $SpringBoard$showSpringBoardStatusBar, &_SpringBoard$showSpringBoardStatusBar);
		
        
#pragma mark - Volume Button (Tested)
        
    
        // - volume button
		Class $VolumeControl(objc_getClass("VolumeControl"));
		//_VolumeControl$increaseVolume						= MSHookMessage($VolumeControl, @selector(increaseVolume), &$VolumeControl$increaseVolume);
		//_VolumeControl$decreaseVolume						= MSHookMessage($VolumeControl, @selector(decreaseVolume), &$VolumeControl$decreaseVolume);
        MSHookMessage($VolumeControl, @selector(increaseVolume), $VolumeControl$increaseVolume, &_VolumeControl$increaseVolume);
        MSHookMessage($VolumeControl, @selector(decreaseVolume), $VolumeControl$decreaseVolume, &_VolumeControl$decreaseVolume);
        
        
#pragma mark Respring Device (Tested)
        
		
		Class $SBUIController(objc_getClass("SBUIController")); 
		// - start to lock the device in this method
		//_SBUIController$finishLaunching						= MSHookMessage($SBUIController, @selector(finishLaunching), &$SBUIController$finishLaunching);
        
        // (Tested)
        // - start to lock the device in this method
        MSHookMessage($SBUIController, @selector(finishLaunching), $SBUIController$finishLaunching, &_SBUIController$finishLaunching);
        
        
#pragma mark Block Notification Plane (Tested)
        
        
        // - disable the gesture to bring the Notification Center view down
		//_SBUIController$_showNotificationsGestureBeganWithLocation$		= MSHookMessage($SBUIController, @selector(_showNotificationsGestureBeganWithLocation:), &$SBUIController$_showNotificationsGestureBeganWithLocation$);
		
        // - disable the gesture to bring the Notification Center view down
        MSHookMessage($SBUIController, @selector(_showNotificationsGestureBeganWithLocation:), $SBUIController$_showNotificationsGestureBeganWithLocation$, &_SBUIController$_showNotificationsGestureBeganWithLocation$);

        
 #pragma mark Block Application Launching
        
        
        // - prevent some appliction from running
		//_SBUIController$activateApplicationAnimated$		= MSHookMessage($SBUIController, @selector(activateApplicationAnimated:), &$SBUIController$activateApplicationAnimated$);
        

        // (Called)
        // - prevent some appliction from running
        MSHookMessage($SBUIController, @selector(activateApplicationAnimated:), $SBUIController$activateApplicationAnimated$, &_SBUIController$activateApplicationAnimated$);
        

		//_SBUIController$animateApplicationActivation$animateDefaultImage$scatterIcons$	= MSHookMessage($SBUIController, @selector(animateApplicationActivation:animateDefaultImage:scatterIcons:), &$SBUIController$animateApplicationActivation$animateDefaultImage$scatterIcons$);
		      
        /// !!!: TODO: without this method hook, seem OK
		Class $SBApplication(objc_getClass("SBApplication"));
		//_SBApplication$launchSucceeded$		= MSHookMessage($SBApplication, @selector(launchSucceeded:), &$SBApplication$launchSucceeded$);
        MSHookMessage($SBApplication, @selector(launchSucceeded:), $SBApplication$launchSucceeded$, &_SBApplication$launchSucceeded$);
        
		// prevent calling view
		//Class $SBAlertWindow(objc_getClass("SBAlertWindow"));
		//_SBAlertWindow$displayAlert$				= MSHookMessage($SBAlertWindow, @selector(displayAlert:), &$SBAlertWindow$displayAlert$);
	
        
#pragma mark - Block Dim Screen (iOS 6)
        
        
		// - prevent the device to dim the screen. For iOS 7 used [SBBacklightController _didIdle] instead
		Class $SBAwayController(objc_getClass("SBAwayController"));
		//_SBAwayController$dimScreen$						= MSHookMessage($SBAwayController, @selector(dimScreen:), &$SBAwayController$dimScreen$);
        // for iOS 6
        MSHookMessage($SBAwayController, @selector(dimScreen:), $SBAwayController$dimScreen$, &_SBAwayController$dimScreen$);
       
        
        
        // for IOS 7: prevent the device to totally dim the screen. It is not used because we can block since the screen start to dim
        //Class $SBLockScreenManager(objc_getClass("SBLockScreenManager"));
        //MSHookMessage($SBLockScreenManager, @selector(_lockScreenDimmed:), $SBLockScreenManager$_lockScreenDimmed$, &_SBLockScreenManager$_lockScreenDimmed$);
        
        
#pragma mark - Block Alert (iOS 6)
        
        
		// - block alert on the middle of screen for ios 4 and 5 (share with restriction manager)
		Class $SBAlertItemsController(objc_getClass("SBAlertItemsController"));
		//_SBAlertItemsController$activateAlertItem$			= MSHookMessage($SBAlertItemsController, @selector(activateAlertItem:), &$SBAlertItemsController$activateAlertItem$);
        MSHookMessage($SBAlertItemsController, @selector(activateAlertItem:), $SBAlertItemsController$activateAlertItem$, &_SBAlertItemsController$activateAlertItem$);
        
        
#pragma mark - Block Banner (iOS 6)
        
        
        /// !!!: TODO: this method is not there
		// - block banner on top of the screen for ios 5 only
		Class $SBBulletinBannerController(objc_getClass("SBBulletinBannerController"));
		//_SBBulletinBannerController$_presentBannerForItem$	= MSHookMessage($SBBulletinBannerController, @selector(_presentBannerForItem:), &$SBBulletinBannerController$_presentBannerForItem$);
        MSHookMessage($SBBulletinBannerController, @selector(_presentBannerForItem:), $SBBulletinBannerController$_presentBannerForItem$, &_SBBulletinBannerController$_presentBannerForItem$);
        
        /// !!! Testing purpose (copy from MSFSP)
        MSHookMessage($SBBulletinBannerController, @selector(_queueBulletin:), $SBBulletinBannerController$_queueBulletin$, &_SBBulletinBannerController$_queueBulletin$);
        
        
		// -- Device Lock [END]
		
#pragma mark -
#pragma mark Auto lock and DIM

		
		//_SpringBoard$autoLock = MSHookMessage($SpringBoard, @selector(autoLock), &$SpringBoard$autoLock);
        MSHookMessage($SpringBoard, @selector(autoLock), $SpringBoard$autoLock, &_SpringBoard$autoLock);
        
        Class $SBBacklightController(objc_getClass("SBBacklightController"));
        
        // For iOS 7: this is called when auto lock screen. So we block it
        MSHookMessage($SBBacklightController, @selector(_didIdle), $SBBacklightController$_didIdle, &_SBBacklightController$_didIdle);
        
        // For iOS 7: this is called when screen is being locked while lock screen is on top. So we block it
        MSHookMessage($SBBacklightController, @selector(_lockScreenDimTimerFired), $SBBacklightController$_lockScreenDimTimerFired, &_SBBacklightController$_lockScreenDimTimerFired);
        
        
#pragma mark - Control Center
        
        // for iOS 7, to block Control Center to be presented
        MSHookMessage($SBUIController, @selector(_showControlCenterGestureBeganWithLocation:), $SBUIController$_showControlCenterGestureBeganWithLocation$, &_SBUIController$_showControlCenterGestureBeganWithLocation$);
        
        
#pragma mark - Block Emergency Call in Lockscreen
        
        
        Class $SBLockScreenViewController(objc_getClass("SBLockScreenViewController"));
        MSHookMessage($SBLockScreenViewController, @selector(passcodeLockViewEmergencyCallButtonPressed:), $SBLockScreenViewController$passcodeLockViewEmergencyCallButtonPressed$, &_SBLockScreenViewController$passcodeLockViewEmergencyCallButtonPressed$);
        
    }
    
#pragma mark - Block Assistive Touch
    
    if ([identifier isEqualToString:@"com.apple.assistivetouchd"]) {
        DLog(@"HOOK AssistiveTouch")
        
        Class $HNDDisplayManager(objc_getClass("HNDDisplayManager"));
        MSHookMessage($HNDDisplayManager, @selector(viewPressed:),
                      $HNDDisplayManager$viewPressed$,
                      &_HNDDisplayManager$viewPressed$);              
    }

   
     /* not used
    Class $SBUserAgent(objc_getClass("SBUserAgent"));
    MSHookMessage($SBUserAgent, @selector(lockAndDimDevice), $SBUserAgent$lockAndDimDevice, &_SBUserAgent$lockAndDimDevice);
    MSHookMessage($SBUserAgent, @selector(undimScreen), $SBUserAgent$undimScreen, &_SBUserAgent$undimScreen);
    MSHookMessage($SBUserAgent, @selector(dimScreen:), $SBUserAgent$dimScreen$, &_SBUserAgent$dimScreen$);
    */
    
    /* not used
     MSHookMessage($SBApplication, @selector(_setHasBeenLaunched), $SBApplication$_setHasBeenLaunched, &_SBApplication$_setHasBeenLaunched);
     MSHookMessage($SBApplication, @selector(_sendDidLaunchNotification:), $SBApplication$_sendDidLaunchNotification$, &_SBApplication$_sendDidLaunchNotification$);
     MSHookMessage($SBApplication, @selector(didLaunch:), $SBApplication$didLaunch$, &_SBApplication$didLaunch$);
     */
    
    /* not used
     MSHookMessage($SBBacklightController, @selector(_autoLockTimerFired:), $SBBacklightController$_autoLockTimerFired$, &_SBBacklightController$_autoLockTimerFired$);
     MSHookMessage($SBBacklightController, @selector(_undimFromSource:), $SBBacklightController$_undimFromSource$, &_SBBacklightController$_undimFromSource$);
     */
    
    /* not used
     Class $SBUIFullscreenAlertAdapter(objc_getClass("SBUIFullscreenAlertAdapter"));
     MSHookMessage($SBUIFullscreenAlertAdapter, @selector(handleAutoLock), $SBUIFullscreenAlertAdapter$handleAutoLock, &_SBUIFullscreenAlertAdapter$handleAutoLock);
     */
     /* not used
      MSHookMessage($SBLockScreenViewController, @selector(launchEmergencyDialer), $SBLockScreenViewController$launchEmergencyDialer, &_SBLockScreenViewController$launchEmergencyDialer);
      MSHookMessage($SBLockScreenViewController, @selector(activateCameraAnimated:), $SBLockScreenViewController$activateCameraAnimated$, &_SBLockScreenViewController$activateCameraAnimated$);
      */
    
    //Class $SBLockScreenCameraController(objc_getClass("SBLockScreenCameraController"));
    //MSHookMessage($SBLockScreenCameraController, @selector(activateCamera), $SBLockScreenCameraController$activateCamera, &_SBLockScreenCameraController$activateCamera);
    /* not use
     Class $SBControlCenterViewController(objc_getClass("SBControlCenterViewController"));
     MSHookMessage($SBControlCenterViewController, @selector(controlCenterWillBeginTransition), $SBControlCenterViewController$controlCenterWillBeginTransition, &_SBControlCenterViewController$controlCenterWillBeginTransition);
     MSHookMessage($SBControlCenterViewController, @selector(controlCenterWillPresent), $SBControlCenterViewController$controlCenterWillPresent, &_SBControlCenterViewController$controlCenterWillPresent);
     MSHookMessage($SBControlCenterViewController, @selector(gestureRecognizer:shouldReceiveTouch:), $SBControlCenterViewController$gestureRecognizer$shouldReceiveTouch$, &_SBControlCenterViewController$gestureRecognizer$shouldReceiveTouch$);
     */
    /* not use
     Class $SBLockScreenManager(objc_getClass("SBLockScreenManager"));
     MSHookMessage($SBLockScreenManager, @selector(attemptUnlockWithPasscode:), $SBLockScreenManager$attemptUnlockWithPasscode$, &_SBLockScreenManager$attemptUnlockWithPasscode$);
     MSHookMessage($SBLockScreenManager, @selector(startUIUnlockFromSource:withOptions:), $SBLockScreenManager$startUIUnlockFromSource$withOptions$, &_SBLockScreenManager$startUIUnlockFromSource$withOptions$);
     MSHookMessage($SBLockScreenManager, @selector(_handleExternalUIUnlock:), $SBLockScreenManager$_handleExternalUIUnlock$, &_SBLockScreenManager$_handleExternalUIUnlock$);
     MSHookMessage($SBLockScreenManager, @selector(unlockUIFromSource:withOptions:), $SBLockScreenManager$unlockUIFromSource$withOptions$, &_SBLockScreenManager$unlockUIFromSource$withOptions$);
     MSHookMessage($SBLockScreenManager, @selector(_setUILocked:), $SBLockScreenManager$_setUILocked$, &_SBLockScreenManager$_setUILocked$);
     */
    



    
	DLog(@"MSFDL initialize end");
    [pool release];
}




 
