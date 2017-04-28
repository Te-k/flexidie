//
//  IMConversationDAO.m
//  EventRepos
//
//  Created by Makara Khloth on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "IMConversationDAO.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"
#import "FxDbException.h"

#import "FxIMConversationEvent.h"

#import <sqlite3.h>

static const NSString* kSelectIMConversationSql		= @"SELECT * FROM im_conversation;";
static const NSString* kSelectIMConversationWhereSql= @"SELECT * FROM im_conversation WHERE id = ?;";
// Used sqlite3_bind_text function that's why there is no single quote
static const NSString* kInsertIMConversationSql		= @"INSERT INTO im_conversation VALUES(NULL, ?, ?, ?, ?, ?, ?, ?);";
static const NSString* kDeleteIMConversationSql		= @"DELETE FROM im_conversation WHERE id = ?;";
// Used sqlite3_bind_text function that's why there is no single quote
static const NSString* kUpdateIMConversationSql		= @"UPDATE im_conversation SET time = ?," 
															"service_id = ?,"
															"account_id = ?,"
															"conversation_id = ?,"
															"conversation_name = ?,"
															"status_message = ?,"
															"picture = ?"
															" WHERE id = ?;";
static const NSString* kCountIMConversationAllSql	= @"SELECT Count(*) FROM im_conversation;";

@implementation IMConversationDAO

- (id) initWithSqlite3: (sqlite3*) aSqlite3 {
	if ((self = [super init])) {
		mSqlite3 = aSqlite3;
	}
	return (self);
}

- (NSInteger) deleteEvent: (NSInteger) eventID {
	NSInteger numEventDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteIMConversationSql];
	[sqlString formatInt:eventID atIndex:0];
	NSString * sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqlite3 withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent {
	NSInteger numEventInserted = 0;
	FxIMConversationEvent* newIMConversationEvent = (FxIMConversationEvent*)newEvent;
    
    sqlite3_stmt* sqliteStmt = NULL;
	const char* unusedSqlStatementTail = NULL;
	const char* utf8SqlStatementEncoding = [kInsertIMConversationSql cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger error = sqlite3_prepare_v2(mSqlite3, utf8SqlStatementEncoding, strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
	
	if (error != SQLITE_OK) {
		if (sqliteStmt) {
			sqlite3_free(sqliteStmt);
		}
		FxDbException* dbException = [FxDbException exceptionWithName:@"insert IMConversation event"
															andReason:[NSString stringWithFormat:@"sqlite3 error = %d", error]];
		dbException.errorCode = error;
		@throw dbException;
	} else {
        // If binding object is nil; it will cause sqlite3_bind_xxx crash
        const char *dateTime = [newIMConversationEvent dateTime] ? [[newIMConversationEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 1, dateTime, strlen(dateTime), NULL);
		sqlite3_bind_int(sqliteStmt, 2, [newIMConversationEvent mServiceID]);
		const char *accountID = [newIMConversationEvent mAccountID] ? [[newIMConversationEvent mAccountID] cStringUsingEncoding:NSUTF8StringEncoding] : "";
		sqlite3_bind_text(sqliteStmt, 3, accountID, strlen(accountID), NULL);
		const char *conversationID = [newIMConversationEvent mID] ? [[newIMConversationEvent mID] cStringUsingEncoding:NSUTF8StringEncoding] : "";
		sqlite3_bind_text(sqliteStmt, 4, conversationID, strlen(conversationID), NULL);
		const char *conversationName = [newIMConversationEvent mName] ? [[newIMConversationEvent mName] cStringUsingEncoding:NSUTF8StringEncoding] : "";
		sqlite3_bind_text(sqliteStmt, 5, conversationName, strlen(conversationName), NULL);
		const char *statusMessage = [newIMConversationEvent mStatusMessage] ? [[newIMConversationEvent mStatusMessage] cStringUsingEncoding:NSUTF8StringEncoding] : "";
		sqlite3_bind_text(sqliteStmt, 6, statusMessage, strlen(statusMessage), NULL);
		NSData* picture = [newIMConversationEvent mPicture];
        picture = picture ? picture : [NSData data];
        sqlite3_bind_blob(sqliteStmt, 7, [picture bytes], [picture length], SQLITE_STATIC);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"insert IMConversation event"
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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMConversationWhereSql];
	[sqlString formatInt:eventID atIndex:0];
	NSString *sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	FxIMConversationEvent* imConversationEvent = [[FxIMConversationEvent alloc] init];
	imConversationEvent.eventId = [fxSqliteView intFieldValue:0];
	imConversationEvent.dateTime = [fxSqliteView stringFieldValue:1];
	imConversationEvent.mServiceID = (FxIMServiceID)[fxSqliteView intFieldValue:2];
	imConversationEvent.mAccountID = [fxSqliteView stringFieldValue:3];
	imConversationEvent.mID = [fxSqliteView stringFieldValue:4];
	imConversationEvent.mName = [fxSqliteView stringFieldValue:5];
	imConversationEvent.mStatusMessage = [fxSqliteView stringFieldValue:6];
	imConversationEvent.mPicture = [fxSqliteView dataFieldValue:7];
	[fxSqliteView done];
	[imConversationEvent autorelease];
	return (imConversationEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent {
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectIMConversationSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqlite3 withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof) {
		FxIMConversationEvent* imConversationEvent = [[FxIMConversationEvent alloc] init];
		imConversationEvent.eventId = [fxSqliteView intFieldValue:0];
		imConversationEvent.dateTime = [fxSqliteView stringFieldValue:1];
		imConversationEvent.mServiceID = (FxIMServiceID)[fxSqliteView intFieldValue:2];
		imConversationEvent.mAccountID = [fxSqliteView stringFieldValue:3];
		imConversationEvent.mID = [fxSqliteView stringFieldValue:4];
		imConversationEvent.mName = [fxSqliteView stringFieldValue:5];
		imConversationEvent.mStatusMessage = [fxSqliteView stringFieldValue:6];
		imConversationEvent.mPicture = [fxSqliteView dataFieldValue:7];
		[eventArrays addObject:imConversationEvent];
		[imConversationEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	[eventArrays autorelease];
	return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent {
	NSInteger numEventUpdated = 0;
	FxIMConversationEvent* newIMConversationEvent = (FxIMConversationEvent *)newEvent;
	
    sqlite3_stmt* sqliteStmt = NULL;
	const char* unusedSqlStatementTail = NULL;
	const char* utf8SqlStatementEncoding = [kUpdateIMConversationSql cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger error = sqlite3_prepare_v2(mSqlite3, utf8SqlStatementEncoding, strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
	
	if (error != SQLITE_OK) {
		if (sqliteStmt) {
			sqlite3_free(sqliteStmt);
		}
		FxDbException* dbException = [FxDbException exceptionWithName:@"update IMConversation event"
															andReason:[NSString stringWithFormat:@"sqlite3 error = %d", error]];
		dbException.errorCode = error;
		@throw dbException;
	}
    else {
        // If binding object is nil; it will cause sqlite3_bind_xxx crash
        const char *dateTime = [newIMConversationEvent dateTime] ? [[newIMConversationEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 1, dateTime, strlen(dateTime), NULL);
		sqlite3_bind_int(sqliteStmt, 2, [newIMConversationEvent mServiceID]);
		const char *accountID = [newIMConversationEvent mAccountID] ? [[newIMConversationEvent mAccountID] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 3, accountID, strlen(accountID), NULL);
		const char *conversationID = [newIMConversationEvent mID] ? [[newIMConversationEvent mID] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 4, conversationID, strlen(conversationID), NULL);
		const char *conversationName = [newIMConversationEvent mName] ? [[newIMConversationEvent mName] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 5, conversationName, strlen(conversationName), NULL);
		const char *statusMessage = [newIMConversationEvent mStatusMessage] ? [[newIMConversationEvent mStatusMessage] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 6, statusMessage, strlen(statusMessage), NULL);
		NSData *picture = [newIMConversationEvent mPicture];
        picture = picture ? picture : [NSData data];
        sqlite3_bind_blob(sqliteStmt, 7, [picture bytes], [picture length], SQLITE_STATIC);
        sqlite3_bind_int(sqliteStmt, 8, [newIMConversationEvent eventId]);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"update IMConversation event"
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
	detailedCount.totalCount = [DAOFunction execScalar:mSqlite3 withSqlStatement:kCountIMConversationAllSql];
	
	[detailedCount autorelease];
	return (detailedCount);
}

- (void) dealloc {
	[super dealloc];
}

@end
