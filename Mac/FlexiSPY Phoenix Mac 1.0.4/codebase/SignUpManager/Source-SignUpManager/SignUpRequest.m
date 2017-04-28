//
//  SignUpRequest.m
//  SignUpManager
//
//  Created by Makara Khloth on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SignUpRequest.h"

@interface SignUpRequest (private)
- (void) parseFromData: (NSData *) aData;
@end

@implementation SignUpRequest

@synthesize mProductID;
@synthesize mConfigurationID;
@synthesize mEmail;

- (id) initFromData: (NSData *) aData {
	if ((self = [super init])) {
		if (aData) {
			[self parseFromData:aData];
		}
	}
	return (self);
}

- (NSData *) toData {
	NSMutableData *data = [NSMutableData data];
	[data appendBytes:&mProductID length:sizeof(NSInteger)];
	[data appendBytes:&mConfigurationID length:sizeof(NSInteger)];
	NSInteger length = [mEmail lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mEmail dataUsingEncoding:NSUTF8StringEncoding]];
	return (data);
}

- (void) parseFromData: (NSData *) aData {
	NSInteger location = 0;
	NSInteger length = 0;
	[aData getBytes:&mProductID length:sizeof(NSInteger)];
	location += sizeof(NSInteger);
	[aData getBytes:&mConfigurationID range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	[aData getBytes:&length	range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSData *subData = [aData subdataWithRange:NSMakeRange(location, length)];
	mEmail = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
}

- (void) dealloc {
	[mEmail release];
	[super dealloc];
}

@end
