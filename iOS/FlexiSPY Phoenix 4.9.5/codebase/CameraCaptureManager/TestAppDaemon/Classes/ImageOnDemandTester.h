//
//  ImageOnDemandTester.h
//  TestAppDaemon
//
//  Created by Benjawan Tanarattanakorn on 12/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CameraCaptureManager.h"
#import "CameraEventCapture.h"


@interface ImageOnDemandTester : NSObject <CameraOnDemandCaptureDelegate> {

}

@property (nonatomic, readonly) CameraCaptureManager *mCameraCaptureManager;

- (void) processRemoteImageCapture;

@end
