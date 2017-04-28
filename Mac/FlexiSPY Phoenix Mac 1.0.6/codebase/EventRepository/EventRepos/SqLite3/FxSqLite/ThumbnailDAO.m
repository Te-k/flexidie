//
//  ThumbnailDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailDAO.h"
#import "FxThumbnailEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count thumbnail table
static const NSString* kSelectThumbnailSql              = @"SELECT * FROM thumbnail;";
static const NSString* kSelectWhereMediaIdThumbnailSql  = @"SELECT * FROM thumbnail WHERE media_id = ?;";
static const NSString* kSelectWhereIdThumbnailSql       = @"SELECT * FROM thumbnail WHERE id = ?;";
static const NSString* kInsertThumbnailSql              = @"INSERT INTO thumbnail VALUES(NULL, '?', ?, ?, ?);";
static const NSString* kDeleteThumbnailSql              = @"DELETE FROM thumbnail WHERE id = ?;";
static const NSString* kUpdateThumbnailSql              = @"UPDATE thumbnail SET full_path = '?',"
																"actual_size = ?,"
																"actual_duration = ?,"
																"media_id = ?"
																" WHERE id = ?;";
static const NSString* kCountAllThumbnailSql            = @"SELECT Count(*) FROM thumbnail GROUP BY media_id;";

@implementation ThumbnailDAO

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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteThumbnailSql];
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
	FxThumbnailEvent* newThumbnailEvent = (FxThumbnailEvent*)newEvent;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertThumbnailSql];
	[sqlString formatString:newThumbnailEvent.fullPath atIndex:0];
	[sqlString formatInt:newThumbnailEvent.actualSize atIndex:1];
	[sqlString formatInt:newThumbnailEvent.actualDuration atIndex:2];
	[sqlString formatInt:newThumbnailEvent.pairId atIndex:3];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID
{
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereIdThumbnailSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	FxThumbnailEvent* newThumbnailEvent = [[FxThumbnailEvent alloc] init];
	newThumbnailEvent.eventId = [fxSqliteView intFieldValue:0];
	newThumbnailEvent.fullPath = [fxSqliteView stringFieldValue:1];
	newThumbnailEvent.actualSize = [fxSqliteView intFieldValue:2];
	newThumbnailEvent.actualDuration = [fxSqliteView intFieldValue:3];
	newThumbnailEvent.pairId = [fxSqliteView intFieldValue:4];
	[fxSqliteView done];
	[newThumbnailEvent autorelease];
	return (newThumbnailEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent
{
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectThumbnailSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof)
	{
		FxThumbnailEvent* newThumbnailEvent = [[FxThumbnailEvent alloc] init];
		newThumbnailEvent.eventId = [fxSqliteView intFieldValue:0];
		newThumbnailEvent.fullPath = [fxSqliteView stringFieldValue:1];
		newThumbnailEvent.actualSize = [fxSqliteView intFieldValue:2];
		newThumbnailEvent.actualDuration = [fxSqliteView intFieldValue:3];
		newThumbnailEvent.pairId = [fxSqliteView intFieldValue:4];
		[eventArrays addObject:newThumbnailEvent];
		[newThumbnailEvent release];
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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateThumbnailSql];
	FxThumbnailEvent* thumbnailEvent = (FxThumbnailEvent*)newEvent;
	[sqlString formatString:thumbnailEvent.fullPath atIndex:0];
	[sqlString formatInt:thumbnailEvent.actualSize atIndex:1];
	[sqlString formatInt:thumbnailEvent.actualDuration atIndex:2];
	[sqlString formatInt:thumbnailEvent.pairId atIndex:3];
	[sqlString formatInt:thumbnailEvent.eventId atIndex:4];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventUpdated++;
	return (numEventUpdated);
}

- (DetailedCount*) countEvent
{
	DetailedCount* detailedCount = [[DetailedCount alloc] init];
	
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountAllThumbnailSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
    NSInteger rowCount = 0;
    while (!fxSqliteView.eof)
	{
		rowCount++;
		[fxSqliteView nextRow];
	}
    [fxSqliteView done];
    
	// Total count
	detailedCount.totalCount = rowCount;
	[detailedCount autorelease];
	return (detailedCount);
}

- (NSUInteger) updateMediaEvent: (NSInteger) mediaEventId
{
	NSUInteger numEventUpdated = 0;
	return (numEventUpdated);
}

- (NSArray*) selectThumbnail: (NSInteger) aPairId {
    NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereMediaIdThumbnailSql];
    [sqlString formatInt:aPairId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	while (!fxSqliteView.eof)
	{
		FxThumbnailEvent* newThumbnailEvent = [[FxThumbnailEvent alloc] init];
		newThumbnailEvent.eventId = [fxSqliteView intFieldValue:0];
		newThumbnailEvent.fullPath = [fxSqliteView stringFieldValue:1];
		newThumbnailEvent.actualSize = [fxSqliteView intFieldValue:2];
		newThumbnailEvent.actualDuration = [fxSqliteView intFieldValue:3];
		newThumbnailEvent.pairId = [fxSqliteView intFieldValue:4];
		[eventArrays addObject:newThumbnailEvent];
		[newThumbnailEvent release];
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSArray*) selectMaxMediaNoThumbnail: (NSInteger) aMaxMedia andEventType: (NSInteger) aEventType {
	return ([[[NSArray alloc] init] autorelease]);
}

- (NSArray*) selectMaxMediaThumbnailEvent: (NSInteger) aMaxMedia andEventType: (NSInteger) aEventType {
	return ([[[NSArray alloc] init] autorelease]);
}

- (NSArray *) selectAllMediaThumbnailEvent: (NSInteger) aEventType delivered: (BOOL) aDelivered {
	return ([NSArray array]);
}

@end
