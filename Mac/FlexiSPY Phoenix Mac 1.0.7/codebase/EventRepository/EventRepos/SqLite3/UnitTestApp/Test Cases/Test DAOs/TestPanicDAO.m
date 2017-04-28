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

#import "FxPanicEvent.h"
#import "PanicDAO.h"

NSString* const kEventDateTime2  = @"11:11:11 2011-11-11";

@interface TestPanicDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestPanicDAO

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
    FxPanicEvent* event = [[FxPanicEvent alloc] init];
    event.dateTime = kEventDateTime2;
    [event setPanicStatus:kFxPanicStatusStart];
    PanicDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxPanicEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event panicStatus], [event1 panicStatus], @"Compare panic status");
    }
    FxPanicEvent* tempEvent = (FxPanicEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEquals([event panicStatus], [tempEvent panicStatus], @"Compare panic status");
    FxPanicStatus newUpdate = kFxPanicStatusStop;
    [tempEvent setPanicStatus:newUpdate];
    [dao updateEvent:tempEvent];
    tempEvent = (FxPanicEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEquals(newUpdate, [tempEvent panicStatus], @"Compare panic status");
    
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    
    [event release];
}

- (void) testStressTest {
    PanicDAO* dao = [DAOFactory dataAccessObject:kEventTypePanic withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxPanicEvent* event = [[FxPanicEvent alloc] init];
    event.dateTime = kEventDateTime2;
    [event setPanicStatus:kFxPanicStatusStart];
    NSInteger maxEventTest = 100;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        [event setDateTime:[NSString stringWithFormat:@"11:11:11 2%d-11-11", i]];
        [dao insertEvent:event];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxPanicEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString* string = [NSString stringWithFormat:@"11:11:11 2%d-11-11", i];
        GHAssertEqualStrings(string, [event1 dateTime], @"Compare date time");
        GHAssertEquals([event panicStatus], [event1 panicStatus], @"Compare panic status");
        i++;
    }
    FxPanicEvent* tempEvent = (FxPanicEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEquals([event panicStatus], [tempEvent panicStatus], @"Compare panic status");
    FxPanicStatus newUpdate = kFxPanicStatusStop;
    [tempEvent setPanicStatus:newUpdate];
    [dao updateEvent:tempEvent];
    tempEvent = (FxPanicEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEquals(newUpdate, [tempEvent panicStatus], @"Compare panic status");
    
    for (NSNumber* number in eventIdArray) {
        [dao deleteEvent:[number intValue]];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    [eventIdArray release];
    [event release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
