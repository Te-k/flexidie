//
//  RequestPersistStore.h
//  DDM
//
//  Created by Makara Khloth on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RequestDatabase;
@class DeliveryRequest;

@interface RequestPersistStore : NSObject {
@private
	RequestDatabase*	mRequestDatabase;
}

- (void) dropAllRequests;
- (void) deleteRequest: (NSInteger) aCSID;
- (void) updateRequest: (DeliveryRequest*) aRequest;
- (void) insertRequest: (DeliveryRequest*) aRequest;
- (NSArray*) selectAllRequests;
- (NSInteger) countRequest;

@end
