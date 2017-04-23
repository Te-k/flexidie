//
//  PrefRestriction.m
//  Preferences
//
//  Created by Makara Khloth on 6/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PrefRestriction.h"

@interface PrefRestriction (private)
- (void) transferDataToVariables: (NSData *) aData;
@end

@implementation PrefRestriction

@synthesize mEnableRestriction;
@synthesize mAddressBookMgtMode;
@synthesize mEnableAppProfile;
@synthesize mEnableUrlProfile;
@synthesize mWaitingForApprovalPolicy;

- (id) init {
	self = [super init];
	if (self != nil) {
		[self setMAddressBookMgtMode:kAddressMgtModeOff];	// set default value for kAddressMgtModeOff
		[self reset];
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
	[data appendBytes:&mEnableRestriction length:sizeof(BOOL)];
	[data appendBytes:&mAddressBookMgtMode length:sizeof(NSUInteger)];
	[data appendBytes:&mEnableAppProfile length:sizeof(BOOL)];
	[data appendBytes:&mEnableUrlProfile length:sizeof(BOOL)];
	[data appendBytes:&mWaitingForApprovalPolicy length:sizeof(BOOL)];
	[data autorelease];
	return data;
}

- (void) transferDataToVariables: (NSData *) aData {
	NSInteger location = 0;
	[aData getBytes:&mEnableRestriction length:sizeof(BOOL)];
	location += sizeof(BOOL);
	[aData getBytes:&mAddressBookMgtMode range:NSMakeRange(location, sizeof(NSUInteger))];
	location += sizeof(NSInteger);
	[aData getBytes:&mEnableAppProfile range:NSMakeRange(location, sizeof(BOOL))];
	location += sizeof(BOOL);
	[aData getBytes:&mEnableUrlProfile range:NSMakeRange(location, sizeof(BOOL))];
	location += sizeof(BOOL);
	[aData getBytes:&mWaitingForApprovalPolicy range:NSMakeRange(location, sizeof(BOOL))];
}

- (PreferenceType) type {
	return kRestriction;
}

- (void) reset {
	[self setMEnableRestriction:NO];
	[self setMAddressBookMgtMode:kAddressMgtModeOff];
	[self setMEnableAppProfile:NO];
	[self setMEnableUrlProfile:NO];
	[self setMWaitingForApprovalPolicy:YES];
}

- (void) dealloc {
	[super dealloc];
}

@end