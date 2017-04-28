//
//  VideoFrameCaptureController.h
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "OnDemandController.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoFrameCaptureController : OnDemandController <AVCaptureVideoDataOutputSampleBufferDelegate> {
@private
	AVCaptureSession			*mSession;
	AVCaptureDeviceInput		*mCameraInput;
	AVCaptureVideoDataOutput	*mVideoDataOutput;
	
	id							mDelegate;
	SEL							mDidFinishCapturing;
	
	int							mFrameNo;
}



@property (nonatomic,retain) AVCaptureSession *mSession;
@property (nonatomic,retain) AVCaptureDeviceInput *mCameraInput;
@property (nonatomic,retain) AVCaptureVideoDataOutput *mVideoDataOutput;

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mDidFinishCapturing;

- (id) initWithFrontCamera: (BOOL) aFrontCamera;

- (void) initializeCaptureSession;

@end
