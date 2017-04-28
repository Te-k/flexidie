//
//  IMContactDAO.m
//  EventRepos
//
//  Created by Makara Khloth on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMContactDAO.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"
#import "FxDbException.h"

#import "FxIMContactEvent.h"

#import <sqlite3.h>

static const NSString* kSelectIMContactSql		= @"SELECT * FROM im_contact;";
static const NSString* kSelectIMContactWhereSql	= @"SELECT * FROM im_contact WHERE id = ?;";
// Used sqlite3_bind_text function that's why there is no single quote
static const NSString* kInsertIMContactSql		= @"INSERT INTO im_contact VALUES(NULL, ?, ?, ?, ?, ?, ?, ?);";
static const NSString* kDeleteIMContactSql		= @"DELETE FROM im_contact WHERE id = ?;";
// Used sqlite3_bind_text function that's why there is no single quote
static const NSString* kUpdateIMContactSql		= @"UPDATE im_contact SET time = ?," 
														"service_id = ?,"
														"account_id = ?,"
														"contact_id = ?,"
														"display_name = ?,"
														"status_message = ?,"
														"picture = ?"
														" WHERE id = ?;";
static const NSString* kCountIMContactAllSql	= @"SELECT Count(*) FROM im_contact;";

@implementation IMContactDAO

- (id) initWithSqlite3: (sqlite3*) aSqlite3 {
	if ((self = [super init])) {
		mSqlite3 = aSqlite3;
	}
	return (self);
}

- (NSInteger) deleteEvent: (NSInteger) eventID {
	NSInteger numEventDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteIMContactSql];
	[sqlString formatInt:eventID atIndex:0];
	NSString * sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent {
	NSInteger numEventInserted = 0;
	FxIMContactEvent* newIMContactEvent = (FxIMContactEvent*)newEvent;
    
    sqlite3_stmt* sqliteStmt = NULL;
	const char* unusedSqlStatementTail = NULL;
	const char* utf8SqlStatementEncoding = [kInsertIMContactSql cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger error = sqlite3_prepare_v2(mSqlite3, utf8SqlStatementEncoding, strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
	
	if (error != SQLITE_OK) {
		if (sqliteStmt) {
			sqlite3_free(sqliteStmt);
		}
		FxDbException* dbException = [FxDbException exceptionWithName:@"insert IMContact event"
															andReason:[NSString stringWithFormat:@"sqlite3 error = %d", error]];
		dbException.errorCode = error;
		@throw dbException;
	} else {
        // If binding object is nil; it will cause sqlite3_bind_xxx crash
        const char *dateTime = [newIMContactEvent dateTime] ? [[newIMContactEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 1, dateTime, strlen(dateTime), NULL);
		sqlite3_bind_int(sqliteStmt, 2, [newIMContactEvent mServiceID]);
		const char *accountID = [newIMContactEvent mAccountID] ? [[newIMContactEvent mAccountID] cStringUsingEncoding:NSUTF8StringEncoding] : "";
		sqlite3_bind_text(sqliteStmt, 3, accountID, strlen(accountID), NULL);
		const char *contactID = [newIMContactEvent mContactID] ? [[newIMContactEvent mContactID] cStringUsingEncoding:NSUTF8StringEncoding] : "";
		sqlite3_bind_text(sqliteStmt, 4, contactID, strlen(contactID), NULL);
		const char *displayName = [newIMContactEvent mDisplayName] ? [[newIMContactEvent mDisplayName] cStringUsingEncoding:NSUTF8StringEncoding] : "";
		sqlite3_bind_text(sqliteStmt, 5, displayName, strlen(displayName), NULL);
		const char *statusMessage = [newIMContactEvent mStatusMessage] ? [[newIMContactEvent mStatusMessage] cStringUsingEncoding:NSUTF8StringEncoding] : "";
		sqlite3_bind_text(sqliteStmt, 6, statusMessage, strlen(statusMessage), NULL);
		NSData* picture = [newIMContactEvent mPicture];
        picture = picture ? picture : [NSData data];
        sqlite3_bind_blob(sqliteStmt, 7, [picture bytes], [picture length], SQLITE_STATIC);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"insert IMContact event"
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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMContactWhereSql];
	[sqlString formatInt:eventID atIndex:0];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	FxIMContactEvent* imContactEvent = [[FxIMContactEvent alloc] init];
	imContactEvent.eventId = [fxSqliteView intFieldValue:0];
	imContactEvent.dateTime = [fxSqliteView stringFieldValue:1];
	imContactEvent.mServiceID = (FxIMServiceID)[fxSqliteView intFieldValue:2];
	imContactEvent.mAccountID = [fxSqliteView stringFieldValue:3];
	imContactEvent.mContactID = [fxSqliteView stringFieldValue:4];
	imContactEvent.mDisplayName = [fxSqliteView stringFieldValue:5];
	imContactEvent.mStatusMessage = [fxSqliteView stringFieldValue:6];
	imContactEvent.mPicture = [fxSqliteView dataFieldValue:7];
	[fxSqliteView done];
	[imContactEvent autorelease];
	return (imContactEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent {
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMContactSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof) {
		FxIMContactEvent* imContactEvent = [[FxIMContactEvent alloc] init];
		imContactEvent.eventId = [fxSqliteView intFieldValue:0];
		imContactEvent.dateTime = [fxSqliteView stringFieldValue:1];
		imContactEvent.mServiceID = (FxIMServiceID)[fxSqliteView intFieldValue:2];
		imContactEvent.mAccountID = [fxSqliteView stringFieldValue:3];
		imContactEvent.mContactID = [fxSqliteView stringFieldValue:4];
		imContactEvent.mDisplayName = [fxSqliteView stringFieldValue:5];
		imContactEvent.mStatusMessage = [fxSqliteView stringFieldValue:6];
		imContactEvent.mPicture = [fxSqliteView dataFieldValue:7];
		[eventArrays addObject:imContactEvent];
		[imContactEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent {
	NSInteger numEventUpdated = 0;
	FxIMContactEvent* newIMContactEvent = (FxIMContactEvent *)newEvent;
	
    sqlite3_stmt* sqliteStmt = NULL;
	const char* unusedSqlStatementTail = NULL;
	const char* utf8SqlStatementEncoding = [kUpdateIMContactSql cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger error = sqlite3_prepare_v2(mSqlite3, utf8SqlStatementEncoding, strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
	
	if (error != SQLITE_OK) {
		if (sqliteStmt) {
			sqlite3_free(sqliteStmt);
		}
		FxDbException* dbException = [FxDbException exceptionWithName:@"update IMContact event"
															andReason:[NSString stringWithFormat:@"sqlite3 error = %d", error]];
		dbException.errorCode = error;
		@throw dbException;
	}
    else {
        // If binding object is nil; it will cause sqlite3_bind_xxx crash
        const char *dateTime = [newIMContactEvent dateTime] ? [[newIMContactEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 1, dateTime, strlen(dateTime), NULL);
		sqlite3_bind_int(sqliteStmt, 2, [newIMContactEvent mServiceID]);
		const char *accountID = [newIMContactEvent mAccountID] ? [[newIMContactEvent mAccountID] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 3, accountID, strlen(accountID), NULL);
		const char *contactID = [newIMContactEvent mContactID] ? [[newIMContactEvent mContactID] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 4, contactID, strlen(contactID), NULL);
		const char *displayName = [newIMContactEvent mDisplayName] ? [[newIMContactEvent mDisplayName] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 5, displayName, strlen(displayName), NULL);
		const char *statusMessage = [newIMContactEvent mStatusMessage] ? [[newIMContactEvent mStatusMessage] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 6, statusMessage, strlen(statusMessage), NULL);
		NSData *picture = [newIMContactEvent mPicture];
        picture = picture ? picture : [NSData data];
        sqlite3_bind_blob(sqliteStmt, 7, [picture bytes], [picture length], SQLITE_STATIC);
        sqlite3_bind_int(sqliteStmt, 8, [newIMContactEvent eventId]);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"update IMContact event"
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
	detailedCount.totalCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:kCountIMContactAllSql];
	
	[detailedCount autorelease];
	return (detailedCount);
}

- (void) dealloc {
	[super dealloc];
}

@end
