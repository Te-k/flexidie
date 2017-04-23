//
//  FxApplicationLifeCycleEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 9/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FxApplicationLifeCycleEvent.h"


@implementation FxApplicationLifeCycleEvent

@synthesize mAppState;
@synthesize mAppType;
@synthesize mAppID;
@synthesize mAppName;
@synthesize mAppVersion;
@synthesize mAppSize;
@synthesize mAppIconType;
@synthesize mAppIconData;

- (id) init {
	if ((self = [super init])) {
		[self setEventType:kEventTypeApplicationLifeCycle];
	}
	return (self);
}

- (BOOL) isEqualALCEvent: (FxApplicationLifeCycleEvent *) aALCEvent {
	return (self != aALCEvent &&
			[[self dateTime] isEqualToString:[aALCEvent dateTime]] &&
			[self mAppState] == [aALCEvent mAppState] &&
			[self mAppType] == [aALCEvent mAppType] &&
			[[self mAppID] isEqualToString:[aALCEvent mAppID]] &&
			[[self mAppName] isEqualToString:[aALCEvent mAppName]]);
}

- (NSString *) description {
	return ([NSString stringWithFormat:@"%@\n%d\n%d\n%@\n%@\n%@\n%d\n%d\n%@\n",
			 [self dateTime], [self mAppState], [self mAppType], [self mAppID],
			 [self mAppName], [self mAppVersion], [self mAppSize], [self mAppIconType], [self mAppIconData]]);
}

// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventType]]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self eventId]]];
	[aCoder encodeObject:[self dateTime]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self mAppState]]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self mAppType]]];
	[aCoder encodeObject:[self mAppID]];
	[aCoder encodeObject:[self mAppName]];
	[aCoder encodeObject:[self mAppVersion]];
	[aCoder encodeObject:[NSNumber numberWithUnsignedInt:[self mAppSize]]];
	[aCoder encodeObject:[NSNumber numberWithInt:[self mAppIconType]]];
	[aCoder encodeObject:[self mAppIconData]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		[self setEventType:(FxEventType)[[aDecoder decodeObject] intValue]];
		[self setEventId:[[aDecoder decodeObject] intValue]];
		[self setDateTime:[aDecoder decodeObject]];
		[self setMAppState:(ALCState)[[aDecoder decodeObject] intValue]];
		[self setMAppType:(ALCType)[[aDecoder decodeObject] intValue]];
		[self setMAppID:[aDecoder decodeObject]];
		[self setMAppName:[aDecoder decodeObject]];
		[self setMAppVersion:[aDecoder decodeObject]];
		[self setMAppSize:[[aDecoder decodeObject] unsignedIntValue]];
		[self setMAppIconType:[[aDecoder decodeObject] intValue]];
		[self setMAppIconData:[aDecoder decodeObject]];
		}
	return (self);
}

- (void) dealloc {
	[mAppID release];
	[mAppName release];
	[mAppVersion release];
	[mAppIconData release];
	[super dealloc];
}

@end
