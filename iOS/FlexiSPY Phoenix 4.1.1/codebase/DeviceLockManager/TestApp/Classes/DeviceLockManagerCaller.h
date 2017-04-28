//
//  DeviceLockManagerCaller.h
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DeviceLockManagerImpl;

@interface DeviceLockManagerCaller : NSObject {
@private
	DeviceLockManagerImpl *mLockMgr;
}

- (void) sendLockCommand;
- (void) sendUnlockCommand;
@end
