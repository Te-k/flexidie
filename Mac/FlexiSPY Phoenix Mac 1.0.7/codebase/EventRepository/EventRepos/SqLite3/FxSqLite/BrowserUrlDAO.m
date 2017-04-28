//
//  BrowserUrlDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 5/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BrowserUrlDAO.h"
#import "FxBrowserUrlEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count browser_url table
static const NSString* kSelectBrowserUrlSql				= @"SELECT * FROM browser_url;";
static const NSString* kSelectWhereBrowserUrlSql		= @"SELECT * FROM browser_url WHERE id = ?;";
static const NSString* kInsertBrowserUrlSql				= @"INSERT INTO browser_url VALUES(NULL, '?', '?', '?', '?', ?, '?');";
static const NSString* kDeleteBrowserUrlSql				= @"DELETE FROM browser_url WHERE id = ?;";
static const NSString* kUpdateBrowserUrlSql				= @"UPDATE browser_url SET time = '?',"
																"title = '?',"
																"url = '?',"
																"visit_time = '?',"
																"block = ?,"
																"owning_app = '?'"
																" WHERE id = ?;";
static const NSString* kCountAllBrowserUrlSql			= @"SELECT Count(*) FROM browser_url;";

@implementation BrowserUrlDAO

- (id) initWithSqlite3: (sqlite3 *) aSqlite3 {
	if (self = [super init]) {
		mSqlite3 = aSqlite3;
	}
	return (self);
}

- (void) dealloc {
	[super dealloc];
}

- (NSInteger) deleteEvent: (NSInteger) eventID {
	NSInteger numEventDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteBrowserUrlSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent {
	DLog (@"Url browser event need to insert = %@", newEvent);
	NSInteger numEventInserted = 0;
	FxBrowserUrlEvent* newBrowserUrlEvent = (FxBrowserUrlEvent*)newEvent;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertBrowserUrlSql];
	[sqlString formatString:newBrowserUrlEvent.dateTime atIndex:0];
	[sqlString formatString:newBrowserUrlEvent.mTitle atIndex:1];
	[sqlString formatString:newBrowserUrlEvent.mUrl atIndex:2];
	[sqlString formatString:newBrowserUrlEvent.mVisitTime atIndex:3];
	[sqlString formatInt:newBrowserUrlEvent.mIsBlocked atIndex:4];
	[sqlString formatString:newBrowserUrlEvent.mOwningApp atIndex:5];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID {
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereBrowserUrlSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	FxBrowserUrlEvent* newBrowserUrlEvent = [[FxBrowserUrlEvent alloc] init];
	newBrowserUrlEvent.eventId = [fxSqliteView intFieldValue:0];
	newBrowserUrlEvent.dateTime = [fxSqliteView stringFieldValue:1];
	newBrowserUrlEvent.mTitle = [fxSqliteView stringFieldValue:2];
	newBrowserUrlEvent.mUrl = [fxSqliteView stringFieldValue:3];
	newBrowserUrlEvent.mVisitTime = [fxSqliteView stringFieldValue:4];
	newBrowserUrlEvent.mIsBlocked = [fxSqliteView intFieldValue:5];
	newBrowserUrlEvent.mOwningApp = [fxSqliteView stringFieldValue:6];
	[fxSqliteView done];
	[newBrowserUrlEvent autorelease];
	return (newBrowserUrlEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent {
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectBrowserUrlSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof) {
		FxBrowserUrlEvent* newBrowserUrlEvent = [[FxBrowserUrlEvent alloc] init];
		newBrowserUrlEvent.eventId = [fxSqliteView intFieldValue:0];
		newBrowserUrlEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newBrowserUrlEvent.mTitle = [fxSqliteView stringFieldValue:2];
		newBrowserUrlEvent.mUrl = [fxSqliteView stringFieldValue:3];
		newBrowserUrlEvent.mVisitTime = [fxSqliteView stringFieldValue:4];
		newBrowserUrlEvent.mIsBlocked = [fxSqliteView intFieldValue:5];
		newBrowserUrlEvent.mOwningApp = [fxSqliteView stringFieldValue:6];
		[eventArrays addObject:newBrowserUrlEvent];
		[newBrowserUrlEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent {
	NSInteger numEventUpdated = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateBrowserUrlSql];
	FxBrowserUrlEvent* newBrowserUrlEvent = (FxBrowserUrlEvent*)newEvent;
	[sqlString formatString:newBrowserUrlEvent.dateTime atIndex:0];
	[sqlString formatString:newBrowserUrlEvent.mTitle atIndex:1];
	[sqlString formatString:newBrowserUrlEvent.mUrl atIndex:2];
	[sqlString formatString:newBrowserUrlEvent.mVisitTime atIndex:3];
	[sqlString formatInt:newBrowserUrlEvent.mIsBlocked atIndex:4];
	[sqlString formatString:newBrowserUrlEvent.mOwningApp atIndex:5];
	[sqlString formatInt:newBrowserUrlEvent.eventId atIndex:6];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventUpdated++;
	return (numEventUpdated);
}

- (DetailedCount*) countEvent {
	DetailedCount* detailedCount = [[DetailedCount alloc] init];
	
	// Total count
	detailedCount.totalCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:kCountAllBrowserUrlSql];
		
	[detailedCount autorelease];
	return (detailedCount);
}

@end
