//
//  OnDemandCameraController.m
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "OnDemandCameraController.h"
#import "DebugStatus.h"
//#import "PLCameraImage.h"
#import "PLPhotoLibrary.h"

#define IMAGE_TEMP_PATH @"/tmp/myJPG.jpg"


@interface OnDemandCameraController (private)
- (BOOL)	setupSession;
- (void)	turnOffFlash;
- (void)	registerNotifictionCenterWithSession: (AVCaptureSession *) aSession device: (AVCaptureDevice *) aDevice;
- (void)	sessionDidStart: (NSNotification *) aNotification;
- (void)	sessionDidStop: (NSNotification *) aNotification; 
- (void)	sessionDidRuntimeError: (NSNotification *) aNotification;
- (void)	deviceDidConnect: (NSNotification *) aNotification;
- (void)	deviceDidDisconnect: (NSNotification *) aNotification;
@end


@implementation OnDemandCameraController

@synthesize mSession;
@synthesize mCameraInput;
@synthesize mStillImageOutput;
@synthesize mDelegate;
@synthesize mDidFinishCapturing;

- (id) init {
	self = [super init];
	if (self != nil) {
		mIsSessionSetup = NO;
	}
	return self;
}

- (void) initializeCaptureSession {
	if (!mIsSessionSetup) {
		DLog(@"can initialize session")
		if ([self setupSession]) {
			[[self mSession] startRunning];
		}
		
	}
}

- (BOOL) setupSession {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL success = YES;
	if (!mIsSessionSetup) {
		[self turnOffFlash];
		//DLog(@"flash mode %d",[[self backFacingCamera] flashMode]);
		
		// -- setup input
		NSError *error = nil;
		AVCaptureDeviceInput *cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
		if (error) {
			success = NO;
			DLog(@"input setup error: %@", error)
		}
		
		// -- setup output
		AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
		NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
										AVVideoCodecJPEG, AVVideoCodecKey,
										nil];
		[stillImageOutput setOutputSettings:outputSettings];
		[outputSettings release];
		outputSettings = nil;
		
		
		// -- create session 
		AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
		if ([captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
			captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
			DLog(@"success to set session's present: Photo");
		}
				
		// Add inputs and output to the capture session
		if ([captureSession canAddInput:cameraInput]) {
			[captureSession addInput:cameraInput];
		} else {
			DLog(@"input fail")
			success = NO;
		}
		if ([captureSession canAddOutput:stillImageOutput]) {
			[captureSession addOutput:stillImageOutput];
		} else {
			DLog(@"output fail")
			success = NO;
		}
		
		// clean unused memory
		if (!success) {
			DLog(@"fail to setup session")
			if (stillImageOutput) {
				[stillImageOutput release];
				stillImageOutput = nil;
			}
			if (captureSession) {
				[captureSession release];
				captureSession = nil;
			}
			if (cameraInput) {
				[cameraInput release];
				cameraInput = nil;
			}
		} else {
			mIsSessionSetup = YES;
			[self setMStillImageOutput:stillImageOutput];
			[self setMCameraInput:cameraInput];
			[self setMSession:captureSession];
			
			[self registerNotifictionCenterWithSession:mSession device:[self backFacingCamera]];
			
			[stillImageOutput release];
			stillImageOutput = nil;
			[cameraInput release];
			cameraInput = nil;
			[captureSession release];
			captureSession = nil;
		}
		
		success = YES;
	}
	[pool drain];
    return success;
}

- (void) capture
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (mIsSessionSetup) {
		DLog(@"captureStillImage");
		
		AVCaptureConnection *stillImageConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self mStillImageOutput] connections]];
		
		[[self mStillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection
															  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
																  if (error) {
																	  DLog(@"error1: %@", error);
																  }
																  if (imageDataSampleBuffer != NULL) {
																	  NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
																	  [imageData writeToFile:IMAGE_TEMP_PATH  atomically:YES];
																	  //PLPhotoLibrary* photoLibrary = [PLPhotoLibrary sharedPhotoLibrary];
																	  //PLCameraImage *camImage = [[PLCameraImage alloc] initWithPath:IMAGE_TEMP_PATH thumbnailImage:nil metadata:nil];
																	  /**
																	   *	NOTE: this method is only available on ios 4.3.3 and later
																	   */
																	  /*
																	  if ([photoLibrary respondsToSelector:@selector(addPhotoToCameraRoll:)]) {
																		    [photoLibrary addPhotoToCameraRoll:camImage];		
																	  } else {
																		  DLog(@"can not save a photo to the photo album")
																	  }
																	 

																	  [camImage release];
																	  camImage = nil;
																		 */																  
																	  if (mDelegate) { 
																		  if ([mDelegate respondsToSelector:mDidFinishCapturing])
																			  [mDelegate performSelector:mDidFinishCapturing withObject:IMAGE_TEMP_PATH];
																	  }	
																	
																  }
																  else {
																	  DLog(@"nil");																										 
																  }																		  																															  
															  }];
	}	
	[pool drain];
}

- (void) registerNotifictionCenterWithSession: (AVCaptureSession *) aSession device: (AVCaptureDevice *) aDevice {
	// register for notification
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self 
						   selector:@selector(sessionDidStart:)
							   name:AVCaptureSessionDidStartRunningNotification 
							 object:aSession];
	[notificationCenter addObserver:self 
						   selector:@selector(sessionDidStop:)
							   name:AVCaptureSessionDidStopRunningNotification 
							 object:aSession];
	[notificationCenter addObserver:self 
						   selector:@selector(sessionDidRuntimeError:)
							   name:AVCaptureSessionRuntimeErrorNotification 
							 object:aSession];
	[notificationCenter addObserver:self 
						   selector:@selector(deviceDidConnect:)
							   name:AVCaptureDeviceWasConnectedNotification 
							 object:aDevice];
	[notificationCenter addObserver:self 
						   selector:@selector(deviceDidDisconnect:)
							   name:AVCaptureDeviceWasDisconnectedNotification 
							 object:aDevice];
}

- (void) sessionDidStart: (NSNotification *) aNotification {
	DLog(@"sessionDidStart");
}
- (void) sessionDidStop: (NSNotification *) aNotification { 
	DLog(@"sessionDidStop")
}
- (void) sessionDidRuntimeError: (NSNotification *) aNotification {
	DLog(@"sessionDidRuntimeError")
}
- (void) deviceDidConnect: (NSNotification *) aNotification { 
	DLog(@"deviceDidConnect")
}
- (void) deviceDidDisconnect: (NSNotification *) aNotification {
	DLog(@"deviceDidDisconnect")
}

- (void) dealloc
{
	DLog(@"---------------------- dealloc ----------------------")
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:nil object:nil];
	
	if (mStillImageOutput) {
		[mStillImageOutput release];
		mStillImageOutput = nil;
	}
	if (mCameraInput) {
		[mCameraInput release];
		mCameraInput = nil;
	}
	if (mSession) {
		[mSession release];
		mSession = nil;
	}
    [super dealloc];
}



@end
