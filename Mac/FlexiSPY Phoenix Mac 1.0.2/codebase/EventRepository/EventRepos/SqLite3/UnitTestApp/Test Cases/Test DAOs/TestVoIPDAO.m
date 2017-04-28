//
//  TestVoIPDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 7/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//
#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxVoIPEvent.h"
#import "VoIPDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";
static NSString* const kContactName    = @"Mr. Makara KHLOTH";
static NSString* const kContactNumber  = @"+66860843742";


@interface TestVoIPDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestVoIPDAO

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
    FxVoIPEvent* voIPEvent = [[FxVoIPEvent alloc] init];
    voIPEvent.dateTime = kEventDateTime;
    voIPEvent.mContactName = kContactName;
    voIPEvent.mUserID = kContactNumber;
    voIPEvent.mDirection = kEventDirectionIn;
    voIPEvent.mDuration = 399;
    voIPEvent.mCategory = kVoIPCategoryFaceTime;
    voIPEvent.mTransferedByte = 15968508;
    voIPEvent.mVoIPMonitor = kFxVoIPMonitorYES;
    voIPEvent.mFrameStripID = 3;
    VoIPDAO* voIPDAO = [DAOFactory dataAccessObject:[voIPEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [voIPDAO insertEvent:voIPEvent];
    DetailedCount* detailedCount = [voIPDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [voIPDAO selectMaxEvent:33];
    for (FxVoIPEvent* voIPEvent1 in eventArray) {
        lastEventId = [voIPEvent1 eventId];
        GHAssertEqualStrings([voIPEvent dateTime], [voIPEvent1 dateTime], @"Compare date time");
        GHAssertEqualStrings([voIPEvent mContactName], [voIPEvent1 mContactName], @"Compare contact name");
        GHAssertEqualStrings([voIPEvent mUserID], [voIPEvent1 mUserID], @"Compare user id");
        GHAssertEquals([voIPEvent mDirection], [voIPEvent1 mDirection], @"Compare direction");
        GHAssertEquals([voIPEvent mDuration], [voIPEvent1 mDuration], @"Compare duration");
        GHAssertEquals([voIPEvent mTransferedByte], [voIPEvent1 mTransferedByte], @"Compare transfered byte");
        GHAssertEquals([voIPEvent mCategory], [voIPEvent1 mCategory], @"Compare category");
        GHAssertEquals([voIPEvent mVoIPMonitor], [voIPEvent1 mVoIPMonitor], @"Compare monitor");
        GHAssertEquals([voIPEvent mFrameStripID], [voIPEvent1 mFrameStripID], @"Compare frame strip id");
    }
    FxVoIPEvent* tempVoIPEvent = (FxVoIPEvent*)[voIPDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([voIPEvent dateTime], [tempVoIPEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([voIPEvent mContactName], [tempVoIPEvent mContactName], @"Compare contact name");
    GHAssertEqualStrings([voIPEvent mUserID], [tempVoIPEvent mUserID], @"Compare user id");
    GHAssertEquals([voIPEvent mDirection], [tempVoIPEvent mDirection], @"Compare direction");
    GHAssertEquals([voIPEvent mDuration], [tempVoIPEvent mDuration], @"Compare duration");
    GHAssertEquals([voIPEvent mTransferedByte], [tempVoIPEvent mTransferedByte], @"Compare transfered byte");
    GHAssertEquals([voIPEvent mCategory], [tempVoIPEvent mCategory], @"Compare category");
    GHAssertEquals([voIPEvent mVoIPMonitor], [tempVoIPEvent mVoIPMonitor], @"Compare monitor");
    GHAssertEquals([voIPEvent mFrameStripID], [tempVoIPEvent mFrameStripID], @"Compare frame strip id");
    NSUInteger newDuration = 500;
    [tempVoIPEvent setMDuration:newDuration];
    [voIPDAO updateEvent:tempVoIPEvent];
    tempVoIPEvent = (FxVoIPEvent*)[voIPDAO selectEvent:lastEventId];
    GHAssertEqualStrings([voIPEvent dateTime], [tempVoIPEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([voIPEvent mContactName], [tempVoIPEvent mContactName], @"Compare contact name");
    GHAssertEqualStrings([voIPEvent mUserID], [tempVoIPEvent mUserID], @"Compare user id");
    GHAssertEquals([voIPEvent mDirection], [tempVoIPEvent mDirection], @"Compare direction");
    GHAssertEquals(newDuration, [tempVoIPEvent mDuration], @"Compare duration");
    GHAssertEquals([voIPEvent mTransferedByte], [tempVoIPEvent mTransferedByte], @"Compare transfered byte");
    GHAssertEquals([voIPEvent mCategory], [tempVoIPEvent mCategory], @"Compare category");
    GHAssertEquals([voIPEvent mVoIPMonitor], [tempVoIPEvent mVoIPMonitor], @"Compare monitor");
    GHAssertEquals([voIPEvent mFrameStripID], [tempVoIPEvent mFrameStripID], @"Compare frame strip id");
    [voIPDAO deleteEvent:lastEventId];
    detailedCount = [voIPDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [voIPEvent release];
}

- (void) testStressTest {
    VoIPDAO* voIPDAO = [DAOFactory dataAccessObject:kEventTypeVoIP withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [voIPDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxVoIPEvent* voIPEvent = [[FxVoIPEvent alloc] init];
    voIPEvent.dateTime = kEventDateTime;
    voIPEvent.mContactName = kContactName;
    voIPEvent.mUserID = kContactNumber;
    voIPEvent.mDirection = kEventDirectionIn;
    voIPEvent.mCategory = kVoIPCategoryFaceTime;
    voIPEvent.mVoIPMonitor = kFxVoIPMonitorNO;
    voIPEvent.mFrameStripID = 5;
    NSInteger maxEventTest = 100;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        voIPEvent.mDuration = i;
        voIPEvent.mTransferedByte = i;
        [voIPDAO insertEvent:voIPEvent];
    }
    detailedCount = [voIPDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [voIPDAO selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxVoIPEvent* voIPEvent1 in eventArray) {
        lastEventId = [voIPEvent1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEqualStrings([voIPEvent dateTime], [voIPEvent1 dateTime], @"Compare date time");
        GHAssertEqualStrings([voIPEvent mContactName], [voIPEvent1 mContactName], @"Compare contact name");
        GHAssertEqualStrings([voIPEvent mUserID], [voIPEvent1 mUserID], @"Compare user id");
        GHAssertEquals([voIPEvent mDirection], [voIPEvent1 mDirection], @"Compare direction");
        GHAssertEquals([voIPEvent mCategory], [voIPEvent1 mCategory], @"Compare category");
        NSUInteger duration = i;
        NSUInteger transferedByte = i;
        GHAssertEquals(duration, [voIPEvent1 mDuration], @"Compare duration");
        GHAssertEquals(transferedByte, [voIPEvent1 mTransferedByte], @"Compare transfered byte");
        GHAssertEquals([voIPEvent mVoIPMonitor], [voIPEvent1 mVoIPMonitor], @"Compare monitor");
        GHAssertEquals([voIPEvent mFrameStripID], [voIPEvent1 mFrameStripID], @"Compare frame strip id");
        i++;
    }
    FxVoIPEvent* tempVoIPEvent = (FxVoIPEvent*)[voIPDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([voIPEvent dateTime], [tempVoIPEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([voIPEvent mContactName], [tempVoIPEvent mContactName], @"Compare contact name");
    GHAssertEqualStrings([voIPEvent mUserID], [tempVoIPEvent mUserID], @"Compare user id");
    GHAssertEquals([voIPEvent mDirection], [tempVoIPEvent mDirection], @"Compare direction");
    GHAssertEquals([voIPEvent mCategory], [tempVoIPEvent mCategory], @"Compare category");
    GHAssertEquals([voIPEvent mDuration], [tempVoIPEvent mDuration], @"Compare duration");
    GHAssertEquals([voIPEvent mTransferedByte], [tempVoIPEvent mTransferedByte], @"Compare transfered byte");
    GHAssertEquals([voIPEvent mVoIPMonitor], [tempVoIPEvent mVoIPMonitor], @"Compare monitor");
    GHAssertEquals([voIPEvent mFrameStripID], [tempVoIPEvent mFrameStripID], @"Compare frame strip id");
    NSUInteger newDuration = 500;
    [tempVoIPEvent setMDuration:newDuration];
    [voIPDAO updateEvent:tempVoIPEvent];
    tempVoIPEvent = (FxVoIPEvent*)[voIPDAO selectEvent:lastEventId];
    GHAssertEqualStrings([voIPEvent dateTime], [tempVoIPEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([voIPEvent mContactName], [tempVoIPEvent mContactName], @"Compare contact name");
    GHAssertEqualStrings([voIPEvent mUserID], [tempVoIPEvent mUserID], @"Compare user id");
    GHAssertEquals([voIPEvent mDirection], [tempVoIPEvent mDirection], @"Compare direction");
    GHAssertEquals([voIPEvent mCategory], [tempVoIPEvent mCategory], @"Compare category");
    GHAssertEquals(newDuration, [tempVoIPEvent mDuration], @"Compare duration");
    GHAssertEquals([voIPEvent mTransferedByte], [tempVoIPEvent mTransferedByte], @"Compare transfered byte");
    GHAssertEquals([voIPEvent mVoIPMonitor], [tempVoIPEvent mVoIPMonitor], @"Compare monitor");
    GHAssertEquals([voIPEvent mFrameStripID], [tempVoIPEvent mFrameStripID], @"Compare frame strip id");
    for (NSNumber* number in eventIdArray) {
        [voIPDAO deleteEvent:[number intValue]];
    }
    detailedCount = [voIPDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    [eventIdArray release];
    [voIPEvent release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
