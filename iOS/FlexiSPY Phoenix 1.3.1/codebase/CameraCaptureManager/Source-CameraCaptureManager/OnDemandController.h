//
//  OnDemandController.h
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVCaptureDevice;
@class AVCaptureConnection;

@interface OnDemandController : NSObject {
@private
	NSString	*mOutputPath;
	
@protected
	NSThread	*mCallThread;		// Not own
	BOOL		mIsSessionSetup;
}

@property (nonatomic, copy) NSString *mOutputPath;
@property (nonatomic, readonly) BOOL mIsSessionSetup;

- (AVCaptureDevice *)	backFacingCamera;
- (AVCaptureConnection *) connectionWithMediaType:(NSString *)mediaType 
								  fromConnections:(NSArray *)connections;
- (AVCaptureDevice *) audioDevice;
- (void) turnOffFlash;

@end
