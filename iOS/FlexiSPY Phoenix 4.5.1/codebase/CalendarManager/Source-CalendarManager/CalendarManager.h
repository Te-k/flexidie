//
//  CalendarManager.h
//  CalendarManager
//
//  Created by Benjawan Tanarattanakorn on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CalendarDeliveryDelegate;


@protocol CalendarManager <NSObject> 	
@required
- (BOOL) deliverCalendar: (id <CalendarDeliveryDelegate>) aDelegate;
@end


@protocol CalendarDeliveryDelegate <NSObject>
@required
- (void) calendarDidDelivered: (NSError *) aError;
@end
