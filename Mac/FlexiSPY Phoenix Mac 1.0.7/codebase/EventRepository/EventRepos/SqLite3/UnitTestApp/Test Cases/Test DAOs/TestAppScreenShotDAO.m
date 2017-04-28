//
//  TestAppScreenShotDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 4/26/16.
//
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxAppScreenShotEvent.h"
#import "AppScreenShotDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestAppScreenShotDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestAppScreenShotDAO

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
    FxAppScreenShotEvent* event = [[FxAppScreenShotEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mApplication_Catagory = kAppScreenShotNon_Browser;
    event.mUrl = @"";
    event.mScreenshotFilePath = @"/var/mobile/screenshot-1.jpg";
    event.mScreenshot_Category = kAppScreenShotChatApp;
    
    AppScreenShotDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxAppScreenShotEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([event mApplicationName], [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEquals([event mApplication_Catagory], [event1 mApplication_Catagory], @"Compare app category");
        GHAssertEqualStrings([event mUrl], [event1 mUrl], @"Compare url");
        GHAssertEqualStrings([event mScreenshotFilePath], [event1 mScreenshotFilePath], @"Compare screen shot path");
        GHAssertEquals([event mScreenshot_Category], [event1 mScreenshot_Category], @"Compare screen category");
        
        GHAssertEquals(lastEventId, 1, @"Compare lastEventId with 1");
    }
    FxAppScreenShotEvent* tempEvent = (FxAppScreenShotEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals([event mApplication_Catagory], [tempEvent mApplication_Catagory], @"Compare app category");
    GHAssertEqualStrings([event mUrl], [tempEvent mUrl], @"Compare url");
    GHAssertEqualStrings([event mScreenshotFilePath], [tempEvent mScreenshotFilePath], @"Compare screen shot path");
    GHAssertEquals([event mScreenshot_Category], [tempEvent mScreenshot_Category], @"Compare screen category");
    
    NSString *newApplicationID = @"com.scb.mobilescb";
    NSString *newApplicationName = @"SCB Mobile Banking";
    [tempEvent setMApplicationID:newApplicationID];
    [tempEvent setMApplicationName:newApplicationName];
    [tempEvent setMScreenshotFilePath:@"/User/Desktop/2015-02-03 14:20:11.jpg"];
    [tempEvent setMApplication_Catagory:kAppScreenShotBrowser];
    [tempEvent setMUrl:@"https://portal.vervata.com/projects/mobileproducts/Phoenix%20Protocol%20Specs/Phoenix%20Protocol%208/Structured%20Commands/Application%20Category.aspx"];
    [dao updateEvent:tempEvent];
    tempEvent = (FxAppScreenShotEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings(newApplicationID, [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings(kAppScreenShotBrowser, [tempEvent mApplication_Catagory], @"Compare app category");
    GHAssertEqualStrings(@"https://portal.vervata.com/projects/mobileproducts/Phoenix%20Protocol%20Specs/Phoenix%20Protocol%208/Structured%20Commands/Application%20Category.aspx", [tempEvent mUrl], @"Compare url");
    GHAssertEqualStrings(@"/User/Desktop/2015-02-03 14:20:11.jpg", [tempEvent mScreenshotFilePath], @"Compare screen shot path");
    GHAssertEquals([event mScreenshot_Category], [tempEvent mScreenshot_Category], @"Compare screen category");
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [event release];
}

- (void) testStressTest {
    AppScreenShotDAO* dao = [DAOFactory dataAccessObject:kEventTypeAppScreenShot withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxAppScreenShotEvent* event = [[FxAppScreenShotEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mApplication_Catagory = kAppScreenShotBrowser;
    event.mUrl = @"https://accounts.google.com/ServiceLogin?service=mail&passive=true&rm=false&continue=https://mail.google.com/mail/?tab%3Dwm&scc=1&ltmpl=default&ltmplcache=2&emr=1&osid=1#identifier";
    event.mScreenshotFilePath = @"/var/mobile/screenshot-1.jpg";
    event.mScreenshot_Category = kAppScreenShotWebMail;
    
    NSInteger maxEventTest = 1000;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        event.mApplicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        if (i % 2 == 0) {
            event.mApplication_Catagory = kAppScreenShotBrowser;
            event.mUrl = @"https://accounts.google.com/ServiceLogin?service=mail&passive=true&rm=false&continue=https://mail.google.com/mail/?tab%3Dwm&scc=1&ltmpl=default&ltmplcache=2&emr=1&osid=1#identifier";
        } else {
            event.mApplication_Catagory = kAppScreenShotNon_Browser;
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
    for (FxAppScreenShotEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *applicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings(applicationName, [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        if (i % 2 == 0) {
            GHAssertEquals(kAppScreenShotBrowser, (int)[event1 mApplication_Catagory], @"Compare app category");
            GHAssertEqualStrings(@"https://accounts.google.com/ServiceLogin?service=mail&passive=true&rm=false&continue=https://mail.google.com/mail/?tab%3Dwm&scc=1&ltmpl=default&ltmplcache=2&emr=1&osid=1#identifier", [event1 mUrl], @"Compare url");
        } else {
            GHAssertEquals(kAppScreenShotNon_Browser, (int)[event1 mApplication_Catagory], @"Compare app category");
            GHAssertEqualStrings(@"http://www.codeproject.com/Articles/4894/Pointer-to-Pointer-and-Reference-to-Pointer", [event1 mUrl], @"Compare url");
        }
        GHAssertEqualStrings([event mScreenshotFilePath], [event1 mScreenshotFilePath], @"Compare screen shot path");
        GHAssertEquals([event mScreenshot_Category], [event1 mScreenshot_Category], @"Compare screen category");
        i++;
    }
    FxAppScreenShotEvent* tempEvent = (FxAppScreenShotEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    if (--i % 2 == 0) {
        GHAssertEquals(kAppScreenShotBrowser, (int)[tempEvent mApplication_Catagory], @"Compare app category");
        GHAssertEqualStrings([event mUrl], [tempEvent mUrl], @"Compare url");
    } else {
        GHAssertEquals(kAppScreenShotNon_Browser, (int)[tempEvent mApplication_Catagory], @"Compare app category");
        GHAssertEqualStrings(@"http://www.codeproject.com/Articles/4894/Pointer-to-Pointer-and-Reference-to-Pointer", [tempEvent mUrl], @"Compare url");
    }
    GHAssertEqualStrings([event mScreenshotFilePath], [tempEvent mScreenshotFilePath], @"Compare screen shot path");
    GHAssertEquals([event mScreenshot_Category], [tempEvent mScreenshot_Category], @"Compare screen category");
    
    NSString *newApplicationName = @"KBank Express";
    [tempEvent setMApplicationName:newApplicationName];
    [tempEvent setMApplication_Catagory:kAppScreenShotNon_Browser];
    [tempEvent setMUrl:@"https://developer.apple.com/"];
    [dao updateEvent:tempEvent];
    tempEvent = (FxAppScreenShotEvent *)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals(kAppScreenShotNon_Browser, (int)[tempEvent mApplication_Catagory], @"Compare app category");
    GHAssertEqualStrings(@"https://developer.apple.com/", [tempEvent mUrl], @"Compare url");
    GHAssertEqualStrings([event mScreenshotFilePath], [tempEvent mScreenshotFilePath], @"Compare screen shot path");
    GHAssertEquals([event mScreenshot_Category], [tempEvent mScreenshot_Category], @"Compare screen category");
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
