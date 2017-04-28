//
//  BookmarksDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 5/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BookmarksDAO.h"
#import "FxBookmarkEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count bookmarks table
static const NSString* kSelectBookmarksSql				= @"SELECT * FROM bookmarks;";
static const NSString* kSelectWhereBookmarksSql			= @"SELECT * FROM bookmarks WHERE id = ?;";
static const NSString* kInsertBookmarksSql				= @"INSERT INTO bookmarks VALUES(NULL, '?');";
static const NSString* kDeleteBookmarksSql				= @"DELETE FROM bookmarks WHERE id = ?;";
static const NSString* kUpdateBookmarksSql				= @"UPDATE bookmarks SET time = '?'"
																" WHERE id = ?;";
static const NSString* kCountAllBookmarksSql			= @"SELECT Count(*) FROM bookmarks;";

@implementation BookmarksDAO

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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteBookmarksSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent {
	NSInteger numEventInserted = 0;
	FxBookmarkEvent* newBookmarkEvent = (FxBookmarkEvent*)newEvent;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertBookmarksSql];
	[sqlString formatString:newBookmarkEvent.dateTime atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID {
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereBookmarksSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	FxBookmarkEvent* newBookmarkEvent = [[FxBookmarkEvent alloc] init];
	newBookmarkEvent.eventId = [fxSqliteView intFieldValue:0];
	newBookmarkEvent.dateTime = [fxSqliteView stringFieldValue:1];
	[fxSqliteView done];
	[newBookmarkEvent autorelease];
	return (newBookmarkEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent {
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectBookmarksSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof) {
		FxBookmarkEvent* newBookmarkEvent = [[FxBookmarkEvent alloc] init];
		newBookmarkEvent.eventId = [fxSqliteView intFieldValue:0];
		newBookmarkEvent.dateTime = [fxSqliteView stringFieldValue:1];
		[eventArrays addObject:newBookmarkEvent];
		[newBookmarkEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent {
	NSInteger numEventUpdated = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateBookmarksSql];
	FxBookmarkEvent* newBookmarkEvent = (FxBookmarkEvent*)newEvent;
	[sqlString formatString:newBookmarkEvent.dateTime atIndex:0];
	[sqlString formatInt:newBookmarkEvent.eventId atIndex:1];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventUpdated++;
	return (numEventUpdated);
}

- (DetailedCount*) countEvent {
	DetailedCount* detailedCount = [[DetailedCount alloc] init];
	
	// Total count
	detailedCount.totalCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:kCountAllBookmarksSql];
	
	[detailedCount autorelease];
	return (detailedCount);
}

@end