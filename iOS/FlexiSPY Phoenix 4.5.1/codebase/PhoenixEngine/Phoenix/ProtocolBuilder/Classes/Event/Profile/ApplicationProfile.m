//
//  ApplicationProfile.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ApplicationProfile.h"
#import "DataProvider.h"

@implementation ApplicationProfile

@synthesize mPolicy;
@synthesize mProfileName;
@synthesize mAllowAppsCount;
@synthesize mDisAllowAppsCount;
@synthesize mAllowAppsProvider;
@synthesize mDisAllowAppsProvider;

- (id) init {
	self = [super init];
	if (self) {
		mPolicy = kAppPolicyAllow;
	}
	return (self);
}

- (void) dealloc {
	[mProfileName release];
	[mAllowAppsProvider release];
	[mDisAllowAppsProvider release];
	[super dealloc];
}

@end
