//
//  LogonDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import "LogonDAO.h"
#import "FxLogonEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count Logon table
static NSString * const kSelectLogonSql           = @"SELECT * FROM logon;";
static NSString * const kSelectWhereLogonSql      = @"SELECT * FROM logon WHERE id = ?;";
static NSString * const kInsertLogonSql           = @"INSERT INTO logon VALUES(NULL, '?', '?', '?', '?', '?', ?);";
static NSString * const kDeleteLogonSql           = @"DELETE FROM logon WHERE id = ?;";
static NSString * const kUpdateLogonSql           = @"UPDATE logon SET time = '?',"
                                                        "user_logon_name = '?',"
                                                        "application_id = '?',"
                                                        "application_name = '?',"
                                                        "title = '?',"
                                                        "action = ?"
                                                        " WHERE id = ?;";
static NSString * const kCountAllLogonSql         = @"SELECT Count(*) FROM logon;";

@implementation LogonDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
    if ((self = [super init])) {
        mSQLite3 = aSQLite3;
    }
    return (self);
}

- (NSInteger) deleteEvent: (NSInteger) aEventID {
    NSInteger numEventDeleted		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kDeleteLogonSql];
    [sqlString formatInt:aEventID atIndex:0];
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventDeleted++;
    return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent *) aNewEvent {
    NSInteger numEventInserted		= 0;
    FxLogonEvent *newLogonEvent     = (FxLogonEvent *)aNewEvent;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kInsertLogonSql];
    
    [sqlString formatString:newLogonEvent.dateTime atIndex:0];
    [sqlString formatString:newLogonEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newLogonEvent.mApplicationID atIndex:2];
    [sqlString formatString:newLogonEvent.mApplicationName atIndex:3];
    [sqlString formatString:newLogonEvent.mTitle atIndex:4];
    [sqlString formatInt:newLogonEvent.mAction atIndex:5];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventInserted++;
    return (numEventInserted);
}

- (FxEvent *) selectEvent: (NSInteger) aEventID {
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kSelectWhereLogonSql];
    [sqlString formatInt:aEventID atIndex:0];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView *fxSqliteView		= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    
    FxLogonEvent *logonEvent              = [[FxLogonEvent alloc] init];
    logonEvent.eventId                    = [fxSqliteView intFieldValue:0];
    logonEvent.dateTime                   = [fxSqliteView stringFieldValue:1];
    logonEvent.mUserLogonName             = [fxSqliteView stringFieldValue:2];
    logonEvent.mApplicationID             = [fxSqliteView stringFieldValue:3];
    logonEvent.mApplicationName           = [fxSqliteView stringFieldValue:4];
    logonEvent.mTitle                     = [fxSqliteView stringFieldValue:5];
    logonEvent.mAction                    = (FxLogonAction)[fxSqliteView intFieldValue:6];
    
    [fxSqliteView done];
    [logonEvent autorelease];
    return (logonEvent);
}

- (NSArray *) selectMaxEvent: (NSInteger) aMaxEvent {
    NSMutableArray *eventArrays			= [[NSMutableArray alloc] init];
    
    FxSqlString *sqlString				= [[FxSqlString alloc] initWithSqlFormat:kSelectLogonSql];
    const NSString *sqlStatement		= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView* fxSqliteView			= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    NSInteger count						= 0;
    
    while (count < aMaxEvent && !fxSqliteView.eof) {
        FxLogonEvent *logonEvent              = [[FxLogonEvent alloc] init];
        logonEvent.eventId                    = [fxSqliteView intFieldValue:0];
        logonEvent.dateTime                   = [fxSqliteView stringFieldValue:1];
        logonEvent.mUserLogonName             = [fxSqliteView stringFieldValue:2];
        logonEvent.mApplicationID             = [fxSqliteView stringFieldValue:3];
        logonEvent.mApplicationName           = [fxSqliteView stringFieldValue:4];
        logonEvent.mTitle                     = [fxSqliteView stringFieldValue:5];
        logonEvent.mAction                    = (FxLogonAction)[fxSqliteView intFieldValue:6];
        
        [eventArrays addObject:logonEvent];
        [logonEvent release];
        count++;
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
    [eventArrays autorelease];
    return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent *) aNewEvent {
    NSInteger numEventUpdated		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kUpdateLogonSql];
    
    FxLogonEvent *newLogonEvent	= (FxLogonEvent *)aNewEvent;
    [sqlString formatString:newLogonEvent.dateTime atIndex:0];
    [sqlString formatString:newLogonEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newLogonEvent.mApplicationID atIndex:2];
    [sqlString formatString:newLogonEvent.mApplicationName atIndex:3];
    [sqlString formatString:newLogonEvent.mTitle atIndex:4];
    [sqlString formatInt:newLogonEvent.mAction atIndex:5];
    [sqlString formatInt:newLogonEvent.eventId atIndex:6];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventUpdated++;
    return (numEventUpdated);
}

- (DetailedCount *) countEvent {
    DetailedCount *detailedCount	= [[DetailedCount alloc] init];
    
    // Total count
    detailedCount.totalCount		= [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllLogonSql];
    [detailedCount autorelease];
    
    return (detailedCount);
}

- (void) dealloc {
    [super dealloc];
}

@end
