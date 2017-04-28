//
//  DeviceSettingsManagerImpl.h
//  DeviceSettingsManager
//
//  Created by Makara on 3/4/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeviceSettingsManager.h"
#import "DeliveryListener.h"

@class DevicePasscodeController;
@protocol DataDelivery, DeviceSettingsDelegate;

@interface DeviceSettingsManagerImpl : NSObject <DeviceSettingsManager, DeliveryListener> {
@private
    id <DataDelivery>   mDDM;
    id <DeviceSettingsDelegate> mDeviceSettingsDelegate;
    DevicePasscodeController    *mDevicePasscodeController;
}

@property (nonatomic, assign) id <DeviceSettingsDelegate> mDeviceSettingsDelegate;

- (id) initWithDataDeliveryManager: (id <DataDelivery>) aDDM;

@end
