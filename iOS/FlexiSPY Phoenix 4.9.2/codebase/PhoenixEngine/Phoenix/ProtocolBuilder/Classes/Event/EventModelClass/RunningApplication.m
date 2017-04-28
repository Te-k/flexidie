//
//  RunningApplication.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RunningApplication.h"


@implementation RunningApplication

@synthesize mType;
@synthesize mName;
@synthesize mID;

- (id) init {
	if (self = [super init]) {
	}
	return (self);
}


- (NSString *) description {
	return [NSString stringWithFormat:@"name:%@ id:%@ type:%d", mName, mID, mType];
}
- (void) dealloc {
	[mName release];
	[mID release];
	[super dealloc];
}

@end
