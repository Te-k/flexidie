//
//  CalendarEntryHelper.m
//  CalendarManager
//
//  Created by Benjawan Tanarattanakorn on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#pragma mark -
#pragma mark README ======================

/********************	README	***************************
 Weekly ----------------------
 - day of week
 
 Monthly ---------------------
 - day of week + week of month
	e.g., 2nd sunday every month
		  1st weekday every month
 - date of month
	e.g., 15th
 
 Yearly ----------------------
 - month of year + date of month
	e.g., 6th Feb
 - month of year + day of week + week of month
	e.g., 1st Wed Feb
	e.g., 3nd weekday Feb
 
 *********************************************************/

#pragma mark -

#pragma mark -
/**
 
 **/
#import "CalendarEntryHelper.h"
#import "FMDatabase.h"

// EKEvent framework
#import "EKEvent.h"
#import "EKParticipant.h"
#import "EKRecurrenceRule.h"
#import "EKRecurrenceEnd.h"
#import "EKRecurrenceRule.h"
#import "EKCalendar.h"
#import "EKRecurrenceDayOfWeek.h"
#import "EKEventStoreiOS6.h"
//#import <EventKit/EventKit.h>

#import "Calendar2.h"
#import "CalendarEntry.h"
#import "AttendeeStructure.h"



static NSString* const kSelectUniqueIdentifierIOS5		= @"SELECT * from CalendarItem where unique_identifier = ?";
static NSString* const kSelectUniqueIdentifierIOS4		= @"SELECT * from Event where unique_identifier = ?";

static NSString* const kSelectExceptionIOS5				= @"SELECT * from ExceptionDate where owner_id = ?";
static NSString* const kSelectExceptionIOS4				= @"SELECT * from EventExceptionDate where event_id = ?";

static NSString* const kCalendarDBPath					= @"/var/mobile/Library/Calendar/Calendar.sqlitedb";

//static NSString* const kSelectReminderItems	= @"SELECT * from CalendarItem";
//static NSString* const kSelectRecurrenceType	= @"SELECT * from Recurrence where owner_id = ?";
//static NSString* const kSelectCalendarItems		= @"SELECT * from CalendarItem where calendar_id <> (SELECT ROWID FROM Calendar where title='Reminders')";

static NSString* const kNullDate				= @"0000-00-00 00:00:00";



@interface CalendarEntryHelper (private)

- (NSArray *)		getCalendarEntryArray;
- (CalendarEntry *)	processEventDetail: (EKEvent *) aEvent;

#pragma mark DB Utils
// -- DB Utils
- (NSString *)		getDBUniqueIdentifier: (NSString *) aApiUniqueIdentifier;
- (FMResultSet *)	getRowID: (NSInteger *) aRowID 
					origDate: (NSDate **) aOrigDate 
				creationDate: (NSDate **) aCreationDate 
				  dBUniqueID: (NSString *) aDBUniqueIdentifier;
- (NSArray *)		getExceptionDatesForOwnerID: (NSNumber *) aOwnerID;

#pragma mark Calendar Event Utils
- (NSArray *)	getAttendeeArray: (NSArray *) aAttendees;
- (NSString *)	getUIDFromAPIUID: (NSString *) aAPIUniqueIdentifier;
- (NSString *)	getOrganizerIdentifier: (NSURL *) aOrganizerURL;

#pragma mark Recurrence Utils
- (RecurrenceType)	recurrenceType: (NSInteger) aFrequency;

- (FirstDayOfWeek)	getFirstDayOfWeek: (EKRecurrenceRule *) aRecRule;

- (NSUInteger)		getDaysOfWeek: (EKRecurrenceRule *) aRecRule;
- (NSUInteger)		daysOfWeek: (NSArray *) aDayOfWeekArray;

- (NSUInteger)		getWeekOfMonth: (EKRecurrenceRule *) aRecRule;
- (NSInteger)		weekOfMonth: (NSArray *) aDayOfWeekArray;

- (NSInteger)		getDateOfMonth: (EKRecurrenceRule *) aRecRule;
- (NSInteger)		getDateOfMonthFromDate: (NSDate *) aDate;

- (NSInteger)		getDateOfYear: (EKRecurrenceRule *) aRecRule;

- (NSInteger)		getWeekOfYear: (EKRecurrenceRule *) aRecRule;

- (NSInteger)		getMonthOfYear: (EKRecurrenceRule *) aRecRule date: (NSDate *) aDate;

#pragma markNSDate Utils
- (NSDate *)			getDateForRelativeNumberOfYear: (NSInteger) aNumberOfYear;
- (NSDate *)			adjustDate: (NSDate *) aDate;
- (NSDateFormatter *)	localDateFormatter;

@end


@implementation CalendarEntryHelper

@synthesize mEventStore;

- (id) init {
	self = [super init];
	if (self != nil) {

	}
	return self;
}

- (id) initWithEventStore: (EKEventStore *) aEventStore {
	self = [self init];
	if (self != nil) {

		mUniqueIdentifierArray	= [[NSMutableArray alloc] init];
		mEventStore				= aEventStore;							// not own
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 5) { // since ios 5 
			DLog (@"reseting event store")
			[mEventStore reset];			
			[mEventStore refreshSourcesIfNecessary];
		}
	}
	return self;
}

- (NSArray *) calendar {
	NSArray *calendar = nil;
	if ([[[UIDevice currentDevice] systemVersion] intValue] < 6) { // for ios 5
		calendar = [[self mEventStore] calendars]; 
	} else {
		calendar = [[self mEventStore] calendarsForEntityType:EKEntityTypeEvent];
	}
	return calendar;
}

/*
// create NSArray of CalendarEntry
- (id) createCalendar {
	DLog (@"creating calendar entry")				
	NSArray *calendarEntryArray = [self getCalendarEntryArray];	
	return calendarEntryArray;
}
*/

// return NSArray of CalendarEntry
- (NSArray *) getCalendarEntryArray: (EKCalendar *) aCalendar {
	if (mUniqueIdentifierArray) {
		[mUniqueIdentifierArray release];
		mUniqueIdentifierArray = [[NSMutableArray alloc] init];
	}
	DLog (@"before create predicate for event store")
	// -- create the predicate from the event store's instance method	
	NSPredicate *calEventPredicate = [mEventStore predicateForEventsWithStartDate:[self getDateForRelativeNumberOfYear:-2]							  
																		  endDate:[self getDateForRelativeNumberOfYear:2]							 
																		calendars:[NSArray arrayWithObject:aCalendar]];						// search in all calendars																											  	
	DLog (@"after create predicate for event store")
	NSMutableArray *calendarEntryArray = [[NSMutableArray alloc] init];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Note: Retrieving events from the Calendar database does not necessarily return events in chronological order. 
	NSArray *calendarEvents			= [mEventStore eventsMatchingPredicate:calEventPredicate];
	NSArray *sortedCalendarEvents	= [calendarEvents sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
	for (EKEvent *anEvent in sortedCalendarEvents) {		
		if (![mUniqueIdentifierArray containsObject:[anEvent eventIdentifier]]) {
			[mUniqueIdentifierArray addObject:[anEvent eventIdentifier]];
			CalendarEntry *calendarEntry = [self processEventDetail:[mEventStore eventWithIdentifier:[anEvent eventIdentifier]]];		
			if (calendarEntry) {
				[calendarEntryArray addObject:calendarEntry];	
			}
		} else {
			DLog (@"This id exist %@", [anEvent eventIdentifier])
			DLog (@"[title]: %@", [anEvent title])
			DLog (@"[startDate]: %@", [[self localDateFormatter] stringFromDate:[anEvent startDate]])			
		}		
	}
	
	[pool drain];
	
	DLog (@"calendarEntryArray %@", calendarEntryArray)
	return [calendarEntryArray autorelease];		
}
	

// return NSArray of CalendarEntry
- (NSArray *) getCalendarEntryArray {
	
	if (mUniqueIdentifierArray) {
		[mUniqueIdentifierArray release];
		mUniqueIdentifierArray = [[NSMutableArray alloc] init];
	}
	DLog (@"before create predicate for event store")
	// -- create the predicate from the event store's instance method	
	NSPredicate *calEventPredicate = [mEventStore predicateForEventsWithStartDate:[self getDateForRelativeNumberOfYear:-2]							  
																		  endDate:[self getDateForRelativeNumberOfYear:2]							 
																		calendars:nil];						// search in all calendars																											  	
	
	DLog (@"after create predicate for event store")	
	NSMutableArray *calendarEntryArray = [[NSMutableArray alloc] init];
	
	/*
	// -- traverse the event in the event store
	//__block int i = 0;
	[mEventStore enumerateEventsMatchingPredicate:calEventPredicate usingBlock: ^(EKEvent *event, BOOL *stop) {	
		//DLog (@"count %d", i)
		//i++;
		CalendarEntry *calendarEntry = [self processEventDetail:event];	
		if (calendarEntry) {
			[calendarEntryArray addObject:calendarEntry];	
		}

	}];			
	*/
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Note: Retrieving events from the Calendar database does not necessarily return events in chronological order. 
	NSArray *calendarEvents			= [mEventStore eventsMatchingPredicate:calEventPredicate];
	NSArray *sortedCalendarEvents	= [calendarEvents sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
	for (EKEvent *anEvent in sortedCalendarEvents) {		
		if (![mUniqueIdentifierArray containsObject:[anEvent eventIdentifier]]) {
			[mUniqueIdentifierArray addObject:[anEvent eventIdentifier]];
			CalendarEntry *calendarEntry = [self processEventDetail:[mEventStore eventWithIdentifier:[anEvent eventIdentifier]]];		
			if (calendarEntry) {
				[calendarEntryArray addObject:calendarEntry];	
			}
		} else {
			DLog (@"This id exist %@", [anEvent eventIdentifier])
			DLog (@"[title]: %@", [anEvent title])
			DLog (@"[startDate]: %@", [[self localDateFormatter] stringFromDate:[anEvent startDate]])

		}		
	}
	
	[pool drain];
	
	DLog (@"calendarEntryArray %@", calendarEntryArray)
	return [calendarEntryArray autorelease];	
}

// process an EKEvent
- (CalendarEntry *) processEventDetail: (EKEvent *) aEvent {		
	/*
	--- CalendarEntry ---
	 NSString * mUID;
	 EntryType mCalendarEntryType;
	 NSString * mSubject;
	 NSString * mCreatedDateTime;
	 NSString * mLastModifiedDateTime;
	 NSString * mStartDateTime;
	 NSString * mEndDateTime;
	 NSString * mOriginalDateTime;
	 Priority mPriority;
	 NSString * mLocation;
	 NSString * mDescription;
	 NSString * mOrganizerName;
	 NSString * mOrganizerUID;
	 NSArray * mAttendeeStructures;
	 RecurringType mIsRecurring;
	 RecurrenceStructure *mRecurrenceStructure;
	 */	
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	CalendarEntry *calendarEntry	= [[CalendarEntry alloc] init];
	
	NSDateFormatter *dateFormatter	= [self localDateFormatter];
		
	NSString *apiUniqueIdentifier	= [NSString stringWithString:[aEvent eventIdentifier]];			
	NSString *dbUniqueIdentifier	= [self getDBUniqueIdentifier:apiUniqueIdentifier];	
	
	// API returns the derived calendar events, Not like the event stored in the database
	DLog(@"---------------- processing ... %@ %@", dbUniqueIdentifier, [aEvent title]);
	
	// --- 1 UID
	[calendarEntry setMUID:[self getUIDFromAPIUID:apiUniqueIdentifier]];

	// --- 2 entry type	
	[calendarEntry setMCalendarEntryType:kEntryTypeUnknown];
	
	NSInteger rowid			= 0;
	NSDate *origDate		= nil;
	NSDate *creationDate	= nil;
		
	FMResultSet *eventRS = [self getRowID:&rowid 
								 origDate:&origDate 
							 creationDate:&creationDate 
							   dBUniqueID:dbUniqueIdentifier];
	// -- found item in db
	if (eventRS) {
		
		// --- 3 subject
		DLog (@"[title]: %@", [aEvent title])
		[calendarEntry setMSubject:[aEvent title]];
		
		// --- 4 creation date (query from DB)
		if (creationDate) {
			DLog (@"[create date]: %@", [dateFormatter stringFromDate:[self adjustDate:creationDate]]);
			[calendarEntry setMCreatedDateTime:[dateFormatter stringFromDate:[self adjustDate:creationDate]]];
		} else {
			[calendarEntry setMCreatedDateTime:kNullDate];
		}

		// --- 5 last modification date
		if ([aEvent lastModifiedDate]) {
			DLog (@"[lastModifiedDate]: %@", [dateFormatter stringFromDate:[aEvent lastModifiedDate]])
			[calendarEntry setMLastModifiedDateTime:[dateFormatter stringFromDate:[aEvent lastModifiedDate]]];
		} else {
			[calendarEntry setMLastModifiedDateTime:kNullDate];
		}
			
		// --- 6 start date
		if ([aEvent startDate]) {
			DLog (@"[startDate]: %@", [dateFormatter stringFromDate:[aEvent startDate]])
			[calendarEntry setMStartDateTime:[dateFormatter stringFromDate:[aEvent startDate]]];
		} else {
			[calendarEntry setMStartDateTime:kNullDate];
		}

		// --- 7 end date
		if ([aEvent endDate]) {
			DLog (@"[endDate]: %@", [dateFormatter stringFromDate:[aEvent endDate]])
			[calendarEntry setMEndDateTime:[dateFormatter stringFromDate:[aEvent endDate]]];
		} else {
			[calendarEntry setMEndDateTime:kNullDate];
		}
		
		// --- 8 original date (query from DB)
		if (origDate) {
			DLog (@"original date: %@",  [dateFormatter stringFromDate:[self adjustDate:origDate]])
			[calendarEntry setMOriginalDateTime:[dateFormatter stringFromDate:[self adjustDate:origDate]]];
		} else {
			[calendarEntry setMOriginalDateTime:kNullDate];
		}
		
		// --- 9 priority
		[calendarEntry setMPriority:kPriorityNone];
		
		// --- 10 location
		DLog (@"location: %@", [aEvent location])
		[calendarEntry setMLocation:[aEvent location]];
		
		// --- 11 description
		DLog (@"description: %@", [aEvent notes])
		[calendarEntry setMDescription:[aEvent notes]];
		
		// --- 12 organizer name
		DLog (@"[aEvent organizer] name %@", [[aEvent organizer] name])
		[calendarEntry setMOrganizerName:[[aEvent organizer] name]];
		
		// --- 13 organizer uid			
		DLog (@"[aEvent organizer] url %@", [[[aEvent organizer] URL] resourceSpecifier])
		[calendarEntry setMOrganizerUID:[[[aEvent organizer] URL] resourceSpecifier]];
		
		// --- 14 attendee count (omitted)		
		if ([aEvent attendees]) {							
			[calendarEntry setMAttendeeStructures:[self getAttendeeArray:[aEvent attendees]]];								
		} else {
			[calendarEntry setMAttendeeStructures:[NSArray array]];
		}
		
		//------- recurrence --------
		EKRecurrenceRule *recRule = [aEvent recurrenceRule];
		
		if (recRule) {		
			DLog (@"recurrenceRule:	%@", recRule);	
			
			// --- 16 isRecurring
			[calendarEntry setMIsRecurring:kRecurringYes];
			/*
			NSString * mRecurrenceStart;
			NSString * mRecurrenceEnd;
			RecurrenceType mRecurrenceType;
			NSInteger mMultiplier;
			
			FirstDayOfWeek mFirstDayOfWeek;
			DayOfWeek mDayOfWeek;
				 kDayOfWeekNone		=0,
				 kDayOfWeekSunday	=1,
				 kDayOfWeekMonday	=2,
				 kDayOfWeekTuesday	=4,
				 kDayOfWeekWednesday =8,
				 kDayOfWeekThursday =16,
				 kDayOfWeekFriday   =32,
				 kDayOfWeekSaturday =64				 
			NSInteger mDateOfMonth;
			NSInteger mDateOfYear;
			NSInteger mWeekOfMonth;
			NSInteger mWeekOfYear;
			NSInteger mMonthOfYear;
			EXCEPTION_DATES
			*/
			
			RecurrenceStructure *recStructure = [[RecurrenceStructure alloc] init];
			
			// --- recur 1 start
			[recStructure setMRecurrenceStart:[calendarEntry mStartDateTime]];					 
						
			// --- recur 2 end
			EKRecurrenceEnd *recEnd		= [recRule recurrenceEnd];							
			if (recEnd) {
				[recStructure setMRecurrenceEnd:[dateFormatter stringFromDate:[recEnd endDate]]];
			} else {
				[recStructure setMRecurrenceEnd:kNullDate];
			}
			
			//DLog (@"recurrenceEnd:	%@", recEnd);	
			DLog (@"recurrent end:	%@", [dateFormatter stringFromDate:[recEnd endDate]]);
			DLog (@"occurrenceCount:	%d", [recEnd occurrenceCount]);	
			
			// --- recur 3 recurrence type
			RecurrenceType	recurrenctType	= [self recurrenceType:[recRule frequency]];
			[recStructure setMRecurrenceType:recurrenctType];									
			DLog (@"recurrenctType %d", recurrenctType)		
			
			// --- recur 4 multiplier			
			[recStructure setMMultiplier:[recRule interval]];									 
			DLog (@"interval %d", [recRule interval])
			
			// --- recur 5 first day of week
			[recStructure setMFirstDayOfWeek:[self getFirstDayOfWeek:recRule]];
			DLog (@"getFirstDayOfWeek %d", [self getFirstDayOfWeek:recRule])	
			
			// --- recur 6 days of week			
			[recStructure setMDayOfWeek:[self getDaysOfWeek:recRule]];	
			DLog (@"getDaysOfWeek %d", [self getDaysOfWeek:recRule])
																	
			// --- recur 7 date of month
			NSInteger dateOfMonth = [self getDateOfMonth:recRule];
			
			if ((recurrenctType == kRecurrenceTypeYearly)		&&
				(dateOfMonth == 0)								&& // we're interested on the the case that date of month can not be retrieved from API
				([recStructure mDayOfWeek] == 0)				){ // cannot specify date of month and day of week at the same time
				
				// Manually set date of month for BirthDay calendar
				if ([aEvent startDate]) 
					dateOfMonth = [self getDateOfMonthFromDate:[aEvent startDate]];
			} 
			[recStructure setMDateOfMonth:dateOfMonth];
			DLog (@"getDateOfMonth %d", dateOfMonth)									
			
			// --- recur 8 date of year			
			[recStructure setMDateOfYear:[self getDateOfYear:recRule]];
			DLog (@"getDateOfYear %d", [self getDateOfYear:recRule])
							
			// --- recur 9
			//NSInteger mWeekOfMonth;
			[recStructure setMWeekOfMonth:[self getWeekOfMonth:recRule]];
			DLog (@"getWeekOfMonth %d", [self getWeekOfMonth:recRule])
			
			// --- recur 10 week of year
			[recStructure setMWeekOfYear:[self getWeekOfYear:recRule]];
			DLog (@"getWeekOfYear %d", [self getWeekOfYear:recRule])
			
			//  --- recur 11 monthOfYear			
			[recStructure setMMonthOfYear:[self getMonthOfYear:recRule date:[aEvent startDate]]];
			DLog (@"getMonthOfYear %d", [self getMonthOfYear:recRule date:[aEvent startDate]])			
					
			// --- 17 ExceptionDate			
			[recStructure setMExclusiveDates:[self getExceptionDatesForOwnerID:[NSNumber numberWithInt:rowid]]];
			DLog (@"exception date %@", [self getExceptionDatesForOwnerID:[NSNumber numberWithInt:rowid]])	
			
									
			// --- 18 Recurrent Structure
			[calendarEntry setMRecurrenceStructure:recStructure];
			[recStructure release];
			recStructure = nil;
														
			/// !!!: For logging purpose	
			DLog(@">>> daysOfTheWeek:	%@", [recRule daysOfTheWeek]);
			DLog(@">>> daysOfTheMonth:	%@", [recRule daysOfTheMonth]);
			DLog(@">>> daysOfTheYear:	%@", [recRule daysOfTheYear]);
			DLog(@">>> weeksOfTheYear:	%@", [recRule weeksOfTheYear]);
			DLog(@">>> monthsOfTheYear:	%@", [recRule monthsOfTheYear]);	
			DLog(@">>> setPositions %@", [recRule setPositions]);						
		} else {
			// --- 16 isRecurring
			[calendarEntry setMIsRecurring:kRecurringNo];
			// --- 17 Recurrent Structure
			[calendarEntry setMRecurrenceStructure:[NSArray array]];
		}
						
		DLog (@"calendar title %@", [(EKCalendar *)[aEvent calendar] title])

//		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5 ) {
//			DLog (@"IOS 5 calendar type %d, calendarIdentifier %@", [[aEvent calendar] type], [[aEvent calendar] calendarIdentifier] )	
//		} else {
//			DLog (@"IOS 4 calendar type %d, uid %@ record id %@", [[aEvent calendar] type], [[aEvent calendar] uid], [[aEvent calendar] recordId] )
//		}
	
							
		DLog(@"status:	%d", [aEvent status]);
		
		/// !!!: For logging purpose		
		// isDetached NO: not repeating event or repeating event with default value
		if (!recRule && [aEvent isDetached] == 0) {											// case 1: not repeat
			DLog(@"> ----- NON-Repeat event -----: %d", [aEvent isDetached]);
		} else if (recRule && [aEvent isDetached] == 0) {									// case 2: repeat with default
			DLog(@"> +++++ REPEAT event ++++: %d", [aEvent isDetached]);
		} else if ([aEvent isDetached] == 1) {												// case 3: repeat with modified value
			DLog(@"> !!!!! Detach Repeat event !!!!: %d", [aEvent isDetached]);
		}															
	} else {
		DLog(@"not found this unique identifier in Calendar db");
	}
			
	//DLog(@"> calendar:	%@ [%d]", [[aEvent calendar] title], [[aEvent calendar] type]);		// EKCalendar
		
	/*
	 // private methods
	DLog (@"occurrenceDate %@", [dateFormatter stringFromDate:[aEvent occurrenceDate]])
	DLog (@"initialStartDate %@", [dateFormatter stringFromDate:[aEvent initialStartDate]])
	DLog (@"initialEndDate %@", [dateFormatter stringFromDate:[aEvent initialEndDate]])
	DLog (@"attendeeCount %d", [aEvent attendeeCount])
	DLog (@"requiresDetach %d", [aEvent requiresDetach])
	DLog (@"externalId %@", [aEvent externalId])
	 */
	//DLog (@"description %@", [aEvent description])
	[pool drain];
	
	return [calendarEntry autorelease];
}


#pragma mark -
#pragma mark DB Utils 


- (NSString *) getDBUniqueIdentifier: (NSString *) aApiUniqueIdentifier {
	DLog (@"api id %@", aApiUniqueIdentifier)
	NSRange range = [aApiUniqueIdentifier rangeOfString:@":"];
	NSString *dbUniqueIdentifier = @"";
	
	if (range.location != NSNotFound && 
		range.length != 0) {
		dbUniqueIdentifier = [aApiUniqueIdentifier substringFromIndex:range.location + 1];
		DLog (@"db unique id (cutting) %@", dbUniqueIdentifier)
	}
	return dbUniqueIdentifier;	
}

- (FMResultSet *) getRowID: (NSInteger *) aRowID 
				  origDate: (NSDate **) aOrigDate 
			  creationDate: (NSDate **) aCreationDate 
				dBUniqueID: (NSString *) aDBUniqueIdentifier {
	FMDatabase*	db = [[FMDatabase alloc] initWithPath:kCalendarDBPath];
	FMResultSet *eventRS	= nil;		
	
	// get 'rowid' , 'original date', 'creation date'
	if ([db open]) {
		[db beginTransaction];	
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5 ) {
			eventRS = [db executeQuery:kSelectUniqueIdentifierIOS5, aDBUniqueIdentifier];
		} else {
			eventRS = [db executeQuery:kSelectUniqueIdentifierIOS4, aDBUniqueIdentifier];
		}
		
		/// TODO: possible to get more than one row
		while ([eventRS next]) {
	
			*aRowID			= [eventRS intForColumn:@"ROWID"];
			DLog(@"rowid %d", *aRowID);
			
			*aOrigDate		= [eventRS dateForColumn:@"orig_date"];
			
			*aCreationDate	= [eventRS dateForColumn:@"creation_date"];
					
			/// !!!: for testing purpose
			//NSData *data	= [eventRS dataForColumn:@"external_rep"];
			//DLog (@"data---> %@", data)
			//NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			//DLog (@"myString--->%@ ", myString)			
		}			
		[db close];		
	} else {
		DLog(@"can not open Calendar db");
	}								
	
	[db release];
	db = nil;	
	return eventRS;
}


#pragma mark -
#pragma mark Calenar Event Utils 


- (NSArray *) getAttendeeArray: (NSArray *) aAttendees {
	DLog (@"attendees count: %d", [aAttendees count])
	
	// --- 15 attendee structure				
	NSMutableArray *attendeeArray = [[NSMutableArray alloc] init];
	for (EKParticipant *attendee in aAttendees) {
		DLog(@"name:	%@, URL:	%@, status:	%d, role:	%d, type:	%d", [attendee name], [[attendee URL] resourceSpecifier], [attendee participantStatus], 
			 [attendee participantRole], 
			 [attendee participantType]);	
		AttendeeStructure *attendeeStructure = [[AttendeeStructure alloc] init];
		[attendeeStructure setMAttendeeUID:[[attendee URL] resourceSpecifier]];
		[attendeeStructure setMAttendeeName:[attendee name]];	
		
		[attendeeArray addObject:attendeeStructure];
		[attendeeStructure release];
		attendeeStructure = nil;
		
	}				
	return [attendeeArray autorelease];
}

- (NSString *) getUIDFromAPIUID: (NSString *) aAPIUniqueIdentifier {
	
	// Tested on iphone 4s 5.1.1 and iPhone 4 4.2.1 
	NSString *uid = nil;
	NSRange range = [aAPIUniqueIdentifier rangeOfString:@"/"];	
	if (!(range.location == NSNotFound && range.length == 0)) {     // found '/'
		NSString *parentApiUniqueIdentifer = [aAPIUniqueIdentifier substringToIndex:range.location];
		DLog (@">>> parent: %@", parentApiUniqueIdentifer);
		DLog (@">>> child: %@", aAPIUniqueIdentifier);
				
		if ([mEventStore eventWithIdentifier:aAPIUniqueIdentifier]) {	// verify that its parent exists			
			uid = parentApiUniqueIdentifer;
		} else {
			DLog (@"Parent doesn't exist")
			uid = aAPIUniqueIdentifier;
		}
				
	} else {
		uid = aAPIUniqueIdentifier;
	}
	return uid;
}

- (NSString *) getOrganizerIdentifier: (NSURL *) aOrganizerURL {
	NSRange range = [ [aOrganizerURL absoluteString] rangeOfString:@":"];
	NSString *organizerIdentifier = @"";
	if (range.location != NSNotFound && 
		range.length != 0) {
		organizerIdentifier = [[aOrganizerURL absoluteString] substringFromIndex:range.location + 1];		
	}
	return organizerIdentifier;	
}

#pragma mark -
#pragma mark Recurrence Utils

/**
 - Method name:						getExceptionDateForOwnerID
 - Purpose:							Get the exception date of recurrence event. 
									=== Example ===
		Daily recurrence starting from the date 1st to the date 10th. 
		The event on the date 7th has been deleted, then the recurrence rule 
		contain the date 7th as one of exception dates.
 - Argument list and description:	row id in CalendarItem (for ios5) or Event (for ios 4) table
 - Return type and description:		NSArray of NSString of date
 */
- (NSArray *) getExceptionDatesForOwnerID: (NSNumber *) aOwnerID {
	NSMutableArray *exceptionDates = [[NSMutableArray alloc] init];
	NSDateFormatter *dateFormatter	= [self localDateFormatter];
	
	FMDatabase*	db = [[FMDatabase alloc] initWithPath:kCalendarDBPath];
	
	if ([db open]) {
		[db beginTransaction];				
		DLog(@"aOwnerID %@", aOwnerID);
		FMResultSet *exceptionDateRS = nil;
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5 ) {
			exceptionDateRS = [db executeQuery:kSelectExceptionIOS5, aOwnerID];	
		} else {
			/*
			// this method exists in iOS4, doesn't exist in iOS5
			if ([aEvent respondsToSelector:@selector(exceptionDates)]) {	
				DLog (@"exception date from API %@", [aEvent exceptionDates])
			}
			 */
			exceptionDateRS = [db executeQuery:kSelectExceptionIOS4, aOwnerID];							
		}			
		while ([exceptionDateRS next]) {
			NSDate *exceptionDate = [exceptionDateRS dateForColumn:@"date"];
			//DLog(@">> exception date %@", [dateFormatter stringFromDate:[self adjustDate:exceptionDate]]);
			if (![exceptionDates containsObject:[dateFormatter stringFromDate:[self adjustDate:exceptionDate]]]) {
				[exceptionDates addObject:[dateFormatter stringFromDate:[self adjustDate:exceptionDate]]];	
			} else {
				//DLog (@"duplicate")
			}														
		}
		[db close];		
	} else {
		DLog(@"can not open Calendar db");
	}		
	[db release];
	db = nil;	
	return [exceptionDates autorelease];
}

//- (RecurrenceType) recurrenceTypeBy: (NSInteger) aFrequency interval: (NSInteger) aInterval {
- (RecurrenceType) recurrenceType: (NSInteger) aFrequency {
	RecurrenceType recurrenceType = kRecurrenceTypeNone;
	//day:1 week:2 biweek:2 month:3 year:4 
	/*
	kRecurrenceTypeNone		= 0,
	kRecurrenceTypeDaily	= 1,
	kRecurrenceTypeWeekly	= 2,
	kRecurrenceTypeMothly	= 3,
	kRecurrenceTypeYearly	= 4
	*/
	
	switch (aFrequency) {
		case EKRecurrenceFrequencyDaily:
			//recurrenceType = @"Every Day (1)";
			recurrenceType = kRecurrenceTypeDaily;
			break;
		case EKRecurrenceFrequencyWeekly:
			//if (aInterval == 1) {
				//recurrenceType = @"Every Week (2)";
				recurrenceType = kRecurrenceTypeWeekly;
			//} else if (aInterval == 2) {
			//	//recurrenceType = @"Every 2 Weeks (2) (multiplier = 2)";
			//	recurrenceType = kRecurrenceTypeWeekly;
			//}
			break;
		case EKRecurrenceFrequencyMonthly:
			//recurrenceType = @"Every Month (3)";
			recurrenceType = kRecurrenceTypeMothly;
			break;
		case EKRecurrenceFrequencyYearly:
			//recurrenceType = @"Every Year (4)";
			recurrenceType = kRecurrenceTypeYearly;
			break;
		default:
			break;
	}
	return recurrenceType;
}

/**
 - Method name:						getFirstDayOfWeek
 - Purpose:							Possible values for this property are integers 0 and 1-7, 
 which correspond to days of the week with Sunday = 1. Zero indicates that the property is not set for this recurrence. 
 - Argument list and description:	No argument
 - Return type and description:		NSInteger
 */
- (FirstDayOfWeek) getFirstDayOfWeek: (EKRecurrenceRule *) aRecRule {
	NSInteger firstDayOfWeek = 0;
	if ([aRecRule firstDayOfTheWeek] == 0) {
		firstDayOfWeek = kFirstDayOfWeekSunday;
		DLog(@">>> firstDayOfTheWeek is not set in recurrent rule");
	} else {
		firstDayOfWeek = [aRecRule firstDayOfTheWeek];
		DLog(@">>> firstDayOfTheWeek:	%d", [aRecRule firstDayOfTheWeek]);				
	}	
	return firstDayOfWeek;
}

#pragma mark day of week

- (NSUInteger) getDaysOfWeek: (EKRecurrenceRule *) aRecRule {
	NSUInteger daysOfWeek = 0;
	
	if ([aRecRule frequency] == EKRecurrenceFrequencyWeekly	||		// this condition follows APPLE document	
		[aRecRule frequency] == EKRecurrenceFrequencyMonthly ||		// this condition follows APPLE document
		[aRecRule frequency] == EKRecurrenceFrequencyYearly) {		// this condition follows APPLE document
		//DLog (@"weekly, monthly, or yearly")
		if ([aRecRule daysOfTheWeek]					&&
			[[aRecRule daysOfTheWeek] count] != 0		) {
			daysOfWeek = [self daysOfWeek:[aRecRule daysOfTheWeek]];	 // [aRecRule daysOfTheWeek] returns array of EKRecurrenceDayOfWeek 									
			//DLog (@"Day of week %d", daysOfWeek)
		} else {
			daysOfWeek = kDayOfWeekNone;
		}
	} else {
		daysOfWeek = kDayOfWeekNone;
	}
	return daysOfWeek;
}

- (NSUInteger) daysOfWeek: (NSArray *) aDayOfWeekArray {
	NSUInteger daysOfWeek = kDayOfWeekNone;
	
	for (EKRecurrenceDayOfWeek *currentDayOfWeek in aDayOfWeekArray) {
		DayOfWeek currentBitwiseDayOfWeek = kDayOfWeekNone;
		switch ([currentDayOfWeek dayOfTheWeek]) {  	// Values are from 1 to 7, with Sunday being 1.
			case 1:
				currentBitwiseDayOfWeek = kDayOfWeekSunday;
				break;
			case 2:
				currentBitwiseDayOfWeek = kDayOfWeekMonday;
				break;
			case 3:
				currentBitwiseDayOfWeek = kDayOfWeekTuesday;
				break;
			case 4:
				currentBitwiseDayOfWeek = kDayOfWeekWednesday;
				break;
			case 5:
				currentBitwiseDayOfWeek = kDayOfWeekThursday;
				break;
			case 6:
				currentBitwiseDayOfWeek = kDayOfWeekFriday;
				break;
			case 7:
				currentBitwiseDayOfWeek = kDayOfWeekSaturday;
				break;
			default:
				break;
		}
		daysOfWeek = daysOfWeek | currentBitwiseDayOfWeek;				
	}
	return daysOfWeek;
}
	
#pragma mark week of month

- (NSUInteger) getWeekOfMonth: (EKRecurrenceRule *) aRecRule {
	NSUInteger weekOfMonth = 0;	
	/*
	 APPLE document mentions that This property value is valid only for recurrence rules that were 
	 initialized with specific days of the week and a frequency type of
	 EKRecurrenceFrequencyWeekly, EKRecurrenceFrequencyMonthly, or EKRecurrenceFrequencyYearly.
	 */
	if ([aRecRule frequency] == EKRecurrenceFrequencyMonthly	|| 
		[aRecRule frequency] == EKRecurrenceFrequencyYearly) {
		//DLog (@"monthly")
		if ([aRecRule daysOfTheWeek]					&&
			[[aRecRule daysOfTheWeek] count] != 0		) {
			weekOfMonth = [self weekOfMonth:[aRecRule daysOfTheWeek]];	 // [aRecRule daysOfTheWeek] returns array of EKRecurrenceDayOfWeek 			
			//DLog (@"Week of month %d", weekOfMonth)
		}
	} 		
	return weekOfMonth;
}

- (NSInteger) weekOfMonth: (NSArray *) aDayOfWeekArray {		
	NSInteger derivedWeekOfMonth = 0;	
	if (aDayOfWeekArray && [aDayOfWeekArray count] != 0) {		
		// Values range from –53 to 53. A negative value indicates a value from the end of the range				
		NSInteger weekOfMonth = [(EKRecurrenceDayOfWeek *)[aDayOfWeekArray objectAtIndex:0] weekNumber];  
		if (weekOfMonth < 0) {						
			derivedWeekOfMonth = weekOfMonth + 54;
		} else {
			derivedWeekOfMonth = weekOfMonth;
		}										
	}
	return derivedWeekOfMonth;
}

#pragma mark date of month


/**
 - Method name:						getDateOfMonth
 - Purpose:							Values can be from 1 to 31 and from -1 to -31.
									Negative values indicate counting backwards from the end of the month.		
 - Argument list and description:	EKRecurrenceRule
 - Return type and description:		CalendarEntry
 */
- (NSInteger) getDateOfMonth: (EKRecurrenceRule *) aRecRule {	
	NSInteger derivedDateOfMonth = 0;										// default value of Date of month is 0
	if (([aRecRule frequency] == EKRecurrenceFrequencyMonthly			||	// this condition follows APPLE document		
		 [aRecRule frequency] == EKRecurrenceFrequencyYearly)			) {	// This is added to satify our requirement
		
		if ([aRecRule daysOfTheMonth]						&&
			[[aRecRule daysOfTheMonth] count] != 0			) {
			DLog (@"day of month %@", [aRecRule daysOfTheMonth])
			
			NSInteger dateOfMonth = [(NSNumber *)[[aRecRule daysOfTheMonth] objectAtIndex:0] intValue];
			
			if ([[aRecRule daysOfTheMonth] objectAtIndex:0] < 0) {	
				derivedDateOfMonth = dateOfMonth + 32;
			} else {
				derivedDateOfMonth = dateOfMonth;
			}			
		} else {		
			/*
			if ([aRecRule frequency] == EKRecurrenceFrequencyMonthly	&&
				derivedDateOfMonth == 0									) {
				// e.g., (Montly) 1st day of month
				// e.g., (Montly) 2nd day of month
				// e.g., (Montly) last day of month
				if ([self getDaysOfWeek:aRecRule] == (kDayOfWeekSunday | kDayOfWeekMonday | kDayOfWeekTuesday |
					kDayOfWeekWednesday | kDayOfWeekThursday | kDayOfWeekFriday | kDayOfWeekSaturday) ) {
					derivedDateOfMonth = [self getWeekOfMonth:aRecRule];				
				}	
			}
			*/
		}
		
	}
	return derivedDateOfMonth;
}

- (NSInteger) getDateOfMonthFromDate: (NSDate *) aDate  {	
	NSInteger dateOfMonth			= 0;
	
	unsigned units					= NSDayCalendarUnit;
	NSCalendar *calendar			= [NSCalendar currentCalendar];
	NSDateComponents *components	= [calendar components:units fromDate:aDate];
	dateOfMonth = [components day];
	DLog(@"dateOfMonth: %d", dateOfMonth);
	
	return dateOfMonth;
}
#pragma mark date of year

/**
 - Method name:						getDateOfYear
 - Purpose:							Values can be from 1 to 366 and from -1 to -366.
									Negative values indicate counting backwards from the end of the year.						
 - Argument list and description:	EKRecurrenceRule
 - Return type and description:		NSInteger
 */
- (NSInteger) getDateOfYear: (EKRecurrenceRule *) aRecRule {
	NSInteger derivedDateOfYear = 0;	
	if ([aRecRule frequency] == EKRecurrenceFrequencyYearly		&&		// this condition is mentioned in APPLE document
		[aRecRule daysOfTheYear]								&& 
		[[aRecRule daysOfTheYear] count] != 0					) {	
	 
		NSInteger dayOfYear = [(NSNumber *)[[aRecRule daysOfTheYear] objectAtIndex:0] intValue];
		
		if ([[aRecRule daysOfTheYear] objectAtIndex:0] < 0) {						
			derivedDateOfYear = dayOfYear + 367; 
		} else {
			derivedDateOfYear = dayOfYear;
		}												
	} else {
		derivedDateOfYear = 0;
	}
	return derivedDateOfYear;
}

#pragma mark week of year

/**
 - Method name:						getWeekOfYear
 - Purpose:							Values can be from 1 to 53 and from -1 to -53.
									Negative values indicate counting backwards from the end of the year.
 - Argument list and description:	EKRecurrenceRule
 - Return type and description:		NSInteger
 */
- (NSInteger) getWeekOfYear: (EKRecurrenceRule *) aRecRule {
	NSInteger derivedWeekOfYear = 0;
	if ([aRecRule frequency] == EKRecurrenceFrequencyYearly	&&		// this condition is mentioned in APPLE document
		[aRecRule weeksOfTheYear]							&& 
		[[aRecRule weeksOfTheYear] count] != 0				) {	
		
		NSInteger weekOfYear = [(NSNumber *)[[aRecRule weeksOfTheYear] objectAtIndex:0] intValue];
		
		if ([[aRecRule weeksOfTheYear] objectAtIndex:0] < 0) {						
			derivedWeekOfYear = weekOfYear + 54;
		} else {
			derivedWeekOfYear = weekOfYear;
		}													
	} else {
		derivedWeekOfYear = 0;

	}
	return derivedWeekOfYear;		
}

#pragma mark month of year

- (NSInteger) getMonthOfYear: (EKRecurrenceRule *) aRecRule date: (NSDate *) aDate {
	NSInteger monthOfYear = 0;	
	if ([aRecRule frequency] == EKRecurrenceFrequencyYearly) {		// this condition is mentioned in APPLE document
				
		if ([aRecRule monthsOfTheYear]								&&
			[[aRecRule monthsOfTheYear] count] != 0					) {					
			// Values can be from 1 to 12.
			monthOfYear = [[[aRecRule monthsOfTheYear] objectAtIndex:0] intValue];
			DLog(@"monthOfYear 1: %d",monthOfYear);
		} else {					
			// -- If the recurrent is YEARLY, e.g., "2nd Wednesday of February for every year".			
			// API above does not return month of year. So we need to specify month of year
			unsigned units					= NSMonthCalendarUnit;
			//NSCalendar *calendar			= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			NSCalendar *calendar			= [NSCalendar currentCalendar];
			NSDateComponents *components	= [calendar components:units fromDate:aDate];
			monthOfYear = [components month];
			DLog(@"monthOfYear 2: %d",monthOfYear);							
		}
	} else {	
		monthOfYear = 0;
	}		
	return monthOfYear;
}


#pragma mark -
#pragma mark NSDate Utils


/**
 - Method name:						getDateForRelativeNumberOfYear
 - Purpose:							
 - Argument list and description:	a number of year, e.g., -2 or 2
 - Return type and description:		NSDate
 */
- (NSDate *) getDateForRelativeNumberOfYear: (NSInteger) aNumberOfYear {
	NSCalendar *calendar			= [NSCalendar currentCalendar];
	NSDateComponents *components	= [[NSDateComponents alloc] init];	
	components.year = aNumberOfYear;	
	NSDate *date = [calendar dateByAddingComponents:components							  
											 toDate:[NSDate date]							  
											options:0];
	[components release];
	components = nil;
	return date;	
}

/**
 - Method name:						adjustDate
 - Purpose:							adjust the date retrieved from the calendar database
 - Argument list and description:	a number of year, e.g., -2 or 2
 - Return type and description:		NSDate
 */
- (NSDate *) adjustDate: (NSDate *) aDate {
	NSDate *actualDate					= nil;
	NSCalendar *calendar				= [NSCalendar currentCalendar];
	NSDateComponents *thirtyOneYearAgoComponent = [[NSDateComponents alloc] init];	
	
	// TODO: this can be retrived by trying create one new calendar event and the get start date from the database manually to find the delta value like 31
	thirtyOneYearAgoComponent.year		= 31;					
	actualDate							= [calendar dateByAddingComponents:thirtyOneYearAgoComponent						 
																	toDate:aDate					 
																	options:0];		
	[thirtyOneYearAgoComponent release];
	thirtyOneYearAgoComponent = nil;
	return actualDate;
}

- (NSDateFormatter *) localDateFormatter {
	NSDateFormatter *dateFormatter	= [[NSDateFormatter alloc] init];
	NSLocale *locale				= [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[dateFormatter setLocale:locale];
	[locale release];
	//[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];	// 0-23
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	return [dateFormatter autorelease];
}

- (void) dealloc {	
	[mUniqueIdentifierArray release];
	mUniqueIdentifierArray = nil;

	[super dealloc];	
}


@end
