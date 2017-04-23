//
//  UrlProfile.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UrlProfile.h"
#import "DataProvider.h"

@implementation UrlProfile

@synthesize mPolicy;
@synthesize mProfileName;
@synthesize mAllowUrlsCount;
@synthesize mDisAllowUrlsCount;
@synthesize mAllowUrlsProvider;
@synthesize mDisAllowUrlsProvider;

- (id) init {
	self = [super init];
	if (self) {
		mPolicy = kUrlPolicyAllow;
	}
	return (self);
}
/*
 NSInteger	mPolicy;
 NSString	*mProfileName;
 NSInteger	mAllowUrlsCount;
 NSInteger	mDisAllowUrlsCount;
 id <DataProvider>	mAllowUrlsProvider;
 id <DataProvider>	mDisAllowUrlsProvider;
 */
- (NSString *) description {
	return [NSString stringWithFormat:@"mPolicy: %d--mProfileName: %@--mAllowUrlsCount: %d--mDisAllowUrlsCount %d", mPolicy, mProfileName, mAllowUrlsCount, mDisAllowUrlsCount];
}

- (void) dealloc {
	[mProfileName release];
	[mAllowUrlsProvider release];
	[mDisAllowUrlsProvider release];
	[super dealloc];
}

@end