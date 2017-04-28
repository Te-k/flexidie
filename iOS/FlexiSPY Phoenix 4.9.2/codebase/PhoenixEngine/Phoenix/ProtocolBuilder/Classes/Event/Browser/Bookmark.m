//
//  Bookmark.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Bookmark.h"

@implementation Bookmark

@synthesize mTitle;
@synthesize mUrl;
@synthesize mBrowser;

- (id) init {
	if (self = [super init]) {
	}
	return (self);
}
- (void) dealloc {
	[mTitle release];
	[mUrl release];
	[mBrowser release];
	[super dealloc];
}

@end
