//
//  TestBrowserUrlDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 5/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "DAOFactory.h"
#import "BrowserUrlDAO.h"
#import "FxBrowserUrlEvent.h"

NSString* const kBrowserUrlDateTime = @"20-09-2011 11:08:11 AM";

@interface TestBrowserUrlDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestBrowserUrlDAO

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

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

- (void) testNormalTest {
    FxBrowserUrlEvent* event = [[FxBrowserUrlEvent alloc] init];
    [event setDateTime:kBrowserUrlDateTime];
    [event setMTitle:@"Network Programming: Chapter 11"];
    [event setMUrl:@"http://oreilly.com/iphone/excerpts/iphone-sdk/network-programming.html"];
    [event setMVisitTime:kBrowserUrlDateTime];
    [event setMIsBlocked:NO];
    [event setMOwningApp:@"MobileSafari"];
    
    BrowserUrlDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    NSInteger lastInsertedRowId = 0;
    [dao insertEvent:event];
    
    lastInsertedRowId = [mDatabaseManager lastInsertRowId];
    
    DetailedCount* detailedCount = [dao countEvent];
    
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxBrowserUrlEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEqualStrings([event mUrl], [event1 mUrl], @"Compare url");
        GHAssertEqualStrings([event mVisitTime], [event1 mVisitTime], @"Compare visit time");
        GHAssertEquals([event mIsBlocked], [event1 mIsBlocked], @"Compare is blocked flag");
        GHAssertEqualStrings([event mOwningApp], [event1 mOwningApp], @"Compare owning app");
    }
    
    FxBrowserUrlEvent* tmpEvent = (FxBrowserUrlEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mTitle], [tmpEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mUrl], [tmpEvent mUrl], @"Compare url");
    GHAssertEqualStrings([event mVisitTime], [tmpEvent mVisitTime], @"Compare visit time");
    GHAssertEquals([event mIsBlocked], [tmpEvent mIsBlocked], @"Compare is blocked flag");
    GHAssertEqualStrings([event mOwningApp], [tmpEvent mOwningApp], @"Compare owning app");
    
    NSString* newUpdate = @"www.google.com";
    [tmpEvent setMUrl:newUpdate];
    [dao updateEvent:tmpEvent];
    tmpEvent = (FxBrowserUrlEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mTitle], [tmpEvent mTitle], @"Compare title");
    GHAssertEqualStrings(newUpdate, [tmpEvent mUrl], @"Compare url");
    GHAssertEqualStrings([event mVisitTime], [tmpEvent mVisitTime], @"Compare visit time");
    GHAssertEquals([event mIsBlocked], [tmpEvent mIsBlocked], @"Compare is blocked flag");
    GHAssertEqualStrings([event mOwningApp], [tmpEvent mOwningApp], @"Compare owning app");
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after update passed");
    [dao deleteEvent:192039]; // No exception when execute delete sql with not found event id
    [dao deleteEvent:lastEventId];
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [event release];
}

- (void) testStressTest {
    FxBrowserUrlEvent* event = [[FxBrowserUrlEvent alloc] init];
    [event setDateTime:kBrowserUrlDateTime];
    [event setMTitle:@"Network Programming: Chapter 11"];
    [event setMUrl:@"http://oreilly.com/iphone/excerpts/iphone-sdk/network-programming.html"];
    [event setMVisitTime:kBrowserUrlDateTime];
    [event setMIsBlocked:NO];
    [event setMOwningApp:@"MobileSafari"];
    
    BrowserUrlDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    
    NSInteger maxInsertEvent = 100;
    NSInteger i;
    for (i = 0; i < maxInsertEvent; i++) {
        NSInteger lastInsertedRowId = 0;
        [event setMTitle:[NSString stringWithFormat:@"Network Programming: Chapter %d", i]];
        [event setMUrl:[NSString stringWithFormat:@"http://oreilly.com/iphone/excerpts/iphone-sdk/network-programming-%d.html", i]];
        [dao insertEvent:event];
        
        lastInsertedRowId = [mDatabaseManager lastInsertRowId];
    }
    
    DetailedCount* detailedCount = [dao countEvent];
    
    GHAssertEquals([detailedCount totalCount], maxInsertEvent, @"Count event after insert passed");
    
    i = 0;
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:maxInsertEvent];
    NSMutableArray* eventIdArray = [NSMutableArray array];
    for (FxBrowserUrlEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        
        NSString* test = [NSString stringWithFormat:@"Network Programming: Chapter %d", i];
        GHAssertEqualStrings(test, [event1 mTitle], @"Compare title");
        test = [NSString stringWithFormat:@"http://oreilly.com/iphone/excerpts/iphone-sdk/network-programming-%d.html", i];
        GHAssertEqualStrings(test, [event1 mUrl], @"Compare url");
        GHAssertEqualStrings([event mVisitTime], [event1 mVisitTime], @"Compare visit time");
        GHAssertEquals([event mIsBlocked], [event1 mIsBlocked], @"Compare is blocked flag");
        GHAssertEqualStrings([event mOwningApp], [event1 mOwningApp], @"Compare owning app");
        i++;
    }
    
    FxBrowserUrlEvent* tmpEvent = (FxBrowserUrlEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mTitle], [tmpEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mUrl], [tmpEvent mUrl], @"Compare url");
    GHAssertEqualStrings([event mVisitTime], [tmpEvent mVisitTime], @"Compare visit time");
    GHAssertEquals([event mIsBlocked], [tmpEvent mIsBlocked], @"Compare is blocked flag");
    GHAssertEqualStrings([event mOwningApp], [tmpEvent mOwningApp], @"Compare owning app");
    NSString* newUpdate = @"www.google.com";
    [tmpEvent setMUrl:newUpdate];
    [dao updateEvent:tmpEvent];
    tmpEvent = (FxBrowserUrlEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mTitle], [tmpEvent mTitle], @"Compare title");
    GHAssertEqualStrings(newUpdate, [tmpEvent mUrl], @"Compare url");
    GHAssertEqualStrings([event mVisitTime], [tmpEvent mVisitTime], @"Compare visit time");
    GHAssertEquals([event mIsBlocked], [tmpEvent mIsBlocked], @"Compare is blocked flag");
    GHAssertEqualStrings([event mOwningApp], [tmpEvent mOwningApp], @"Compare owning app");

    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxInsertEvent, @"Count event after update passed");
    [dao deleteEvent:192039]; // No exception when execute delete sql with not found event id
    [dao deleteEvent:lastEventId];
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxInsertEvent - 1, @"Count event after delete passed");
        
    for (NSNumber* number in eventIdArray) {
        [dao deleteEvent:[number intValue]];
    }
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
        
    [event release];
}

@end
