//
//  PolicyUrlsProfile.m
//  RestrictionManagerUtils
//
//  Created by Makara Khloth on 7/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PolicyUrlsProfileContainer.h"
#import "UrlsPolicyProfile.h"
#import "UrlsProfile.h"

@implementation PolicyUrlsProfileContainer

@synthesize mUrlsPolicy;
@synthesize mProfiles;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) dealloc {
	[mUrlsPolicy release];
	[mProfiles release];
	[super dealloc];
}

@end
