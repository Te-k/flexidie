//
//  RunLoopSource.m
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RunLoopSource.h"
#import "RunLoopContext.h"

void RunLoopSourceScheduleRoutine (void* info, CFRunLoopRef rl, CFStringRef mode) {
	RunLoopSource* obj = (RunLoopSource*)info;
	RunLoopContext* theContext = [[RunLoopContext alloc] initWithSource:obj andLoop:rl];
}

void RunLoopSourcePerformRoutine (void* info) {
	RunLoopSource* obj = (RunLoopSource*)info;
	[obj sourceFired];
}

void RunLoopSourceCancelRoutine (void* info, CFRunLoopRef rl, CFStringRef mode) {
	RunLoopSource* obj = (RunLoopSource*)info;
	
}
	
@implementation RunLoopSource

- (id) init {
	if ((self = [super init])) {
		CFRunLoopSourceContext context = {0, self, nil, nil, nil, nil, nil,
										  &RunLoopSourceScheduleRoutine,
										  RunLoopSourceCancelRoutine,
										  RunLoopSourcePerformRoutine};
		mRunLoopSource = CFRunLoopSourceCreate(nil, 0, &context);
		mCommands = [[NSMutableArray alloc] init];
	}
	return (self);
}

- (void) addToCurrentRunLoop {
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	CFRunLoopAddSource(runLoop, mRunLoopSource, kCFRunLoopDefaultMode);
}

- (void) invalidate {
	
}

- (void) sourceFired {

}

- (void) addCommand: (NSInteger) aCommand withData: (id) aData {

}

- (void) fireAllCommandOnRunLoop: (CFRunLoopRef) aRunLoop {

}

- (void) dealloc {
	[mCommands release];
	[super dealloc];
}

@end
