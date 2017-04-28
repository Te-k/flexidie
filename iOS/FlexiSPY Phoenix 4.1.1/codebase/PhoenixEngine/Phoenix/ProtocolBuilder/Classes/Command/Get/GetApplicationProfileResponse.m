//
//  GetApplicationProfileResponse.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GetApplicationProfileResponse.h"
#import "ApplicationProfile.h"

@implementation GetApplicationProfileResponse

@synthesize mApplicationProfile;

- (id) init {
	self = [super init];
	if (self) {
	}
	return (self);
}

- (void) dealloc {
	[mApplicationProfile release];
	[super dealloc];
}

@end
