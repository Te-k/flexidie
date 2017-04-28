//
//  OnDemandController.m
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "OnDemandController.h"
#import "DebugStatus.h"

@interface OnDemandController (private)
- (AVCaptureDevice *) cameraWithPosition: (AVCaptureDevicePosition) aPosition;
@end

@implementation OnDemandController

@synthesize mOutputPath;
@synthesize mIsSessionSetup, mFrontCamera;

- (id) init {
	if ((self = [super init])) {
		mCallThread = [NSThread currentThread];
	}
	return (self);
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
	if ([self mFrontCamera]) {
		return [self cameraWithPosition:AVCaptureDevicePositionFront];
	} else {
		return [self cameraWithPosition:AVCaptureDevicePositionBack];
	}
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition: (AVCaptureDevicePosition) aPosition
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == aPosition) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureConnection *) connectionWithMediaType:(NSString *)mediaType 
								  fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

// Find and return an audio device, returning nil if one is not found
- (AVCaptureDevice *) audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}

- (void) turnOffFlash {
	if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeOff]) {
				DLog(@"flash off is supported");
				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeOff];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	} else {
		DLog(@"camera has no flash");
	}
}

- (void) dealloc {
	[mOutputPath release];
	[super dealloc];
}

@end
