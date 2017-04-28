//
//  CalendarEntryProvider.m
//  CalendarManager
//
//  Created by Benjawan Tanarattanakorn on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CalendarEntryProvider.h"
#import "CalendarEntry.h"
#import "Calendar2.h"
#import "CalendarEntryHelper.h"
#import "SendCalendar.h"

#import "EKEventStore.h"
#import "EKEventStoreiOS6.h"
#import "EKCalendariOS5.h"
//#import <EventKit/EventKit.h>


//static NSString* const kCalendarName			= @"iPhone Calendar";


@implementation CalendarEntryProvider

@synthesize mCalendarEntryArray;
@synthesize mEventStore;
@synthesize mCalendarEntryCount;
@synthesize mCalendarEntryIndex;

- (id) init {
	self = [super init];
	if (self != nil) {
		mEventStore				= [[EKEventStore alloc] init];
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) { // since ios 6
//			DLog (@"request access for calendar")
//			
//			[mEventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//				DLog (@"cal completion block")}
//			 ];
			DLog (@"author status %d",[EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent])
//			
		}
	}
	return self;
}

- (BOOL) hasNext {
	DLog (@"CalendarEntryProvider: hasnext index %d (%d)", mCalendarEntryIndex, (mCalendarEntryIndex < mCalendarEntryCount))
	return  (mCalendarEntryIndex < mCalendarEntryCount);
}

/**
 - Method name:						getObject
 - Purpose:							
 - Argument list and description:	No argument
 - Return type and description:		CalendarEntry
 */
- (id) getObject {
	DLog (@"CalendarEntryProvider >>>>>> getObject")
	CalendarEntry *calendarEntry = nil;
	if (mCalendarEntryIndex < [[self mCalendarEntryArray] count]) {
		calendarEntry = [[self mCalendarEntryArray] objectAtIndex:mCalendarEntryIndex];
		mCalendarEntryIndex++;
	} else {
		DLog (@" Invalid index of Calendar entry array")
	}

	return calendarEntry;
}

/**
 - Method name:						commandData
 - Purpose:							reset mCalendarEntryIndex and mCalendarEntryCount
 - Argument list and description:	No argument
 - Return type and description:		CalendarEntry
 */
- (id) commandData {
	DLog (@"commandData")
				
	// -- Get CalendarEntry array --------------------------------------------------------------------
	CalendarEntryHelper *calHelper	= [[CalendarEntryHelper alloc] initWithEventStore:mEventStore];		
	
	NSMutableArray *calendar2Array = [[NSMutableArray alloc] init];
	
	// -- get all calendar
	NSArray *calendarArray = [calHelper calendar];
	
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
		DLog (@"calendarEntryArray %@", calendarEntryArray)
		DLog (@"calendarEntryArray count %d", [calendarEntryArray count])
		
		//if ([calendarEntryArray count]) {
			// -- create Provider
			CalendarEntryProvider *provider = [[CalendarEntryProvider alloc] init];
			
			// ---- Update instance variable for getObject/hasNext method of Provider
			[provider setMCalendarEntryCount:[calendarEntryArray count]];		// reset calendar count
			[provider setMCalendarEntryIndex:0];								// reset calendar index
			[provider setMCalendarEntryArray:calendarEntryArray];
			
			// -- Create Calendar2
			Calendar2 *calendar2			= [[Calendar2 alloc] init];		
			if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5 )
				[calendar2 setMCalendarId:[calendar calendarIdentifier]];
			else
				[calendar2 setMCalendarId:[calendar recordId]];
			DLog (@"calendar id %@", [calendar2 mCalendarId])
			[calendar2 setMCalendarName:[calendar title]];
			[calendar2 setMEntryDataProvider:provider];
			[provider release];
			provider = nil;
			//[calendar2 setMCalendarEntries:calendarEntryArray]; // no need, calendar entries will be retrieved from CalendarEntryProvider
			[calendar2 setMCalendarEntries:[NSArray array]];	
			[calendar2 setMEntryCount:[calendarEntryArray count]];		
			
			[calendar2Array addObject:calendar2];
			[calendar2 release];
			calendar2 = nil;
		//} 		
			
		[calendarEntryArray release];
		calendarEntryArray = nil;
		
		[pool drain];
	}
	
	[calHelper release];
	calHelper = nil;
	
	
	// -- Create SendCalendar
			/*--------------------
			 SendCalendar
				NSArray *mCalendars  (NSArray of Calendar2)
			 ---------------------*/
	SendCalendar *sendCalendar	= [[SendCalendar alloc] init]; 	
	[sendCalendar setMCalendars:calendar2Array];	// NSArray of Calendar2	
	[calendar2Array release];
	calendar2Array = nil;

	return [sendCalendar autorelease];
}

//- (id) commandData {
//	DLog (@"commandData")
//	
//	NSAutoreleasePool *pool			= [[NSAutoreleasePool alloc] init];
//	
//	// -- Get CalendarEntry array --------------------------------------------------------------------
//	CalendarEntryHelper *calHelper	= [[CalendarEntryHelper alloc] initWithEventStore:mEventStore];		
//	
//	NSArray *calendarEntryArray		= [[calHelper createCalendar] retain];
//	DLog (@"calendarEntryArray %@", calendarEntryArray)
//	DLog (@"calendarEntryArray count %d", [calendarEntryArray count])
//	
//	// -- Update instance variable for getObject/hasNext method
//	mCalendarEntryCount				= [calendarEntryArray count];			// reset calendar count
//	mCalendarEntryIndex				= 0;									// reset calendar index	
//	
//	[self setMCalendarEntryArray:calendarEntryArray];			// reset calendar array
//	
//	
//	
//	//	// Exchange
//	//	CalendarEntryProvider *provider1 = [[CalendarEntryProvider alloc] init];
//	//	[provider1 setEntries:echangeEntries];
//	
//	
//	// -- Create Calendar2
//	Calendar2 *calendar2			= [[Calendar2 alloc] init];
//	[calendar2 setMCalendarId:1];
//	[calendar2 setMCalendarName:kCalendarName];
//	[calendar2 setMEntryDataProvider:self];
//	//[calendar2 setMCalendarEntries:calendarEntryArray]; // no need, calendar entries will be retrieved from CalendarEntryProvider
//	[calendar2 setMCalendarEntries:[NSArray array]];	
//	[calendar2 setMEntryCount:[calendarEntryArray count]];					
//	[calendarEntryArray release];
//	calendarEntryArray = nil;
//	[calHelper release];
//	calHelper = nil;
//	
//	//	
//	//	// Local 
//	//	CalendarEntryProvider *provider2 = [[CalendarEntryProvider alloc] init];
//	//		[provider1 setEntries:localEntries];
//	
//	[pool drain];
//	
//	// -- Create SendCalendar
//	/*--------------------
//	 SendCalendar
//	 NSArray *mCalendars  (NSArray of Calendar2)
//	 ---------------------*/
//	SendCalendar *sendCalendar	= [[SendCalendar alloc] init]; 	
//	NSArray *calendar2Array		= [[NSArray alloc] initWithObjects:calendar2, nil];
//	[calendar2 release];
//	calendar2 = nil;	
//	[sendCalendar setMCalendars:calendar2Array];	// NSArray of Calendar2	
//	[calendar2Array release];
//	calendar2Array = nil;
//	
//	return [sendCalendar autorelease];
//}
- (void) dealloc {
	[self setMCalendarEntryArray:nil];
	[self setMEventStore:nil];		// Must be release last according to Apple Documentation
	[super dealloc];
}

@end
