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
@synthesize mShouldTerminate;
@synthesize mHistory;

- (void) startMonitor {
    if (!mHistory) {
        mHistory = [[NSMutableArray alloc]init];
    }
    self.mShouldTerminate = YES;
    
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
    DLog(@"-------- Check to capture logoff event -----------");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //dispatch_async(dispatch_get_main_queue(), ^{
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        @try {
            NSString *tempPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/logoff.dat"];
            NSData *logoffEventData = [NSData dataWithContentsOfFile:tempPath];
            DLog(@"logoffEventData, %@", logoffEventData);
            if (logoffEventData) {
                
                // Capture logon
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
                
                DLog(@"-------- Capture logoff event -----------");
            }
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:tempPath error:nil];
        }
        @catch (NSException *exception) {
            DLog(@"Checking log on/off event exception: %@", exception);
        }
        @finally {
            ;
        }
        
        [pool drain];
    });
    DLog(@"-------- Done checking -----------");
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
            [self userLogoff:nil];
            break;
        case kAEShowRestartDialog:
        case kAERestart:
            DLog(@"system restart");
            [self userLogoff:nil];
            break;
        case kAEShowShutdownDialog:
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
    NSString *cmd = [NSString stringWithFormat:@"open -a %@", agentUI];
    system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
    
    DLog(@"resourcePath = %@", resourcePath);
    DLog(@"agentUI  = %@", agentUI);
    DLog(@"cmd = %@", cmd);
    
    //DLog(@"userDefault: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    [processInfo disableSuddenTermination];
    
    NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    
    // User logoff
    // Apple event only work when application is none UI element
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleQuitEvent:withReplyEvent:) forEventClass:kCoreEventClass andEventID:kAEQuitApplication];
    
    [nc addObserver:self selector:@selector(userLogoff:) name:NSWorkspaceWillPowerOffNotification object:nil];
    
    //[dnc addObserver:self selector:@selector(userLogoff:) name:@"com.apple.restartInitiated" object:nil];
    //[dnc addObserver:self selector:@selector(userLogoff:) name:@"com.apple.shutdownInitiated" object:nil];
    //[dnc addObserver:self selector:@selector(userLogoff:) name:@"com.apple.logoutCancelled" object:nil];
    [dnc addObserver:self selector:@selector(userLogoff:) name:@"com.apple.logoutContinued" object:nil];
    
    /*
     // Useless for lock/unlock screen
     com.apple.screenIsLocked
     com.apple.screenIsUnlocked
     
     com.apple.screensaver.didstart
     com.apple.screensaver.willstop
     com.apple.screensaver.didstop
    */
    
    // User lock/unlock screen
    [nc addObserver:self selector:@selector(userLockUnlockScreen:) name:NSWorkspaceScreensDidSleepNotification object:nil];
    [nc addObserver:self selector:@selector(userLockUnlockScreen:) name:NSWorkspaceScreensDidWakeNotification object:nil];
}

- (void) stopUserActivityMonitor {
    system("killall -9 UserActivityMonitorAgentUI");
    
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    [processInfo enableSuddenTermination];
    
    NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    NSDistributedNotificationCenter *dnc = [NSDistributedNotificationCenter defaultCenter];
    
    // User logoff
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager removeEventHandlerForEventClass:kCoreEventClass andEventID:kAEQuitApplication];
    
    [nc removeObserver:self name:NSWorkspaceWillPowerOffNotification object:nil];
    [dnc removeObserver:self name:@"com.apple.logoutContinued" object:nil];
    
    // User lock/unlock screen
    [nc removeObserver:self name:NSWorkspaceScreensDidSleepNotification object:nil];
    [nc removeObserver:self name:NSWorkspaceScreensDidWakeNotification object:nil];
}

- (void) userLogoff: (NSNotification *) aNotification {
    DLog(@"Logoff notification: %@, %@", aNotification, [aNotification userInfo]);
    
    self.mShouldTerminate = NO;
    
    NSString * dateTime = [DateTimeFormat phoenixDateTime];
    NSString * history = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%@-%@",[SystemUtilsImpl userLogonName],dateTime]];
    
    if (! [mHistory containsObject:history]) {
        
        [mHistory addObject:history];
        
        // Capture logoff
        FxLogonEvent *logoffEvent = [[[FxLogonEvent alloc] init] autorelease];
        [logoffEvent setDateTime:dateTime];
        [logoffEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
        [logoffEvent setMApplicationID:[SystemUtilsImpl frontApplicationID]];
        [logoffEvent setMApplicationName:[SystemUtilsImpl frontApplicationName]];
        [logoffEvent setMTitle:[SystemUtilsImpl frontApplicationWindowTitle]];
        [logoffEvent setMAction:kLogonActionLogoff];
        
        [self storeEvent:logoffEvent];
        
        // Save logoff event to temp file
        NSString *tempPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/logoff.dat"];
        NSData *logoffEventData = [logoffEvent toData];
        [logoffEventData writeToFile:tempPath atomically:YES];
    }
    
    self.mShouldTerminate = YES;
    
}

- (void) userLockUnlockScreen: (NSNotification *) aNotification {
    DLog(@"Lock/Unlock notification, %@", aNotification);
    
    // Capture lock/unlock screen
    FxLogonAction action = kLogonActionUnknown;
    if ([[aNotification name] isEqualToString:NSWorkspaceScreensDidSleepNotification]) {
        action = kLogonActionLockScreen;
    } else if ([[aNotification name] isEqualToString:NSWorkspaceScreensDidWakeNotification]) {
        action = kLogonActionUnlockScreen;
    }

    FxLogonEvent *logonEvent = [[[FxLogonEvent alloc] init] autorelease];
    [logonEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    [logonEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
    [logonEvent setMApplicationID:[SystemUtilsImpl frontApplicationID]];
    [logonEvent setMApplicationName:[SystemUtilsImpl frontApplicationName]];
    [logonEvent setMTitle:[SystemUtilsImpl frontApplicationWindowTitle]];
    [logonEvent setMAction:action];
    
    [self storeEvent:logonEvent];
   
}

- (void) storeEvent: (FxEvent *) aEvent {
    if ([mDelegate respondsToSelector:mSelector]) {
        [mDelegate performSelector:mSelector withObject:aEvent];
    }
}

- (void) dealloc {
    [self stopMonitor];
    [mHistory release];
    [super dealloc];
}

@end
