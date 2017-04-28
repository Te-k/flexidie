//
//  NetworkTrafficDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 10/16/15.
//
//

#import "NetworkTrafficDAO.h"
#import "FxNetworkTrafficEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"
#import "FxDbException.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count NetworkTraffic network_traffic table
static NSString * const kSelectNetworkTrafficSql        = @"SELECT * FROM network_traffic;";
static NSString * const kSelectWhereNetworkTrafficSql   = @"SELECT * FROM network_traffic WHERE id = ?;";
static NSString * const kInsertNetworkTrafficSql        = @"INSERT INTO network_traffic VALUES(NULL, ?, ?, ?, ?, ?, ?, ?, ?);"; // sqlite3_bind_text, sqlite3_bind_blob
static NSString * const kDeleteNetworkTrafficSql        = @"DELETE FROM network_traffic WHERE id = ?;";
static NSString * const kUpdateNetworkTrafficSql        = @"UPDATE network_traffic SET time = ?,"
                                                                "user_logon_name = ?,"
                                                                "application_id = ?,"
                                                                "application_name = ?,"
                                                                "title = ?,"
                                                                "start_time = ?,"
                                                                "end_time = ?,"
                                                                "network_traffic_interface = ?"
                                                                " WHERE id = ?;"; // sqlite3_bind_text, sqlite3_bind_blob
static NSString * const kCountAllNetworkTrafficSql         = @"SELECT Count(*) FROM network_traffic;";

@implementation NetworkTrafficDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
    if ((self = [super init])) {
        mSQLite3 = aSQLite3;
    }
    return (self);
}

- (NSInteger) deleteEvent: (NSInteger) eventID {
    NSInteger numEventDeleted = 0;
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteNetworkTrafficSql];
    [sqlString formatInt:eventID atIndex:0];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventDeleted++;
    return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent {
    NSInteger numEventInserted = 0;
    FxNetworkTrafficEvent* newNetworkTrafficEvent = (FxNetworkTrafficEvent*)newEvent;
    
    sqlite3_stmt* sqliteStmt = NULL;
    const char* unusedSqlStatementTail = NULL;
    const char* utf8SqlStatementEncoding = [kInsertNetworkTrafficSql cStringUsingEncoding:NSUTF8StringEncoding];
    NSInteger error = sqlite3_prepare_v2(mSQLite3, utf8SqlStatementEncoding, (int)strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
    
    if (error != SQLITE_OK) {
        if (sqliteStmt) {
            sqlite3_free(sqliteStmt);
        }
        FxDbException* dbException = [FxDbException exceptionWithName:@"insert NetworkTraffic event blob data" andReason:@"sqlite3_prepare_v2"];
        dbException.errorCode = error;
        @throw dbException;
    } else {
        const char* dateTime = [[newNetworkTrafficEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* userLogonName = [[newNetworkTrafficEvent mUserLogonName] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* applicationID = [[newNetworkTrafficEvent mApplicationID] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* applicationName = [[newNetworkTrafficEvent mApplicationName] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* title = [[newNetworkTrafficEvent mTitle] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* startTime = [[newNetworkTrafficEvent mStartTime] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* endTime = [[newNetworkTrafficEvent mEndTime] cStringUsingEncoding:NSUTF8StringEncoding];
        
        NSData* networkInterfacesData = [NSKeyedArchiver archivedDataWithRootObject:[newNetworkTrafficEvent mNetworkInterfaces]];
        networkInterfacesData = networkInterfacesData ? networkInterfacesData : [NSData data]; // If networkInterfacesData is nil; it will cause sqlite3_bind_xxx crash
        
        sqlite3_bind_text(sqliteStmt, 1, dateTime, (int)strlen(dateTime), NULL);
        sqlite3_bind_text(sqliteStmt, 2, userLogonName, (int)strlen(userLogonName), NULL);
        sqlite3_bind_text(sqliteStmt, 3, applicationID, (int)strlen(applicationID), NULL);
        sqlite3_bind_text(sqliteStmt, 4, applicationName, (int)strlen(applicationName), NULL);
        sqlite3_bind_text(sqliteStmt, 5, title, (int)strlen(title), NULL);
        sqlite3_bind_text(sqliteStmt, 6, startTime, (int)strlen(startTime), NULL);
        sqlite3_bind_text(sqliteStmt, 7, endTime, (int)strlen(endTime), NULL);
        sqlite3_bind_blob(sqliteStmt, 8, [networkInterfacesData bytes], (int)[networkInterfacesData length], SQLITE_STATIC);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"insert NetworkTraffic event blob data" andReason:@"sqlite_step"];
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
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereNetworkTrafficSql];
    [sqlString formatInt:eventID atIndex:0];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    FxNetworkTrafficEvent* newNetworkTrafficEvent = [[FxNetworkTrafficEvent alloc] init];
    newNetworkTrafficEvent.eventId = [fxSqliteView intFieldValue:0];
    newNetworkTrafficEvent.dateTime = [fxSqliteView stringFieldValue:1];
    newNetworkTrafficEvent.mUserLogonName = [fxSqliteView stringFieldValue:2];
    newNetworkTrafficEvent.mApplicationID = [fxSqliteView stringFieldValue:3];
    newNetworkTrafficEvent.mApplicationName = [fxSqliteView stringFieldValue:4];
    newNetworkTrafficEvent.mTitle = [fxSqliteView stringFieldValue:5];
    newNetworkTrafficEvent.mStartTime = [fxSqliteView stringFieldValue:6];
    newNetworkTrafficEvent.mEndTime = [fxSqliteView stringFieldValue:7];
    const NSData* networkInterfacesData = [fxSqliteView dataFieldValue:8];
    NSArray *networkInterfaces = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)networkInterfacesData];
    newNetworkTrafficEvent.mNetworkInterfaces = networkInterfaces;
    [fxSqliteView done];
    [newNetworkTrafficEvent autorelease];
    return (newNetworkTrafficEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent {
    NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectNetworkTrafficSql];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    NSInteger count = 0;
    while (count < maxEvent && !fxSqliteView.eof)
    {
        FxNetworkTrafficEvent* newNetworkTrafficEvent = [[FxNetworkTrafficEvent alloc] init];
        newNetworkTrafficEvent.eventId = [fxSqliteView intFieldValue:0];
        newNetworkTrafficEvent.dateTime = [fxSqliteView stringFieldValue:1];
        newNetworkTrafficEvent.mUserLogonName = [fxSqliteView stringFieldValue:2];
        newNetworkTrafficEvent.mApplicationID = [fxSqliteView stringFieldValue:3];
        newNetworkTrafficEvent.mApplicationName = [fxSqliteView stringFieldValue:4];
        newNetworkTrafficEvent.mTitle = [fxSqliteView stringFieldValue:5];
        newNetworkTrafficEvent.mStartTime = [fxSqliteView stringFieldValue:6];
        newNetworkTrafficEvent.mEndTime = [fxSqliteView stringFieldValue:7];
        const NSData* networkInterfacesData = [fxSqliteView dataFieldValue:8];
        NSArray *networkInterfaces = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)networkInterfacesData];
        newNetworkTrafficEvent.mNetworkInterfaces = networkInterfaces;
        [eventArrays addObject:newNetworkTrafficEvent];
        [newNetworkTrafficEvent release];
        count++;
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
    [eventArrays autorelease];
    return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent {
    NSInteger numEventUpdated = 0;
    FxNetworkTrafficEvent* newNetworkTrafficEvent = (FxNetworkTrafficEvent*)newEvent;
    
    sqlite3_stmt* sqliteStmt = NULL;
    const char* unusedSqlStatementTail = NULL;
    const char* utf8SqlStatementEncoding = [kUpdateNetworkTrafficSql cStringUsingEncoding:NSUTF8StringEncoding];
    NSInteger error = sqlite3_prepare_v2(mSQLite3, utf8SqlStatementEncoding, (int)strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
    
    if (error != SQLITE_OK) {
        if (sqliteStmt) {
            sqlite3_free(sqliteStmt);
        }
        FxDbException* dbException = [FxDbException exceptionWithName:@"update NetworkTraffic event blob data" andReason:@"sqlite3_prepare_v2"];
        dbException.errorCode = error;
        @throw dbException;
    } else {
        const char* dateTime = [[newNetworkTrafficEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* userLogonName = [[newNetworkTrafficEvent mUserLogonName] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* applicationID = [[newNetworkTrafficEvent mApplicationID] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* applicationName = [[newNetworkTrafficEvent mApplicationName] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* title = [[newNetworkTrafficEvent mTitle] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* startTime = [[newNetworkTrafficEvent mStartTime] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* endTime = [[newNetworkTrafficEvent mEndTime] cStringUsingEncoding:NSUTF8StringEncoding];
        unsigned int eventId = (unsigned int)[newNetworkTrafficEvent eventId];
        
        NSData* networkInterfacesData = [NSKeyedArchiver archivedDataWithRootObject:[newNetworkTrafficEvent mNetworkInterfaces]];
        networkInterfacesData = networkInterfacesData ? networkInterfacesData : [NSData data]; // If networkInterfacesData is nil; it will cause sqlite3_bind_xxx crash
        
        sqlite3_bind_text(sqliteStmt, 1, dateTime, (int)strlen(dateTime), NULL);
        sqlite3_bind_text(sqliteStmt, 2, userLogonName, (int)strlen(userLogonName), NULL);
        sqlite3_bind_text(sqliteStmt, 3, applicationID, (int)strlen(applicationID), NULL);
        sqlite3_bind_text(sqliteStmt, 4, applicationName, (int)strlen(applicationName), NULL);
        sqlite3_bind_text(sqliteStmt, 5, title, (int)strlen(title), NULL);
        sqlite3_bind_text(sqliteStmt, 6, startTime, (int)strlen(startTime), NULL);
        sqlite3_bind_text(sqliteStmt, 7, endTime, (int)strlen(endTime), NULL);
        sqlite3_bind_blob(sqliteStmt, 8, [networkInterfacesData bytes], (int)[networkInterfacesData length], SQLITE_STATIC);
        sqlite3_bind_int(sqliteStmt, 9, eventId);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"update NetworkTraffic event blob data" andReason:@"sqlite3_step"];
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
    detailedCount.totalCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllNetworkTrafficSql];
    
    [detailedCount autorelease];
    return (detailedCount);
}

@end
