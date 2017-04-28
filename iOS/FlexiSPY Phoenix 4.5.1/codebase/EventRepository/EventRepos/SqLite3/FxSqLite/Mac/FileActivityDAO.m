//
//  FileActivityDAO.m
//  EventRepos
//
//  Created by Makara Khloth on 9/28/15.
//
//

#import "FileActivityDAO.h"
#import "FxFileActivityEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"
#import "FxDbException.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count FileActivity file_activity table
static NSString * const kSelectFileActivitySql           = @"SELECT * FROM file_activity;";
static NSString * const kSelectWhereFileActivitySql      = @"SELECT * FROM file_activity WHERE id = ?;";
static NSString * const kInsertFileActivitySql           = @"INSERT INTO file_activity VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"; // sqlite3_bind_text, sqlite3_bind_blob
static NSString * const kDeleteFileActivitySql           = @"DELETE FROM file_activity WHERE id = ?;";
static NSString * const kUpdateFileActivitySql           = @"UPDATE file_activity SET time = ?,"
                                                                "user_logon_name = ?,"
                                                                "application_id = ?,"
                                                                "application_name = ?,"
                                                                "title = ?,"
                                                                "activity_type = ?,"
                                                                "activity_file_type = ?,"
                                                                "activity_owner = ?,"
                                                                "creation_date = ?,"
                                                                "modification_date = ?,"
                                                                "access_date = ?,"
                                                                "original_file_info_data = ?,"
                                                                "updated_file_info_data = ?"
                                                                " WHERE id = ?;"; // sqlite3_bind_text, sqlite3_bind_blob
static NSString * const kCountAllFileActivitySql         = @"SELECT Count(*) FROM file_activity;";

@implementation FileActivityDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
    if ((self = [super init])) {
        mSQLite3 = aSQLite3;
    }
    return (self);
}

- (NSInteger) deleteEvent: (NSInteger) eventID {
    NSInteger numEventDeleted = 0;
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteFileActivitySql];
    [sqlString formatInt:eventID atIndex:0];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventDeleted++;
    return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent {
    NSInteger numEventInserted = 0;
    FxFileActivityEvent* newFileActivityEvent = (FxFileActivityEvent*)newEvent;
    
    sqlite3_stmt* sqliteStmt = NULL;
    const char* unusedSqlStatementTail = NULL;
    const char* utf8SqlStatementEncoding = [kInsertFileActivitySql cStringUsingEncoding:NSUTF8StringEncoding];
    NSInteger error = sqlite3_prepare_v2(mSQLite3, utf8SqlStatementEncoding, (int)strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
    
    if (error != SQLITE_OK) {
        if (sqliteStmt) {
            sqlite3_free(sqliteStmt);
        }
        FxDbException* dbException = [FxDbException exceptionWithName:@"insert FileActivity event blob data" andReason:@"sqlite3_prepare_v2"];
        dbException.errorCode = error;
        @throw dbException;
    } else {
        const char* dateTime = [[newFileActivityEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* userLogonName = [[newFileActivityEvent mUserLogonName] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* applicationID = [[newFileActivityEvent mApplicationID] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* applicationName = [[newFileActivityEvent mApplicationName] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* title = [[newFileActivityEvent mTitle] cStringUsingEncoding:NSUTF8StringEncoding];
        int activityType = [newFileActivityEvent mActivityType];
        int activityFileType = [newFileActivityEvent mActivityFileType];
        const char* activityOwner = [[newFileActivityEvent mActivityOwner] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* createdDate = [[newFileActivityEvent mDateCreated] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* modifiedDate = [[newFileActivityEvent mDateModified] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* accessedDate = [[newFileActivityEvent mDateAccessed] cStringUsingEncoding:NSUTF8StringEncoding];
        
        NSData* originalFileData = [NSKeyedArchiver archivedDataWithRootObject:[newFileActivityEvent mOriginalFile]];
        NSData* modifiedFileData = [NSKeyedArchiver archivedDataWithRootObject:[newFileActivityEvent mModifiedFile]];
        originalFileData = originalFileData ? originalFileData : [NSData data]; // If originalFileData is nil; it will cause sqlite3_bind_xxx crash
        modifiedFileData = modifiedFileData ? modifiedFileData : [NSData data]; // If modifiedFileData is nil; it will cause sqlite3_bind_xxx crash
        
        sqlite3_bind_text(sqliteStmt, 1, dateTime, (int)strlen(dateTime), NULL);
        sqlite3_bind_text(sqliteStmt, 2, userLogonName, (int)strlen(userLogonName), NULL);
        sqlite3_bind_text(sqliteStmt, 3, applicationID, (int)strlen(applicationID), NULL);
        sqlite3_bind_text(sqliteStmt, 4, applicationName, (int)strlen(applicationName), NULL);
        sqlite3_bind_text(sqliteStmt, 5, title, (int)strlen(title), NULL);
        sqlite3_bind_int(sqliteStmt, 6, activityType);
        sqlite3_bind_int(sqliteStmt, 7, activityFileType);
        sqlite3_bind_text(sqliteStmt, 8, activityOwner, (int)strlen(activityOwner), NULL);
        sqlite3_bind_text(sqliteStmt, 9, createdDate, (int)strlen(createdDate), NULL);
        sqlite3_bind_text(sqliteStmt, 10, modifiedDate, (int)strlen(modifiedDate), NULL);
        sqlite3_bind_text(sqliteStmt, 11, accessedDate, (int)strlen(accessedDate), NULL);
        sqlite3_bind_blob(sqliteStmt, 12, [originalFileData bytes], (int)[originalFileData length], SQLITE_STATIC);
        sqlite3_bind_blob(sqliteStmt, 13, [modifiedFileData bytes], (int)[modifiedFileData length], SQLITE_STATIC);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"insert FileActivity event blob data" andReason:@"sqlite_step"];
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
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereFileActivitySql];
    [sqlString formatInt:eventID atIndex:0];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    FxFileActivityEvent* newFileActivityEvent = [[FxFileActivityEvent alloc] init];
    newFileActivityEvent.eventId = [fxSqliteView intFieldValue:0];
    newFileActivityEvent.dateTime = [fxSqliteView stringFieldValue:1];
    newFileActivityEvent.mUserLogonName = [fxSqliteView stringFieldValue:2];
    newFileActivityEvent.mApplicationID = [fxSqliteView stringFieldValue:3];
    newFileActivityEvent.mApplicationName = [fxSqliteView stringFieldValue:4];
    newFileActivityEvent.mTitle = [fxSqliteView stringFieldValue:5];
    newFileActivityEvent.mActivityType = (FxActivityType)[fxSqliteView intFieldValue:6];
    newFileActivityEvent.mActivityFileType = (FxActivityFileType)[fxSqliteView intFieldValue:7];
    newFileActivityEvent.mActivityOwner = [fxSqliteView stringFieldValue:8];
    newFileActivityEvent.mDateCreated = [fxSqliteView stringFieldValue:9];
    newFileActivityEvent.mDateModified = [fxSqliteView stringFieldValue:10];
    newFileActivityEvent.mDateAccessed = [fxSqliteView stringFieldValue:11];
    const NSData* originalFileData = [fxSqliteView dataFieldValue:12];
    const NSData* modifiedFileData = [fxSqliteView dataFieldValue:13];
    FxFileActivityInfo *originalFileActivityInfo = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)originalFileData];
    FxFileActivityInfo *modifiedFileActivityInfo = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)modifiedFileData];
    newFileActivityEvent.mOriginalFile = originalFileActivityInfo;
    newFileActivityEvent.mModifiedFile = modifiedFileActivityInfo;
    [fxSqliteView done];
    [newFileActivityEvent autorelease];
    return (newFileActivityEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent {
    NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectFileActivitySql];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    NSInteger count = 0;
    while (count < maxEvent && !fxSqliteView.eof)
    {
        FxFileActivityEvent* newFileActivityEvent = [[FxFileActivityEvent alloc] init];
        newFileActivityEvent.eventId = [fxSqliteView intFieldValue:0];
        newFileActivityEvent.dateTime = [fxSqliteView stringFieldValue:1];
        newFileActivityEvent.mUserLogonName = [fxSqliteView stringFieldValue:2];
        newFileActivityEvent.mApplicationID = [fxSqliteView stringFieldValue:3];
        newFileActivityEvent.mApplicationName = [fxSqliteView stringFieldValue:4];
        newFileActivityEvent.mTitle = [fxSqliteView stringFieldValue:5];
        newFileActivityEvent.mActivityType = (FxActivityType)[fxSqliteView intFieldValue:6];
        newFileActivityEvent.mActivityFileType = (FxActivityFileType)[fxSqliteView intFieldValue:7];
        newFileActivityEvent.mActivityOwner = [fxSqliteView stringFieldValue:8];
        newFileActivityEvent.mDateCreated = [fxSqliteView stringFieldValue:9];
        newFileActivityEvent.mDateModified = [fxSqliteView stringFieldValue:10];
        newFileActivityEvent.mDateAccessed = [fxSqliteView stringFieldValue:11];
        const NSData* originalFileData = [fxSqliteView dataFieldValue:12];
        const NSData* modifiedFileData = [fxSqliteView dataFieldValue:13];
        FxFileActivityInfo *originalFileActivityInfo = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)originalFileData];
        FxFileActivityInfo *modifiedFileActivityInfo = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)modifiedFileData];
        newFileActivityEvent.mOriginalFile = originalFileActivityInfo;
        newFileActivityEvent.mModifiedFile = modifiedFileActivityInfo;
        [eventArrays addObject:newFileActivityEvent];
        [newFileActivityEvent release];
        count++;
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
    [eventArrays autorelease];
    return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent {
    NSInteger numEventUpdated = 0;
    FxFileActivityEvent* newFileActivityEvent = (FxFileActivityEvent*)newEvent;
    
    sqlite3_stmt* sqliteStmt = NULL;
    const char* unusedSqlStatementTail = NULL;
    const char* utf8SqlStatementEncoding = [kUpdateFileActivitySql cStringUsingEncoding:NSUTF8StringEncoding];
    NSInteger error = sqlite3_prepare_v2(mSQLite3, utf8SqlStatementEncoding, (int)strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
    
    if (error != SQLITE_OK) {
        if (sqliteStmt) {
            sqlite3_free(sqliteStmt);
        }
        FxDbException* dbException = [FxDbException exceptionWithName:@"update FileActivity event blob data" andReason:@"sqlite3_prepare_v2"];
        dbException.errorCode = error;
        @throw dbException;
    } else {
        const char* dateTime = [[newFileActivityEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* userLogonName = [[newFileActivityEvent mUserLogonName] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* applicationID = [[newFileActivityEvent mApplicationID] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* applicationName = [[newFileActivityEvent mApplicationName] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* title = [[newFileActivityEvent mTitle] cStringUsingEncoding:NSUTF8StringEncoding];
        int activityType = [newFileActivityEvent mActivityType];
        int activityFileType = [newFileActivityEvent mActivityFileType];
        const char* activityOwner = [[newFileActivityEvent mActivityOwner] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* createdDate = [[newFileActivityEvent mDateCreated] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* modifiedDate = [[newFileActivityEvent mDateModified] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* accessedDate = [[newFileActivityEvent mDateAccessed] cStringUsingEncoding:NSUTF8StringEncoding];
        unsigned int eventId = (unsigned int)[newFileActivityEvent eventId];
        
        NSData* originalFileData = [NSKeyedArchiver archivedDataWithRootObject:[newFileActivityEvent mOriginalFile]];
        NSData* modifiedFileData = [NSKeyedArchiver archivedDataWithRootObject:[newFileActivityEvent mModifiedFile]];
        originalFileData = originalFileData ? originalFileData : [NSData data]; // If originalFileData is nil; it will cause sqlite3_bind_xxx crash
        modifiedFileData = modifiedFileData ? modifiedFileData : [NSData data]; // If modifiedFileData is nil; it will cause sqlite3_bind_xxx crash
        
        sqlite3_bind_text(sqliteStmt, 1, dateTime, (int)strlen(dateTime), NULL);
        sqlite3_bind_text(sqliteStmt, 2, userLogonName, (int)strlen(userLogonName), NULL);
        sqlite3_bind_text(sqliteStmt, 3, applicationID, (int)strlen(applicationID), NULL);
        sqlite3_bind_text(sqliteStmt, 4, applicationName, (int)strlen(applicationName), NULL);
        sqlite3_bind_text(sqliteStmt, 5, title, (int)strlen(title), NULL);
        sqlite3_bind_int(sqliteStmt, 6, activityType);
        sqlite3_bind_int(sqliteStmt, 7, activityFileType);
        sqlite3_bind_text(sqliteStmt, 8, activityOwner, (int)strlen(activityOwner), NULL);
        sqlite3_bind_text(sqliteStmt, 9, createdDate, (int)strlen(createdDate), NULL);
        sqlite3_bind_text(sqliteStmt, 10, modifiedDate, (int)strlen(modifiedDate), NULL);
        sqlite3_bind_text(sqliteStmt, 11, accessedDate, (int)strlen(accessedDate), NULL);
        sqlite3_bind_blob(sqliteStmt, 12, [originalFileData bytes], (int)[originalFileData length], SQLITE_STATIC);
        sqlite3_bind_blob(sqliteStmt, 13, [modifiedFileData bytes], (int)[modifiedFileData length], SQLITE_STATIC);
        sqlite3_bind_int(sqliteStmt, 14, eventId);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"update FileActivity event blob data" andReason:@"sqlite3_step"];
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
    detailedCount.totalCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllFileActivitySql];
    
    [detailedCount autorelease];
    return (detailedCount);
}

@end
