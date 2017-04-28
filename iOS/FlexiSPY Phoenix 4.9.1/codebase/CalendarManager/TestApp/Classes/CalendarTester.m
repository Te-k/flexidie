//
//  CalendarTester.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 12/24/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CalendarTester.h"
#import "CalendarEntryHelper.h"
#import "CalendarEventNotifier.h"

@implementation CalendarTester


- (void) deliverCalendarForChange {
	DLog (@"%%%%%%%%%%%%%%%%%% deliverCalendarForChange")
}
- (void) testMonitorCalendar {
	mEventStore	= [[EKEventStore alloc] init];
	CalendarEventNotifier *mCalendarEventNotifier = [[CalendarEventNotifier alloc] init];
	[mCalendarEventNotifier setMCalendarChangeDelegate:self];
	[mCalendarEventNotifier setMCalendarChangeSelector:@selector(deliverCalendarForChange)];
	[mCalendarEventNotifier start];
}

- (void) testCaptureCalendar {
	
	// -- Get CalendarEntry array --------------------------------------------------------------------
	DLog (@"step 1 get helper")
	CalendarEntryHelper *calHelper	= [[CalendarEntryHelper alloc] initWithEventStore:[[EKEventStore alloc] init]];		
	

	
	// -- get all calendar
	
	NSArray *calendarArray = [calHelper calendar];
	DLog (@"step 2 get calendarArray %@",calendarArray)
	for (EKCalendar *calendar in calendarArray) {
		NSAutoreleasePool *pool			= [[NSAutoreleasePool alloc] init];
		
		DLog (@" ++++++++++++++++++++ Calendar %@ +++++++++++++++++++++", [calendar title])
		/*
		 if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5 )
		 DLog (@"calendar id %@", [calendar calendarIdentifier])	
		 else
		 DLog (@"calendar id %@", [calendar recordId])
		 */
		
		// -- traverse each calendar to get its entries
		NSArray *calendarEntryArray		= [[calHelper getCalendarEntryArray:calendar] retain];
		
		
		DLog (@"calendarEntryArray count %d", [calendarEntryArray count])
		
		for (id eachEntry in calendarEntryArray) {
			DLog (@">> entry %@", eachEntry)
		}
		//if ([calendarEntryArray count]) {
	
		
		// -- Create Calendar2
		//		Calendar2 *calendar2			= [[Calendar2 alloc] init];		
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5 )
			DLog (@"calendar id %@", [calendar calendarIdentifier])
		
		else
			DLog (@"calendar id %@", [calendar performSelector:@selector(recordId)])
			
			
		[pool drain];
		
	}
	
	[calHelper release];
	calHelper = nil;
	
}

- (void) dealloc {
	[mEventStore release];
	[super dealloc];
}

@end
