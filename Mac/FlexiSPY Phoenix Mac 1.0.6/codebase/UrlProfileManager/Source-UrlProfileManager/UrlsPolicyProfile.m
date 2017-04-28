//
//  UrlsPolicyProfile.m
//  UrlProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UrlsPolicyProfile.h"

@interface UrlsPolicyProfile (private)
- (void) parseFromData: (NSData *) aData;
@end

@implementation UrlsPolicyProfile

@synthesize mDBID;
@synthesize mPolicy;
@synthesize mProfileName;

- (id) initFromData: (NSData *) aData {
	if ((self = [super init])) {
		if (aData) {
			[self parseFromData:aData];
		}
	}
	return (self);
}

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (NSData *) toData {
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&mDBID length:sizeof(NSInteger)];						// 4 bytes dbid
	[data appendBytes:&mPolicy length:sizeof(NSInteger)];					// 4 bytes policy
	NSInteger length = [mProfileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];					// 4 bytes leng of profile name
	[data appendData:[mProfileName dataUsingEncoding:NSUTF8StringEncoding]];// n bytes profile name
	return (data);
}

- (void) parseFromData: (NSData *) aData {
	NSInteger location = 0;
	[aData getBytes:&mDBID length:sizeof(NSInteger)];
	location += sizeof(NSInteger);
	DLog (@"parseFromData mDBID %d", mDBID)
	[aData getBytes:&mPolicy range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	DLog (@"parseFromData mPolicy %d", mPolicy)
	NSInteger length = 0;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSData *someData = [aData subdataWithRange:NSMakeRange(location, length)];
	mProfileName = [[NSString alloc] initWithData:someData encoding:NSUTF8StringEncoding];
	DLog (@"parseFromData mProfileName %@", mProfileName)
}

- (NSString *) description {
	return [NSString stringWithFormat:@"dbid: %d,policy: %d,profile: %@", mDBID, mPolicy, mProfileName];
}

- (void) dealloc {
	[mProfileName release];
	[super dealloc];
}

@end
