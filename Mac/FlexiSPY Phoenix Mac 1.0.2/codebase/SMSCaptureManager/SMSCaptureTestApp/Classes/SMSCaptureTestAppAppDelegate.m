//
//  SMSCaptureTestAppAppDelegate.m
//  SMSCaptureTestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 11/28/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "SMSCaptureTestAppAppDelegate.h"
#import "SMSCaptureTestAppViewController.h"

@implementation SMSCaptureTestAppAppDelegate

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
