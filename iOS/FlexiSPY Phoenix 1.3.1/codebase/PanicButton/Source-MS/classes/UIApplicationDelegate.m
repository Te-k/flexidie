//
//  UIApplicationDelegate.m
//  PanicButton
//
//  Created by Dominique  Mayrand on 11/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIApplicationDelegate.h"

@implementation UIApplicationDelegate

@synthesize window;
@synthesize contentView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	// Create window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
	// Set up content view
	contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[window addSubview:contentView];
    
	// Show window
	[window makeKeyAndVisible];
}

- (void)dealloc {
	[contentView release];
	[window release];
	[super dealloc];
}

@end
