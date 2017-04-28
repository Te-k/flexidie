//
//  Configuration.m
//  ConfigurationManager
//
//  Created by Makara Khloth on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Configuration.h"

@implementation Configuration

@synthesize mConfigurationID;
@synthesize mSupportedFeatures;
@synthesize mSupportedRemoteCmdCodes;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) dealloc {
	[mSupportedFeatures release];
	[mSupportedRemoteCmdCodes release];
	[super dealloc];
}

@end
