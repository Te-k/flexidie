//
//  ActivationAppDelegate.m
//  Activation
//
//  Created by Pichaya Srifar on 11/1/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import "ActivationAppDelegate.h"
#import "ActivationViewController.h"

@implementation ActivationAppDelegate

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
