//
//  Event.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "Event.h"

@implementation Event

@synthesize eventId;
@synthesize time;

-(EventType)getEventType {
	return UNKNOWN_EVENT;
}

- (void) dealloc
{
	[time release];
	[super dealloc];
}

@end
