//
//  TestPanicAppDelegate.m
//  TestPanic
//
//  Created by Dominique  Mayrand on 11/16/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestPanicAppDelegate.h"
#import "TestPanicViewController.h"

@implementation TestPanicAppDelegate

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
