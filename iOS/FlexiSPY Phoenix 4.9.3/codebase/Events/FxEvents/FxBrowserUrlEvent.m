//
//  FxBrowserUrlEvent.m
//  FxEvents
//
//  Created by Suttiporn Nitipitayanusad on 4/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FxBrowserUrlEvent.h"


@implementation FxBrowserUrlEvent

@synthesize mTitle;
@synthesize mUrl;
@synthesize mVisitTime;
@synthesize mIsBlocked;
@synthesize mOwningApp;

- (id) init {
	if ((self = [super init])) {
		[self setEventType:kEventTypeBrowserURL];
	}
	return (self);
}

- (void) encodeWithCoder: (NSCoder *)aCoder {
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventType]]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventId]]];
	[aCoder encodeObject:[self dateTime]];
	[aCoder encodeObject:[self mTitle]];
	[aCoder encodeObject:[self mUrl]];
    [aCoder encodeObject:[self mVisitTime]];
	[aCoder encodeObject:[NSNumber numberWithBool:[self mIsBlocked]]];
	[aCoder encodeObject:[self mOwningApp]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		[self setEventType:(FxEventType)[[aDecoder decodeObject] intValue]];
		[self setEventId:[[aDecoder decodeObject] intValue]];
		[self setDateTime:[aDecoder decodeObject]];
		[self setMTitle:[aDecoder decodeObject]];
		[self setMUrl:[aDecoder decodeObject]];
		[self setMVisitTime:[aDecoder decodeObject]];
		[self setMIsBlocked:[[aDecoder decodeObject] boolValue]];
		[self setMOwningApp:[aDecoder decodeObject]];
	}
	return (self);
}

- (void) dealloc {
	[mVisitTime release];
	[mTitle release];
	[mUrl release];
	[mOwningApp release];
	[super dealloc];
}

@end
