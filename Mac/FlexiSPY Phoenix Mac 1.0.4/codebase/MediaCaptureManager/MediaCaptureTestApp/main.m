//
//  main.m
//  MediaCaptureTestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 2/9/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaCaptureManager.h"
MediaCaptureManager *mMMSCaptureManager;
int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  	mMMSCaptureManager =[[MediaCaptureManager alloc] initWithEventDelegate:nil andThumbnailDirectoryPath:@"/var/tmp/"];
	[mMMSCaptureManager startCapture];
	NSDate *now = [[NSDate alloc] init];
	NSTimer *timer = [[NSTimer alloc] initWithFireDate:now
											  interval:.01
												target:mMMSCaptureManager
											  selector:@selector(startCapture)
											  userInfo:nil
											   repeats:YES];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
	[runLoop run];
	[pool release];
    return 0;
}
