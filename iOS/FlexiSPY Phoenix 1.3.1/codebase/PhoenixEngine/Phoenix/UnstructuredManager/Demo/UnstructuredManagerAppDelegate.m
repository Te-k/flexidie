//
//  UnstructuredManagerAppDelegate.m
//  UnstructuredManager
//
//  Created by Pichaya Srifar on 7/20/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import "UnstructuredManagerAppDelegate.h"

@implementation UnstructuredManagerAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
	
	[NSTimer scheduledTimerWithTimeInterval:0 
					target:self 
					selector:@selector(testUnstructuredManager:) 
					userInfo:nil 
					repeats:NO];
	
	
}

-(void)testUnstructuredManager:(NSTimer *)timer {
	
	NSString *deviceUDID = [[UIDevice currentDevice] uniqueIdentifier];
	
	UnstructuredManager *manager = [[UnstructuredManager alloc] init];
	[manager doKeyExchange:1 withEncodingType:1];
	[manager doAckSecure:1 withSessionId:654];
	[manager doAck:1 withSessionId:654 withDeviceId:deviceUDID];
	[manager doPing:1];
	[manager release];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
