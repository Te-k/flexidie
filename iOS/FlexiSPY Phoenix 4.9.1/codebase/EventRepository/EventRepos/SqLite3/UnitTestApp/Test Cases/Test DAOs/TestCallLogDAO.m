//
//  TestCallLogDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxCallLogEvent.h"
#import "CallLogDAO.h"

NSString* const kEventDateTime  = @"11:11:11 2011-11-11";
NSString* const kContactName    = @"Mr. Makara KHLOTH";
NSString* const kContactNumber  = @"+66860843742";


@interface TestCallLogDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestCallLogDAO

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
    FxCallLogEvent* callLogEvent = [[FxCallLogEvent alloc] init];
    callLogEvent.dateTime = kEventDateTime;
    callLogEvent.contactName = kContactName;
    callLogEvent.contactNumber = kContactNumber;
    callLogEvent.direction = kEventDirectionIn;
    callLogEvent.duration = 399;
    CallLogDAO* callLogDAO = [DAOFactory dataAccessObject:[callLogEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [callLogDAO insertEvent:callLogEvent];
    DetailedCount* detailedCount = [callLogDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [callLogDAO selectMaxEvent:33];
    for (FxCallLogEvent* callLogEvent1 in eventArray) {
        lastEventId = [callLogEvent1 eventId];
        GHAssertEqualStrings([callLogEvent dateTime], [callLogEvent1 dateTime], @"Compare date time");
        GHAssertEqualStrings([callLogEvent contactName], [callLogEvent1 contactName], @"Compare contact name");
        GHAssertEqualStrings([callLogEvent contactNumber], [callLogEvent1 contactNumber], @"Compare contact number");
        GHAssertEquals([callLogEvent direction], [callLogEvent1 direction], @"Compare direction");
        GHAssertEquals([callLogEvent duration], [callLogEvent1 duration], @"Compare duration");
    }
    FxCallLogEvent* tempCallLogEvent = (FxCallLogEvent*)[callLogDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([callLogEvent dateTime], [tempCallLogEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([callLogEvent contactName], [tempCallLogEvent contactName], @"Compare contact name");
    GHAssertEqualStrings([callLogEvent contactNumber], [tempCallLogEvent contactNumber], @"Compare contact number");
    GHAssertEquals([callLogEvent direction], [tempCallLogEvent direction], @"Compare direction");
    GHAssertEquals([callLogEvent duration], [tempCallLogEvent duration], @"Compare duration");
    NSUInteger newDuration = 500;
    [tempCallLogEvent setDuration:newDuration];
    [callLogDAO updateEvent:tempCallLogEvent];
    tempCallLogEvent = (FxCallLogEvent*)[callLogDAO selectEvent:lastEventId];
    GHAssertEqualStrings([callLogEvent dateTime], [tempCallLogEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([callLogEvent contactName], [tempCallLogEvent contactName], @"Compare contact name");
    GHAssertEqualStrings([callLogEvent contactNumber], [tempCallLogEvent contactNumber], @"Compare contact number");
    GHAssertEquals([callLogEvent direction], [tempCallLogEvent direction], @"Compare direction");
    GHAssertEquals([tempCallLogEvent duration], newDuration, @"Compare duration");
    
    [callLogDAO deleteEvent:lastEventId];
    detailedCount = [callLogDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    
    [callLogEvent release];
}

- (void) testStressTest {
    CallLogDAO* callLogDAO = [DAOFactory dataAccessObject:kEventTypeCallLog withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [callLogDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxCallLogEvent* callLogEvent = [[FxCallLogEvent alloc] init];
    callLogEvent.dateTime = kEventDateTime;
    callLogEvent.contactName = kContactName;
    callLogEvent.contactNumber = kContactNumber;
    callLogEvent.direction = kEventDirectionIn;
    NSInteger maxEventTest = 100;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        callLogEvent.duration = i;
        [callLogDAO insertEvent:callLogEvent];
    }
    detailedCount = [callLogDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [callLogDAO selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxCallLogEvent* callLogEvent1 in eventArray) {
        lastEventId = [callLogEvent1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEqualStrings([callLogEvent dateTime], [callLogEvent1 dateTime], @"Compare date time");
        GHAssertEqualStrings([callLogEvent contactName], [callLogEvent1 contactName], @"Compare contact name");
        GHAssertEqualStrings([callLogEvent contactNumber], [callLogEvent1 contactNumber], @"Compare contact number");
        GHAssertEquals([callLogEvent direction], [callLogEvent1 direction], @"Compare direction");
        NSUInteger duration = i;
        GHAssertEquals(duration, [callLogEvent1 duration], @"Compare duration");
        i++;
    }
    FxCallLogEvent* tempCallLogEvent = (FxCallLogEvent*)[callLogDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([callLogEvent dateTime], [tempCallLogEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([callLogEvent contactName], [tempCallLogEvent contactName], @"Compare contact name");
    GHAssertEqualStrings([callLogEvent contactNumber], [tempCallLogEvent contactNumber], @"Compare contact number");
    GHAssertEquals([callLogEvent direction], [tempCallLogEvent direction], @"Compare direction");
    GHAssertEquals([callLogEvent duration], [tempCallLogEvent duration], @"Compare duration");
    NSUInteger newDuration = 500;
    [tempCallLogEvent setDuration:newDuration];
    [callLogDAO updateEvent:tempCallLogEvent];
    tempCallLogEvent = (FxCallLogEvent*)[callLogDAO selectEvent:lastEventId];
    GHAssertEqualStrings([callLogEvent dateTime], [tempCallLogEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([callLogEvent contactName], [tempCallLogEvent contactName], @"Compare contact name");
    GHAssertEqualStrings([callLogEvent contactNumber], [tempCallLogEvent contactNumber], @"Compare contact number");
    GHAssertEquals([callLogEvent direction], [tempCallLogEvent direction], @"Compare direction");
    GHAssertEquals([tempCallLogEvent duration], newDuration, @"Compare duration");
    
    for (NSNumber* number in eventIdArray) {
        [callLogDAO deleteEvent:[number intValue]];
    }
    detailedCount = [callLogDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    [eventIdArray release];
    [callLogEvent release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end