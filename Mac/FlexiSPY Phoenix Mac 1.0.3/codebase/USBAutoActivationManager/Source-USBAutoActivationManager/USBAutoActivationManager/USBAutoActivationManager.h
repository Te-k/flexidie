//
//  USBAutoActivationManager.h
//  USBAutoActivationManager
//
//  Created by ophat on 6/11/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivationListener.h"

@class ActivationManager;
@protocol AppContext, USBAutoActivationDelegate;

@interface USBAutoActivationManager : NSObject <ActivationListener>{
    id mActivationManager;
    id <AppContext> mAppContext;
    id <USBAutoActivationDelegate> mDelegate;
    
    NSString * mLicensePath;
    NSString * mLicenseCode;
    NSString * mCSVLogPath;
}

@property(nonatomic,assign) id mActivationManager;
@property(nonatomic,assign) id <AppContext> mAppContext;
@property(nonatomic,assign) id <USBAutoActivationDelegate> mDelegate;

@property (nonatomic, copy) NSString *mLicensePath;
@property (nonatomic, copy) NSString *mLicenseCode;
@property (nonatomic, copy) NSString *mCSVLogPath;

- (id) initWithActivationManager:(ActivationManager *) aActivationManager withAppContext:(id <AppContext> )aAppContext;
- (void) onComplete:(ActivationResponse *)aActivationResponse;
- (void) startAutoCheckAndStartActivate;

@end



