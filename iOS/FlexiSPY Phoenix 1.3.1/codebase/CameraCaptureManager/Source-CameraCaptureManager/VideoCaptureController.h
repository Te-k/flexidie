//
//  VideoCaptureController.h
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnDemandController.h"
#import <AVFoundation/AVFoundation.h>


@class AVCaptureSession;
@class AVCaptureDeviceInput;
@class AVCaptureMovieFileOutput;

@interface VideoCaptureController : OnDemandController <AVCaptureFileOutputRecordingDelegate> {
@private
	AVCaptureSession			*mSession;
	AVCaptureDeviceInput		*mCameraInput;
	AVCaptureDeviceInput		*mAudioInput;
	AVCaptureMovieFileOutput	*mMovieFileOutput;
	
	id							mDelegate;
	SEL							mDidFinishCapturing;
}

@property (nonatomic,retain) AVCaptureSession *mSession;
@property (nonatomic,retain) AVCaptureDeviceInput *mCameraInput;
@property (nonatomic,retain) AVCaptureDeviceInput *mAudioInput;
@property (nonatomic,retain) AVCaptureMovieFileOutput *mMovieFileOutput;

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mDidFinishCapturing;

- (void) initializeCaptureSession;
- (void) startCaptureVideo;
- (void) stopCaptureVideo;

@end
