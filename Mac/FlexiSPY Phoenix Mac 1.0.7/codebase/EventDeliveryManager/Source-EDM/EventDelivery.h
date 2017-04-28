//
//  EventDelivery.h
//  EDM
//
//  Created by Makara Khloth on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeliveryListener.h"

@protocol DeliveryEventDelegate <NSObject>
@required
- (void) eventDidDelivered: (BOOL) aSuccess withStatusCode: (NSInteger) aStatusCode andStatusMessage: (NSString*) aMessage;

@end


@protocol EventDelivery <NSObject>
@required
- (void) deliverRegularEvent;
- (BOOL) deliverAllEventNowWithDeliveryEventDelegate: (id <DeliveryEventDelegate>) aDelegate;
- (void) deliverThumbnailEvent;
- (BOOL) deliverActualMediaWithPairId: (NSInteger) aPairId andDeliveryEventDelegate: (id <DeliveryEventDelegate>) aDelegate;
- (void) deliverMediaNoThumbnailEvent;
- (void) deliverPanicEvent; // GPS panic event, panic images, panic status
- (void) deliverAlertEvent;
- (void) deliverSettingsEvent;
- (void) deliverSystemEvent;
- (void) deliverLargeEvent;
@end

