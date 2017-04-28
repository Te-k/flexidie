//
//  CameraCaptureManagerUtils.m
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraCaptureManagerUIUtils.h"
#import "CameraCaptureManager.h"
#import "MessagePortIPCSender.h"
#import "MessagePortIPCReader.h"
#import "DefStd.h"
#import "DebugStatus.h"

@interface CameraCaptureManagerUIUtils (private)

// Sender part
- (BOOL) sendData: (NSData *) aData toPort: (NSString *) aPortName;
- (BOOL) sendData: (NSData *) aData;
// Receiver part
- (void) startMessagePort;
- (void) stopMessagePort;
@end


@implementation CameraCaptureManagerUIUtils

@synthesize mCameraCaptureManager;

- (id) initWithCameraCaptureManager: (CameraCaptureManager *) aCameraCaptureManager {
	if ((self = [super init])) {
		[self setMCameraCaptureManager:aCameraCaptureManager];
		[self startMessagePort];	// wait from command from a daemon
	}
	return (self);
}

#pragma mark -
#pragma mark Sender part


- (void) commandToDaemon: (CameraCaptureManagerCmd) aCommand interval: (NSInteger) aInterval{
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
	if (!(success = [self sendData:aData toPort:kPanicImageUISenderMessagePort])) {
		//DLog(@"!!!!!!!!!!!!!!!!!!!! send event to the daemon")
	}
	return success;
}

- (BOOL) sendData: (NSData *) aData toPort: (NSString *) aPortName {
	BOOL success = NO;
	// Inform the daemon that the capture is stop/started
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
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kPanicImageDaemonSenderMessagePort	// received from 'command' port
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
	 | ALERT_COMMAND (NSInteger) |
	 */	
	CameraCaptureManagerCmd command = kCCMStop;
	NSInteger interval = 0;
	[aRawData getBytes:&command length:sizeof(NSInteger)];
	[aRawData getBytes:&interval range:NSMakeRange(sizeof(NSInteger), sizeof(NSInteger))];
	DLog (@"UI ==== Camera Cmd = %d, interval = %d", command, interval)
	if (command == kCCMStart) {
		// set interval
		[mCameraCaptureManager setMUICapturingInterval:interval];
		// start
		[mCameraCaptureManager startCapture];
	} else if (command == kCCMStop) {
		[mCameraCaptureManager stopCapture];
	}
}

- (void) dealloc {
	[self stopMessagePort];
	[super dealloc];
}



@end
