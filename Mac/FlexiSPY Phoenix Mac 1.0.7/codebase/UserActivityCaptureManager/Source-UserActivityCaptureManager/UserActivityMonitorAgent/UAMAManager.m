//
//  UAMAManager.m
//  UserActivityCaptureManager
//
//  Created by Makara Khloth on 6/4/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "UAMAManager.h"

#import "DebugStatus.h"

#include <sys/sysctl.h>

#define OPProcessValueUnknown UINT_MAX

@interface UAMAManager (private)
- (void)handleQuitEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent;
- (void) userLogoff;
- (void) logoffNotification: (NSNotification *) aNotification;
@end

@implementation UAMAManager

@synthesize mPPID;

- (void) startActivityMonitor {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    [processInfo disableSuddenTermination];
    
    // Apple event only work for none UI element
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleQuitEvent:withReplyEvent:) forEventClass:kCoreEventClass andEventID:kAEQuitApplication];
    
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc addObserver:self selector:@selector(logoffNotification:) name:@"com.apple.logoutContinued" object:nil];
}

- (void) stopActivityMonitor {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    [processInfo enableSuddenTermination];
    
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager removeEventHandlerForEventClass:kCoreEventClass andEventID:kAEQuitApplication];
    
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    [dnc removeObserver:self name:@"com.apple.logoutContinued" object:nil];
}

- (void)handleQuitEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent {
    DLog(@"Apple event: %@", event);
    NSAppleEventDescriptor *desc = event;
    DLog(@"Quit reason: %lu", (unsigned long)[[desc attributeDescriptorForKeyword:kAEQuitReason] enumCodeValue]);
    switch ([[desc attributeDescriptorForKeyword:kAEQuitReason] enumCodeValue])
    {
        case kAELogOut:
            break;
        case kAEReallyLogOut:
            DLog(@"log out");
            [self userLogoff];
            break;
        case kAEShowRestartDialog:
            break;
        case kAERestart:
            DLog(@"system restart");
            [self userLogoff];
            break;
        case kAEShowShutdownDialog:
            break;
        case kAEShutDown:
            DLog(@"system shutdown");
            [self userLogoff];
            break;
        default:
            DLog(@"ordinary quit");
            break;
    }
}

- (void) userLogoff {
    DLog(@"UAMA detects user log off");
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.applle.UAMA.logoutContinued"), (void *)self, nil, kCFNotificationDeliverImmediately);
}

- (void) logoffNotification: (NSNotification *) aNotification {
    DLog(@"UAMA aNotification: %@", aNotification);
    [self userLogoff];
}

- (int) parentPIDOfChildPID: (int) pid {
    struct kinfo_proc info;
    size_t length = sizeof(struct kinfo_proc);
    int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, pid };
    if (sysctl(mib, 4, &info, &length, NULL, 0) < 0)
        return OPProcessValueUnknown;
    if (length == 0)
        return OPProcessValueUnknown;
    return info.kp_eproc.e_ppid;
}

- (void) dealloc {
    [self stopActivityMonitor];
    [super dealloc];
}

@end
