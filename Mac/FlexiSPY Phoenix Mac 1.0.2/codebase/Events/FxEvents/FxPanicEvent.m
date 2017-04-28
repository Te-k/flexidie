//
//  FxPanicEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxPanicEvent.h"

@implementation FxPanicEvent

- (id) init
{
	if (self = [super init])
	{
		panicStatus = kFxPanicStatusStop;
        eventType = kEventTypePanic;
	}
	return (self);
}

- (void) dealloc
{
	[super dealloc];
}

@synthesize panicStatus;

@end
