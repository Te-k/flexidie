//
//  main.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/5/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraCaptureManager.h"

int main(int argc, char *argv[]) {    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"main function 1");
    int retVal = UIApplicationMain(argc, argv, nil, nil);
	NSLog(@"main function 2");
//	int retVal = 0;
//	CameraCaptureManager *mReceiverCameraCaptureManager = [[CameraCaptureManager alloc] initWithEventDelegate:nil];
//	[mReceiverCameraCaptureManager captureCameraVideo:10];
//	[mReceiverCameraCaptureManager performSelector:@selector(captureCameraImage) withObject:nil afterDelay:5];
//	[mReceiverCameraCaptureManager performSelector:@selector(captureCameraImage) withObject:nil afterDelay:5];
//	[mReceiverCameraCaptureManager performSelector:@selector(captureCameraImage) withObject:nil afterDelay:20];	
	//[NSTimer scheduledTimerWithTimeInterval:5 target:mReceiverCameraCaptureManager selector:@selector(isReadyToCapturePhotoOrVideo) userInfo:nil repeats:YES];	
//	CFRunLoopRun();
    [pool release];
    return retVal;
}
