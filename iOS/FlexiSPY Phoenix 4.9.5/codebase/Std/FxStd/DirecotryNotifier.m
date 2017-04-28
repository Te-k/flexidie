//
//  DirecotryNotifier.m
//  FxStd
//
//  Created by Makara Khloth on 2/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DirecotryNotifier.h"

// https://developer.apple.com/library/mac/#documentation/Darwin/Conceptual/FSEvents_ProgGuide/UsingtheFSEventsFramework/UsingtheFSEventsFramework.html#//apple_ref/doc/uid/TP40005289-CH4-SW1

@implementation DirecotryNotifier

@synthesize mDelegate;
@synthesize mDirectory;

- (id) initWithDirectoryDelegate: (id <DirectoryEventDelegate>) aDelegate withDirectory: (NSString *) aDirectory {
	if ((self = [super init])) {
		mDelegate = aDelegate;
		[self setMDirectory:aDirectory];
	}
	return (self);
}

- (void) startMonitor {
	if (!mIsMonitoring) {
	}
}

- (void) stopMonitor {
}

- (void) dealloc {
	[mDirectory release];
	[super dealloc];
}

@end
