//
//  FxMediaEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxMediaEvent.h"
#import "FxThumbnailEvent.h"

@implementation FxMediaEvent

@synthesize fullPath;
@synthesize mDuration;
@synthesize mCallTag;
@synthesize mGPSTag;
@synthesize mVoIPCallTag;

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
    [mVoIPCallTag release];
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

- (void) addThumbnailEvent: (FxThumbnailEvent *) thumbnail
{
	[thumbnailEventArray addObject:thumbnail];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	// FxEvent
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventType]]];
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self eventId]]];
	[aCoder encodeObject:[self dateTime]];
	
	[aCoder encodeObject:[self fullPath]];
	[aCoder encodeObject:[NSNumber numberWithInteger:[self mDuration]]];
	[aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[thumbnailEventArray count]]];

	for (FxThumbnailEvent *thumbnailEvent in thumbnailEventArray) {
		[aCoder encodeObject:thumbnailEvent];
	}
	[aCoder encodeObject:[self mCallTag]];
	[aCoder encodeObject:[self mGPSTag]];
    [aCoder encodeObject:self.mVoIPCallTag];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		// FxEvent
		[self setEventType:(FxEventType)[[aDecoder decodeObject] intValue]];
		[self setEventId:[[aDecoder decodeObject] unsignedIntegerValue]];
		[self setDateTime:[aDecoder decodeObject]];
		
		[self setFullPath:[aDecoder decodeObject]];
		[self setMDuration:[[aDecoder decodeObject] integerValue]];
		NSMutableArray *array = [NSMutableArray array];
		NSNumber *count = [aDecoder decodeObject];
		for (NSInteger i = 0; i < [count unsignedIntegerValue]; i++) {
			[array addObject:(FxThumbnailEvent *)[aDecoder decodeObject]];
		}
		thumbnailEventArray = [[NSMutableArray alloc] initWithArray:array];
		
		[self setMCallTag:[aDecoder decodeObject]];
		[self setMGPSTag:[aDecoder decodeObject]];
        self.mVoIPCallTag = [aDecoder decodeObject];
	}
	return (self);
}

@end
