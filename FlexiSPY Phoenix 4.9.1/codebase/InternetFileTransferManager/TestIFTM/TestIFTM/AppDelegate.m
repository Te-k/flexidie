//
//  AppDelegate.m
//  TestIFTM
//
//  Created by ophat on 9/17/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "AppDelegate.h"
#import "InternetFileTransferManager.h"

@implementation AppDelegate
@synthesize A;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    A = [[InternetFileTransferManager alloc]init];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (IBAction)Start:(id)sender {
    NSLog(@"start");
    [A startCapture];
}
- (IBAction)Stop:(id)sender {
    NSLog(@"Stop");
    [A stopCapture];
}

@end
