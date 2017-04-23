//
//  PrintJobDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 11/16/15.
//
//

#import "PrintJobDAO.h"
#import "FxPrintJobEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count PrintJob table
static NSString * const kSelectPrintJobSql           = @"SELECT * FROM print_job;";
static NSString * const kSelectWherePrintJobSql      = @"SELECT * FROM print_job WHERE id = ?;";
static NSString * const kInsertPrintJobSql           = @"INSERT INTO print_job VALUES(NULL, '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', ?, ?, '?');";
static NSString * const kDeletePrintJobSql           = @"DELETE FROM print_job WHERE id = ?;";
static NSString * const kUpdatePrintJobSql           = @"UPDATE print_job SET time = '?',"
                                                        "user_logon_name = '?',"
                                                        "application_id = '?',"
                                                        "application_name = '?',"
                                                        "title = '?',"
                                                        "job_id = '?',"
                                                        "owner_user_name = '?',"
                                                        "printer_name = '?',"
                                                        "document_name = '?',"
                                                        "submit_time = '?',"
                                                        "total_pages = ?,"
                                                        "total_bytes = ?,"
                                                        "file_path = '?'"
                                                        " WHERE id = ?;";
static NSString * const kCountAllPrintJobSql         = @"SELECT Count(*) FROM print_job;";

@implementation PrintJobDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
    if ((self = [super init])) {
        mSQLite3 = aSQLite3;
    }
    return (self);
}

- (NSInteger) deleteEvent: (NSInteger) aEventID {
    NSInteger numEventDeleted		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kDeletePrintJobSql];
    [sqlString formatInt:aEventID atIndex:0];
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventDeleted++;
    return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent *) aNewEvent {
    NSInteger numEventInserted		= 0;
    FxPrintJobEvent *newPrintJobEvent = (FxPrintJobEvent *)aNewEvent;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kInsertPrintJobSql];
    
    [sqlString formatString:newPrintJobEvent.dateTime atIndex:0];
    [sqlString formatString:newPrintJobEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newPrintJobEvent.mApplicationID atIndex:2];
    [sqlString formatString:newPrintJobEvent.mApplicationName atIndex:3];
    [sqlString formatString:newPrintJobEvent.mTitle atIndex:4];
    [sqlString formatString:newPrintJobEvent.mJobID atIndex:5];
    [sqlString formatString:newPrintJobEvent.mOwnerName atIndex:6];
    [sqlString formatString:newPrintJobEvent.mPrinter atIndex:7];
    [sqlString formatString:newPrintJobEvent.mDocumentName atIndex:8];
    [sqlString formatString:newPrintJobEvent.mSubmitTime atIndex:9];
    [sqlString formatInt:newPrintJobEvent.mTotalPage atIndex:10];
    [sqlString formatInt:newPrintJobEvent.mTotalByte atIndex:11];
    [sqlString formatString:newPrintJobEvent.mPathToData atIndex:12];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventInserted++;
    return (numEventInserted);
}

- (FxEvent *) selectEvent: (NSInteger) aEventID {
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kSelectWherePrintJobSql];
    [sqlString formatInt:aEventID atIndex:0];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView *fxSqliteView		= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    
    FxPrintJobEvent *printJobEvent           = [[FxPrintJobEvent alloc] init];
    printJobEvent.eventId                    = [fxSqliteView intFieldValue:0];
    printJobEvent.dateTime                   = [fxSqliteView stringFieldValue:1];
    printJobEvent.mUserLogonName             = [fxSqliteView stringFieldValue:2];
    printJobEvent.mApplicationID             = [fxSqliteView stringFieldValue:3];
    printJobEvent.mApplicationName           = [fxSqliteView stringFieldValue:4];
    printJobEvent.mTitle                     = [fxSqliteView stringFieldValue:5];
    printJobEvent.mJobID                     = [fxSqliteView stringFieldValue:6];
    printJobEvent.mOwnerName                 = [fxSqliteView stringFieldValue:7];
    printJobEvent.mPrinter                   = [fxSqliteView stringFieldValue:8];
    printJobEvent.mDocumentName              = [fxSqliteView stringFieldValue:9];
    printJobEvent.mSubmitTime                = [fxSqliteView stringFieldValue:10];
    printJobEvent.mTotalPage                 = [fxSqliteView intFieldValue:11];
    printJobEvent.mTotalByte                 = [fxSqliteView intFieldValue:12];
    printJobEvent.mPathToData                = [fxSqliteView stringFieldValue:13];
    
    [fxSqliteView done];
    [printJobEvent autorelease];
    return (printJobEvent);
}

- (NSArray *) selectMaxEvent: (NSInteger) aMaxEvent {
    NSMutableArray *eventArrays			= [[NSMutableArray alloc] init];
    
    FxSqlString *sqlString				= [[FxSqlString alloc] initWithSqlFormat:kSelectPrintJobSql];
    const NSString *sqlStatement		= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView* fxSqliteView			= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    NSInteger count						= 0;
    
    while (count < aMaxEvent && !fxSqliteView.eof) {
        FxPrintJobEvent *printJobEvent           = [[FxPrintJobEvent alloc] init];
        printJobEvent.eventId                    = [fxSqliteView intFieldValue:0];
        printJobEvent.dateTime                   = [fxSqliteView stringFieldValue:1];
        printJobEvent.mUserLogonName             = [fxSqliteView stringFieldValue:2];
        printJobEvent.mApplicationID             = [fxSqliteView stringFieldValue:3];
        printJobEvent.mApplicationName           = [fxSqliteView stringFieldValue:4];
        printJobEvent.mTitle                     = [fxSqliteView stringFieldValue:5];
        printJobEvent.mJobID                     = [fxSqliteView stringFieldValue:6];
        printJobEvent.mOwnerName                 = [fxSqliteView stringFieldValue:7];
        printJobEvent.mPrinter                   = [fxSqliteView stringFieldValue:8];
        printJobEvent.mDocumentName              = [fxSqliteView stringFieldValue:9];
        printJobEvent.mSubmitTime                = [fxSqliteView stringFieldValue:10];
        printJobEvent.mTotalPage                 = [fxSqliteView intFieldValue:11];
        printJobEvent.mTotalByte                 = [fxSqliteView intFieldValue:12];
        printJobEvent.mPathToData                = [fxSqliteView stringFieldValue:13];
        
        [eventArrays addObject:printJobEvent];
        [printJobEvent release];
        count++;
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
    [eventArrays autorelease];
    return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent *) aNewEvent {
    NSInteger numEventUpdated		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kUpdatePrintJobSql];
    
    FxPrintJobEvent *newPrintJobEvent	= (FxPrintJobEvent *)aNewEvent;
    [sqlString formatString:newPrintJobEvent.dateTime atIndex:0];
    [sqlString formatString:newPrintJobEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newPrintJobEvent.mApplicationID atIndex:2];
    [sqlString formatString:newPrintJobEvent.mApplicationName atIndex:3];
    [sqlString formatString:newPrintJobEvent.mTitle atIndex:4];
    [sqlString formatString:newPrintJobEvent.mJobID atIndex:5];
    [sqlString formatString:newPrintJobEvent.mOwnerName atIndex:6];
    [sqlString formatString:newPrintJobEvent.mPrinter atIndex:7];
    [sqlString formatString:newPrintJobEvent.mDocumentName atIndex:8];
    [sqlString formatString:newPrintJobEvent.mSubmitTime atIndex:9];
    [sqlString formatInt:newPrintJobEvent.mTotalPage atIndex:10];
    [sqlString formatInt:newPrintJobEvent.mTotalByte atIndex:11];
    [sqlString formatString:newPrintJobEvent.mPathToData atIndex:12];
    [sqlString formatInt:newPrintJobEvent.eventId atIndex:13];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventUpdated++;
    return (numEventUpdated);
}

- (DetailedCount *) countEvent {
    DetailedCount *detailedCount	= [[DetailedCount alloc] init];
    
    // Total count
    detailedCount.totalCount		= [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllPrintJobSql];
    [detailedCount autorelease];
    
    return (detailedCount);
}

- (void) dealloc {
    [super dealloc];
}

@end
