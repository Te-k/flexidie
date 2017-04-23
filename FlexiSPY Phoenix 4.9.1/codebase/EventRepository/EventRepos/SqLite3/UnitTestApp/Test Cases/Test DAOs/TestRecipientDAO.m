//
//  TestRecipientDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "RecipientDAO.h"

#import "FxRecipient.h"
#import "FxRecipientWrapper.h"
#import "FxEventEnums.h"

@interface TestRecipientDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestRecipientDAO

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
    FxRecipient* recipient = [[FxRecipient alloc] init];
    [recipient setRecipType:kFxRecipientBCC];
    [recipient setRecipNumAddr:@"makara@ovi.com"];
    [recipient setRecipContactName:@"Mr. Makara KHLOTH"];
    
    RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    FxRecipientWrapper* wrapper = [[FxRecipientWrapper alloc] init];
    [wrapper setSmsId:1];
    [wrapper setRecipient:recipient];
    [recipDAO insertRow:wrapper];
    
    NSInteger attCount = [recipDAO countRow];
    GHAssertEquals(attCount, 1, @"Count attachment after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [recipDAO selectMaxRow:33];
    for (FxRecipientWrapper* event1 in eventArray) {
        lastEventId = [[event1 recipient] dbId];
        GHAssertEquals([event1 smsId], [wrapper smsId], @"Compare sms id");
        GHAssertEquals([[event1 recipient] recipType], [[wrapper recipient] recipType], @"Compare recipient type");
        GHAssertEqualStrings([[event1 recipient] recipNumAddr], [[wrapper recipient] recipNumAddr], @"Compare recipient number address");
        GHAssertEqualStrings([[event1 recipient] recipContactName], [[wrapper recipient] recipContactName], @"Compare recipient contact name");
    }
    [wrapper release];
    
    NSUInteger one = 1;
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp"
    "GDB is free software, covered by the GNU General Public License, and you are";
    
    NSArray* recipArray = [recipDAO selectRow:lastEventId andEventType:kEventTypeSms];
    
    for (FxRecipientWrapper* tmpEvent in recipArray) {
        GHAssertEquals(one, [tmpEvent smsId], @"Compare sms id");
        GHAssertEquals([recipient recipType], [[tmpEvent recipient] recipType], @"Compare recipient type");
        GHAssertEqualStrings([recipient recipNumAddr], [[tmpEvent recipient] recipNumAddr], @"Compare recipient number address");
        GHAssertEqualStrings([recipient recipContactName], [[tmpEvent recipient] recipContactName], @"Compare recipient contact name");
        [[tmpEvent recipient] setRecipContactName:newUpdate];
        [recipDAO updateRow:tmpEvent];
    }
    
    recipArray = [recipDAO selectRow:lastEventId andEventType:kEventTypeSms];
    for (FxRecipientWrapper* tmpEvent in recipArray) {
        GHAssertEquals([tmpEvent smsId], one, @"Compare sms id");
        GHAssertEquals([recipient recipType], [[tmpEvent recipient] recipType], @"Compare recipient type");
        GHAssertEqualStrings([recipient recipNumAddr], [[tmpEvent recipient] recipNumAddr], @"Compare recipient number address");
        GHAssertEqualStrings(newUpdate, [[tmpEvent recipient] recipContactName], @"Compare recipient contact name");
    }
    
    attCount = [recipDAO countRow];
    GHAssertEquals(attCount, 1, @"Count event after update passed");
    
    [recipDAO deleteRow:lastEventId];
    
    attCount = [recipDAO countRow];
    GHAssertEquals(attCount, 0, @"Count attachment after delete passed");
    
    [recipDAO release];
    [recipient release];
}

- (void) testStressTest {
    FxRecipient* recipient = [[FxRecipient alloc] init];
    [recipient setRecipType:kFxRecipientBCC];
    [recipient setRecipNumAddr:@"makara@ovi.com"];
    [recipient setRecipContactName:@"Mr. Makara KHLOTH"];
    
    RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    
    NSInteger maxInsertRow = 100;
    NSUInteger i;
    for (i = 0; i < maxInsertRow; i++) {
        FxRecipientWrapper* wrapper = [[FxRecipientWrapper alloc] init];
        [wrapper setSmsId:i];
        [recipient setRecipNumAddr:[NSString stringWithFormat:@"makara@ovi.com%d", i]];
        [wrapper setRecipient:recipient];
        [recipDAO insertRow:wrapper];
        [wrapper release];
    }
    
    NSInteger attCount = [recipDAO countRow];
    GHAssertEquals(attCount, maxInsertRow, @"Count attachment after insert passed");
    
    NSInteger lastEventId = 0;
    NSUInteger j = 0;
    NSMutableArray* rowIdArray = [[NSMutableArray alloc] init];
    NSArray* eventArray = [recipDAO selectMaxRow:maxInsertRow];
    for (FxRecipientWrapper* event1 in eventArray) {
        lastEventId = [[event1 recipient] dbId];
        [rowIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEquals([event1 smsId], j, @"Compare sms id");
        GHAssertEquals([[event1 recipient] recipType], [recipient recipType], @"Compare recipient type");
        
        NSString* recipNumAddr = [NSString stringWithFormat:@"makara@ovi.com%d", j];
        GHAssertEqualStrings([[event1 recipient] recipNumAddr], recipNumAddr, @"Compare recipient number address");
        GHAssertEqualStrings([[event1 recipient] recipContactName], [recipient recipContactName], @"Compare recipient contact name");
        j++;
    }
    
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp"
    "GDB is free software, covered by the GNU General Public License, and you are";
    
    NSArray* recipArray = [recipDAO selectRow:lastEventId andEventType:kEventTypeSms];
    
    for (FxRecipientWrapper* tmpEvent in recipArray) {
        GHAssertEquals(j-1, [tmpEvent smsId], @"Compare sms id");
        GHAssertEquals([recipient recipType], [[tmpEvent recipient] recipType], @"Compare recipient type");
        GHAssertEqualStrings([recipient recipNumAddr], [[tmpEvent recipient] recipNumAddr], @"Compare recipient number address");
        GHAssertEqualStrings([recipient recipContactName], [[tmpEvent recipient] recipContactName], @"Compare recipient contact name");
        [[tmpEvent recipient] setRecipContactName:newUpdate];
        [recipDAO updateRow:tmpEvent];
    }
    
    recipArray = [recipDAO selectRow:lastEventId andEventType:kEventTypeSms];
    for (FxRecipientWrapper* tmpEvent in recipArray) {
        GHAssertEquals([tmpEvent smsId], j-1, @"Compare sms id");
        GHAssertEquals([recipient recipType], [[tmpEvent recipient] recipType], @"Compare recipient type");
        GHAssertEqualStrings([recipient recipNumAddr], [[tmpEvent recipient] recipNumAddr], @"Compare recipient number address");
        GHAssertEqualStrings(newUpdate, [[tmpEvent recipient] recipContactName], @"Compare recipient contact name");
    }
    
    attCount = [recipDAO countRow];
    GHAssertEquals(attCount, maxInsertRow, @"Count event after update passed");
    
    for (NSNumber* number in rowIdArray) {
        [recipDAO deleteRow:[number intValue]];
    }
    
    attCount = [recipDAO countRow];
    GHAssertEquals(attCount, 0, @"Count attachment after delete passed");
    
    [rowIdArray release];
    [recipDAO release];
    [recipient release];
}

@end

