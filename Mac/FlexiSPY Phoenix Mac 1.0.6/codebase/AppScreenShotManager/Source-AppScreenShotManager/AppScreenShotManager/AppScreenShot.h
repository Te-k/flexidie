//
//  AppScreenShot.h
//  AppScreenShotManager
//
//  Created by ophat on 4/1/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PageVisitedDelegate.h"

@class AppScreenRule;
@class PageVisitedNotifier;

@interface AppScreenShot  : NSObject <PageVisitedDelegate> {
@private
    NSString    *mSavePath;
    
    NSMutableArray * mRules;
    NSMutableArray * mListOfApplication;
    
    NSTimer * mSnapShotTimer;
    
    NSString * mSnapAppID;
    NSString * mSnapAppUrl;
    NSString * mSnapAppTitle;
    NSString * mSnapAppName;
    int mSnapAppType;
    
    NSString * mSnapRuleTitle;
    NSString * mSnapRuleUrl;
    
    PageVisitedNotifier  *mPageNotifier;
    
    NSThread * mThread;
    
    id         mDelegate;
    SEL        mSelector;
}

@property (nonatomic,copy) NSString *mSavePath;

@property (nonatomic,retain) NSTimer * mSnapShotTimer;

@property (nonatomic,copy) NSString * mSnapAppID;
@property (nonatomic,copy) NSString * mSnapAppUrl;
@property (nonatomic,copy) NSString * mSnapAppTitle;
@property (nonatomic,copy) NSString * mSnapAppName;
@property (nonatomic,assign) int mSnapAppType;

@property (nonatomic,copy) NSString * mSnapRuleTitle;
@property (nonatomic,copy) NSString * mSnapRuleUrl;

@property(nonatomic,assign) NSThread * mThread;

@property (nonatomic,assign) id mDelegate;
@property (nonatomic,assign) SEL mSelector;

- (void) startCapture;
- (void) stopCapture;

- (void) addRule:(AppScreenRule *)aRule;
- (void) clearRules;

@end

