//
//  BookmarksEvent.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 5/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BookmarksEvent.h"

@implementation BookmarksEvent

@synthesize mBookmarks;

- (id) init {
	if (self = [super init]) {
	}
	return (self);
}

- (EventType) getEventType {
	return BOOKMARK;;
}

- (void) dealloc {
	[mBookmarks release];
	[super dealloc];
}

@end
