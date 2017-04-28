//
//  VoIPCallTagDAO.m
//  EventRepos
//
//  Created by Makara Khloth on 10/10/16.
//
//

#import "VoIPCallTagDAO.h"
#import "FxVoIPCallTag.h"
#import "DAOFunction.h"
#import "FxSqlString.h"
#import "FxSqliteView.h"
#import "FxDbException.h"

// Select/Insert/Delete/Update/Count voip call tag table
static const NSString* kSelectVoIPCallTagSql		= @"SELECT * FROM voip_call_tag;";
static const NSString* kSelectWhereVoIPCallTagSql	= @"SELECT * FROM voip_call_tag WHERE id = ?;";
static const NSString* kInsertVoIPCallTagSql		= @"INSERT INTO voip_call_tag VALUES(?, ?, ?, ?, ?, ?, ?, ?);";
static const NSString* kDeleteVoIPCallTagSql		= @"DELETE FROM voip_call_tag WHERE id = ?;";
static const NSString* kUpdateVoIPCallTagSql		= @"UPDATE voip_call_tag SET direction = ?,"
                                                            "duration = ?,"
                                                            "owner_number_addr = ?,"
                                                            "owner_name = ?,"
                                                            "recipients = ?,"
                                                            "category = ?,"
                                                            "is_monitor = ?"
                                                            " WHERE id = ?;";
static const NSString* kCountAllVoIPCallTagSql		= @"SELECT Count(*) FROM voip_call_tag;";


@implementation VoIPCallTagDAO

- (instancetype) initWithSqlite3: (sqlite3 *) aSQLite3 {
    if ((self = [super init])) {
        mSQLite3 = aSQLite3;
    }
    return (self);
}

- (NSInteger) deleteRow: (NSInteger) rowId {
    NSInteger numRowDeleted = 0;
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteVoIPCallTagSql];
    [sqlString formatInt:rowId atIndex:0];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numRowDeleted++;
    return (numRowDeleted);
}

- (NSInteger) insertRow: (id) row {
    NSInteger numRowInserted = 0;
    FxVoIPCallTag* newRow = row;
    
    sqlite3_stmt* sqliteStmt = NULL;
    const char* unusedSqlStatementTail = NULL;
    const char* utf8SqlStatementEncoding = [kInsertVoIPCallTagSql cStringUsingEncoding:NSUTF8StringEncoding];
    NSInteger error = sqlite3_prepare_v2(mSQLite3, utf8SqlStatementEncoding, (int)strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
    
    if (error != SQLITE_OK) {
        if (sqliteStmt) {
            sqlite3_free(sqliteStmt);
        }
        FxDbException* dbException = [FxDbException exceptionWithName:@"insert VoIPCallTag blob data" andReason:@"sqlite3_prepare_v2"];
        dbException.errorCode = error;
        @throw dbException;
    } else {
        sqlite3_int64 rowID     = newRow.dbId;
        int direction           = newRow.direction;
        int duration            = newRow.duration;
        const char *ownerID     = [newRow.ownerNumberAddr cStringUsingEncoding:NSUTF8StringEncoding];
        const char *ownerName   = [newRow.ownerName cStringUsingEncoding:NSUTF8StringEncoding];
        NSData *recipients      = [NSKeyedArchiver archivedDataWithRootObject:newRow.recipients];
        recipients              = recipients != nil ? recipients : [NSData data];
        int category            = newRow.category;
        int isMonitor           = newRow.isMonitor;
        
        sqlite3_bind_int64(sqliteStmt, 1, rowID);
        sqlite3_bind_int(sqliteStmt, 2, direction);
        sqlite3_bind_int(sqliteStmt, 3, duration);
        sqlite3_bind_text(sqliteStmt, 4, ownerID, (int)strlen(ownerID), NULL);
        sqlite3_bind_text(sqliteStmt, 5, ownerName, (int)strlen(ownerName), NULL);
        sqlite3_bind_blob(sqliteStmt, 6, recipients.bytes, (int)recipients.length, SQLITE_STATIC);
        sqlite3_bind_int(sqliteStmt, 7, category);
        sqlite3_bind_int(sqliteStmt, 8, isMonitor);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"insert VoIPCallTag blob data" andReason:@"sqlite_step"];
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
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereVoIPCallTagSql];
    [sqlString formatInt:rowId atIndex:0];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    FxVoIPCallTag* newRow = nil;
    if (!fxSqliteView.eof) {
        newRow                  = [[FxVoIPCallTag alloc] init];
        newRow.dbId             = [fxSqliteView int64FieldValue:0];
        newRow.direction        = (FxEventDirection)[fxSqliteView intFieldValue:1];
        newRow.duration         = [fxSqliteView intFieldValue:2];
        newRow.ownerNumberAddr  = [fxSqliteView stringFieldValue:3];
        newRow.ownerName        = [fxSqliteView stringFieldValue:4];
        NSData *recipients      = [fxSqliteView dataFieldValue:5];
        newRow.recipients       = [NSKeyedUnarchiver unarchiveObjectWithData:recipients];
        newRow.category         = (FxVoIPCategory)[fxSqliteView intFieldValue:6];
        newRow.isMonitor        = (FxVoIPMonitor)[fxSqliteView intFieldValue:7];
        [newRow autorelease];
    }
    [fxSqliteView done];
    return (newRow);
}

- (NSArray*) selectMaxRow: (NSInteger) maxRow {
    NSMutableArray* rowArrays = [[NSMutableArray alloc] init];
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectVoIPCallTagSql];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    NSInteger count = 0;
    while (count < maxRow && !fxSqliteView.eof) {
        FxVoIPCallTag* newRow   = [[FxVoIPCallTag alloc] init];
        newRow.dbId             = [fxSqliteView int64FieldValue:0];
        newRow.direction        = (FxEventDirection)[fxSqliteView intFieldValue:1];
        newRow.duration         = [fxSqliteView intFieldValue:2];
        newRow.ownerNumberAddr  = [fxSqliteView stringFieldValue:3];
        newRow.ownerName        = [fxSqliteView stringFieldValue:4];
        NSData *recipients      = [fxSqliteView dataFieldValue:5];
        newRow.recipients       = [NSKeyedUnarchiver unarchiveObjectWithData:recipients];
        newRow.category         = (FxVoIPCategory)[fxSqliteView intFieldValue:6];
        newRow.isMonitor        = (FxVoIPMonitor)[fxSqliteView intFieldValue:7];
        [rowArrays addObject:newRow];
        [newRow release];
        count++;
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
    [rowArrays autorelease];
    return (rowArrays);
}

- (NSInteger) updateRow: (id) row {
    NSInteger numRowUpdated = 0;
    FxVoIPCallTag* newRow = row;
    
    sqlite3_stmt* sqliteStmt = NULL;
    const char* unusedSqlStatementTail = NULL;
    const char* utf8SqlStatementEncoding = [kUpdateVoIPCallTagSql cStringUsingEncoding:NSUTF8StringEncoding];
    NSInteger error = sqlite3_prepare_v2(mSQLite3, utf8SqlStatementEncoding, (int)strlen(utf8SqlStatementEncoding), &sqliteStmt, &unusedSqlStatementTail);
    
    if (error != SQLITE_OK) {
        if (sqliteStmt) {
            sqlite3_free(sqliteStmt);
        }
        FxDbException* dbException = [FxDbException exceptionWithName:@"update VoIPCallTag blob data" andReason:@"sqlite3_prepare_v2"];
        dbException.errorCode = error;
        @throw dbException;
    } else {
        sqlite3_int64 rowID     = newRow.dbId;
        int direction           = newRow.direction;
        int duration            = newRow.duration;
        const char *ownerID     = [newRow.ownerNumberAddr cStringUsingEncoding:NSUTF8StringEncoding];
        const char *ownerName   = [newRow.ownerName cStringUsingEncoding:NSUTF8StringEncoding];
        NSData *recipients      = [NSKeyedArchiver archivedDataWithRootObject:newRow.recipients];
        recipients              = recipients != nil ? recipients : [NSData data];
        int category            = newRow.category;
        int isMonitor           = newRow.isMonitor;
        
        sqlite3_bind_int(sqliteStmt, 1, direction);
        sqlite3_bind_int(sqliteStmt, 2, duration);
        sqlite3_bind_text(sqliteStmt, 3, ownerID, (int)strlen(ownerID), NULL);
        sqlite3_bind_text(sqliteStmt, 4, ownerName, (int)strlen(ownerName), NULL);
        sqlite3_bind_blob(sqliteStmt, 5, recipients.bytes, (int)recipients.length, SQLITE_STATIC);
        sqlite3_bind_int(sqliteStmt, 6, category);
        sqlite3_bind_int(sqliteStmt, 7, isMonitor);
        sqlite3_bind_int64(sqliteStmt, 8, rowID);
        
        error = sqlite3_step(sqliteStmt);
        if (error != SQLITE_DONE) {
            FxDbException* dbException = [FxDbException exceptionWithName:@"update VoIPCallTag blob data" andReason:@"sqlite_step"];
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
    NSInteger rowCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllVoIPCallTagSql];
    return (rowCount);
}

@end
