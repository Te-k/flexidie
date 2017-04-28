//
//  PolicyAppsProfileContainer.m
//  RestrictionManagerUtils
//
//  Created by Makara Khloth on 7/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PolicyAppsProfileContainer.h"
#import "AppPolicyProfile.h"
#import "AppProfile.h"

@implementation PolicyAppsProfileContainer

@synthesize mAppPolicy;
@synthesize mProfiles;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) dealloc {
	[mAppPolicy release];
	[mProfiles release];
	[super dealloc];
}

@end
