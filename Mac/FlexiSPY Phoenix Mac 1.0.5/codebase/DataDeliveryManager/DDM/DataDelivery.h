//
//  DataDelivery.h
//  DDM
//
//  Created by Makara Khloth on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeliveryListener.h"

@protocol DataDelivery <NSObject>
@required
- (void) deliver: (DeliveryRequest*) aRequest;
- (BOOL) isRequestIsPending: (DeliveryRequest*) aRequest;
- (BOOL) isRequestPendingForCaller: (NSInteger) aCallerId; // Check when app or device restart
- (void) registerCaller: (NSInteger) aCallerId withListener: (id <DeliveryListener>) aListener;

@end
