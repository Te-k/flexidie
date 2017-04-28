//
//  AttachmentDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AttachmentDAO.h"
#import "FxAttachment.h"
#import "FxAttachmentWrapper.h"
#import "DAOFunction.h"
#import "FxSqlString.h"
#import "FxSqliteView.h"
#import "EventCount.h"
#import "EventBaseDAO.h"

// Select/Insert/Delete/Update/Count attachment table
static const NSString* kSelectAttachmentSql			= @"SELECT * FROM attachment;";
static const NSString* kSelectWhereAttachmentSql	= @"SELECT * FROM attachment WHERE id = ?;";
static const NSString* kSelectWhereMMSAttachmentSql	= @"SELECT * FROM attachment WHERE mms_id = ?;";
static const NSString* kSelectWhereEmailAttachmentSql	= @"SELECT * FROM attachment WHERE email_id = ?;";
static const NSString* kSelectWhereIMAttachmentSql	= @"SELECT * FROM attachment WHERE im_id = ?;";
static const NSString* kInsertAttachmentSql			= @"INSERT INTO attachment VALUES(NULL, '?', ?, ?, ?);";
static const NSString* kDeleteAttachmentSql			= @"DELETE FROM attachment WHERE id = ?;";
static const NSString* kUpdateAttachmentSql			= @"UPDATE attachment SET full_path = '?',"
																"mms_id = ?,"
																"email_id = ?,"
																"im_id = ?"
																" WHERE id = ?;";
static const NSString* kCountAllAttachmentSql			= @"SELECT Count(*) FROM attachment;";

@implementation AttachmentDAO

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

- (NSInteger) deleteRow: (NSInteger) rowId
{
	NSInteger numRowDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteAttachmentSql];
	[sqlString formatInt:rowId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numRowDeleted++;
	return (numRowDeleted);
}

- (NSInteger) insertRow: (id) row
{
	NSInteger numRowInserted = 0;
	FxAttachmentWrapper* newRow = row;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertAttachmentSql];
	[sqlString formatString:newRow.attachment.fullPath atIndex:0];
	[sqlString formatInt:newRow.mmsId atIndex:1];
	[sqlString formatInt:newRow.emailId atIndex:2];
	[sqlString formatInt:newRow.mIMID atIndex:3];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numRowInserted++;
	return (numRowInserted);
}

- (id) selectRow: (NSInteger) rowId
{
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereAttachmentSql];
	[sqlString formatInt:rowId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
    FxAttachmentWrapper* newRow = [[FxAttachmentWrapper alloc] init];
	FxAttachment* attachment = [[FxAttachment alloc] init];
	attachment.dbId = [fxSqliteView intFieldValue:0];
	attachment.fullPath = [fxSqliteView stringFieldValue:1];
	newRow.mmsId = [fxSqliteView intFieldValue:2];
	newRow.emailId = [fxSqliteView intFieldValue:3];
	newRow.mIMID = [fxSqliteView intFieldValue:4];
	newRow.attachment = attachment;
	[attachment release];
    [fxSqliteView done];
	[newRow autorelease];
	return (newRow);
}

- (NSArray*) selectMaxRow: (NSInteger) maxRow
{
	NSMutableArray* rowArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectAttachmentSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxRow && !fxSqliteView.eof)
	{
		FxAttachmentWrapper* newRow = [[FxAttachmentWrapper alloc] init];
		FxAttachment* attachment = [[FxAttachment alloc] init];
		attachment.dbId = [fxSqliteView intFieldValue:0];
		attachment.fullPath = [fxSqliteView stringFieldValue:1];
		newRow.mmsId = [fxSqliteView intFieldValue:2];
		newRow.emailId = [fxSqliteView intFieldValue:3];
		newRow.mIMID = [fxSqliteView intFieldValue:4];
		newRow.attachment = attachment;
		[attachment release];
		[rowArrays addObject:newRow];
		[newRow release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[rowArrays autorelease];
	return (rowArrays);
}

- (NSInteger) updateRow: (id) row
{
	NSInteger numRowUpdated = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateAttachmentSql];
	FxAttachmentWrapper* attWrapper = row;
	[sqlString formatString:attWrapper.attachment.fullPath atIndex:0];
	[sqlString formatInt:attWrapper.mmsId atIndex:1];
	[sqlString formatInt:attWrapper.emailId atIndex:2];
	[sqlString formatInt:attWrapper.mIMID atIndex:3];
	[sqlString formatInt:attWrapper.attachment.dbId atIndex:4];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:sqliteDatabase withSqlStatement:sqlStatement];
	numRowUpdated++;
	return (numRowUpdated);
}

- (NSInteger) countRow
{
	NSInteger rowCount = [DAOFunction execScalar:sqliteDatabase withSqlStatement:kCountAllAttachmentSql];
	return (rowCount);
}

- (EventCount*) countAllEvent {
	EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:sqliteDatabase];
	EventCount* eventCount = [eventBaseDAO countAllEvent];
	[eventBaseDAO release];
	return (eventCount);
}

- (NSUInteger) totalEventCount {
	EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:sqliteDatabase];
	NSInteger totalEventCount = [eventBaseDAO totalEventCount];
	[eventBaseDAO release];
	return (totalEventCount);
}

- (void) executeSql: (NSString*) aSqlStatement {
	EventBaseDAO* eventBaseDAO = [[EventBaseDAO alloc] initWithSqlite3:sqliteDatabase];
	[eventBaseDAO executeSql:aSqlStatement];
	[eventBaseDAO release];
}

- (id) selectRow: (NSInteger) aEventTypeId andEventType: (NSInteger) aEventType {
	NSMutableArray* rowArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = nil;
	switch (aEventType) {
		case kEventTypeMms: {
			sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereMMSAttachmentSql];
		} break;
		case kEventTypeMail: {
			sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereEmailAttachmentSql];
		} break;
		case kEventTypeIM: {
			sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereIMAttachmentSql];
		} break;
		default: {
		} break;
	}
	[sqlString formatInt:aEventTypeId atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:sqliteDatabase withSqlStatement:sqlStatement];
    while (!fxSqliteView.eof) {
        FxAttachmentWrapper* newRow = [[FxAttachmentWrapper alloc] init];
        FxAttachment* attachment = [[FxAttachment alloc] init];
        attachment.dbId = [fxSqliteView intFieldValue:0];
        attachment.fullPath = [fxSqliteView stringFieldValue:1];
        newRow.mmsId = [fxSqliteView intFieldValue:2];
        newRow.emailId = [fxSqliteView intFieldValue:3];
		newRow.mIMID = [fxSqliteView intFieldValue:4];
        newRow.attachment = attachment;
        [attachment release];
        [rowArrays addObject:newRow];
        [newRow release];
        [fxSqliteView nextRow];
    }
	[fxSqliteView done];
	[rowArrays autorelease];
	return (rowArrays);
}

@end
