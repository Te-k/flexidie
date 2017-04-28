//
//  RepositoryChangePolicyMapPool.m
//  EventRepos
//
//  Created by Makara Khloth on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RepositoryChangePolicyMapPool.h"
#import "RepositoryChangePolicyMap.h"

@implementation RepositoryChangePolicyMapPool

@synthesize mMapPool;

- (id) init {
	if ((self = [super init])) {
		mMapPool = [[NSMutableArray alloc] init];
	}
	return (self);
}

- (void) dealloc {
	[mMapPool release];
	[super dealloc];
}

@end
