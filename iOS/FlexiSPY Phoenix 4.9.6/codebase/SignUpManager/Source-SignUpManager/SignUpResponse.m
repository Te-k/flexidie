//
//  SignUpResponse.m
//  SignUpManager
//
//  Created by Makara Khloth on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SignUpResponse.h"

@interface SignUpResponse (private)
- (void) parseFromData: (NSData *) aData;
@end

@implementation SignUpResponse

@synthesize mStatus;
@synthesize mActivationCode;
@synthesize mMessage;

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
	NSInteger length = [mStatus lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mStatus dataUsingEncoding:NSUTF8StringEncoding]];
	length = [mActivationCode lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mActivationCode dataUsingEncoding:NSUTF8StringEncoding]];
	length = [mMessage lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mMessage dataUsingEncoding:NSUTF8StringEncoding]];
	return (data);
}

- (void) parseFromData: (NSData *) aData {
	NSInteger location = 0;
	NSInteger length = 0;
	
	[aData getBytes:&length length:sizeof(NSInteger)];
	location += sizeof(NSInteger);
	NSData *subData = [aData subdataWithRange:NSMakeRange(location, length)];
	mStatus = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
	location += length;
	
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	subData = [aData subdataWithRange:NSMakeRange(location, length)];
	mActivationCode = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
	location += length;
	
	[aData getBytes:&length	range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	subData = [aData subdataWithRange:NSMakeRange(location, length)];
	mMessage = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
}

- (void) dealloc {
	[mStatus release];
	[mActivationCode release];
	[mMessage release];
	[super dealloc];
}

@end
