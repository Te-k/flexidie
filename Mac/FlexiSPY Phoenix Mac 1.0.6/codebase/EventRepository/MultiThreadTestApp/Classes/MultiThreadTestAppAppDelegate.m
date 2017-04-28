//
//  MultiThreadTestAppAppDelegate.m
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 10/10/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "MultiThreadTestAppAppDelegate.h"
#import "MultiThreadTestAppViewController.h"

@implementation MultiThreadTestAppAppDelegate

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
