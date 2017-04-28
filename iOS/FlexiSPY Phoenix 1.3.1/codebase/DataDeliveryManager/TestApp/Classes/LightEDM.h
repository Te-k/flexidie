//
//  LightEDM.h
//  TestApp
//
//  Created by Makara Khloth on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeliveryListener.h"

@protocol DataDelivery;

@class RegularEventDataProvider;
@class PanicEventDataProvider;
@class ThumbnailEventProvider;

@interface LightEDM : NSObject <DeliveryListener> {
@private
	id <DataDelivery>	mDataDelivery;
	RegularEventDataProvider*	mRegEventProvider;
	PanicEventDataProvider*		mPanicEventProvider;
	ThumbnailEventProvider*		mThumbnailEventProvider;
}

- (id) initWithDataDelivery: (id <DataDelivery>) aDataDelivery;
- (void) sendRegularEvent;
- (void) sendPanicEvent;
- (void) sendThumbnail;
- (void) sendActualEvent;
- (void) sendSystemEvent;

@end
