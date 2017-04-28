//
//  TestApplicationLifeCycleDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxApplicationLifeCycleEvent.h"
#import "ApplicationLifeCycleDAO.h"

static NSString* const kEventDateTime1  = @"11:11:11 2011-11-11";

@interface TestApplicationLifeCycleDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestApplicationLifeCycleDAO

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
    FxApplicationLifeCycleEvent* alcEvent = [[FxApplicationLifeCycleEvent alloc] init];
    alcEvent.dateTime = kEventDateTime1;
    [alcEvent setMAppState:kALCLaunched];
    [alcEvent setMAppType:kALCProcess];
    [alcEvent setMAppID:@"com.apple.springboard"];
    [alcEvent setMAppName:@"SpringBoard"];
    [alcEvent setMAppVersion:@"2.00.2 (2323 BA)"];
    NSUInteger appSize = 10004232;
    [alcEvent setMAppSize:appSize];
    [alcEvent setMAppIconType:23];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundleResourcePath = [bundle resourcePath];
    NSString *iconPath = [bundleResourcePath stringByAppendingString:@"/appicon@2x.png"];
    
    [alcEvent setMAppIconData:[NSData dataWithContentsOfFile:iconPath]];
    ApplicationLifeCycleDAO* alcDAO = [DAOFactory dataAccessObject:[alcEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [alcDAO insertEvent:alcEvent];
    DetailedCount* detailedCount = [alcDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [alcDAO selectMaxEvent:33];
    for (FxApplicationLifeCycleEvent* alcEvent1 in eventArray) {
        lastEventId = [alcEvent1 eventId];
        GHAssertEqualStrings([alcEvent dateTime], [alcEvent1 dateTime], @"Compare date time");
        GHAssertEquals([alcEvent mAppState], [alcEvent1 mAppState], @"Compare state");
        GHAssertEquals([alcEvent mAppType], [alcEvent1 mAppType], @"Compare type");
        GHAssertEqualStrings([alcEvent mAppID], [alcEvent1 mAppID], @"Compare application id");
        GHAssertEqualStrings([alcEvent mAppName], [alcEvent1 mAppName], @"Compare name");
        GHAssertEqualStrings([alcEvent mAppVersion], [alcEvent1 mAppVersion], @"Compare version");
        GHAssertEquals([alcEvent mAppSize], [alcEvent1 mAppSize], @"Compare size");
        GHAssertEquals([alcEvent mAppIconType], [alcEvent1 mAppIconType], @"Compare icon type");
        GHAssertTrue([[alcEvent mAppIconData] isEqualToData:[alcEvent1 mAppIconData]], @"Compare icon data");
    }
    FxApplicationLifeCycleEvent* tempALCEvent = (FxApplicationLifeCycleEvent*)[alcDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([alcEvent dateTime], [tempALCEvent dateTime], @"Compare date time");
    GHAssertEquals([alcEvent mAppState], [tempALCEvent mAppState], @"Compare state");
    GHAssertEquals([alcEvent mAppType], [tempALCEvent mAppType], @"Compare type");
    GHAssertEqualStrings([alcEvent mAppID], [tempALCEvent mAppID], @"Compare application id");
    GHAssertEqualStrings([alcEvent mAppName], [tempALCEvent mAppName], @"Compare name");
    GHAssertEqualStrings([alcEvent mAppVersion], [tempALCEvent mAppVersion], @"Compare version");
    GHAssertEquals([alcEvent mAppSize], [tempALCEvent mAppSize], @"Compare size");
    GHAssertEquals([alcEvent mAppIconType], [tempALCEvent mAppIconType], @"Compare icon type");
    GHAssertTrue([[alcEvent mAppIconData] isEqualToData:[tempALCEvent mAppIconData]], @"Compare icon data");
    
    NSString * newALCVersion = @"123.q4321.1341";
    [tempALCEvent setMAppVersion:newALCVersion];
    [alcDAO updateEvent:tempALCEvent];
    
    tempALCEvent = (FxApplicationLifeCycleEvent*)[alcDAO selectEvent:lastEventId];
    GHAssertEqualStrings([alcEvent dateTime], [tempALCEvent dateTime], @"Compare date time");
    GHAssertEquals([alcEvent mAppState], [tempALCEvent mAppState], @"Compare state");
    GHAssertEquals([alcEvent mAppType], [tempALCEvent mAppType], @"Compare type");
    GHAssertEqualStrings([alcEvent mAppID], [tempALCEvent mAppID], @"Compare application id");
    GHAssertEqualStrings([alcEvent mAppName], [tempALCEvent mAppName], @"Compare name");
    GHAssertEqualStrings(newALCVersion, [tempALCEvent mAppVersion], @"Compare version");
    GHAssertEquals([alcEvent mAppSize], [tempALCEvent mAppSize], @"Compare size");
    GHAssertEquals([alcEvent mAppIconType], [tempALCEvent mAppIconType], @"Compare icon type");
    GHAssertTrue([[alcEvent mAppIconData] isEqualToData:[tempALCEvent mAppIconData]], @"Compare icon data");
    
    [alcDAO deleteEvent:lastEventId];
    detailedCount = [alcDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    
    [alcEvent release];
}

- (void) testStressTest {
    ApplicationLifeCycleDAO* alcDAO = [DAOFactory dataAccessObject:kEventTypeApplicationLifeCycle withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [alcDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxApplicationLifeCycleEvent* alcEvent = [[FxApplicationLifeCycleEvent alloc] init];
    alcEvent.dateTime = kEventDateTime1;
    [alcEvent setMAppState:kALCLaunched];
    [alcEvent setMAppType:kALCProcess];
    [alcEvent setMAppID:@"com.apple.springboard"];
    [alcEvent setMAppName:@"SpringBoard"];
    [alcEvent setMAppVersion:@"2.00.2 (2323 BA)"];
    NSUInteger appSize = 10004232;
    [alcEvent setMAppSize:appSize];
    [alcEvent setMAppIconType:23];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundleResourcePath = [bundle resourcePath];
    NSString *iconPath = [bundleResourcePath stringByAppendingString:@"/appicon@2x.png"];
    
    [alcEvent setMAppIconData:[NSData dataWithContentsOfFile:iconPath]];
    NSInteger maxEventTest = 100;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        [alcEvent setMAppName:[NSString stringWithFormat:@"SpringBoard-%d", i]];
        [alcDAO insertEvent:alcEvent];
    }
    detailedCount = [alcDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [alcDAO selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxApplicationLifeCycleEvent* alcEvent1 in eventArray) {
        lastEventId = [alcEvent1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEqualStrings([alcEvent dateTime], [alcEvent1 dateTime], @"Compare date time");
        NSString* string = [NSString stringWithFormat:@"SpringBoard-%d", i];
        GHAssertEqualStrings([alcEvent dateTime], [alcEvent1 dateTime], @"Compare date time");
        GHAssertEquals([alcEvent mAppState], [alcEvent1 mAppState], @"Compare state");
        GHAssertEquals([alcEvent mAppType], [alcEvent1 mAppType], @"Compare type");
        GHAssertEqualStrings([alcEvent mAppID], [alcEvent1 mAppID], @"Compare application id");
        GHAssertEqualStrings(string, [alcEvent1 mAppName], @"Compare name");
        GHAssertEqualStrings([alcEvent mAppVersion], [alcEvent1 mAppVersion], @"Compare version");
        GHAssertEquals([alcEvent mAppSize], [alcEvent1 mAppSize], @"Compare size");
        GHAssertEquals([alcEvent mAppIconType], [alcEvent1 mAppIconType], @"Compare icon type");
        GHAssertTrue([[alcEvent mAppIconData] isEqualToData:[alcEvent1 mAppIconData]], @"Compare icon data");
        i++;
    }
    FxApplicationLifeCycleEvent* tempALCEvent = (FxApplicationLifeCycleEvent*)[alcDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([alcEvent dateTime], [tempALCEvent dateTime], @"Compare date time");
    NSString* string = [NSString stringWithFormat:@"SpringBoard-%d", maxEventTest - 1];
    GHAssertEqualStrings([alcEvent dateTime], [tempALCEvent dateTime], @"Compare date time");
    GHAssertEquals([alcEvent mAppState], [tempALCEvent mAppState], @"Compare state");
    GHAssertEquals([alcEvent mAppType], [tempALCEvent mAppType], @"Compare type");
    GHAssertEqualStrings([alcEvent mAppID], [tempALCEvent mAppID], @"Compare application id");
    GHAssertEqualStrings(string, [tempALCEvent mAppName], @"Compare name");
    GHAssertEqualStrings([alcEvent mAppVersion], [tempALCEvent mAppVersion], @"Compare version");
    GHAssertEquals([alcEvent mAppSize], [tempALCEvent mAppSize], @"Compare size");
    GHAssertEquals([alcEvent mAppIconType], [tempALCEvent mAppIconType], @"Compare icon type");
    GHAssertTrue([[alcEvent mAppIconData] isEqualToData:[tempALCEvent mAppIconData]], @"Compare icon data");
    
    NSString * newALCVersion = @"123.q4321.1341";
    [tempALCEvent setMAppVersion:newALCVersion];
    [alcDAO updateEvent:tempALCEvent];
    
    tempALCEvent = (FxApplicationLifeCycleEvent*)[alcDAO selectEvent:lastEventId];
    GHAssertEqualStrings([alcEvent dateTime], [tempALCEvent dateTime], @"Compare date time");
    GHAssertEquals([alcEvent mAppState], [tempALCEvent mAppState], @"Compare state");
    GHAssertEquals([alcEvent mAppType], [tempALCEvent mAppType], @"Compare type");
    GHAssertEqualStrings([alcEvent mAppID], [tempALCEvent mAppID], @"Compare application id");
    GHAssertEqualStrings(string, [tempALCEvent mAppName], @"Compare name");
    GHAssertEqualStrings(newALCVersion, [tempALCEvent mAppVersion], @"Compare version");
    GHAssertEquals([alcEvent mAppSize], [tempALCEvent mAppSize], @"Compare size");
    GHAssertEquals([alcEvent mAppIconType], [tempALCEvent mAppIconType], @"Compare icon type");
    GHAssertTrue([[alcEvent mAppIconData] isEqualToData:[tempALCEvent mAppIconData]], @"Compare icon data");
    
    for (NSNumber* number in eventIdArray) {
        [alcDAO deleteEvent:[number intValue]];
    }
    detailedCount = [alcDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    [eventIdArray release];
    [alcEvent release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
