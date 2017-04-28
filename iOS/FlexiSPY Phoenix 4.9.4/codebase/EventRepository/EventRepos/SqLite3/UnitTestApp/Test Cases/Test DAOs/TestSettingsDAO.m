//
//  TestSettingsDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 11/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxSettingsEvent.h"
#import "SettingsDAO.h"

static NSString* const kEventDateTime2  = @"11:11:11 2011-11-11";

@interface TestSettingsDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestSettingsDAO

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
    FxSettingsEvent* event = [[FxSettingsEvent alloc] init];
    event.dateTime = kEventDateTime2;
    NSMutableArray* elementsArray = [[NSMutableArray alloc] init];
    FxSettingsElement* settingsElement = [[FxSettingsElement alloc] init];
    [settingsElement setMSettingId:1];
    [settingsElement setMSettingValue:@"One"];
    [elementsArray addObject:settingsElement];
    [settingsElement release];
    settingsElement = [[FxSettingsElement alloc] init];
    [settingsElement setMSettingId:2];
    [settingsElement setMSettingValue:@"two"];
    [elementsArray addObject:settingsElement];
    [settingsElement release];
    settingsElement = [[FxSettingsElement alloc] init];
    [settingsElement setMSettingId:10];
    [settingsElement setMSettingValue:@"ten"];
    [elementsArray addObject:settingsElement];
    [settingsElement release];
    settingsElement = [[FxSettingsElement alloc] init];
    [settingsElement setMSettingId:34];
    [settingsElement setMSettingValue:@"Thirty four"];
    [elementsArray addObject:settingsElement];
    [settingsElement release];
    settingsElement = [[FxSettingsElement alloc] init];
    [settingsElement setMSettingId:49];
    [settingsElement setMSettingValue:@"Fourthy nine"];
    [elementsArray addObject:settingsElement];
    [settingsElement release];
    [event setMSettingArray:elementsArray];
    [elementsArray release];
    SettingsDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxSettingsEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        NSInteger i = 0;
        for (FxSettingsElement* element1 in [event1 mSettingArray]) {
            FxSettingsElement* element = [[event mSettingArray] objectAtIndex:i];
            GHAssertEquals([element mSettingId], [element1 mSettingId], @"Compare each element Id");
            GHAssertEqualStrings([element mSettingValue], [element1 mSettingValue], @"Compare each element value");
            i++;
        }
    }
    FxSettingsEvent* tempEvent = (FxSettingsEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    NSInteger i = 0;
    for (FxSettingsElement* element1 in [tempEvent mSettingArray]) {
        FxSettingsElement* element = [[event mSettingArray] objectAtIndex:i];
        GHAssertEquals([element mSettingId], [element1 mSettingId], @"Compare each element Id");
        GHAssertEqualStrings([element mSettingValue], [element1 mSettingValue], @"Compare each element value");
        i++;
    }
    NSInteger newSettingId = 69;
    NSString* newSettingValue = @"Sixty nine";
    FxSettingsElement* element = [[tempEvent mSettingArray] objectAtIndex:0];
    [element setMSettingId:newSettingId];
    [element setMSettingValue:newSettingValue];
    [dao updateEvent:tempEvent];
    tempEvent = (FxSettingsEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    i = 0;
    for (FxSettingsElement* element1 in [tempEvent mSettingArray]) {
        FxSettingsElement* element = [[event mSettingArray] objectAtIndex:i];
        if (i == 0) {
            GHAssertEquals(newSettingId, [element1 mSettingId], @"Compare each element Id 0");
            GHAssertEqualStrings(newSettingValue, [element1 mSettingValue], @"Compare each element value 0");
        } else {
            GHAssertEquals([element mSettingId], [element1 mSettingId], @"Compare each element Id");
            GHAssertEqualStrings([element mSettingValue], [element1 mSettingValue], @"Compare each element value");
        }
        i++;
    }
    
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    
    [event release];
}

- (void) testStressTest {
    
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
