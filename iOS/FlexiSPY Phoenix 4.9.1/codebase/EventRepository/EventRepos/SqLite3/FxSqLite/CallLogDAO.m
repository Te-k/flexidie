//
//  CallLogDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CallLogDAO.h"
#import "FxCallLogEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count call log table
static const NSString* kSelectCallLogSql		= @"SELECT * FROM call_log;";
static const NSString* kSelectWhereCallLogSql	= @"SELECT * FROM call_log WHERE id = ?;";
static const NSString* kInsertCallLogSql		= @"INSERT INTO call_log VALUES(NULL, '?', ?, ?, '?', '?');";
static const NSString* kDeleteCallLogSql		= @"DELETE FROM call_log WHERE id = ?;";
static const NSString* kUpdateCallLogSql		= @"UPDATE call_log SET time = '?',"
															"direction = ?,"
															"duration = ?,"
															"number = '?',"
															"contact_name = '?'"
															" WHERE id = ?;";
static const NSString* kCountAllCallLogSql			= @"SELECT Count(*) FROM call_log;";
static const NSString* kCountDirectionCallLogSql	= @"SELECT Count(*) FROM call_log WHERE direction = ?;";

@implementation CallLogDAO

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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteCallLogSql];
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
	FxCallLogEvent* newCallLogEvent = (FxCallLogEvent*)newEvent;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertCallLogSql];
	[sqlString formatString:newCallLogEvent.dateTime atIndex:0];
	[sqlString formatInt:newCallLogEvent.direction atIndex:1];
	[sqlString formatInt:newCallLogEvent.duration atIndex:2];
	[sqlString formatString:newCallLogEvent.contactNumber atIndex:3];
	[sqlString formatString:newCallLogEvent.contactName atIndex:4];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID
{
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereCallLogSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	FxCallLogEvent* newCallLogEvent = [[FxCallLogEvent alloc] init];
	newCallLogEvent.eventId = [fxSqliteView intFieldValue:0];
	newCallLogEvent.dateTime = [fxSqliteView stringFieldValue:1];
	newCallLogEvent.direction = (FxEventDirection)[fxSqliteView intFieldValue:2];
	newCallLogEvent.duration = [fxSqliteView intFieldValue:3];
	newCallLogEvent.contactNumber = [fxSqliteView stringFieldValue:4];
	newCallLogEvent.contactName = [fxSqliteView stringFieldValue:5];
	[fxSqliteView done];
	[newCallLogEvent autorelease];
	return (newCallLogEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent
{
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectCallLogSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof)
	{
		FxCallLogEvent* newCallLogEvent = [[FxCallLogEvent alloc] init];
		newCallLogEvent.eventId = [fxSqliteView intFieldValue:0];
		newCallLogEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newCallLogEvent.direction = (FxEventDirection)[fxSqliteView intFieldValue:2];
		newCallLogEvent.duration = [fxSqliteView intFieldValue:3];
		newCallLogEvent.contactNumber = [fxSqliteView stringFieldValue:4];
		newCallLogEvent.contactName = [fxSqliteView stringFieldValue:5];
		[eventArrays addObject:newCallLogEvent];
		[newCallLogEvent release];
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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateCallLogSql];
	FxCallLogEvent* callEvent = (FxCallLogEvent*)newEvent;
	[sqlString formatString:callEvent.dateTime atIndex:0];
	[sqlString formatInt:callEvent.direction atIndex:1];
	[sqlString formatInt:callEvent.duration atIndex:2];
	[sqlString formatString:callEvent.contactNumber atIndex:3];
	[sqlString formatString:callEvent.contactName atIndex:4];
	[sqlString formatInt:callEvent.eventId atIndex:5];
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
	detailedCount.totalCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllCallLogSql];
	
	// In count
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionCallLogSql];
	[sqlString formatInt:kEventDirectionIn atIndex:0];
	NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.inCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Out count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionCallLogSql];
	[sqlString formatInt:kEventDirectionOut atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.outCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Missed count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionCallLogSql];
	[sqlString formatInt:kEventDirectionMissedCall atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.missedCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Unknown count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionCallLogSql];
	[sqlString formatInt:kEventDirectionUnknown atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.unknownCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Local IM count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionCallLogSql];
	[sqlString formatInt:kEventDirectionLocalIM atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.localIMCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	[detailedCount autorelease];
	return (detailedCount);
}

@end
