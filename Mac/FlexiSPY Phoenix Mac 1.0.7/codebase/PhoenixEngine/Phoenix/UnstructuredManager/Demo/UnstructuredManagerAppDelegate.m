//
//  UnstructuredManagerAppDelegate.m
//  UnstructuredManager
//
//  Created by Pichaya Srifar on 7/20/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import "UnstructuredManagerAppDelegate.h"

#import "CSMDeviceManager.h"

@implementation UnstructuredManagerAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
    window.rootViewController = [[[UINavigationController alloc] init] autorelease];
	
	[NSTimer scheduledTimerWithTimeInterval:0 
					target:self 
					selector:@selector(testUnstructuredManager:) 
					userInfo:nil 
					repeats:NO];
	
	NSLog(@"Temporary derectory : %@", NSTemporaryDirectory());
}

-(void)testUnstructuredManager:(NSTimer *)timer {
	
    UIDevice *device = [UIDevice currentDevice];
	NSString *deviceUDID = @"126e3bdc50a92b03b6225a6c03b8b7b0acd93893";
    if ([device respondsToSelector:@selector(uniqueIdentifier)]) {
        NSString *uniqueID = [device performSelector:@selector(uniqueIdentifier)];
        if (uniqueID != nil) {
            deviceUDID = uniqueID;
        }
    }
    NSLog(@"deviceUDID = %@", deviceUDID);
    
    [[CSMDeviceManager sharedCSMDeviceManager] setMIMEI:deviceUDID];
	
	UnstructuredManager *manager = [[UnstructuredManager alloc] init];
	[manager doKeyExchangev2:1 withEncodingType:1];
//	[manager doAckSecure:1 withSessionId:654];
	[manager doAck:1 withSessionId:654 withDeviceId:deviceUDID];
//	[manager doPing:1];
	[manager release];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
