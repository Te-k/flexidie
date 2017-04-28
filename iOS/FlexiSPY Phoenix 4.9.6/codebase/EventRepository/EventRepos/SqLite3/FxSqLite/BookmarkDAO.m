//
//  BookmarkDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 5/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BookmarkDAO.h"
#import "FxBookmarkEvent.h"
#import "FxBookmarkWrapper.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"
#import "EventBaseDAO.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count bookmarks table
static const NSString* kSelectBookmarkSql				= @"SELECT * FROM bookmark;";
static const NSString* kSelectWhereBookmarkSql			= @"SELECT * FROM bookmark WHERE id = ?;";
static const NSString* kSelectWhereBookmarksBookmarkSql	= @"SELECT * FROM bookmark WHERE bookmarks_id = ?;";
static const NSString* kInsertBookmarkSql				= @"INSERT INTO bookmark VALUES(NULL, '?', '?', ?);";
static const NSString* kDeleteBookmarkSql				= @"DELETE FROM bookmark WHERE id = ?;";
static const NSString* kUpdateBookmarkSql				= @"UPDATE bookmark SET title = '?',"
																"url = '?',"
																"bookmarks_id = ?"
																" WHERE id = ?;";
static const NSString* kCountAllBookmarkSql				= @"SELECT Count(*) FROM bookmark;";

@implementation BookmarkDAO

- (id) initWithSqlite3: (sqlite3 *) aSqlite3 {
	if (self = [super init]) {
		mSqlite3 = aSqlite3;
	}
	return (self);
}

- (void) dealloc {
	[super dealloc];
}

- (NSInteger) deleteRow: (NSInteger) rowId {
	NSInteger numRowDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteBookmarkSql];
	[sqlString formatInt:rowId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numRowDeleted++;
	return (numRowDeleted);
}

- (NSInteger) insertRow: (id) row {
	NSInteger numEventInserted = 0;
	FxBookmarkWrapper* newBookmark = (FxBookmarkWrapper *)row;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertBookmarkSql];
	[sqlString formatString:newBookmark.mBookmark.mTitle atIndex:0];
	[sqlString formatString:newBookmark.mBookmark.mUrl atIndex:1];
	[sqlString formatInt:newBookmark.mBookmarksId atIndex:2];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (id) selectRow: (NSInteger) rowId {
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereBookmarkSql];
	[sqlString formatInt:rowId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	FxBookmarkWrapper* newBookmark = [[FxBookmarkWrapper alloc] init];
	newBookmark.mDBId = [fxSqliteView intFieldValue:0];
	FxBookmark *bookmark = [[FxBookmark alloc] init];
	bookmark.mTitle = [fxSqliteView stringFieldValue:1];
	bookmark.mUrl = [fxSqliteView stringFieldValue:2];
	newBookmark.mBookmark = bookmark;
	[bookmark release];
	newBookmark.mBookmarksId = [fxSqliteView intFieldValue:3];
	[fxSqliteView done];
	[newBookmark autorelease];
	return (newBookmark);
}

- (NSArray*) selectMaxRow: (NSInteger) maxRow {
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectBookmarkSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxRow && !fxSqliteView.eof) {
		FxBookmarkWrapper* newBookmark = [[FxBookmarkWrapper alloc] init];
		newBookmark.mDBId = [fxSqliteView intFieldValue:0];
		FxBookmark *bookmark = [[FxBookmark alloc] init];
		bookmark.mTitle = [fxSqliteView stringFieldValue:1];
		bookmark.mUrl = [fxSqliteView stringFieldValue:2];
		newBookmark.mBookmark = bookmark;
		[bookmark release];
		newBookmark.mBookmarksId = [fxSqliteView intFieldValue:3];
		[eventArrays addObject:newBookmark];
		[newBookmark release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateRow: (id) row {
	NSInteger numRowUpdated = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateBookmarkSql];
	FxBookmarkWrapper* newBookmark = (FxBookmarkWrapper *)row;
	[sqlString formatString:newBookmark.mBookmark.mTitle atIndex:0];
	[sqlString formatString:newBookmark.mBookmark.mUrl atIndex:1];
	[sqlString formatInt:newBookmark.mBookmarksId atIndex:2];
	[sqlString formatInt:newBookmark.mDBId atIndex:3];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numRowUpdated++;
	return (numRowUpdated);
}

- (NSInteger) countRow {
	NSInteger totalCount = 0;
	
	// Total count
	totalCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:kCountAllBookmarkSql];
	
	return (totalCount);
}

- (EventCount*) countAllEvent {
	EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:mSqlite3];
	EventCount* eventCount = [eventBaseDAO countAllEvent];
	[eventBaseDAO release];
	return (eventCount);
}

- (NSUInteger) totalEventCount {
	EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:mSqlite3];
	NSInteger totalEventCount = [eventBaseDAO totalEventCount];
	[eventBaseDAO release];
	return (totalEventCount);
}

- (void) executeSql: (NSString*) aSqlStatement {
	EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:mSqlite3];
	[eventBaseDAO executeSql:aSqlStatement];
	[eventBaseDAO release];
}

- (id) selectRow: (NSInteger) aEventTypeId andEventType: (NSInteger) aEventType {
	NSMutableArray* rowArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = nil;
	switch (aEventType) {
		case kEventTypeBookmark: {
			sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereBookmarksBookmarkSql];
		} break;
		default: {
		} break;
	}
	[sqlString formatInt:aEventTypeId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
    while (!fxSqliteView.eof) {
        FxBookmarkWrapper* newRow = [[FxBookmarkWrapper alloc] init];
        newRow.mDBId = [fxSqliteView intFieldValue:0];
		FxBookmark* bookmark = [[FxBookmark alloc] init];
        bookmark.mTitle = [fxSqliteView stringFieldValue:1];
        bookmark.mUrl = [fxSqliteView stringFieldValue:2];
		newRow.mBookmark = bookmark;
		[bookmark release];
        newRow.mBookmarksId = [fxSqliteView intFieldValue:3];
        [rowArrays addObject:newRow];
        [newRow release];
        [fxSqliteView nextRow];
    }
	[fxSqliteView done];
	[rowArrays autorelease];
	return (rowArrays);
}


@end
