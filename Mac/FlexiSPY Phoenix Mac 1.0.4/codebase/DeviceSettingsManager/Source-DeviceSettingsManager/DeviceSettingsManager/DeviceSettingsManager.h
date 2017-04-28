//
//  DeviceSettingsManager.h
//  DeviceSettingsManager
//
//  Created by Makara on 3/4/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DeviceSettingsDelegate <NSObject>
@required
- (void) deviceSettingsDidDeliver: (NSError *) aError;
@end

@protocol DeviceSettingsManager <NSObject>
@required
- (BOOL) deliverDeviceSettings: (NSArray *) aDeviceSettingIDs delegate: (id <DeviceSettingsDelegate>) aDelegate;
- (NSArray *) getDeviceSettings;
@end
