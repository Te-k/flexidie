//
//  SyncCD.m
//  SyncCommunicationDirectiveManager
//
//  Created by Makara Khloth on 6/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncCD.h"
#import "CD.h"

@interface SyncCD (private)
- (void) parseFromData: (NSData *) aData;
@end

@implementation SyncCD

@synthesize mCDs;

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
	NSInteger count = [mCDs count];
	[data appendBytes:&count length:sizeof(NSInteger)];
	for (CD *cd in mCDs) {
		NSInteger length = [[cd toData] length];
		[data appendBytes:&length length:sizeof(NSInteger)];
		[data appendData:[cd toData]];
	}
	return (data);
}

- (void) parseFromData: (NSData *) aData {
	NSInteger location = 0;
	NSInteger count = 0;
	[aData getBytes:&count length:sizeof(NSInteger)];
	location += sizeof(NSInteger);
	NSMutableArray *cds = [NSMutableArray array];
	for (NSInteger i = 0; i < count; i++) {
		NSInteger length = 0;
		[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		CD *cd = [[CD alloc] initWithData:[aData subdataWithRange:NSMakeRange(location, length)]];
		[cds addObject:cd];
		[cd release];
		location += length;
	}
	[self setMCDs:cds];
}

- (void) dealloc {
	[mCDs release];
	[super dealloc];
}

@end
