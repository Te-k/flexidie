//
//  CommandServiceManagerAppDelegate.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 7/29/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import "CommandServiceManagerAppDelegate.h"

@implementation CommandServiceManagerAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Override point for customization after application launch
	[window addSubview:[viewController view]];
	[window makeKeyAndVisible];
	
}



- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
