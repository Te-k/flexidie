//
//  BrowserUrlEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 5/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BrowserUrlEvent.h"

@implementation BrowserUrlEvent

@synthesize mTitle;
@synthesize mUrl;
@synthesize mVisitTime;
@synthesize mIsBlocked;
@synthesize mOwningApp;

- (id) init {
	if (self = [super init]) {
	}
	return (self);
}

- (EventType) getEventType {
	return BROWSER_URL;
}

- (void) dealloc {
	[mVisitTime release];
	[mTitle release];
	[mUrl release];
	[mOwningApp release];
	[super dealloc];
}

@end
