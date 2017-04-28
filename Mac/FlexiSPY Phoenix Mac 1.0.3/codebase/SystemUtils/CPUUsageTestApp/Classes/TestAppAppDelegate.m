//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"

#import "CPUUsage.h"

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	CPUUsage *cpuUsage = [[CPUUsage alloc] init];
	
	NSLog(@"Going to shedule the timer");
	
	[NSTimer scheduledTimerWithTimeInterval:5.00 target:cpuUsage selector:@selector(cpuUsage:) userInfo:nil repeats:YES];
	
	[cpuUsage release];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
