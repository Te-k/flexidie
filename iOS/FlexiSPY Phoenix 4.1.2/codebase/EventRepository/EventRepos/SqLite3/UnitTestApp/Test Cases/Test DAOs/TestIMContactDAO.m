//
//  TestIMContactDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 2/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "DAOFactory.h"
#import "IMContactDAO.h"

#import "FxIMContactEvent.h"

static NSString * const kEventDateTime = @"11:11:11 2011-11-11";

@interface TestIMContactDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestIMContactDAO

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
    FxIMContactEvent* imContactEvent = [[FxIMContactEvent alloc] init];
    imContactEvent.dateTime = kEventDateTime;
    imContactEvent.mServiceID = kIMServiceBBM;
    imContactEvent.mAccountID = @"makarakhloth@gmail.com";
    imContactEvent.mContactID = @"kh_makara";
    imContactEvent.mDisplayName = @"Makara KHLOTH";
    imContactEvent.mStatusMessage = @"Where is the perfect world?";
    imContactEvent.mPicture = [NSData data];
    IMContactDAO* imContactDAO = [DAOFactory dataAccessObject:[imContactEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [imContactDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event before insert passed");
    [imContactDAO insertEvent:imContactEvent];
    detailedCount = [imContactDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [imContactDAO selectMaxEvent:33];
    for (FxIMContactEvent* imContactEvent1 in eventArray) {
        lastEventId = [imContactEvent1 eventId];
        GHAssertEqualStrings([imContactEvent dateTime], [imContactEvent1 dateTime], @"Compare date time");
        GHAssertEquals([imContactEvent mServiceID], [imContactEvent1 mServiceID], @"Compare service id");
        GHAssertEqualStrings([imContactEvent mAccountID], [imContactEvent1 mAccountID], @"Compare account id");
        GHAssertEqualStrings([imContactEvent mContactID], [imContactEvent1 mContactID], @"Compare contact id");
        GHAssertEqualStrings([imContactEvent mDisplayName], [imContactEvent1 mDisplayName], @"Compare display name");
        GHAssertEqualStrings([imContactEvent mStatusMessage], [imContactEvent1 mStatusMessage], @"Compare status message");
        NSData *data1 = [imContactEvent mPicture];
        NSData *data2 = [imContactEvent1 mPicture];
        GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
    }
    FxIMContactEvent* tempIMContactEvent = (FxIMContactEvent *)[imContactDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([imContactEvent dateTime], [tempIMContactEvent dateTime], @"Compare date time");
    GHAssertEquals([imContactEvent mServiceID], [tempIMContactEvent mServiceID], @"Compare service id");
    GHAssertEqualStrings([imContactEvent mAccountID], [tempIMContactEvent mAccountID], @"Compare account id");
    GHAssertEqualStrings([imContactEvent mContactID], [tempIMContactEvent mContactID], @"Compare contact id");
    GHAssertEqualStrings([imContactEvent mDisplayName], [tempIMContactEvent mDisplayName], @"Compare display name");
    GHAssertEqualStrings([imContactEvent mStatusMessage], [tempIMContactEvent mStatusMessage], @"Compare status message");
    NSData *data1 = [imContactEvent mPicture];
    NSData *data2 = [tempIMContactEvent mPicture];
    GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
    
    NSString *newStatusMessage = @"Where is the hell?";
    [tempIMContactEvent setMStatusMessage:newStatusMessage];
    [imContactDAO updateEvent:tempIMContactEvent];
    tempIMContactEvent = (FxIMContactEvent *)[imContactDAO selectEvent:lastEventId];
    GHAssertEqualStrings([imContactEvent dateTime], [tempIMContactEvent dateTime], @"Compare date time");
    GHAssertEquals([imContactEvent mServiceID], [tempIMContactEvent mServiceID], @"Compare service id");
    GHAssertEqualStrings([imContactEvent mAccountID], [tempIMContactEvent mAccountID], @"Compare account id");
    GHAssertEqualStrings([imContactEvent mContactID], [tempIMContactEvent mContactID], @"Compare contact id");
    GHAssertEqualStrings([imContactEvent mDisplayName], [tempIMContactEvent mDisplayName], @"Compare display name");
    GHAssertEqualStrings(newStatusMessage, [tempIMContactEvent mStatusMessage], @"Compare status message");
    data1 = [imContactEvent mPicture];
    data2 = [tempIMContactEvent mPicture];
    GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
    
    [imContactDAO deleteEvent:lastEventId];
    detailedCount = [imContactDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    
    [imContactEvent release];
}

- (void) testStressTest {
    FxIMContactEvent* imContactEvent = [[FxIMContactEvent alloc] init];
    imContactEvent.dateTime = kEventDateTime;
    imContactEvent.mServiceID = kIMServiceBBM;
    imContactEvent.mAccountID = @"makarakhloth@gmail.com";
    imContactEvent.mContactID = @"kh_makara";
    imContactEvent.mDisplayName = @"Makara KHLOTH";
    imContactEvent.mStatusMessage = @"Where is the perfect world?";
    imContactEvent.mPicture = [NSData data];
    IMContactDAO* imContactDAO = [DAOFactory dataAccessObject:[imContactEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [imContactDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event before insert passed");
    NSInteger maxEventTest = 100;
    for (NSInteger i = 0; i < maxEventTest; i++) {
        NSString *statusMsg = [NSString stringWithFormat:@"Where is the perfect world %d?", i];
        [imContactEvent setMStatusMessage:statusMsg];
        [imContactDAO insertEvent:imContactEvent];
    }
    detailedCount = [imContactDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger i = 0;
    NSInteger lastEventId = 0;
    NSMutableArray *eventIdArray = [NSMutableArray arrayWithCapacity:maxEventTest];
    NSArray* eventArray = [imContactDAO selectMaxEvent:maxEventTest];
    for (FxIMContactEvent* imContactEvent1 in eventArray) {
        lastEventId = [imContactEvent1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *statusMsg = [NSString stringWithFormat:@"Where is the perfect world %d?", i];
        GHAssertEqualStrings([imContactEvent dateTime], [imContactEvent1 dateTime], @"Compare date time");
        GHAssertEquals([imContactEvent mServiceID], [imContactEvent1 mServiceID], @"Compare service id");
        GHAssertEqualStrings([imContactEvent mContactID], [imContactEvent1 mContactID], @"Compare contact id");
        GHAssertEqualStrings([imContactEvent mAccountID], [imContactEvent1 mAccountID], @"Compare account id");
        GHAssertEqualStrings([imContactEvent mDisplayName], [imContactEvent1 mDisplayName], @"Compare display name");
        GHAssertEqualStrings(statusMsg, [imContactEvent1 mStatusMessage], @"Compare status message");
        NSData *data1 = [imContactEvent mPicture];
        NSData *data2 = [imContactEvent1 mPicture];
        GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
        i++;
    }
    FxIMContactEvent* tempIMContactEvent = (FxIMContactEvent *)[imContactDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([imContactEvent dateTime], [tempIMContactEvent dateTime], @"Compare date time");
    GHAssertEquals([imContactEvent mServiceID], [tempIMContactEvent mServiceID], @"Compare service id");
    GHAssertEqualStrings([imContactEvent mAccountID], [tempIMContactEvent mAccountID], @"Compare account id");
    GHAssertEqualStrings([imContactEvent mContactID], [tempIMContactEvent mContactID], @"Compare contact id");
    GHAssertEqualStrings([imContactEvent mDisplayName], [tempIMContactEvent mDisplayName], @"Compare display name");
    NSString *statusMsg = [NSString stringWithFormat:@"Where is the perfect world %d?", maxEventTest - 1];
    GHAssertEqualStrings(statusMsg, [tempIMContactEvent mStatusMessage], @"Compare status message");
    NSData *data1 = [imContactEvent mPicture];
    NSData *data2 = [tempIMContactEvent mPicture];
    GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
    
    NSString *newStatusMessage = @"Where is the hell?";
    [tempIMContactEvent setMStatusMessage:newStatusMessage];
    [imContactDAO updateEvent:tempIMContactEvent];
    tempIMContactEvent = (FxIMContactEvent *)[imContactDAO selectEvent:lastEventId];
    GHAssertEqualStrings([imContactEvent dateTime], [tempIMContactEvent dateTime], @"Compare date time");
    GHAssertEquals([imContactEvent mServiceID], [tempIMContactEvent mServiceID], @"Compare service id");
    GHAssertEqualStrings([imContactEvent mAccountID], [tempIMContactEvent mAccountID], @"Compare account id");
    GHAssertEqualStrings([imContactEvent mContactID], [tempIMContactEvent mContactID], @"Compare contact id");
    GHAssertEqualStrings([imContactEvent mDisplayName], [tempIMContactEvent mDisplayName], @"Compare display name");
    GHAssertEqualStrings(newStatusMessage, [tempIMContactEvent mStatusMessage], @"Compare status message");
    data1 = [imContactEvent mPicture];
    data2 = [tempIMContactEvent mPicture];
    GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
    
    for (NSNumber *eventId in eventIdArray) {
        [imContactDAO deleteEvent:[eventId intValue]];
    }
    detailedCount = [imContactDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    
    [imContactEvent release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
