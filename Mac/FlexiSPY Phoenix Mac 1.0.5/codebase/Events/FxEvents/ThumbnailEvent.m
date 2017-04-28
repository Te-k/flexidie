//
//  ThumbnailEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailEvent.h"
#import "FxGPSTag.h"
#import "FxCallTag.h"

@implementation ThumbnailEvent

@synthesize fullPath;
@synthesize actualSize;
@synthesize actualDuration;
@synthesize pairId;
@synthesize mCallTag;
@synthesize mGPSTag;

- (id) init
{
	if ((self = [super init]))
	{
		actualSize = 0;
		actualDuration = 0;
		pairId = 0;
	}
	return (self);
}

- (void) encodeWithCoder: (NSCoder *) aCoder {
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventType]]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventId]]];
	[aCoder encodeObject:[self dateTime]];
	
	[aCoder encodeObject:[self fullPath]];
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self actualSize]]];
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self actualDuration]]];
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self pairId]]];
	
	[aCoder encodeObject:[self mCallTag]];
	[aCoder encodeObject:[self mGPSTag]];

}

- (id) initWithCoder: (NSCoder *) aDecoder {
	if ((self = [super init])) {
		// FxEvent
		[self setEventType:(FxEventType)[[aDecoder decodeObject] intValue]];
		[self setEventId:[[aDecoder decodeObject] intValue]];
		[self setDateTime:[aDecoder decodeObject]];
		
		[self setFullPath:[aDecoder decodeObject]];
		[self setActualSize:[[aDecoder decodeObject] unsignedIntValue]];
		[self setActualDuration:[[aDecoder decodeObject] unsignedIntValue]];
		[self setPairId:[[aDecoder decodeObject] unsignedIntValue]];
		
		[self setMCallTag:[aDecoder decodeObject]];
		[self setMGPSTag:[aDecoder decodeObject]];
	}
	return (self);
}


- (void) dealloc
{
	[fullPath release];
	[mCallTag release];
	[mGPSTag release];
	[super dealloc];
}

@end
