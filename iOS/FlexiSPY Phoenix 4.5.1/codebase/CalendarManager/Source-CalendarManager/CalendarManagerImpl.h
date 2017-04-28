//
//  CalendarManagerImpl.h
//  CalendarManager
//
//  Created by Benjawan Tanarattanakorn on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalendarManager.h"
#import "DeliveryListener.h"


@protocol CalendarDeliveryDelegate;
@protocol DataDelivery;


@class CalendarEntryProvider;
@class CalendarEventNotifier;


@interface CalendarManagerImpl : NSObject <CalendarManager, DeliveryListener>{
@private
	id <DataDelivery>				mDDM;						// DDM
	id <CalendarDeliveryDelegate>	mDelegate;					// not own
	
	CalendarEntryProvider			*mCalendarEntryProvider;	// own
	CalendarEventNotifier			*mCalendarEventNotifier;	// own
}


- (id) initWithDDM: (id <DataDelivery>) aDDM;

- (void) startCapture;
- (void) stopCapture;

@end
