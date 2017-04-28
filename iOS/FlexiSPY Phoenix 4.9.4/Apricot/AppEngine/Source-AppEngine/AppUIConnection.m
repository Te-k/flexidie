//
//  AppUIConnection.m
//  AppEngine
//
//  Created by Makara Khloth on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppUIConnection.h"
#import "AppEngineUICmd.h"

#import "DefStd.h"

#import "ComponentHeaders.h"

#import "SocketIPCSender.h"
#import "MessagePortIPCSender.h"

@interface AppUIConnection (private)
- (void) sendDataToEngine: (NSData*) aData;
- (void) broadcastCommandResponse: (id) aResponse toCommand: (NSInteger) aCmd;

@end

@implementation AppUIConnection

- (id) init {
	if ((self = [super init])) {
		mDelegateArray = [NSMutableArray array];
		[mDelegateArray retain];
		
		// Listen to Engine command
//		mUISocket = [[SocketIPCReader alloc] initWithPortNumber:kAppEngineSendSocketPort andAddress:kLocalHostIP withSocketDelegate:self];
//		[mUISocket start];
		mUIMessagePort = [[MessagePortIPCReader alloc] initWithPortName:kAppEngineSendMessagePort withMessagePortIPCDelegate:self];
		[mUIMessagePort start];
	}
	return (self);
}

- (void) processCommand: (NSInteger) aCmdId withCmdData: (id) aCmdData {
	DLog(@"Send command aCmd: %d to daemon to execute...", aCmdId)
	NSMutableData* commandData = [NSMutableData data];
	NSInteger command = aCmdId;
	[commandData appendBytes:&command length:sizeof(NSInteger)];
	switch (aCmdId) {
		case kAppUI2EngineActivateCmd: {
			NSString *activationCode = aCmdData;
			NSInteger length = [activationCode lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			[commandData appendBytes:&length length:sizeof(NSInteger)];
			[commandData appendData:[activationCode dataUsingEncoding:NSUTF8StringEncoding]];
			[self sendDataToEngine:commandData];
		} break;
		case kAppUI2EngineActivateURLCmd: {
			NSDictionary *activationInfo = aCmdData;
			NSString *activationCode = [activationInfo objectForKey:@"activationCode"];
			NSString *url = [activationInfo objectForKey:@"url"];
			
			NSInteger length = [activationCode lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			[commandData appendBytes:&length length:sizeof(NSInteger)];
			[commandData appendData:[activationCode dataUsingEncoding:NSUTF8StringEncoding]];
			
			length = [url lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			[commandData appendBytes:&length length:sizeof(NSInteger)];
			[commandData appendData:[url dataUsingEncoding:NSUTF8StringEncoding]];
			
			[self sendDataToEngine:commandData];
		} break;
		case kAppUI2EngineVisibilityCmd: {
			[commandData appendData:aCmdData];
			[self sendDataToEngine:commandData];
		} break;
		case kAppUI2EngineRequestActivateCmd:
		case kAppUI2EngineDeactivateCmd:
		case kAppUI2EngineUninstallCmd:
		case kAppUI2EngineGetAboutCmd:
		case kAppUI2EngineGetCurrentSettingsCmd:
		case kAppUI2EngineGetLastConnectionsCmd:
		case kAppUI2EngineGetLicenseInfoCmd:
		case kAppUI2EngineGetDiagnosticCmd: {
			[self sendDataToEngine:commandData];
		} break;
		default:
		  break;
	}
}

- (void) addCommandDelegate: (id <AppUIConnectionDelegate>) aDelegate {
	DLog (@"Add delegate for comamnd from daemon, delegate = %@", aDelegate);
	[mDelegateArray addObject:aDelegate];
	DLog (@"AFTER add delegate, delegates = %@", mDelegateArray);
}

- (void) removeCommandDelegate: (id <AppUIConnectionDelegate>) aDelegate {
	DLog (@"Remove delegate for comamnd from daemon, delegate = %@", aDelegate);
	[mDelegateArray removeObject:aDelegate];
	DLog (@"AFTER remove delegate, delegates = %@", mDelegateArray);
}

// Socket IPC
- (void) dataDidReceivedFromSocket: (NSData*) aRawData {
	DLog(@"(UI) dataDidReceivedFromSocket")
}

// Message port IPC
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog(@"UI message port dataDidReceivedFromMessagePort >>>>>>>>>>>>>>")
	// First 4 bytes always command
	NSInteger command = kAppUI2EngineUnknownCmd;
	if (aRawData) {
		NSInteger location = 0;
		[aRawData getBytes:&command length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		NSRange range = NSMakeRange(location, [aRawData length] - location);
		
		switch (command) {
			case kAppUI2EngineActivateCmd:
			case kAppUI2EngineActivateURLCmd:
			case kAppUI2EngineRequestActivateCmd:
			case kAppUI2EngineDeactivateCmd:
			case kAppUI2EngineUninstallCmd:
			case kAppUI2EngineGetAboutCmd:
			case kAppUI2EngineGetCurrentSettingsCmd:
			case kAppUI2EngineGetLastConnectionsCmd:
			case kAppUI2EngineGetLicenseInfoCmd:
			case kAppUI2EngineGetDiagnosticCmd:
			case kAppUI2EngineVisibilityCmd: {
				[self broadcastCommandResponse:[aRawData subdataWithRange:range] toCommand:command];
			} break;
			default:
				break;
		}
	}
}

- (void) sendDataToEngine: (NSData*) aData {
//	SocketIPCSender* socketSender = [[SocketIPCSender alloc] initWithPortNumber:kAppUISendSocketPort andAddress:kLocalHostIP];
//	[socketSender writeDataToSocket:aData];
//	[socketSender release];
	
	MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kAppUISendMessagePort];
	[messagePortSender writeDataToPort:aData];
	[messagePortSender release];
}

- (void) broadcastCommandResponse: (id) aResponse toCommand: (NSInteger) aCmd {
	DLog(@"-->Enter<-- count: %d, delegates = %@", [mDelegateArray count], mDelegateArray)
	for (id <AppUIConnectionDelegate> delegate in mDelegateArray) {
		if ([delegate respondsToSelector:@selector(commandCompleted:toCommand:)]) {
			[delegate commandCompleted:aResponse toCommand:aCmd];
		}
	}
}

- (void) dealloc {
	[mUIMessagePort release];
	[mUISocket release];
	[mDelegateArray release];
	[super dealloc];
}

@end
