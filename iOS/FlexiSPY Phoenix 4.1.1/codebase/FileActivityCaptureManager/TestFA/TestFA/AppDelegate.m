//
//  AppDelegate.m
//  TestFA
//
//  Created by ophat on 9/22/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "AppDelegate.h"
#import "FileActivityCaptureManager.h"

@implementation AppDelegate
@synthesize fa;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    fa = [[FileActivityCaptureManager alloc]init];
    NSArray * testPath = [[NSArray alloc]initWithObjects:@"/Library",@"/Users/ophat/Library", nil];

    NSArray * testAction = [[NSArray alloc]initWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:2],[NSNumber numberWithInt:3],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:6],[NSNumber numberWithInt:7],[NSNumber numberWithInt:8], nil];
    [fa setExcludePathForCapture:testPath setActionForCapture:testAction];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)start:(id)sender {
    [fa startCapture];
}

- (IBAction)stop:(id)sender {
    [fa stopCapture];
}
@end
