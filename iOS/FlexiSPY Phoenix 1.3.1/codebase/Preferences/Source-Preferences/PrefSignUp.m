//
//  PrefSignUp.m
//  Preferences
//
//  Created by Makara Khloth on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PrefSignUp.h"

@interface PrefSignUp (private)
- (void) transferDataToVariables: (NSData *) aData;
@end

@implementation PrefSignUp

@synthesize mSignedUp;
@synthesize mActivationCode;

- (id) init {
	self = [super init];
	if (self != nil) {
	}
	return self;
}


- (id) initFromData: (NSData *) aData {
	self = [super init];
	if (self != nil) {
		[self transferDataToVariables:aData];
	}
	return self;
}

- (id) initFromFile: (NSString *) aFilePath {
	self = [super init];
	if (self != nil) {
		NSData *data = [NSData dataWithContentsOfFile:aFilePath];
		[self transferDataToVariables:data];
	}
	return self;
}

- (NSData *) toData {
	NSMutableData* data = [[NSMutableData alloc] init];
	[data appendBytes:&mSignedUp length:sizeof(BOOL)];
	NSInteger length = [mActivationCode lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[data appendBytes:&length length:sizeof(NSUInteger)];
	[data appendData:[mActivationCode dataUsingEncoding:NSUTF8StringEncoding]];
	return ([data autorelease]);
}

- (void) transferDataToVariables: (NSData *) aData {
	NSInteger location = 0;
	[aData getBytes:&mSignedUp length:sizeof(BOOL)];
	location += sizeof(BOOL);
	NSInteger length = 0;
	[aData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
	location += sizeof(NSInteger);
	NSData *subData = [aData subdataWithRange:NSMakeRange(location, length)];
	mActivationCode = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
}

- (PreferenceType) type {
	return kSignUp;
}

- (void) reset {
	[self setMSignedUp:NO];
	[self setMActivationCode:@""];
}

- (void) dealloc {
	[mActivationCode release];
	[super dealloc];
}

@end
