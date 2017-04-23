//
//  IMMessageAttachmentDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 2/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMMessageAttachmentDAO.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"
#import "FxDbException.h"

#import "FxAttachment.h"
#import "FxAttachmentWrapper.h"

#include <sqlite3.h>

static NSString * const kSelectIMMessageAttachmentSql			= @"SELECT * FROM im_message_attachment;";
static NSString * const kSelectIMMessageAttachmentWhereSql		= @"SELECT * FROM im_message_attachment WHERE id = ?;";
static NSString * const kSelectIMMessageAttachmentWhereIMMessageIDSql	= @"SELECT * FROM im_message_attachment WHERE im_message_id = ?;";
// Used sqlite3_bind_text function that's why there is no single quote
static NSString * const kInsertIMMessageAttachmentSql			= @"INSERT INTO im_message_attachment VALUES(NULL, ?, ?, ?);";
static NSString * const kDeleteIMMessageAttachmentSql			= @"DELETE FROM im_message_attachment WHERE id = ?;";
// Used sqlite3_bind_text function that's why there is no single quote
static NSString * const kUpdateIMMessageAttachmentSql			= @"UPDATE im_message_attachment SET full_path = ?,"
																				"thumbnail = ?,"
																				"im_message_id = ?"																				
																				" WHERE id = ?;";
static NSString * const kCountIMMessageAttachmentAllSql			= @"SELECT Count(*) FROM im_message_attachment;";

@implementation IMMessageAttachmentDAO

- (id) initWithSqlite3: (sqlite3 *) aSqlite3 {
	if ((self = [super init])) {
		mSqlite3 = aSqlite3;
	}
	return (self);
}

- (NSArray *) selectRowWithIMMessageID: (NSInteger) aIMMessageID {
    NSMutableArray* rowArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMMessageAttachmentWhereIMMessageIDSql];
    [sqlString formatInt:aIMMessageID atIndex:0];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	while (!fxSqliteView.eof) {
		FxAttachmentWrapper* row = [[FxAttachmentWrapper alloc] init];
		FxAttachment* attachment = [[FxAttachment alloc] init];
		attachment.dbId = [fxSqliteView intFieldValue:0];
		attachment.fullPath = [fxSqliteView stringFieldValue:1];
		attachment.mThumbnail = [fxSqliteView dataFieldValue:2];
		row.mIMID = [fxSqliteView intFieldValue:3];
		row.attachment = attachment;
		[attachment release];
		[rowArrays addObject:row];
		[row release];
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[rowArrays autorelease];
	return (rowArrays);
}

- (NSInteger) deleteRow: (NSInteger) rowId {
	NSInteger numEventDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteIMMessageAttachmentSql];
	[sqlString formatInt:rowId atIndex:0];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertRow: (id) row {
	NSInteger numRowInserted = 0;
	FxAttachmentWrapper* newRow = (FxAttachmentWrapper*)row;
    
    sqlite3_stmt* sqliteStmt = NULL;
	const char* unusedSqlStatementTail = NULL;
	const char* utf8SqlStatementEncoding = [kInsertIMMessageAttachmentSql cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger error = sqlite3_prepare_v2(mSqlite3, utf8SqlStatementEncoding, strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
	
	if (error != SQLITE_OK) {
		if (sqliteStmt) {
			sqlite3_free(sqliteStmt);
		}
		FxDbException* dbException = [FxDbException exceptionWithName:@"insert IMMessageAttachment row"
															andReason:[NSString stringWithFormat:@"sqlite3 error = %d", error]];
		dbException.errorCode = error;
		@throw dbException;
	} else {
        // If binding object is nil; it will cause sqlite3_bind_xxx crash
		const char *fullPath = [[newRow attachment] fullPath] ? [[[newRow attachment] fullPath] cStringUsingEncoding:NSUTF8StringEncoding] : "";
		sqlite3_bind_text(sqliteStmt, 1, fullPath, strlen(fullPath), NULL);
		NSData *thumbnail = [[newRow attachment] mThumbnail];
        thumbnail = thumbnail ? thumbnail : [NSData data];
        sqlite3_bind_blob(sqliteStmt, 2, [thumbnail bytes], [thumbnail length], SQLITE_STATIC);
		sqlite3_bind_int(sqliteStmt, 3, [newRow mIMID]);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"insert IMMessageAttachment row"
																andReason:[NSString stringWithFormat:@"sqlite3 step3, error = %d", error]];
            dbException.errorCode = error;
            @throw dbException;
        }
        sqlite3_finalize(sqliteStmt);
        sqliteStmt = NULL;
    }
    
    numRowInserted++;
	return (numRowInserted);
}

- (id) selectRow: (NSInteger) rowId {
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMMessageAttachmentSql];
	[sqlString formatInt:rowId atIndex:0];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
    FxAttachmentWrapper* row = [[FxAttachmentWrapper alloc] init];
	FxAttachment* attachment = [[FxAttachment alloc] init];
	attachment.dbId = [fxSqliteView intFieldValue:0];
	attachment.fullPath = [fxSqliteView stringFieldValue:1];
	attachment.mThumbnail = [fxSqliteView dataFieldValue:2];
	row.mIMID = [fxSqliteView intFieldValue:3];
	row.attachment = attachment;
	[attachment release];
    [fxSqliteView done];
	[row autorelease];
	return (row);
}

- (NSArray*) selectMaxRow: (NSInteger) maxRow {
	NSMutableArray* rowArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMMessageAttachmentSql];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxRow && !fxSqliteView.eof) {
		FxAttachmentWrapper* row = [[FxAttachmentWrapper alloc] init];
		FxAttachment* attachment = [[FxAttachment alloc] init];
		attachment.dbId = [fxSqliteView intFieldValue:0];
		attachment.fullPath = [fxSqliteView stringFieldValue:1];
		attachment.mThumbnail = [fxSqliteView dataFieldValue:2];
		row.mIMID = [fxSqliteView intFieldValue:3];
		row.attachment = attachment;
		[attachment release];
		[rowArrays addObject:row];
		[row release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[rowArrays autorelease];
	return (rowArrays);
}

- (NSInteger) updateRow: (id) row {
	NSInteger numRowUpdated = 0;
	FxAttachmentWrapper* newRow = (FxAttachmentWrapper *)row;
	
    sqlite3_stmt* sqliteStmt = NULL;
	const char* unusedSqlStatementTail = NULL;
	const char* utf8SqlStatementEncoding = [kUpdateIMMessageAttachmentSql cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger error = sqlite3_prepare_v2(mSqlite3, utf8SqlStatementEncoding, strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
	
	if (error != SQLITE_OK) {
		if (sqliteStmt) {
			sqlite3_free(sqliteStmt);
		}
		FxDbException* dbException = [FxDbException exceptionWithName:@"update IMMessageAttachment row"
															andReason:[NSString stringWithFormat:@"sqlite3 error = %d", error]];
		dbException.errorCode = error;
		@throw dbException;
	}
    else {
        // If binding object is nil; it will cause sqlite3_bind_xxx crash
        const char *fullPath = [[newRow attachment] fullPath] ? [[[newRow attachment] fullPath] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 1, fullPath, strlen(fullPath), NULL);
		NSData *thumbnail = [[newRow attachment] mThumbnail];
        thumbnail = thumbnail ? thumbnail : [NSData data];
        sqlite3_bind_blob(sqliteStmt, 2, [thumbnail bytes], [thumbnail length], SQLITE_STATIC);
		sqlite3_bind_int(sqliteStmt, 3, [newRow mIMID]);
        sqlite3_bind_int(sqliteStmt, 4, [[newRow attachment] dbId]);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"update IMMessageAttachment row"
																andReason:[NSString stringWithFormat:@"sqlite3 step3, error = %d", error]];
            dbException.errorCode = error;
            @throw dbException;
        }
        sqlite3_finalize(sqliteStmt);
        sqliteStmt = NULL;
    }
	numRowUpdated++;
	return (numRowUpdated);
}

- (NSInteger) countRow {
	NSInteger rowCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:kCountIMMessageAttachmentAllSql];
	return (rowCount);
}

- (void) dealloc {
	[super dealloc];
}

@end
