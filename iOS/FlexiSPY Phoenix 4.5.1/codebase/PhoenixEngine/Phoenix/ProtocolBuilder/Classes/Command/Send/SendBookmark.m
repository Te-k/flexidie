//
//  SendBookmark.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SendBookmark.h"


@implementation SendBookmark

@synthesize mBookmarkProvider;
@synthesize mBookmarkCount;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (CommandCode) getCommand {
	return (SEND_BOOKMARKS);
}

- (void) dealloc {
	[mBookmarkProvider release];
	[super dealloc];
}

@end
