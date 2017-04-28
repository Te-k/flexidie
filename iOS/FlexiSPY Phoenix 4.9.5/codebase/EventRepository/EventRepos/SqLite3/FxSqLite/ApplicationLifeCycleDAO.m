//
//  ApplicationLifeCycleDAO.m
//  EventRepos
//
//  Created by Makara Khloth on 9/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ApplicationLifeCycleDAO.h"
#import "FxApplicationLifeCycleEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"
#import "FxDbException.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count application_life_cycle (ALC) table
static NSString * const kSelectALCSql			= @"SELECT * FROM application_life_cycle;";
static NSString * const kSelectWhereALCSql		= @"SELECT * FROM application_life_cycle WHERE id = ?;";
// Used sqlite3_bind_text function that's why there is no single quote
static NSString * const kInsertALCSql			= @"INSERT INTO application_life_cycle VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
static NSString * const kDeleteALCSql			= @"DELETE FROM application_life_cycle WHERE id = ?;";
// Used sqlite3_bind_text function that's why there is no single quote
static NSString * const kUpdateALCSql			= @"UPDATE application_life_cycle SET time = ?,"
														"app_state = ?,"
														"app_type = ?,"
														"app_id = ?,"
														"app_name = ?,"
														"app_version = ?,"
														"app_size = ?,"
														"app_icon_type = ?,"
														"app_icon_data = ?"
														" WHERE id = ?;";
static NSString * const kCountAllALCSql			= @"SELECT Count(*) FROM application_life_cycle;";

@implementation ApplicationLifeCycleDAO

- (id) initWithSqlite3:(sqlite3 *) aNewSqlite3Database {
	if ((self = [super init])) {
		mSqliteDatabase = aNewSqlite3Database;
	}
	return (self);
}

// DataAccessObject
- (NSInteger) deleteEvent: (NSInteger) eventID {
	NSInteger numEventDeleted = 0;
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteALCSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	[DAOFunction execDML:mSqliteDatabase withSqlStatement:sqlStatement];
	numEventDeleted++;
	return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent {
	NSInteger numEventInserted = 0;
	FxApplicationLifeCycleEvent* newALCEvent = (FxApplicationLifeCycleEvent*)newEvent;
    
    sqlite3_stmt* sqliteStmt = NULL;
	const char* unusedSqlStatementTail = NULL;
	const char* utf8SqlStatementEncoding = [kInsertALCSql cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger error = sqlite3_prepare_v2(mSqliteDatabase, utf8SqlStatementEncoding, strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
	
	if (error != SQLITE_OK) {
		if (sqliteStmt) {
			sqlite3_free(sqliteStmt);
		}
		FxDbException* dbException = [FxDbException exceptionWithName:@"insertEvent prepare sql Application life cycle blob data" andReason:@""];
		dbException.errorCode = error;
		@throw dbException;
	}
    else {
        const char* dateTime = [newALCEvent dateTime] ? [[newALCEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 1, dateTime, strlen(dateTime), NULL);
		sqlite3_bind_int(sqliteStmt, 2, (int)[newALCEvent mAppState]);
		sqlite3_bind_int(sqliteStmt, 3, (int)[newALCEvent mAppType]);
		NSString *t1 = [newALCEvent mAppID] ? [newALCEvent mAppID] : @""; // If text is null cause application crash
		NSString *t2 = [newALCEvent mAppName] ? [newALCEvent mAppName] : @""; // If text is null cause application crash
		NSString *t3 = [newALCEvent mAppVersion] ? [newALCEvent mAppVersion] : @""; // If text is null cause application crash
		const char* appID = [t1 cStringUsingEncoding:NSUTF8StringEncoding];
		const char* appName = [t2 cStringUsingEncoding:NSUTF8StringEncoding];
		const char* appVersion = [t3 cStringUsingEncoding:NSUTF8StringEncoding];
		sqlite3_bind_text(sqliteStmt, 4, appID, strlen(appID), NULL);
		sqlite3_bind_text(sqliteStmt, 5, appName, strlen(appName), NULL);
		sqlite3_bind_text(sqliteStmt, 6, appVersion, strlen(appVersion), NULL);
		sqlite3_bind_int64(sqliteStmt, 7, (sqlite3_int64)[newALCEvent mAppSize]);
		sqlite3_bind_int(sqliteStmt, 8, (int)[newALCEvent mAppIconType]);
		NSData* appIconData = [newALCEvent mAppIconData];
        appIconData = appIconData ? appIconData : [NSData data];
        sqlite3_bind_blob(sqliteStmt, 9, [appIconData bytes], [appIconData length], SQLITE_STATIC);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"insertEvent execute sql Application life cycle blob data" andReason:@""];
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
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereALCSql];
	[sqlString formatInt:eventID atIndex:0];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqliteDatabase withSqlStatement:sqlStatement];
	FxApplicationLifeCycleEvent* newALCEvent = [[FxApplicationLifeCycleEvent alloc] init];
	newALCEvent.eventId = [fxSqliteView intFieldValue:0];
	newALCEvent.dateTime = [fxSqliteView stringFieldValue:1];
	newALCEvent.mAppState = (ALCState)[fxSqliteView intFieldValue:2];
	newALCEvent.mAppType = (ALCType)[fxSqliteView intFieldValue:3];
	newALCEvent.mAppID = [fxSqliteView stringFieldValue:4];
	newALCEvent.mAppName = [fxSqliteView stringFieldValue:5];
	newALCEvent.mAppVersion = [fxSqliteView stringFieldValue:6];
	newALCEvent.mAppSize = [fxSqliteView int64FieldValue:7];
	newALCEvent.mAppIconType = [fxSqliteView intFieldValue:8];
	newALCEvent.mAppIconData = [fxSqliteView dataFieldValue:9];
	[fxSqliteView done];
	return ([newALCEvent autorelease]);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent {
	NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
	FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectALCSql];
	const NSString* sqlStatement = [sqlString finalizeSqlString];
	[sqlString release];
	FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSqliteDatabase withSqlStatement:sqlStatement];
	NSInteger count = 0;
	while (count < maxEvent && !fxSqliteView.eof) {
		FxApplicationLifeCycleEvent* newALCEvent = [[FxApplicationLifeCycleEvent alloc] init];
		newALCEvent.eventId = [fxSqliteView intFieldValue:0];
		newALCEvent.dateTime = [fxSqliteView stringFieldValue:1];
		newALCEvent.mAppState = (ALCState)[fxSqliteView intFieldValue:2];
		newALCEvent.mAppType = (ALCType)[fxSqliteView intFieldValue:3];
		newALCEvent.mAppID = [fxSqliteView stringFieldValue:4];
		newALCEvent.mAppName = [fxSqliteView stringFieldValue:5];
		newALCEvent.mAppVersion = [fxSqliteView stringFieldValue:6];
		newALCEvent.mAppSize = [fxSqliteView int64FieldValue:7];
		newALCEvent.mAppIconType = [fxSqliteView intFieldValue:8];
		newALCEvent.mAppIconData = [fxSqliteView dataFieldValue:9];
		[eventArrays addObject:newALCEvent];
		[newALCEvent release];
		count++;
		[fxSqliteView nextRow];
	}
	[fxSqliteView done];
	return ([eventArrays autorelease]);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent {
	NSInteger numEventUpdated = 0;
	FxApplicationLifeCycleEvent* newALCEvent = (FxApplicationLifeCycleEvent*)newEvent;
	
    sqlite3_stmt* sqliteStmt = NULL;
	const char* unusedSqlStatementTail = NULL;
	const char* utf8SqlStatementEncoding = [kUpdateALCSql cStringUsingEncoding:NSUTF8StringEncoding];
	NSInteger error = sqlite3_prepare_v2(mSqliteDatabase, utf8SqlStatementEncoding, strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
	
	if (error != SQLITE_OK) {
		if (sqliteStmt) {
			sqlite3_free(sqliteStmt);
		}
		FxDbException* dbException = [FxDbException exceptionWithName:@"updateEvent prepare v2 Application life cycle blob data" andReason:@""];
		dbException.errorCode = error;
		@throw dbException;
	}
    else {
        const char* dateTime = [newALCEvent dateTime] ? [[newALCEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding] : "";
        sqlite3_bind_text(sqliteStmt, 1, dateTime, strlen(dateTime), NULL);
		sqlite3_bind_int(sqliteStmt, 2, (int)[newALCEvent mAppState]);
		sqlite3_bind_int(sqliteStmt, 3, (int)[newALCEvent mAppType]);
		NSString *t1 = [newALCEvent mAppID] ? [newALCEvent mAppID] : @""; // If text is null cause application crash
		NSString *t2 = [newALCEvent mAppName] ? [newALCEvent mAppName] : @""; // If text is null cause application crash
		NSString *t3 = [newALCEvent mAppVersion] ? [newALCEvent mAppVersion] : @""; // If text is null cause application crash
		const char* appID = [t1 cStringUsingEncoding:NSUTF8StringEncoding];
		const char* appName = [t2 cStringUsingEncoding:NSUTF8StringEncoding];
		const char* appVersion = [t3 cStringUsingEncoding:NSUTF8StringEncoding];
		sqlite3_bind_text(sqliteStmt, 4, appID, strlen(appID), NULL);
		sqlite3_bind_text(sqliteStmt, 5, appName, strlen(appName), NULL);
		sqlite3_bind_text(sqliteStmt, 6, appVersion, strlen(appVersion), NULL);
		sqlite3_bind_int64(sqliteStmt, 7, (sqlite3_int64)[newALCEvent mAppSize]);
		sqlite3_bind_int(sqliteStmt, 8, (int)[newALCEvent mAppIconType]);
		NSData* appIconData = [newALCEvent mAppIconData];
        appIconData = appIconData ? appIconData : [NSData data];
        sqlite3_bind_blob(sqliteStmt, 9, [appIconData bytes], [appIconData length], SQLITE_STATIC);
        sqlite3_bind_int(sqliteStmt, 10, [newALCEvent eventId]);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"updateEvent execute Application life cycle blob data" andReason:@""];
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
	detailedCount.totalCount = [DAOFunction execScalar:mSqliteDatabase withSqlStatement:kCountAllALCSql];
	
	return ([detailedCount autorelease]);
}

- (void) dealloc {
	[super dealloc];
}

@end
