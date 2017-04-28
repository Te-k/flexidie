//
//  DeviceLockManagerCaller.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DeviceLockManagerCaller.h"
#import "DeviceLockManagerImpl.h"

@implementation DeviceLockManagerCaller
- (id) init
{
	self = [super init];
	if (self != nil) {
		mLockMgr = [[DeviceLockUtils alloc] init];
	}
	return self;
}

- (void) sendLockCommand {
	[mLockMgr lockScreenAndSuspendKeys];
}


- (void) sendUnlockCommand {
	[mLockMgr unlockScreenAndResumeKeys];
}

- (void) dealloc {
	[mLockMgr release];
	mLockMgr = nil;
	[super dealloc];
@end
