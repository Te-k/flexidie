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
	[appAgentManager startListenSystemPowerAndWakeIphone];
	
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
	
	CFRunLoopRun();
	
	[appAgentManager stopListenSystemPowerAndWakeIphone];
	[appAgentManager release];
	
    [pool release];
    return retVal;
}
	