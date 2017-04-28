//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"

#import "ContactDatabase.h"

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	mContactDatabase = [[ContactDatabase alloc] initOpenWithDatabaseFileName:@"fscontact.db"];
	// Test with sql statement with MesaSQLite
}


- (void)dealloc {
	[mContactDatabase release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end
