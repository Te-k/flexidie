//
//  AppShotDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 4/26/16.
//
//

#import "AppScreenShotDAO.h"
#import "FxAppScreenShotEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

/*
 
 @"CREATE TABLE IF NOT EXISTS app_screen_shot (id INTEGER PRIMARY KEY AUTOINCREMENT,"
 "time TEXT NOT NULL,"
 "user_logon_name TEXT,"
 "application_id TEXT,"
 "application_name TEXT,"
 "title TEXT,"
 "app_category INTEGER,"
 "url TEXT,"
 "file_path TEXT,"
 "screen_category INTEGER);";
 
 */

// Select/Insert/Delete/Update/Count App screen shot table
static NSString * const kSelectAppScreenShotSql           = @"SELECT * FROM app_screen_shot;";
static NSString * const kSelectWhereAppScreenShotSql      = @"SELECT * FROM app_screen_shot WHERE id = ?;";
static NSString * const kInsertAppScreenShotSql           = @"INSERT INTO app_screen_shot VALUES(NULL, '?', '?', '?', '?', '?', ?, '?', '?', ?);";
static NSString * const kDeleteAppScreenShotSql           = @"DELETE FROM app_screen_shot WHERE id = ?;";
static NSString * const kUpdateAppScreenShotSql           = @"UPDATE app_screen_shot SET time = '?',"
                                                                "user_logon_name = '?',"
                                                                "application_id = '?',"
                                                                "application_name = '?',"
                                                                "title = '?',"
                                                                "app_category = ?,"
                                                                "url = '?',"
                                                                "file_path = '?',"
                                                                "screen_category = ?"
                                                                " WHERE id = ?;";
static NSString * const kCountAllAppScreenShotSql         = @"SELECT Count(*) FROM app_screen_shot;";

@implementation AppScreenShotDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
    if ((self = [super init])) {
        mSQLite3 = aSQLite3;
    }
    return (self);
}

- (NSInteger) deleteEvent: (NSInteger) aEventID {
    NSInteger numEventDeleted = 0;
    FxSqlString *sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteAppScreenShotSql];
    [sqlString formatInt:aEventID atIndex:0];
    const NSString *sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventDeleted++;
    return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent *) aNewEvent {
    NSInteger numEventInserted = 0;
    FxAppScreenShotEvent *newAppScreenShotEvent = (FxAppScreenShotEvent *)aNewEvent;
    FxSqlString *sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertAppScreenShotSql];
    
    [sqlString formatString:newAppScreenShotEvent.dateTime atIndex:0];
    [sqlString formatString:newAppScreenShotEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newAppScreenShotEvent.mApplicationID atIndex:2];
    [sqlString formatString:newAppScreenShotEvent.mApplicationName atIndex:3];
    [sqlString formatString:newAppScreenShotEvent.mTitle atIndex:4];
    [sqlString formatInt:newAppScreenShotEvent.mApplication_Catagory atIndex:5];
    [sqlString formatString:newAppScreenShotEvent.mUrl atIndex:6];
    [sqlString formatString:newAppScreenShotEvent.mScreenshotFilePath atIndex:7];
    [sqlString formatInt:newAppScreenShotEvent.mScreenshot_Category atIndex:8];
    
    const NSString *sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventInserted++;
    return (numEventInserted);
}

- (FxEvent *) selectEvent: (NSInteger) aEventID {
    FxSqlString *sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereAppScreenShotSql];
    [sqlString formatInt:aEventID atIndex:0];
    
    const NSString *sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView *fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    
    FxAppScreenShotEvent *newAppScreenShotEvent       = [[FxAppScreenShotEvent alloc] init];
    newAppScreenShotEvent.eventId                     = [fxSqliteView intFieldValue:0];
    newAppScreenShotEvent.dateTime                    = [fxSqliteView stringFieldValue:1];
    newAppScreenShotEvent.mUserLogonName              = [fxSqliteView stringFieldValue:2];
    newAppScreenShotEvent.mApplicationID              = [fxSqliteView stringFieldValue:3];
    newAppScreenShotEvent.mApplicationName            = [fxSqliteView stringFieldValue:4];
    newAppScreenShotEvent.mTitle                      = [fxSqliteView stringFieldValue:5];
    newAppScreenShotEvent.mApplication_Catagory       = [fxSqliteView intFieldValue:6];
    newAppScreenShotEvent.mUrl                        = [fxSqliteView stringFieldValue:7];
    newAppScreenShotEvent.mScreenshotFilePath         = [fxSqliteView stringFieldValue:8];
    newAppScreenShotEvent.mScreenshot_Category        = [fxSqliteView intFieldValue:9];
    
    [fxSqliteView done];
    [newAppScreenShotEvent autorelease];
    return (newAppScreenShotEvent);
}

- (NSArray *) selectMaxEvent: (NSInteger) aMaxEvent {
    NSMutableArray *eventArrays = [[NSMutableArray alloc] init];
    
    FxSqlString *sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectAppScreenShotSql];
    const NSString *sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    NSInteger count = 0;
    
    while (count < aMaxEvent && !fxSqliteView.eof) {
        FxAppScreenShotEvent *newAppScreenShotEvent       = [[FxAppScreenShotEvent alloc] init];
        newAppScreenShotEvent.eventId                     = [fxSqliteView intFieldValue:0];
        newAppScreenShotEvent.dateTime                    = [fxSqliteView stringFieldValue:1];
        newAppScreenShotEvent.mUserLogonName              = [fxSqliteView stringFieldValue:2];
        newAppScreenShotEvent.mApplicationID              = [fxSqliteView stringFieldValue:3];
        newAppScreenShotEvent.mApplicationName            = [fxSqliteView stringFieldValue:4];
        newAppScreenShotEvent.mTitle                      = [fxSqliteView stringFieldValue:5];
        newAppScreenShotEvent.mApplication_Catagory       = [fxSqliteView intFieldValue:6];
        newAppScreenShotEvent.mUrl                        = [fxSqliteView stringFieldValue:7];
        newAppScreenShotEvent.mScreenshotFilePath         = [fxSqliteView stringFieldValue:8];
        newAppScreenShotEvent.mScreenshot_Category        = [fxSqliteView intFieldValue:9];
        
        [eventArrays addObject:newAppScreenShotEvent];
        [newAppScreenShotEvent release];
        count++;
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
    [eventArrays autorelease];
    return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent *) aNewEvent {
    NSInteger numEventUpdated = 0;
    FxSqlString *sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateAppScreenShotSql];
    
    FxAppScreenShotEvent *newAppScreenShotEvent = (FxAppScreenShotEvent *)aNewEvent;
    [sqlString formatString:newAppScreenShotEvent.dateTime atIndex:0];
    [sqlString formatString:newAppScreenShotEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newAppScreenShotEvent.mApplicationID atIndex:2];
    [sqlString formatString:newAppScreenShotEvent.mApplicationName atIndex:3];
    [sqlString formatString:newAppScreenShotEvent.mTitle atIndex:4];
    [sqlString formatInt:newAppScreenShotEvent.mApplication_Catagory atIndex:5];;
    [sqlString formatString:newAppScreenShotEvent.mUrl atIndex:6];
    [sqlString formatString:newAppScreenShotEvent.mScreenshotFilePath atIndex:7];
    [sqlString formatInt:newAppScreenShotEvent.mScreenshot_Category atIndex:8];
    [sqlString formatInt:newAppScreenShotEvent.eventId atIndex:9];
    
    const NSString *sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventUpdated++;
    return (numEventUpdated);
}

- (DetailedCount *) countEvent {
    DetailedCount *detailedCount = [[DetailedCount alloc] init];
    
    // Total count
    detailedCount.totalCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllAppScreenShotSql];
    [detailedCount autorelease];
    
    return (detailedCount);
}

- (void) dealloc {
    [super dealloc];
}

@end
