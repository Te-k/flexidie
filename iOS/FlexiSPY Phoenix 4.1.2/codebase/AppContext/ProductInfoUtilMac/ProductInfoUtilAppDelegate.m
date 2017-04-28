//
//  ProductInfoUtilAppDelegate.m
//  ProductInfoUtil
//
//  Created by Benjawan Tanarattanakorn on 12/2/54 BE.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProductInfoUtilAppDelegate.h"
#import "ProductInfoUtilViewController.h"

@implementation ProductInfoUtilAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

	// Set the view controller as the window's root view controller and display.
    //self.window.rootViewController = self.viewController;
	[window addSubview:viewController.view];
    [self.window makeKeyAndVisible];

    return YES;
}
- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
