//
//  RequestScheduler.m
//  DDM
//
//  Created by Makara Khloth on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RequestScheduler.h"
#import "DeliveryRequest.h"
#import "DefDDM.h"

@interface RequestScheduler (private)

- (id) initWithRequestQueue: (NSArray*) aRequestQueue;
- (DeliveryRequest*) doSchedule;
- (DeliveryRequest*) selectRequestFromTheSamePriorityQueue: (NSArray*) aTheSamePriorityRequestQueue;

@end

@implementation RequestScheduler

+ (DeliveryRequest*) scheduleRequest: (NSArray*) aRequestQueue {
	RequestScheduler* me = [[RequestScheduler alloc] initWithRequestQueue:aRequestQueue];
	DeliveryRequest* request = [me doSchedule];
	//[me autorelease];
	[me release];
	me = nil;
	return (request);
}

- (id) initWithRequestQueue: (NSArray*) aRequestQueue {
	if ((self = [super init])) {
		mRequestQueue = aRequestQueue;
		[mRequestQueue retain];
	}
	return (self);
}

- (DeliveryRequest*) doSchedule {
	NSMutableArray* highPArray = [[NSMutableArray alloc] init];
	NSMutableArray* normalPArray = [[NSMutableArray alloc] init];
	NSMutableArray* lowPArray = [[NSMutableArray alloc] init];
	// 1. Group request by priority
	for (DeliveryRequest* req in mRequestQueue) {
		if ([req mPriority] == kDDMRequestPriortyHigh) {
			[highPArray addObject:req];
		} else if ([req mPriority] == kDDMRequestPriortyNormal) {
			[normalPArray addObject:req];
		} else {
			[lowPArray addObject:req];
		}
	}
	
	// 2. Select one request from each priority array
	DeliveryRequest* highPReq = [self selectRequestFromTheSamePriorityQueue:highPArray];
	DeliveryRequest* normalPReq = [self selectRequestFromTheSamePriorityQueue:normalPArray];
	DeliveryRequest* lowPReq = [self selectRequestFromTheSamePriorityQueue:lowPArray];
	
	// 3. Select request from high first if any otherwise would select normal otherwise would be low
	DeliveryRequest* scheduledReq = nil;
	if (highPReq) {
		scheduledReq = highPReq;
	} else if (normalPReq) {
		scheduledReq = normalPReq;
	} else if (lowPReq) {
		scheduledReq = lowPReq;
	}
	[scheduledReq retain];
	[scheduledReq autorelease];
	[highPArray release];
	[normalPArray release];
	[lowPArray release];
	return (scheduledReq);
}

- (DeliveryRequest*) selectRequestFromTheSamePriorityQueue: (NSArray*) aTheSamePriorityRequestQueue {
	// We choose request in one of following conditions if it satisfied
	// 1. Select request that is persisted in FIFO
	// 2. If there is no persisted request, select request in FIFO (that mean simply select first one)
	
	DeliveryRequest* request = nil;
	for (DeliveryRequest* req in aTheSamePriorityRequestQueue) {
		// Schedule the persisted request
		if ([req mPersisted]) {
			request = req;
			break;
		}
	}
	
	if (!request) {
		// No request is persisted (all ready to schedule are new request) so just select the first
		if ([aTheSamePriorityRequestQueue count]) {
			request = [aTheSamePriorityRequestQueue objectAtIndex:0];
		}
	}
	return (request);
}

- (void) dealloc {
	[mRequestQueue release];
	[super dealloc];
}

@end
