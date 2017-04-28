//
//  IMDAO.m
//  EventRepos
//
//  Created by Makara Khloth on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "IMDAO.h"
#import "FxIMEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count im table
static const NSString* kSelectIMSql				= @"SELECT * FROM im;";
static const NSString* kSelectWhereIMSql		= @"SELECT * FROM im WHERE id = ?;";
static const NSString* kInsertIMSql				= @"INSERT INTO im VALUES(NULL, '?', ?, '?', '?', '?', '?');";
static const NSString* kDeleteIMSql				= @"DELETE FROM im WHERE id = ?;";
static const NSString* kUpdateIMSql				= @"UPDATE im SET time = '?',"
														"direction = ?,"
														"user_id = '?',"
														"im_service_id = '?',"
														"message = '?',"
														"user_display_name = '?'"
														" WHERE id = ?;";
static const NSString* kCountAllIMSql			= @"SELECT Count(*) FROM im;";
static const NSString* kCountDirectionIMSql		= @"SELECT Count(*) FROM im WHERE direction = ?;";

@implementation IMDAO

- (id) initWithSqlite3: (sqlite3*) newSqlite3Database {
	if (self = [super init]) {
		sqliteDatabase = newSqlite3Database;
	}
	return (self);
}

- (void) dealloc {
	[super dealloc];
}

- (NSInteger) deleteEvent: (NSInteger) eventID {
	NSInteger numEventDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteIMSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent {
	NSInteger numEventInserted = 0;
	FxIMEvent* newIMEvent = (FxIMEvent*)newEvent;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertIMSql];
	[sqlString formatString:newIMEvent.dateTime atIndex:0];
	[sqlString formatInt:newIMEvent.mDirection atIndex:1];
	[sqlString formatString:newIMEvent.mUserID atIndex:2];
	[sqlString formatString:newIMEvent.mIMServiceID atIndex:3];
	[sqlString formatString:newIMEvent.mMessage atIndex:4];
	[sqlString formatString:newIMEvent.mUserDisplayName atIndex:5];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID {
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereIMSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	FxIMEvent* newIMEvent = [[FxIMEvent alloc] init];
	newIMEvent.eventId = [fxSqliteView intFieldValue:0];
	newIMEvent.dateTime = [fxSqliteView stringFieldValue:1];
	newIMEvent.mDirection = (FxEventDirection)[fxSqliteView intFieldValue:2];
	newIMEvent.mUserID = [fxSqliteView stringFieldValue:3];
	newIMEvent.mIMServiceID = [fxSqliteView stringFieldValue:4];
	newIMEvent.mMessage = [fxSqliteView stringFieldValue:5];
	newIMEvent.mUserDisplayName = [fxSqliteView stringFieldValue:6];
	[fxSqliteView done];
	[newIMEvent autorelease];
	return (newIMEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent {
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof) {
		FxIMEvent* newIMEvent = [[FxIMEvent alloc] init];
		newIMEvent.eventId = [fxSqliteView intFieldValue:0];
		newIMEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newIMEvent.mDirection = (FxEventDirection)[fxSqliteView intFieldValue:2];
		newIMEvent.mUserID = [fxSqliteView stringFieldValue:3];
		newIMEvent.mIMServiceID = [fxSqliteView stringFieldValue:4];
		newIMEvent.mMessage = [fxSqliteView stringFieldValue:5];
		newIMEvent.mUserDisplayName = [fxSqliteView stringFieldValue:6];
		[eventArrays addObject:newIMEvent];
		[newIMEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent {
	NSInteger numEventUpdated = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateIMSql];
	FxIMEvent* newIMEvent = (FxIMEvent*)newEvent;
	[sqlString formatString:newIMEvent.dateTime atIndex:0];
	[sqlString formatInt:newIMEvent.mDirection atIndex:1];
	[sqlString formatString:newIMEvent.mUserID atIndex:2];
	[sqlString formatString:newIMEvent.mIMServiceID atIndex:3];
	[sqlString formatString:newIMEvent.mMessage atIndex:4];
	[sqlString formatString:newIMEvent.mUserDisplayName atIndex:5];
	[sqlString formatInt:newIMEvent.eventId atIndex:6];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventUpdated++;
	return (numEventUpdated);
}

- (DetailedCount*) countEvent {
	DetailedCount* detailedCount = [[DetailedCount alloc] init];
	
	// Total count
	detailedCount.totalCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllIMSql];
	
	// In count
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionIMSql];
	[sqlString formatInt:kEventDirectionIn atIndex:0];
	NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.inCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Out count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionIMSql];
	[sqlString formatInt:kEventDirectionOut atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.outCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Missed count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionIMSql];
	[sqlString formatInt:kEventDirectionMissedCall atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.missedCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Unknown count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionIMSql];
	[sqlString formatInt:kEventDirectionUnknown atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.unknownCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	// Local IM count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionIMSql];
	[sqlString formatInt:kEventDirectionLocalIM atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	detailedCount.localIMCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:sqlStatement];
	
	[detailedCount autorelease];
	return (detailedCount);
}

@end
