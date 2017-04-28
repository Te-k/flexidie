//
//  TestCallTagDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "CallTagDAO.h"
#import "FxCallTag.h"

@interface TestCallTagDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestCallTagDAO

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
    FxCallTag* callTag = [[FxCallTag alloc] init];
    [callTag setDirection:(FxEventDirection)kEventDirectionOut];
    [callTag setDuration:23];
    [callTag setContactNumber:@"0873246246823"];
    [callTag setContactName:@"R. Mr'cm \"CamKh"];
    
    // Insert gps tag
    CallTagDAO* dao = [[CallTagDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    
    [callTag setDbId:1];
    [dao insertRow:callTag];
    
    GHAssertEquals([dao countRow], 1, @"Count gps tag after insert passed");
    
    NSInteger lastRowId = 0;
    NSArray* rowArray = [dao selectMaxRow:33];
    for (FxCallTag* tag in rowArray) {
        lastRowId = [tag dbId];
        GHAssertEquals([callTag direction], [tag direction], @"Compare direction");
        GHAssertEquals([callTag duration], [tag duration], @"Compare duration");
        GHAssertEqualStrings([callTag contactNumber], [tag contactNumber], @"Compare contact number");
        GHAssertEqualStrings([callTag contactName], [tag contactName], @"Compare contact name");
    }
    
    FxCallTag* tmpRow = (FxCallTag*)[dao selectRow:lastRowId];
    
    GHAssertEquals([callTag direction], [tmpRow direction], @"Compare direction");
    GHAssertEquals([callTag duration], [tmpRow duration], @"Compare duration");
    GHAssertEqualStrings([callTag contactNumber], [tmpRow contactNumber], @"Compare contact number");
    GHAssertEqualStrings([callTag contactName], [tmpRow contactName], @"Compare contact name");
    NSString* newUpdate = @"111122234412";
    [tmpRow setContactNumber:newUpdate];
    [dao updateRow:tmpRow];
    tmpRow = (FxCallTag*)[dao selectRow:lastRowId];
    GHAssertEquals([callTag direction], [tmpRow direction], @"Compare direction");
    GHAssertEquals([callTag duration], [tmpRow duration], @"Compare duration");
    GHAssertEqualStrings(newUpdate, [tmpRow contactNumber], @"Compare contact number");
    GHAssertEqualStrings([callTag contactName], [tmpRow contactName], @"Compare contact name");
    
    NSInteger rowCount = [dao countRow];
    GHAssertEquals(rowCount, 1, @"Count row after update passed");
    
    
    [dao deleteRow:lastRowId];
    rowCount = [dao countRow];
    GHAssertEquals(rowCount, 0, @"Count row after delete passed");
    
    [dao release];
    [callTag release];
}

- (void) testStressTest {
    FxCallTag* callTag = [[FxCallTag alloc] init];
    [callTag setDirection:(FxEventDirection)kEventDirectionOut];
    [callTag setDuration:23];
    [callTag setContactNumber:@"0873246246823"];
    [callTag setContactName:@"R. Mr'cm \"CamKh"];
    
    // Insert gps tag
    CallTagDAO* dao = [[CallTagDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    
    NSInteger maxRowInsert = 100;
    NSInteger i = 0;
    for (i = 0 ; i < maxRowInsert; i++) {
        [callTag setDuration:i];
        [callTag setDbId:i];
        [dao insertRow:callTag];
    }
    
    GHAssertEquals([dao countRow], maxRowInsert, @"Count gps tag after insert passed");
    
    NSInteger lastRowId = 0;
    NSInteger j = 0;
    NSMutableArray* rowIdArray = [[NSMutableArray alloc] init];
    NSArray* rowArray = [dao selectMaxRow:maxRowInsert];
    for (FxCallTag* tag in rowArray) {
        lastRowId = [tag dbId];
        [rowIdArray addObject:[NSNumber numberWithInt:lastRowId]];
        GHAssertEquals([callTag direction], [tag direction], @"Compare direction");
        GHAssertEquals(j, [tag duration], @"Compare duration");
        GHAssertEqualStrings([callTag contactNumber], [tag contactNumber], @"Compare contact number");
        GHAssertEqualStrings([callTag contactName], [tag contactName], @"Compare contact name");
        j++;
    }
    
    FxCallTag* tmpRow = (FxCallTag*)[dao selectRow:lastRowId];
    
    GHAssertEquals([callTag direction], [tmpRow direction], @"Compare direction");
    GHAssertEquals([callTag duration], [tmpRow duration], @"Compare duration");
    GHAssertEqualStrings([callTag contactNumber], [tmpRow contactNumber], @"Compare contact number");
    GHAssertEqualStrings([callTag contactName], [tmpRow contactName], @"Compare contact name");
    NSString* newUpdate = @"111122234412";
    [tmpRow setContactNumber:newUpdate];
    [dao updateRow:tmpRow];
    tmpRow = (FxCallTag*)[dao selectRow:lastRowId];
    GHAssertEquals([callTag direction], [tmpRow direction], @"Compare direction");
    GHAssertEquals([callTag duration], [tmpRow duration], @"Compare duration");
    GHAssertEqualStrings(newUpdate, [tmpRow contactNumber], @"Compare contact number");
    GHAssertEqualStrings([callTag contactName], [tmpRow contactName], @"Compare contact name");
    
    NSInteger rowCount = [dao countRow];
    GHAssertEquals(rowCount, maxRowInsert, @"Count row after update passed");
    
    
    for (NSNumber* number in rowIdArray) {
        [dao deleteRow:[number intValue]];
    }
    rowCount = [dao countRow];
    GHAssertEquals(rowCount, 0, @"Count row after delete passed");
    
    [rowIdArray release];
    [dao release];
    [callTag release];
}

@end
