//
//  TestUsbConnectionDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxUSBConnectionEvent.h"
#import "UsbConnectionDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestUsbConnectionDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestUsbConnectionDAO

- (void) setUp {
    if (!mDatabaseManager) {
        mDatabaseManager = [[DatabaseManager alloc] init];
        [mDatabaseManager dropDB];
    } else {
        [mDatabaseManager dropDB];
    }
}

- (void) tearDown {
    
}

- (void) testNormalTest {
    FxUSBConnectionEvent* usbConnEvent = [[FxUSBConnectionEvent alloc] init];
    usbConnEvent.dateTime = kEventDateTime;
    usbConnEvent.mUserLogonName = @"Ophat";
    usbConnEvent.mApplicationID = @"com.kbak.kmobile";
    usbConnEvent.mApplicationName = @"KBank Mobile";
    usbConnEvent.mTitle = @"iTune Connect";
    usbConnEvent.mAction = kUSBConnectionActionConnected;
    usbConnEvent.mDeviceType = kUSBConnectionTypeMassStorage;
    usbConnEvent.mDriveName = @"Ophat 10 GB";
    
    UsbConnectionDAO* usbConnDAO = [DAOFactory dataAccessObject:[usbConnEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [usbConnDAO insertEvent:usbConnEvent];
    DetailedCount* detailedCount = [usbConnDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [usbConnDAO selectMaxEvent:33];
    for (FxUSBConnectionEvent* usbConnEvent1 in eventArray) {
        lastEventId = [usbConnEvent1 eventId];
        GHAssertEqualStrings([usbConnEvent dateTime], [usbConnEvent1 dateTime], @"Compare date time");
        GHAssertEqualStrings([usbConnEvent mUserLogonName], [usbConnEvent1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([usbConnEvent mApplicationID], [usbConnEvent1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([usbConnEvent mApplicationName], [usbConnEvent1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([usbConnEvent mTitle], [usbConnEvent1 mTitle], @"Compare title");
        GHAssertEquals([usbConnEvent mAction], [usbConnEvent1 mAction], @"Compare action");
        GHAssertEquals([usbConnEvent mDeviceType], [usbConnEvent1 mDeviceType], @"Compare device type");
        GHAssertEqualStrings([usbConnEvent mDriveName], [usbConnEvent1 mDriveName], @"Compare drive name");
        
        GHAssertEquals(lastEventId, 1, @"Compare lastEventId with 1");
    }
    FxUSBConnectionEvent* tempUsbConnEvent = (FxUSBConnectionEvent*)[usbConnDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([usbConnEvent dateTime], [tempUsbConnEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([usbConnEvent mUserLogonName], [tempUsbConnEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([usbConnEvent mApplicationID], [tempUsbConnEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([usbConnEvent mApplicationName], [tempUsbConnEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([usbConnEvent mTitle], [tempUsbConnEvent mTitle], @"Compare title");
    GHAssertEquals([usbConnEvent mAction], [tempUsbConnEvent mAction], @"Compare action");
    GHAssertEquals([usbConnEvent mDeviceType], [tempUsbConnEvent mDeviceType], @"Compare device type");
    GHAssertEqualStrings([usbConnEvent mDriveName], [tempUsbConnEvent mDriveName], @"Compare drive name");
    
    NSString *newApplicationID = @"com.scb.mobilescb";
    NSString *newApplicationName = @"SCB Mobile Banking";
    [tempUsbConnEvent setMApplicationID:newApplicationID];
    [tempUsbConnEvent setMApplicationName:newApplicationName];
    [usbConnDAO updateEvent:tempUsbConnEvent];
    tempUsbConnEvent = (FxUSBConnectionEvent*)[usbConnDAO selectEvent:lastEventId];
    GHAssertEqualStrings([usbConnEvent dateTime], [tempUsbConnEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([usbConnEvent mUserLogonName], [tempUsbConnEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings(newApplicationID, [tempUsbConnEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempUsbConnEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([usbConnEvent mTitle], [tempUsbConnEvent mTitle], @"Compare title");
    GHAssertEquals([usbConnEvent mAction], [tempUsbConnEvent mAction], @"Compare action");
    GHAssertEquals([usbConnEvent mDeviceType], [tempUsbConnEvent mDeviceType], @"Compare device type");
    GHAssertEqualStrings([usbConnEvent mDriveName], [tempUsbConnEvent mDriveName], @"Compare drive name");
    [usbConnDAO deleteEvent:lastEventId];
    detailedCount = [usbConnDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [usbConnEvent release];
}

- (void) testStressTest {
    UsbConnectionDAO* usbConnDAO = [DAOFactory dataAccessObject:kEventTypeUsbConnection withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [usbConnDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxUSBConnectionEvent* usbConnEvent = [[FxUSBConnectionEvent alloc] init];
    usbConnEvent.dateTime = kEventDateTime;
    usbConnEvent.mUserLogonName = @"Ophat";
    usbConnEvent.mApplicationID = @"com.kbak.kmobile";
    usbConnEvent.mApplicationName = @"KBank Mobile";
    usbConnEvent.mTitle = @"iTune Connect";
    usbConnEvent.mAction = kUSBConnectionActionConnected;
    usbConnEvent.mDeviceType = kUSBConnectionTypeMassStorage;
    usbConnEvent.mDriveName = @"Ophat 10 GB";
    
    NSInteger maxEventTest = 1000;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        usbConnEvent.mApplicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        if (i % 2 == 0) {
            usbConnEvent.mAction = kUSBConnectionActionConnected;
        } else {
            usbConnEvent.mAction = kUSBConnectionActionDisconnected;
        }
        [usbConnDAO insertEvent:usbConnEvent];
    }
    detailedCount = [usbConnDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [usbConnDAO selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxUSBConnectionEvent* usbConnEvent1 in eventArray) {
        lastEventId = [usbConnEvent1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *applicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        
        GHAssertEqualStrings([usbConnEvent dateTime], [usbConnEvent1 dateTime], @"Compare date time");
        GHAssertEqualStrings([usbConnEvent mUserLogonName], [usbConnEvent1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([usbConnEvent mApplicationID], [usbConnEvent1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings(applicationName, [usbConnEvent1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([usbConnEvent mTitle], [usbConnEvent1 mTitle], @"Compare title");
        if (i % 2 == 0) {
            GHAssertEquals(kUSBConnectionActionConnected, [usbConnEvent1 mAction], @"Compare action");
        } else {
            GHAssertEquals(kUSBConnectionActionDisconnected, [usbConnEvent1 mAction], @"Compare action");
        }
        GHAssertEquals([usbConnEvent mDeviceType], [usbConnEvent1 mDeviceType], @"Compare device type");
        GHAssertEqualStrings([usbConnEvent mDriveName], [usbConnEvent1 mDriveName], @"Compare drive name");
        i++;
    }
    FxUSBConnectionEvent* tempUsbConnEvent = (FxUSBConnectionEvent*)[usbConnDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([usbConnEvent dateTime], [tempUsbConnEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([usbConnEvent mUserLogonName], [tempUsbConnEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([usbConnEvent mApplicationID], [tempUsbConnEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([usbConnEvent mApplicationName], [tempUsbConnEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([usbConnEvent mTitle], [tempUsbConnEvent mTitle], @"Compare title");
    if (--i % 2 == 0) {
        GHAssertEquals(kUSBConnectionActionConnected, [tempUsbConnEvent mAction], @"Compare action");
    } else {
        GHAssertEquals(kUSBConnectionActionDisconnected, [tempUsbConnEvent mAction], @"Compare action");
    }
    GHAssertEquals([usbConnEvent mDeviceType], [tempUsbConnEvent mDeviceType], @"Compare device type");
    GHAssertEqualStrings([usbConnEvent mDriveName], [tempUsbConnEvent mDriveName], @"Compare drive name");
    NSString *newApplicationName = @"KBank Express";
    [tempUsbConnEvent setMApplicationName:newApplicationName];
    [tempUsbConnEvent setMAction:kUSBConnectionActionUnknown];
    [usbConnDAO updateEvent:tempUsbConnEvent];
    tempUsbConnEvent = (FxUSBConnectionEvent *)[usbConnDAO selectEvent:lastEventId];
    GHAssertEqualStrings([usbConnEvent dateTime], [tempUsbConnEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([usbConnEvent mUserLogonName], [tempUsbConnEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([usbConnEvent mApplicationID], [tempUsbConnEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempUsbConnEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([usbConnEvent mTitle], [tempUsbConnEvent mTitle], @"Compare title");
    GHAssertEquals(kUSBConnectionActionUnknown, [tempUsbConnEvent mAction], @"Compare action");
    GHAssertEquals([usbConnEvent mDeviceType], [tempUsbConnEvent mDeviceType], @"Compare device type");
    GHAssertEqualStrings([usbConnEvent mDriveName], [tempUsbConnEvent mDriveName], @"Compare drive name");
    for (NSNumber* number in eventIdArray) {
        [usbConnDAO deleteEvent:[number intValue]];
    }
    detailedCount = [usbConnDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    [eventIdArray release];
    [usbConnEvent release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
