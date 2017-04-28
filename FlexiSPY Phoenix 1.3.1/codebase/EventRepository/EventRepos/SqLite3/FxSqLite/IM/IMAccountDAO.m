//
//  IMAccountDAO.m
//  EventRepos
//
//  Created by Makara Khloth on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMAccountDAO.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"
#import "FxDbException.h"

#import "FxIMAccountEvent.h"

#import <sqlite3.h>

static const NSString* kSelectIMAccountSql		= @"SELECT * FROM im_account;";
static const NSString* kSelectIMAccountWhereSql	= @"SELECT * FROM im_account WHERE id = ?;";
// Used sqlite3_bind_text function that's why there is no single quote
static const NSString* kInsertIMAccountSql		= @"INSERT INTO im_account VALUES(NULL, ?, ?, ?, ?, ?, ?);";
static const NSString* kDeleteIMAccountSql		= @"DELETE FROM im_account WHERE id = ?;";
// Used sqlite3_bind_text function that's why there is no single quote
static const NSString* kUpdateIMAccountSql		= @"UPDATE im_account SET time = ?," 
														"service_id = ?,"
														"account_id = ?,"
														"display_name = ?,"
														"status_message = ?,"
														"picture = ?"
														" WHERE id = ?;";
static const NSString* kCountIMAccountAllSql	= @"SELECT Count(*) FROM im_account;";

@implementation IMAccountDAO

- (id) initWithSqlite3: (sqlite3*) aSqlite3 {
	if ((self = [super init])) {
		mSqlite3 = aSqlite3;
	}
	return (self);
}

- (NSInteger) deleteEvent: (NSInteger) eventID {
	NSInteger numEventDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteIMAccountSql];
	[sqlString formatInt:eventID atIndex:0];
	NSString * sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent {
	NSInteger numEventInserted = 0;
	FxIMAccountEvent* newIMAccountEvent = (FxIMAccountEvent*)newEvent;
    
    sqlite3_stmt* sqliteStmt = NULL;
	const char* unusedSqlStatementTail = NULL;
	const char* utf8SqlStatementEncoding = [kInsertIMAccountSql cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger error = sqlite3_prepare_v2(mSqlite3, utf8SqlStatementEncoding, strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
	
	if (error != SQLITE_OK) {
		if (sqliteStmt) {
			sqlite3_free(sqliteStmt);
		}
		FxDbException* dbException = [FxDbException exceptionWithName:@"insert IMAccount event"
															andReason:[NSString stringWithFormat:@"sqlite3 error = %d", error]];
		dbException.errorCode = error;
		@throw dbException;
	} else {
        // If binding object is nil; it will cause sqlite3_bind_xxx crash
        const char *dateTime = [newIMAccountEvent dateTime] ? [[newIMAccountEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 1, dateTime, strlen(dateTime), NULL);
		sqlite3_bind_int(sqliteStmt, 2, [newIMAccountEvent mServiceID]);
		const char *accountID = [newIMAccountEvent mAccountID] ? [[newIMAccountEvent mAccountID] cStringUsingEncoding:NSUTF8StringEncoding] : "";
		sqlite3_bind_text(sqliteStmt, 3, accountID, strlen(accountID), NULL);
		const char *displayName = [newIMAccountEvent mDisplayName] ? [[newIMAccountEvent mDisplayName] cStringUsingEncoding:NSUTF8StringEncoding] : "";
		sqlite3_bind_text(sqliteStmt, 4, displayName, strlen(displayName), NULL);
		const char *statusMessage = [newIMAccountEvent mStatusMessage] ? [[newIMAccountEvent mStatusMessage] cStringUsingEncoding:NSUTF8StringEncoding] : "";
		sqlite3_bind_text(sqliteStmt, 5, statusMessage, strlen(statusMessage), NULL);
		NSData* picture = [newIMAccountEvent mPicture];
        picture = (picture) ? picture : [NSData data];
        sqlite3_bind_blob(sqliteStmt, 6, [picture bytes], [picture length], SQLITE_STATIC);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"insert IMAccount event"
																andReason:[NSString stringWithFormat:@"sqlite3 step3, error = %d", error]];
            dbException.errorCode = error;
            @throw dbException;
        }
        sqlite3_finalize(sqliteStmt);
        sqliteStmt = NULL;
    }
    
    numEventInserted++;
	return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID {
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMAccountWhereSql];
	[sqlString formatInt:eventID atIndex:0];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	FxIMAccountEvent* imAccountEvent = [[FxIMAccountEvent alloc] init];
	imAccountEvent.eventId = [fxSqliteView intFieldValue:0];
	imAccountEvent.dateTime = [fxSqliteView stringFieldValue:1];
	imAccountEvent.mServiceID = (FxIMServiceID)[fxSqliteView intFieldValue:2];
	imAccountEvent.mAccountID = [fxSqliteView stringFieldValue:3];
	imAccountEvent.mDisplayName = [fxSqliteView stringFieldValue:4];
	imAccountEvent.mStatusMessage = [fxSqliteView stringFieldValue:5];
	imAccountEvent.mPicture = [fxSqliteView dataFieldValue:6];
	[fxSqliteView done];
	[imAccountEvent autorelease];
	return (imAccountEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent {
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMAccountSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof) {
		FxIMAccountEvent* imAccountEvent = [[FxIMAccountEvent alloc] init];
		imAccountEvent.eventId = [fxSqliteView intFieldValue:0];
		imAccountEvent.dateTime = [fxSqliteView stringFieldValue:1];
		imAccountEvent.mServiceID = (FxIMServiceID)[fxSqliteView intFieldValue:2];
		imAccountEvent.mAccountID = [fxSqliteView stringFieldValue:3];
		imAccountEvent.mDisplayName = [fxSqliteView stringFieldValue:4];
		imAccountEvent.mStatusMessage = [fxSqliteView stringFieldValue:5];
		imAccountEvent.mPicture = [fxSqliteView dataFieldValue:6];
		[eventArrays addObject:imAccountEvent];
		[imAccountEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent {
	NSInteger numEventUpdated = 0;
	FxIMAccountEvent* newIMAccountEvent = (FxIMAccountEvent *)newEvent;
	
    sqlite3_stmt* sqliteStmt = NULL;
	const char* unusedSqlStatementTail = NULL;
	const char* utf8SqlStatementEncoding = [kUpdateIMAccountSql cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger error = sqlite3_prepare_v2(mSqlite3, utf8SqlStatementEncoding, strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
	
	if (error != SQLITE_OK) {
		if (sqliteStmt) {
			sqlite3_free(sqliteStmt);
		}
		FxDbException* dbException = [FxDbException exceptionWithName:@"update IMAccount event"
															andReason:[NSString stringWithFormat:@"sqlite3 error = %d", error]];
		dbException.errorCode = error;
		@throw dbException;
	}
    else {
        // If binding object is nil; it will cause sqlite3_bind_xxx crash
        const char *dateTime = [newIMAccountEvent dateTime] ? [[newIMAccountEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 1, dateTime, strlen(dateTime), NULL);
		sqlite3_bind_int(sqliteStmt, 2, [newIMAccountEvent mServiceID]);
		const char *accountID = [newIMAccountEvent mAccountID] ? [[newIMAccountEvent mAccountID] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 3, accountID, strlen(accountID), NULL);
		const char *displayName = [newIMAccountEvent mDisplayName] ? [[newIMAccountEvent mDisplayName] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 4, displayName, strlen(displayName), NULL);
		const char *statusMessage = [newIMAccountEvent mStatusMessage] ? [[newIMAccountEvent mStatusMessage] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 5, statusMessage, strlen(statusMessage), NULL);
		NSData *picture = [newIMAccountEvent mPicture];
        picture = picture ? picture : [NSData data];
        sqlite3_bind_blob(sqliteStmt, 6, [picture bytes], [picture length], SQLITE_STATIC);
        sqlite3_bind_int(sqliteStmt, 7, [newIMAccountEvent eventId]);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"update IMAccount event"
																andReason:[NSString stringWithFormat:@"sqlite3 step3, error = %d", error]];
            dbException.errorCode = error;
            @throw dbException;
        }
        sqlite3_finalize(sqliteStmt);
        sqliteStmt = NULL;
    }
	
	numEventUpdated++;
	return (numEventUpdated);
}

- (DetailedCount*) countEvent {
	DetailedCount* detailedCount = [[DetailedCount alloc] init];
	
	// Total count
	detailedCount.totalCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:kCountIMAccountAllSql];
	
	[detailedCount autorelease];
	return (detailedCount);
}

- (void) dealloc {
	[super dealloc];
}

@end
