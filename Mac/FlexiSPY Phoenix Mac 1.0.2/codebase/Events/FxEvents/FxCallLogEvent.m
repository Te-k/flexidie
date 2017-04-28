//
//  FxCallLogEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxCallLogEvent.h"

@implementation FxCallLogEvent

- (id) init
{
	if (self = [super init])
	{
		eventType = kEventTypeCallLog;
		direction = kEventDirectionUnknown;
	}
	return (self);
}

- (void) dealloc
{
	[contactName release];
	[contactNumber release];
	[super dealloc];
}

@synthesize contactName;
@synthesize contactNumber;
@synthesize duration;
@synthesize direction;

@end
