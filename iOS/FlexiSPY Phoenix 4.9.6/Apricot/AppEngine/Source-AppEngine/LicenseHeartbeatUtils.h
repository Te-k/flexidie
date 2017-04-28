//
//  LicenseHeartbeatUtils.h
//  AppEngine
//
//  Created by Makara Khloth on 8/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeliveryListener.h"

@protocol DataDelivery;

@interface LicenseHeartbeatUtils : NSObject <DeliveryListener> {
@private
	id <DataDelivery>	mDataDelivery; // Not own
}

@property (nonatomic, assign) id <DataDelivery> mDataDelivery;

- (id) initWithDataDelivery: (id <DataDelivery>) aDataDelivery;

- (void) sendHeartbeat;


@end
