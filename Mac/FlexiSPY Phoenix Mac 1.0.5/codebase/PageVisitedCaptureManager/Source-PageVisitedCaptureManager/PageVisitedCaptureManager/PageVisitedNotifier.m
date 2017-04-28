//
//  PageVisitedNotifier.m
//  PageVisitedCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PageVisitedNotifier.h"
#import "PageVisitedDelegate.h"
#import "PageInfo.h"
#import "FirefoxUrlInfoInquirer.h"
#import "Firefox.h"

#import "SystemUtilsImpl.h"
#import "DefStd.h"
#import "UIElementUtilities.h"

NSString * const kSafariBundleID         = @"com.apple.Safari";
NSString * const kFirefoxBundleID        = @"org.mozilla.firefox";
NSString * const kGoogleChromeBundleID   = @"com.google.Chrome";

@implementation PageVisitedNotifier

@synthesize mPageVisitedDelegate;

@synthesize mSafariTitle, mSafariUrl;
@synthesize mChromeTitle, mChromeUrl;
@synthesize mFirefoxTitle, mFirefoxUrl;

@synthesize mPID3;
@synthesize mFirefoxUrlInquirer;

@synthesize mCheckUrlTitle;

- (id) initWithPageVisitedDelegate:(id<PageVisitedDelegate>) aPageVisitedDelegate{
    if ((self = [super init])) {
        self.mPageVisitedDelegate = aPageVisitedDelegate;
    }
    return self;
}

- (void) startNotify {
    [self stopNotify];
    DLog(@"Start notify");

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(pageVisitedRegisterAppNotify:)  name:NSWorkspaceDidActivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(pageVisitedUnRegisterAppNotify:)  name:NSWorkspaceDidDeactivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(pageVisitedRegisterAppNotifyCaseLaunch:)  name:NSWorkspaceDidLaunchApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(pageVisitedUnRegisterAppNotifyCaseTerminate:)  name:NSWorkspaceDidTerminateApplicationNotification  object:nil];
    
}

- (void) stopNotify {
    DLog(@"Stop notify");
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    [self unRegisterPageEventSafari];
    [self unRegisterPageEventFirefox];
    [self unRegisterPageEventChrome];
}

- (void) pageVisitedRegisterAppNotify:(NSNotification *) notification {
    //DLog(@"notification : %@", notification);
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication * runningapp = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    DLog(@"Process Identifier : %d", runningapp.processIdentifier);
    
    if ([[runningapp bundleIdentifier] isEqualToString:kSafariBundleID]) {
        [self registerPageEventSafari:runningapp.processIdentifier];
        [self titleChangeCallBack];
    } else if ([[runningapp bundleIdentifier] isEqualToString:kGoogleChromeBundleID]) {
        [self registerPageEventChrome:runningapp.processIdentifier];
        [self titleChangeCallBack];
    } else if ([[runningapp bundleIdentifier] isEqualToString:kFirefoxBundleID]) {
        // Firefox can run multiple instance base on profile
        [self unRegisterPageEventFirefox];
        
        self.mPID3 = runningapp.processIdentifier; // Initialization for SBApplication, otherwise exception in titleChangeCallBack (-[SBApplication windows]: unrecognized selector)
        [self registerPageEventFirefox:runningapp.processIdentifier];
        [self titleChangeCallBack];
    }
}

- (void) pageVisitedUnRegisterAppNotify:(NSNotification *) notification {
    //DLog(@"notification : %@", notification);
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication *runningapp = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    
    if ([[runningapp bundleIdentifier] isEqualToString:kSafariBundleID]) {
        [self unRegisterPageEventSafari];
    } else if ([[runningapp bundleIdentifier] isEqualToString:kGoogleChromeBundleID]) {
        [self unRegisterPageEventChrome];
    } else if ([[runningapp bundleIdentifier] isEqualToString:kFirefoxBundleID]) {
        // Firefox can run multiple instance base on profile
    }
}

- (void) pageVisitedRegisterAppNotifyCaseLaunch:(NSNotification *) notification {
    // DO NOTHING
}

- (void) pageVisitedUnRegisterAppNotifyCaseTerminate:(NSNotification *) notification {
    //DLog(@"notification : %@", notification);
    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    
    if ([appBundleIdentifier isEqualToString:kSafariBundleID]) {
        [self unRegisterPageEventSafari];
    } else if([appBundleIdentifier isEqualToString:kGoogleChromeBundleID]) {
        [self unRegisterPageEventChrome];
    } else if ([appBundleIdentifier isEqualToString:kFirefoxBundleID]) {
        // Firefox can run multiple instance base on profile
    }
}

- (void) registerPageEventSafari: (pid_t) aPID {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (mProcess1 == nil && mObserver1 == nil) {
            pid_t pid = [self getPID:@"Safari"];
            if (pid != -1) {
                mProcess1 = AXUIElementCreateApplication(pid);
                AXObserverCreate(pid, AXObserver_TitleChangeCallback, &mObserver1);
                AXObserverAddNotification(mObserver1, mProcess1, [self getAXChangeNotification2], self);
                
                CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mObserver1), kCFRunLoopDefaultMode);
                DLog(@"registerPageEvent Safari");
            }
        }
    });
}

- (void) registerPageEventChrome: (pid_t) aPID {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (mProcess2 == nil && mObserver2 == nil) {
            pid_t pid = [self getPID:@"Google Chrome"];
            if (pid != -1) {
                mProcess2 = AXUIElementCreateApplication(pid);
                AXObserverCreate(pid, AXObserver_TitleChangeCallback, &mObserver2);
                AXObserverAddNotification(mObserver2, mProcess2, [self getAXChangeNotification], self);
                
                CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mObserver2), kCFRunLoopDefaultMode);
                DLog(@"registerPageEvent Google Chrome");
            }
        }
    });
}


- (void) registerPageEventFirefox : (pid_t) aPID {
    /*
     Require delay for 2.0 seconds otherwise AXObserver_TitleChangeCallback will not call if register as soon as application active
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (mProcess3 == nil && mObserver3 == nil) {
            pid_t pid = [self getPID:@"firefox"];
            if (pid == -1) {
                pid = [self getPID:@"firefox-bin"];
            }
            if (pid != -1) {
                mProcess3 = AXUIElementCreateApplication(pid);
                AXObserverCreate(pid, AXObserver_TitleChangeCallback, &mObserver3);
                AXObserverAddNotification(mObserver3, mProcess3, [self getAXChangeNotification], self);
                
                CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mObserver3), kCFRunLoopDefaultMode);
                DLog(@"registerPageEvent Firefox");
            }
            self.mPID3 = pid;
        }
    });
}

- (void) unRegisterPageEventSafari {
    if (mProcess1 != nil && mObserver1 != nil) {
        DLog(@"unRegisterPageEventSafari");
        AXObserverRemoveNotification(mObserver1, mProcess1, [self getAXChangeNotification2]);
        
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mObserver1), kCFRunLoopDefaultMode);
        
        CFRelease(mObserver1);
        CFRelease(mProcess1);
        
        mObserver1 = nil;
        mProcess1 = nil;
    }
}

- (void) unRegisterPageEventChrome {
    if (mProcess2 != nil && mObserver2 != nil) {
        DLog(@"unRegisterPageEventChrome");
        AXObserverRemoveNotification(mObserver2, mProcess2, [self getAXChangeNotification]);

        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mObserver2), kCFRunLoopDefaultMode);
        
        CFRelease(mObserver2);
        CFRelease(mProcess2);
        
        mObserver2 = nil;
        mProcess2 = nil;
    }
}

- (void) unRegisterPageEventFirefox {
    if (mObserver3 != nil && mProcess3 != nil) {
        DLog(@"unRegisterPageEventFirefox");
        AXObserverRemoveNotification(mObserver3, mProcess3, [self getAXChangeNotification]);

        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mObserver3), kCFRunLoopDefaultMode);
        
        CFRelease(mObserver3);
        CFRelease(mProcess3);
        
        mObserver3 = nil;
        mProcess3 = nil;
        
        self.mPID3 = -1;
        self.mFirefoxUrlInquirer = nil;
    }
}

#pragma mark - Methods for sub-class to change the notification name

- (CFStringRef) getAXChangeNotification {
    return kAXTitleChangedNotification;
}

- (CFStringRef) getAXChangeNotification2 {
    CFStringRef name = nil;
    if ([SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10]) {
        name = kAXTitleChangedNotification;
    } else if ([SystemUtilsImpl isOSX_10_9]) {
        name = kAXValueChangedNotification;
    }
    return name;
}

#pragma mark -

- (int) getPID: (NSString *) aProcessName {
    int pid = -1;
    SystemUtilsImpl *systemUtils = [[[SystemUtilsImpl alloc] init] autorelease];
    NSArray *runningApps = [systemUtils getRunningProcesses];
    for (NSDictionary *pInfo in runningApps) {
        if ([[pInfo objectForKey:kRunningProcessNameTag] isEqualToString:aProcessName]) {
            pid_t frontmostPID = [(NSString *)[pInfo objectForKey:kRunningProcessIDTag] intValue];
            NSRunningApplication *frontmostApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
            if (frontmostApp.processIdentifier == frontmostPID) {
                pid = frontmostPID;
                break;
            }
        }
    }
    DLog(@"%@ PID : %d", aProcessName, pid);
    
    return pid;
}

void AXObserver_TitleChangeCallback(AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void * contextData) {
    //DLog(@"notificationName : %@", (NSString *)notificationName);
    //DLog(@"role : %@, subrole : %@, title : %@", [UIElementUtilities roleOfUIElement:element], [UIElementUtilities subroleOfUIElement:element], [UIElementUtilities titleOfUIElement:element]);
    CFTypeRef _title = nil;
    if (AXUIElementCopyAttributeValue(element, (CFStringRef)NSAccessibilityTitleAttribute, (CFTypeRef *)&_title) == kAXErrorSuccess) {
        NSString *title = (NSString *)_title;
        if ([title length] > 0) {
            PageVisitedNotifier *myself = (PageVisitedNotifier *)contextData;
            [myself titleChangeCallBack];
        }
    }
    
    if (_title != NULL){
        CFRelease(_title);
    }
}

- (void) titleChangeCallBack {
    @try {
        NSRunningApplication *frontmostApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
        DLog(@"###### frontmostApp : %@", frontmostApp);
        
        if ([frontmostApp.bundleIdentifier isEqualToString:kSafariBundleID]) {
            NSAppleScript *scpt = [[NSAppleScript alloc] initWithSource:@"tell application \"Safari\" \n return{ URL of current tab of window 1,name of current tab of window 1} \n end tell"];
            NSDictionary *error = nil;
            NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:&error];
            
            if (!error) {
                [self sendUrl:[[scptResult descriptorAtIndex:1] stringValue] title:[[scptResult descriptorAtIndex:2] stringValue] appName:frontmostApp.localizedName];
            }
            [scpt release];
        }
        
        if ([frontmostApp.bundleIdentifier isEqualToString:kGoogleChromeBundleID]) {
            NSAppleScript *scpt = [[NSAppleScript alloc] initWithSource:@"tell application \"Google Chrome\" to return {URL of active tab of front window, title of active tab of front window}"];
            NSDictionary *error = nil;
            NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:&error];
            
            if (!error) {
                [self sendUrl:[[scptResult descriptorAtIndex:1] stringValue]  title:[[scptResult descriptorAtIndex:2] stringValue] appName:frontmostApp.localizedName];
            }
            [scpt release];
        }
        
        if ([frontmostApp.bundleIdentifier isEqualToString:kFirefoxBundleID]) {
            @try {
                pid_t pid = self.mPID3;
                NSString *title = nil;
                FirefoxApplication *firefoxApp = (FirefoxApplication *)[SBApplication applicationWithProcessIdentifier:pid];
                for (FirefoxWindow *window in [[firefoxApp windows] get]) {
                    if (window.titled) {
                        title = [window name];
                        DLog(@"#### --> title : %@", title);
                        break;
                    }
                }
                
                if (title.length == 0) {
                    title = [SystemUtilsImpl frontApplicationWindowTitleWithPID:[NSNumber numberWithInt:pid]];
                    DLog(@"#### title : %@", title);
                }
                
                if (self.mFirefoxUrlInquirer) {
                    NSString *url = [self.mFirefoxUrlInquirer urlWithTitle:title];
                    
                    if (url.length > 0) {
                        [self sendUrl:url title:title appName:frontmostApp.localizedName];
                    }
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        FirefoxUrlInfoInquirer *firefoxUrlInquirer = [[[FirefoxUrlInfoInquirer alloc] initWithFirefoxPID:pid] autorelease];
                        NSString *url = [firefoxUrlInquirer urlWithTitle:title];
                        
                        if (url.length > 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self sendUrl:url title:title appName:frontmostApp.localizedName];
                            });
                        } else {
                            DLog(@"Cannot select url for Firefox title : %@", title);
                        }
                        
                        if (pid == self.mPID3) {
                            self.mFirefoxUrlInquirer = firefoxUrlInquirer;
                        }
                    });
                }
            }
            @catch (NSException *e) {
                DLog(@"------> PageVisited Firefox url title exception : %@", e);
            }
            @catch (...) {
                DLog(@"------> PageVisited Firefox url title unknow exception...");
            }
        }
    }@catch (NSException *exception){
        DLog(@"### exception %@",exception);
    }
}

- (void) sendUrl:(NSString *) aUrl title:(NSString *) aTitle appName:(NSString *) aAppName {
    //DLog(@"########## aUrl : %@, aTitle : %@, aAppName : %@, delegate : %@", aUrl, aTitle, aAppName, self.mPageVisitedDelegate);
    if (![aTitle isEqualToString:@"Mozilla Firefox"]    && ![aUrl isEqualToString:@"Mozilla Firefox"]       &&
        ![aTitle isEqualToString:@"Top Sites"]          && ![aUrl isEqualToString:@"topsites://"]           &&
        ![aTitle isEqualToString:@"New Tab"]            && ![aUrl isEqualToString:@"chrome://newtab/"]      &&
        ![aTitle isEqualToString:@"Settings"]           && ![aUrl isEqualToString:@"chrome://settings/"]    ) {
        if ([aUrl length] > 0  && [aTitle length] > 0   && ![self isPreviousEqualToUrl:aUrl title:aTitle appName:aAppName]) {
            if ([self.mPageVisitedDelegate respondsToSelector:@selector(pageVisited:)]) {
                DLog(@"##### aUrl : %@, aTitle : %@, aAppName : %@", aUrl, aTitle, aAppName);
                PageInfo *pInfo = [[PageInfo alloc] init];
                [pInfo setMUrl:aUrl];
                [pInfo setMTitle:aTitle];
                [pInfo setMApplicationName:aAppName];
                //[pInfo setMApplicationID:[SystemUtilsImpl frontApplicationID]];
                if ([aAppName isEqualToString:@"Firefox"]) {
                    [pInfo setMApplicationID:kFirefoxBundleID];
                    pInfo.mPID = self.mPID3;
                    pInfo.mFirefoxPlacesPath = self.mFirefoxUrlInquirer.mFirefoxDatabasePath;
                    self.mFirefoxTitle = aTitle;
                    self.mFirefoxUrl = aUrl;
                } else if ([aAppName isEqualToString:@"Safari"]) {
                    [pInfo setMApplicationID:kSafariBundleID];
                    self.mSafariTitle = aTitle;
                    self.mSafariUrl = aUrl;
                } else if ([aAppName isEqualToString:@"Google Chrome"]) {
                    [pInfo setMApplicationID:kGoogleChromeBundleID];
                    self.mChromeTitle = aTitle;
                    self.mChromeUrl = aUrl;
                }
                [self.mPageVisitedDelegate pageVisited:pInfo];
                [pInfo release];
            }
        }
    }
}

- (BOOL) isPreviousEqualToUrl: (NSString *) aUrl title: (NSString *) aTitle appName: (NSString *) aAppName {
    BOOL isEqual = NO;
    if (self.mCheckUrlTitle) {
        if ([aAppName isEqualToString:@"Firefox"]) {
            isEqual = ([self.mFirefoxTitle isEqualToString:aTitle] && [self.mFirefoxUrl isEqualToString:aUrl]);
        }
        else if ([aAppName isEqualToString:@"Safari"]) {
            isEqual = ([self.mSafariTitle isEqualToString:aTitle]  && [self.mSafariUrl isEqualToString:aUrl]);
        }
        else if ([aAppName isEqualToString:@"Google Chrome"]) {
            isEqual = ([self.mChromeTitle isEqualToString:aTitle]  && [self.mChromeUrl isEqualToString:aUrl]);
        }
    }
    return isEqual;
}

- (void) dealloc {
    [self stopNotify];
    [mSafariTitle release];
    [mSafariUrl release];
    [mChromeTitle release];
    [mChromeUrl release];
    [mFirefoxTitle release];
    [mFirefoxUrl release];
    [mFirefoxUrlInquirer release];
    [super dealloc];
}

@end



