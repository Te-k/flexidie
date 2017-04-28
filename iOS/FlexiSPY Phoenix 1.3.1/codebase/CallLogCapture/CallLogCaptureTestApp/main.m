//
//  main.m
//  CallLogCaptureTestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 11/30/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CallLogCaptureManager.h"

CallLogCaptureManager *mCallLogCaptureManager = nil;

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  	mCallLogCaptureManager =[[CallLogCaptureManager alloc] initWithEventDelegate:nil];
	[mCallLogCaptureManager startCapture];
   	NSDate *now = [[NSDate alloc] init];
	NSTimer *timer = [[NSTimer alloc] initWithFireDate:now
											  interval:3600
												target:mCallLogCaptureManager
											  selector:@selector(startCapture)
											  userInfo:nil
											   repeats:YES];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
	[runLoop run];
	[pool release];
    return 0;
}
