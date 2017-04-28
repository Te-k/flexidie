//
//  EventKeysDAO.m
//  EDM
//
//  Created by Makara Khloth on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventKeysDAO.h"
#import "EventKeys.h"
#import "FMDatabase.h"
#import "FxException.h"

// Table schema: | edp_type | event_id | event_type |
static NSString* kDeleteEventKeysSql	= @"DELETE FROM edmeventkeys WHERE edp_type = ?";
static NSString* kInsertEventKeysSql	= @"INSERT INTO edmeventkeys VALUES(?, ?, ?)";
static NSString* kSelectEventKeysSql	= @"SELECT * FROM edmeventkeys WHERE edp_type = ?";

@implementation EventKeysDAO

@synthesize mDatabase;

- (id) initWithDatabase: (FMDatabase*) aDatabase {
	if ((self = [super init])) {
		mDatabase = aDatabase;
		[mDatabase retain];
	}
	return (self);
}

- (void) insertEventKeys: (EventKeys*) aEventKey withEDPType: (NSInteger) aEDPType {
	NSNumber* edpType = [NSNumber numberWithInt:aEDPType];
	NSInteger i = kEventTypeUnknown;
	for (i; i < kEventTypeMaxEventType; i++) {
		NSNumber* eventType = [NSNumber numberWithInt:i];
		for (NSNumber* eventId in [aEventKey eventIdArray:(FxEventType)i]) {
			BOOL success = [[self mDatabase] executeUpdate:kInsertEventKeysSql, edpType,
							eventId,
							eventType];
			if (!success) {
				FxException* exception = [FxException exceptionWithName:@"insertEventKeys" andReason:[mDatabase lastErrorMessage]];
				[exception setErrorCode:[[self mDatabase] lastErrorCode]];
				[exception setErrorCategory:kFxErrorEDMDatabase];
				@throw exception;
			}
		}
	}
}

- (EventKeys*) selectEventKeys: (NSInteger) aEDPType {
	DLog (@"Select event where EDPType = %d", aEDPType);
	EventKeys* eventKeys = [[EventKeys alloc] init];
	NSMutableDictionary* eventTypeIdArrayDic = [[NSMutableDictionary alloc] init];
	NSInteger eventType;
	for (eventType = kEventTypeUnknown; eventType < kEventTypeMaxEventType; eventType++) {
		NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
		[eventTypeIdArrayDic setObject:eventIdArray forKey:[NSNumber numberWithInt:eventType]];
		[eventIdArray release];
	}
	FMResultSet* resultSet = [[self mDatabase] executeQuery:kSelectEventKeysSql, [NSNumber numberWithInt:aEDPType]];
	while ([resultSet next]) {
		NSNumber* dbEventId = [NSNumber numberWithInt:[resultSet intForColumnIndex:1]];
		NSNumber* dbEventType = [NSNumber numberWithInt:[resultSet intForColumnIndex:2]];
		NSMutableArray* eventIdArray = [eventTypeIdArrayDic objectForKey:dbEventType];
		[eventIdArray addObject:dbEventId];
		DLog (@"dbEventId = %@, dbEventType = %@", dbEventId, dbEventType);
	}
	for (eventType = kEventTypeUnknown; eventType < kEventTypeMaxEventType; eventType++) {
		NSArray* eventIdArray = [eventTypeIdArrayDic objectForKey:[NSNumber numberWithInt:eventType]];
		if ([eventIdArray count]) {
			[eventKeys put:(FxEventType)eventType withEventIdArray:eventIdArray];
		}
	}
	[eventTypeIdArrayDic release];
	[eventKeys autorelease];
	return (eventKeys);
}
	
- (void) deleteEventKeys: (NSInteger) aEDPType {
	NSNumber* edpType = [NSNumber numberWithInt:aEDPType];
	BOOL success = [[self mDatabase] executeUpdate:kDeleteEventKeysSql, edpType];
	if (!success) {
		FxException* exception = [FxException exceptionWithName:@"deleteEventKeys" andReason:[mDatabase lastErrorMessage]];
		[exception setErrorCode:[[self mDatabase] lastErrorCode]];
		[exception setErrorCategory:kFxErrorEDMDatabase];
		@throw exception;
	}
}

- (void) dealloc {
	[mDatabase release];
	[super dealloc];
}

@end
