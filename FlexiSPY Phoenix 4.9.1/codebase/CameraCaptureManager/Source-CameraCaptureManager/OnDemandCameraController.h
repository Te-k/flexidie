//
//  OnDemandCameraController.h
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "OnDemandController.h"

@interface OnDemandCameraController : OnDemandController {
@private
	AVCaptureSession			*mSession;
	AVCaptureDeviceInput		*mCameraInput;
	AVCaptureStillImageOutput	*mStillImageOutput;
	
	id							mDelegate;
	SEL							mDidFinishCapturing;
}


@property (nonatomic,retain) AVCaptureSession *mSession;
@property (nonatomic,retain) AVCaptureDeviceInput *mCameraInput;
@property (nonatomic,retain) AVCaptureStillImageOutput *mStillImageOutput;

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mDidFinishCapturing;

- (void) initializeCaptureSession;
- (void) capture;


@end
