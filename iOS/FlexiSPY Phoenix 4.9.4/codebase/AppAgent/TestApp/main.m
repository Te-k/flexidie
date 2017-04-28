//
//  main.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 3/27/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemoryCheckerCaller.h"
#import "DiskSpaceCheckerCaller.h"
#import "AppAgentCaller.h"
#import "AppAgentManager.h"
#import "Battest.h"
#import "TestAppAppDelegate.h"

int main(int argc, char *argv[]) {
    
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
	//Caller *caller = [[Caller alloc] init];
	//DiskSpaceCheckerCaller *diskCaller = [[DiskSpaceCheckerCaller alloc] init];
	//AppAgentCaller *appAgentCaller = [[AppAgentCaller alloc] init];

	//Battest *bat = [[Battest alloc] init];
	//AppAgentCaller *appAgentCaller = [[AppAgentCaller alloc] init];
	
	AppAgentManager *appAgentManager = [[AppAgentManager alloc] initWithEventDelegate:nil];
//	[appAgentManager startListenBatteryWarningLevel];
//	[appAgentManager startHandleUncaughtException];
    [appAgentManager startListenMemoryWarningLevel];

//	[appAgentManager startListenDiskSpaceWarningLevel];
//	[appAgentManager setThresholdInMegabyteForDiskSpaceWarningLevel:0];
//	[appAgentManager setThresholdInMegabyteForDiskSpaceUrgentLevel:0];
//	[appAgentManager setThresholdInMegabyteForDiskSpaceCriticalLevel:12120];
	
//	[appAgentManager startListenSystemPowerAndWakeIphone];
//	[bat batteryLevelDidChange:1];
//	[bat batteryLevelDidChange:0.9];
//	NSLog(@"------------");
//	[bat batteryLevelDidChange:0.5];
//	NSLog(@"------------");
//	[bat batteryLevelDidChange:0.2];
//	NSLog(@"------------");	
//	[bat batteryLevelDidChange:0.19];
//	NSLog(@"------------");	
//	[bat batteryLevelDidChange:0.10];
//	NSLog(@"------------");
//	[bat batteryLevelDidChange:0.9];
//	NSLog(@"------------");
//	[bat batteryLevelDidChange:0.20];
//	NSLog(@"------------");
//	[bat batteryLevelDidChange:0.09];
    NSLog(@"&&&&&&&&&&&&&&&&&&&&&& start application &&&&&&&&&&&&&&&&&&");
//	TestAppAppDelegate *delegate = [[TestAppAppDelegate alloc] init];
//	[delegate performSelector:@selector(makeArrayOutOfBoundException) withObject:nil afterDelay:20];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:[MemoryCheckerCaller class]
                                   selector:@selector(buildupMemory)
                                   userInfo:nil
                                    repeats:YES];
	
	CFRunLoopRun();
//	[appAgentManager stopListenSystemPowerAndWakeIphone];

	[appAgentManager release];
	
    [pool release];
    return retVal;
}
	
