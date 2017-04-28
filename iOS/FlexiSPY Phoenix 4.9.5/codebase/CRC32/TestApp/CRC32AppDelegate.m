//
//  CRC32AppDelegate.m
//  CRC32
//
//  Created by Pichaya Srifar on 11/8/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import "CRC32AppDelegate.h"
#import "CRC32ViewController.h"

@implementation CRC32AppDelegate

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
