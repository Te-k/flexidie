//
//  ScreenshotDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 2/12/15.
//
//

#import "ScreenshotDAO.h"
#import "FxScreenshotEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count IM screenshot table
static NSString * const kSelectScreenshotSql           = @"SELECT * FROM screenshot;";
static NSString * const kSelectWhereScreenshotSql      = @"SELECT * FROM screenshot WHERE id = ?;";
static NSString * const kInsertScreenshotSql           = @"INSERT INTO screenshot VALUES(NULL, '?', '?', '?', '?', '?', ?, ?, '?');";
static NSString * const kDeleteScreenshotSql           = @"DELETE FROM screenshot WHERE id = ?;";
static NSString * const kUpdateScreenshotSql           = @"UPDATE screenshot SET time = '?',"
                                                            "user_logon_name = '?',"
                                                            "application_id = '?',"
                                                            "application_name = '?',"
                                                            "title = '?',"
                                                            "calling_module = ?,"
                                                            "frame_id = ?,"
                                                            "screenshot_file_path = '?'"
                                                            " WHERE id = ?;";
static NSString * const kCountAllScreenshotSql         = @"SELECT Count(*) FROM screenshot;";

@implementation ScreenshotDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
    if ((self = [super init])) {
        mSQLite3 = aSQLite3;
    }
    return (self);
}

- (NSInteger) deleteEvent: (NSInteger) aEventID {
    NSInteger numEventDeleted		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kDeleteScreenshotSql];
    [sqlString formatInt:aEventID atIndex:0];
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventDeleted++;
    return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent *) aNewEvent {
    NSInteger numEventInserted		= 0;
    FxScreenshotEvent *newScreenshotEvent = (FxScreenshotEvent *)aNewEvent;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kInsertScreenshotSql];
    
    [sqlString formatString:newScreenshotEvent.dateTime atIndex:0];
    [sqlString formatString:newScreenshotEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newScreenshotEvent.mApplicationID atIndex:2];
    [sqlString formatString:newScreenshotEvent.mApplicationName atIndex:3];
    [sqlString formatString:newScreenshotEvent.mTitle atIndex:4];
    [sqlString formatInt:newScreenshotEvent.mCallingModule atIndex:5];
    [sqlString formatInt:newScreenshotEvent.mFrameID atIndex:6];
    [sqlString formatString:newScreenshotEvent.mScreenshotFilePath atIndex:7];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventInserted++;
    return (numEventInserted);
}

- (FxEvent *) selectEvent: (NSInteger) aEventID {
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kSelectWhereScreenshotSql];
    [sqlString formatInt:aEventID atIndex:0];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView *fxSqliteView		= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    
    FxScreenshotEvent *newScreenshotEvent          = [[FxScreenshotEvent alloc] init];
    newScreenshotEvent.eventId                     = [fxSqliteView intFieldValue:0];
    newScreenshotEvent.dateTime                    = [fxSqliteView stringFieldValue:1];
    newScreenshotEvent.mUserLogonName              = [fxSqliteView stringFieldValue:2];
    newScreenshotEvent.mApplicationID              = [fxSqliteView stringFieldValue:3];
    newScreenshotEvent.mApplicationName            = [fxSqliteView stringFieldValue:4];
    newScreenshotEvent.mTitle                      = [fxSqliteView stringFieldValue:5];
    newScreenshotEvent.mCallingModule              = (FxScreenshotCallingModule)[fxSqliteView intFieldValue:6];
    newScreenshotEvent.mFrameID                    = [fxSqliteView intFieldValue:7];
    newScreenshotEvent.mScreenshotFilePath         = [fxSqliteView stringFieldValue:8];
    
    [fxSqliteView done];
    [newScreenshotEvent autorelease];
    return (newScreenshotEvent);
}

- (NSArray *) selectMaxEvent: (NSInteger) aMaxEvent {
    NSMutableArray *eventArrays			= [[NSMutableArray alloc] init];
    
    FxSqlString *sqlString				= [[FxSqlString alloc] initWithSqlFormat:kSelectScreenshotSql];
    const NSString *sqlStatement		= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView* fxSqliteView			= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    NSInteger count						= 0;
    
    while (count < aMaxEvent && !fxSqliteView.eof) {
        FxScreenshotEvent *newScreenshotEvent             = [[FxScreenshotEvent alloc] init];
        newScreenshotEvent.eventId                     = [fxSqliteView intFieldValue:0];
        newScreenshotEvent.dateTime                    = [fxSqliteView stringFieldValue:1];
        newScreenshotEvent.mUserLogonName              = [fxSqliteView stringFieldValue:2];
        newScreenshotEvent.mApplicationID              = [fxSqliteView stringFieldValue:3];
        newScreenshotEvent.mApplicationName            = [fxSqliteView stringFieldValue:4];
        newScreenshotEvent.mTitle                      = [fxSqliteView stringFieldValue:5];
        newScreenshotEvent.mCallingModule              = (FxScreenshotCallingModule)[fxSqliteView intFieldValue:6];
        newScreenshotEvent.mFrameID                    = [fxSqliteView intFieldValue:7];
        newScreenshotEvent.mScreenshotFilePath         = [fxSqliteView stringFieldValue:8];
        
        [eventArrays addObject:newScreenshotEvent];
        [newScreenshotEvent release];
        count++;
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
    [eventArrays autorelease];
    return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent *) aNewEvent {
    NSInteger numEventUpdated		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kUpdateScreenshotSql];
    
    FxScreenshotEvent *newScreenshotEvent = (FxScreenshotEvent *)aNewEvent;
    [sqlString formatString:newScreenshotEvent.dateTime atIndex:0];
    [sqlString formatString:newScreenshotEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newScreenshotEvent.mApplicationID atIndex:2];
    [sqlString formatString:newScreenshotEvent.mApplicationName atIndex:3];
    [sqlString formatString:newScreenshotEvent.mTitle atIndex:4];
    [sqlString formatInt:newScreenshotEvent.mCallingModule atIndex:5];;
    [sqlString formatInt:newScreenshotEvent.mFrameID atIndex:6];
    [sqlString formatString:newScreenshotEvent.mScreenshotFilePath atIndex:7];
    [sqlString formatInt:newScreenshotEvent.eventId atIndex:8];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventUpdated++;
    return (numEventUpdated);
}

- (DetailedCount *) countEvent {
    DetailedCount *detailedCount	= [[DetailedCount alloc] init];
    
    // Total count
    detailedCount.totalCount		= [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllScreenshotSql];
    [detailedCount autorelease];
    
    return (detailedCount);
}

- (void) dealloc {
    [super dealloc];
}

@end
