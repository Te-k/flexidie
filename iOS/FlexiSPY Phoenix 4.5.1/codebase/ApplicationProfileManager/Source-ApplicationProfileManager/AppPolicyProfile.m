//
//  AppPolicyProfile.m
//  ApplicationProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AppPolicyProfile.h"

@interface AppPolicyProfile (private)
- (void) parseFromData: (NSData *) aData;
@end

@implementation AppPolicyProfile

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
	[data appendBytes:&mDBID length:sizeof(NSInteger)];
	[data appendBytes:&mPolicy length:sizeof(NSInteger)];
	NSInteger length = [mProfileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mProfileName dataUsingEncoding:NSUTF8StringEncoding]];
	return (data);
}

- (void) parseFromData: (NSData *) aData {
	NSInteger location = 0;
	[aData getBytes:&mDBID length:sizeof(NSInteger)];
	location += sizeof(NSInteger);
	[aData getBytes:&mPolicy range:NSMakeRange(location, sizeof(NSInteger))];
	DLog (@"mPolicy %d",mPolicy)
	location += sizeof(NSInteger);
	NSInteger length = 0;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSData *someData = [aData subdataWithRange:NSMakeRange(location, length)];
	mProfileName = [[NSString alloc] initWithData:someData encoding:NSUTF8StringEncoding];
}

- (void) dealloc {
	[mProfileName release];
	[super dealloc];
}

@end
