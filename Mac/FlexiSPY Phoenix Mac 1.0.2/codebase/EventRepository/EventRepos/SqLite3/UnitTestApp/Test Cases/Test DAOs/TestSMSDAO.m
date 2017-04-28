//
//  TestSMSDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "DAOFactory.h"
#import "SMSDAO.h"
#import "RecipientDAO.h"
#import "FxSmsEvent.h"
#import "FxRecipient.h"

#import "FxRecipientWrapper.h"

NSString* const kSMSDateTime = @"20-09-2011 11:08:11 AM";

@interface TestSMSDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestSMSDAO

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
    FxSmsEvent* event = [[FxSmsEvent alloc] init];
    [event setDateTime:kSMSDateTime];
    [event setDirection:kEventDirectionOut];
    [event setSenderNumber:@"+85511773337"];
    [event setContactName:@"Mr. A and MR M'c B"];
    [event setSmsSubject:@"Hello B, introduction"];
    [event setSmsData: @"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
     "Copyright 2004 Free Software Foundation, Inc."
     "GDB is free software, covered by the GNU General 'Public License', and you are"
     "welcome to change it and/or distribute copies of it under certain conditions."
     "Type \"show copying\" to see the conditions."];
    [event setMConversationID:@"converstion:sms:1"];
    // @todo back to test [add the same recipient object but change the value after added, and see what happen?]
    FxRecipient* recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 007"];
    [recipient setRecipNumAddr:@"jame@porn.com"];
    [recipient setRecipType:kFxRecipientTO];
    [event addRecipient:recipient];
    [recipient release];
    recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 069"];
    [recipient setRecipNumAddr:@"jame@pornxx.com"];
    [recipient setRecipType:kFxRecipientCC];
    [event addRecipient:recipient];
    [recipient release];
    
    SMSDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    NSInteger lastInsertedRowId = 0;
    [dao insertEvent:event];
    lastInsertedRowId = [mDatabaseManager lastInsertRowId];
    
    for (recipient in [event recipientArray]) {
        FxRecipientWrapper* recipWrapper = [[FxRecipientWrapper alloc] init];
        [recipWrapper setRecipient:recipient];
        [recipWrapper setSmsId:lastInsertedRowId];
        [recipDAO insertRow:recipWrapper];
        [recipWrapper release];
    }
    
    DetailedCount* detailedCount = [dao countEvent];
    
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    GHAssertEquals([detailedCount outCount], 1, @"Count event after insert passed");
    
    NSInteger recipCount = [recipDAO countRow];
    GHAssertEquals(recipCount, 2, @"Count recipient after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxSmsEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event direction], [event1 direction], @"Compare direction");
        GHAssertEqualStrings([event senderNumber], [event1 senderNumber], @"Compare sender number");
        GHAssertEqualStrings([event contactName], [event1 contactName], @"Compare contact name");
        GHAssertEqualStrings([event smsData], [event1 smsData], @"Compare sms data");
        GHAssertEqualStrings([event smsSubject], [event1 smsSubject], @"Compare sms subject");
        GHAssertEqualStrings([event mConversationID], [event1 mConversationID], @"Compare conversation id");
    }
    
    FxSmsEvent* tmpEvent = (FxSmsEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event direction], [tmpEvent direction], @"Compare direction");
    GHAssertEqualStrings([event senderNumber], [tmpEvent senderNumber], @"Compare sender number");
    GHAssertEqualStrings([event contactName], [tmpEvent contactName], @"Compare contact name");
    GHAssertEqualStrings([event smsData], [tmpEvent smsData], @"Compare sms data");
    GHAssertEqualStrings([event smsSubject], [tmpEvent smsSubject], @"Compare sms subject");
    GHAssertEqualStrings([event mConversationID], [tmpEvent mConversationID], @"Compare conversation id");
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp"
    "GDB is free software, covered by the GNU General Public License, and you are";
    [tmpEvent setSmsData:newUpdate];
    [dao updateEvent:tmpEvent];
    tmpEvent = (FxSmsEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event direction], [tmpEvent direction], @"Compare direction");
    GHAssertEqualStrings([event senderNumber], [tmpEvent senderNumber], @"Compare sender number");
    GHAssertEqualStrings([event contactName], [tmpEvent contactName], @"Compare contact name");
    GHAssertEqualStrings(newUpdate, [tmpEvent smsData], @"Compare sms data");
    GHAssertEqualStrings([event smsSubject], [tmpEvent smsSubject], @"Compare sms subject");
    GHAssertEqualStrings([event mConversationID], [tmpEvent mConversationID], @"Compare conversation id");
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after update passed");
    [dao deleteEvent:192039]; // No exception when execute delete sql with not found event id
    [dao deleteEvent:lastEventId];
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    recipCount = [recipDAO countRow];
    GHAssertEquals(recipCount, 0, @"Count recipient after delete passed");
    
    [recipDAO release];
    [event release];
}

- (void) testStressTest {
    FxSmsEvent* event = [[FxSmsEvent alloc] init];
    [event setDateTime:kSMSDateTime];
    [event setDirection:kEventDirectionIn];
    [event setSenderNumber:@"+85511773337"];
    [event setContactName:@"Mr. A and MR M'c B"];
    [event setSmsSubject:@"Hello B, introduction"];
    [event setSmsData: @"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
     "Copyright 2004 Free Software Foundation, Inc."
     "GDB is free software, covered by the GNU General 'Public License', and you are"
     "welcome to change it and/or distribute copies of it under certain conditions."
     "Type \"show copying\" to see the conditions."];
    [event setMConversationID:@"conversation:sms:1"];
    // @todo back to test [add the same recipient object but change the value after added, and see what happen?]
    FxRecipient* recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 007"];
    [recipient setRecipNumAddr:@"jame@porn.com"];
    [recipient setRecipType:kFxRecipientTO];
    [event addRecipient:recipient];
    [recipient release];
    recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 069"];
    [recipient setRecipNumAddr:@"jame@pornxx.com"];
    [recipient setRecipType:kFxRecipientCC];
    [event addRecipient:recipient];
    [recipient release];
    
    SMSDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    
    NSInteger lastInsertedRowId = 0;
    NSInteger maxInsertEvent = 100;
    NSInteger i;
    for (i = 0; i < maxInsertEvent; i++) {
        [event setSenderNumber:[NSString stringWithFormat:@"+66%d17786555", i]];
        [dao insertEvent:event];
        lastInsertedRowId = [mDatabaseManager lastInsertRowId];
        
        for (recipient in [event recipientArray]) {
            FxRecipientWrapper* recipWrapper = [[FxRecipientWrapper alloc] init];
            [recipWrapper setRecipient:recipient];
            [recipWrapper setSmsId:lastInsertedRowId];
            [recipDAO insertRow:recipWrapper];
            [recipWrapper release];
        }
    }
    
    DetailedCount* detailedCount = [dao countEvent];
    
    GHAssertEquals([detailedCount totalCount], maxInsertEvent, @"Count event after insert passed");
    GHAssertEquals([detailedCount inCount], maxInsertEvent, @"Count event after insert passed");
    
    NSInteger recipCount = [recipDAO countRow];
    GHAssertEquals(recipCount, 2*maxInsertEvent, @"Count recipient after insert passed");
    
    NSInteger lastEventId = 0;
    NSInteger j = 0;
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    NSArray* eventArray = [dao selectMaxEvent:maxInsertEvent];
    for (FxSmsEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event direction], [event1 direction], @"Compare direction");
        
        NSString* senderNumber = [NSString stringWithFormat:@"+66%d17786555", j];
        GHAssertEqualStrings(senderNumber, [event1 senderNumber], @"Compare sender number");
        GHAssertEqualStrings([event contactName], [event1 contactName], @"Compare contact name");
        GHAssertEqualStrings([event smsData], [event1 smsData], @"Compare sms data");
        GHAssertEqualStrings([event smsSubject], [event1 smsSubject], @"Compare sms subject");
        GHAssertEqualStrings([event mConversationID], [event1 mConversationID], @"Compare conversation id");
        j++;
    }
    
    FxSmsEvent* tmpEvent = (FxSmsEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event direction], [tmpEvent direction], @"Compare direction");
    GHAssertEqualStrings([event senderNumber], [tmpEvent senderNumber], @"Compare sender number");
    GHAssertEqualStrings([event contactName], [tmpEvent contactName], @"Compare contact name");
    GHAssertEqualStrings([event smsData], [tmpEvent smsData], @"Compare sms data");
    GHAssertEqualStrings([event smsSubject], [tmpEvent smsSubject], @"Compare sms subject");
    GHAssertEqualStrings([event mConversationID], [tmpEvent mConversationID], @"Compare conversation id");
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp"
    "GDB is free software, covered by the GNU General Public License, and you are";
    [tmpEvent setSmsData:newUpdate];
    [dao updateEvent:tmpEvent];
    tmpEvent = (FxSmsEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event direction], [tmpEvent direction], @"Compare direction");
    GHAssertEqualStrings([event senderNumber], [tmpEvent senderNumber], @"Compare sender number");
    GHAssertEqualStrings([event contactName], [tmpEvent contactName], @"Compare contact name");
    GHAssertEqualStrings(newUpdate, [tmpEvent smsData], @"Compare sms data");
    GHAssertEqualStrings([event smsSubject], [tmpEvent smsSubject], @"Compare sms subject");
    GHAssertEqualStrings([event mConversationID], [tmpEvent mConversationID], @"Compare conversation id");
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxInsertEvent, @"Count event after update passed");
    
    recipCount = [recipDAO countRow];
    GHAssertEquals(recipCount, 2*maxInsertEvent, @"Count recipient after update passed");
    
    [dao deleteEvent:192039]; // No exception when execute delete sql with not found event id
    
    for (NSNumber* number in eventIdArray) {
        [dao deleteEvent:[number intValue]];
    }
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    recipCount = [recipDAO countRow];
    GHAssertEquals(recipCount, 0, @"Count recipient after delete passed");
    
    [eventIdArray release];
    [recipDAO release];
    [event release];
}

@end


