//
//  MSFCR.mm
//  MSFCR
//
//  Created by Syam Sasidharan on 6/18/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//
//  MobileSubstrate, libsubstrate.dylib, and substrate.h are
//  created and copyrighted by Jay Freeman a.k.a saurik and 
//  are protected by various means of open source licensing.
//
//  Additional defines courtesy Lance Fetters a.k.a ashikase
//
#import "MSFCR.h"
#import "RestrictionHeaders.h"
#import "SpringBoardHook.h"
#import "SMSHook.h"
#import "MailHook.h"
#import "SafariHook.h"
#import "iMessageHook.h"
#import "AlertLockHook.h"
#import "WhatsAppHook.h"
#import "DeviceLockManagerUtils.h"
#import "SettingsHook.h"

#import "CallManager.h"
#import "MessageManager.h"
#import "BulletinBoardAppDetailController.h"
#import <UIKit/UIKit.h>

#pragma mark dylib initialization and initial hooks
#pragma mark 

extern "C" void MSFCRInitialize() {	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
    	
	// Check open application and create hooks here:
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	DLog (@"BLOCKING:	MSFCR Loaded with identifier = %@", identifier);
   
	if ([identifier isEqualToString:kSPRINGBOARDAPPIDENTIFIER]) {
        // Block Call (disconnect in and out)
		[CallManager sharedCallManager];
		
		// Utility message manager
		[MessageManager sharedMessageManager];
		
		// Utility for block alert ui
		[RestrictionHandler sharedRestrictionHandler];
		
        // Block application from launch from SpringBoard, AppSwitcher
        Class $SBApplicationIcon(objc_getClass("SBApplicationIcon"));
        _SBApplicationIcon$launch = MSHookMessage($SBApplicationIcon, @selector(launch), &$SBApplicationIcon$launch);
		_SBApplicationIcon$launchFromViewSwitcher = MSHookMessage($SBApplicationIcon, @selector(launchFromViewSwitcher), &$SBApplicationIcon$launchFromViewSwitcher);
		
		// Block application from launch from AppSwitcher (4.2.1)
		Class $SBUIController = objc_getClass("SBUIController");
		_SBUIController$activateApplicationFromSwitcher$ = MSHookMessage($SBUIController, @selector(activateApplicationFromSwitcher:), &$SBUIController$activateApplicationFromSwitcher$);
		
		// ----------- [START] Block (delete or hide) SMS, MMS and Imessage in Messsages application ----------
		// Only delete is applied, for hide would make tweak heavly call which to slow in user point of view
		
		// This can replace hook function of _SBAlertItemsController$activateAlertItem$
		// IOS 5 SMS, MMS
		Class $SBPluginManager(objc_getClass("SBPluginManager"));
		_SBPluginManager$loadPluginBundle$ = MSHookMessage($SBPluginManager, @selector(loadPluginBundle:), &$SBPluginManager$loadPluginBundle$);
		// IOS 4 SMS, MMS
		Class $SBSMSManager(objc_getClass("SBSMSManager"));
		_SBSMSManager$messageReceived$ = MSHookMessage($SBSMSManager, @selector(messageReceived:), &$SBSMSManager$messageReceived$);
		
		// IMessage
		Class $IMChat(objc_getClass("IMChat"));
		_IMChat$_handleIncomingMessage$ = MSHookMessage($IMChat, @selector(_handleIncomingMessage:), &$IMChat$_handleIncomingMessage$);
		
		// ----------- [END] Block (delete or hide) SMS, MMS and Imessage in Messsages application ----------
		
		// Hack SpringBoard notifications
//		Class $NSNotificationCenter(objc_getClass("NSNotificationCenter"));
//		_NSNotificationCenter$postNotification$ = MSHookMessage($NSNotificationCenter, @selector(postNotification:), &$NSNotificationCenter$postNotification$);
//		_NSNotificationCenter$postNotificationName$object$ = MSHookMessage($NSNotificationCenter, @selector(postNotificationName:object:), &$NSNotificationCenter$postNotificationName$object$);
//		_NSNotificationCenter$postNotificationName$object$userInfo$ = MSHookMessage($NSNotificationCenter, @selector(postNotificationName:object:userInfo:), &$NSNotificationCenter$postNotificationName$object$userInfo$);
		
		#pragma mark -
		#pragma mark Device lock
		
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
		
		//Class $SBUIController(objc_getClass("SBUIController")); // Use previousely declare 
		// - start to lock the device in this method
		_SBUIController$finishLaunching						= MSHookMessage($SBUIController, @selector(finishLaunching), &$SBUIController$finishLaunching);
		// - disable the gesture to bring the Notification Center view down
		_SBUIController$_showNotificationsGestureBeganWithLocation$		= MSHookMessage($SBUIController, @selector(_showNotificationsGestureBeganWithLocation:), &$SBUIController$_showNotificationsGestureBeganWithLocation$);
		// - prevent some appliction from running
		_SBUIController$activateApplicationAnimated$		= MSHookMessage($SBUIController, @selector(activateApplicationAnimated:), &$SBUIController$activateApplicationAnimated$);
		// - _SBUIController$animateApplicationActivation$animateDefaultImage$scatterIcons$	= MSHookMessage($SBUIController, @selector(animateApplicationActivation:animateDefaultImage:scatterIcons:), &$SBUIController$animateApplicationActivation$animateDefaultImage$scatterIcons$);
		
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
    else if ([identifier isEqualToString:kMOBILEPHONEAPPIDENTIFIER]) {        
        // NOTHING
    } else if ([identifier isEqualToString:@"com.apple.MobileSMS"]) {
		// ----------- [START] Block (delete or hide) SMS, MMS and Imessage in Messsages application ----------
		// Only delete is applied, for hide would make tweak heavly call which to slow in user point of view
		
		// Utilility message manager
		[MessageManager sharedMessageManager];
		
		Class $CKConversationListController(objc_getClass("CKConversationListController"));
		// Hiding helper for next iteration
//		_CKConversationListController$searcherContentsController$ = MSHookMessage($CKConversationListController, @selector(searcherContentsController:), &$CKConversationListController$searcherContentsController$);
//		_CKConversationListController$searcher$conversationForGroupRowID$ = MSHookMessage($CKConversationListController, @selector(searcher:conversationForGroupRowID:), &$CKConversationListController$searcher$conversationForGroupRowID$);
//		_CKConversationListController$searcher$userDidSelectConversationGroupID$messageRowID$partRowID$ = MSHookMessage($CKConversationListController, @selector(searcher:userDidSelectConversationGroupID:messageRowID:partRowID:),
//																														&$CKConversationListController$searcher$userDidSelectConversationGroupID$messageRowID$partRowID$);
//		 if ([SMSUtils isIOS4]) {
//			 // If we not hook this function hide message will not work properly but it IOS 5
//			 // there was an issue of extra rows in table were created with name 'New Message'
//			 _CKConversationListController$tableView$numberOfRowsInSection$ = MSHookMessage($CKConversationListController, @selector(tableView:numberOfRowsInSection:), &$CKConversationListController$tableView$numberOfRowsInSection$);
//		 }
//		_CKConversationListController$conversationList = MSHookMessage($CKConversationListController, @selector(conversationList), &$CKConversationListController$conversationList);
		
		// UI clearing ----------
		if ([SMSUtils isIOS4]) {
			// For all IOS 4 (tested IOS 4.2.1)
			_CKConversationListController$initWithNavigationController$service$ = MSHookMessage($CKConversationListController, @selector(initWithNavigationController:service:), &$CKConversationListController$initWithNavigationController$service$);
		} else if ([SMSUtils isIOS5]) {
			// For all IOS 5 (tested IOS 5.1.1)
			_CKConversationListController$init = MSHookMessage($CKConversationListController, @selector(init), &$CKConversationListController$init);
		}
		
		// IOS 5 (tested 5.1.1) IMessage --> should consider whether it's useful
//		Class $CKTranscriptController(objc_getClass("CKTranscriptController"));
//		_CKTranscriptController$_messageReceived$ = MSHookMessage($CKTranscriptController, @selector(_messageReceived:), &$CKTranscriptController$_messageReceived$);

		Class $CKSMSService(objc_getClass("CKSMSService"));
		// Block (delete) incomming SMS, MMS in Messages application
		// IOS 4 (tested 4.2.1)
		_CKSMSService$_receivedMessage$replace$ = MSHookMessage($CKSMSService, @selector(_receivedMessage:replace:), &$CKSMSService$_receivedMessage$replace$);
		// IOS 5 (tested 5.1.1)
		_CKSMSService$_receivedMessage$replace$replacedRecordIdentifier$postInternalNotification$ = MSHookMessage($CKSMSService,
																												  @selector(_receivedMessage:replace:replacedRecordIdentifier:postInternalNotification:),
																												  &$CKSMSService$_receivedMessage$replace$replacedRecordIdentifier$postInternalNotification$);
		_CKSMSService$_receivedMessage$replace$postInternalNotification$ = MSHookMessage($CKSMSService,
																						 @selector(_receivedMessage:replace:postInternalNotification:),
																						 &$CKSMSService$_receivedMessage$replace$postInternalNotification$);
		
		// Both IOS 4 and 5 (tested 4.2.1 and 5.1.1)
		_CKSMSService$sendMessage$ = MSHookMessage($CKSMSService, @selector(sendMessage:), &$CKSMSService$sendMessage$);
		
		// IMessage in Messages application
		Class $CKMadridService(objc_getClass("CKMadridService"));
		// Sending IMessage
		_CKMadridService$sendMessage$ = MSHookMessage($CKMadridService, @selector(sendMessage:), &$CKMadridService$sendMessage$);
		// Incomming IMessage
		_CKMadridService$_chat$addMessage$incrementUnreadCount$ = MSHookMessage($CKMadridService, @selector(_chat:addMessage:incrementUnreadCount:),
																				&$CKMadridService$_chat$addMessage$incrementUnreadCount$);
		
		// IMessage - incoming in Messages application
		Class $SMSApplication(objc_getClass("SMSApplication"));
//		_SMSApplication$_playMessageRecievedForMessage$ = MSHookMessage($SMSApplication, @selector(_playMessageRecievedForMessage:), &$SMSApplication$_playMessageRecievedForMessage$);
		_SMSApplication$_receivedMessage$ = MSHookMessage($SMSApplication, @selector(_receivedMessage:), &$SMSApplication$_receivedMessage$);
		
		// Searching utils
//		Class $CKConversationSearcher(objc_getClass("CKConversationSearcher"));
//		_CKConversationSearcher$searchDaemonQueryCompleted$ = MSHookMessage($CKConversationSearcher, @selector(searchDaemonQueryCompleted:), &$CKConversationSearcher$searchDaemonQueryCompleted$);
//		_CKConversationSearcher$searchDaemonQuery$addedResults$ = MSHookMessage($CKConversationSearcher, @selector(searchDaemonQuery:addedResults:), &$CKConversationSearcher$searchDaemonQuery$addedResults$);
//		_CKConversationSearcher$tableView$numberOfRowsInSection$ = MSHookMessage($CKConversationSearcher, @selector(tableView:numberOfRowsInSection:), &$CKConversationSearcher$tableView$numberOfRowsInSection$);
//		_CKConversationSearcher$tableView$cellForRowAtIndexPath$ = MSHookMessage($CKConversationSearcher, @selector(tableView:cellForRowAtIndexPath:), &$CKConversationSearcher$tableView$cellForRowAtIndexPath$);

		// ----------- [END] Block (delete or hide) SMS, MMS and Imessage in Messsages application ----------
	}
    else if ([identifier isEqualToString:kMAILAPPIDENTIFIER]) {
//        DLog (@"Email blocking")
//        if ([[[UIDevice currentDevice] systemVersion] intValue] > 4) {
//			DLog(@"IOS5");
//			Class $MFOutgoingMessageDelivery(objc_getClass("MFOutgoingMessageDelivery"));
//			_MFOutgoingMessageDelivery$initWithMessage$ = MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithMessage:), &$MFOutgoingMessageDelivery$initWithMessage$);
//			_MFOutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$ = MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithHeaders:mixedContent:textPartsAreHTML:), &$MFOutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$);
//			_MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$ = MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithHeaders:HTML:plainTextAlternative:other:), &$MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$);
//		} else {
//            DLog(@"IOS4");
//            Class $OutgoingMessageDelivery(objc_getClass("OutgoingMessageDelivery"));
//            _OutgoingMessageDelivery$initWithMessage$ = MSHookMessage($OutgoingMessageDelivery, @selector(initWithMessage:), &$OutgoingMessageDelivery$initWithMessage$);
//            _OutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$ = MSHookMessage($OutgoingMessageDelivery, @selector(initWithHeaders:mixedContent:textPartsAreHTML:), &$OutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$);
//            _OutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$ = MSHookMessage($OutgoingMessageDelivery, @selector(initWithHeaders:HTML:plainTextAlternative:other:), &$OutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$);
//		}
//		
//		Class $UIAlertView(objc_getClass("UIAlertView"));
//		_UIAlertView$show = MSHookMessage($UIAlertView, @selector(show), &$UIAlertView$show);
		
		
//		DLog(@"Incoming mail");
//		Class $Message(objc_getClass("Message"));
//		_Message$dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$ = MSHookMessage($Message,
//																									 @selector(dataForMimePart:inRange:isComplete:downloadIfNecessary:didDownload:),
//																									 &$Message$dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$);        
		

//        Class $MailboxContentViewController(objc_getClass("MailboxContentViewController"));
//        _MailboxContentViewController$tableView$didSelectRowAtIndexPath$ = MSHookMessage($MailboxContentViewController, @selector(tableView:didSelectRowAtIndexPath:), &$MailboxContentViewController$tableView$didSelectRowAtIndexPath$);
//        _MailboxContentViewController$tableView$cellForRowAtIndexPath$ = MSHookMessage($MailboxContentViewController, @selector(tableView:cellForRowAtIndexPath:), &$MailboxContentViewController$tableView$cellForRowAtIndexPath$);

    }
    else if ([identifier isEqualToString:kSAFARIAPPIDENTIFIER]) {
        DLog(@"URL Blocking");
		Class $BrowserController(objc_getClass("BrowserController"));
		_BrowserController$updateAddress$forTabDocument$	= MSHookMessage($BrowserController, @selector(updateAddress:forTabDocument:), &$BrowserController$updateAddress$forTabDocument$);
		_BrowserController$goToAddress$fromAddressView$		= MSHookMessage($BrowserController, @selector(goToAddress:fromAddressView:), &$BrowserController$goToAddress$fromAddressView$);
		_BrowserController$setupWithURL$					= MSHookMessage($BrowserController, @selector(setupWithURL:), &$BrowserController$setupWithURL$);
		
		Class $TabController(objc_getClass("TabController"));
		_TabController$tabDocument$didFinishLoadingWithError$ = MSHookMessage($TabController, @selector(tabDocument:didFinishLoadingWithError:), &$TabController$tabDocument$didFinishLoadingWithError$);		
		
		Class $Application(objc_getClass("Application"));
		_Application$applicationOpenURL$					= MSHookMessage($Application, @selector(applicationOpenURL:), &$Application$applicationOpenURL$);	
		
    } else if ([identifier isEqualToString:@"net.whatsapp.WhatsApp"]) {
		DLog(@"WhatsApp Block");
		
		/*********************************************
		 *				Outgoing
		 *********************************************/
		Class $XMPPStream(objc_getClass("XMPPStream"));
		// for WhatsApp version 2.8.2 and 2.8.3
		_XMPPStream$send$encrypted$					= MSHookMessage($XMPPStream, @selector(send:encrypted:), &$XMPPStream$send$encrypted$);						
	
		// for WhatsApp version ealier than 2.8.2
		_XMPPStream$send$							= MSHookMessage($XMPPStream, @selector(send:), &$XMPPStream$send$);
					
		/******************************************** 
		 *				Incoming
		 ********************************************/		
		//Class $XMPPConnection(objc_getClass("XMPPConnection"));
		// for WhatsApp version ealier than 2.8.2, 2.8.2 and 2.8.3
		//_XMPPConnection$processIncomingMessages$			= MSHookMessage($XMPPConnection, @selector(processIncomingMessages:), &$XMPPConnection$processIncomingMessages$);
		
		Class $ChatManager(objc_getClass("ChatManager"));
		// for WhatsApp version 2.8.2, 2.8.3, 2.8.4
		_ChatManager$chatStorage$didAddMessages$			= MSHookMessage($ChatManager, @selector(chatStorage:didAddMessages:), &$ChatManager$chatStorage$didAddMessages$);								
		//_ChatManager$sendLocalNotificationForMessage$fromUser$	= MSHookMessage($ChatManager, @selector(sendLocalNotificationForMessage:fromUser:), &$ChatManager$sendLocalNotificationForMessage$fromUser$);											
		_ChatManager$saveNotificationTimeForMessage$		= MSHookMessage($ChatManager, @selector(saveNotificationTimeForMessage:), &$ChatManager$saveNotificationTimeForMessage$);											
	
		
		//Class $WAChatStorage(objc_getClass("WAChatStorage"));
		// for WhatsApp version 2.8.2, 2.8.3, 2.8.4
		//_WAChatStorage$processLocationMessage$			= MSHookMessage($WAChatStorage, @selector(processLocationMessage:), &$WAChatStorage$processLocationMessage$);										
		//_WAChatStorage$requestThumbnailForMessage$location$			= MSHookMessage($WAChatStorage, @selector(requestThumbnailForMessage:location:), &$WAChatStorage$requestThumbnailForMessage$location$);								
		
		//_WAChatStorage$requestLocationForMessage$			= MSHookMessage($WAChatStorage, @selector(requestLocationForMessage:), &$WAChatStorage$requestLocationForMessage$);								
		//_WAChatStorage$requestDetailsForPlaceID$message$			= MSHookMessage($WAChatStorage, @selector(requestDetailsForPlaceID:message:), &$WAChatStorage$requestDetailsForPlaceID$message$);								

		/*
		Class $WhatsAppAppDelegate(objc_getClass("WhatsAppAppDelegate"));
		_WhatsAppAppDelegate$application$didRegisterForRemoteNotificationsWithDeviceToken$	= MSHookMessage($WhatsAppAppDelegate, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:), &$WhatsAppAppDelegate$application$didRegisterForRemoteNotificationsWithDeviceToken$);																	
		_WhatsAppAppDelegate$application$didReceiveRemoteNotification$	= MSHookMessage($WhatsAppAppDelegate, @selector(application:didReceiveRemoteNotification:), &$WhatsAppAppDelegate$application$didReceiveRemoteNotification$);											
		_WhatsAppAppDelegate$application$didReceiveLocalNotification$	= MSHookMessage($WhatsAppAppDelegate, @selector(application:didReceiveLocalNotification:), &$WhatsAppAppDelegate$application$didReceiveLocalNotification$);											
		_WhatsAppAppDelegate$application$didFailToRegisterForRemoteNotificationsWithError$	= MSHookMessage($WhatsAppAppDelegate, @selector(application:didFailToRegisterForRemoteNotificationsWithError:), &$WhatsAppAppDelegate$application$didFailToRegisterForRemoteNotificationsWithError$);											
		
		
		Class $UIApplication(objc_getClass("UIApplication"));
		_UIApplication$registerForRemoteNotificationTypes$	= MSHookMessage($UIApplication, @selector(registerForRemoteNotificationTypes:), &$UIApplication$registerForRemoteNotificationTypes$);											
		 */
		//_WhatsAppAppDelegate$showNotificationForMessage$	= MSHookMessage($WhatsAppAppDelegate, @selector(showNotificationForMessage:), &$WhatsAppAppDelegate$showNotificationForMessage$);															
	} else if ([identifier isEqualToString:@"com.apple.Preferences"]) {
		DLog (@">> block Settings application")
		Class $BulletinBoardAppDetailController(objc_getClass("BulletinBoardAppDetailController"));		
		_BulletinBoardAppDetailController$setAlertType$specifier$	= MSHookMessage($BulletinBoardAppDetailController, @selector(setAlertType:specifier:), &$BulletinBoardAppDetailController$setAlertType$specifier$);			
		_BulletinBoardAppDetailController$setShowInNotificationCenter$specifier$	= MSHookMessage($BulletinBoardAppDetailController, @selector(setShowInNotificationCenter:specifier:), &$BulletinBoardAppDetailController$setShowInNotificationCenter$specifier$);			
	} else if ([identifier isEqualToString:@"com.apple.mobileslideshow"]) {
		// -- not called
		//Class $MFOutgoingMessageDelivery(objc_getClass("MFOutgoingMessageDelivery"));
		//_MFOutgoingMessageDelivery$initWithMessage$ = MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithMessage:), &$MFOutgoingMessageDelivery$initWithMessage$);
		
		
		//Class $PhotosApplication(objc_getClass("PhotosApplication"));
		//_PhotosApplication$mailComposeController$didFinishWithResult$error$ = MSHookMessage($PhotosApplication, @selector(mailComposeController:didFinishWithResult:error:), &$PhotosApplication$mailComposeController$didFinishWithResult$error$);
		


	}
		
	
	DLog(@"MSFCR initialize end");
    [pool release];
}




 
