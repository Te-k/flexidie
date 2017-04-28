//
//  LightActivationManager.h
//  TestApp
//
//  Created by Makara Khloth on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeliveryListener.h"

@protocol DataDelivery;

@class ActivationDataProvider;

@interface LightActivationManager : NSObject <DeliveryListener> {
@private
	id <DataDelivery>	mDataDelivery;
	ActivationDataProvider*		mActivationDataProvider;
}

- (id) initWithDataDelivery: (id <DataDelivery>) aDataDelivery;
- (void) sendActivation;
- (void) sendDeactivation;

@end
