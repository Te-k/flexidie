//
//  main.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 11/30/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recorder.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
   // int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
	
	Recorder *rec = [[Recorder alloc] init];
	[rec testStartRecord];
	//[rec testStartRecordWhilePreviosRecIsInProgress];
	//[rec testStartRecordWithLongInterval];
	//[rec testStopRecordingBeforeCompleteInterval];
	//[rec testIsRecording];
	
	CFRunLoopRun();
    [pool release];
    return retVal;
}
