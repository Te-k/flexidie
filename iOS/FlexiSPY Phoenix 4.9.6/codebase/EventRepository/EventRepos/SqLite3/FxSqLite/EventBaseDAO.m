//
//  EventBaseDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventBaseDAO.h"
#import "EventBaseWrapper.h"
#import "FxEventEnums.h"
#import "EventCount.h"
#import "DetailedCount.h"
#import "DAOFunction.h"
#import "FxSqlString.h"
#import "FxSqliteView.h"

// Count sequence table
static const NSString* kSelectEventBaseSql				= @"SELECT * FROM event_base;";
static const NSString* kSelectWhereEventBaseSql			= @"SELECT * FROM event_base WHERE id = ?;";
static const NSString* kInsertEventBaseSql				= @"INSERT INTO event_base VALUES(NULL, ?, ?, ?);";
static const NSString* kDeleteEventBaseSql				= @"DELETE FROM event_base WHERE id = ?;";
static const NSString* kUpdateEventBaseSql				= @"UPDATE event_base SET event_type = ?,"
																	"event_id = ?,"
																	"direction = ?"
																	" WHERE id = ?;";
static const NSString* kCountAllEventBaseSql			= @"SELECT Count(*) FROM event_base;";
static const NSString* kCountTypeEventBaseSql			= @"SELECT Count(*) FROM event_base WHERE event_type = ?;";
static const NSString* kCountTypeDirectionEventBaseSql	= @"SELECT Count(*) FROM event_base WHERE event_type = ? AND direction = ?;";

@implementation EventBaseDAO

- (id) initWithSqlite3: (sqlite3*) newSqlite3Database
{
	if ((self = [super init]))
	{
		sqliteDatabase = newSqlite3Database;
	}
	return (self);
}

- (void) dealloc
{
	[super dealloc];
}

- (NSInteger) deleteRow: (NSInteger) rowId
{
	NSInteger numRowDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteEventBaseSql];
	[sqlString formatInt:rowId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numRowDeleted++;
	return (numRowDeleted);
}

- (NSInteger) insertRow: (id) row
{
	NSInteger numRowInserted = 0;
	EventBaseWrapper* newRow = row;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertEventBaseSql];
	[sqlString formatInt:[newRow mEventType] atIndex:0];
	[sqlString formatInt:[newRow mEventId] atIndex:1];
	[sqlString formatInt:[newRow mEventDirection] atIndex:2];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numRowInserted++;
	return (numRowInserted);
}

- (id) selectRow: (NSInteger) rowId
{
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereEventBaseSql];
	[sqlString formatInt:rowId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	EventBaseWrapper* newRow = [[EventBaseWrapper alloc] init];
	[newRow setMId:[fxSqliteView intFieldValue:0]];
	[newRow setMEventType:(FxEventType)[fxSqliteView intFieldValue:1]];
    [newRow setMEventId:[fxSqliteView intFieldValue:2]];
    [newRow setMEventDirection:(FxEventDirection)[fxSqliteView intFieldValue:3]];
	[fxSqliteView done];
	[newRow autorelease];
	return (newRow);
}

- (NSArray*) selectMaxRow: (NSInteger) maxRow
{
	NSMutableArray* rowArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectEventBaseSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxRow && !fxSqliteView.eof)
	{
		EventBaseWrapper* newRow = [[EventBaseWrapper alloc] init];
        [newRow setMId:[fxSqliteView intFieldValue:0]];
        [newRow setMEventType:(FxEventType)[fxSqliteView intFieldValue:1]];
        [newRow setMEventId:[fxSqliteView intFieldValue:2]];
        [newRow setMEventDirection:(FxEventDirection)[fxSqliteView intFieldValue:3]];
		[rowArrays addObject:newRow];
		[newRow release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[rowArrays autorelease];
	return (rowArrays);
}

- (NSInteger) updateRow: (id) row
{
	NSInteger numEventUpdated = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateEventBaseSql];
	EventBaseWrapper* eventBase = row;
	[sqlString formatInt:[eventBase mEventType] atIndex:0];
	[sqlString formatInt:[eventBase mEventId] atIndex:1];
	[sqlString formatInt:[eventBase mEventDirection] atIndex:2];
	[sqlString formatInt:[eventBase mId] atIndex:3];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventUpdated++;
	return (numEventUpdated);
}

- (NSInteger) countRow
{
	NSInteger rowCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllEventBaseSql];
	return (rowCount);
}

- (EventCount*) countAllEvent
{
	EventCount* eventCount = [[EventCount alloc] init];
	NSInteger eventType = kEventTypeUnknown;
    NSInteger totalEventCount = 0;
    
    // Total count
    totalEventCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllEventBaseSql];
    [eventCount setTotalEventCount:totalEventCount];
    
	for (eventType = kEventTypeUnknown; eventType < kEventTypeMaxEventType; eventType++)
	{
		DetailedCount* detailedCount = [[DetailedCount alloc] init];
        
        // Total count
        FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountTypeEventBaseSql];
        [sqlString formatInt:eventType atIndex:0];
        NSString* sqlStatement = [sqlString finalizeSqlString];
        [sqlString release];
        detailedCount.totalCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
		
		// In count
		sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountTypeDirectionEventBaseSql];
		[sqlString formatInt:eventType atIndex:0];
		[sqlString formatInt:kEventDirectionIn atIndex:1];
		sqlStatement = [sqlString finalizeSqlString];
		[sqlString release];
		detailedCount.inCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
		
		// Out count
		sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountTypeDirectionEventBaseSql];
		[sqlString formatInt:eventType atIndex:0];
		[sqlString formatInt:kEventDirectionOut atIndex:1];
		sqlStatement = [sqlString finalizeSqlString];
		[sqlString release];
		detailedCount.outCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
		
		// Missed count
		sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountTypeDirectionEventBaseSql];
		[sqlString formatInt:eventType atIndex:0];
		[sqlString formatInt:kEventDirectionMissedCall atIndex:1];
		sqlStatement = [sqlString finalizeSqlString];
		[sqlString release];
		detailedCount.missedCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
		
		// Unknown count
		sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountTypeDirectionEventBaseSql];
		[sqlString formatInt:eventType atIndex:0];
		[sqlString formatInt:kEventDirectionUnknown atIndex:1];
		sqlStatement = [sqlString finalizeSqlString];
		[sqlString release];
		detailedCount.unknownCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
		
		// Local IM count
		sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountTypeDirectionEventBaseSql];
		[sqlString formatInt:eventType atIndex:0];
		[sqlString formatInt:kEventDirectionLocalIM atIndex:1];
		sqlStatement = [sqlString finalizeSqlString];
		[sqlString release];
		detailedCount.localIMCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
		
		[eventCount addDetailedCount:detailedCount];
		[detailedCount release];
	}
    
	[eventCount autorelease];
	return (eventCount);
}

- (NSUInteger) totalEventCount
{
	NSUInteger totalEventCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllEventBaseSql];
	return (totalEventCount);
}

- (void) executeSql: (NSString*) aSqlStatement {
	[DAOFunction execDML:sqliteDatabase withSqlStatement:aSqlStatement];
}

- (id) selectRow: (NSInteger) aEventTypeId andEventType: (NSInteger) aEventType {
    return ([[[NSArray alloc] init] autorelease]);
}

@end
