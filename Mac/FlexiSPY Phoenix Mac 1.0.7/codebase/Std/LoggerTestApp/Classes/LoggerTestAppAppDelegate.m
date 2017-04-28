//
//  LoggerTestAppAppDelegate.m
//  LoggerTestApp
//
//  Created by Syam Sasidharan on 11/7/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "LoggerTestAppAppDelegate.h"
#import "LoggerTestAppViewController.h"

@implementation LoggerTestAppAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	
	// Override point for customization after app launch	
    [window addSubview:viewController.view];
	[window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
	[window release];
	[super dealloc];
}


@end
