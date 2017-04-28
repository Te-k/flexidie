//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "TestAppViewController.h"

#import "SenderThread.h"
#import "ReceiverThread.h"
#import "ReceiverMessagePortThread.h"
#import "SenderMessagePortThread.h"

@implementation TestAppAppDelegate

@synthesize window;
@synthesize viewController;

@synthesize mSenderThread;
@synthesize mReceiverThread;

@synthesize mSenderMessagePortThread, mReceiverMessagePortThread;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	mSenderThread = [[SenderThread alloc] init];
	mReceiverThread = [[ReceiverThread alloc] init];
	
	mSenderMessagePortThread = [[SenderMessagePortThread alloc] init];
	mReceiverMessagePortThread = [[ReceiverMessagePortThread alloc] init];
	
}


- (void)dealloc {
	[mReceiverThread release];
	[mSenderThread release];
	[mSenderMessagePortThread release];
	[mReceiverMessagePortThread release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end
