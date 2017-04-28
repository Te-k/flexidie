//
//  NSMutableArray+PriorityQueue.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/22/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Priority queue category for NSMutable array 
 */
@interface NSMutableArray (PriorityQueue)

/**
 Get highest priority Request
 @return the last object in array
 */
- (id)dequeue;

/**
 Put object in array then sort by last object will be highest priority
 @param anObject Request object
 */
- (void) enqueue:(id)anObject;

/**
 Remove a request from queue
 @param aCSID client session id
 */
- (void)removeRequest:(NSInteger)aCSID;

@end
