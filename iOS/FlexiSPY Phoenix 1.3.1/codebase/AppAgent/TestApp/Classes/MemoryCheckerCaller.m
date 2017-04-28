//
//  Caller.m
//  TestMemWaningNSAcrossThread
//
//  Created by bengasi on 3/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MemoryCheckerCaller.h"
#import "MemoryWarningAgent.h"

@implementation MemoryCheckerCaller

- (id) init
{
	self = [super init];
	if (self != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(memoryWarningDidReceived:) 
													 name:NSMemoryWarningLevelNotification 
												   object:nil];
		
		MemoryWarningAgent *memHandler = [[MemoryWarningAgent alloc] init];
		[memHandler startListenToMemoryWarningLevelNotification];
		
	}
	return self;
}

- (void) memoryWarningDidReceived: (NSNotification *) aNotification {
	NSLog(@"Caller --> memoryWarningDidReceived: main thread ? %d", [NSThread isMainThread]);
	NSLog(@"Caller --> memoryWarningDidReceived: !!!!! MEMORY WARNNING LEVEL: %@ !!!!! ", [aNotification object]);
}

@end
