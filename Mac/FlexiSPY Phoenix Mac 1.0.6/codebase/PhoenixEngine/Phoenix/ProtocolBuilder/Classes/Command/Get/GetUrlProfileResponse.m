//
//  GetUrlProfileResponse.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GetUrlProfileResponse.h"
#import "UrlProfile.h"

@implementation GetUrlProfileResponse

@synthesize mUrlProfile;

- (id) init {
	self = [super init];
	if (self) {
	}
	return (self);
}

- (void) dealloc {
	[mUrlProfile release];
	[super dealloc];
}

@end
