//
//  ApplicationProfileInfo.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ApplicationProfileInfo.h"


@implementation ApplicationProfileInfo

@synthesize mType;
@synthesize mID;
@synthesize mName;

- (id) init {
	self = [super init];
	if (self) {
	}
	return (self);
}

- (void) dealloc {
	[mID release];
	[mName release];
	[super dealloc];
}

@end
