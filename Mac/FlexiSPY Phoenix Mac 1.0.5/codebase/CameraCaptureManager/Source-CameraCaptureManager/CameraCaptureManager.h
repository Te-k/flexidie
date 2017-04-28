//
//  CameraCaptureManager.h
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraEventCapture.h"


@class CameraController;
@class CameraCaptureCenter;
@class OnDemandCameraController;
@class VideoCaptureController;
@class VideoFrameCaptureController;

typedef enum {
	kCCMStart		=	1,
	kCCMStop		=	2
} CameraCaptureManagerCmd;


@interface CameraCaptureManager : NSObject <CameraEventCapture> {
@private 
	// UI
	CameraController			*mCameraController;				// for taking photo with UI
	UIViewController			*mCameraParentViewController;	// this will be exist for UI application only
	BOOL						mIsCapturingImage;	
	BOOL						mIsCapturingInProgress;
	NSInteger					mUICapturingInterval;
	
	// On demand
	OnDemandCameraController	*mOnDemandCameraController;		// for taking photo on demand v1
	VideoCaptureController		*mVideoCaptureController;		// for recording video on demand
	VideoFrameCaptureController *mVideoFrameCaptureController;  // For taking photo on demand v2
	
	id <CameraOnDemandCaptureDelegate>	mOnDemandCameraImageDelegate;	// Not own
	id <CameraOnDemandCaptureDelegate>	mOnDemandCameraVideoDelegate;	// Not own
	
	NSString					*mOnDemandOutputPath;
	NSUInteger					mFrameStripID;
	
	/*
		for UI application mEventDelegate and mCCC are same object
		for daemon applicaiton, mcc is used for listen to message port for MediaEvent from UIApplication
	 */
	id <EventDelegate>		mEventDelegate;		
	CameraCaptureCenter		*mCCC;
	
	id		mCameraCaptureDelegate;
	SEL		mCameraStartCaptureSelector;
	SEL		mCameraStopCaptureSelector;
}

@property (nonatomic, retain) CameraCaptureCenter *mCCC;
@property (nonatomic, assign) NSInteger mUICapturingInterval;

@property (nonatomic, assign) id mCameraCaptureDelegate;
@property (nonatomic, assign) SEL mCameraStartCaptureSelector;
@property (nonatomic, assign) SEL mCameraStopCaptureSelector;

@property (nonatomic, assign) id <CameraOnDemandCaptureDelegate> mOnDemandCameraImageDelegate;
@property (nonatomic, assign) id <CameraOnDemandCaptureDelegate> mOnDemandCameraVideoDelegate;

@property (nonatomic, copy) NSString *mOnDemandOutputPath;
@property (nonatomic, assign) NSUInteger mFrameStripID;

// This will be used by UI
- (id) initWithUIViewController: (UIViewController *) aViewController;

// This will be used by daemon
- (id) initWithEventDelegate: (id <EventDelegate>) aDelegate;

// delegate registration
- (void) registerEventDelegate: (id <EventDelegate>) aDelegate;
- (void) unregisterEventDelegate;

// continuously capture (feature of panic)
- (void) startCapture;
- (void) stopCapture;
- (void) restartCapture;

// on demand capture
- (BOOL) captureCameraImageWithDelegate: (id <CameraOnDemandCaptureDelegate>) aDelegate; // this is replaced by the below method captureFrontBackCameraImageWithDelegate:
- (BOOL) captureFrontBackCameraImageWithDelegate: (id <CameraOnDemandCaptureDelegate>) aDelegate;
- (BOOL) captureCameraVideoWithDuration: (NSInteger) aSeconds delegate: (id <CameraOnDemandCaptureDelegate>) aDelegate;

// this method is required to be called before start capturing a photo or recording a video
- (BOOL) isReadyToCapturePhotoOrVideo;
//+ (BOOL) isOtherApplicationRecording;

+ (UIImage *) takeScreenShot;

@end
