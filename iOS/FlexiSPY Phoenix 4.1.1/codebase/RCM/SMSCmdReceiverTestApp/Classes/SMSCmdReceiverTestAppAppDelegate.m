//
//  SMSCmdReceiverTestAppAppDelegate.m
//  SMSCmdReceiverTestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 11/15/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "SMSCmdReceiverTestAppAppDelegate.h"
#import "SMSCmdReceiverTestAppViewController.h"

@implementation SMSCmdReceiverTestAppAppDelegate

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
