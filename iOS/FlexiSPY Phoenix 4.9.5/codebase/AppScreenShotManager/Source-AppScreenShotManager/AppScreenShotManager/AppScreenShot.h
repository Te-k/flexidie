//
//  AppScreenShot.h
//  AppScreenShotManager
//
//  Created by ophat on 4/1/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppScreenRule;
@class FirefoxURLDetector;

@interface AppScreenShot  : NSObject{
    NSString    *mSavePath;
    BOOL mIsContainSafariSnapShot;
    BOOL mIsContainChromeSnapShot;
    BOOL mIsContainFirefoxSnapShot;
    BOOL mIsAppScreenStarted;
    NSMutableArray * mRules;
    NSMutableArray * mListOfApplication;
    NSTimer * mSnapShotTimer;
    NSString * mActiveAppID;
    NSString * mActiveAppUrl;
    NSString * mActiveAppTitle;
    NSString * mActiveAppName;
    int mActiveAppType;
    
    NSString * mPageURLSafari;
    NSString * mPageURLFirefox;
    NSString * mPageURLChrome;
    AXObserverRef mObserver1;
    AXObserverRef mObserver2;
    AXObserverRef mObserver3;
    AXUIElementRef mProcess1;
    AXUIElementRef mProcess2;
    AXUIElementRef mProcess3;
    CFRunLoopRef mLoop1;
    CFRunLoopRef mLoop2;
    CFRunLoopRef mLoop3;
    FirefoxURLDetector  *mFirefoxURLDetector;
    
    int mSafariSleepTime;
    int mChromeSleepTime;
    int mFirefoxSleepTime;
    
    BOOL mIsContainBrowserSnapShot;
    BOOL mIsTakingSnapShot;
    
    NSThread * mThread;
    id         mDelegate;
    SEL        mSelector;
}
@property(nonatomic,copy) NSString *mSavePath;
@property(nonatomic,assign) BOOL mIsContainSafariSnapShot;
@property(nonatomic,assign) BOOL mIsContainChromeSnapShot;
@property(nonatomic,assign) BOOL mIsContainFirefoxSnapShot;
@property(nonatomic,assign) BOOL mIsAppScreenStarted;
@property(nonatomic,retain) NSMutableArray * mRules;
@property(nonatomic,retain) NSMutableArray * mListOfApplication;
@property(nonatomic,retain) NSTimer * mSnapShotTimer;

@property (nonatomic,copy) NSString * mActiveAppID;
@property (nonatomic,copy) NSString * mActiveAppUrl;
@property (nonatomic,copy) NSString * mActiveAppTitle;
@property (nonatomic,copy) NSString * mActiveAppName;
@property (nonatomic,assign) int mActiveAppType;

@property (nonatomic,copy) NSString * mPageURLSafari;
@property (nonatomic,copy) NSString * mPageURLFirefox;
@property (nonatomic,copy) NSString * mPageURLChrome;

@property (nonatomic, assign) AXObserverRef mObserver1;
@property (nonatomic, assign) AXObserverRef mObserver2;
@property (nonatomic, assign) AXObserverRef mObserver3;
@property (nonatomic, assign) CFRunLoopRef mLoop1;
@property (nonatomic, assign) CFRunLoopRef mLoop2;
@property (nonatomic, assign) CFRunLoopRef mLoop3;
@property (nonatomic, assign) AXUIElementRef mProcess1;
@property (nonatomic, assign) AXUIElementRef mProcess2;
@property (nonatomic, assign) AXUIElementRef mProcess3;

@property (nonatomic, assign) int mSafariSleepTime;
@property (nonatomic, assign) int mChromeSleepTime;
@property (nonatomic, assign) int mFirefoxSleepTime;

@property(nonatomic,retain) NSThread * mThread;
@property (nonatomic,assign) id mDelegate;
@property (nonatomic,assign) SEL mSelector;

-(id) init;
-(void) startCapture;
-(void) stopCapture;
-(void) setRule:(AppScreenRule *)aRule;

@end

