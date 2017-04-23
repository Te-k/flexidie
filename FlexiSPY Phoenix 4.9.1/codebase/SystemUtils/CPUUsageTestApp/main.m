//
//  main.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CPUUsage.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
	
	int retVal = 0;
	
	CPUUsage *cpuUsage = [[CPUUsage alloc] init];
	
	NSLog(@"Going to shedule the timer");
	
	[NSTimer scheduledTimerWithTimeInterval:5.00 
									 target:cpuUsage
								   selector:@selector(cpuUsage:)
								   userInfo:nil
									repeats:YES];
	
	CFRunLoopRun();
	
	NSLog(@"Ending the run loop . . .");
	
	[cpuUsage release];
	
    [pool release];
    return retVal;
}
