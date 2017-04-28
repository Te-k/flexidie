//
//  FxBookmarkWrapper.m
//  FxSqLite
//
//  Created by Makara Khloth on 5/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FxBookmarkWrapper.h"
#import "FxBookmarkEvent.h"

@implementation FxBookmarkWrapper

@synthesize mDBId;
@synthesize mBookmarksId;
@synthesize mBookmark;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) dealloc {
	[mBookmark release];
	[super dealloc];
}

@end
