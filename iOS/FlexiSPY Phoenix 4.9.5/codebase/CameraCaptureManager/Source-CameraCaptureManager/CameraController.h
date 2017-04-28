//
//  CameraController.h
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraCaptureManager;

// note that UIImagePickerController subclass is required to conform to UIImagePickerControllerDelegate and UINavigationControllerDelegate
@interface CameraController : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
@private
	BOOL						mShouldCapture;
	NSTimer						*mWatchdogTimer;
	
	id							mDelegate;
	SEL							mRestartCaptureSelector;
	SEL							mCapturePathSelector;
	SEL							mDidFinishCapturing;
	NSInteger					mCapturingInterval;
}


@property (nonatomic, assign) BOOL mShouldCapture;	// this is set by CameraCaptureManager and itself

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mRestartCaptureSelector;
@property (nonatomic, assign) SEL mCapturePathSelector;
@property (nonatomic, assign) SEL mDidFinishCapturing;
@property (nonatomic, assign) NSInteger mCapturingInterval;

+ (BOOL) hasCamera;
- (void) displayAsModalViewByController: (UIViewController*) aController  
							   animated: (BOOL) aAnimated;
- (void) dismissModalViewController: (UIViewController *) aController animated: (BOOL) aAnimated;
- (void) takePicture;

@end
