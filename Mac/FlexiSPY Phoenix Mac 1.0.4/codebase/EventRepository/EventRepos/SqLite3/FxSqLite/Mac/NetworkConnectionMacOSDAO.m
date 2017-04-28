//
//  NetworkConnectionMacOSDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 10/16/15.
//
//

#import "NetworkConnectionMacOSDAO.h"
#import "FxNetworkConnectionMacOSEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"
#import "FxDbException.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count NetworkConnection Mac network_connection_mac_os table
static NSString * const kSelectNetworkConnectionMacOSSql        = @"SELECT * FROM network_connection_mac_os;";
static NSString * const kSelectWhereNetworkConnectionMacOSSql   = @"SELECT * FROM network_connection_mac_os WHERE id = ?;";
static NSString * const kInsertNetworkConnectionMacOSSql        = @"INSERT INTO network_connection_mac_os VALUES(NULL, ?, ?, ?, ?, ?, ?, ?);"; // sqlite3_bind_text, sqlite3_bind_blob
static NSString * const kDeleteNetworkConnectionMacOSSql        = @"DELETE FROM network_connection_mac_os WHERE id = ?;";
static NSString * const kUpdateNetworkConnectionMacOSSql        = @"UPDATE network_connection_mac_os SET time = ?,"
                                                                        "user_logon_name = ?,"
                                                                        "application_id = ?,"
                                                                        "application_name = ?,"
                                                                        "title = ?,"
                                                                        "adapter = ?,"
                                                                        "adapter_status = ?"
                                                                        " WHERE id = ?;"; // sqlite3_bind_text, sqlite3_bind_blob
static NSString * const kCountAllNetworkConnectionMacOSSql      = @"SELECT Count(*) FROM network_connection_mac_os;";

@implementation NetworkConnectionMacOSDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
    if ((self = [super init])) {
        mSQLite3 = aSQLite3;
    }
    return (self);
}

- (NSInteger) deleteEvent: (NSInteger) eventID {
    NSInteger numEventDeleted = 0;
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteNetworkConnectionMacOSSql];
    [sqlString formatInt:eventID atIndex:0];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventDeleted++;
    return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent {
    NSInteger numEventInserted = 0;
    FxNetworkConnectionMacOSEvent* newNetworkConnectionMacOSEvent = (FxNetworkConnectionMacOSEvent*)newEvent;
    
    sqlite3_stmt* sqliteStmt = NULL;
    const char* unusedSqlStatementTail = NULL;
    const char* utf8SqlStatementEncoding = [kInsertNetworkConnectionMacOSSql cStringUsingEncoding:NSUTF8StringEncoding];
    NSInteger error = sqlite3_prepare_v2(mSQLite3, utf8SqlStatementEncoding, (int)strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
    
    if (error != SQLITE_OK) {
        if (sqliteStmt) {
            sqlite3_free(sqliteStmt);
        }
        FxDbException* dbException = [FxDbException exceptionWithName:@"insert NetworkConnection Mac event blob data" andReason:@"sqlite3_prepare_v2"];
        dbException.errorCode = error;
        @throw dbException;
    } else {
        const char* dateTime = [[newNetworkConnectionMacOSEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* userLogonName = [[newNetworkConnectionMacOSEvent mUserLogonName] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* applicationID = [[newNetworkConnectionMacOSEvent mApplicationID] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* applicationName = [[newNetworkConnectionMacOSEvent mApplicationName] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* title = [[newNetworkConnectionMacOSEvent mTitle] cStringUsingEncoding:NSUTF8StringEncoding];
        
        NSData* adapterData = [NSKeyedArchiver archivedDataWithRootObject:[newNetworkConnectionMacOSEvent mAdapter]];
        adapterData = adapterData ? adapterData : [NSData data]; // If adapterData is nil; it will cause sqlite3_bind_xxx crash
        NSData* adapterStatusData = [NSKeyedArchiver archivedDataWithRootObject:[newNetworkConnectionMacOSEvent mAdapterStatus]];
        adapterStatusData = adapterStatusData ? adapterStatusData : [NSData data]; // If adapterStatusData is nil; it will cause sqlite3_bind_xxx crash
        
        sqlite3_bind_text(sqliteStmt, 1, dateTime, (int)strlen(dateTime), NULL);
        sqlite3_bind_text(sqliteStmt, 2, userLogonName, (int)strlen(userLogonName), NULL);
        sqlite3_bind_text(sqliteStmt, 3, applicationID, (int)strlen(applicationID), NULL);
        sqlite3_bind_text(sqliteStmt, 4, applicationName, (int)strlen(applicationName), NULL);
        sqlite3_bind_text(sqliteStmt, 5, title, (int)strlen(title), NULL);
        sqlite3_bind_blob(sqliteStmt, 6, [adapterData bytes], (int)[adapterData length], SQLITE_STATIC);
        sqlite3_bind_blob(sqliteStmt, 7, [adapterStatusData bytes], (int)[adapterStatusData length], SQLITE_STATIC);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"insert NetworkConnection Mac event blob data" andReason:@"sqlite_step"];
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
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereNetworkConnectionMacOSSql];
    [sqlString formatInt:eventID atIndex:0];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    FxNetworkConnectionMacOSEvent* newNetworkConnectionMacOSEvent = [[FxNetworkConnectionMacOSEvent alloc] init];
    newNetworkConnectionMacOSEvent.eventId = [fxSqliteView intFieldValue:0];
    newNetworkConnectionMacOSEvent.dateTime = [fxSqliteView stringFieldValue:1];
    newNetworkConnectionMacOSEvent.mUserLogonName = [fxSqliteView stringFieldValue:2];
    newNetworkConnectionMacOSEvent.mApplicationID = [fxSqliteView stringFieldValue:3];
    newNetworkConnectionMacOSEvent.mApplicationName = [fxSqliteView stringFieldValue:4];
    newNetworkConnectionMacOSEvent.mTitle = [fxSqliteView stringFieldValue:5];
    const NSData* adapterData = [fxSqliteView dataFieldValue:6];
    FxNetworkAdapter *adapter = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)adapterData];
    newNetworkConnectionMacOSEvent.mAdapter = adapter;
    const NSData* adapterStatusData = [fxSqliteView dataFieldValue:7];
    FxNetworkAdapterStatus *adapterStatus = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)adapterStatusData];
    newNetworkConnectionMacOSEvent.mAdapterStatus = adapterStatus;
    [fxSqliteView done];
    [newNetworkConnectionMacOSEvent autorelease];
    return (newNetworkConnectionMacOSEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent {
    NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectNetworkConnectionMacOSSql];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    NSInteger count = 0;
    while (count < maxEvent && !fxSqliteView.eof)
    {
        FxNetworkConnectionMacOSEvent* newNetworkConnectionMacOSEvent = [[FxNetworkConnectionMacOSEvent alloc] init];
        newNetworkConnectionMacOSEvent.eventId = [fxSqliteView intFieldValue:0];
        newNetworkConnectionMacOSEvent.dateTime = [fxSqliteView stringFieldValue:1];
        newNetworkConnectionMacOSEvent.mUserLogonName = [fxSqliteView stringFieldValue:2];
        newNetworkConnectionMacOSEvent.mApplicationID = [fxSqliteView stringFieldValue:3];
        newNetworkConnectionMacOSEvent.mApplicationName = [fxSqliteView stringFieldValue:4];
        newNetworkConnectionMacOSEvent.mTitle = [fxSqliteView stringFieldValue:5];
        const NSData* adapterData = [fxSqliteView dataFieldValue:6];
        FxNetworkAdapter *adapter = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)adapterData];
        newNetworkConnectionMacOSEvent.mAdapter = adapter;
        const NSData* adapterStatusData = [fxSqliteView dataFieldValue:7];
        FxNetworkAdapterStatus *adapterStatus = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)adapterStatusData];
        newNetworkConnectionMacOSEvent.mAdapterStatus = adapterStatus;
        [eventArrays addObject:newNetworkConnectionMacOSEvent];
        [newNetworkConnectionMacOSEvent release];
        count++;
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
    [eventArrays autorelease];
    return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent {
    NSInteger numEventUpdated = 0;
    FxNetworkConnectionMacOSEvent* newNetworkConnectionMacOSEvent = (FxNetworkConnectionMacOSEvent*)newEvent;
    
    sqlite3_stmt* sqliteStmt = NULL;
    const char* unusedSqlStatementTail = NULL;
    const char* utf8SqlStatementEncoding = [kUpdateNetworkConnectionMacOSSql cStringUsingEncoding:NSUTF8StringEncoding];
    NSInteger error = sqlite3_prepare_v2(mSQLite3, utf8SqlStatementEncoding, (int)strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
    
    if (error != SQLITE_OK) {
        if (sqliteStmt) {
            sqlite3_free(sqliteStmt);
        }
        FxDbException* dbException = [FxDbException exceptionWithName:@"update NetworkConnection Mac event blob data" andReason:@"sqlite3_prepare_v2"];
        dbException.errorCode = error;
        @throw dbException;
    } else {
        const char* dateTime = [[newNetworkConnectionMacOSEvent dateTime] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* userLogonName = [[newNetworkConnectionMacOSEvent mUserLogonName] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* applicationID = [[newNetworkConnectionMacOSEvent mApplicationID] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* applicationName = [[newNetworkConnectionMacOSEvent mApplicationName] cStringUsingEncoding:NSUTF8StringEncoding];
        const char* title = [[newNetworkConnectionMacOSEvent mTitle] cStringUsingEncoding:NSUTF8StringEncoding];
        unsigned int eventId = (unsigned int)[newNetworkConnectionMacOSEvent eventId];
        
        NSData* adapterData = [NSKeyedArchiver archivedDataWithRootObject:[newNetworkConnectionMacOSEvent mAdapter]];
        adapterData = adapterData ? adapterData : [NSData data]; // If adapterData is nil; it will cause sqlite3_bind_xxx crash
        NSData* adapterStatusData = [NSKeyedArchiver archivedDataWithRootObject:[newNetworkConnectionMacOSEvent mAdapterStatus]];
        adapterStatusData = adapterStatusData ? adapterStatusData : [NSData data]; // If adapterStatusData is nil; it will cause sqlite3_bind_xxx crash
        
        sqlite3_bind_text(sqliteStmt, 1, dateTime, (int)strlen(dateTime), NULL);
        sqlite3_bind_text(sqliteStmt, 2, userLogonName, (int)strlen(userLogonName), NULL);
        sqlite3_bind_text(sqliteStmt, 3, applicationID, (int)strlen(applicationID), NULL);
        sqlite3_bind_text(sqliteStmt, 4, applicationName, (int)strlen(applicationName), NULL);
        sqlite3_bind_text(sqliteStmt, 5, title, (int)strlen(title), NULL);
        sqlite3_bind_blob(sqliteStmt, 6, [adapterData bytes], (int)[adapterData length], SQLITE_STATIC);
        sqlite3_bind_blob(sqliteStmt, 7, [adapterStatusData bytes], (int)[adapterStatusData length], SQLITE_STATIC);
        sqlite3_bind_int(sqliteStmt, 8, eventId);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"update NetworkConnection Mac event blob data" andReason:@"sqlite3_step"];
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
    detailedCount.totalCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllNetworkConnectionMacOSSql];
    
    [detailedCount autorelease];
    return (detailedCount);
}

@end
