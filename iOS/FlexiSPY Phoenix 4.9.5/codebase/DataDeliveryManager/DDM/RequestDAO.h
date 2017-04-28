//
//  RequestDAO.h
//  DDM
//
//  Created by Makara Khloth on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class DeliveryRequest;

@interface RequestDAO : NSObject {
@private
	FMDatabase*	mDatabase;
}

- (id) initWithDatabase: (FMDatabase*) aDatabase;
- (void) deleteRequest: (NSInteger) aCSID;
- (void) updateRequest: (DeliveryRequest*) aRequest;
- (void) insertRequest: (DeliveryRequest*) aRequest;
- (NSArray*) selectAllRequests;
- (NSInteger) countRequest;
@end
