//
//  PanicEventDataProvider.m
//  TestApp
//
//  Created by Makara Khloth on 10/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PanicEventDataProvider.h"

#import "SendEvent.h"
#import "PanicStatus.h"

@implementation PanicEventDataProvider

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) commandData {
	mEventLeft = 1;
	SendEvent* sendEvent = [[SendEvent alloc] init];
	[sendEvent setEventCount:mEventLeft];
	[sendEvent setEventProvider:self];
	[sendEvent autorelease];
	return (sendEvent);
}

- (id)getObject {
	PanicStatus* panicStatus = [[PanicStatus alloc] init];
	[panicStatus setEventId:1];
	[panicStatus setTime:@"20-10-2011 03:04:45"];
	[panicStatus setStatus:PANIC_END];
	[panicStatus autorelease];
	@synchronized (self) {
		mEventLeft--;
	}
	return (panicStatus);
}

- (BOOL)hasNext {
	return (mEventLeft > 0);
}

- (void) dealloc {
	[super dealloc];
}

@end
