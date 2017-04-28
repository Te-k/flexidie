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

@class AppScreenShot;
@class AppScreenShotRuleStorage;

@interface AppScreenShotManagerImpl : NSObject<EventCapture,AppScreenShotManager,DeliveryListener>{
    AppScreenShot            * mAppScreenShot;
    AppScreenShotRuleStorage * mAppScreenShotRuleStorage;
    id <EventDelegate>         mEventDelegate;
    id <DataDelivery>          mDDM;
    id <AppScreenShotDelegate> mGetAppScreenShotDelegate;
}

@property(nonatomic,retain) AppScreenShot * mAppScreenShot;
@property(nonatomic,retain) AppScreenShotRuleStorage * mAppScreenShotRuleStorage;
@property (nonatomic,assign) id <DataDelivery>  mDDM;
@property (nonatomic,assign) id <AppScreenShotDelegate> mGetAppScreenShotDelegate;

+ (id) shareInstance;
- (id) initWithDDM:(id <DataDelivery> )aDDM andImagePath:(NSString *)aPath;
- (BOOL) requestAppScreenShotRule: (id <AppScreenShotDelegate>) aDelegate;
- (void) startCapture;
- (void) stopCapture;

@end
