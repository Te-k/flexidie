//
//  DeviceLockManager.h
//  DeviceLockManager
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DeviceLockOption;
@protocol PreferenceManager;


@protocol DeviceLockManager
@required
- (void) lockDevice;
- (void) unlockDevice;
- (BOOL) isDeviceLock;
- (void) setDeviceLockOption: (DeviceLockOption *) aDeviceLockOption;
- (void) setPreferences: (id <PreferenceManager>) aPrefManager;
@end
