//
//  SMSDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SMSDAO.h"
#import "FxSmsEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count sms table
static const NSString* kSelectSMSSql			= @"SELECT * FROM sms;";
static const NSString* kSelectWhereSMSSql		= @"SELECT * FROM sms WHERE id = ?;";
static const NSString* kInsertSMSSql			= @"INSERT INTO sms VALUES(NULL, '?', ?, '?', '?', '?', '?', '?');";
static const NSString* kDeleteSMSSql			= @"DELETE FROM sms WHERE id = ?;";
static const NSString* kUpdateSMSSql			= @"UPDATE sms SET time = '?',"
														"direction = ?,"
														"sender_number = '?',"
														"contact_name = '?',"
														"subject = '?',"
														"message = '?',"
														"conversation_id = '?'"
														" WHERE id = ?;";
static const NSString* kCountAllSMSSql			= @"SELECT Count(*) FROM sms;";
static const NSString* kCountDirectionSMSSql	= @"SELECT Count(*) FROM sms WHERE direction = ?;";

@implementation SMSDAO

- (id) initWithSqlite3: (sqlite3*) newSqlite3Database
{
	if (self = [super init])
	{
		sqliteDatabase = newSqlite3Database;
	}
	return (self);
}

- (void) dealloc
{
	[super dealloc];
}

- (NSInteger) deleteEvent: (NSInteger) eventID
{
	NSInteger numEventDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteSMSSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent
{
	NSInteger numEventInserted = 0;
	FxSmsEvent* newSmsEvent = (FxSmsEvent*)newEvent;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertSMSSql];
	[sqlString formatString:newSmsEvent.dateTime atIndex:0];
	[sqlString formatInt:newSmsEvent.direction atIndex:1];
	[sqlString formatString:newSmsEvent.senderNumber atIndex:2];
	[sqlString formatString:newSmsEvent.contactName atIndex:3];
	[sqlString formatString:newSmsEvent.smsSubject atIndex:4];
	[sqlString formatString:newSmsEvent.smsData atIndex:5];
	[sqlString formatString:newSmsEvent.mConversationID atIndex:6];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID
{
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereSMSSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	FxSmsEvent* newSmsEvent = [[FxSmsEvent alloc] init];
	newSmsEvent.eventId = [fxSqliteView intFieldValue:0];
	newSmsEvent.dateTime = [fxSqliteView stringFieldValue:1];
	newSmsEvent.direction = (FxEventDirection)[fxSqliteView intFieldValue:2];
	newSmsEvent.senderNumber = [fxSqliteView stringFieldValue:3];
	newSmsEvent.contactName = [fxSqliteView stringFieldValue:4];
	newSmsEvent.smsSubject = [fxSqliteView stringFieldValue:5];
	newSmsEvent.smsData = [fxSqliteView stringFieldValue:6];
	newSmsEvent.mConversationID = [fxSqliteView stringFieldValue:7];
	[fxSqliteView done];
	[newSmsEvent autorelease];
	return (newSmsEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent
{
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectSMSSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof)
	{
		FxSmsEvent* newSmsEvent = [[FxSmsEvent alloc] init];
		newSmsEvent.eventId = [fxSqliteView intFieldValue:0];
		newSmsEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newSmsEvent.direction = (FxEventDirection)[fxSqliteView intFieldValue:2];
		newSmsEvent.senderNumber = [fxSqliteView stringFieldValue:3];
		newSmsEvent.contactName = [fxSqliteView stringFieldValue:4];
		newSmsEvent.smsSubject = [fxSqliteView stringFieldValue:5];
		newSmsEvent.smsData = [fxSqliteView stringFieldValue:6];
		newSmsEvent.mConversationID = [fxSqliteView stringFieldValue:7];
		[eventArrays addObject:newSmsEvent];
		[newSmsEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent
{
	NSInteger numEventUpdated = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateSMSSql];
	FxSmsEvent* smsEvent = (FxSmsEvent*)newEvent;
	[sqlString formatString:smsEvent.dateTime atIndex:0];
	[sqlString formatInt:smsEvent.direction atIndex:1];
	[sqlString formatString:smsEvent.senderNumber atIndex:2];
	[sqlString formatString:smsEvent.contactName atIndex:3];
	[sqlString formatString:smsEvent.smsSubject atIndex:4];
	[sqlString formatString:smsEvent.smsData atIndex:5];
	[sqlString formatString:smsEvent.mConversationID atIndex:6];
	[sqlString formatInt:smsEvent.eventId atIndex:7];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventUpdated++;
	return (numEventUpdated);
}

- (DetailedCount*) countEvent
{
	DetailedCount* detailedCount = [[DetailedCount alloc] init];
	
	// Total count
	detailedCount.totalCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllSMSSql];
	
	// In count
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionSMSSql];
	[sqlString formatInt:kEventDirectionIn atIndex:0];
	NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.inCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Out count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionSMSSql];
	[sqlString formatInt:kEventDirectionOut atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.outCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Missed count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionSMSSql];
	[sqlString formatInt:kEventDirectionMissedCall atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.missedCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Unknown count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionSMSSql];
	[sqlString formatInt:kEventDirectionUnknown atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.unknownCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Local IM count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionSMSSql];
	[sqlString formatInt:kEventDirectionLocalIM atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.localIMCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	[detailedCount autorelease];
	return (detailedCount);
}

@end
