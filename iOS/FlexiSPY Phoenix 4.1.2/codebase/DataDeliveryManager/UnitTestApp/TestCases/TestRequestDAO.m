//
//  TestRequestDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

#import "RequestPersistStore.h"
#import "DDMDBException.h"
#import "DeliveryRequest.h"

@interface TestRequestDAO : GHTestCase {
@private
    RequestPersistStore*    mRequestPersistStore;
}
@end

@implementation TestRequestDAO

- (void) setUp {
    if (!mRequestPersistStore) {
        @try {
            mRequestPersistStore = [[RequestPersistStore alloc] init];
            [mRequestPersistStore dropAllRequests];
        }
        @catch (DDMDBException* e) {
            NSLog(@"Exception name: %@", [e excName]);
            NSLog(@"Exception reason: %@", [e excReason]);
        }
        @finally {
            
        }
    } else {
        [mRequestPersistStore dropAllRequests];
    }
}

- (void) tearDown {
    
}

- (void) dealloc {
    [mRequestPersistStore release];
    [super dealloc];
}

- (void) testDAOTransactions {
    DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCSID:19332];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
    
    NSInteger count = [mRequestPersistStore countRequest];
    GHAssertEquals(count, 0, @"Compare count request");
    
    // Insert
    [mRequestPersistStore insertRequest:request];
    
    // Count
    count = [mRequestPersistStore countRequest];
    GHAssertEquals(count, 1, @"Compare count request again");
    
    // Select
    NSArray* allRequests = [mRequestPersistStore selectAllRequests];
    DeliveryRequest* tmp = [allRequests objectAtIndex:0];
    GHAssertEquals([tmp mCSID], [request mCSID], @"Compare CSID");
    GHAssertEquals([tmp mCallerId], [request mCallerId], @"Compare caller id");
    GHAssertEquals([tmp mPriority], [request mPriority], @"Compare priority");
    GHAssertEquals([tmp mRetryCount], [request mRetryCount], @"Compare retry count");
    GHAssertEquals([tmp mMaxRetry], [request mMaxRetry], @"Compare max retry");
    GHAssertEquals([tmp mPersisted], [request mPersisted], @"Compare persisted");
    NSInteger edp1 = [tmp mEDPType];
    NSInteger edp2 = [request mEDPType];
    GHAssertEquals(edp1, edp2, @"Compare EDP type");
    GHAssertEquals([tmp mRetryTimeout], [request mRetryTimeout], @"Compare retry timeout");
    GHAssertEquals([tmp mConnectionTimeout], [request mConnectionTimeout], @"Compare connection timeout");
    
    // Update
    [request setMRetryCount:[request mRetryCount] + 1];
    [mRequestPersistStore updateRequest:request];
    allRequests = [mRequestPersistStore selectAllRequests];
    tmp = [allRequests objectAtIndex:0];
    GHAssertEquals([tmp mCSID], [request mCSID], @"Compare CSID again");
    GHAssertEquals([tmp mCallerId], [request mCallerId], @"Compare caller id again");
    GHAssertEquals([tmp mPriority], [request mPriority], @"Compare priority again");
    GHAssertEquals([tmp mRetryCount], [request mRetryCount], @"Compare retry count again");
    GHAssertEquals([tmp mMaxRetry], [request mMaxRetry], @"Compare max retry again");
    GHAssertEquals([tmp mPersisted], [request mPersisted], @"Compare persisted again");
    edp1 = [tmp mEDPType];
    edp2 = [request mEDPType];
    GHAssertEquals(edp1, edp2, @"Compare EDP type again");
    GHAssertEquals([tmp mRetryTimeout], [request mRetryTimeout], @"Compare retry timeout again");
    GHAssertEquals([tmp mConnectionTimeout], [request mConnectionTimeout], @"Compare connection timeout again");
    
    // Delete
    [mRequestPersistStore deleteRequest:[request mCSID]];
    count = [mRequestPersistStore countRequest];
    GHAssertEquals(count, 0, @"Compare count request again and again");
    [request release];
}

- (void) testDAOTransactionsHardcore {
    DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCSID:19332];
    [request setMCallerId:273242];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMRetryCount:0];
    [request setMMaxRetry:45];
    [request setMPersisted:TRUE];
    [request setMEDPType:kEDPTypeCommon];
    [request setMRetryTimeout:4395];
    [request setMConnectionTimeout:345];
    
    NSInteger count = [mRequestPersistStore countRequest];
    GHAssertEquals(count, 0, @"Compare count request");
    
    // Insert
    NSInteger max = 1000;
    NSInteger i = 0;
    for (i = 0; i < max; i++) {
        [request setMCSID:i];
        [mRequestPersistStore insertRequest:request];
    }
    
    // Count
    count = [mRequestPersistStore countRequest];
    GHAssertEquals(count, max, @"Compare count request again");
    
    NSInteger edp1;
    NSInteger edp2;
    // Select
    i = 0;
    NSArray* allRequests = [mRequestPersistStore selectAllRequests];
    for (DeliveryRequest* tmp in allRequests) {
        GHAssertEquals([tmp mCSID], i, @"Compare CSID");
        GHAssertEquals([tmp mCallerId], [request mCallerId], @"Compare caller id");
        GHAssertEquals([tmp mPriority], [request mPriority], @"Compare priority");
        GHAssertEquals([tmp mRetryCount], [request mRetryCount], @"Compare retry count");
        GHAssertEquals([tmp mMaxRetry], [request mMaxRetry], @"Compare max retry");
        GHAssertEquals([tmp mPersisted], [request mPersisted], @"Compare persisted");
        edp1 = [tmp mEDPType];
        edp2 = [request mEDPType];
        GHAssertEquals(edp1, edp2, @"Compare EDP type");
        GHAssertEquals([tmp mRetryTimeout], [request mRetryTimeout], @"Compare retry timeout");
        GHAssertEquals([tmp mConnectionTimeout], [request mConnectionTimeout], @"Compare connection timeout");
        i++;
    }
    
    // Update
    i = 0;
    for (DeliveryRequest* tmp in allRequests) {
        [tmp setMRetryCount:i];
        [mRequestPersistStore updateRequest:tmp];
        i++;
    }
    
    i = 0;
    allRequests = [mRequestPersistStore selectAllRequests];
    for (DeliveryRequest* tmp in allRequests) {
        GHAssertEquals([tmp mCSID], i, @"Compare CSID again");
        GHAssertEquals([tmp mCallerId], [request mCallerId], @"Compare caller id again");
        GHAssertEquals([tmp mPriority], [request mPriority], @"Compare priority again");
        GHAssertEquals([tmp mRetryCount], i, @"Compare retry count again");
        GHAssertEquals([tmp mMaxRetry], [request mMaxRetry], @"Compare max retry again");
        GHAssertEquals([tmp mPersisted], [request mPersisted], @"Compare persisted again");
        edp1 = [tmp mEDPType];
        edp2 = [request mEDPType];
        GHAssertEquals(edp1, edp2, @"Compare EDP type again");
        GHAssertEquals([tmp mRetryTimeout], [request mRetryTimeout], @"Compare retry timeout again");
        GHAssertEquals([tmp mConnectionTimeout], [request mConnectionTimeout], @"Compare connection timeout again");
        i++;
    }
    
    // Delete
    for (DeliveryRequest* tmp in allRequests) {
        [mRequestPersistStore deleteRequest:[tmp mCSID]];
    }
    
    count = [mRequestPersistStore countRequest];
    GHAssertEquals(count, 0, @"Compare count request again and again");
    [request release];
}

@end