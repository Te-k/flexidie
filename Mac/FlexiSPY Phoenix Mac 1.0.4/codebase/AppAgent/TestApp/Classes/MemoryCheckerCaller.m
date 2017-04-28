//
//  Caller.m
//  TestMemWaningNSAcrossThread
//
//  Created by bengasi on 3/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MemoryCheckerCaller.h"
#import "MemoryWarningAgent.h"
#import "MemoryWarningAgentV2.h"

@implementation MemoryCheckerCaller

- (id) init
{
	self = [super init];
	if (self != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(memoryWarningDidReceived:) 
													 name:NSMemoryWarningLevelNotification 
												   object:nil];
		
//		MemoryWarningAgent *memHandler = [[MemoryWarningAgent alloc] init];
//		[memHandler startListenToMemoryWarningLevelNotification];
        
        MemoryWarningAgentV2 *memHandler = [[MemoryWarningAgentV2 alloc] init];
        [memHandler startListenToMemoryWarningLevelNotification];
		
	}
	return self;
}

- (void) memoryWarningDidReceived: (NSNotification *) aNotification {
	NSLog(@"Caller --> memoryWarningDidReceived: main thread ? %d", [NSThread isMainThread]);
	NSLog(@"Caller --> memoryWarningDidReceived: !!!!! MEMORY WARNNING LEVEL: %@ !!!!! ", [aNotification object]);
}

+ (void) buildupMemory {
    //Memory Usage Performance Guidelines
    NSData *data = [[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://developer.apple.com/library/ios/documentation/Performance/Conceptual/ManagingMemory/ManagingMemory.pdf"]] retain];
    NSLog(@"Memory Usage Performance Guidelines, data length = %lu", (unsigned long)[data length]);
}

@end
