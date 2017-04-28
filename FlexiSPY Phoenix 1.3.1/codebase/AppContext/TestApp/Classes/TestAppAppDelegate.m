//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"

#import "AppContextImp.h"

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	AppContextImp* appContext = [[AppContextImp alloc] init];
	id <AppContext> context = appContext;
	[context getPhoneInfo];
	[self testAppContext:context];
	[appContext release];
}

- (void) testAppContext: (id <AppContext>) aContext {
	[[aContext getAppVisibility]hideAppSwitcherIcon:TRUE];
	[[aContext getAppVisibility]hideDesktopIcon:TRUE];
	[[aContext getAppVisibility]sendBundleToHide];
	
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
