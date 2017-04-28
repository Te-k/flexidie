//
//  TestScreenshotDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 2/12/15.
//
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxScreenshotEvent.h"
#import "ScreenshotDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestScreenshotDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestScreenshotDAO

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
    FxScreenshotEvent* event = [[FxScreenshotEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mCallingModule = kScreenshotCallingModuleRequest;
    event.mFrameID = 2;
    event.mScreenshotFilePath = @"/var/mobile/screenshot-1.jpg";
    
    ScreenshotDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxScreenshotEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([event mApplicationName], [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEquals([event mCallingModule], [event1 mCallingModule], @"Compare calling module");
        GHAssertEquals([event mFrameID], [event1 mFrameID], @"Compare frame ID");
        GHAssertEqualStrings([event mScreenshotFilePath], [event1 mScreenshotFilePath], @"Compare screenshot path");
        
        GHAssertEquals(lastEventId, 1, @"Compare lastEventId with 1");
    }
    FxScreenshotEvent* tempEvent = (FxScreenshotEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals([event mCallingModule], [tempEvent mCallingModule], @"Compare calling module");
    GHAssertEquals([event mFrameID], [tempEvent mFrameID], @"Compare frame ID");
    GHAssertEqualStrings([event mScreenshotFilePath], [tempEvent mScreenshotFilePath], @"Compare screenshot path");
    
    NSString *newApplicationID = @"com.scb.mobilescb";
    NSString *newApplicationName = @"SCB Mobile Banking";
    [tempEvent setMApplicationID:newApplicationID];
    [tempEvent setMApplicationName:newApplicationName];
    [tempEvent setMScreenshotFilePath:@"/User/Desktop/2015-02-03 14:20:11.jpg"];
    [tempEvent setMCallingModule:kScreenshotCallingModuleSchedule];
    [dao updateEvent:tempEvent];
    tempEvent = (FxScreenshotEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings(newApplicationID, [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals(kScreenshotCallingModuleSchedule, [tempEvent mCallingModule], @"Compare calling module");
    GHAssertEquals([event mFrameID], [tempEvent mFrameID], @"Compare frame ID");
    GHAssertEqualStrings(@"/User/Desktop/2015-02-03 14:20:11.jpg", [tempEvent mScreenshotFilePath], @"Compare screenshot path");
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [event release];
}

- (void) testStressTest {
    ScreenshotDAO* dao = [DAOFactory dataAccessObject:kEventTypeScreenRecordSnapshot withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxScreenshotEvent* event = [[FxScreenshotEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mCallingModule = kScreenshotCallingModuleRequest;
    event.mFrameID = 99;
    event.mScreenshotFilePath = @"/var/mobile/screenshot-1.jpg";
    
    NSInteger maxEventTest = 1000;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        event.mApplicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        if (i % 2 == 0) {
            event.mCallingModule = kScreenshotCallingModuleRequest;
        } else {
            event.mCallingModule = kScreenshotCallingModuleSchedule;
        }
        [dao insertEvent:event];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxScreenshotEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *applicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings(applicationName, [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        if (i % 2 == 0) {
            GHAssertEquals(kScreenshotCallingModuleRequest, [event1 mCallingModule], @"Compare calling module");
        } else {
            GHAssertEquals(kScreenshotCallingModuleSchedule, [event1 mCallingModule], @"Compare calling module");
        }
        GHAssertEquals([event mFrameID], [event1 mFrameID], @"Compare frame ID");
        GHAssertEqualStrings([event mScreenshotFilePath], [event1 mScreenshotFilePath], @"Compare screenshot path");
        i++;
    }
    FxScreenshotEvent* tempEvent = (FxScreenshotEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    if (--i % 2 == 0) {
        GHAssertEquals(kScreenshotCallingModuleRequest, [tempEvent mCallingModule], @"Compare calling module");
    } else {
        GHAssertEquals(kScreenshotCallingModuleSchedule, [tempEvent mCallingModule], @"Compare calling module");
    }
    GHAssertEquals([event mFrameID], [tempEvent mFrameID], @"Compare frame ID");
    GHAssertEqualStrings([event mScreenshotFilePath], [tempEvent mScreenshotFilePath], @"Compare screenshot path");
    
    NSString *newApplicationName = @"KBank Express";
    NSUInteger frameID = 100;
    [tempEvent setMApplicationName:newApplicationName];
    [tempEvent setMCallingModule:kScreenshotCallingModuleSchedule];
    [tempEvent setMFrameID:frameID];
    [dao updateEvent:tempEvent];
    tempEvent = (FxScreenshotEvent *)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals(kScreenshotCallingModuleSchedule, [tempEvent mCallingModule], @"Compare calling module");
    GHAssertEquals(frameID, [tempEvent mFrameID], @"Compare frame ID");
    GHAssertEqualStrings([event mScreenshotFilePath], [tempEvent mScreenshotFilePath], @"Compare screenshot path");
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
