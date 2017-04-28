//
//  SendInstalledApplication.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SendInstalledApplication.h"


@implementation SendInstalledApplication

@synthesize mInstalledAppsProvider;
@synthesize mInstalledAppsCount;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (CommandCode) getCommand {
	return (SEND_INSTALLED_APPLICATIONS);
}

- (void) dealloc {
	[mInstalledAppsProvider release];
	[super dealloc];
}


@end
