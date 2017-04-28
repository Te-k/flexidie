//
//  CSMDeviceManager.m
//  CommandServiceManager
//
//  Created by Makara Khloth on 11/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CSMDeviceManager.h"

static CSMDeviceManager *_CSMDeviceManager = nil;

@implementation CSMDeviceManager

@synthesize mIMEI;

+ (id) sharedCSMDeviceManager {
	if (_CSMDeviceManager == nil) {
		_CSMDeviceManager = [[CSMDeviceManager alloc] init];
	}
	return (_CSMDeviceManager);
}

- (void) dealloc {
	[mIMEI release];
	[super dealloc];
}

@end
