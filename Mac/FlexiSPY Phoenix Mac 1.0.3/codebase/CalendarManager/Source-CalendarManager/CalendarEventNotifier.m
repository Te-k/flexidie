//
//  CalendarEventNotifier.m
//  CalendarManager
//
//  Created by Benjawan Tanarattanakorn on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CalendarEventNotifier.h"

#import "EKEventStore.h"
//#import <EventKit/EventKit.h>


@interface CalendarEventNotifier (private)
- (void) calendarContextDidSaved: (NSNotification *) aNotification;
- (void) lastNotification;
@end


@implementation CalendarEventNotifier

@synthesize mCalendarChangeDelegate;
@synthesize mCalendarChangeSelector;


- (void) start {
	DLog(@"=========== START Calendar Event Notifier ========");
	//EKEventStore *mEventStore = [[EKEventStore alloc] init];	// create this to make the notification work
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(calendarContextDidSaved:) 
												 name: EKEventStoreChangedNotification
											   object: nil];
}

- (void) stop {
	DLog(@"=========== STOP Calendar Event Notifier ========");
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:EKEventStoreChangedNotification
												  object:nil];
}

- (void) calendarContextDidSaved: (NSNotification *) aNotification {
	DLog (@"===================== cal change =====================")

	
	/*************************************************************************************************************************
	 * If we access [aNotification userInfo], there will be assertion failure as below
	 *	==> *** Assertion failure in -[EKObjectID entityName], /SourceCache/Calendar/Calendar-1023.8/EKObjectID.m:204
	 *************************************************************************************************************************/
	//DLog (@"aNotification userInfo %@", [aNotification userInfo])

	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(lastNotification) withObject:nil afterDelay:10.0];
	DLog (@"=====================  end chagne ===================== ")

}

- (void) lastNotification {
	DLog (@"===================== cal change =====================")
	DLog (@" --- lastNotification ---")
	DLog (@"===================================")
	if ([mCalendarChangeDelegate respondsToSelector:mCalendarChangeSelector]) {
		[mCalendarChangeDelegate performSelector:mCalendarChangeSelector];
	}
}

- (void) dealloc {
	DLog (@"dealloc of CalendarEventNotifier")
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super dealloc];
}

@end
