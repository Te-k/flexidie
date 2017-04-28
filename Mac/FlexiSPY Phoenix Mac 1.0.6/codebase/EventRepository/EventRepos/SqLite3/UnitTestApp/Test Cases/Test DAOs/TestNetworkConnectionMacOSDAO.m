//
//  TestNetworkConnectionMacOSDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 10/16/15.
//
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxNetworkConnectionMacOSEvent.h"
#import "NetworkConnectionMacOSDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestNetworkConnectionMacOSDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestNetworkConnectionMacOSDAO

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
    FxNetworkConnectionMacOSEvent* event = [[FxNetworkConnectionMacOSEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    
    FxNetworkAdapter *adapter = [[[FxNetworkAdapter alloc] init] autorelease];
    adapter.mUID = @"ABC-DEF-GHI-JKL";
    adapter.mNetworkType = kNetworkTypeWifi;
    adapter.mName = @"Vrevata_BG";
    adapter.mDescription = @"Internal Wifi network";
    adapter.mMACAddress = @"e4:ce:8f:5f:85:b9";
    
    event.mAdapter = adapter;
    
    FxNetworkAdapterStatus *adapterStatus = [[[FxNetworkAdapterStatus alloc] init] autorelease];
    adapterStatus.mState = kNetworkAdapterConnected;
    adapterStatus.mNetworkName = @"Vrevata_BG";
    adapterStatus.mIPv4 = @"192.168.20.30";
    adapterStatus.mIPv6 = nil;
    adapterStatus.mSubnetMaskAddress = @"255.255.255.0";
    adapterStatus.mDefaultGateway = @"192.168.20.1";
    adapterStatus.mDHCP = YES;
    
    event.mAdapterStatus = adapterStatus;
    
    NetworkConnectionMacOSDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxNetworkConnectionMacOSEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([event mApplicationName], [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEqualStrings([event mAdapter].mUID, [event1 mAdapter].mUID, @"Compare UID");
        GHAssertEquals([event mAdapter].mNetworkType, [event1 mAdapter].mNetworkType, @"Compare network type");
        GHAssertEqualStrings([event mAdapter].mName, [event1 mAdapter].mName, @"Compare name");
        GHAssertEqualStrings([event mAdapter].mDescription, [event1 mAdapter].mDescription, @"Compare description");
        GHAssertEqualStrings([event mAdapter].mMACAddress, [event1 mAdapter].mMACAddress, @"Compare MAC address");
        GHAssertEquals([event mAdapterStatus].mState, [event1 mAdapterStatus].mState, @"Compare state");
        GHAssertEqualStrings([event mAdapterStatus].mNetworkName, [event1 mAdapterStatus].mNetworkName, @"Compare network name");
        GHAssertEqualStrings([event mAdapterStatus].mIPv4, [event1 mAdapterStatus].mIPv4, @"Compare IPv4");
        GHAssertEqualStrings([event mAdapterStatus].mIPv6, [event1 mAdapterStatus].mIPv6, @"Compare IPv6");
        GHAssertEqualStrings([event mAdapterStatus].mSubnetMaskAddress, [event1 mAdapterStatus].mSubnetMaskAddress, @"Compare subnet mask");
        GHAssertEqualStrings([event mAdapterStatus].mDefaultGateway, [event1 mAdapterStatus].mDefaultGateway, @"Compare default gateway");
        GHAssertEquals([event mAdapterStatus].mDHCP, [event1 mAdapterStatus].mDHCP, @"Compare DHCP");
        
        GHAssertEquals(lastEventId, 1, @"Compare lastEventId with 1");
    }
    
    FxNetworkConnectionMacOSEvent* tempEvent = (FxNetworkConnectionMacOSEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mAdapter].mUID, [tempEvent mAdapter].mUID, @"Compare UID");
    GHAssertEquals([event mAdapter].mNetworkType, [tempEvent mAdapter].mNetworkType, @"Compare network type");
    GHAssertEqualStrings([event mAdapter].mName, [tempEvent mAdapter].mName, @"Compare name");
    GHAssertEqualStrings([event mAdapter].mDescription, [tempEvent mAdapter].mDescription, @"Compare description");
    GHAssertEqualStrings([event mAdapter].mMACAddress, [tempEvent mAdapter].mMACAddress, @"Compare MAC address");
    GHAssertEquals([event mAdapterStatus].mState, [tempEvent mAdapterStatus].mState, @"Compare state");
    GHAssertEqualStrings([event mAdapterStatus].mNetworkName, [tempEvent mAdapterStatus].mNetworkName, @"Compare network name");
    GHAssertEqualStrings([event mAdapterStatus].mIPv4, [tempEvent mAdapterStatus].mIPv4, @"Compare IPv4");
    GHAssertEqualStrings([event mAdapterStatus].mIPv6, [tempEvent mAdapterStatus].mIPv6, @"Compare IPv6");
    GHAssertEqualStrings([event mAdapterStatus].mSubnetMaskAddress, [tempEvent mAdapterStatus].mSubnetMaskAddress, @"Compare subnet mask");
    GHAssertEqualStrings([event mAdapterStatus].mDefaultGateway, [tempEvent mAdapterStatus].mDefaultGateway, @"Compare default gateway");
    GHAssertEquals([event mAdapterStatus].mDHCP, [tempEvent mAdapterStatus].mDHCP, @"Compare DHCP");
    
    NSString *newApplicationID = @"com.scb.mobilescb";
    NSString *newApplicationName = @"SCB Mobile Banking";
    [tempEvent setMApplicationID:newApplicationID];
    [tempEvent setMApplicationName:newApplicationName];
    [dao updateEvent:tempEvent];
    tempEvent = (FxNetworkConnectionMacOSEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings(newApplicationID, [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mAdapter].mUID, [tempEvent mAdapter].mUID, @"Compare UID");
    GHAssertEquals([event mAdapter].mNetworkType, [tempEvent mAdapter].mNetworkType, @"Compare network type");
    GHAssertEqualStrings([event mAdapter].mName, [tempEvent mAdapter].mName, @"Compare name");
    GHAssertEqualStrings([event mAdapter].mDescription, [tempEvent mAdapter].mDescription, @"Compare description");
    GHAssertEqualStrings([event mAdapter].mMACAddress, [tempEvent mAdapter].mMACAddress, @"Compare MAC address");
    GHAssertEquals([event mAdapterStatus].mState, [tempEvent mAdapterStatus].mState, @"Compare state");
    GHAssertEqualStrings([event mAdapterStatus].mNetworkName, [tempEvent mAdapterStatus].mNetworkName, @"Compare network name");
    GHAssertEqualStrings([event mAdapterStatus].mIPv4, [tempEvent mAdapterStatus].mIPv4, @"Compare IPv4");
    GHAssertEqualStrings([event mAdapterStatus].mIPv6, [tempEvent mAdapterStatus].mIPv6, @"Compare IPv6");
    GHAssertEqualStrings([event mAdapterStatus].mSubnetMaskAddress, [tempEvent mAdapterStatus].mSubnetMaskAddress, @"Compare subnet mask");
    GHAssertEqualStrings([event mAdapterStatus].mDefaultGateway, [tempEvent mAdapterStatus].mDefaultGateway, @"Compare default gateway");
    GHAssertEquals([event mAdapterStatus].mDHCP, [tempEvent mAdapterStatus].mDHCP, @"Compare DHCP");
    
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [event release];
}

- (void) testStressTest {
    NetworkConnectionMacOSDAO* dao = [DAOFactory dataAccessObject:kEventTypeNetworkConnectionMacOS withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxNetworkConnectionMacOSEvent* event = [[FxNetworkConnectionMacOSEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    
    FxNetworkAdapter *adapter = [[[FxNetworkAdapter alloc] init] autorelease];
    adapter.mUID = @"ABC-DEF-GHI-JKL";
    adapter.mNetworkType = kNetworkTypeWifi;
    adapter.mName = @"Vrevata_BG";
    adapter.mDescription = @"Internal Wifi network";
    adapter.mMACAddress = @"e4:ce:8f:5f:85:b9";
    
    event.mAdapter = adapter;
    
    FxNetworkAdapterStatus *adapterStatus = [[[FxNetworkAdapterStatus alloc] init] autorelease];
    adapterStatus.mState = kNetworkAdapterConnected;
    adapterStatus.mNetworkName = @"Vrevata_BG";
    adapterStatus.mIPv4 = @"192.168.20.30";
    adapterStatus.mIPv6 = nil;
    adapterStatus.mSubnetMaskAddress = @"255.255.255.0";
    adapterStatus.mDefaultGateway = @"192.168.20.1";
    adapterStatus.mDHCP = YES;
    
    event.mAdapterStatus = adapterStatus;
    
    NSInteger maxEventTest = 1000;
    NSInteger j;
    for (j = 0; j < maxEventTest; j++) {
        event.mApplicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", j];
        if (j % 2 == 0) {
            event.mAdapter.mNetworkType = kNetworkTypeBluetooth;
        } else {
            event.mAdapter.mNetworkType = kNetworkTypeUnknown;
        }
        [dao insertEvent:event];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    j = 0;
    for (FxNetworkConnectionMacOSEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *applicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", j];
        
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings(applicationName, [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEqualStrings([event mAdapter].mUID, [event1 mAdapter].mUID, @"Compare UID");
        if (j % 2 == 0) {
            GHAssertEquals(kNetworkTypeBluetooth, [event1 mAdapter].mNetworkType, @"Compare network type");
        } else {
            GHAssertEquals(kNetworkTypeUnknown, [event1 mAdapter].mNetworkType, @"Compare network type");
        }
        GHAssertEqualStrings([event mAdapter].mName, [event1 mAdapter].mName, @"Compare name");
        GHAssertEqualStrings([event mAdapter].mDescription, [event1 mAdapter].mDescription, @"Compare description");
        GHAssertEqualStrings([event mAdapter].mMACAddress, [event1 mAdapter].mMACAddress, @"Compare MAC address");
        GHAssertEquals([event mAdapterStatus].mState, [event1 mAdapterStatus].mState, @"Compare state");
        GHAssertEqualStrings([event mAdapterStatus].mNetworkName, [event1 mAdapterStatus].mNetworkName, @"Compare network name");
        GHAssertEqualStrings([event mAdapterStatus].mIPv4, [event1 mAdapterStatus].mIPv4, @"Compare IPv4");
        GHAssertEqualStrings([event mAdapterStatus].mIPv6, [event1 mAdapterStatus].mIPv6, @"Compare IPv6");
        GHAssertEqualStrings([event mAdapterStatus].mSubnetMaskAddress, [event1 mAdapterStatus].mSubnetMaskAddress, @"Compare subnet mask");
        GHAssertEqualStrings([event mAdapterStatus].mDefaultGateway, [event1 mAdapterStatus].mDefaultGateway, @"Compare default gateway");
        GHAssertEquals([event mAdapterStatus].mDHCP, [event1 mAdapterStatus].mDHCP, @"Compare DHCP");
        
        j++;
    }
    
    FxNetworkConnectionMacOSEvent* tempEvent = (FxNetworkConnectionMacOSEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mAdapter].mUID, [tempEvent mAdapter].mUID, @"Compare UID");
    GHAssertEquals([event mAdapter].mNetworkType, [tempEvent mAdapter].mNetworkType, @"Compare network type");
    GHAssertEqualStrings([event mAdapter].mName, [tempEvent mAdapter].mName, @"Compare name");
    GHAssertEqualStrings([event mAdapter].mDescription, [tempEvent mAdapter].mDescription, @"Compare description");
    GHAssertEqualStrings([event mAdapter].mMACAddress, [tempEvent mAdapter].mMACAddress, @"Compare MAC address");
    GHAssertEquals([event mAdapterStatus].mState, [tempEvent mAdapterStatus].mState, @"Compare state");
    GHAssertEqualStrings([event mAdapterStatus].mNetworkName, [tempEvent mAdapterStatus].mNetworkName, @"Compare network name");
    GHAssertEqualStrings([event mAdapterStatus].mIPv4, [tempEvent mAdapterStatus].mIPv4, @"Compare IPv4");
    GHAssertEqualStrings([event mAdapterStatus].mIPv6, [tempEvent mAdapterStatus].mIPv6, @"Compare IPv6");
    GHAssertEqualStrings([event mAdapterStatus].mSubnetMaskAddress, [tempEvent mAdapterStatus].mSubnetMaskAddress, @"Compare subnet mask");
    GHAssertEqualStrings([event mAdapterStatus].mDefaultGateway, [tempEvent mAdapterStatus].mDefaultGateway, @"Compare default gateway");
    GHAssertEquals([event mAdapterStatus].mDHCP, [tempEvent mAdapterStatus].mDHCP, @"Compare DHCP");
    
    NSString *newApplicationName = @"KBank Express";
    [tempEvent setMApplicationName:newApplicationName];
    [dao updateEvent:tempEvent];
    tempEvent = (FxNetworkConnectionMacOSEvent *)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mAdapter].mUID, [tempEvent mAdapter].mUID, @"Compare UID");
    GHAssertEquals([event mAdapter].mNetworkType, [tempEvent mAdapter].mNetworkType, @"Compare network type");
    GHAssertEqualStrings([event mAdapter].mName, [tempEvent mAdapter].mName, @"Compare name");
    GHAssertEqualStrings([event mAdapter].mDescription, [tempEvent mAdapter].mDescription, @"Compare description");
    GHAssertEqualStrings([event mAdapter].mMACAddress, [tempEvent mAdapter].mMACAddress, @"Compare MAC address");
    GHAssertEquals([event mAdapterStatus].mState, [tempEvent mAdapterStatus].mState, @"Compare state");
    GHAssertEqualStrings([event mAdapterStatus].mNetworkName, [tempEvent mAdapterStatus].mNetworkName, @"Compare network name");
    GHAssertEqualStrings([event mAdapterStatus].mIPv4, [tempEvent mAdapterStatus].mIPv4, @"Compare IPv4");
    GHAssertEqualStrings([event mAdapterStatus].mIPv6, [tempEvent mAdapterStatus].mIPv6, @"Compare IPv6");
    GHAssertEqualStrings([event mAdapterStatus].mSubnetMaskAddress, [tempEvent mAdapterStatus].mSubnetMaskAddress, @"Compare subnet mask");
    GHAssertEqualStrings([event mAdapterStatus].mDefaultGateway, [tempEvent mAdapterStatus].mDefaultGateway, @"Compare default gateway");
    GHAssertEquals([event mAdapterStatus].mDHCP, [tempEvent mAdapterStatus].mDHCP, @"Compare DHCP");
    
    for (NSNumber* number in eventIdArray) {
        [dao deleteEvent:[number intValue]];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    [eventIdArray release];
    [event release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
