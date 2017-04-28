//
//  FxIMMessageEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 1/31/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FxIMMessageEvent.h"


@implementation FxIMMessageEvent

- (id) init {
	if ((self = [super init])) {
		eventType = kEventTypeIMMessage;
	}
	return (self);
}

- (void) dealloc {
	[super dealloc];
}

@end
