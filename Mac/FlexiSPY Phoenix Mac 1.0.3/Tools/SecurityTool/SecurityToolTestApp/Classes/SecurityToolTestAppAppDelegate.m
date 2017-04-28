//
//  SecurityToolTestAppAppDelegate.m
//  SecurityToolTestApp
//
//  Created by admin on 10/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "SecurityToolTestAppAppDelegate.h"
#import "SecurityToolTestAppViewController.h"

@implementation SecurityToolTestAppAppDelegate

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
