//
//  RequestStore.h
//  DDM
//
//  Created by Makara Khloth on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeliveryListener.h"

@class CommandServiceManager;
@class RequestPersistStore;
@class DeliveryRequest;

@interface RequestStore : NSObject {
@private
	NSMutableArray*	mRequestQueue;
	NSMutableArray*	mWaitToRescheduleQueue;
	RequestPersistStore*	mRequestPersistStore;
}

- (id) initWithCSM: (CommandServiceManager*) aCSM;

// Check orphan requests
- (BOOL) isOrphanRequestForCaller: (NSInteger) aCallerId;
- (void) adoptOrphanRequestForCaller: (NSInteger) aCallerId withDeliveryListener: (id <DeliveryListener>) aListener;

// Queue operation
- (BOOL) isRequestExist: (DeliveryRequest*) aRequest;
- (void) addRequest: (DeliveryRequest*) aRequest;
- (void) addRequestToWaitQueue: (DeliveryRequest*) aRequest;
- (void) updateRequestStatusToReadyForSchedule: (NSInteger) aCSID;

// Involve database operation
- (void) updatePersistStatusAndInsertRequest: (DeliveryRequest*) aRequest;
- (void) increaseRetryCount: (NSInteger) aCSID;
- (void) deleteDeliveryRequest: (NSInteger) aCSID;

// Utilities methods
- (DeliveryRequest*) scheduleRequest;
- (NSInteger) countAllRequest;
- (NSInteger) countPersistedRequest;
- (NSInteger) countNewRequest;

@end
