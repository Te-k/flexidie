//
//  PageVisitedDAO.m
//  EventRepos
//
//  Created by Benjawan Tanarattanakorn on 9/3/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PageVisitedDAO.h"
#import "FxPageVisitedEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

/*
 @"CREATE TABLE IF NOT EXISTS page_visited (id INTEGER PRIMARY KEY AUTOINCREMENT,"
 "time TEXT NOT NULL,"
 "user_name TEXT,"
 "application_id TEXT,"
 "application_name TEXT,"
 "window_title TEXT,"
 "url TEXT,"
 "actual_display_data TEXT,"
 "raw_data TEXT,"
 "screen_shot_path TEXT,"
 "browsing_start_time TEXT,"
 "browsing_end_time TEXT,"
 "browsing_duration INTEGER);";
*/

// Select/Insert/Delete/Update/Count PageVisited table
static NSString * const kSelectPageVisitedSql		= @"SELECT * FROM page_visited;";
static NSString * const kSelectWherePageVisitedSql	= @"SELECT * FROM page_visited WHERE id = ?;";
static NSString * const kInsertPageVisitedSql		= @"INSERT INTO page_visited VALUES(NULL, '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', ?);";
static NSString * const kDeletePageVisitedSql		= @"DELETE FROM page_visited WHERE id = ?;";
static NSString * const kUpdatePageVisitedSql		= @"UPDATE page_visited SET time = '?',"
																	"user_name = '?',"
																	"application_id = '?',"
                                                                    "application_name = '?',"
																	"window_title = '?',"
                                                                    "url = '?',"
																	"actual_display_data = '?',"
																	"raw_data = '?',"
                                                                    "screen_shot_path = '?',"
                                                                    "browsing_start_time = '?',"
                                                                    "browsing_end_time = '?',"
                                                                    "browsing_duration = ?"
																	" WHERE id = ?;";
static NSString * const kCountAllPageVisitedSql		= @"SELECT Count(*) FROM page_visited;";


@implementation PageVisitedDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
	if ((self = [super init])) {
		mSQLite3 = aSQLite3;
	}
	return (self);
}

- (NSInteger) deleteEvent: (NSInteger) aEventID {
	NSInteger numEventDeleted		= 0;
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kDeletePageVisitedSql];
	[sqlString formatInt:aEventID atIndex:0];
	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent *) aNewEvent {
	NSInteger numEventInserted		= 0;
	FxPageVisitedEvent *newPageVisitedEvent	= (FxPageVisitedEvent *)aNewEvent;
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kInsertPageVisitedSql];
	
	[sqlString formatString:newPageVisitedEvent.dateTime atIndex:0];
	[sqlString formatString:newPageVisitedEvent.mUserName atIndex:1];
	[sqlString formatString:newPageVisitedEvent.mApplicationID atIndex:2];
    [sqlString formatString:newPageVisitedEvent.mApplication atIndex:3];
	[sqlString formatString:newPageVisitedEvent.mTitle atIndex:4];
    [sqlString formatString:newPageVisitedEvent.mUrl atIndex:5];
    [sqlString formatString:newPageVisitedEvent.mActualDisplayData atIndex:6];
	[sqlString formatString:newPageVisitedEvent.mRawData atIndex:7];
    [sqlString formatString:newPageVisitedEvent.mBrowserScreenshotPath atIndex:8];
    [sqlString formatString:newPageVisitedEvent.mBrowsingStartTime atIndex:9];
    [sqlString formatString:newPageVisitedEvent.mBrowsingEndTime atIndex:10];
    [sqlString formatInt:newPageVisitedEvent.mBrowsingDuration atIndex:11];

	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent *) selectEvent: (NSInteger) aEventID {
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kSelectWherePageVisitedSql];
	[sqlString formatInt:aEventID atIndex:0];
	
	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	
	FxSqliteView *fxSqliteView		= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
	
	FxPageVisitedEvent *pageVisitedEvent    = [[FxPageVisitedEvent alloc] init];
	pageVisitedEvent.eventId				= [fxSqliteView intFieldValue:0];
	pageVisitedEvent.dateTime               = [fxSqliteView stringFieldValue:1];
	pageVisitedEvent.mUserName              = [fxSqliteView stringFieldValue:2];
	pageVisitedEvent.mApplicationID         = [fxSqliteView stringFieldValue:3];
    pageVisitedEvent.mApplication           = [fxSqliteView stringFieldValue:4];
	pageVisitedEvent.mTitle                 = [fxSqliteView stringFieldValue:5];
    pageVisitedEvent.mUrl                   = [fxSqliteView stringFieldValue:6];
    pageVisitedEvent.mActualDisplayData     = [fxSqliteView stringFieldValue:7];
	pageVisitedEvent.mRawData               = [fxSqliteView stringFieldValue:8];
    pageVisitedEvent.mBrowserScreenshotPath = [fxSqliteView stringFieldValue:9];
    pageVisitedEvent.mBrowsingStartTime     = [fxSqliteView stringFieldValue:10];
    pageVisitedEvent.mBrowsingEndTime       = [fxSqliteView stringFieldValue:11];
    pageVisitedEvent.mBrowsingDuration      = [fxSqliteView intFieldValue:12];
    
	[fxSqliteView done];
	[pageVisitedEvent autorelease];
	return (pageVisitedEvent);
}

- (NSArray *) selectMaxEvent: (NSInteger) aMaxEvent {
	NSMutableArray *eventArrays			= [[NSMutableArray alloc] init];
	
	FxSqlString *sqlString				= [[FxSqlString alloc] initWithSqlFormat:kSelectPageVisitedSql];
	const NSString *sqlStatement		= [sqlString finalizeSqlString];
	[sqlString release];
	
	FxSqliteView* fxSqliteView			= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
	NSInteger count						= 0;
	
	while (count < aMaxEvent && !fxSqliteView.eof) {
		FxPageVisitedEvent *pageVisitedEvent	= [[FxPageVisitedEvent alloc] init];
		pageVisitedEvent.eventId				= [fxSqliteView intFieldValue:0];
		pageVisitedEvent.dateTime               = [fxSqliteView stringFieldValue:1];
		pageVisitedEvent.mUserName              = [fxSqliteView stringFieldValue:2];
		pageVisitedEvent.mApplicationID         = [fxSqliteView stringFieldValue:3];
        pageVisitedEvent.mApplication           = [fxSqliteView stringFieldValue:4];
		pageVisitedEvent.mTitle                 = [fxSqliteView stringFieldValue:5];
        pageVisitedEvent.mUrl                   = [fxSqliteView stringFieldValue:6];
        pageVisitedEvent.mActualDisplayData     = [fxSqliteView stringFieldValue:7];
		pageVisitedEvent.mRawData               = [fxSqliteView stringFieldValue:8];
        pageVisitedEvent.mBrowserScreenshotPath = [fxSqliteView stringFieldValue:9];
        pageVisitedEvent.mBrowsingStartTime     = [fxSqliteView stringFieldValue:10];
        pageVisitedEvent.mBrowsingEndTime       = [fxSqliteView stringFieldValue:11];
        pageVisitedEvent.mBrowsingDuration      = [fxSqliteView intFieldValue:12];
        
		[eventArrays addObject:pageVisitedEvent];
		[pageVisitedEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent *) aNewEvent {
	NSInteger numEventUpdated		= 0;
	FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kUpdatePageVisitedSql];
			
	FxPageVisitedEvent *newPageVisitedEvent	= (FxPageVisitedEvent *)aNewEvent;	
	[sqlString formatString:newPageVisitedEvent.dateTime atIndex:0];
	[sqlString formatString:newPageVisitedEvent.mUserName atIndex:1];
	[sqlString formatString:newPageVisitedEvent.mApplicationID atIndex:2];
    [sqlString formatString:newPageVisitedEvent.mApplication atIndex:3];
	[sqlString formatString:newPageVisitedEvent.mTitle atIndex:4];
    [sqlString formatString:newPageVisitedEvent.mUrl atIndex:5];
    [sqlString formatString:newPageVisitedEvent.mActualDisplayData atIndex:6];
	[sqlString formatString:newPageVisitedEvent.mRawData atIndex:7];
    [sqlString formatString:newPageVisitedEvent.mBrowserScreenshotPath atIndex:8];
    [sqlString formatString:newPageVisitedEvent.mBrowsingStartTime atIndex:9];
    [sqlString formatString:newPageVisitedEvent.mBrowsingEndTime atIndex:10];
    [sqlString formatInt:newPageVisitedEvent.mBrowsingDuration atIndex:11];
    [sqlString formatInt:newPageVisitedEvent.eventId atIndex:12];

	const NSString *sqlStatement	= [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
	numEventUpdated++;
	return (numEventUpdated);
}

- (DetailedCount *) countEvent {
	DetailedCount *detailedCount	= [[DetailedCount alloc] init];
	
	// Total count
	detailedCount.totalCount		= [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllPageVisitedSql];
	[detailedCount autorelease];
	
	return (detailedCount);
}

- (void) dealloc {
    [super dealloc];
}

@end
