//
//  FxSystemEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 9/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxSystemEvent.h"

@implementation FxSystemEvent

- (id) init
{
	if (self = [super init])
	{
        eventType = kEventTypeSystem;
        direction = kEventDirectionUnknown;
	}
	return (self);
}

- (void) dealloc
{
	[message release];
	[super dealloc];
}

@synthesize message;
@synthesize direction;
@synthesize systemEventType;

@end
