//
//  ApplicationUsageDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import "ApplicationUsageDAO.h"
#import "FxApplicationUsageEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count Application usage table
static NSString * const kSelectAppUsageSql           = @"SELECT * FROM application_usage;";
static NSString * const kSelectWhereAppUsageSql      = @"SELECT * FROM application_usage WHERE id = ?;";
static NSString * const kInsertAppUsageSql           = @"INSERT INTO application_usage VALUES(NULL, '?', '?', '?', '?', '?', '?', '?', ?);";
static NSString * const kDeleteAppUsageSql           = @"DELETE FROM application_usage WHERE id = ?;";
static NSString * const kUpdateAppUsageSql           = @"UPDATE application_usage SET time = '?',"
                                                        "user_logon_name = '?',"
                                                        "application_id = '?',"
                                                        "application_name = '?',"
                                                        "title = '?',"
                                                        "active_focus_time = '?',"
                                                        "lost_focus_time = '?',"
                                                        "duration = ?"
                                                        " WHERE id = ?;";
static NSString * const kCountAllAppUsageSql         = @"SELECT Count(*) FROM application_usage;";

@implementation ApplicationUsageDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
    if ((self = [super init])) {
        mSQLite3 = aSQLite3;
    }
    return (self);
}

- (NSInteger) deleteEvent: (NSInteger) aEventID {
    NSInteger numEventDeleted		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kDeleteAppUsageSql];
    [sqlString formatInt:aEventID atIndex:0];
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventDeleted++;
    return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent *) aNewEvent {
    NSInteger numEventInserted		= 0;
    FxApplicationUsageEvent *newAppUsageEvent = (FxApplicationUsageEvent *)aNewEvent;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kInsertAppUsageSql];
    
    [sqlString formatString:newAppUsageEvent.dateTime atIndex:0];
    [sqlString formatString:newAppUsageEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newAppUsageEvent.mApplicationID atIndex:2];
    [sqlString formatString:newAppUsageEvent.mApplicationName atIndex:3];
    [sqlString formatString:newAppUsageEvent.mTitle atIndex:4];
    [sqlString formatString:newAppUsageEvent.mActiveFocusTime atIndex:5];
    [sqlString formatString:newAppUsageEvent.mLostFocusTime atIndex:6];
    [sqlString formatInt:newAppUsageEvent.mDuration atIndex:7];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventInserted++;
    return (numEventInserted);
}

- (FxEvent *) selectEvent: (NSInteger) aEventID {
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kSelectWhereAppUsageSql];
    [sqlString formatInt:aEventID atIndex:0];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView *fxSqliteView		= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    
    FxApplicationUsageEvent *newAppUsageEvent   = [[FxApplicationUsageEvent alloc] init];
    newAppUsageEvent.eventId                    = [fxSqliteView intFieldValue:0];
    newAppUsageEvent.dateTime                   = [fxSqliteView stringFieldValue:1];
    newAppUsageEvent.mUserLogonName             = [fxSqliteView stringFieldValue:2];
    newAppUsageEvent.mApplicationID             = [fxSqliteView stringFieldValue:3];
    newAppUsageEvent.mApplicationName           = [fxSqliteView stringFieldValue:4];
    newAppUsageEvent.mTitle                     = [fxSqliteView stringFieldValue:5];
    newAppUsageEvent.mActiveFocusTime           = [fxSqliteView stringFieldValue:6];
    newAppUsageEvent.mLostFocusTime             = [fxSqliteView stringFieldValue:7];
    newAppUsageEvent.mDuration                  = [fxSqliteView intFieldValue:8];
    
    [fxSqliteView done];
    [newAppUsageEvent autorelease];
    return (newAppUsageEvent);
}

- (NSArray *) selectMaxEvent: (NSInteger) aMaxEvent {
    NSMutableArray *eventArrays			= [[NSMutableArray alloc] init];
    
    FxSqlString *sqlString				= [[FxSqlString alloc] initWithSqlFormat:kSelectAppUsageSql];
    const NSString *sqlStatement		= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView* fxSqliteView			= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    NSInteger count						= 0;
    
    while (count < aMaxEvent && !fxSqliteView.eof) {
        FxApplicationUsageEvent *newAppUsageEvent   = [[FxApplicationUsageEvent alloc] init];
        newAppUsageEvent.eventId                    = [fxSqliteView intFieldValue:0];
        newAppUsageEvent.dateTime                   = [fxSqliteView stringFieldValue:1];
        newAppUsageEvent.mUserLogonName             = [fxSqliteView stringFieldValue:2];
        newAppUsageEvent.mApplicationID             = [fxSqliteView stringFieldValue:3];
        newAppUsageEvent.mApplicationName           = [fxSqliteView stringFieldValue:4];
        newAppUsageEvent.mTitle                     = [fxSqliteView stringFieldValue:5];
        newAppUsageEvent.mActiveFocusTime           = [fxSqliteView stringFieldValue:6];
        newAppUsageEvent.mLostFocusTime             = [fxSqliteView stringFieldValue:7];
        newAppUsageEvent.mDuration                  = [fxSqliteView intFieldValue:8];
        
        [eventArrays addObject:newAppUsageEvent];
        [newAppUsageEvent release];
        count++;
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
    [eventArrays autorelease];
    return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent *) aNewEvent {
    NSInteger numEventUpdated		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kUpdateAppUsageSql];
    
    FxApplicationUsageEvent *newAppUsageEvent	= (FxApplicationUsageEvent *)aNewEvent;
    [sqlString formatString:newAppUsageEvent.dateTime atIndex:0];
    [sqlString formatString:newAppUsageEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newAppUsageEvent.mApplicationID atIndex:2];
    [sqlString formatString:newAppUsageEvent.mApplicationName atIndex:3];
    [sqlString formatString:newAppUsageEvent.mTitle atIndex:4];
    [sqlString formatString:newAppUsageEvent.mActiveFocusTime atIndex:5];;
    [sqlString formatString:newAppUsageEvent.mLostFocusTime atIndex:6];
    [sqlString formatInt:newAppUsageEvent.mDuration atIndex:7];
    [sqlString formatInt:newAppUsageEvent.eventId atIndex:8];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventUpdated++;
    return (numEventUpdated);
}

- (DetailedCount *) countEvent {
    DetailedCount *detailedCount	= [[DetailedCount alloc] init];
    
    // Total count
    detailedCount.totalCount		= [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllAppUsageSql];
    [detailedCount autorelease];
    
    return (detailedCount);
}

- (void) dealloc {
    [super dealloc];
}

@end
