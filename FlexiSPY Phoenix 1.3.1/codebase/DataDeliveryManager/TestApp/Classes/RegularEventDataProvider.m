//
//  RegularEventDataProvider.m
//  TestApp
//
//  Created by Makara Khloth on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RegularEventDataProvider.h"

#import "SendEvent.h"
#import "CallLogEvent.h"

@implementation RegularEventDataProvider

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
	CallLogEvent* callLogEvent = [[CallLogEvent alloc] init];
	[callLogEvent setEventId:1];
	[callLogEvent setTime:@"20-10-2011 03:04:45"];
	[callLogEvent setDuration:35];
	[callLogEvent setDirection:IN];
	[callLogEvent setNumber:@"223324453"];
	[callLogEvent setContactName:@"Mr.ABC"];
	[callLogEvent autorelease];
	@synchronized (self) {
		mEventLeft--;
	}
	return (callLogEvent);
}

- (BOOL)hasNext {
	return (mEventLeft > 0);
}

- (void) dealloc {
	[super dealloc];
}

@end
