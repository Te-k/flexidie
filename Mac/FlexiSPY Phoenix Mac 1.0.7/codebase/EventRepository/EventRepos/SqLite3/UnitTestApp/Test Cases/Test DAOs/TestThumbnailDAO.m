//
//  TestThumbnailDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "DAOFactory.h"
#import "ThumbnailDAO.h"
#import "FxThumbnailEvent.h"

@interface TestThumbnailDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestThumbnailDAO

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
    FxThumbnailEvent* event = [[FxThumbnailEvent alloc] init];
    [event setPairId:1];
    [event setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.gif"];
    [event setActualSize:46246823];
    [event setActualDuration:234];
    
    // Insert gps tag
    ThumbnailDAO* dao = [DAOFactory dataAccessObject:kEventTypeCameraImageThumbnail withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    
    DetailedCount* detailedCount = [dao countEvent];
    
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxThumbnailEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEquals([event pairId], [event1 pairId], @"Compare pair id");
        GHAssertEquals([event actualSize], [event1 actualSize], @"Compare actual size");
        GHAssertEquals([event actualDuration], [event1 actualDuration], @"Compare actual duration");
        GHAssertEqualStrings([event fullPath], [event1 fullPath], @"Compare full path");
    }
    
    FxThumbnailEvent* tmpEvent = (FxThumbnailEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEquals([event pairId], [tmpEvent pairId], @"Compare pair id");
    GHAssertEquals([event actualSize], [tmpEvent actualSize], @"Compare actual size");
    GHAssertEquals([event actualDuration], [tmpEvent actualDuration], @"Compare actual duration");
    GHAssertEqualStrings([event fullPath], [tmpEvent fullPath], @"Compare full path");
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp";
    [tmpEvent setFullPath:newUpdate];
    [dao updateEvent:tmpEvent];
    tmpEvent = (FxThumbnailEvent*)[dao selectEvent:lastEventId];
    GHAssertEquals([event pairId], [tmpEvent pairId], @"Compare pair id");
    GHAssertEquals([event actualSize], [tmpEvent actualSize], @"Compare actual size");
    GHAssertEquals([event actualDuration], [tmpEvent actualDuration], @"Compare actual duration");
    GHAssertEqualStrings(newUpdate, [tmpEvent fullPath], @"Compare full path");
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after update passed");
    
    
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");

    [event release];
}

- (void) testStressTest {
//    NSLog(@"db full path: %@", [mDatabaseManager dbFullName]);
    FxThumbnailEvent* event = [[FxThumbnailEvent alloc] init];
    [event setPairId:1];
    [event setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.gif"];
    [event setActualSize:46246823];
    [event setActualDuration:234];
    
    // Insert gps tag
    ThumbnailDAO* dao = [DAOFactory dataAccessObject:kEventTypeCameraImageThumbnail withSqlite3:[mDatabaseManager sqlite3db]];
    
    NSUInteger i;
    NSInteger maxInsertEvent = 100;
    for (i = 0; i < maxInsertEvent; i++) {
        [event setPairId:i];
        [event setFullPath:[NSString stringWithFormat:@"/hello/world/application/documents/Test/%d-thumbnail.gif", i]];
        [dao insertEvent:event];
    }
    
    DetailedCount* detailedCount = [dao countEvent];
    
    GHAssertEquals([detailedCount totalCount], maxInsertEvent, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSUInteger j = 0;
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    NSArray* eventArray = [dao selectMaxEvent:maxInsertEvent];
    for (FxThumbnailEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEquals(j, [event1 pairId], @"Compare pair id");
        GHAssertEquals([event actualSize], [event1 actualSize], @"Compare actual size");
        GHAssertEquals([event actualDuration], [event1 actualDuration], @"Compare actual duration");
        NSString* fullPath = [NSString stringWithFormat:@"/hello/world/application/documents/Test/%d-thumbnail.gif", j];
        GHAssertEqualStrings(fullPath, [event1 fullPath], @"Compare full path");
        j++;
    }
    
    FxThumbnailEvent* tmpEvent = (FxThumbnailEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEquals([event pairId], [tmpEvent pairId], @"Compare pair id");
    GHAssertEquals([event actualSize], [tmpEvent actualSize], @"Compare actual size");
    GHAssertEquals([event actualDuration], [tmpEvent actualDuration], @"Compare actual duration");
    GHAssertEqualStrings([event fullPath], [tmpEvent fullPath], @"Compare full path");
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp";
    [tmpEvent setFullPath:newUpdate];
    [dao updateEvent:tmpEvent];
    tmpEvent = (FxThumbnailEvent*)[dao selectEvent:lastEventId];
    GHAssertEquals([event pairId], [tmpEvent pairId], @"Compare pair id");
    GHAssertEquals([event actualSize], [tmpEvent actualSize], @"Compare actual size");
    GHAssertEquals([event actualDuration], [tmpEvent actualDuration], @"Compare actual duration");
    GHAssertEqualStrings(newUpdate, [tmpEvent fullPath], @"Compare full path");
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxInsertEvent, @"Count event after update passed");
    
    for (NSNumber* number in eventIdArray) {
        [dao deleteEvent:[number intValue]];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [eventIdArray release];
    [event release];
}

@end
