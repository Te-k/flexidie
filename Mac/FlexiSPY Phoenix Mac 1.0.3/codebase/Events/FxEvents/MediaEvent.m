//
//  MediaEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaEvent.h"
#import "ThumbnailEvent.h"

@implementation MediaEvent

@synthesize fullPath;
@synthesize mDuration;
@synthesize mCallTag;
@synthesize mGPSTag;

- (id) init
{
	if ((self = [super init]))
	{
		thumbnailEventArray = [[NSMutableArray alloc] init];
	}
	return (self);
}

- (void) dealloc
{
	[fullPath release];
	[thumbnailEventArray release];
	[mCallTag release];
	[mGPSTag release];
	[super dealloc];
}

- (BOOL) hasThumbnails
{
	return ([thumbnailEventArray count]);
}

- (NSArray*) thumbnailEvents
{
	return (thumbnailEventArray);
}

- (void) addThumbnailEvent: (ThumbnailEvent*) thumbnail
{
	[thumbnailEventArray addObject:thumbnail];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	// FxEvent
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventType]]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventId]]];
	[aCoder encodeObject:[self dateTime]];
	
	[aCoder encodeObject:[self fullPath]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self mDuration]]];
	[aCoder encodeObject:[NSNumber numberWithInt:[thumbnailEventArray count]]];

	for (ThumbnailEvent *thumbnailEvent in thumbnailEventArray) {
		[aCoder encodeObject:thumbnailEvent];
	}
	[aCoder encodeObject:[self mCallTag]];
	[aCoder encodeObject:[self mGPSTag]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		// FxEvent
		[self setEventType:(FxEventType)[[aDecoder decodeObject] intValue]];
		[self setEventId:[[aDecoder decodeObject] intValue]];
		[self setDateTime:[aDecoder decodeObject]];
		
		[self setFullPath:[aDecoder decodeObject]];
		[self setMDuration:[[aDecoder decodeObject] intValue]];
		NSMutableArray *array = [NSMutableArray array];
		NSNumber *count = [aDecoder decodeObject];
		for (NSInteger i = 0; i < [count intValue]; i++) {
			[array addObject:(ThumbnailEvent *)[aDecoder decodeObject]];
		}
		thumbnailEventArray = [[NSMutableArray alloc] initWithArray:array];
		
		[self setMCallTag:[aDecoder decodeObject]];
		[self setMGPSTag:[aDecoder decodeObject]];
	}
	return (self);
}

@end
