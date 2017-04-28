//
//  AppAgentManagerForMac.m
//  AppAgent
//
//  Created by Makara Khloth on 3/23/15.
//
//

#import "AppAgentManagerForMac.h"

#import "EventDelegate.h"
#import "FxSystemEvent.h"
#import "FxEventEnums.h"
#import "DateTimeFormat.h"
#import "DiskSpaceWarningAgent.h"
#import "ExceptionHandleAgent.h"

@interface AppAgentManagerForMac (PrivateAPI)

- (void)		sendSystemEventForLowDiskSpace: (NSString *) aDiskspaceLevelTex;

- (void)		sendSystemEventFor: (FxSystemEventType) aEventType message: (NSString *) aMessage;

- (void)		diskSpaceWarningDidReceived: (NSNotification *) aNotification;
- (void)		exceptionNotificationReceived: (NSNotification *) aNotification;

@end

@implementation AppAgentManagerForMac

@synthesize mEventDelegate;

- (id) init {
    if ((self = [super init])) {
        // Disk space
        mDiskSpaceWarningAgent = [[DiskSpaceWarningAgent alloc] init];
        mListeningDiskSpaceWarning = FALSE;
        
        // Signal/Exception
        // note that we need to register this notification before the init of mExceptionHandleAgent because
        // the init method of mExceptionHandleAgent will post notification to check if there is a previous crash or not
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(exceptionNotificationReceived:)
                                                     name:CRASH_REPORT_NOTIFICATION
                                                   object:nil];
        mExceptionHandleAgent = [[ExceptionHandleAgent alloc] init];
        mListeningException = FALSE;
    }
    return self;
}

#pragma mark - Event delegate -

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    self.mEventDelegate = aEventDelegate;
}

- (void) unregisterEventDelegate {
    self.mEventDelegate = nil;
}

- (void) startCapture {
    [self startHandleUncaughtException];
    [self startListenDiskSpaceWarningLevel];
}

- (void) stopCapture {
    [self stopHandleUncaughtException];
    [self stopListenDiskSpaceWarningLevel];
}

#pragma mark -
#pragma mark Disk Space


- (void) startListenDiskSpaceWarningLevel {
    //DLog(@"startListenDiskSpaceWarningLevel")
    if (!mListeningDiskSpaceWarning) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(diskSpaceWarningDidReceived:)
                                                     name:NSDiskSpaceWarningLevelNotification
                                                   object:nil];
        [mDiskSpaceWarningAgent startListenToDiskSpaceWarningLevelNotification];
        mListeningDiskSpaceWarning = TRUE;
    }
}

- (void) stopListenDiskSpaceWarningLevel {
    if (mListeningDiskSpaceWarning) {
        [mDiskSpaceWarningAgent stopListenToDiskSpaceWarningLevelNotification];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSDiskSpaceWarningLevelNotification
                                                      object:nil];
        mListeningDiskSpaceWarning = FALSE;
    }
}

- (void) diskSpaceWarningDidReceived: (NSNotification *) aNotification {
    //DLog(@"AppAgentManager --> diskSpaceWarningDidReceived: main thread ? %d", [NSThread isMainThread]);
    //DLog(@"AppAgentManager --> diskSpaceWarningDidReceived: !!!!! DISK SPACE WARNNING LEVEL: %@ !!!!! ", [aNotification object]);
    
    NSDictionary *diskspaceInfo = (NSDictionary *)[aNotification object];
    NSString *diskspaceLevelText = [diskspaceInfo objectForKey:DISK_SPACE_LEVEL_STRING_KEY];
    [self sendSystemEventForLowDiskSpace:diskspaceLevelText];
}

- (void) sendSystemEventForLowDiskSpace: (NSString *) aDiskspaceLevelText {
    [self sendSystemEventFor:kSystemEventTypeDiskInfo
                     message:[NSString stringWithFormat:@"%@%@", @"Disk space level: ", aDiskspaceLevelText]];
}

- (BOOL) setThresholdInMegabyteForDiskSpaceCriticalLevel: (uint64_t) aValue {
    return [mDiskSpaceWarningAgent setDiskSpaceThresholdForLevel:DiskSpaceNotificationLevelCritical valueInMegaByte:aValue];
}

- (BOOL) setThresholdInMegabyteForDiskSpaceUrgentLevel: (uint64_t) aValue {
    return [mDiskSpaceWarningAgent setDiskSpaceThresholdForLevel:DiskSpaceNotificationLevelUrgent valueInMegaByte:aValue];
}

- (BOOL) setThresholdInMegabyteForDiskSpaceWarningLevel: (uint64_t) aValue {
    return [mDiskSpaceWarningAgent setDiskSpaceThresholdForLevel:DiskSpaceNotificationLevelWarning valueInMegaByte:aValue];
}

#pragma mark -
#pragma mark Exception handler

- (void) startHandleUncaughtException {
    if (!mListeningException) {
        [mExceptionHandleAgent installExceptionHandler];
    }
    
}

- (void) stopHandleUncaughtException {
    if (mListeningException) {
        [mExceptionHandleAgent uninstallExceptionHandler];
    }
}

- (void) exceptionNotificationReceived: (NSNotification *) aNotification {
    //DLog(@"AppAgentManager --> exceptionNotificationReceived: >>>>>>>>>>>>>>>>>> %@ <<<<<<<<<<<<<<<<<<<<< ", [aNotification object]);
    
    NSDictionary *crashInfo = (NSDictionary *)[aNotification object];
    NSNumber *crashType = [crashInfo objectForKey:CRASH_TYPE_KEY];
    NSString *log = [crashInfo objectForKey:CRASH_REPORT_KEY];
    
    if ([crashType integerValue] == CRASH_TYPE_EXCEPTION) {
        [self sendSystemEventFor:kSystemEventTypeAppCrash message:log];
    } else if ([crashType integerValue] == CRASH_TYPE_SIGNAL) {
        [self sendSystemEventFor:kSystemEventTypeAppCrash message:log];
    }
}

#pragma mark -
#pragma mark System Event


- (void) sendSystemEventFor: (FxSystemEventType) aEventType message: (NSString *) aMessage {
    DLog(@"sending system event")
    FxSystemEvent *systemEvent = [[FxSystemEvent alloc] init];
    [systemEvent setMessage:[NSString stringWithString:aMessage]];
    [systemEvent setDirection:kEventDirectionOut];
    [systemEvent setSystemEventType:aEventType];
    [systemEvent setDateTime:[DateTimeFormat phoenixDateTime]];
    
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        [mEventDelegate performSelector:@selector(eventFinished:) withObject:systemEvent withObject:self];
    }
    [systemEvent release];
}

- (void) dealloc {
    DLog (@"Application agent manager is dealloced...");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CRASH_REPORT_NOTIFICATION
                                                  object:nil];
    [self stopHandleUncaughtException];
    [mExceptionHandleAgent release];
    mExceptionHandleAgent = nil;
    
    [self stopListenDiskSpaceWarningLevel]; // To invalidate otherwise it won't call dealloc
    [mDiskSpaceWarningAgent release];
    mDiskSpaceWarningAgent = nil;
    
    [super dealloc];
}

@end
