//
//  TestIMAccountDAO.m
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
#import "IMAccountDAO.h"

#import "FxIMAccountEvent.h"

static NSString * const kEventDateTime = @"11:11:11 2011-11-11";

@interface TestIMAccountDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestIMAccountDAO

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
    FxIMAccountEvent* imAccountEvent = [[FxIMAccountEvent alloc] init];
    imAccountEvent.dateTime = kEventDateTime;
    imAccountEvent.mServiceID = kIMServiceBBM;
    imAccountEvent.mAccountID = @"makarakhloth@gmail.com";
    imAccountEvent.mDisplayName = @"Makara KHLOTH";
    imAccountEvent.mStatusMessage = @"Where is the perfect world?";
    imAccountEvent.mPicture = [NSData data];
    IMAccountDAO* imAccountDAO = [DAOFactory dataAccessObject:[imAccountEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [imAccountDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event before insert passed");
    [imAccountDAO insertEvent:imAccountEvent];
    detailedCount = [imAccountDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [imAccountDAO selectMaxEvent:33];
    for (FxIMAccountEvent* imAccountEvent1 in eventArray) {
        lastEventId = [imAccountEvent1 eventId];
        GHAssertEqualStrings([imAccountEvent dateTime], [imAccountEvent1 dateTime], @"Compare date time");
        GHAssertEquals([imAccountEvent mServiceID], [imAccountEvent1 mServiceID], @"Compare service id");
        GHAssertEqualStrings([imAccountEvent mAccountID], [imAccountEvent1 mAccountID], @"Compare account id");
        GHAssertEqualStrings([imAccountEvent mDisplayName], [imAccountEvent1 mDisplayName], @"Compare display name");
        GHAssertEqualStrings([imAccountEvent mStatusMessage], [imAccountEvent1 mStatusMessage], @"Compare status message");
        NSData *data1 = [imAccountEvent mPicture];
        NSData *data2 = [imAccountEvent1 mPicture];
        GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
    }
    FxIMAccountEvent* tempIMAccountEvent = (FxIMAccountEvent *)[imAccountDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([imAccountEvent dateTime], [tempIMAccountEvent dateTime], @"Compare date time");
    GHAssertEquals([imAccountEvent mServiceID], [tempIMAccountEvent mServiceID], @"Compare service id");
    GHAssertEqualStrings([imAccountEvent mAccountID], [tempIMAccountEvent mAccountID], @"Compare account id");
    GHAssertEqualStrings([imAccountEvent mDisplayName], [tempIMAccountEvent mDisplayName], @"Compare display name");
    GHAssertEqualStrings([imAccountEvent mStatusMessage], [tempIMAccountEvent mStatusMessage], @"Compare status message");
    NSData *data1 = [imAccountEvent mPicture];
    NSData *data2 = [tempIMAccountEvent mPicture];
    GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");

    NSString *newStatusMessage = @"Where is the hell?";
    [tempIMAccountEvent setMStatusMessage:newStatusMessage];
    [imAccountDAO updateEvent:tempIMAccountEvent];
    tempIMAccountEvent = (FxIMAccountEvent *)[imAccountDAO selectEvent:lastEventId];
    GHAssertEqualStrings([imAccountEvent dateTime], [tempIMAccountEvent dateTime], @"Compare date time");
    GHAssertEquals([imAccountEvent mServiceID], [tempIMAccountEvent mServiceID], @"Compare service id");
    GHAssertEqualStrings([imAccountEvent mAccountID], [tempIMAccountEvent mAccountID], @"Compare account id");
    GHAssertEqualStrings([imAccountEvent mDisplayName], [tempIMAccountEvent mDisplayName], @"Compare display name");
    GHAssertEqualStrings(newStatusMessage, [tempIMAccountEvent mStatusMessage], @"Compare status message");
    data1 = [imAccountEvent mPicture];
    data2 = [tempIMAccountEvent mPicture];
    GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
    
    [imAccountDAO deleteEvent:lastEventId];
    detailedCount = [imAccountDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    
    [imAccountEvent release];
}

- (void) testStressTest {
    FxIMAccountEvent* imAccountEvent = [[FxIMAccountEvent alloc] init];
    imAccountEvent.dateTime = kEventDateTime;
    imAccountEvent.mServiceID = kIMServiceBBM;
    imAccountEvent.mAccountID = @"makarakhloth@gmail.com";
    imAccountEvent.mDisplayName = @"Makara KHLOTH";
    imAccountEvent.mStatusMessage = @"Where is the perfect world?";
    imAccountEvent.mPicture = [NSData data];
    IMAccountDAO* imAccountDAO = [DAOFactory dataAccessObject:[imAccountEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [imAccountDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event before insert passed");
    NSInteger maxEventTest = 100;
    for (NSInteger i = 0; i < maxEventTest; i++) {
        NSString *statusMsg = [NSString stringWithFormat:@"Where is the perfect world %d?", i];
        [imAccountEvent setMStatusMessage:statusMsg];
        [imAccountDAO insertEvent:imAccountEvent];
    }
    detailedCount = [imAccountDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger i = 0;
    NSInteger lastEventId = 0;
    NSMutableArray *eventIdArray = [NSMutableArray arrayWithCapacity:maxEventTest];
    NSArray* eventArray = [imAccountDAO selectMaxEvent:maxEventTest];
    for (FxIMAccountEvent* imAccountEvent1 in eventArray) {
        lastEventId = [imAccountEvent1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *statusMsg = [NSString stringWithFormat:@"Where is the perfect world %d?", i];
        GHAssertEqualStrings([imAccountEvent dateTime], [imAccountEvent1 dateTime], @"Compare date time");
        GHAssertEquals([imAccountEvent mServiceID], [imAccountEvent1 mServiceID], @"Compare service id");
        GHAssertEqualStrings([imAccountEvent mAccountID], [imAccountEvent1 mAccountID], @"Compare account id");
        GHAssertEqualStrings([imAccountEvent mDisplayName], [imAccountEvent1 mDisplayName], @"Compare display name");
        GHAssertEqualStrings(statusMsg, [imAccountEvent1 mStatusMessage], @"Compare status message");
        NSData *data1 = [imAccountEvent mPicture];
        NSData *data2 = [imAccountEvent1 mPicture];
        GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
        i++;
    }
    FxIMAccountEvent* tempIMAccountEvent = (FxIMAccountEvent *)[imAccountDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([imAccountEvent dateTime], [tempIMAccountEvent dateTime], @"Compare date time");
    GHAssertEquals([imAccountEvent mServiceID], [tempIMAccountEvent mServiceID], @"Compare service id");
    GHAssertEqualStrings([imAccountEvent mAccountID], [tempIMAccountEvent mAccountID], @"Compare account id");
    GHAssertEqualStrings([imAccountEvent mDisplayName], [tempIMAccountEvent mDisplayName], @"Compare display name");
    NSString *statusMsg = [NSString stringWithFormat:@"Where is the perfect world %d?", maxEventTest - 1];
    GHAssertEqualStrings(statusMsg, [tempIMAccountEvent mStatusMessage], @"Compare status message");
    NSData *data1 = [imAccountEvent mPicture];
    NSData *data2 = [tempIMAccountEvent mPicture];
    GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
    
    NSString *newStatusMessage = @"Where is the hell?";
    [tempIMAccountEvent setMStatusMessage:newStatusMessage];
    [imAccountDAO updateEvent:tempIMAccountEvent];
    tempIMAccountEvent = (FxIMAccountEvent *)[imAccountDAO selectEvent:lastEventId];
    GHAssertEqualStrings([imAccountEvent dateTime], [tempIMAccountEvent dateTime], @"Compare date time");
    GHAssertEquals([imAccountEvent mServiceID], [tempIMAccountEvent mServiceID], @"Compare service id");
    GHAssertEqualStrings([imAccountEvent mAccountID], [tempIMAccountEvent mAccountID], @"Compare account id");
    GHAssertEqualStrings([imAccountEvent mDisplayName], [tempIMAccountEvent mDisplayName], @"Compare display name");
    GHAssertEqualStrings(newStatusMessage, [tempIMAccountEvent mStatusMessage], @"Compare status message");
    data1 = [imAccountEvent mPicture];
    data2 = [tempIMAccountEvent mPicture];
    GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
    
    for (NSNumber *eventId in eventIdArray) {
        [imAccountDAO deleteEvent:[eventId intValue]];
    }
    detailedCount = [imAccountDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    
    [imAccountEvent release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
