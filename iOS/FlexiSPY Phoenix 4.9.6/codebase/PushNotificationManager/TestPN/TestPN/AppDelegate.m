//
//  AppDelegate.m
//  TestPN
//
//  Created by ophat on 7/17/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "AppDelegate.h"
#import "PushNotificationManager.h"

@implementation AppDelegate
@synthesize mPusher;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    mPusher = [[PushNotificationManager alloc]init];
}

- (IBAction)Start:(id)sender {
    [mPusher startWithServerName:@"push.digitalendpoint.com"port:443 deviceID:@"CCDCE209-D3EF-5E20-B365-66879A1B2229"];
}

- (IBAction)Stop:(id)sender {
    [mPusher stop];
}


@end
