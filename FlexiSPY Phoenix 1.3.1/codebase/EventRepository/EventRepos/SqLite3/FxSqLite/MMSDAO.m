//
//  MMSDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MMSDAO.h"
#import "FxMmsEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count mms table
static const NSString* kSelectMMSSql			= @"SELECT * FROM mms;";
static const NSString* kSelectWhereMMSSql		= @"SELECT * FROM mms WHERE id = ?;";
static const NSString* kInsertMMSSql			= @"INSERT INTO mms VALUES(NULL, '?', ?, '?', '?', '?', '?', '?');";
static const NSString* kDeleteMMSSql			= @"DELETE FROM mms WHERE id = ?;";
static const NSString* kUpdateMMSSql			= @"UPDATE mms SET time = '?',"
															"direction = ?,"
															"sender_number = '?',"
															"contact_name = '?',"
															"subject = '?',"
															"message = '?',"
															"conversation_id = '?'"
															" WHERE id = ?;";
static const NSString* kCountAllMMSSql			= @"SELECT Count(*) FROM mms;";
static const NSString* kCountDirectionMMSSql	= @"SELECT Count(*) FROM mms WHERE direction = ?;";

@implementation MMSDAO

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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteMMSSql];
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
	FxMmsEvent* newMmsEvent = (FxMmsEvent*)newEvent;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertMMSSql];
	[sqlString formatString:newMmsEvent.dateTime atIndex:0];
	[sqlString formatInt:newMmsEvent.direction atIndex:1];
	[sqlString formatString:newMmsEvent.senderNumber atIndex:2];
	[sqlString formatString:newMmsEvent.senderContactName atIndex:3];
	[sqlString formatString:newMmsEvent.subject atIndex:4];
	[sqlString formatString:newMmsEvent.message atIndex:5];
	[sqlString formatString:newMmsEvent.mConversationID atIndex:6];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID
{
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereMMSSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	FxMmsEvent* newMmsEvent = [[FxMmsEvent alloc] init];
	newMmsEvent.eventId = [fxSqliteView intFieldValue:0];
	newMmsEvent.dateTime = [fxSqliteView stringFieldValue:1];
	newMmsEvent.direction = (FxEventDirection)[fxSqliteView intFieldValue:2];
	newMmsEvent.senderNumber = [fxSqliteView stringFieldValue:3];
	newMmsEvent.senderContactName = [fxSqliteView stringFieldValue:4];
	newMmsEvent.subject = [fxSqliteView stringFieldValue:5];
	newMmsEvent.message = [fxSqliteView stringFieldValue:6];
	newMmsEvent.mConversationID = [fxSqliteView stringFieldValue:7];
	[fxSqliteView done];
	[newMmsEvent autorelease];
	return (newMmsEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent
{
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectMMSSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof)
	{
		FxMmsEvent* newMmsEvent = [[FxMmsEvent alloc] init];
		newMmsEvent.eventId = [fxSqliteView intFieldValue:0];
		newMmsEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newMmsEvent.direction = (FxEventDirection)[fxSqliteView intFieldValue:2];
		newMmsEvent.senderNumber = [fxSqliteView stringFieldValue:3];
		newMmsEvent.senderContactName = [fxSqliteView stringFieldValue:4];
		newMmsEvent.subject = [fxSqliteView stringFieldValue:5];
		newMmsEvent.message = [fxSqliteView stringFieldValue:6];
		newMmsEvent.mConversationID = [fxSqliteView stringFieldValue:7];
		[eventArrays addObject:newMmsEvent];
		[newMmsEvent release];
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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateMMSSql];
	FxMmsEvent* mmsEvent = (FxMmsEvent*)newEvent;
	[sqlString formatString:mmsEvent.dateTime atIndex:0];
	[sqlString formatInt:mmsEvent.direction atIndex:1];
	[sqlString formatString:mmsEvent.senderNumber atIndex:2];
	[sqlString formatString:mmsEvent.senderContactName atIndex:3];
	[sqlString formatString:mmsEvent.subject atIndex:4];
	[sqlString formatString:mmsEvent.message atIndex:5];
	[sqlString formatString:mmsEvent.mConversationID atIndex:6];
	[sqlString formatInt:mmsEvent.eventId atIndex:7];
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
	detailedCount.totalCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllMMSSql];
	
	// In count
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionMMSSql];
	[sqlString formatInt:kEventDirectionIn atIndex:0];
	NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.inCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Out count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionMMSSql];
	[sqlString formatInt:kEventDirectionOut atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.outCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Missed count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionMMSSql];
	[sqlString formatInt:kEventDirectionMissedCall atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.missedCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Unknown count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionMMSSql];
	[sqlString formatInt:kEventDirectionUnknown atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.unknownCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Local IM count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionMMSSql];
	[sqlString formatInt:kEventDirectionLocalIM atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.localIMCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	[detailedCount autorelease];
	return (detailedCount);
}

@end
