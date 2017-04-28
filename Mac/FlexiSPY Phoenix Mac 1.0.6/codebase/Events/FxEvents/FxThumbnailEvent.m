//
//  FxThumbnailEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxThumbnailEvent.h"

@implementation FxThumbnailEvent

@synthesize fullPath;
@synthesize actualSize;
@synthesize actualDuration;
@synthesize pairId;

- (id) init {
	if ((self = [super init])) {
		actualSize = 0;
		actualDuration = 0;
		pairId = 0;
	}
	return (self);
}

- (void) encodeWithCoder: (NSCoder *) aCoder {
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventType]]];
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self eventId]]];
	[aCoder encodeObject:[self dateTime]];
	
	[aCoder encodeObject:[self fullPath]];
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self actualSize]]];
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self actualDuration]]];
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self pairId]]];
}

- (id) initWithCoder: (NSCoder *) aDecoder {
	if ((self = [super init])) {
		// FxEvent
		[self setEventType:(FxEventType)[[aDecoder decodeObject] intValue]];
		[self setEventId:[[aDecoder decodeObject] unsignedIntegerValue]];
		[self setDateTime:[aDecoder decodeObject]];
		
		[self setFullPath:[aDecoder decodeObject]];
		[self setActualSize:[[aDecoder decodeObject] unsignedIntegerValue]];
		[self setActualDuration:[[aDecoder decodeObject] unsignedIntegerValue]];
		[self setPairId:[[aDecoder decodeObject] unsignedIntegerValue]];
	}
	return (self);
}

- (void) dealloc {
	[fullPath release];
	[super dealloc];
}

@end
