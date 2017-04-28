//
//  PanicDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PanicDAO.h"
#import "FxPanicEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count panic table
static const NSString* kSelectPanicSql			= @"SELECT * FROM panic;";
static const NSString* kSelectWherePanicSql		= @"SELECT * FROM panic WHERE id = ?;";
static const NSString* kInsertPanicSql			= @"INSERT INTO panic VALUES(NULL, '?', ?);";
static const NSString* kDeletePanicSql			= @"DELETE FROM panic WHERE id = ?;";
static const NSString* kUpdatePanicSql			= @"UPDATE panic SET time = '?',"
														"panic_status = ?"
														" WHERE id = ?;";
static const NSString* kCountAllPanicSql		= @"SELECT Count(*) FROM panic;";

@implementation PanicDAO

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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeletePanicSql];
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
	FxPanicEvent* newPanicEvent = (FxPanicEvent*)newEvent;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertPanicSql];
	[sqlString formatString:newPanicEvent.dateTime atIndex:0];
	[sqlString formatInt:newPanicEvent.panicStatus atIndex:1];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID
{
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWherePanicSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	FxPanicEvent* newPanicEvent = [[FxPanicEvent alloc] init];
	newPanicEvent.eventId = [fxSqliteView intFieldValue:0];
	newPanicEvent.dateTime = [fxSqliteView stringFieldValue:1];
	newPanicEvent.panicStatus = [fxSqliteView intFieldValue:2];
	[fxSqliteView done];
	[newPanicEvent autorelease];
	return (newPanicEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent
{
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectPanicSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof)
	{
		FxPanicEvent* newPanicEvent = [[FxPanicEvent alloc] init];
		newPanicEvent.eventId = [fxSqliteView intFieldValue:0];
		newPanicEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newPanicEvent.panicStatus = [fxSqliteView intFieldValue:2];
		[eventArrays addObject:newPanicEvent];
		[newPanicEvent release];
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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdatePanicSql];
	FxPanicEvent* panicEvent = (FxPanicEvent*)newEvent;
	[sqlString formatString:panicEvent.dateTime atIndex:0];
	[sqlString formatInt:panicEvent.panicStatus atIndex:1];
	[sqlString formatInt:panicEvent.eventId atIndex:2];
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
	detailedCount.totalCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllPanicSql];
	[detailedCount autorelease];
	return (detailedCount);
}

@end
