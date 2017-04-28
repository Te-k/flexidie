//
//  DeviceLockManagerCaller.h
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DeviceLockUtils;

@interface DeviceLockUtilsCaller : NSObject {
@private
	DeviceLockUtils		*mLockUtils;
}

- (void) sendLockCommand;
- (void) sendUnlockCommand;

@end
