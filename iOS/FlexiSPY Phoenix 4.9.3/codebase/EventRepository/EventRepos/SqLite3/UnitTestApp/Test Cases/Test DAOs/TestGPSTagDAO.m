//
//  TestGPSTagDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "GPSTagDAO.h"
#import "FxGPSTag.h"

@interface TestGPSTagDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestGPSTagDAO

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
    FxGPSTag* gpsTag = [[FxGPSTag alloc] init];
    [gpsTag setLatitude:93.087760];
    [gpsTag setLongitude:923.836398];
    [gpsTag setAltitude:62.98];
    [gpsTag setCellId:345];
    [gpsTag setAreaCode:@"342"];
    [gpsTag setNetworkId:@"45"];
    [gpsTag setCountryCode:@"512"];
    
    // Insert gps tag
    GPSTagDAO* dao = [[GPSTagDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];

    [gpsTag setDbId:1];
    [dao insertRow:gpsTag];
    
    GHAssertEquals([dao countRow], 1, @"Count gps tag after insert passed");
    
    NSInteger lastRowId = 0;
    NSArray* rowArray = [dao selectMaxRow:33];
    for (FxGPSTag* tag in rowArray) {
        lastRowId = [tag dbId];
        GHAssertEquals([gpsTag longitude], [tag longitude], @"Compare longitude");
        GHAssertEquals([gpsTag latitude], [tag latitude], @"Compare latitude");
        GHAssertEquals([gpsTag altitude], [tag altitude], @"Compare altitude");
        GHAssertEquals([gpsTag cellId], [tag cellId], @"Compare cell Id");
        GHAssertEqualStrings([gpsTag areaCode], [tag areaCode], @"Compare area code");
        GHAssertEqualStrings([gpsTag networkId], [tag networkId], @"Compare network code");
        GHAssertEqualStrings([gpsTag countryCode], [tag countryCode], @"Compare country code");
    }
    
    FxGPSTag* tmpRow = (FxGPSTag*)[dao selectRow:lastRowId];
    
    GHAssertEquals([gpsTag longitude], [tmpRow longitude], @"Compare longitude");
    GHAssertEquals([gpsTag latitude], [tmpRow latitude], @"Compare latitude");
    GHAssertEquals([gpsTag altitude], [tmpRow altitude], @"Compare altitude");
    GHAssertEquals([gpsTag cellId], [tmpRow cellId], @"Compare cell Id");
    GHAssertEqualStrings([gpsTag areaCode], [tmpRow areaCode], @"Compare area code");
    GHAssertEqualStrings([gpsTag networkId], [tmpRow networkId], @"Compare network code");
    GHAssertEqualStrings([gpsTag countryCode], [tmpRow countryCode], @"Compare country code");
    NSString* newUpdate = @"111122234412";
    [tmpRow setAreaCode:newUpdate];
    [dao updateRow:tmpRow];
    tmpRow = (FxGPSTag*)[dao selectRow:lastRowId];
    GHAssertEquals([gpsTag longitude], [tmpRow longitude], @"Compare longitude");
    GHAssertEquals([gpsTag latitude], [tmpRow latitude], @"Compare latitude");
    GHAssertEquals([gpsTag altitude], [tmpRow altitude], @"Compare altitude");
    GHAssertEquals([gpsTag cellId], [tmpRow cellId], @"Compare cell Id");
    GHAssertEqualStrings(newUpdate, [tmpRow areaCode], @"Compare area code");
    GHAssertEqualStrings([gpsTag networkId], [tmpRow networkId], @"Compare network code");
    GHAssertEqualStrings([gpsTag countryCode], [tmpRow countryCode], @"Compare country code");
    
    NSInteger rowCount = [dao countRow];
    GHAssertEquals(rowCount, 1, @"Count row after update passed");
    
    
    [dao deleteRow:lastRowId];
    rowCount = [dao countRow];
    GHAssertEquals(rowCount, 0, @"Count row after delete passed");
    
    [dao release];
    [gpsTag release];
}

- (void) testStressTest {
    FxGPSTag* gpsTag = [[FxGPSTag alloc] init];
    [gpsTag setLatitude:93.087760];
    [gpsTag setLongitude:923.836398];
    [gpsTag setAltitude:62.98];
    [gpsTag setCellId:345];
    [gpsTag setAreaCode:@"342"];
    [gpsTag setNetworkId:@"45"];
    [gpsTag setCountryCode:@"512"];
    
    // Insert gps tag
    GPSTagDAO* dao = [[GPSTagDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    NSInteger maxRowInsert = 100;
    NSInteger i = 0;
    for (i = 0; i < maxRowInsert; i++) {
        [gpsTag setDbId:i];
        [gpsTag setLatitude:i+0.389042];
        [dao insertRow:gpsTag];
    }
    
    GHAssertEquals([dao countRow], maxRowInsert, @"Count gps tag after insert passed");
    
    NSInteger lastRowId = 0;
    NSInteger j = 0;
    NSArray* rowArray = [dao selectMaxRow:maxRowInsert];
    NSMutableArray* rowIdArray = [[NSMutableArray alloc] init];
    for (FxGPSTag* tag in rowArray) {
        lastRowId = [tag dbId];
        [rowIdArray addObject:[NSNumber numberWithInt:lastRowId]];
        GHAssertEquals([gpsTag longitude], [tag longitude], @"Compare longitude");
        float latitude = j+0.389042;
        GHAssertEquals(latitude, [tag latitude], @"Compare latitude");
        GHAssertEquals([gpsTag altitude], [tag altitude], @"Compare altitude");
        GHAssertEquals([gpsTag cellId], [tag cellId], @"Compare cell Id");
        GHAssertEqualStrings([gpsTag areaCode], [tag areaCode], @"Compare area code");
        GHAssertEqualStrings([gpsTag networkId], [tag networkId], @"Compare network code");
        GHAssertEqualStrings([gpsTag countryCode], [tag countryCode], @"Compare country code");
        j++;
    }
    
    FxGPSTag* tmpRow = (FxGPSTag*)[dao selectRow:lastRowId];
    
    GHAssertEquals([gpsTag longitude], [tmpRow longitude], @"Compare longitude");
    GHAssertEquals([gpsTag latitude], [tmpRow latitude], @"Compare latitude");
    GHAssertEquals([gpsTag altitude], [tmpRow altitude], @"Compare altitude");
    GHAssertEquals([gpsTag cellId], [tmpRow cellId], @"Compare cell Id");
    GHAssertEqualStrings([gpsTag areaCode], [tmpRow areaCode], @"Compare area code");
    GHAssertEqualStrings([gpsTag networkId], [tmpRow networkId], @"Compare network code");
    GHAssertEqualStrings([gpsTag countryCode], [tmpRow countryCode], @"Compare country code");
    NSString* newUpdate = @"111122234412";
    [tmpRow setAreaCode:newUpdate];
    [dao updateRow:tmpRow];
    tmpRow = (FxGPSTag*)[dao selectRow:lastRowId];
    GHAssertEquals([gpsTag longitude], [tmpRow longitude], @"Compare longitude");
    GHAssertEquals([gpsTag latitude], [tmpRow latitude], @"Compare latitude");
    GHAssertEquals([gpsTag altitude], [tmpRow altitude], @"Compare altitude");
    GHAssertEquals([gpsTag cellId], [tmpRow cellId], @"Compare cell Id");
    GHAssertEqualStrings(newUpdate, [tmpRow areaCode], @"Compare area code");
    GHAssertEqualStrings([gpsTag networkId], [tmpRow networkId], @"Compare network code");
    GHAssertEqualStrings([gpsTag countryCode], [tmpRow countryCode], @"Compare country code");
    
    NSInteger rowCount = [dao countRow];
    GHAssertEquals(rowCount, maxRowInsert, @"Count row after update passed");
    
    for (NSNumber* number in rowIdArray) {
        [dao deleteRow:[number intValue]];
    }
    rowCount = [dao countRow];
    GHAssertEquals(rowCount, 0, @"Count row after delete passed");
    
    [rowIdArray release];
    [dao release];
    [gpsTag release];
}

@end