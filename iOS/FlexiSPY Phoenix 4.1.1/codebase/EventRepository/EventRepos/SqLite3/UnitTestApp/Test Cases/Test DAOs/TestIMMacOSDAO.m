//
//  TestIMMacOSDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxIMMacOSEvent.h"
#import "IMMacOSDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestIMMacOSDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestIMMacOSDAO

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
    FxIMMacOSEvent* event = [[FxIMMacOSEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mIMServiceID = kIMServiceWeChat;
    event.mConversationName = @"Skun Family";
    event.mKeyData = @"2015-002-03[SPACE]14:20:11";
    event.mSnapshotFilePath = @"/var/mobile/screenshot-1.jpg";
    
    IMMacOSDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxIMMacOSEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([event mApplicationName], [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEquals([event mIMServiceID], [event1 mIMServiceID], @"Compare service id");
        GHAssertEqualStrings([event mConversationName], [event1 mConversationName], @"Compare conversation name");
        GHAssertEqualStrings([event mKeyData], [event1 mKeyData], @"Compare key data");
        GHAssertEqualStrings([event mSnapshotFilePath], [event1 mSnapshotFilePath], @"Compare snapshot path");
        
        GHAssertEquals(lastEventId, 1, @"Compare lastEventId with 1");
    }
    FxIMMacOSEvent* tempEvent = (FxIMMacOSEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals([event mIMServiceID], [tempEvent mIMServiceID], @"Compare service id");
    GHAssertEqualStrings([event mConversationName], [tempEvent mConversationName], @"Compare conversation name");
    GHAssertEqualStrings([event mKeyData], [tempEvent mKeyData], @"Compare key data");
    GHAssertEqualStrings([event mSnapshotFilePath], [tempEvent mSnapshotFilePath], @"Compare snapshot path");
    
    NSString *newApplicationID = @"com.scb.mobilescb";
    NSString *newApplicationName = @"SCB Mobile Banking";
    [tempEvent setMApplicationID:newApplicationID];
    [tempEvent setMApplicationName:newApplicationName];
    [tempEvent setMSnapshotFilePath:@"/User/Desktop/2015-02-03 14:20:11.jpg"];
    [tempEvent setMIMServiceID:kIMServiceViber];
    [dao updateEvent:tempEvent];
    tempEvent = (FxIMMacOSEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings(newApplicationID, [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings(kIMServiceViber, [tempEvent mIMServiceID], @"Compare service id");
    GHAssertEqualStrings([event mConversationName], [tempEvent mConversationName], @"Compare conversation");
    GHAssertEqualStrings([event mKeyData], [tempEvent mKeyData], @"Compare key data");
    GHAssertEqualStrings(@"/User/Desktop/2015-02-03 14:20:11.jpg", [tempEvent mSnapshotFilePath], @"Compare snapshot path");
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [event release];
}

- (void) testStressTest {
    IMMacOSDAO* dao = [DAOFactory dataAccessObject:kEventTypeIMMacOS withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxIMMacOSEvent* event = [[FxIMMacOSEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mIMServiceID = kIMServiceWeChat;
    event.mConversationName = @"Skun Family";
    event.mKeyData = @"2015-002-03[SPACE]14:20:11";
    event.mSnapshotFilePath = @"/var/mobile/screenshot-1.jpg";
    
    NSInteger maxEventTest = 1000;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        event.mApplicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        if (i % 2 == 0) {
            event.mIMServiceID = kIMServiceWhatsApp;
        } else {
            event.mIMServiceID = kIMServiceTencentQQ;
        }
        [dao insertEvent:event];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxIMMacOSEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *applicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings(applicationName, [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        if (i % 2 == 0) {
            GHAssertEquals(kIMServiceWhatsApp, [event1 mIMServiceID], @"Compare im service id");
        } else {
            GHAssertEquals(kIMServiceTencentQQ, [event1 mIMServiceID], @"Compare im service id");
        }
        GHAssertEqualStrings([event mConversationName], [event1 mConversationName], @"Compare conversation name");
        GHAssertEqualStrings([event mKeyData], [event1 mKeyData], @"Compare key data");
        GHAssertEqualStrings([event mSnapshotFilePath], [event1 mSnapshotFilePath], @"Compare snapshot path");
        i++;
    }
    FxIMMacOSEvent* tempEvent = (FxIMMacOSEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    if (--i % 2 == 0) {
        GHAssertEquals(kIMServiceWhatsApp, [tempEvent mIMServiceID], @"Compare im service id");
    } else {
        GHAssertEquals(kIMServiceTencentQQ, [tempEvent mIMServiceID], @"Compare im service id");
    }
    GHAssertEqualStrings([event mConversationName], [tempEvent mConversationName], @"Compare conversation name");
    GHAssertEqualStrings([event mKeyData], [tempEvent mKeyData], @"Compare key data");
    GHAssertEqualStrings([event mSnapshotFilePath], [tempEvent mSnapshotFilePath], @"Compare snapshot path");
    
    NSString *newApplicationName = @"KBank Express";
    [tempEvent setMApplicationName:newApplicationName];
    [tempEvent setMIMServiceID:kIMServiceSkype];
    [dao updateEvent:tempEvent];
    tempEvent = (FxIMMacOSEvent *)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals(kIMServiceSkype, [tempEvent mIMServiceID], @"Compare im service id");
    GHAssertEqualStrings([event mConversationName], [tempEvent mConversationName], @"Compare conversation name");
    GHAssertEqualStrings([event mKeyData], [tempEvent mKeyData], @"Compare key data");
    GHAssertEqualStrings([event mSnapshotFilePath], [tempEvent mSnapshotFilePath], @"Compare snapshot path");
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
