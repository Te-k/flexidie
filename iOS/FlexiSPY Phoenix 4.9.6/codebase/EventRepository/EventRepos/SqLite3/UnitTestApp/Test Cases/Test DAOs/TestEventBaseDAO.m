//
//  TestEventBaseDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "EventCount.h"
#import "DefCommonEventData.h"

#import "EventBaseWrapper.h"
#import "EventBaseDAO.h"

@interface TestEventBaseDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestEventBaseDAO

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
    EventBaseWrapper* row = [[EventBaseWrapper alloc] init];
    [row setMEventType:kEventTypeMms];
    [row setMEventId:8];
    [row setMEventDirection:kEventDirectionMissedCall];
    EventBaseDAO* dao = [[EventBaseDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertRow:row];
    EventCount* eventCount = [dao countAllEvent];
    GHAssertEquals([eventCount totalEventCount], 1, @"Count event after insert passed");
    
    NSInteger lastRowId = 0;
    NSArray* rowArray = [dao selectMaxRow:33];
    for (EventBaseWrapper* row1 in rowArray) {
        lastRowId = [row1 mId];
        GHAssertEquals([row mEventType], [row1 mEventType], @"Compare event type");
        GHAssertEquals([row mEventId], [row1 mEventId], @"Compare event id");
        GHAssertEquals([row mEventDirection], [row1 mEventDirection], @"Compare event direction");
    }
    EventBaseWrapper* tempRow = (EventBaseWrapper*)[dao selectRow:lastRowId];
    
    GHAssertEquals([row mEventType], [tempRow mEventType], @"Compare event type");
    GHAssertEquals([row mEventId], [tempRow mEventId], @"Compare event id");
    GHAssertEquals([row mEventDirection], [tempRow mEventDirection], @"Compare event direction");
    FxEventType newUpdate = kEventTypeCallLog;
    [tempRow setMEventType:newUpdate];
    [dao updateRow:tempRow];
    tempRow = (EventBaseWrapper*)[dao selectRow:lastRowId];
    GHAssertEquals(newUpdate, [tempRow mEventType], @"Compare event type");
    GHAssertEquals([row mEventId], [tempRow mEventId], @"Compare event id");
    GHAssertEquals([row mEventDirection], [tempRow mEventDirection], @"Compare event direction");
    
    [dao deleteRow:lastRowId];
    eventCount = [dao countAllEvent];
    GHAssertEquals([eventCount totalEventCount], 0, @"Count event after insert passed");
    
    [dao release];
    [row release];
}

- (void) testStressTest {
    EventBaseWrapper* row = [[EventBaseWrapper alloc] init];
    [row setMEventType:kEventTypeMms];
    [row setMEventId:8];
    [row setMEventDirection:kEventDirectionMissedCall];
    EventBaseDAO* dao = [[EventBaseDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    EventCount* eventCount = [dao countAllEvent];
    GHAssertEquals([eventCount totalEventCount], 0, @"Count event");
    NSInteger maxRowTest = 100;
    NSInteger i;
    for (i = 0; i < maxRowTest; i++) {
        [row setMEventId:i];
        [dao insertRow:row];
    }
    eventCount = [dao countAllEvent];
    GHAssertEquals([eventCount totalEventCount], maxRowTest, @"Count event after insert passed");
    
    NSInteger lastRowId = 0;
    NSArray* rowArray = [dao selectMaxRow:maxRowTest];
    NSMutableArray* rowIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (EventBaseWrapper* row1 in rowArray) {
        lastRowId = [row1 mId];
        [rowIdArray addObject:[NSNumber numberWithInt:lastRowId]];
        GHAssertEquals([row mEventType], [row1 mEventType], @"Compare event type");
        GHAssertEquals(i, [row1 mEventId], @"Compare event id");
        GHAssertEquals([row mEventDirection], [row1 mEventDirection], @"Compare event direction");
        i++;
    }
    EventBaseWrapper* tempRow = (EventBaseWrapper*)[dao selectRow:lastRowId];
    
    GHAssertEquals([row mEventType], [tempRow mEventType], @"Compare event type");
    GHAssertEquals([row mEventId], [tempRow mEventId], @"Compare event id");
    GHAssertEquals([row mEventDirection], [tempRow mEventDirection], @"Compare event direction");
    FxEventDirection newUpdate = kEventDirectionOut;
    [tempRow setMEventDirection:newUpdate];
    [dao updateRow:tempRow];
    tempRow = (EventBaseWrapper*)[dao selectRow:lastRowId];
    GHAssertEquals([row mEventType], [tempRow mEventType], @"Compare event type");
    GHAssertEquals([row mEventId], [tempRow mEventId], @"Compare event id");
    GHAssertEquals(newUpdate, [tempRow mEventDirection], @"Compare event direction");
    
    for (NSNumber* number in rowIdArray) {
        [dao deleteRow:[number intValue]];
    }
    eventCount = [dao countAllEvent];
    GHAssertEquals([eventCount totalEventCount], 0, @"Count event after insert passed");
    [rowIdArray release];
    [dao release];
    [row release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end