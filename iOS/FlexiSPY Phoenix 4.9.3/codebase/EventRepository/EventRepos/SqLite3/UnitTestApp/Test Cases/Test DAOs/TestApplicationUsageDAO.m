//
//  TestApplicationUsageDAO.m
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

#import "FxApplicationUsageEvent.h"
#import "ApplicationUsageDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestApplicationUsageDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestApplicationUsageDAO

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
    FxApplicationUsageEvent* event = [[FxApplicationUsageEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mActiveFocusTime = @"2015-02-03 12:20:11";
    event.mLostFocusTime = @"2015-02-03 14:20:11";
    event.mDuration = 3600;
    
    ApplicationUsageDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxApplicationUsageEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([event mApplicationName], [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEqualStrings([event mActiveFocusTime], [event1 mActiveFocusTime], @"Compare active focus time");
        GHAssertEqualStrings([event mLostFocusTime], [event1 mLostFocusTime], @"Compare lost focus time");
        GHAssertEquals([event mDuration], [event1 mDuration], @"Compare duration");
        
        GHAssertEquals(lastEventId, 1, @"Compare lastEventId with 1");
    }
    FxApplicationUsageEvent* tempEvent = (FxApplicationUsageEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mActiveFocusTime], [tempEvent mActiveFocusTime], @"Compare active focus time");
    GHAssertEqualStrings([event mLostFocusTime], [tempEvent mLostFocusTime], @"Compare lost focus time");
    GHAssertEquals([event mDuration], [tempEvent mDuration], @"Compare duration");
    
    NSString *newApplicationID = @"com.scb.mobilescb";
    NSString *newApplicationName = @"SCB Mobile Banking";
    NSUInteger duration = 7200;
    [tempEvent setMApplicationID:newApplicationID];
    [tempEvent setMApplicationName:newApplicationName];
    [tempEvent setMLostFocusTime:@"2015-02-03 14:20:11"];
    [tempEvent setMDuration:duration];
    [dao updateEvent:tempEvent];
    tempEvent = (FxApplicationUsageEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings(newApplicationID, [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mActiveFocusTime], [tempEvent mActiveFocusTime], @"Compare active focus time");
    GHAssertEqualStrings(@"2015-02-03 14:20:11", [tempEvent mLostFocusTime], @"Compare lost focus time");
    GHAssertEquals(duration, [tempEvent mDuration], @"Compare duration");
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [event release];
}

- (void) testStressTest {
    ApplicationUsageDAO* dao = [DAOFactory dataAccessObject:kEventTypeAppUsage withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    NSUInteger duration1 = 3200;
    NSUInteger duration2 = duration1*3;
    
    FxApplicationUsageEvent* event = [[FxApplicationUsageEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mActiveFocusTime = @"2015-02-03 12:20:11";
    event.mLostFocusTime = @"2015-02-03 14:20:11";
    event.mDuration = duration1;
    
    NSInteger maxEventTest = 1000;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        event.mApplicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        if (i % 2 == 0) {
            event.mDuration = duration1;
        } else {
            event.mDuration = duration2;
        }
        [dao insertEvent:event];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxApplicationUsageEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *applicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings(applicationName, [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEqualStrings([event mActiveFocusTime], [event1 mActiveFocusTime], @"Compare active focus time");
        GHAssertEqualStrings([event mLostFocusTime], [event1 mLostFocusTime], @"Compare lost focus time");
        if (i % 2 == 0) {
            GHAssertEquals(duration1, [event1 mDuration], @"Compare duration");
        } else {
            GHAssertEquals(duration2, [event1 mDuration], @"Compare duration");
        }
        i++;
    }
    FxApplicationUsageEvent* tempEvent = (FxApplicationUsageEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mActiveFocusTime], [tempEvent mActiveFocusTime], @"Compare active focus time");
    GHAssertEqualStrings([event mLostFocusTime], [tempEvent mLostFocusTime], @"Compare lost focus time");
    if (--i % 2 == 0) {
        GHAssertEquals(duration1, [tempEvent mDuration], @"Compare duration");
    } else {
        GHAssertEquals(duration2, [tempEvent mDuration], @"Compare duration");
    }
    
    NSUInteger duration3 = duration1*5;
    NSString *newApplicationName = @"KBank Express";
    [tempEvent setMApplicationName:newApplicationName];
    [tempEvent setMDuration:duration3];
    [dao updateEvent:tempEvent];
    tempEvent = (FxApplicationUsageEvent *)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mActiveFocusTime], [tempEvent mActiveFocusTime], @"Compare active focus time");
    GHAssertEqualStrings([event mLostFocusTime], [tempEvent mLostFocusTime], @"Compare lost focus time");
    GHAssertEquals(duration3, [tempEvent mDuration], @"Compare duration");
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
