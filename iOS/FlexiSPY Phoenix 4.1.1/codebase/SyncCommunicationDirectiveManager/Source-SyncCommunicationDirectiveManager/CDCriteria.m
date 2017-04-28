//
//  CDCriteria.m
//  SyncCommunicationDirectiveManager
//
//  Created by Makara Khloth on 6/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CDCriteria.h"

@interface CDCriteria (private)
- (void) parseFromData: (NSData *) aData;
@end

@implementation CDCriteria

@synthesize mMultiplier;
@synthesize mDayOfWeek;
@synthesize mDayOfMonth;
@synthesize mMonthOfYear;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) initWithData: (NSData *) aData {
	if (aData) {
		if ((self = [super init])) {
			[self parseFromData:aData];
		}
	}
	return (self);
}

- (NSData *) toData {
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&mMultiplier length:sizeof(NSInteger)];
	[data appendBytes:&mDayOfWeek length:sizeof(NSInteger)];
	[data appendBytes:&mDayOfMonth length:sizeof(NSInteger)];
	[data appendBytes:&mMonthOfYear length:sizeof(NSInteger)];
	return (data);
}

- (void) parseFromData: (NSData *) aData {
	NSInteger location = 0;
	[aData getBytes:&mMultiplier range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	[aData getBytes:&mDayOfWeek range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	[aData getBytes:&mDayOfMonth range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	[aData getBytes:&mMonthOfYear range:NSMakeRange(location, sizeof(NSInteger))];
}

- (void) dealloc {
	[super dealloc];
}

@end
