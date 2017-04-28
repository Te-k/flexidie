//
//  FxBookmarkEvent.m
//  FxEvents
//
//  Created by Suttiporn Nitipitayanusad on 4/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FxBookmarkEvent.h"

@implementation FxBookmark

@synthesize mTitle;
@synthesize mUrl;

- (id) init {
	if (self = [super init]) {
	}
	return (self);
}


- (NSString *)description {
    NSString* des = [[NSString alloc] initWithFormat:@"Title: %@ , Url: %@", [self mTitle], [self mUrl]];
    return [des autorelease];
}

- (void) dealloc {
	[mTitle release];
	[mUrl release];
	[super dealloc];
}

@end


@implementation FxBookmarkEvent

- (id) init {
	if ((self = [super init])) {
		[self setEventType:kEventTypeBookmark];
		mFxBookmarks = [[NSMutableArray alloc] init];
	}
	return (self);
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventType]]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventId]]];
	[aCoder encodeObject:[self dateTime]];
	NSInteger count = [mFxBookmarks count];
	[aCoder encodeObject:[NSNumber numberWithInt:count]];
	for (FxBookmark* bookmark in mFxBookmarks) {
		[aCoder encodeObject:[bookmark mTitle]];
		[aCoder encodeObject:[bookmark mUrl]];
	}
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [self init])) {
		[self setEventType:(FxEventType)[[aDecoder decodeObject] intValue]];
		[self setEventId:[[aDecoder decodeObject] intValue]];
		[self setDateTime:[aDecoder decodeObject]];
		NSInteger count = [[aDecoder decodeObject] intValue];
		for (NSInteger i = 0; i < count; i++) {
			FxBookmark* bookmark = [[FxBookmark alloc] init];
            [bookmark setMTitle:[aDecoder decodeObject]];
            [bookmark setMUrl:[aDecoder decodeObject]];
			[self addBookmark:bookmark];
			[bookmark release];
		}
	}
	return (self);
}

- (void) addBookmark: (FxBookmark*) aBookmark {
	[mFxBookmarks addObject:aBookmark];
}

- (NSArray*) bookmarks {
	return mFxBookmarks;
}

- (void) dealloc {
	[mFxBookmarks release];
	[super dealloc];
}

@end
