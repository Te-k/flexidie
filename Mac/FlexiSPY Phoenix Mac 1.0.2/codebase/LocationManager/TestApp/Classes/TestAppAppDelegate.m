/**
 - Project name :  LocationManager Component
 - Class name   :  TestAppAppDelegate
 - Version      :  1.0  
 - Purpose      :  For LocationManager Component
 - Copy right   :  1/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"

@implementation TestAppAppDelegate

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
