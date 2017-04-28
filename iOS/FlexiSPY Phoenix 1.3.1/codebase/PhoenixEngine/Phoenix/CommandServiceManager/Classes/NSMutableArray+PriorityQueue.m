//
//  NSMutableArray+PriorityQueue.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/22/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "NSMutableArray+PriorityQueue.h"
#import "Request.h"

@implementation NSMutableArray (PriorityQueue)

- (id) dequeue {
	id result = nil;
	if ([self count] > 0) {
		result = [self objectAtIndex:([self count]-1)];
		if (result) {
			[[result retain] autorelease];
			[self removeLastObject];
		}
	}
	return result;
}

- (void) enqueue:(id)anObject {
	[self addObject:anObject];
	[self sortUsingSelector:@selector(compare:)];
}

- (void) removeRequest:(NSInteger)aCSID {
	DLog(@"removeRequest 1 %d %d", aCSID, [self count]);
	for (int i=0; i< [self count];i++) {
		DLog(@"removeRequest 2 %d %d", aCSID, [(Request *)[self objectAtIndex:i] CSID]);
		if ([(Request *)[self objectAtIndex:i] CSID] == aCSID) {
			[self removeObjectAtIndex:i];
			break;
		}
	}
}

@end
