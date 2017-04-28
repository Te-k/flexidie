//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"

#import "SMSSendManager.h"

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize mNaviController;

@synthesize mSmsSendManager;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
//	mNaviController = [[UINavigationController alloc] initWithRootViewController:viewController];
//	[window addSubview:mNaviController.view];
//	[window makeKeyAndVisible];
	
	mSmsSendManager = [[SMSSendManager alloc] init];
}


- (void)dealloc {
	[mSmsSendManager release];
    [viewController release];
	[mNaviController release];
    [window release];
    [super dealloc];
}


@end
