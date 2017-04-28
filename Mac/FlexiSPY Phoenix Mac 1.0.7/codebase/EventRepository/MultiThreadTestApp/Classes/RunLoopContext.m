//
//  RunLoopContext.m
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RunLoopContext.h"
#import "RunLoopSource.h"

@implementation RunLoopContext

@synthesize mRunLoop;
@synthesize mSource;

- (id) initWithSource: (RunLoopSource*) aSource andLoop: (CFRunLoopRef) aLoop {
	if ((self = [super init])) {
		mSource = aSource;
		[mSource retain];
		mRunLoop = aLoop;
	}
	return (self);
}

- (void) dealloc {
	[mSource release];
	[super dealloc];
}

@end
