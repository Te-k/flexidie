//
//  TestPageVisitedDAO.m
//  
//
//  Created by Makara Khloth on 1/13/17.
//
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxPageVisitedEvent.h"
#import "PageVisitedDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestPageVisitedDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestPageVisitedDAO

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
    FxPageVisitedEvent* event = [[FxPageVisitedEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplication = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mActualDisplayData = @"";
    event.mRawData = @"";
    event.mUrl = @"";
    event.mBrowserScreenshotPath = @"/var/mobile/safari.png";
    event.mBrowsingStartTime = kEventDateTime;
    event.mBrowsingEndTime = kEventDateTime;
    event.mBrowsingDuration = 0;
    
    PageVisitedDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxPageVisitedEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserName], [event1 mUserName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([event mApplication], [event1 mApplication], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEqualStrings([event mActualDisplayData], [event1 mActualDisplayData], @"Compare display data");
        GHAssertEqualStrings([event mRawData], [event1 mRawData], @"Compare raw data");
        GHAssertEqualStrings([event mUrl], [event1 mUrl], @"Compare url");
        GHAssertEqualStrings([event mBrowserScreenshotPath], [event1 mBrowserScreenshotPath], @"Compare browser screenshot path");
        GHAssertEqualStrings([event mBrowsingStartTime], [event1 mBrowsingStartTime], @"Compare browsing start time");
        GHAssertEqualStrings([event mBrowsingEndTime], [event1 mBrowsingEndTime], @"Compare browsing end time");
        GHAssertEquals([event mBrowsingDuration], [event1 mBrowsingDuration], @"Compare browsing duration");
        
        GHAssertEquals(lastEventId, 1, @"Compare lastEventId with 1");
    }
    
    FxPageVisitedEvent* tempEvent = (FxPageVisitedEvent *)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserName], [tempEvent mUserName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplication], [tempEvent mApplication], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mActualDisplayData], [tempEvent mActualDisplayData], @"Compare display data");
    GHAssertEqualStrings([event mRawData], [tempEvent mRawData], @"Compare raw data");
    GHAssertEqualStrings([event mUrl], [tempEvent mUrl], @"Compare url");
    GHAssertEqualStrings([event mBrowserScreenshotPath], [tempEvent mBrowserScreenshotPath], @"Compare browser screenshot path");
    GHAssertEqualStrings([event mBrowsingStartTime], [tempEvent mBrowsingStartTime], @"Compare browsing start time");
    GHAssertEqualStrings([event mBrowsingEndTime], [tempEvent mBrowsingEndTime], @"Compare browsing end time");
    GHAssertEquals([event mBrowsingDuration], [tempEvent mBrowsingDuration], @"Compare browsing duration");
    
    NSString *newApplicationID = @"com.scb.mobilescb";
    NSString *newApplicationName = @"SCB Mobile Banking";
    [tempEvent setMApplicationID:newApplicationID];
    [tempEvent setMApplication:newApplicationName];
    [tempEvent setMTitle:@"/User/Desktop/2015-02-03 14:20:11.jpg"];
    [tempEvent setMUrl:@"https://portal.vervata.com/projects/mobileproducts/Phoenix%20Protocol%20Specs/Phoenix%20Protocol%208/Structured%20Commands/Application%20Category.aspx"];
    [tempEvent setMBrowsingDuration:7];
    [dao updateEvent:tempEvent];
    tempEvent = (FxPageVisitedEvent *)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserName], [tempEvent mUserName], @"Compare user logon name");
    GHAssertEqualStrings(newApplicationID, [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplication], @"Compare application name");
    GHAssertEqualStrings(@"/User/Desktop/2015-02-03 14:20:11.jpg", [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mActualDisplayData], [tempEvent mActualDisplayData], @"Compare display data");
    GHAssertEqualStrings([event mRawData], [tempEvent mRawData], @"Compare raw data");
    GHAssertEqualStrings(@"https://portal.vervata.com/projects/mobileproducts/Phoenix%20Protocol%20Specs/Phoenix%20Protocol%208/Structured%20Commands/Application%20Category.aspx", [tempEvent mUrl], @"Compare url");
    GHAssertEqualStrings([event mBrowserScreenshotPath], [tempEvent mBrowserScreenshotPath], @"Compare browser screenshot path");
    GHAssertEqualStrings([event mBrowsingStartTime], [tempEvent mBrowsingStartTime], @"Compare browsing start time");
    GHAssertEqualStrings([event mBrowsingEndTime], [tempEvent mBrowsingEndTime], @"Compare browsing end time");
    GHAssertEquals((NSUInteger)7, [tempEvent mBrowsingDuration], @"Compare browsing duration");
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [event release];
}

- (void) testStressTest {
    PageVisitedDAO* dao = [DAOFactory dataAccessObject:kEventTypePageVisited withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxPageVisitedEvent* event = [[FxPageVisitedEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplication = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mActualDisplayData = @"";
    event.mRawData = @"";
    event.mUrl = @"https://accounts.google.com/ServiceLogin?service=mail&passive=true&rm=false&continue=https://mail.google.com/mail/?tab%3Dwm&scc=1&ltmpl=default&ltmplcache=2&emr=1&osid=1#identifier";
    event.mBrowserScreenshotPath = @"/var/mobile/safari.png";
    event.mBrowsingStartTime = kEventDateTime;
    event.mBrowsingEndTime = kEventDateTime;
    event.mBrowsingDuration = 0;
    
    NSInteger maxEventTest = 1000;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        event.mApplication = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        if (i % 2 == 0) {
            event.mBrowsingDuration = 90;
            event.mUrl = @"https://accounts.google.com/ServiceLogin?service=mail&passive=true&rm=false&continue=https://mail.google.com/mail/?tab%3Dwm&scc=1&ltmpl=default&ltmplcache=2&emr=1&osid=1#identifier";
        } else {
            event.mBrowsingDuration = 300;
            event.mUrl = @"http://www.codeproject.com/Articles/4894/Pointer-to-Pointer-and-Reference-to-Pointer";
        }
        [dao insertEvent:event];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxPageVisitedEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *applicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserName], [event1 mUserName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings(applicationName, [event1 mApplication], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEqualStrings([event mActualDisplayData], [event1 mActualDisplayData], @"Compare display data");
        GHAssertEqualStrings([event mRawData], [event1 mRawData], @"Compare raw data");
        if (i % 2 == 0) {
            GHAssertEquals(90, (int)[event1 mBrowsingDuration], @"Compare browsing duration");
            GHAssertEqualStrings(@"https://accounts.google.com/ServiceLogin?service=mail&passive=true&rm=false&continue=https://mail.google.com/mail/?tab%3Dwm&scc=1&ltmpl=default&ltmplcache=2&emr=1&osid=1#identifier", [event1 mUrl], @"Compare url");
        } else {
            GHAssertEquals(300, (int)[event1 mBrowsingDuration], @"Compare browsing duration");
            GHAssertEqualStrings(@"http://www.codeproject.com/Articles/4894/Pointer-to-Pointer-and-Reference-to-Pointer", [event1 mUrl], @"Compare url");
        }
        GHAssertEqualStrings([event mBrowserScreenshotPath], [event1 mBrowserScreenshotPath], @"Compare browser screenshot path");
        GHAssertEqualStrings([event mBrowsingStartTime], [event1 mBrowsingStartTime], @"Compare browsing start time");
        GHAssertEqualStrings([event mBrowsingEndTime], [event1 mBrowsingEndTime], @"Compare browsing end time");
        i++;
    }
    
    FxPageVisitedEvent* tempEvent = (FxPageVisitedEvent *)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserName], [tempEvent mUserName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplication], [tempEvent mApplication], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mActualDisplayData], [tempEvent mActualDisplayData], @"Compare display data");
    GHAssertEqualStrings([event mRawData], [tempEvent mRawData], @"Compare raw data");
    if (--i % 2 == 0) {
        GHAssertEquals(90, (int)[tempEvent mBrowsingDuration], @"Compare browsing duration");
        GHAssertEqualStrings([event mUrl], [tempEvent mUrl], @"Compare url");
    } else {
        GHAssertEquals(300, (int)[tempEvent mBrowsingDuration], @"Compare browsing duration");
        GHAssertEqualStrings(@"http://www.codeproject.com/Articles/4894/Pointer-to-Pointer-and-Reference-to-Pointer", [tempEvent mUrl], @"Compare url");
    }
    GHAssertEqualStrings([event mBrowserScreenshotPath], [tempEvent mBrowserScreenshotPath], @"Compare browser screenshot path");
    GHAssertEqualStrings([event mBrowsingStartTime], [tempEvent mBrowsingStartTime], @"Compare browsing start time");
    GHAssertEqualStrings([event mBrowsingEndTime], [tempEvent mBrowsingEndTime], @"Compare browsing end time");
    
    NSString *newApplicationName = @"KBank Express";
    [tempEvent setMApplication:newApplicationName];
    [tempEvent setMUrl:@"https://developer.apple.com/"];
    [tempEvent setMBrowsingDuration:500];
    [dao updateEvent:tempEvent];
    tempEvent = (FxPageVisitedEvent *)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserName], [tempEvent mUserName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplication], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mActualDisplayData], [tempEvent mActualDisplayData], @"Compare display data");
    GHAssertEqualStrings([event mRawData], [tempEvent mRawData], @"Compare raw data");
    GHAssertEqualStrings(@"https://developer.apple.com/", [tempEvent mUrl], @"Compare url");
    GHAssertEqualStrings([event mBrowserScreenshotPath], [tempEvent mBrowserScreenshotPath], @"Compare browser screenshot path");
    GHAssertEqualStrings([event mBrowsingStartTime], [tempEvent mBrowsingStartTime], @"Compare browsing start time");
    GHAssertEqualStrings([event mBrowsingEndTime], [tempEvent mBrowsingEndTime], @"Compare browsing end time");
    GHAssertEquals(500, (int)[tempEvent mBrowsingDuration], @"Compare browsing duration");
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
