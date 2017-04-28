//
//  DetailedCount.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailedCount.h"

@implementation DetailedCount

- (id) init
{
	if (self = [super init])
	{
		inCount = 0;
		outCount = 0;
		missedCount = 0;
		unknownCount = 0;
		localIMCount = 0;
		totalCount = 0;
	}
	return (self);
}

- (id) initWithData: (NSData *) aData {
	if ((self = [super init])) {
		NSInteger location = 0;
		[aData getBytes:&inCount length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		[aData getBytes:&outCount range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		[aData getBytes:&missedCount range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		[aData getBytes:&unknownCount range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		[aData getBytes:&localIMCount range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		[aData getBytes:&totalCount range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
	}
	return (self);
}

- (NSData *) transformToData {
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&inCount length:sizeof(NSInteger)];
	[data appendBytes:&outCount length:sizeof(NSInteger)];
	[data appendBytes:&missedCount length:sizeof(NSInteger)];
	[data appendBytes:&unknownCount length:sizeof(NSInteger)];
	[data appendBytes:&localIMCount length:sizeof(NSInteger)];
	[data appendBytes:&totalCount length:sizeof(NSInteger)];
	return (data);
}

- (void) dealloc
{
	[super dealloc];
}

@synthesize inCount;
@synthesize outCount;
@synthesize missedCount;
@synthesize unknownCount;
@synthesize localIMCount;
@synthesize totalCount;

@end
