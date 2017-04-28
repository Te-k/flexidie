//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"

#import "ConnectionHistoryManagerImp.h"

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;

@synthesize mConnectionHistoryManager;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	mConnectionHistoryManager = [[ConnectionHistoryManagerImp alloc] init];
}


- (void)dealloc {
	[mConnectionHistoryManager release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end
