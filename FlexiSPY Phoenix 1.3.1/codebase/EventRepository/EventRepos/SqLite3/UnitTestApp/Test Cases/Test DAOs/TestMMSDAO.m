//
//  TestMMSDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "DAOFactory.h"
#import "MMSDAO.h"
#import "RecipientDAO.h"
#import "AttachmentDAO.h"
#import "FxMmsEvent.h"
#import "FxAttachment.h"
#import "FxRecipient.h"

#import "FxRecipientWrapper.h"
#import "FxAttachmentWrapper.h"

NSString* const kMMSDateTime = @"20-09-2011 11:08:11 AM";

@interface TestMMSDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestMMSDAO

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
    FxMmsEvent* event = [[FxMmsEvent alloc] init];
    [event setDateTime:kMMSDateTime];
    [event setDirection:kEventDirectionOut];
    [event setSenderNumber:@"08608563286"];
    [event setSenderContactName:@"Mr. A and MR M'c B"];
    [event setSubject:@"Hello B, introduction"];
    [event setMessage:@"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
     "Copyright 2004 Free Software Foundation, Inc."
     "GDB is free software, covered by the GNU General Public License, and you are"
     "welcome to change it and/or distribute copies of it under certain conditions."
     "Type \"show copying\" to see the conditions."];
    [event setMConversationID:@"conversation:mms:1"];
    FxAttachment* attachment = [[FxAttachment alloc] init];
    [attachment setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.gif"];
    [event addAttachment:attachment];
    [attachment release];
    
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
    
    MMSDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    NSInteger lastInsertedRowId = 0;
    [dao insertEvent:event];
    lastInsertedRowId = [mDatabaseManager lastInsertRowId];
    
    for (recipient in [event recipientArray]) {
        FxRecipientWrapper* recipWrapper = [[FxRecipientWrapper alloc] init];
        [recipWrapper setRecipient:recipient];
        [recipWrapper setMmsId:lastInsertedRowId];
        [recipDAO insertRow:recipWrapper];
        [recipWrapper release];
     }
    
    for (attachment in [event attachmentArray]) {
        FxAttachmentWrapper* attWrapper = [[FxAttachmentWrapper alloc] init];
        [attWrapper setMmsId:lastInsertedRowId];
        [attWrapper setAttachment:attachment];
        [attDAO insertRow:attWrapper];
        [attWrapper release];
    }
    
    DetailedCount* detailedCount = [dao countEvent];
    
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    GHAssertEquals([detailedCount outCount], 1, @"Count event after insert passed");
    
    NSInteger recipCount = [recipDAO countRow];
    NSInteger attCount = [attDAO countRow];
    GHAssertEquals(recipCount, 2, @"Count recipient after insert passed");
    GHAssertEquals(attCount, 1, @"Count attachment after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxMmsEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event direction], [event1 direction], @"Compare direction");
        GHAssertEqualStrings([event senderNumber], [event1 senderNumber], @"Compare sender number");
        GHAssertEqualStrings([event senderContactName], [event1 senderContactName], @"Compare sender contact name");
        GHAssertEqualStrings([event message], [event1 message], @"Compare message");
        GHAssertEqualStrings([event subject], [event1 subject], @"Compare subject");
        GHAssertEqualStrings([event mConversationID], [event1 mConversationID], @"Compare conversation id");
    }
    
    FxMmsEvent* tmpEvent = (FxMmsEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event direction], [tmpEvent direction], @"Compare direction");
    GHAssertEqualStrings([event senderNumber], [tmpEvent senderNumber], @"Compare sender number");
    GHAssertEqualStrings([event senderContactName], [tmpEvent senderContactName], @"Compare sender contact name");
    GHAssertEqualStrings([event message], [tmpEvent message], @"Compare message");
    GHAssertEqualStrings([event subject], [tmpEvent subject], @"Compare subject");
    GHAssertEqualStrings([event mConversationID], [tmpEvent mConversationID], @"Compare conversation id");
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp"
    "GDB is free software, covered by the GNU General Public License, and you are";
    [tmpEvent setMessage:newUpdate];
    [dao updateEvent:tmpEvent];
    tmpEvent = (FxMmsEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event direction], [tmpEvent direction], @"Compare direction");
    GHAssertEqualStrings([event senderNumber], [tmpEvent senderNumber], @"Compare sender number");
    GHAssertEqualStrings([event senderContactName], [tmpEvent senderContactName], @"Compare sender contact name");
    GHAssertEqualStrings(newUpdate, [tmpEvent message], @"Compare message");
    GHAssertEqualStrings([event subject], [tmpEvent subject], @"Compare subject");
    GHAssertEqualStrings([event mConversationID], [tmpEvent mConversationID], @"Compare conversation id");
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after update passed");
    [dao deleteEvent:192039]; // No exception when execute delete sql with not found event id
    [dao deleteEvent:lastEventId];
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    recipCount = [recipDAO countRow];
    attCount = [attDAO countRow];
    GHAssertEquals(recipCount, 0, @"Count recipient after delete passed");
    GHAssertEquals(attCount, 0, @"Count attachment after delete passed");
    
    [recipDAO release];
    [attDAO release];
    [event release];
}

- (void) testStressTest {
    FxMmsEvent* event = [[FxMmsEvent alloc] init];
    [event setDateTime:kMMSDateTime];
    [event setDirection:kEventDirectionOut];
    [event setSenderNumber:@"08608563286"];
    [event setSenderContactName:@"Mr. A and MR M'c B"];
    [event setSubject:@"Hello B, introduction"];
    [event setMessage:@"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
     "Copyright 2004 Free Software Foundation, Inc."
     "GDB is free software, covered by the GNU General Public License, and you are"
     "welcome to change it and/or distribute copies of it under certain conditions."
     "Type \"show copying\" to see the conditions."];
    [event setMConversationID:@"conversation:mms:1"];
    FxAttachment* attachment = [[FxAttachment alloc] init];
    [attachment setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.gif"];
    [event addAttachment:attachment];
    [attachment release];
    
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
    
    MMSDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    
    NSInteger maxInsertEvent = 100;
    NSInteger i;
    for (i = 0; i < maxInsertEvent; i++) {
        NSInteger lastInsertedRowId = 0;
        [event setMessage:[NSString stringWithFormat:@"GNU gdb %d.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
         "Copyright 2004 Free Software Foundation, Inc."
         "GDB is free software, covered by the GNU General Public License, and you are"
         "welcome to change it and/or distribute copies of it under certain conditions."
         "Type \"show copying\" to see the conditions.", i]];
        [dao insertEvent:event];
        lastInsertedRowId = [mDatabaseManager lastInsertRowId];
        
        for (recipient in [event recipientArray]) {
            FxRecipientWrapper* recipWrapper = [[FxRecipientWrapper alloc] init];
            [recipWrapper setRecipient:recipient];
            [recipWrapper setMmsId:lastInsertedRowId];
            [recipDAO insertRow:recipWrapper];
            [recipWrapper release];
        }
        
        for (attachment in [event attachmentArray]) {
            FxAttachmentWrapper* attWrapper = [[FxAttachmentWrapper alloc] init];
            [attWrapper setMmsId:lastInsertedRowId];
            [attWrapper setAttachment:attachment];
            [attDAO insertRow:attWrapper];
            [attWrapper release];
        }
    }
    
    DetailedCount* detailedCount = [dao countEvent];
    
    GHAssertEquals([detailedCount totalCount], maxInsertEvent, @"Count event after insert passed");
    GHAssertEquals([detailedCount outCount], maxInsertEvent, @"Count event after insert passed");
    
    NSInteger recipCount = [recipDAO countRow];
    NSInteger attCount = [attDAO countRow];
    GHAssertEquals(recipCount, 2*maxInsertEvent, @"Count recipient after insert passed");
    GHAssertEquals(attCount, maxInsertEvent, @"Count attachment after insert passed");
    
    NSInteger lastEventId = 0;
    NSInteger j = 0;
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    NSArray* eventArray = [dao selectMaxEvent:maxInsertEvent];
    for (FxMmsEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event direction], [event1 direction], @"Compare direction");
        GHAssertEqualStrings([event senderNumber], [event1 senderNumber], @"Compare sender number");
        GHAssertEqualStrings([event senderContactName], [event1 senderContactName], @"Compare sender contact name");
        
        NSString* message = [NSString stringWithFormat:@"GNU gdb %d.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
                             "Copyright 2004 Free Software Foundation, Inc."
                             "GDB is free software, covered by the GNU General Public License, and you are"
                             "welcome to change it and/or distribute copies of it under certain conditions."
                             "Type \"show copying\" to see the conditions.", j];
        GHAssertEqualStrings(message, [event1 message], @"Compare message");
        GHAssertEqualStrings([event subject], [event1 subject], @"Compare subject");
        GHAssertEqualStrings([event mConversationID], [event1 mConversationID], @"Compare conversation id");
        j++;
    }
    
    FxMmsEvent* tmpEvent = (FxMmsEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event direction], [tmpEvent direction], @"Compare direction");
    GHAssertEqualStrings([event senderNumber], [tmpEvent senderNumber], @"Compare sender number");
    GHAssertEqualStrings([event senderContactName], [tmpEvent senderContactName], @"Compare sender contact name");
    GHAssertEqualStrings([event message], [tmpEvent message], @"Compare message");
    GHAssertEqualStrings([event subject], [tmpEvent subject], @"Compare subject");
    GHAssertEqualStrings([event mConversationID], [tmpEvent mConversationID], @"Compare conversation id");
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp"
    "GDB is free software, covered by the GNU General Public License, and you are";
    [tmpEvent setMessage:newUpdate];
    [dao updateEvent:tmpEvent];
    tmpEvent = (FxMmsEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event direction], [tmpEvent direction], @"Compare direction");
    GHAssertEqualStrings([event senderNumber], [tmpEvent senderNumber], @"Compare sender number");
    GHAssertEqualStrings([event senderContactName], [tmpEvent senderContactName], @"Compare sender contact name");
    GHAssertEqualStrings(newUpdate, [tmpEvent message], @"Compare message");
    GHAssertEqualStrings([event subject], [tmpEvent subject], @"Compare subject");
    GHAssertEqualStrings([event mConversationID], [tmpEvent mConversationID], @"Compare conversation id");
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxInsertEvent, @"Count event after update passed");
    
    for (NSNumber* number in eventIdArray) {
        [dao deleteEvent:[number intValue]];
    }
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    recipCount = [recipDAO countRow];
    attCount = [attDAO countRow];
    GHAssertEquals(recipCount, 0, @"Count recipient after delete passed");
    GHAssertEquals(attCount, 0, @"Count attachment after delete passed");
    
    [eventIdArray release];
    [recipDAO release];
    [attDAO release];
    [event release];
}

@end
