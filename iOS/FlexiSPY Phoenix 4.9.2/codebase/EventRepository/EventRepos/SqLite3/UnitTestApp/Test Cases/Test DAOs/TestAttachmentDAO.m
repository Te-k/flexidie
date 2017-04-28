//
//  TestAttachmentDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "AttachmentDAO.h"

#import "FxAttachment.h"
#import "FxAttachmentWrapper.h"
#import "FxEventEnums.h"

@interface TestAttachmentDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestAttachmentDAO

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
    FxAttachment* attachment = [[FxAttachment alloc] init];
    [attachment setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.gif"];
    
    AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    FxAttachmentWrapper* attWrapper = [[FxAttachmentWrapper alloc] init];
    [attWrapper setMmsId:1];
    [attWrapper setAttachment:attachment];
    [attDAO insertRow:attWrapper];
    
    NSInteger attCount = [attDAO countRow];
    GHAssertEquals(attCount, 1, @"Count attachment after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [attDAO selectMaxRow:33];
    for (FxAttachmentWrapper* event1 in eventArray) {
        lastEventId = [[event1 attachment] dbId];
        GHAssertEquals([event1 mmsId], [attWrapper mmsId], @"Compare mms id");
        GHAssertEqualStrings([[event1 attachment] fullPath], [[attWrapper attachment] fullPath], @"Compare full path");
    }
    [attWrapper release];
    
    NSArray* attArr = [attDAO selectRow:1 andEventType:kEventTypeMms];
    
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp"
    "GDB is free software, covered by the GNU General Public License, and you are";
    
    NSUInteger one = 1;
    for (FxAttachmentWrapper* tmpEvent in attArr) {
        GHAssertEquals([tmpEvent mmsId], one, @"Compare mms id");
        GHAssertEqualStrings([[tmpEvent attachment] fullPath], [attachment fullPath], @"Compare full path");
        [[tmpEvent attachment] setFullPath:newUpdate];
        [attDAO updateRow:tmpEvent];
    }
    
    attArr = [attDAO selectRow:lastEventId andEventType:kEventTypeMms];
    for (FxAttachmentWrapper* tmpEvent in attArr) {
        GHAssertEquals([tmpEvent mmsId], one, @"Compare mms id");
        GHAssertEqualStrings([[tmpEvent attachment] fullPath], newUpdate, @"Compare full path");
    }
    
    attCount = [attDAO countRow];
    GHAssertEquals(attCount, 1, @"Count event after update passed");
    
    [attDAO deleteRow:lastEventId];
    
    attCount = [attDAO countRow];
    GHAssertEquals(attCount, 0, @"Count attachment after delete passed");
    
    [attDAO release];
    [attachment release];
}

- (void) testStressTest {
    FxAttachment* attachment = [[FxAttachment alloc] init];
    [attachment setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.gif"];
    
    AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    
    NSInteger maxRowInsert = 100;
    NSInteger i;
    for (i = 0; i < maxRowInsert; i++) {
        FxAttachmentWrapper* attWrapper = [[FxAttachmentWrapper alloc] init];
        [attWrapper setMmsId:i];
        [attWrapper setAttachment:attachment];
        [attDAO insertRow:attWrapper];
        [attWrapper release];
    }
    
    NSInteger attCount = [attDAO countRow];
    GHAssertEquals(attCount, maxRowInsert, @"Count attachment after insert passed");
    
    NSInteger lastEventId = 0;
    NSUInteger j = 0;
    NSMutableArray* rowIdArray = [[NSMutableArray alloc] init];
    NSArray* eventArray = [attDAO selectMaxRow:maxRowInsert];
    for (FxAttachmentWrapper* event1 in eventArray) {
        lastEventId = [[event1 attachment] dbId];
        [rowIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEquals([event1 mmsId], j, @"Compare mms id");
        GHAssertEqualStrings([[event1 attachment] fullPath], [attachment fullPath], @"Compare full path");
        j++;
    }
    
    NSArray* attArr = [attDAO selectRow:lastEventId andEventType:kEventTypeMms];
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp"
    "GDB is free software, covered by the GNU General Public License, and you are";
    
    for (FxAttachmentWrapper* tmpEvent in attArr) {
        GHAssertEquals([tmpEvent mmsId], j-1, @"Compare mms id");
        GHAssertEqualStrings([[tmpEvent attachment] fullPath], [attachment fullPath], @"Compare full path");
        [[tmpEvent attachment] setFullPath:newUpdate];
        [attDAO updateRow:tmpEvent];
    }
    
    attArr = [attDAO selectRow:lastEventId andEventType:kEventTypeMms];
    for (FxAttachmentWrapper* tmpEvent in attArr) {
        GHAssertEquals([tmpEvent mmsId], j-1, @"Compare mms id");
        GHAssertEqualStrings([[tmpEvent attachment] fullPath], newUpdate, @"Compare full path");
    }
    
    attCount = [attDAO countRow];
    GHAssertEquals(attCount, maxRowInsert, @"Count event after update passed");
    
    [attDAO deleteRow:lastEventId];
    
    attCount = [attDAO countRow];
    GHAssertEquals(attCount, maxRowInsert - 1, @"Count attachment after delete passed");
    
    for (j = 0; j < maxRowInsert - 1; j++) {
        NSNumber* number = [rowIdArray objectAtIndex:j];
        [attDAO deleteRow:[number intValue]];
    }
    
    attCount = [attDAO countRow];
    GHAssertEquals(attCount, 0, @"Count attachment after delete passed");
    
    [attDAO release];
    [attachment release];
}

@end
