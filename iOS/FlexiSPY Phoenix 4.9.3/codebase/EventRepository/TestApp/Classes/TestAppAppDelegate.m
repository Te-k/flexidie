//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Use user define priority
	[window addSubview:viewController.view];
    [window makeKeyAndVisible];

}

- (void)dealloc {
	[viewController release];
    [window release];
    [super dealloc];
}


@end
