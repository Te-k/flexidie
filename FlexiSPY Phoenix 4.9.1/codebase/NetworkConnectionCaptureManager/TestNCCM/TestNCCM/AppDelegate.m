//
//  AppDelegate.m
//  TestNCCM
//
//  Created by ophat on 7/10/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "AppDelegate.h"



@implementation AppDelegate
@synthesize mNCM;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    mNCM = [[NetworkConnectionCaptureManager alloc]init];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (IBAction)start:(id)sender {
    [mNCM startCapture];
}

- (IBAction)stop:(id)sender {
    [mNCM stopCapture];
}

-(void) dealloc{
    [mNCM release];
    [super dealloc];
}

@end
