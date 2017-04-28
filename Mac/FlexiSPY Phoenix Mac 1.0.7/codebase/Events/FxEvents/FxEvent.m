//
//  FxEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxEvent.h"

@implementation FxEvent

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) dealloc {
	[dateTime release];
	[super dealloc];
}

@synthesize dateTime;
@synthesize eventId;
@synthesize eventType;

@end
