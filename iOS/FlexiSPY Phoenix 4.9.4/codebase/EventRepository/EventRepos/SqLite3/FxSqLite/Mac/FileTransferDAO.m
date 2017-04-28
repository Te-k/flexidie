//
//  FileTransferDAO.m
//  FxSqLite
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import "FileTransferDAO.h"
#import "FxFileTransferEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count File transfer table
static NSString * const kSelectFileTransferSql           = @"SELECT * FROM file_transfer;";
static NSString * const kSelectWhereFileTransferSql      = @"SELECT * FROM file_transfer WHERE id = ?;";
static NSString * const kInsertFileTransferSql           = @"INSERT INTO file_transfer VALUES(NULL, '?', ?, '?', '?', '?', '?', ?, '?', '?', '?', ?);";
static NSString * const kDeleteFileTransferSql           = @"DELETE FROM file_transfer WHERE id = ?;";
static NSString * const kUpdateFileTransferSql           = @"UPDATE file_transfer SET time = '?',"
                                                                "direction = ?,"
                                                                "user_logon_name = '?',"
                                                                "application_id = '?',"
                                                                "application_name = '?',"
                                                                "title = '?',"
                                                                "transfer_type = ?,"
                                                                "source_path = '?',"
                                                                "destination_path = '?',"
                                                                "file_name = '?',"
                                                                "file_size = ?"
                                                                " WHERE id = ?;";
static NSString * const kCountAllFileTransferSql         = @"SELECT Count(*) FROM file_transfer;";
static NSString *const kCountDirectionFileTransferSql    = @"SELECT Count(*) FROM file_transfer WHERE direction = ?;";

@implementation FileTransferDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
    if ((self = [super init])) {
        mSQLite3 = aSQLite3;
    }
    return (self);
}

- (NSInteger) deleteEvent: (NSInteger) aEventID {
    NSInteger numEventDeleted		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kDeleteFileTransferSql];
    [sqlString formatInt:aEventID atIndex:0];
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventDeleted++;
    return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent *) aNewEvent {
    NSInteger numEventInserted		= 0;
    FxFileTransferEvent *newFileTransferEvent = (FxFileTransferEvent *)aNewEvent;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kInsertFileTransferSql];
    
    [sqlString formatString:newFileTransferEvent.dateTime atIndex:0];
    [sqlString formatInt:newFileTransferEvent.mDirection atIndex:1];
    [sqlString formatString:newFileTransferEvent.mUserLogonName atIndex:2];
    [sqlString formatString:newFileTransferEvent.mApplicationID atIndex:3];
    [sqlString formatString:newFileTransferEvent.mApplicationName atIndex:4];
    [sqlString formatString:newFileTransferEvent.mTitle atIndex:5];
    [sqlString formatInt:newFileTransferEvent.mTransferType atIndex:6];
    [sqlString formatString:newFileTransferEvent.mSourcePath atIndex:7];
    [sqlString formatString:newFileTransferEvent.mDestinationPath atIndex:8];
    [sqlString formatString:newFileTransferEvent.mFileName atIndex:9];
    [sqlString formatInt:newFileTransferEvent.mFileSize atIndex:10];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventInserted++;
    return (numEventInserted);
}

- (FxEvent *) selectEvent: (NSInteger) aEventID {
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kSelectWhereFileTransferSql];
    [sqlString formatInt:aEventID atIndex:0];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView *fxSqliteView		= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    
    FxFileTransferEvent *fileTransferEvent      = [[FxFileTransferEvent alloc] init];
    fileTransferEvent.eventId                   = [fxSqliteView intFieldValue:0];
    fileTransferEvent.dateTime                  = [fxSqliteView stringFieldValue:1];
    fileTransferEvent.mDirection                = (FxEventDirection)[fxSqliteView intFieldValue:2];
    fileTransferEvent.mUserLogonName            = [fxSqliteView stringFieldValue:3];
    fileTransferEvent.mApplicationID            = [fxSqliteView stringFieldValue:4];
    fileTransferEvent.mApplicationName          = [fxSqliteView stringFieldValue:5];
    fileTransferEvent.mTitle                    = [fxSqliteView stringFieldValue:6];
    fileTransferEvent.mTransferType             = (FxFileTransferType)[fxSqliteView intFieldValue:7];
    fileTransferEvent.mSourcePath               = [fxSqliteView stringFieldValue:8];
    fileTransferEvent.mDestinationPath          = [fxSqliteView stringFieldValue:9];
    fileTransferEvent.mFileName                 = [fxSqliteView stringFieldValue:10];
    fileTransferEvent.mFileSize                 = [fxSqliteView intFieldValue:11];
    
    [fxSqliteView done];
    [fileTransferEvent autorelease];
    return (fileTransferEvent);
}

- (NSArray *) selectMaxEvent: (NSInteger) aMaxEvent {
    NSMutableArray *eventArrays			= [[NSMutableArray alloc] init];
    
    FxSqlString *sqlString				= [[FxSqlString alloc] initWithSqlFormat:kSelectFileTransferSql];
    const NSString *sqlStatement		= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView* fxSqliteView			= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    NSInteger count						= 0;
    
    while (count < aMaxEvent && !fxSqliteView.eof) {
        FxFileTransferEvent *fileTransferEvent      = [[FxFileTransferEvent alloc] init];
        fileTransferEvent.eventId                   = [fxSqliteView intFieldValue:0];
        fileTransferEvent.dateTime                  = [fxSqliteView stringFieldValue:1];
        fileTransferEvent.mDirection                = (FxEventDirection)[fxSqliteView intFieldValue:2];
        fileTransferEvent.mUserLogonName            = [fxSqliteView stringFieldValue:3];
        fileTransferEvent.mApplicationID            = [fxSqliteView stringFieldValue:4];
        fileTransferEvent.mApplicationName          = [fxSqliteView stringFieldValue:5];
        fileTransferEvent.mTitle                    = [fxSqliteView stringFieldValue:6];
        fileTransferEvent.mTransferType             = (FxFileTransferType)[fxSqliteView intFieldValue:7];
        fileTransferEvent.mSourcePath               = [fxSqliteView stringFieldValue:8];
        fileTransferEvent.mDestinationPath          = [fxSqliteView stringFieldValue:9];
        fileTransferEvent.mFileName                 = [fxSqliteView stringFieldValue:10];
        fileTransferEvent.mFileSize                 = [fxSqliteView intFieldValue:11];
        
        [eventArrays addObject:fileTransferEvent];
        [fileTransferEvent release];
        count++;
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
    [eventArrays autorelease];
    return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent *) aNewEvent {
    NSInteger numEventUpdated		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kUpdateFileTransferSql];
    
    FxFileTransferEvent *fileTransferEvent	= (FxFileTransferEvent *)aNewEvent;
    [sqlString formatString:fileTransferEvent.dateTime atIndex:0];
    [sqlString formatInt:fileTransferEvent.mDirection atIndex:1];
    [sqlString formatString:fileTransferEvent.mUserLogonName atIndex:2];
    [sqlString formatString:fileTransferEvent.mApplicationID atIndex:3];
    [sqlString formatString:fileTransferEvent.mApplicationName atIndex:4];
    [sqlString formatString:fileTransferEvent.mTitle atIndex:5];
    [sqlString formatInt:fileTransferEvent.mTransferType atIndex:6];;
    [sqlString formatString:fileTransferEvent.mSourcePath atIndex:7];
    [sqlString formatString:fileTransferEvent.mDestinationPath atIndex:8];
    [sqlString formatString:fileTransferEvent.mFileName atIndex:9];
    [sqlString formatInt:fileTransferEvent.mFileSize atIndex:10];
    [sqlString formatInt:fileTransferEvent.eventId atIndex:11];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventUpdated++;
    return (numEventUpdated);
}

- (DetailedCount *) countEvent {
    DetailedCount *detailedCount	= [[DetailedCount alloc] init];
    
    // Total count
    detailedCount.totalCount		= [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllFileTransferSql];
    
    // In count
    FxSqlString* sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionFileTransferSql];
    [sqlString formatInt:kEventDirectionIn atIndex:0];
    NSString* sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    detailedCount.inCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
    
    // Out count
    sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionFileTransferSql];
    [sqlString formatInt:kEventDirectionOut atIndex:0];
    sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    detailedCount.outCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
    
    // Missed count
    sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionFileTransferSql];
    [sqlString formatInt:kEventDirectionMissedCall atIndex:0];
    sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    detailedCount.missedCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
    
    // Unknown count
    sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionFileTransferSql];
    [sqlString formatInt:kEventDirectionUnknown atIndex:0];
    sqlStatement = [sqlString finalizeSqlString];
    [sqlString release];
    detailedCount.unknownCount = [DAOFunction execScalar:mSQLite3 withSqlStatement:sqlStatement];
    
    // Local IM count
    sqlString = [[FxSqlString alloc] initWithSqlFormat:kCountDirectionFileTransferSql];
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
