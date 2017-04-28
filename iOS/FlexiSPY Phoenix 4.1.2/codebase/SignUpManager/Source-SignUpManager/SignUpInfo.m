//
//  SignUpInfo.m
//  SignUpManager
//
//  Created by Makara Khloth on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SignUpInfo.h"

@interface SignUpInfo (private)
- (void) parseFromData: (NSData *) aData;
@end

@implementation SignUpInfo

@synthesize mIsSignedUp;
@synthesize mSignUpActivationCode;

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
	[data appendBytes:&mIsSignedUp length:sizeof(BOOL)];
	NSInteger length = [mSignUpActivationCode lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSInteger)];
	[data appendData:[mSignUpActivationCode dataUsingEncoding:NSUTF8StringEncoding]];
	return (data);
}

- (void) parseFromData: (NSData *) aData {
	NSInteger location = 0;
	NSInteger length = 0;
	[aData getBytes:&mIsSignedUp length:sizeof(BOOL)];
	location += sizeof(BOOL);
	[aData getBytes:&length	range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSData *subData = [aData subdataWithRange:NSMakeRange(location, length)];
	mSignUpActivationCode = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
}

- (void) dealloc {
	[mSignUpActivationCode release];
	[super dealloc];
}

@end
