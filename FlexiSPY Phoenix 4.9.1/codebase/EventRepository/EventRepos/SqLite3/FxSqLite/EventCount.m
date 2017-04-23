//
//  EventCount.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventCount.h"
#import "DetailedCount.h"

@interface EventCount (private)

@end

@implementation EventCount

@synthesize totalEventCount;

- (id) init
{
	if ((self = [super init]))
	{
		detailedEventCount = [[NSMutableArray alloc] init];
		totalEventCount = 0;
	}
	return (self);
}

- (id) initWithData: (NSData *) aData {
	if ((self = [super init])) {
		detailedEventCount = [[NSMutableArray alloc] init];
		NSInteger location = 0;
		[aData getBytes:&totalEventCount length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		NSInteger count = 0;
		[aData getBytes:&count range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		NSInteger i;
		for (i = 0; i < count; i++) {
			NSInteger length = 0;
			[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
			location += sizeof(NSInteger);
			NSData *data = [aData subdataWithRange:NSMakeRange(location, length)];
			location += length;
			DetailedCount *detailedCount = [[DetailedCount alloc] initWithData:data];
			[detailedEventCount addObject:detailedCount];
			[detailedCount release];
		}
	}
	return (self);
}

- (NSData *) transformToData {
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&totalEventCount length:sizeof(NSInteger)];
	NSInteger count = [detailedEventCount count];
	[data appendBytes:&count length:sizeof(NSInteger)];
	for (DetailedCount *detailedCount in detailedEventCount) {
		NSData *detailedCountData = [detailedCount transformToData];
		NSInteger length = [detailedCountData length];
		[data appendBytes:&length length:sizeof(NSInteger)];
		[data appendData:detailedCountData];
	}
	return (data);
}

- (void) dealloc
{
	[detailedEventCount release];
	[super dealloc];
}

- (DetailedCount*) countEvent: (FxEventType) ofType
{
	return ([detailedEventCount objectAtIndex:(NSInteger)ofType]);
}

- (void) addDetailedCount: (DetailedCount*) detailedCount
{
	[detailedEventCount addObject:detailedCount];
}

@end
