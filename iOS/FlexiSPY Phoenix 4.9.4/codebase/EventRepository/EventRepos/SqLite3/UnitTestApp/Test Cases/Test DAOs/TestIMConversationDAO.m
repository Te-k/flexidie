//
//  TestIMConversationDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 2/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "DAOFactory.h"
#import "IMConversationDAO.h"
#import "IMConversationContactDAO.h"

#import "FxIMConversationEvent.h"

static NSString * const kEventDateTime = @"11:11:11 2011-11-11";

@interface TestIMConversationDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestIMConversationDAO

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
    FxIMConversationEvent* imConversationEvent = [[FxIMConversationEvent alloc] init];
    imConversationEvent.dateTime = kEventDateTime;
    imConversationEvent.mServiceID = kIMServiceBBM;
    imConversationEvent.mAccountID = @"makarakhloth@gmail.com";
    imConversationEvent.mID = @"-023jlkef-kh_makara";
    imConversationEvent.mName = @"Makara KHLOTH";
    imConversationEvent.mStatusMessage = @"Where is the perfect world?";
    NSArray *participants = [NSArray arrayWithObjects:@"mr.a", @"mr. b", @"miss. c", @"ms. hill", nil];
    imConversationEvent.mContactIDs = participants;
    imConversationEvent.mPicture = [NSData data];
    IMConversationDAO* imContactDAO = [DAOFactory dataAccessObject:[imConversationEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    IMConversationContactDAO *imConvsContactDAO = [[IMConversationContactDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [imContactDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event before insert passed");
    [imContactDAO insertEvent:imConversationEvent];
    NSInteger lastInsertRow = [mDatabaseManager lastInsertRowId];
    for (NSString *participant in participants) {
        NSDictionary *rowInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:lastInsertRow], @"im_conversation_id", participant, @"im_conversation_contact_id", nil];
        //NSLog(@"rowInfo = %@", rowInfo);
        [imConvsContactDAO insertRow:rowInfo];
    }
    detailedCount = [imContactDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    GHAssertEquals([imConvsContactDAO countRow], (NSInteger)[participants count], @"Count contact id after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [imContactDAO selectMaxEvent:33];
    for (FxIMConversationEvent* imConversationEvent1 in eventArray) {
        lastEventId = [imConversationEvent1 eventId];
        GHAssertEqualStrings([imConversationEvent dateTime], [imConversationEvent1 dateTime], @"Compare date time");
        GHAssertEquals([imConversationEvent mServiceID], [imConversationEvent1 mServiceID], @"Compare service id");
        GHAssertEqualStrings([imConversationEvent mAccountID], [imConversationEvent1 mAccountID], @"Compare account id");
        GHAssertEqualStrings([imConversationEvent mID], [imConversationEvent1 mID], @"Compare conversation id");
        GHAssertEqualStrings([imConversationEvent mName], [imConversationEvent1 mName], @"Compare conversation name");
        GHAssertEqualStrings([imConversationEvent mStatusMessage], [imConversationEvent1 mStatusMessage], @"Compare status message");
        NSData *data1 = [imConversationEvent mPicture];
        NSData *data2 = [imConversationEvent1 mPicture];
        GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
        
        NSArray *rowInfos = [imConvsContactDAO selectRowWithIMConversationID:lastEventId];
        NSInteger index = 0;
        for (NSDictionary *rowInfo in rowInfos) {
            NSString *conversationContact1 = [rowInfo objectForKey:@"im_conversation_contact_id"];
            NSString *conversationContact2 = [participants objectAtIndex:index];
            GHAssertTrue([conversationContact1 isEqualToString:conversationContact2], @"Compare contact id");
            index++;
        }
    }
    FxIMConversationEvent* tempIMContactEvent = (FxIMConversationEvent *)[imContactDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([imConversationEvent dateTime], [tempIMContactEvent dateTime], @"Compare date time");
    GHAssertEquals([imConversationEvent mServiceID], [tempIMContactEvent mServiceID], @"Compare service id");
    GHAssertEqualStrings([imConversationEvent mAccountID], [tempIMContactEvent mAccountID], @"Compare account id");
    GHAssertEqualStrings([imConversationEvent mID], [tempIMContactEvent mID], @"Compare conversation id");
    GHAssertEqualStrings([imConversationEvent mName], [tempIMContactEvent mName], @"Compare conversation name");
    GHAssertEqualStrings([imConversationEvent mStatusMessage], [tempIMContactEvent mStatusMessage], @"Compare status message");
    NSData *data1 = [imConversationEvent mPicture];
    NSData *data2 = [tempIMContactEvent mPicture];
    GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
    
    NSString *newStatusMessage = @"Where is the hell?";
    [tempIMContactEvent setMStatusMessage:newStatusMessage];
    [imContactDAO updateEvent:tempIMContactEvent];
    tempIMContactEvent = (FxIMConversationEvent *)[imContactDAO selectEvent:lastEventId];
    GHAssertEqualStrings([imConversationEvent dateTime], [tempIMContactEvent dateTime], @"Compare date time");
    GHAssertEquals([imConversationEvent mServiceID], [tempIMContactEvent mServiceID], @"Compare service id");
    GHAssertEqualStrings([imConversationEvent mAccountID], [tempIMContactEvent mAccountID], @"Compare account id");
    GHAssertEqualStrings([imConversationEvent mID], [tempIMContactEvent mID], @"Compare conversation id");
    GHAssertEqualStrings([imConversationEvent mName], [tempIMContactEvent mName], @"Compare conversation name");
    GHAssertEqualStrings(newStatusMessage, [tempIMContactEvent mStatusMessage], @"Compare status message");
    data1 = [imConversationEvent mPicture];
    data2 = [tempIMContactEvent mPicture];
    GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
    
    [imContactDAO deleteEvent:lastEventId];
    detailedCount = [imContactDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    GHAssertEquals([imConvsContactDAO countRow], 0, @"Count contact id after insert passed");
    
    [imConversationEvent release];
}

- (void) testStressTest {
    FxIMConversationEvent* imConversationEvent = [[FxIMConversationEvent alloc] init];
    imConversationEvent.dateTime = kEventDateTime;
    imConversationEvent.mServiceID = kIMServiceBBM;
    imConversationEvent.mAccountID = @"makarakhloth@gmail.com";
    imConversationEvent.mID = @"-023jlkef-kh_makara";
    imConversationEvent.mName = @"Makara KHLOTH";
    imConversationEvent.mStatusMessage = @"Where is the perfect world?";
    NSArray *participants = [NSArray arrayWithObjects:@"mr.a", @"mr. b", @"miss. c", @"ms. hill", nil];
    imConversationEvent.mContactIDs = participants;
    imConversationEvent.mPicture = [NSData data];
    IMConversationDAO* imContactDAO = [DAOFactory dataAccessObject:[imConversationEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    IMConversationContactDAO *imConvsContactDAO = [[IMConversationContactDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [imContactDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event before insert passed");
    NSInteger maxEventTest = 100;
    for (NSInteger i = 0; i < maxEventTest; i++) {
        NSString *conversationID = [NSString stringWithFormat:@"-023jlkef-kh_makara- %d", i];
        imConversationEvent.mID = conversationID;
        [imContactDAO insertEvent:imConversationEvent];
        NSInteger lastInsertRow = [mDatabaseManager lastInsertRowId];
        for (NSString *participant in participants) {
            NSDictionary *rowInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:lastInsertRow], @"im_conversation_id", participant, @"im_conversation_contact_id", nil];
            //NSLog(@"rowInfo = %@", rowInfo);
            [imConvsContactDAO insertRow:rowInfo];
        }
    }
    detailedCount = [imContactDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    GHAssertEquals([imConvsContactDAO countRow], (NSInteger)([participants count] * maxEventTest), @"Count contact id after insert passed");
    
    NSInteger i = 0;
    NSInteger lastEventId = 0;
    NSMutableArray *eventIDArray = [NSMutableArray arrayWithCapacity:maxEventTest];
    NSArray* eventArray = [imContactDAO selectMaxEvent:maxEventTest];
    for (FxIMConversationEvent* imConversationEvent1 in eventArray) {
        lastEventId = [imConversationEvent1 eventId];
        [eventIDArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *conversationID = [NSString stringWithFormat:@"-023jlkef-kh_makara- %d", i];
        GHAssertEqualStrings([imConversationEvent dateTime], [imConversationEvent1 dateTime], @"Compare date time");
        GHAssertEquals([imConversationEvent mServiceID], [imConversationEvent1 mServiceID], @"Compare service id");
        GHAssertEqualStrings([imConversationEvent mAccountID], [imConversationEvent1 mAccountID], @"Compare account id");
        GHAssertEqualStrings(conversationID, [imConversationEvent1 mID], @"Compare conversation id");
        GHAssertEqualStrings([imConversationEvent mName], [imConversationEvent1 mName], @"Compare conversation name");
        GHAssertEqualStrings([imConversationEvent mStatusMessage], [imConversationEvent1 mStatusMessage], @"Compare status message");
        NSData *data1 = [imConversationEvent mPicture];
        NSData *data2 = [imConversationEvent1 mPicture];
        GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
        
        NSArray *rowInfos = [imConvsContactDAO selectRowWithIMConversationID:lastEventId];
        NSInteger index = 0;
        for (NSDictionary *rowInfo in rowInfos) {
            NSString *conversationContact1 = [rowInfo objectForKey:@"im_conversation_contact_id"];
            NSString *conversationContact2 = [participants objectAtIndex:index];
            GHAssertTrue([conversationContact1 isEqualToString:conversationContact2], @"Compare contact id");
            index++;
        }
        i++;
    }
    FxIMConversationEvent* tempIMContactEvent = (FxIMConversationEvent *)[imContactDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([imConversationEvent dateTime], [tempIMContactEvent dateTime], @"Compare date time");
    GHAssertEquals([imConversationEvent mServiceID], [tempIMContactEvent mServiceID], @"Compare service id");
    GHAssertEqualStrings([imConversationEvent mAccountID], [tempIMContactEvent mAccountID], @"Compare account id");
    GHAssertEqualStrings([imConversationEvent mID], [tempIMContactEvent mID], @"Compare conversation id");
    GHAssertEqualStrings([imConversationEvent mName], [tempIMContactEvent mName], @"Compare conversation name");
    GHAssertEqualStrings([imConversationEvent mStatusMessage], [tempIMContactEvent mStatusMessage], @"Compare status message");
    NSData *data1 = [imConversationEvent mPicture];
    NSData *data2 = [tempIMContactEvent mPicture];
    GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
    
    NSString *newStatusMessage = @"Where is the hell?";
    [tempIMContactEvent setMStatusMessage:newStatusMessage];
    [imContactDAO updateEvent:tempIMContactEvent];
    tempIMContactEvent = (FxIMConversationEvent *)[imContactDAO selectEvent:lastEventId];
    GHAssertEqualStrings([imConversationEvent dateTime], [tempIMContactEvent dateTime], @"Compare date time");
    GHAssertEquals([imConversationEvent mServiceID], [tempIMContactEvent mServiceID], @"Compare service id");
    GHAssertEqualStrings([imConversationEvent mAccountID], [tempIMContactEvent mAccountID], @"Compare account id");
    GHAssertEqualStrings([imConversationEvent mID], [tempIMContactEvent mID], @"Compare conversation id");
    GHAssertEqualStrings([imConversationEvent mName], [tempIMContactEvent mName], @"Compare conversation name");
    GHAssertEqualStrings(newStatusMessage, [tempIMContactEvent mStatusMessage], @"Compare status message");
    data1 = [imConversationEvent mPicture];
    data2 = [tempIMContactEvent mPicture];
    GHAssertTrue([data1 isEqualToData:data2], @"Compare picture");
    
    for (NSNumber *eventID in eventIDArray) {
        [imContactDAO deleteEvent:[eventID intValue]];
    }
    detailedCount = [imContactDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    GHAssertEquals([imConvsContactDAO countRow], 0, @"Count contact id after insert passed");
    
    [imConversationEvent release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
