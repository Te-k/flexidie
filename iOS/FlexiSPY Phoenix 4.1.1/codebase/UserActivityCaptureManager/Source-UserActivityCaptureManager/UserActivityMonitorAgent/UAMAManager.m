//
//  UAMAManager.m
//  UserActivityCaptureManager
//
//  Created by Makara Khloth on 6/4/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "UAMAManager.h"

#import "DaemonPrivateHome.h"
#import "DateTimeFormat.h"
#import "SystemUtilsImpl.h"
#import "FxLogonEvent.h"
#import "DebugStatus.h"

@interface UAMAManager (private)
- (void)handleQuitEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent;
- (void)userLogoff;
- (void) logoffNotification: (NSNotification *) aNotification;
@end

@implementation UAMAManager

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
    DLog(@"Apple event, %@", event);
    NSAppleEventDescriptor *desc = event;
    DLog(@"Quit reason: %lu", (unsigned long)[[desc attributeDescriptorForKeyword:kAEQuitReason] enumCodeValue]);
    switch ([[desc attributeDescriptorForKeyword:kAEQuitReason] enumCodeValue])
    {
        case kAELogOut:
        case kAEReallyLogOut:
            DLog(@"log out");
            [self userLogoff];
            break;
        case kAEShowRestartDialog:
        case kAERestart:
            DLog(@"system restart");
            [self userLogoff];
            break;
        case kAEShowShutdownDialog:
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
    // Capture logoff
    FxLogonEvent *logonEvent = [[[FxLogonEvent alloc] init] autorelease];
    [logonEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [logonEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
    [logonEvent setMApplicationID:[SystemUtilsImpl frontApplicationID]];
    [logonEvent setMApplicationName:[SystemUtilsImpl frontApplicationName]];
    [logonEvent setMTitle:[SystemUtilsImpl frontApplicationWindowTitle]];
    [logonEvent setMAction:kLogonActionLogoff];
    
    // Save logoff event to temp file
    NSString *tempPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/logoff.dat"];
    NSData *logoffEventData = [logonEvent toData];
    [logoffEventData writeToFile:tempPath atomically:YES];
}

- (void) logoffNotification: (NSNotification *) aNotification {
    DLog(@"logoffNotification: %@", aNotification);
    [self userLogoff];
}

- (void) dealloc {
    [self stopActivityMonitor];
    [super dealloc];
}

@end
