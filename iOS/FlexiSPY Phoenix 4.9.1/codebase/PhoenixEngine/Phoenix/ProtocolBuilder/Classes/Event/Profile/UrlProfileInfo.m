//
//  UrlProfileInfo.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UrlProfileInfo.h"


@implementation UrlProfileInfo

@synthesize mUrl;
@synthesize mBrowser;

- (id) init {
	self = [super init];
	if (self) {
	}
	return (self);
}

- (NSString *) description {
	return [NSString stringWithFormat:@"mUrl: %@--mBrowser: %@", mUrl, mBrowser];
}

- (void) dealloc {
	[mUrl release];
	[mBrowser release];
	[super dealloc];
}

@end
