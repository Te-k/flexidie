//
//  ALCEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 9/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ALCEvent.h"


@implementation ALCEvent

@synthesize mApplicationState;
@synthesize mApplicationType;
@synthesize mApplicationIdentifier;
@synthesize mApplicationName;
@synthesize mApplicationVersion;
@synthesize mApplicationSize;
@synthesize mApplicationIconType;
@synthesize mApplicationIconData;

-(EventType)getEventType {
	return APPLICATION_LIFE_CYCLE;
}

- (void) dealloc {
	[mApplicationIdentifier release];
	[mApplicationName release];
	[mApplicationVersion release];
	[mApplicationIconData release];
	[super dealloc];
}

@end
