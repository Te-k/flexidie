//
//  UsbConnectionDAO.m
//  EventRepos
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import "UsbConnectionDAO.h"
#import "FxUSBConnectionEvent.h"
#import "FxSqlString.h"
#import "DAOFunction.h"
#import "FxSqliteView.h"
#import "DetailedCount.h"

#import <sqlite3.h>

// Select/Insert/Delete/Update/Count Usb connection table
static NSString * const kSelectUsbConnSql           = @"SELECT * FROM usb_connection;";
static NSString * const kSelectWhereUsbConnSql      = @"SELECT * FROM usb_connection WHERE id = ?;";
static NSString * const kInsertUsbConnSql           = @"INSERT INTO usb_connection VALUES(NULL, '?', '?', '?', '?', '?', ?, ?, '?');";
static NSString * const kDeleteUsbConnSql           = @"DELETE FROM usb_connection WHERE id = ?;";
static NSString * const kUpdateUsbConnSql           = @"UPDATE usb_connection SET time = '?',"
                                                        "user_logon_name = '?',"
                                                        "application_id = '?',"
                                                        "application_name = '?',"
                                                        "title = '?',"
                                                        "action = ?,"
                                                        "usb_device_type = ?,"
                                                        "drive_name = '?'"
                                                        " WHERE id = ?;";
static NSString * const kCountAllUsbConnSql         = @"SELECT Count(*) FROM usb_connection;";

@implementation UsbConnectionDAO

- (id) initWithSQLite3: (sqlite3 *) aSQLite3 {
    if ((self = [super init])) {
        mSQLite3 = aSQLite3;
    }
    return (self);
}

- (NSInteger) deleteEvent: (NSInteger) aEventID {
    NSInteger numEventDeleted		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kDeleteUsbConnSql];
    [sqlString formatInt:aEventID atIndex:0];
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventDeleted++;
    return (numEventDeleted);
}

- (NSInteger) insertEvent: (FxEvent *) aNewEvent {
    NSInteger numEventInserted		= 0;
    FxUSBConnectionEvent *newUsbConnEvent = (FxUSBConnectionEvent *)aNewEvent;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kInsertUsbConnSql];
    
    [sqlString formatString:newUsbConnEvent.dateTime atIndex:0];
    [sqlString formatString:newUsbConnEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newUsbConnEvent.mApplicationID atIndex:2];
    [sqlString formatString:newUsbConnEvent.mApplicationName atIndex:3];
    [sqlString formatString:newUsbConnEvent.mTitle atIndex:4];
    [sqlString formatInt:newUsbConnEvent.mAction atIndex:5];
    [sqlString formatInt:newUsbConnEvent.mDeviceType atIndex:6];
    [sqlString formatString:newUsbConnEvent.mDriveName atIndex:7];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventInserted++;
    return (numEventInserted);
}

- (FxEvent *) selectEvent: (NSInteger) aEventID {
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kSelectWhereUsbConnSql];
    [sqlString formatInt:aEventID atIndex:0];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView *fxSqliteView		= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    
    FxUSBConnectionEvent *usbConnEvent      = [[FxUSBConnectionEvent alloc] init];
    usbConnEvent.eventId                    = [fxSqliteView intFieldValue:0];
    usbConnEvent.dateTime                   = [fxSqliteView stringFieldValue:1];
    usbConnEvent.mUserLogonName             = [fxSqliteView stringFieldValue:2];
    usbConnEvent.mApplicationID             = [fxSqliteView stringFieldValue:3];
    usbConnEvent.mApplicationName           = [fxSqliteView stringFieldValue:4];
    usbConnEvent.mTitle                     = [fxSqliteView stringFieldValue:5];
    usbConnEvent.mAction                    = (FxUSBConnectionAction)[fxSqliteView intFieldValue:6];
    usbConnEvent.mDeviceType                = (FxUSBConnectionType)[fxSqliteView intFieldValue:7];
    usbConnEvent.mDriveName                 = [fxSqliteView stringFieldValue:8];
    
    [fxSqliteView done];
    [usbConnEvent autorelease];
    return (usbConnEvent);
}

- (NSArray *) selectMaxEvent: (NSInteger) aMaxEvent {
    NSMutableArray *eventArrays			= [[NSMutableArray alloc] init];
    
    FxSqlString *sqlString				= [[FxSqlString alloc] initWithSqlFormat:kSelectUsbConnSql];
    const NSString *sqlStatement		= [sqlString finalizeSqlString];
    [sqlString release];
    
    FxSqliteView* fxSqliteView			= [DAOFunction execQuery:mSQLite3 withSqlStatement:sqlStatement];
    NSInteger count						= 0;
    
    while (count < aMaxEvent && !fxSqliteView.eof) {
        FxUSBConnectionEvent *usbConnEvent      = [[FxUSBConnectionEvent alloc] init];
        usbConnEvent.eventId                    = [fxSqliteView intFieldValue:0];
        usbConnEvent.dateTime                   = [fxSqliteView stringFieldValue:1];
        usbConnEvent.mUserLogonName             = [fxSqliteView stringFieldValue:2];
        usbConnEvent.mApplicationID             = [fxSqliteView stringFieldValue:3];
        usbConnEvent.mApplicationName           = [fxSqliteView stringFieldValue:4];
        usbConnEvent.mTitle                     = [fxSqliteView stringFieldValue:5];
        usbConnEvent.mAction                    = (FxUSBConnectionAction)[fxSqliteView intFieldValue:6];
        usbConnEvent.mDeviceType                = (FxUSBConnectionType)[fxSqliteView intFieldValue:7];
        usbConnEvent.mDriveName                 = [fxSqliteView stringFieldValue:8];
        
        [eventArrays addObject:usbConnEvent];
        [usbConnEvent release];
        count++;
        [fxSqliteView nextRow];
    }
    [fxSqliteView done];
    [eventArrays autorelease];
    return (eventArrays);
}

- (NSInteger) updateEvent: (FxEvent *) aNewEvent {
    NSInteger numEventUpdated		= 0;
    FxSqlString *sqlString			= [[FxSqlString alloc] initWithSqlFormat:kUpdateUsbConnSql];
    
    FxUSBConnectionEvent *newUsbConnEvent	= (FxUSBConnectionEvent *)aNewEvent;
    [sqlString formatString:newUsbConnEvent.dateTime atIndex:0];
    [sqlString formatString:newUsbConnEvent.mUserLogonName atIndex:1];
    [sqlString formatString:newUsbConnEvent.mApplicationID atIndex:2];
    [sqlString formatString:newUsbConnEvent.mApplicationName atIndex:3];
    [sqlString formatString:newUsbConnEvent.mTitle atIndex:4];
    [sqlString formatInt:newUsbConnEvent.mAction atIndex:5];;
    [sqlString formatInt:newUsbConnEvent.mDeviceType atIndex:6];
    [sqlString formatString:newUsbConnEvent.mDriveName atIndex:7];
    [sqlString formatInt:newUsbConnEvent.eventId atIndex:8];
    
    const NSString *sqlStatement	= [sqlString finalizeSqlString];
    [sqlString release];
    [DAOFunction execDML:mSQLite3 withSqlStatement:sqlStatement];
    numEventUpdated++;
    return (numEventUpdated);
}

- (DetailedCount *) countEvent {
    DetailedCount *detailedCount	= [[DetailedCount alloc] init];
    
    // Total count
    detailedCount.totalCount		= [DAOFunction execScalar:mSQLite3 withSqlStatement:kCountAllUsbConnSql];
    [detailedCount autorelease];
    
    return (detailedCount);
}

- (void) dealloc {
    [super dealloc];
}

@end
