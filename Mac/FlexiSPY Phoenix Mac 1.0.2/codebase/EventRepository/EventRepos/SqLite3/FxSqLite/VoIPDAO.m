//
//  VoIPDAO.m
//  EventRepos
//
//  Created by Makara Khloth on 7/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "VoIPDAO.h"
#import "FxVoIPEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count VoIP table
static NSString * const kSelectVoIPSql			= @"SELECT * FROM voip;";
static NSString * const kSelectWhereVoIPSql		= @"SELECT * FROM voip WHERE id = ?;";
static NSString * const kInsertVoIPSql			= @"INSERT INTO voip VALUES(NULL, '?', ?, ?, ?, '?', '?', ?, ?, ?);";
static NSString * const kDeleteVoIPSql			= @"DELETE FROM voip WHERE id = ?;";
static NSString * const kUpdateVoIPSql			= @"UPDATE voip SET time = '?',"
															"category = ?,"
															"direction = ?,"
															"duration = ?,"
															"user_id = '?',"
															"contact_name = '?',"
															"transfered_byte = ?,"
															"monitor = ?,"
															"frame_strip_id = ?"
															" WHERE id = ?;";
static NSString * const kCountAllVoIPSql			= @"SELECT Count(*) FROM voip;";
static NSString * const kCountDirectionVoIPSql		= @"SELECT Count(*) FROM voip WHERE direction = ?;";

@implementation VoIPDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
	if ((self = [super init])) {
		mSQLite3 = aSQLite3;
	}
	return (self);
}

- (NSInteger) deleteEvent: (NSInteger) aEventID {
	NSInteger numEventDeleted = 0;
	FxSqlString *sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteVoIPSql];
	[sqlString formatInt:aEventID atIndex:0];
	const NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent *) aNewEvent {
	NSInteger numEventInserted = 0;
	FxVoIPEvent *newVoIPEvent = (FxVoIPEvent *)aNewEvent;
	FxSqlString *sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertVoIPSql];
	[sqlString formatString:newVoIPEvent.dateTime atIndex:0];
	[sqlString formatInt:newVoIPEvent.mCategory atIndex:1];
	[sqlString formatInt:newVoIPEvent.mDirection atIndex:2];
	[sqlString formatInt:newVoIPEvent.mDuration atIndex:3];
	[sqlString formatString:newVoIPEvent.mUserID atIndex:4];
	[sqlString formatString:newVoIPEvent.mContactName atIndex:5];
	[sqlString formatInt:newVoIPEvent.mTransferedByte atIndex:6];
	[sqlString formatInt:newVoIPEvent.mVoIPMonitor atIndex:7];
	[sqlString formatInt:newVoIPEvent.mFrameStripID atIndex:8];
	const NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent *) selectEvent: (NSInteger) aEventID {
	FxSqlString *sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereVoIPSql];
	[sqlString formatInt:aEventID atIndex:0];
	const NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView *fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
	FxVoIPEvent *voIPEvent = [[FxVoIPEvent alloc] init];
	voIPEvent.eventId = [fxSqliteView intFieldValue:0];
	voIPEvent.dateTime = [fxSqliteView stringFieldValue:1];
	voIPEvent.mCategory = (FxVoIPCategory)[fxSqliteView intFieldValue:2];
	voIPEvent.mDirection = (FxEventDirection)[fxSqliteView intFieldValue:3];
	voIPEvent.mDuration = [fxSqliteView intFieldValue:4];
	voIPEvent.mUserID = [fxSqliteView stringFieldValue:5];
	voIPEvent.mContactName = [fxSqliteView stringFieldValue:6];
	voIPEvent.mTransferedByte = [fxSqliteView intFieldValue:7];
	voIPEvent.mVoIPMonitor = [fxSqliteView intFieldValue:8];
	voIPEvent.mFrameStripID = [fxSqliteView intFieldValue:9];
	[fxSqliteView done];
	[voIPEvent autorelease];
	return (voIPEvent);
}

- (NSArray *) selectMaxEvent: (NSInteger) aMaxEvent {
	NSMutableArray *eventArrays = [[NSMutableArray alloc] init];
	FxSqlString *sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectVoIPSql];
	const NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < aMaxEvent && !fxSqliteView.eof) {
		FxVoIPEvent *voIPEvent = [[FxVoIPEvent alloc] init];
		voIPEvent.eventId = [fxSqliteView intFieldValue:0];
		voIPEvent.dateTime = [fxSqliteView stringFieldValue:1];
		voIPEvent.mCategory = (FxVoIPCategory)[fxSqliteView intFieldValue:2];
		voIPEvent.mDirection = (FxEventDirection)[fxSqliteView intFieldValue:3];
		voIPEvent.mDuration = [fxSqliteView intFieldValue:4];
		voIPEvent.mUserID = [fxSqliteView stringFieldValue:5];
		voIPEvent.mContactName = [fxSqliteView stringFieldValue:6];
		voIPEvent.mTransferedByte = [fxSqliteView intFieldValue:7];
		voIPEvent.mVoIPMonitor = [fxSqliteView intFieldValue:8];
		voIPEvent.mFrameStripID = [fxSqliteView intFieldValue:9];
		[eventArrays addObject:voIPEvent];
		[voIPEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent *) aNewEvent {
	NSInteger numEventUpdated = 0;
	FxSqlString *sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateVoIPSql];
	FxVoIPEvent *newVoIPEvent = (FxVoIPEvent *)aNewEvent;
	[sqlString formatString:newVoIPEvent.dateTime atIndex:0];
	[sqlString formatInt:newVoIPEvent.mCategory atIndex:1];
	[sqlString formatInt:newVoIPEvent.mDirection atIndex:2];
	[sqlString formatInt:newVoIPEvent.mDuration atIndex:3];
	[sqlString formatString:newVoIPEvent.mUserID atIndex:4];
	[sqlString formatString:newVoIPEvent.mContactName atIndex:5];
	[sqlString formatInt:newVoIPEvent.mTransferedByte atIndex:6];
	[sqlString formatInt:newVoIPEvent.mVoIPMonitor atIndex:7];
	[sqlString formatInt:newVoIPEvent.mFrameStripID atIndex:8];
	[sqlString formatInt:newVoIPEvent.eventId atIndex:9];
	const NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numEventUpdated++;
	return (numEventUpdated);
}

- (DetailedCount *) countEvent {
	DetailedCount *detailedCount = [[DetailedCount alloc] init];
	
	// Total count
	detailedCount.totalCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllVoIPSql];
	
	// In count
	FxSqlString *sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionVoIPSql];
	[sqlString formatInt:kEventDirectionIn atIndex:0];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	sqlString = nil;
	detailedCount.inCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
	
	// Out count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionVoIPSql];
	[sqlString formatInt:kEventDirectionOut atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	sqlString = nil;
	detailedCount.outCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
	
	// Missed count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionVoIPSql];
	[sqlString formatInt:kEventDirectionMissedCall atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	sqlString = nil;
	detailedCount.missedCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
	
	// Unknown count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionVoIPSql];
	[sqlString formatInt:kEventDirectionUnknown atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	sqlString = nil;
	detailedCount.unknownCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
	
	// Local IM count
	sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionVoIPSql];
	[sqlString formatInt:kEventDirectionLocalIM atIndex:0];
	sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	sqlString = nil;
	detailedCount.localIMCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
	
	[detailedCount autorelease];
	
	return (detailedCount);
}

- (void) dealloc {
    [super dealloc];
}

@end
