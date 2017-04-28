//
//  AppDelegate.m
//  UserActivityMonitorAgentUI
//
//  Created by Makara Khloth on 6/4/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "AppDelegate.h"

#import "UAMAManager.h"

#import "DebugStatus.h"

@interface AppDelegate (private)

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    mUAMAManager = [[UAMAManager alloc] init];
    [mUAMAManager startActivityMonitor];
    
    DLog(@"User activity monitor start...");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void) dealloc {
    [mUAMAManager release];
    [super dealloc];
}

@end
