//
//  CalendarEntryHelper.h
//  CalendarManager
//
//  Created by Benjawan Tanarattanakorn on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EKEventStore.h"
//#import <EventKit/EventKit.h>


@class EKEventStore;


@interface CalendarEntryHelper : NSObject {
	EKEventStore		*mEventStore;				// not own
	NSMutableArray		*mUniqueIdentifierArray;	// own
}

@property (assign, readonly) EKEventStore *mEventStore;

- (id) initWithEventStore: (EKEventStore *) aEventStore;

// create NSArray of Calendar2
//- (id) createCalendar;

- (NSArray *) calendar;
- (NSArray *) getCalendarEntryArray: (EKCalendar *) aCalendar;

@end
