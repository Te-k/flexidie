//
//  SendRunningApplication.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SendRunningApplication.h"


@implementation SendRunningApplication

@synthesize mRunningAppsProvider;
@synthesize mRunningAppsCount;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (CommandCode) getCommand {
	return (SEND_RUNNING_APPLICATIONS);
}

- (void) dealloc {
	[mRunningAppsProvider release];
	[super dealloc];
}

@end
