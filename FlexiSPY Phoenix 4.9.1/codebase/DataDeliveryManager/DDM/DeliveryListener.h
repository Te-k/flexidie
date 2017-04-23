//
//  DeliveryListener.h
//  DDM
//
//  Created by Makara Khloth on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DeliveryRequest;
@class DeliveryResponse;

@protocol DeliveryListener <NSObject>
@required
- (void) requestFinished: (DeliveryResponse*) aResponse;
- (void) updateRequestProgress: (DeliveryResponse*) aResponse;

@end
