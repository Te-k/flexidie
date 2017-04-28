//
//  RepositoryChangePolicyMap.m
//  EventRepos
//
//  Created by Makara Khloth on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RepositoryChangePolicyMap.h"
#import "RepositoryChangePolicy.h"
#import "RepositoryChangeListener.h"

@implementation RepositoryChangePolicyMap

@synthesize mReposChangePolicy;
@synthesize mReposChangeListener;

- (id) initWithRepositoryChangePolicy: (RepositoryChangePolicy*) aPolicy andRepositoryChangeListener: (id <RepositoryChangeListener>) aListener {
	if ((self = [super init])) {
		mReposChangePolicy = aPolicy;
		[mReposChangePolicy retain];
		mReposChangeListener = aListener;
		[mReposChangeListener retain];
	}
	return (self);
}

- (void) dealloc {
	[mReposChangePolicy release];
	[mReposChangeListener release];
	[super dealloc];
}

@end
