//
//  DeviceSettingsUtils.h
//  DeviceSettingsManager
//
//  Created by Makara on 3/4/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DevicePasscodeController;

@interface DeviceSettingsUtils : NSObject {
@private
    DevicePasscodeController *mDevicePasscodeController;
}

- (id) initWithDevicePasscodeController: (DevicePasscodeController *) aDevicePasscodeController;
- (NSArray *) getDeviceSettings: (NSArray *) aDeviceSettingIDs;

@end
