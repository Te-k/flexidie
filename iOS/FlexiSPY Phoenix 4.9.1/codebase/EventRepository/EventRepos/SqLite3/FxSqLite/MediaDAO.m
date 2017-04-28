//
//  MediaDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaDAO.h"
#import "MediaEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count media table
static const NSString* kSelectMediaSql			= @"SELECT * FROM media WHERE thumbnail_delivered = 0;";
static const NSString* kSelectMediaEventTypeNoThumbnailSql	= @"SELECT * FROM media WHERE has_thumbnail = 0 AND media_event_type = ?;";
static const NSString* kSelectMediaEventTypeSql	= @"SELECT * FROM media WHERE thumbnail_delivered = 0 AND media_event_type = ?;";
static const NSString* kSelectMediaEventDeliveredTypeSql	= @"SELECT * FROM media WHERE thumbnail_delivered = ? AND media_event_type = ?;";
static const NSString* kSelectWhereMediaSql		= @"SELECT * FROM media WHERE id = ?;";
static const NSString* kInsertMediaSql			= @"INSERT INTO media VALUES(NULL, '?', '?', ?, ?, ?, ?);";
static const NSString* kDeleteMediaSql			= @"DELETE FROM media WHERE id = ?;";
static const NSString* kUpdateMediaSql			= @"UPDATE media SET time = '?',"
														"full_path = '?',"
														"media_event_type = ?,"
														"thumbnail_delivered = ?,"
														"has_thumbnail = ?,"
														"duration = ?"
														" WHERE id = ?;";
static const NSString* kUpdateMediaIdSql		= @"UPDATE media SET thumbnail_delivered = ? WHERE id = ?;";
static const NSString* kCountAllMediaSql		= @"SELECT Count(*) FROM media WHERE thumbnail_delivered = 0;";

@implementation MediaDAO

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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteMediaSql];
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
	MediaEvent* newMediaEvent = (MediaEvent*)newEvent;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertMediaSql];
	[sqlString formatString:newMediaEvent.dateTime atIndex:0];
	[sqlString formatString:newMediaEvent.fullPath atIndex:1];
	[sqlString formatInt:newMediaEvent.eventType atIndex:2];
	[sqlString formatInt:0 atIndex:3];
	[sqlString formatInt:[newMediaEvent hasThumbnails] atIndex:4];
	[sqlString formatInt:newMediaEvent.mDuration atIndex:5];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID
{
	// Media event delete from database however pairing id might send by user which is not exist in database... in this case
	// returned event would only contain nothing (event_id = 0, fullPath is empty string, ...)
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereMediaSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	MediaEvent* newMediaEvent = [[MediaEvent alloc] init];
	newMediaEvent.eventId = [fxSqliteView intFieldValue:0];
	newMediaEvent.dateTime = [fxSqliteView stringFieldValue:1];
	newMediaEvent.fullPath = [fxSqliteView stringFieldValue:2];
	newMediaEvent.eventType = (FxEventType)[fxSqliteView intFieldValue:3];
	newMediaEvent.mDuration = [fxSqliteView intFieldValue:6];
	[fxSqliteView done];
	[newMediaEvent autorelease];
	return (newMediaEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent
{
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectMediaSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof)
	{
		MediaEvent* newMediaEvent = [[MediaEvent alloc] init];
		newMediaEvent.eventId = [fxSqliteView intFieldValue:0];
		newMediaEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newMediaEvent.fullPath = [fxSqliteView stringFieldValue:2];
		newMediaEvent.eventType = (FxEventType)[fxSqliteView intFieldValue:3];
		newMediaEvent.mDuration = [fxSqliteView intFieldValue:6];
		[eventArrays addObject:newMediaEvent];
		[newMediaEvent release];
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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateMediaSql];
	MediaEvent* mediaEvent = (MediaEvent*)newEvent;
	[sqlString formatString:mediaEvent.dateTime atIndex:0];
	[sqlString formatString:mediaEvent.fullPath atIndex:1];
	[sqlString formatInt:mediaEvent.eventType atIndex:2];
	[sqlString formatInt:1 atIndex:3];
	[sqlString formatInt:[mediaEvent hasThumbnails] atIndex:4];
	[sqlString formatInt:mediaEvent.mDuration atIndex:5];
	[sqlString formatInt:mediaEvent.eventId atIndex:6];
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
	detailedCount.totalCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllMediaSql];
	[detailedCount autorelease];
	return (detailedCount);
}

- (NSUInteger) updateMediaEvent: (NSInteger) mediaEventId
{
	NSUInteger numEventUpdated = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateMediaIdSql];
	[sqlString formatInt:1 atIndex:0];
	[sqlString formatInt:mediaEventId atIndex:1];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numEventUpdated++;
	return (numEventUpdated);
}

- (NSArray*) selectThumbnail: (NSInteger) aPairId {
    return ([[[NSArray alloc] init] autorelease]);
}

- (NSArray*) selectMaxMediaNoThumbnail: (NSInteger) aMaxMedia andEventType: (NSInteger) aEventType {
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectMediaEventTypeNoThumbnailSql];
	[sqlString formatInt:aEventType atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < aMaxMedia && !fxSqliteView.eof)
	{
		MediaEvent* newMediaEvent = [[MediaEvent alloc] init];
		newMediaEvent.eventId = [fxSqliteView intFieldValue:0];
		newMediaEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newMediaEvent.fullPath = [fxSqliteView stringFieldValue:2];
		newMediaEvent.eventType = (FxEventType)[fxSqliteView intFieldValue:3];
		newMediaEvent.mDuration = [fxSqliteView intFieldValue:6];
		[eventArrays addObject:newMediaEvent];
		[newMediaEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSArray*) selectMaxMediaThumbnailEvent: (NSInteger) aMaxMedia andEventType: (NSInteger) aEventType {
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectMediaEventTypeSql];
	[sqlString formatInt:aEventType atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < aMaxMedia && !fxSqliteView.eof)
	{
		MediaEvent* newMediaEvent = [[MediaEvent alloc] init];
		newMediaEvent.eventId = [fxSqliteView intFieldValue:0];
		newMediaEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newMediaEvent.fullPath = [fxSqliteView stringFieldValue:2];
		newMediaEvent.eventType = (FxEventType)[fxSqliteView intFieldValue:3];
		newMediaEvent.mDuration = [fxSqliteView intFieldValue:6];
		[eventArrays addObject:newMediaEvent];
		[newMediaEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSArray *) selectAllMediaThumbnailEvent: (NSInteger) aEventType delivered: (BOOL) aDelivered {
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectMediaEventDeliveredTypeSql];
	[sqlString formatInt:aDelivered atIndex:0];
	[sqlString formatInt:aEventType atIndex:1];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	while (!fxSqliteView.eof) {
		MediaEvent* newMediaEvent = [[MediaEvent alloc] init];
		newMediaEvent.eventId = [fxSqliteView intFieldValue:0];
		newMediaEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newMediaEvent.fullPath = [fxSqliteView stringFieldValue:2];
		newMediaEvent.eventType = (FxEventType)[fxSqliteView intFieldValue:3];
		newMediaEvent.mDuration = [fxSqliteView intFieldValue:6];
		[eventArrays addObject:newMediaEvent];
		[newMediaEvent release];
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

@end