//
//  RequestStore.m
//  DDM
//
//  Created by Makara Khloth on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RequestStore.h"
#import "DeliveryRequest.h"
#import "RequestPersistStore.h"
#import "RequestScheduler.h"

#import "CommandServiceManager.h"

@interface RequestStore (private)

// Clear orphan requests at CSM
- (void) clearOrphanRequestInCSM: (CommandServiceManager*) aCSM;

@end


@implementation RequestStore

- (id) initWithCSM: (CommandServiceManager*) aCSM {
	if ((self = [super init])) {
		mRequestPersistStore = [[RequestPersistStore alloc] init];
		mRequestQueue = [[NSMutableArray alloc] initWithArray:[mRequestPersistStore selectAllRequests]];
		[self clearOrphanRequestInCSM:aCSM];
		mWaitToRescheduleQueue = [[NSMutableArray alloc] init];
	}
	return (self);
}

// Check orphan requests
- (BOOL) isOrphanRequestForCaller: (NSInteger) aCallerId {
	BOOL orphan = FALSE;
	for (DeliveryRequest* rq in mRequestQueue) {
		if ([rq mCallerId] == aCallerId && ![rq mDeliveryListener]) {
			orphan = TRUE;
			break;
		}
	}
	
	if (!orphan) {
		for (DeliveryRequest* rq in mWaitToRescheduleQueue) {
			if ([rq mCallerId] == aCallerId && ![rq mDeliveryListener]) {
				orphan = TRUE;
				break;
			}
		}
	}
	return (orphan);
}

- (void) adoptOrphanRequestForCaller: (NSInteger) aCallerId withDeliveryListener: (id <DeliveryListener>) aListener {
	for (DeliveryRequest* rq in mRequestQueue) {
		if ([rq mCallerId] == aCallerId && ![rq mDeliveryListener]) {
			[rq setMDeliveryListener:aListener];
		}
	}
	
	for (DeliveryRequest* rq in mWaitToRescheduleQueue) {
		if ([rq mCallerId] == aCallerId && ![rq mDeliveryListener]) {
			[rq setMDeliveryListener:aListener];
		}
	}
}

- (BOOL) isRequestExist: (DeliveryRequest*) aRequest {
	BOOL exist = FALSE;
	
	// Find in mRequestQueue (ready to schedule queue)
	for (DeliveryRequest* rq in mRequestQueue) {
		// (caller id == caller id) and
		// (priority == priority) and
		// (edp_type == edp_type)
		if ([rq mCallerId] == [aRequest mCallerId] &&
			[rq mPriority] == [aRequest mPriority] &&
			[rq mEDPType] == [aRequest mEDPType]) {
			exist = TRUE;
			break;
		}
	}
	
	// Find in mWaitToRescheduleQueue (wait to schedule queue)
	if (!exist) {
		for (DeliveryRequest* rq in mWaitToRescheduleQueue) {
			// (caller id == caller id) and
			// (priority == priority) and
			// (edp_type == edp_type)
			if ([rq mCallerId] == [aRequest mCallerId] &&
				[rq mPriority] == [aRequest mPriority] &&
				[rq mEDPType] == [aRequest mEDPType]) {
				exist = TRUE;
				break;
			}
		}
	}
	return (exist);
}

- (void) addRequest: (DeliveryRequest*) aRequest {
	// assert cause absolute path be included in binary (/maraka....)
	//assert([aRequest mReadyToSchedule]); // New request must ready to schedule
	[mRequestQueue addObject:aRequest];
}

- (void) addRequestToWaitQueue: (DeliveryRequest*) aRequest {
	// 1. Change ready to schedule status to FALSE
	// 2. Add request to mWaitToRescheduleQueue (ready to schedule status of request object is FALSE)
	// 3. Remove request from mRequestQueue (ready to schedule)
	[aRequest setMReadyToSchedule:FALSE];
	[mWaitToRescheduleQueue addObject:aRequest];
	[mRequestQueue removeObject:aRequest];
}

- (void) updateRequestStatusToReadyForSchedule: (NSInteger) aCSID {
	for (DeliveryRequest* rq in mWaitToRescheduleQueue) {
		if ([rq mCSID] == aCSID) {
			// 1. Change ready to schedule status to TRUE
			// 2. Add request to mRequestQueue (ready to schedule) back
			// 3. Remove request from mWaitToRescheduleQueue (ready to schedule status of request object is FALSE)
			[rq setMReadyToSchedule:TRUE];
			[mRequestQueue addObject:rq];
			[mWaitToRescheduleQueue removeObject:rq];
			break;
		}
	}
}

// Involve database operation
- (void) updatePersistStatusAndInsertRequest: (DeliveryRequest*) aRequest {
	[aRequest setMPersisted:TRUE];
	[mRequestPersistStore insertRequest:aRequest];
}

- (void) increaseRetryCount: (NSInteger) aCSID {
	DLog(@"Increase retry count for CSID = %d", aCSID)
	for (DeliveryRequest* rq in mRequestQueue) {
		if ([rq mCSID] == aCSID) {
			// Increase both persist store and one in memory (waiting queue) thus object keep sync
			[rq setMRetryCount:[rq mRetryCount] + 1];
			DLog(@"rq have been increased retry count to %d", [rq mRetryCount])
			[mRequestPersistStore updateRequest:rq];
			break;
		}
	}
}

- (void) deleteDeliveryRequest: (NSInteger) aCSID {
	for (DeliveryRequest* rq in mRequestQueue) {
		if ([rq mCSID] == aCSID) {
			[mRequestPersistStore deleteRequest:aCSID];
			[mRequestQueue removeObject:rq];
			break;
		}
	}
}

// Utilities methods
- (DeliveryRequest*) scheduleRequest {
	DeliveryRequest* request = [RequestScheduler scheduleRequest:mRequestQueue];
	if (request && ![request mPersisted]) {
		// Make sure we would not schedule new request; which another the same request (from the same caller id, priority and edp type)
		// is waiting for schedule in mWaitToRescheduleQueue.
		// This scenario could happen when we allow to add multiple request to DDM without check duplication (Yuth prefer this option even
		// I try to convince him from the beginning that we should check duplication from the time where request was submitted to DDM)
		for (DeliveryRequest* rq in mWaitToRescheduleQueue) {
			if ([rq mCallerId] == [request mCallerId] &&
				[rq mPriority] == [request mPriority] &&
				[rq mEDPType] == [request mEDPType]) {
				// The same request found in waiting queue thus force wating request to be ready and reschedule then increase retry count by 1
				[rq setMReadyToSchedule:TRUE];
				[rq setMRetryCount:[rq mRetryCount] + 1];
				[mRequestQueue addObject:rq];
				[mWaitToRescheduleQueue removeObject:rq];
				request = [RequestScheduler scheduleRequest:mRequestQueue];
				break;
			}
		}
	}
	DLog(@"request: %@", request)
	DLog(@"request scheduled, callId: %d, priority: %d, edp: %d, persisted: %d", [request mCallerId], [request mPriority], [request mEDPType], [request mPersisted]);
	return (request);
}

- (NSInteger) countAllRequest {
	NSInteger count1 = [mRequestQueue count];
	NSInteger count2 = [mWaitToRescheduleQueue count];
	return (count1 + count2);
}

- (NSInteger) countPersistedRequest {
	NSInteger count = [mRequestPersistStore countRequest];
	return (count);
}

- (NSInteger) countNewRequest {
	NSInteger count = 0;
	for (DeliveryRequest* rq in mRequestQueue) {
		if (![rq mPersisted]) {
			count++;
		}
	}
	for (DeliveryRequest* rq in mWaitToRescheduleQueue) {
		if (![rq mPersisted]) {
			count++;
		}
	}
	return (count);
}

- (void) clearOrphanRequestInCSM: (CommandServiceManager*) aCSM {
	// Clear orphan request for itself
	for (NSNumber* csid in [aCSM getAllOrphanedSession]) {
		for (DeliveryRequest* rq in mRequestQueue) {
			if ([rq mCSID] == [csid intValue]) {
				[mRequestQueue removeObject:rq];
				break;
			}
		}
	}
	
	// DO NOT muted array while enumerate
	// To make sure all request in DDM queue is resumable
	NSMutableArray* unResumableRequests = [[NSMutableArray alloc] init];
	for (DeliveryRequest* rq in mRequestQueue) {
		BOOL isResumable = FALSE;
		for (NSNumber* csid in [aCSM getAllPendingSession]) {
			if ([csid intValue] == [rq mCSID]) {
				isResumable = TRUE;
				break;
			}
		}
		if (!isResumable) {
			[unResumableRequests addObject:rq];
		}
	}
	for (DeliveryRequest* rq in unResumableRequests) {
		[mRequestPersistStore deleteRequest:[rq mCSID]];
		[mRequestQueue removeObject:rq];
	}
	[unResumableRequests release];
	
	// Clear orphan requext for CSM
	for (NSNumber* csid in [aCSM getAllOrphanedSession]) {
		[aCSM deleteSession:[csid intValue]];
	}
}

- (void) dealloc {
	[mRequestPersistStore release];
	[mRequestQueue release];
	[mWaitToRescheduleQueue release];
	[super dealloc];
}

@end
