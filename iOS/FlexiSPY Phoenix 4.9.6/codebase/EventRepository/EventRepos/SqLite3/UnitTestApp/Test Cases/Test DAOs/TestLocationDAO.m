//
//  TestLocationDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxLocationEvent.h"
#import "LocationDAO.h"

NSString* const kEventDateTime3  = @"11:11:11 2011-11-11";

@interface TestLocationDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestLocationDAO

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
    FxLocationEvent* event = [[FxLocationEvent alloc] init];
    event.dateTime = kEventDateTime3;
    [event setLongitude:101.2384383];
    [event setLatitude:13.3847332];
    [event setAltitude:92.23784];
    [event setHorizontalAcc:0.3493];
    [event setVerticalAcc:0.87348];
    [event setSpeed:0.63527];
    [event setHeading:11.87];
    [event setDatumId:5];
    [event setNetworkId:@"512"];
    [event setNetworkName:@"DTAC"];
    [event setCellId:12211];
    [event setCellName:@"Paiyathai"];
    [event setAreaCode:@"12342"];
    [event setCountryCode:@"53"];
    [event setCallingModule:kGPSCallingModuleCoreTrigger];
    [event setMethod:kGPSTechAssisted];
    [event setProvider:kGPSProviderUnknown];
    LocationDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxLocationEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event longitude], [event1 longitude], @"Compare longitude");
        GHAssertEquals([event latitude], [event1 latitude], @"Compare latitude");
        GHAssertEquals([event altitude], [event1 altitude], @"Compare altitude");
        GHAssertEquals([event horizontalAcc], [event1 horizontalAcc], @"Compare horizontal accuracy");
        GHAssertEquals([event verticalAcc], [event1 verticalAcc], @"Compare vertical accuracy");
        GHAssertEquals([event speed], [event1 speed], @"Compare speed");
        GHAssertEquals([event heading], [event1 heading], @"Compare heading");
        GHAssertEquals([event datumId], [event1 datumId], @"Compare datum id");
        GHAssertEqualStrings([event networkId], [event1 networkId], @"Compare network id");
        GHAssertEqualStrings([event networkName], [event1 networkName], @"Compare network name");
        GHAssertEquals([event cellId], [event1 cellId], @"Compare cell id");
        GHAssertEqualStrings([event cellName], [event1 cellName], @"Compare cell name");
        GHAssertEqualStrings([event areaCode], [event1 areaCode], @"Compare area code");
        GHAssertEqualStrings([event countryCode], [event1 countryCode], @"Compare country code");
        GHAssertEquals([event callingModule], [event1 callingModule], @"Compare calling module");
        GHAssertEquals([event method], [event1 method], @"Compare method");
        GHAssertEquals([event provider], [event1 provider], @"Compare provider");
    }
    FxLocationEvent* tempEvent = (FxLocationEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEquals([event longitude], [tempEvent longitude], @"Compare longitude");
    GHAssertEquals([event latitude], [tempEvent latitude], @"Compare latitude");
    GHAssertEquals([event altitude], [tempEvent altitude], @"Compare altitude");
    GHAssertEquals([event horizontalAcc], [tempEvent horizontalAcc], @"Compare horizontal accuracy");
    GHAssertEquals([event verticalAcc], [tempEvent verticalAcc], @"Compare vertical accuracy");
    GHAssertEquals([event speed], [tempEvent speed], @"Compare speed");
    GHAssertEquals([event heading], [tempEvent heading], @"Compare heading");
    GHAssertEquals([event datumId], [tempEvent datumId], @"Compare datum id");
    GHAssertEqualStrings([event networkId], [tempEvent networkId], @"Compare network id");
    GHAssertEqualStrings([event networkName], [tempEvent networkName], @"Compare network name");
    GHAssertEquals([event cellId], [tempEvent cellId], @"Compare cell id");
    GHAssertEqualStrings([event cellName], [tempEvent cellName], @"Compare cell name");
    GHAssertEqualStrings([event areaCode], [tempEvent areaCode], @"Compare area code");
    GHAssertEqualStrings([event countryCode], [tempEvent countryCode], @"Compare country code");
    GHAssertEquals([event callingModule], [tempEvent callingModule], @"Compare calling module");
    GHAssertEquals([event method], [tempEvent method], @"Compare method");
    GHAssertEquals([event provider], [tempEvent provider], @"Compare provider");
    float newUpdate = 123.5364587;
    [tempEvent setLongitude:newUpdate];
    [dao updateEvent:tempEvent];
    tempEvent = (FxLocationEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEquals(newUpdate, [tempEvent longitude], @"Compare longitude");
    GHAssertEquals([event latitude], [tempEvent latitude], @"Compare latitude");
    GHAssertEquals([event altitude], [tempEvent altitude], @"Compare altitude");
    GHAssertEquals([event horizontalAcc], [tempEvent horizontalAcc], @"Compare horizontal accuracy");
    GHAssertEquals([event verticalAcc], [tempEvent verticalAcc], @"Compare vertical accuracy");
    GHAssertEquals([event speed], [tempEvent speed], @"Compare speed");
    GHAssertEquals([event heading], [tempEvent heading], @"Compare heading");
    GHAssertEquals([event datumId], [tempEvent datumId], @"Compare datum id");
    GHAssertEqualStrings([event networkId], [tempEvent networkId], @"Compare network id");
    GHAssertEqualStrings([event networkName], [tempEvent networkName], @"Compare network name");
    GHAssertEquals([event cellId], [tempEvent cellId], @"Compare cell id");
    GHAssertEqualStrings([event cellName], [tempEvent cellName], @"Compare cell name");
    GHAssertEqualStrings([event areaCode], [tempEvent areaCode], @"Compare area code");
    GHAssertEqualStrings([event countryCode], [tempEvent countryCode], @"Compare country code");
    GHAssertEquals([event callingModule], [tempEvent callingModule], @"Compare calling module");
    GHAssertEquals([event method], [tempEvent method], @"Compare method");
    GHAssertEquals([event provider], [tempEvent provider], @"Compare provider");
    
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    
    [event release];
}

- (void) testStressTest {
    LocationDAO* dao = [DAOFactory dataAccessObject:kEventTypeLocation withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxLocationEvent* event = [[FxLocationEvent alloc] init];
    event.dateTime = kEventDateTime3;
    [event setLongitude:101.2384383];
    [event setLatitude:13.3847332];
    [event setAltitude:92.23784];
    [event setHorizontalAcc:0.3493];
    [event setVerticalAcc:0.87348];
    [event setSpeed:0.63527];
    [event setHeading:11.87];
    [event setDatumId:5];
    [event setNetworkId:@"512"];
    [event setNetworkName:@"DTAC"];
    [event setCellId:12211];
    [event setCellName:@"Paiyathai"];
    [event setAreaCode:@"12342"];
    [event setCountryCode:@"53"];
    [event setCallingModule:kGPSCallingModuleCoreTrigger];
    [event setMethod:kGPSTechAssisted];
    [event setProvider:kGPSProviderUnknown];
    NSInteger maxEventTest = 100;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        [event setLongitude:(0.293728 + i)];
        [dao insertEvent:event];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxLocationEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        float longitude = 0.293728 + i;
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals(longitude, [event1 longitude], @"Compare longitude");
        GHAssertEquals([event latitude], [event1 latitude], @"Compare latitude");
        GHAssertEquals([event altitude], [event1 altitude], @"Compare altitude");
        GHAssertEquals([event horizontalAcc], [event1 horizontalAcc], @"Compare horizontal accuracy");
        GHAssertEquals([event verticalAcc], [event1 verticalAcc], @"Compare vertical accuracy");
        GHAssertEquals([event speed], [event1 speed], @"Compare speed");
        GHAssertEquals([event heading], [event1 heading], @"Compare heading");
        GHAssertEquals([event datumId], [event1 datumId], @"Compare datum id");
        GHAssertEqualStrings([event networkId], [event1 networkId], @"Compare network id");
        GHAssertEqualStrings([event networkName], [event1 networkName], @"Compare network name");
        GHAssertEquals([event cellId], [event1 cellId], @"Compare cell id");
        GHAssertEqualStrings([event cellName], [event1 cellName], @"Compare cell name");
        GHAssertEqualStrings([event areaCode], [event1 areaCode], @"Compare area code");
        GHAssertEqualStrings([event countryCode], [event1 countryCode], @"Compare country code");
        GHAssertEquals([event callingModule], [event1 callingModule], @"Compare calling module");
        GHAssertEquals([event method], [event1 method], @"Compare method");
        GHAssertEquals([event provider], [event1 provider], @"Compare provider");
        i++;
    }
    FxLocationEvent* tempEvent = (FxLocationEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEquals([event longitude], [tempEvent longitude], @"Compare longitude");
    GHAssertEquals([event latitude], [tempEvent latitude], @"Compare latitude");
    GHAssertEquals([event altitude], [tempEvent altitude], @"Compare altitude");
    GHAssertEquals([event horizontalAcc], [tempEvent horizontalAcc], @"Compare horizontal accuracy");
    GHAssertEquals([event verticalAcc], [tempEvent verticalAcc], @"Compare vertical accuracy");
    GHAssertEquals([event speed], [tempEvent speed], @"Compare speed");
    GHAssertEquals([event heading], [tempEvent heading], @"Compare heading");
    GHAssertEquals([event datumId], [tempEvent datumId], @"Compare datum id");
    GHAssertEqualStrings([event networkId], [tempEvent networkId], @"Compare network id");
    GHAssertEqualStrings([event networkName], [tempEvent networkName], @"Compare network name");
    GHAssertEquals([event cellId], [tempEvent cellId], @"Compare cell id");
    GHAssertEqualStrings([event cellName], [tempEvent cellName], @"Compare cell name");
    GHAssertEqualStrings([event areaCode], [tempEvent areaCode], @"Compare area code");
    GHAssertEqualStrings([event countryCode], [tempEvent countryCode], @"Compare country code");
    GHAssertEquals([event callingModule], [tempEvent callingModule], @"Compare calling module");
    GHAssertEquals([event method], [tempEvent method], @"Compare method");
    GHAssertEquals([event provider], [tempEvent provider], @"Compare provider");
    float newUpdate = 123.5364587;
    [tempEvent setLongitude:newUpdate];
    [dao updateEvent:tempEvent];
    tempEvent = (FxLocationEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEquals(newUpdate, [tempEvent longitude], @"Compare longitude");
    GHAssertEquals([event latitude], [tempEvent latitude], @"Compare latitude");
    GHAssertEquals([event altitude], [tempEvent altitude], @"Compare altitude");
    GHAssertEquals([event horizontalAcc], [tempEvent horizontalAcc], @"Compare horizontal accuracy");
    GHAssertEquals([event verticalAcc], [tempEvent verticalAcc], @"Compare vertical accuracy");
    GHAssertEquals([event speed], [tempEvent speed], @"Compare speed");
    GHAssertEquals([event heading], [tempEvent heading], @"Compare heading");
    GHAssertEquals([event datumId], [tempEvent datumId], @"Compare datum id");
    GHAssertEqualStrings([event networkId], [tempEvent networkId], @"Compare network id");
    GHAssertEqualStrings([event networkName], [tempEvent networkName], @"Compare network name");
    GHAssertEquals([event cellId], [tempEvent cellId], @"Compare cell id");
    GHAssertEqualStrings([event cellName], [tempEvent cellName], @"Compare cell name");
    GHAssertEqualStrings([event areaCode], [tempEvent areaCode], @"Compare area code");
    GHAssertEqualStrings([event countryCode], [tempEvent countryCode], @"Compare country code");
    GHAssertEquals([event callingModule], [tempEvent callingModule], @"Compare calling module");
    GHAssertEquals([event method], [tempEvent method], @"Compare method");
    GHAssertEquals([event provider], [tempEvent provider], @"Compare provider");
    
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

