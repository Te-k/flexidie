//
//  CalendarProtocolConverter.m
//	Calendar
//
//  Created by Ophat on 1/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CalendarProtocolConverter.h"
#import "Calendar.h"
#import "CalendarEntry.h"
#import "AttendeeStructure.h"

@implementation CalendarProtocolConverter

+(NSData *)convertToProtocol:(Calendar *)aCalendar{
	NSMutableData *returnData = [NSMutableData data];
	NSMutableData *calendarEntriesStructureData = [[NSMutableData alloc] init];
	
	//============= L_256
	uint8_t lengthOfCalendarId = [[aCalendar mCalendarId] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[returnData appendBytes:&lengthOfCalendarId length:sizeof(uint8_t)];
	DLog(@"returnData %@ lengthOfCalendarName %d",returnData,lengthOfCalendarId);

	//============= CalendarId
//	uint32_t calendarId  = [aCalendar mCalendarId];
//	calendarId = htonl(calendarId);
//	[returnData appendBytes:&calendarId length:sizeof(uint32_t)];
//	DLog(@"returnData %@ calendarId %d",returnData,calendarId);
	
	NSData * calendarId = [[aCalendar mCalendarId] dataUsingEncoding:NSUTF8StringEncoding];
	[returnData appendData:calendarId];
	DLog(@"returnData %@ lengthOfCalendarName %@",returnData,calendarId);
	DLog (@"[aCalendar mCalendarId] %@", [aCalendar mCalendarId])
	
	//============= L_256
	uint8_t lengthOfCalendarName = [[aCalendar mCalendarName] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[returnData appendBytes:&lengthOfCalendarName length:sizeof(uint8_t)];
	DLog(@"returnData %@ lengthOfCalendarName %d",returnData,lengthOfCalendarName);
	
	//============= mCalendarName
	NSData * calendarName = [[aCalendar mCalendarName] dataUsingEncoding:NSUTF8StringEncoding];
	[returnData appendData:calendarName];
	DLog(@"returnData %@ lengthOfCalendarName %@",returnData,calendarName);
	
	//============= mCalendarEntriesCount
	uint16_t lengthOfmCalendarEntriesCount = [[aCalendar mCalendarEntries] count];
	lengthOfmCalendarEntriesCount = htons(lengthOfmCalendarEntriesCount); 
	[returnData appendBytes:&lengthOfmCalendarEntriesCount length:sizeof(uint16_t)];
	DLog(@"returnData %@ lengthOfmCalendarEntriesCount %d",returnData,lengthOfmCalendarEntriesCount);
	
	//============= mCalendarEntries
	//============= mCalendarEntries Structure
	for (int i=0 ; i< [[aCalendar mCalendarEntries]count]; i++) {
		//============= Obtain Object from Array 
		CalendarEntry * calendarEntry = [[aCalendar mCalendarEntries] objectAtIndex:i];
		NSData *calendarEntryStructureData = [CalendarProtocolConverter convertCalendarEntryToProtocol:calendarEntry];
		[calendarEntriesStructureData appendData:calendarEntryStructureData];
		DLog(@"%d calendarEntry %@ calendarEntriesStructureData %@",i,calendarEntry,calendarEntriesStructureData);
	}
	DLog(@"calendarEntriesStructureData is %@\n",calendarEntriesStructureData);
	[returnData appendData:calendarEntriesStructureData];
	[calendarEntriesStructureData release];
	calendarEntriesStructureData = nil;

	DLog(@"Finally returnData is %@\n",returnData);
	return returnData;
}

+ (NSData *) convertCalendarEntryToProtocol:(CalendarEntry *) aCalendarEntry {
	NSMutableData *calendarEntryStructureData = [NSMutableData data];
	
	//============= Obtain Object from Array 
	CalendarEntry * calendarEntry = aCalendarEntry;
	DLog(@"calendarEntry %@ calendarEntryStructureData %@",calendarEntry,calendarEntryStructureData);
	
	//============= UIDLength
	uint8_t lengthOfUID = [[calendarEntry mUID]lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[calendarEntryStructureData appendBytes:&lengthOfUID length:sizeof(uint8_t)];
	DLog(@"lengthOfUID %d calendarEntryStructureData %@",lengthOfUID,calendarEntryStructureData);
	
	//============= UID
	NSData * UID = [[calendarEntry mUID] dataUsingEncoding:NSUTF8StringEncoding];
	[calendarEntryStructureData appendData:UID];
	DLog(@"UID %@ calendarEntryStructureData %@",UID,calendarEntryStructureData);
	
	//============= EntryType
	uint8_t entrytype = [calendarEntry mCalendarEntryType];
	[calendarEntryStructureData appendBytes:&entrytype length:sizeof(uint8_t)];
	DLog(@"entrytype %d calendarEntryStructureData %@",entrytype,calendarEntryStructureData);
	
	//============= L_64k
	uint16_t lengthOfSubject = [[calendarEntry mSubject] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	DLog (@"!!!!!!!!!!!!! lengthOfSubject %d !!!!!!!!!!!!!!", lengthOfSubject)
	lengthOfSubject = htons(lengthOfSubject); 
	[calendarEntryStructureData appendBytes:&lengthOfSubject length:sizeof(uint16_t)];
	DLog(@"lengthOfSubject %d calendarEntryStructureData %@",lengthOfSubject,calendarEntryStructureData);
	
	//============= Subject
	NSData * subject = [[calendarEntry mSubject] dataUsingEncoding:NSUTF8StringEncoding];
	DLog (@"!!!!!!!!!!!!! subject %@ !!!!!!!!!!!!!!", [calendarEntry mSubject])

	[calendarEntryStructureData appendData:subject];
	DLog(@"subject %@ calendarEntryStructureData %@",subject,calendarEntryStructureData);
	
	//============= CreateDateTime
	NSData * createDateTime = [[calendarEntry mCreatedDateTime] dataUsingEncoding:NSUTF8StringEncoding];
	[calendarEntryStructureData appendData:createDateTime];
	DLog(@"createDateTime %@ calendarEntryStructureData %@",createDateTime,calendarEntryStructureData);
	
	//============= LastModifiedDateTime
	NSData * lastModifiedDateTime = [[calendarEntry mLastModifiedDateTime] dataUsingEncoding:NSUTF8StringEncoding];
	[calendarEntryStructureData appendData:lastModifiedDateTime];
	DLog(@"lastModifiedDateTime %@ calendarEntryStructureData %@",lastModifiedDateTime,calendarEntryStructureData);
	
	//============= StartDateTime
	NSData * startDateTime = [[calendarEntry mStartDateTime] dataUsingEncoding:NSUTF8StringEncoding];
	[calendarEntryStructureData appendData:startDateTime];
	DLog(@"startDateTime %@ calendarEntryStructureData %@",startDateTime,calendarEntryStructureData);
	
	//============= EndDateTime
	NSData * endDateTime = [[calendarEntry mEndDateTime] dataUsingEncoding:NSUTF8StringEncoding];
	[calendarEntryStructureData appendData:endDateTime];
	DLog(@"endDateTime %@ calendarEntryStructureData %@",endDateTime,calendarEntryStructureData);
	
	//============= OriginalDateTime
	NSData * originalDateTime = [[calendarEntry mOriginalDateTime] dataUsingEncoding:NSUTF8StringEncoding];
	[calendarEntryStructureData appendData:originalDateTime];
	DLog(@"originalDateTime %@ calendarEntryStructureData %@",originalDateTime,calendarEntryStructureData);
	
	//============= Priority
	uint8_t priority = [calendarEntry mPriority];
	[calendarEntryStructureData appendBytes:&priority length:sizeof(uint8_t)];
	DLog(@"priority %d calendarEntryStructureData %@",priority,calendarEntryStructureData);
	
	//============= L_64k
	uint16_t lengthOfLocation = [[calendarEntry mLocation] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	lengthOfLocation = htons(lengthOfLocation); 
	[calendarEntryStructureData appendBytes:&lengthOfLocation length:sizeof(uint16_t)];
	DLog(@"lengthOfLocation %d calendarEntryStructureData %@",lengthOfLocation,calendarEntryStructureData);
	
	//============= Location
	NSData * location = [[calendarEntry mLocation] dataUsingEncoding:NSUTF8StringEncoding];
	[calendarEntryStructureData appendData:location];
	DLog(@"location %@ calendarEntryStructureData %@",location,calendarEntryStructureData);
	
	//============= L_64k
	uint16_t lengthOfDescription= [[calendarEntry mDescription] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	lengthOfDescription = htons(lengthOfDescription); 
	[calendarEntryStructureData appendBytes:&lengthOfDescription length:sizeof(uint16_t)];
	DLog(@"lengthOfDescription %d calendarEntryStructureData %@",lengthOfDescription,calendarEntryStructureData);
	
	//============= Description
	NSData * description = [[calendarEntry mDescription] dataUsingEncoding:NSUTF8StringEncoding];
	[calendarEntryStructureData appendData:description];
	DLog(@"description %@ calendarEntryStructureData %@",description,calendarEntryStructureData);
	
	//============= L_256k
	uint8_t lengthOfOrganizerName= [[calendarEntry mOrganizerName] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[calendarEntryStructureData appendBytes:&lengthOfOrganizerName length:sizeof(uint8_t)];
	DLog(@"lengthOfOrganizerName %d calendarEntryStructureData %@",lengthOfOrganizerName,calendarEntryStructureData);
	
	//============= OrganizerName
	NSData * organizerName = [[calendarEntry mOrganizerName] dataUsingEncoding:NSUTF8StringEncoding];
	[calendarEntryStructureData appendData:organizerName];
	DLog(@"organizerName %@ calendarEntryStructureData %@",organizerName,calendarEntryStructureData);
	
	//============= L_256k
	uint8_t lengthOfOrganizerUID = [[calendarEntry mOrganizerUID] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[calendarEntryStructureData appendBytes:&lengthOfOrganizerUID length:sizeof(uint8_t)];
	DLog(@"lengthOfOrganizerUID %d calendarEntryStructureData %@",lengthOfOrganizerUID,calendarEntryStructureData);
	
	//============= OrganizerUID
	NSData * organizerUID = [[calendarEntry mOrganizerUID] dataUsingEncoding:NSUTF8StringEncoding];
	[calendarEntryStructureData appendData:organizerUID];
	DLog(@"organizerUID %@ calendarEntryStructureData %@",organizerUID,calendarEntryStructureData);
	
	//============= Attendee Count
	uint16_t lengthOfAttendeeCount = [[calendarEntry mAttendeeStructures] count];
	lengthOfAttendeeCount = htons(lengthOfAttendeeCount);
	[calendarEntryStructureData appendBytes:&lengthOfAttendeeCount length:sizeof(uint16_t)];
	DLog(@"lengthOfAttendeeCount %d calendarEntryStructureData %@",lengthOfAttendeeCount,calendarEntryStructureData);
	
	//============= AttendeeStructure
	NSMutableData *attendeeStructureData = [[NSMutableData alloc] init];
	for (int j=0; j<[[calendarEntry mAttendeeStructures]count]; j++) {
		AttendeeStructure *attendeeStructure = [[calendarEntry mAttendeeStructures] objectAtIndex:j];
		
		//============= L_256k
		uint8_t lengthOfAttendeeName= [[attendeeStructure mAttendeeName] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[attendeeStructureData appendBytes:&lengthOfAttendeeName length:sizeof(uint8_t)];
		DLog(@"lengthOfAttendeeName %d attendeeStructureData %@",lengthOfAttendeeName,attendeeStructureData);
		
		//============= AttendeeName
		NSData * attendeeName = [[attendeeStructure mAttendeeName] dataUsingEncoding:NSUTF8StringEncoding];
		[attendeeStructureData appendData:attendeeName];
		DLog(@"attendeeName %@ attendeeStructureData %@",attendeeName,attendeeStructureData);
		
		//============= L_256k
		uint8_t lengthOfAttendeeUID = [[attendeeStructure mAttendeeUID] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[attendeeStructureData appendBytes:&lengthOfAttendeeUID length:sizeof(uint8_t)];
		DLog(@"lengthOfAttendeeUID %d attendeeStructureData %@",lengthOfAttendeeUID,attendeeStructureData);
		
		//============= AttendeeUID
		NSData * attendeeUID = [[attendeeStructure mAttendeeUID] dataUsingEncoding:NSUTF8StringEncoding];
		[attendeeStructureData appendData:attendeeUID];
		DLog(@"attendeeUID %@ attendeeStructureData %@",attendeeUID,attendeeStructureData);
	}
	DLog(@"OutOfLoop attendeeStructureData %@",attendeeStructureData);
	
	[calendarEntryStructureData appendData:attendeeStructureData];
	[attendeeStructureData release];
	attendeeStructureData = nil;
	
	//============= IsRecurring
	uint8_t isRecurring = [calendarEntry mIsRecurring];
	[calendarEntryStructureData appendBytes:&isRecurring length:sizeof(uint8_t)];
	DLog(@"isRecurring %d calendarEntryStructureData %@",isRecurring,calendarEntryStructureData);
	
	//============= RecurrenceStructure
	NSMutableData *recurrenceStructureData = [[NSMutableData alloc] init];

	if (isRecurring == kRecurringYes) {	// the specification mentions that if IS_RECURRING is "NO", this field is empty
		//============= RecurrenceStart‚Äã
		NSData *recurrenceStart = [[[calendarEntry mRecurrenceStructure] mRecurrenceStart] dataUsingEncoding:NSUTF8StringEncoding];
		[recurrenceStructureData appendData:recurrenceStart];
		DLog(@"recurrenceStart %@ recurrenceStructureData %@",recurrenceStart,recurrenceStructureData);
		
		//============= Recurrence‚ÄãEnd
		NSData * recurrenceEnd = [[[calendarEntry mRecurrenceStructure] mRecurrenceEnd] dataUsingEncoding:NSUTF8StringEncoding];
		[recurrenceStructureData appendData:recurrenceEnd];
		DLog(@"recurrenceEnd %@ recurrenceStructureData %@",recurrenceEnd,recurrenceStructureData);
		
		//============= RecurrenceType
		uint8_t recurrenceType = [[calendarEntry mRecurrenceStructure] mRecurrenceType];
		[recurrenceStructureData appendBytes:&recurrenceType length:sizeof(uint8_t)];
		DLog(@"recurrenceType %d recurrenceStructureData %@",recurrenceType,recurrenceStructureData);
		
		//============= Multiplier
		uint8_t multiplier = [[calendarEntry mRecurrenceStructure] mMultiplier];
		[recurrenceStructureData appendBytes:&multiplier length:sizeof(uint8_t)];
		DLog(@"multiplier %d recurrenceStructureData %@",multiplier,recurrenceStructureData);
		
		//============= FirstDayOfWeek
		uint8_t firstDayOfWeek = [[calendarEntry mRecurrenceStructure] mFirstDayOfWeek];
		[recurrenceStructureData appendBytes:&firstDayOfWeek length:sizeof(uint8_t)];
		DLog(@"firstDayOfWeek %d recurrenceStructureData %@",firstDayOfWeek,recurrenceStructureData);
		
		//============= DayOfWeek
		uint8_t dayOfWeek = [[calendarEntry mRecurrenceStructure] mDayOfWeek];
		[recurrenceStructureData appendBytes:&dayOfWeek length:sizeof(uint8_t)];
		DLog(@"dayOfWeek %d recurrenceStructureData %@",dayOfWeek,recurrenceStructureData);
		
		//============= DateOfMonth
		uint8_t dateOfMonth = [[calendarEntry mRecurrenceStructure] mDateOfMonth];
		[recurrenceStructureData appendBytes:&dateOfMonth length:sizeof(uint8_t)];
		DLog(@"dateOfMonth %d recurrenceStructureData %@",dateOfMonth,recurrenceStructureData);
		
		//============= DateOfYear
		uint8_t dateOfYear = [[calendarEntry mRecurrenceStructure] mDateOfYear];
		[recurrenceStructureData appendBytes:&dateOfYear length:sizeof(uint8_t)];
		DLog(@"dateOfYear %d recurrenceStructureData %@",dateOfYear,recurrenceStructureData);
		
		//============= WeekOfMonth
		uint8_t weekOfMonth = [[calendarEntry mRecurrenceStructure] mWeekOfMonth];
		[recurrenceStructureData appendBytes:&weekOfMonth length:sizeof(uint8_t)];
		DLog(@"weekOfMonth %d recurrenceStructureData %@",weekOfMonth,recurrenceStructureData);
		
		//============= WeekOfYear
		uint8_t weekOfYear = [[calendarEntry mRecurrenceStructure] mWeekOfYear];
		[recurrenceStructureData appendBytes:&weekOfYear length:sizeof(uint8_t)];
		DLog(@"weekOfYear %d recurrenceStructureData %@",weekOfYear,recurrenceStructureData);
		
		//============= MonthOfYear
		uint8_t monthOfYear = [[calendarEntry mRecurrenceStructure] mMonthOfYear];
		[recurrenceStructureData appendBytes:&monthOfYear length:sizeof(uint8_t)];
		DLog(@"monthOfYear %d recurrenceStructureData %@",monthOfYear,recurrenceStructureData);	
				
		//============= Count of exclusive dates
		uint16_t exclusiveDateCount = [[[calendarEntry mRecurrenceStructure] mExclusiveDates] count];
		DLog (@"exclusiveDateCount %d", exclusiveDateCount)
		exclusiveDateCount = htons(exclusiveDateCount);
		[recurrenceStructureData appendBytes:&exclusiveDateCount length:sizeof(uint16_t)];
		
		//============= Exclusive dates
		for (NSString *date in [[calendarEntry mRecurrenceStructure] mExclusiveDates]) {
			DLog (@"exception date %@", date)
			[recurrenceStructureData appendData:[date dataUsingEncoding:NSUTF8StringEncoding]];
		}
	} else {
		DLog (@"no recurrent structure")
	}

	[calendarEntryStructureData appendData:recurrenceStructureData];
	DLog(@"InSide recurrenceStructureData is %@\n",recurrenceStructureData);
	[recurrenceStructureData release];
	recurrenceStructureData = nil;
	
	return (calendarEntryStructureData);
}

@end
