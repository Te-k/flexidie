//
//  RepositoryChangePolicy.m
//  EventRepos
//
//  Created by Makara Khloth on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RepositoryChangePolicy.h"

@implementation RepositoryChangePolicy

@synthesize mMaxNumber;
@synthesize mChangeEventArray;

- (id) init {
	if ((self = [super init])) {
		mChangeEventArray = [[NSMutableArray alloc] init];
	}
	return (self);
}

- (void) addRepositoryChangeEvent: (RepositoryChangeEvent) aEvent {
	[mChangeEventArray addObject:[NSNumber numberWithInt:aEvent]];
}

- (void) dealloc {
	[mChangeEventArray release];
	[super dealloc];
}

@end
