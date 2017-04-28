//
//  SystemDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SystemDAO.h"
#import "FxSystemEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count system table
static const NSString* kSelectSystemSql			= @"SELECT * FROM system;";
static const NSString* kSelectWhereSystemSql	= @"SELECT * FROM system WHERE id = ?;";
static const NSString* kInsertSystemSql			= @"INSERT INTO system VALUES(NULL, '?', ?, ?, '?');";
static const NSString* kDeleteSystemSql			= @"DELETE FROM system WHERE id = ?;";
static const NSString* kUpdateSystemSql			= @"UPDATE system SET time = '?',"
														"log_type = ?,"
														"direction = ?,"
														"message = '?'"
														" WHERE id = ?;";
static const NSString* kCountAllSystemSql		= @"SELECT Count(*) FROM system;";
static const NSString* kCountDirectionSystemSql	= @"SELECT Count(*) FROM system WHERE direction = ?;";

@implementation SystemDAO

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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteSystemSql];
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
	FxSystemEvent* newSystemEvent = (FxSystemEvent*)newEvent;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertSystemSql];
	[sqlString formatString:newSystemEvent.dateTime atIndex:0];
	[sqlString formatInt:newSystemEvent.systemEventType atIndex:1];
	[sqlString formatInt:newSystemEvent.direction atIndex:2];
	[sqlString formatString:newSystemEvent.message atIndex:3];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID
{
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereSystemSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	FxSystemEvent* newSystemEvent = [[FxSystemEvent alloc] init];
	newSystemEvent.eventId = [fxSqliteView intFieldValue:0];
	newSystemEvent.dateTime = [fxSqliteView stringFieldValue:1];
	newSystemEvent.systemEventType = (FxSystemEventType)[fxSqliteView intFieldValue:2];
	newSystemEvent.direction = (FxEventDirection)[fxSqliteView intFieldValue:3];
	newSystemEvent.message = [fxSqliteView stringFieldValue:4];
	[fxSqliteView done];
	[newSystemEvent autorelease];
	return (newSystemEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent
{
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectSystemSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof)
	{
		FxSystemEvent* newSystemEvent = [[FxSystemEvent alloc] init];
		newSystemEvent.eventId = [fxSqliteView intFieldValue:0];
		newSystemEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newSystemEvent.systemEventType = (FxSystemEventType)[fxSqliteView intFieldValue:2];
		newSystemEvent.direction = (FxEventDirection)[fxSqliteView intFieldValue:3];
		newSystemEvent.message = [fxSqliteView stringFieldValue:4];
		[eventArrays addObject:newSystemEvent];
		[newSystemEvent release];
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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateSystemSql];
	FxSystemEvent* systemEvent = (FxSystemEvent*)newEvent;
	[sqlString formatString:systemEvent.dateTime atIndex:0];
	[sqlString formatInt:systemEvent.systemEventType atIndex:1];
	[sqlString formatInt:systemEvent.direction atIndex:2];
	[sqlString formatString:systemEvent.message atIndex:3];
	[sqlString formatInt:systemEvent.eventId atIndex:4];
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
	detailedCount.totalCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllSystemSql];
	
	// In count
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionSystemSql];
	[sqlString formatInt:kEventDirectionIn atIndex:0];
	NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.inCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Out count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionSystemSql];
	[sqlString formatInt:kEventDirectionOut atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.outCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Missed count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionSystemSql];
	[sqlString formatInt:kEventDirectionMissedCall atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.missedCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Unknown count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionSystemSql];
	[sqlString formatInt:kEventDirectionUnknown atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.unknownCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Local IM count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionSystemSql];
	[sqlString formatInt:kEventDirectionLocalIM atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.localIMCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	[detailedCount autorelease];
	return (detailedCount);
}

@end
