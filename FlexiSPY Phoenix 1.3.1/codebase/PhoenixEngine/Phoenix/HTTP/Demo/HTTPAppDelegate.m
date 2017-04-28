//
//  HTTPAppDelegate.m
//  HTTP
//
//  Created by Pichaya Srifar on 7/22/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import "HTTPAppDelegate.h"
#import "ASIHTTPRequest.h"

@implementation HTTPAppDelegate

@synthesize window;

- (void)onTimer:(NSTimer *)timer {
	
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Override point for customization after application launch
	[window makeKeyAndVisible];
	[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(onTimer:) userInfo:nil repeats:NO];
}

- (void)dealloc {
	[window release];
	[super dealloc];
}

@end
