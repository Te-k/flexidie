//
//  DeviceLockManagerCaller.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DeviceLockUtilsCaller.h"
#import "DeviceLockUtils.h"

@implementation DeviceLockUtilsCaller

- (id) init
{
	self = [super init];
	if (self != nil) {
		mLockUtils = [[DeviceLockUtils alloc] init];
	}
	return self;
}

- (void) sendLockCommand {
	[mLockUtils lockScreenAndSuspendKeys];
}


- (void) sendUnlockCommand {
	[mLockUtils unlockScreenAndResumeKeys];
}

- (void) dealloc {
	[mLockUtils release];
	mLockUtils = nil;
	[super dealloc];
}

@end
