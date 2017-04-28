//
//  TestAppViewController.h
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/5/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CameraCaptureManager;


@interface TestAppViewController : UIViewController {
@private 
	CameraCaptureManager *mCameraCaptureManager;
	CameraCaptureManager *mReceiverCameraCaptureManager;
}

- (void) startCapturingPicture;
- (void) stopCapturingPicture;

@end

