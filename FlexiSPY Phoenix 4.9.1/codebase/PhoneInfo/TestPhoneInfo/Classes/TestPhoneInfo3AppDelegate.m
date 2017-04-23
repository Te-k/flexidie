//
//  TestPhoneInfo3AppDelegate.m
//  TestPhoneInfo3
//
//  Created by Dominique  Mayrand on 11/4/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestPhoneInfo3AppDelegate.h"
#import "TestPhoneInfo3ViewController.h"

@implementation TestPhoneInfo3AppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	
	// Override point for customization after app launch	
    [window addSubview:viewController.view];
	[window makeKeyAndVisible];
	
	NSLog(@"Launched");
}


- (void)dealloc {
    [viewController release];
	[window release];
	[super dealloc];
}


@end
