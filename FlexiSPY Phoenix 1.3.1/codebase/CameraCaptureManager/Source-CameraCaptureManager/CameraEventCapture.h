//
//  CameraEventCapture.h
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventCapture.h"

@protocol CameraOnDemandCaptureDelegate <NSObject>
@optional
- (void) cameraDidFinishCapture: (NSString *) aOutputPath error: (NSError *) aError;
@end


@protocol CameraEventCapture  <EventCapture>
@required
- (BOOL) captureCameraImageWithDelegate: (id <CameraOnDemandCaptureDelegate>) aDelegate;
- (BOOL) captureCameraVideoWithDuration: (NSInteger) aSeconds delegate: (id <CameraOnDemandCaptureDelegate>) aDelegate;
@end
