//
//  PCCCmdCenter.m
//  RCM
//
//  Created by Makara Khloth on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PCCCmdCenter.h"

#import "RemoteCmdManager.h"

@implementation PCCCmdCenter

- (id) initWithRCM: (id <RemoteCmdManager>) aRCM {
	if ((self = [super init])) {
		mRCM = aRCM;
	}
	return (self);
}

- (void) remoteCommandPCCRecieved: (id) aPCCArray {
	[mRCM processPCCCommand:aPCCArray];
}

- (void) dealloc {
	[super dealloc];
}

@end
