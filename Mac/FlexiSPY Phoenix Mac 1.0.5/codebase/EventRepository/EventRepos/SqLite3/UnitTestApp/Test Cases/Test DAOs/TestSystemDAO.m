//
//  TestSystemDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxSystemEvent.h"
#import "SystemDAO.h"

NSString* const kEventDateTime1  = @"11:11:11 2011-11-11";
NSString* const kSystemMessage  = @"[4200 -1.00.1 03-05-2011][OK]\nCommand being process";

@interface TestSystemDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestSystemDAO

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
    FxSystemEvent* systemEvent = [[FxSystemEvent alloc] init];
    systemEvent.dateTime = kEventDateTime1;
    [systemEvent setSystemEventType:kSystemEventTypeSmsCmd];
    systemEvent.direction = kEventDirectionOut;
    [systemEvent setMessage:kSystemMessage];
    SystemDAO* systemDAO = [DAOFactory dataAccessObject:[systemEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [systemDAO insertEvent:systemEvent];
    DetailedCount* detailedCount = [systemDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [systemDAO selectMaxEvent:33];
    for (FxSystemEvent* systemEvent1 in eventArray) {
        lastEventId = [systemEvent1 eventId];
        GHAssertEqualStrings([systemEvent dateTime], [systemEvent1 dateTime], @"Compare date time");
        GHAssertEqualStrings([systemEvent message], [systemEvent1 message], @"Compare message");
        GHAssertEquals([systemEvent direction], [systemEvent1 direction], @"Compare direction");
        GHAssertEquals([systemEvent systemEventType], [systemEvent1 systemEventType], @"Compare system event type");
    }
    FxSystemEvent* tempSystemEvent = (FxSystemEvent*)[systemDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([systemEvent dateTime], [tempSystemEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([systemEvent message], [tempSystemEvent message], @"Compare message");
    GHAssertEquals([systemEvent direction], [tempSystemEvent direction], @"Compare direction");
    GHAssertEquals([systemEvent systemEventType], [tempSystemEvent systemEventType], @"Compare system event type");
    FxSystemEventType newSystemEventType = kSystemEventTypeNextCmdReply;
    [tempSystemEvent setSystemEventType:newSystemEventType];
    [systemDAO updateEvent:tempSystemEvent];
    tempSystemEvent = (FxSystemEvent*)[systemDAO selectEvent:lastEventId];
    GHAssertEqualStrings([systemEvent dateTime], [tempSystemEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([systemEvent message], [tempSystemEvent message], @"Compare message");
    GHAssertEquals([systemEvent direction], [tempSystemEvent direction], @"Compare direction");
    GHAssertEquals(newSystemEventType, [tempSystemEvent systemEventType], @"Compare system event type");
    
    [systemDAO deleteEvent:lastEventId];
    detailedCount = [systemDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    
    [systemEvent release];
}

- (void) testStressTest {
    SystemDAO* systemDAO = [DAOFactory dataAccessObject:kEventTypeSystem withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [systemDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxSystemEvent* systemEvent = [[FxSystemEvent alloc] init];
    systemEvent.dateTime = kEventDateTime1;
    [systemEvent setSystemEventType:kSystemEventTypeSmsCmd];
    systemEvent.direction = kEventDirectionOut;
    [systemEvent setMessage:kSystemMessage];
    NSInteger maxEventTest = 100;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        [systemEvent setMessage:[NSString stringWithFormat:@"%d", i]];
        [systemDAO insertEvent:systemEvent];
    }
    detailedCount = [systemDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [systemDAO selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxSystemEvent* systemEvent1 in eventArray) {
        lastEventId = [systemEvent1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEqualStrings([systemEvent dateTime], [systemEvent1 dateTime], @"Compare date time");
        NSString* string = [NSString stringWithFormat:@"%d", i];
        GHAssertEqualStrings(string, [systemEvent1 message], @"Compare message");
        GHAssertEquals([systemEvent direction], [systemEvent1 direction], @"Compare direction");
        GHAssertEquals([systemEvent systemEventType], [systemEvent1 systemEventType], @"Compare system event type");
        i++;
    }
    FxSystemEvent* tempSystemEvent = (FxSystemEvent*)[systemDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([systemEvent dateTime], [tempSystemEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([systemEvent message], [tempSystemEvent message], @"Compare message");
    GHAssertEquals([systemEvent direction], [tempSystemEvent direction], @"Compare direction");
    GHAssertEquals([systemEvent systemEventType], [tempSystemEvent systemEventType], @"Compare system event type");
    FxSystemEventType newSystemEventType = kSystemEventTypeNextCmdReply;
    [tempSystemEvent setSystemEventType:newSystemEventType];
    [systemDAO updateEvent:tempSystemEvent];
    tempSystemEvent = (FxSystemEvent*)[systemDAO selectEvent:lastEventId];
    GHAssertEqualStrings([systemEvent dateTime], [tempSystemEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([systemEvent message], [tempSystemEvent message], @"Compare message");
    GHAssertEquals([systemEvent direction], [tempSystemEvent direction], @"Compare direction");
    GHAssertEquals(newSystemEventType, [tempSystemEvent systemEventType], @"Compare system event type");
    
    for (NSNumber* number in eventIdArray) {
        [systemDAO deleteEvent:[number intValue]];
    }
    detailedCount = [systemDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    [eventIdArray release];
    [systemEvent release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
