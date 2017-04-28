//
//  SendCalendarPayloadBuilder.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SendCalendarPayloadBuilder.h"
#import "ProtocolParser.h"
#import "SendCalendar.h"
#import "Calendar2.h"

@implementation SendCalendarPayloadBuilder

+ (void) buildPayloadWithCommand:(SendCalendar *)aCommand
					withMetaData:(CommandMetaData *)aMetaData
			 withPayloadFilePath:(NSString *)aPayloadFilePath
				   withDirective:(TransportDirective)aDirective {
	if (!aCommand) {
		return;
	}
	// Command code
	uint16_t cmdCode = [aCommand getCommand];
	cmdCode = htons(cmdCode);
	
	// Number of calendar	(Array of Calendar2)
	uint16_t calCount = [[aCommand mCalendars] count];
	calCount = htons(calCount);
	
	NSError *error = nil;
	
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	
	if ([fileMgr fileExistsAtPath:aPayloadFilePath]) {
		[fileMgr removeItemAtPath:aPayloadFilePath error:&error];
	}
	
	[fileMgr createFileAtPath:aPayloadFilePath contents:nil attributes:nil];
	
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:aPayloadFilePath];
	
	[fileHandle writeData:[NSData dataWithBytes:&cmdCode length:sizeof(uint16_t)]];
	[fileHandle writeData:[NSData dataWithBytes:&calCount length:sizeof(uint16_t)]];
	
	// traverse array of Calendar2 which is always one loop
	for (Calendar2 *calendar in [aCommand mCalendars]) {
		NSMutableData *calendarSummaryData = [[NSMutableData alloc] init];
		
		//============= L_256
		uint8_t lengthOfCalendarId = [[calendar mCalendarId] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[calendarSummaryData appendBytes:&lengthOfCalendarId length:sizeof(uint8_t)];

		//============= CalendarId
		//uint32_t calendarId  = [calendar mCalendarId];
		//calendarId = htonl(calendarId);
		//[calendarSummaryData appendBytes:&calendarId length:sizeof(uint32_t)];

		NSData * calendarId = [[calendar mCalendarId] dataUsingEncoding:NSUTF8StringEncoding];
		DLog (@"[calendar mCalendarId] %@", [calendar mCalendarId])
		[calendarSummaryData appendData:calendarId];
		
		//============= L_256
		uint8_t lengthOfCalendarName = [[calendar mCalendarName] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[calendarSummaryData appendBytes:&lengthOfCalendarName length:sizeof(uint8_t)];
		
		//============= mCalendarName
		DLog (@"[calendar mCalendarName] %@", [calendar mCalendarName])
		NSData * calendarName = [[calendar mCalendarName] dataUsingEncoding:NSUTF8StringEncoding];
		[calendarSummaryData appendData:calendarName];
		
		//============= mCalendarEntriesCount
		//DLog (@"[[calendar mCalendarEntries] count] %d", [[calendar mCalendarEntries] count])
		//uint16_t lengthOfmCalendarEntriesCount = [[calendar mCalendarEntries] count];
		DLog (@"[[calendar mCalendarEntries] count] %d", [calendar mEntryCount])
		uint16_t lengthOfmCalendarEntriesCount = [calendar mEntryCount] ;
		
		lengthOfmCalendarEntriesCount = htons(lengthOfmCalendarEntriesCount); 
		DLog (@"Entry count length %d", lengthOfmCalendarEntriesCount)
		[calendarSummaryData appendBytes:&lengthOfmCalendarEntriesCount length:sizeof(uint16_t)];
		
		[fileHandle writeData:calendarSummaryData];
		
		[calendarSummaryData release];
		calendarSummaryData = nil;
		
		id <DataProvider> entryDataProvider = [calendar mEntryDataProvider];	// CalendarEntryProvider
		while ([entryDataProvider hasNext]) {
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			CalendarEntry *entry = [entryDataProvider getObject];
			NSData *calendarEntryStructureData = [ProtocolParser parseCalendarEntry:entry];
			[fileHandle writeData:calendarEntryStructureData];
			[pool release];
		}
	}
}

@end
