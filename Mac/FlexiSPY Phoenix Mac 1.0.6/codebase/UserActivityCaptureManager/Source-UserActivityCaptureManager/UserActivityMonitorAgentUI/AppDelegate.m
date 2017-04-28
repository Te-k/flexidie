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

#include <stdio.h>
#include <utmpx.h>

@interface AppDelegate (private)

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    pid_t ppid = 0;
    NSArray *launchArgs = [[NSProcessInfo processInfo] arguments];
    if (launchArgs.count > 1) {
        ppid = [[launchArgs objectAtIndex:1] intValue];
    }
    
    mUAMAManager = [[UAMAManager alloc] init];
    mUAMAManager.mPPID = ppid;
    [mUAMAManager startActivityMonitor];
    
    //get_all_users_log_in_out_time();
    
    DLog(@"User activity monitor start...");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

int get_all_users_log_in_out_time() {
    struct utmpx *bp;
    char *ct;
    
    setutxent_wtmp(0); // 0 = reverse chronological order
    while ((bp = getutxent_wtmp()) != NULL) {
        switch (bp->ut_type) {
            case USER_PROCESS:
                ct = ctime(&bp->ut_tv.tv_sec);
                printf("%s login %s", bp->ut_user, ct);
                break;
            case DEAD_PROCESS:
                ct = ctime(&bp->ut_tv.tv_sec);
                printf("%s logout %s", bp->ut_user, ct);
                break;
                
            default:
                break;
        }
    };
    endutxent_wtmp();
    
    return 0;
}

- (void) dealloc {
    [mUAMAManager release];
    [super dealloc];
}

@end
