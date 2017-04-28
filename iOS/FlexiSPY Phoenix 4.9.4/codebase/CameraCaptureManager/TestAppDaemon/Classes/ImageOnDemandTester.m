//
//  ImageOnDemandTester.m
//  TestAppDaemon
//
//  Created by Benjawan Tanarattanakorn on 12/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ImageOnDemandTester.h"
#import "DaemonPrivateHome.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation ImageOnDemandTester

@synthesize mCameraCaptureManager;

- (id) init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

// Getter
- (CameraCaptureManager *) mCameraCaptureManager {
	if (!mCameraCaptureManager) {
		
		mCameraCaptureManager			= [[CameraCaptureManager alloc] initWithEventDelegate:nil];
		NSString* cameraCapturePath		= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"media/capture/"];
		[DaemonPrivateHome createDirectoryAndIntermediateDirectories:cameraCapturePath];		
		
		[mCameraCaptureManager setMOnDemandOutputPath:cameraCapturePath];	
	}
	return mCameraCaptureManager;
		
}



- (void) processRemoteImageCapture {
	
	//NSLog (@"[ALAssetsLibrary authorizationStatus] %d", [ALAssetsLibrary authorizationStatus]);
	id <CameraEventCapture> cameraEventCapture = [self mCameraCaptureManager];	
	
	if ([cameraEventCapture captureCameraImageWithDelegate:self]) {
		NSLog (@"Capturing camera image silently");
	} else {
		NSLog (@"Cannot capturing camera image silently");
	}
}

- (void) cameraDidFinishCapture: (NSString *) aOutputPath error: (NSError *) aError {
	// Regardless of aError at this time
	NSLog (@"--------------- cameraDidFinishCapture ---------------");
	NSLog (@"aOutputPath %@",aOutputPath);
	NSLog (@"cameraDidFinishCapture %@", aError);
	[self processRemoteImageCapture];
}



@end
