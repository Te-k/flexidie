//
//  MobileAppScreenShot.h
//  AppScreenShotManager-iOS
//
//  Created by Makara Khloth on 12/30/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppStateNotifier, AppState, ScreenTouchNotifier;
@class AppScreenRule;

@interface MobileAppScreenShot : NSObject {
    NSString *mSavePath;
    NSThread *mThread;
    
    NSMutableArray *mRules;
    AppState *mCurrentActiveApp;
    AppScreenRule *mCurrentRule;
    NSTimer *mCurrentTimer;
    
    AppStateNotifier *mAppStateNotifier;
    ScreenTouchNotifier *mScreenTouchNotifier;
    
    id mDelegate;
    SEL mSelector;
}

@property (nonatomic, copy) NSString *mSavePath;
@property (nonatomic, assign) NSThread *mThread;

@property (nonatomic, retain) AppState *mCurrentActiveApp;
@property (nonatomic, retain) AppScreenRule *mCurrentRule;
@property (nonatomic, retain) NSTimer *mCurrentTimer;

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

- (void) startCapture;
- (void) stopCapture;

- (void) addRule:(AppScreenRule *) aRule;
- (void) clearRules;

@end
