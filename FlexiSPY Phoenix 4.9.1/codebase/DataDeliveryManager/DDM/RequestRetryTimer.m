//
//  RequestRetryTimer.m
//  DDM
//
//  Created by Makara Khloth on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RequestRetryTimer.h"

@interface RequestRetryTimer (private)

- (void) schedule: (NSInteger) aSec;
- (void) timeout;

@end

@implementation RequestRetryTimer

@synthesize mListener;
@synthesize mCSID;

+ (id) scheduleTimeFor: (NSInteger) aCSID withListner: (id <RequestRetryTimerListener>) aListener andWithinSecond: (NSInteger) aSec {
	RequestRetryTimer* me = [[RequestRetryTimer alloc] init];
	[me setMListener:aListener];
	[me setMCSID:aCSID];
	[me schedule:aSec];
	[me autorelease];
	return (me);
}

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) schedule: (NSInteger) aSec {
	[NSTimer scheduledTimerWithTimeInterval:aSec target:self selector:@selector(timeout) userInfo:nil repeats:NO];
}

- (void) timeout {
	[mListener requestRetryTimeout:mCSID];
}

- (void) dealloc {
	[mListener release];
	[super dealloc];
}

@end
