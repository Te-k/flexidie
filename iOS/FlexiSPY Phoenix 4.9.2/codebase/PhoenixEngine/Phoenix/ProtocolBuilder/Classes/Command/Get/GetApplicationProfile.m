//
//  GetApplicationProfile.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GetApplicationProfile.h"


@implementation GetApplicationProfile

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (CommandCode) getCommand {
	return (GET_APPLICATION_PROFILE);
}

- (void) dealloc {
	[super dealloc];
}

@end
