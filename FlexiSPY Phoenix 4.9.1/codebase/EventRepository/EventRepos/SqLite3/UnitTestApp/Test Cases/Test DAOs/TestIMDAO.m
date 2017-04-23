//
//  TestIMDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "DAOFactory.h"
#import "IMDAO.h"
#import "RecipientDAO.h"
#import "AttachmentDAO.h"
#import "FxIMEvent.h"
#import "FxAttachment.h"
#import "FxRecipient.h"

#import "FxRecipientWrapper.h"
#import "FxAttachmentWrapper.h"

NSString* const kIMDateTime = @"20-09-2011 11:08:11 AM";

@interface TestIMDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestIMDAO

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
    FxIMEvent* event = [[FxIMEvent alloc] init];
    [event setDateTime:kIMDateTime];
    [event setMDirection:kEventDirectionOut];
    [event setMUserID:@"helloworld@apple.com"];
    [event setMIMServiceID:@"Skype"];
    [event setMUserDisplayName:@"Hello B, introduction"];
    [event setMMessage:@"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
     "Copyright 2004 Free Software Foundation, Inc."
     "GDB is free software, covered by the GNU General Public License, and you are"
     "welcome to change it and/or distribute copies of it under certain conditions."
     "Type \"show copying\" to see the conditions."];
    
    FxAttachment* attachment = [[FxAttachment alloc] init];
    [attachment setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.gif"];
    NSMutableArray *attachments = [NSMutableArray array];
    [attachments addObject:attachment];
    [event setMAttachments:attachments];
    [attachment release];
    
    // @todo back to test [add the same recipient object but change the value after added, and see what happen?]
    NSMutableArray *participants = [NSMutableArray array];
    FxRecipient* recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 007"];
    [recipient setRecipNumAddr:@"jame@porn.com"];
    [recipient setRecipType:kFxRecipientTO];
    [participants addObject:recipient];
    [recipient release];
    recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 069"];
    [recipient setRecipNumAddr:@"jame@pornxx.com"];
    [recipient setRecipType:kFxRecipientCC];
    [participants addObject:recipient];
    [recipient release];
    [event setMParticipants:participants];
    
    IMDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    NSInteger lastInsertedRowId = 0;
    [dao insertEvent:event];
    
    lastInsertedRowId = [mDatabaseManager lastInsertRowId];
    
    for (recipient in [event mParticipants]) {
        FxRecipientWrapper* recipWrapper = [[FxRecipientWrapper alloc] init];
        [recipWrapper setRecipient:recipient];
        [recipWrapper setMIMID:lastInsertedRowId];
        [recipDAO insertRow:recipWrapper];
        [recipWrapper release];
    }
    
    for (attachment in [event mAttachments]) {
        FxAttachmentWrapper* attWrapper = [[FxAttachmentWrapper alloc] init];
        [attWrapper setMIMID:lastInsertedRowId];
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
    for (FxIMEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event mDirection], [event1 mDirection], @"Compare direction");
        GHAssertEqualStrings([event mUserID], [event1 mUserID], @"Compare user id");
        GHAssertEqualStrings([event mIMServiceID], [event1 mIMServiceID], @"Compare im service id");
        GHAssertEqualStrings([event mMessage], [event1 mMessage], @"Compare message");
        GHAssertEqualStrings([event mUserDisplayName], [event1 mUserDisplayName], @"Compare user display name");
    }
    
    FxIMEvent* tmpEvent = (FxIMEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event mDirection], [tmpEvent mDirection], @"Compare direction");
    GHAssertEqualStrings([event mUserID], [tmpEvent mUserID], @"Compare user id");
    GHAssertEqualStrings([event mIMServiceID], [tmpEvent mIMServiceID], @"Compare im service id");
    GHAssertEqualStrings([event mMessage], [tmpEvent mMessage], @"Compare message");
    GHAssertEqualStrings([event mUserDisplayName], [tmpEvent mUserDisplayName], @"Compare user display name");
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp"
    "GDB is free software, covered by the GNU General Public License, and you are";
    [tmpEvent setMMessage:newUpdate];
    [dao updateEvent:tmpEvent];
    tmpEvent = (FxIMEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event mDirection], [tmpEvent mDirection], @"Compare direction");
    GHAssertEqualStrings([event mUserID], [tmpEvent mUserID], @"Compare user id");
    GHAssertEqualStrings([event mIMServiceID], [tmpEvent mIMServiceID], @"Compare im service id");
    GHAssertEqualStrings(newUpdate, [tmpEvent mMessage], @"Compare message");
    GHAssertEqualStrings([event mUserDisplayName], [tmpEvent mUserDisplayName], @"Compare user display name");
    
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
    FxIMEvent* event = [[FxIMEvent alloc] init];
    [event setDateTime:kIMDateTime];
    [event setMDirection:kEventDirectionOut];
    [event setMUserID:@"helloworld@apple.com"];
    [event setMIMServiceID:@"Skype"];
    [event setMUserDisplayName:@"Hello B, introduction"];
    [event setMMessage:@"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
     "Copyright 2004 Free Software Foundation, Inc."
     "GDB is free software, covered by the GNU General Public License, and you are"
     "welcome to change it and/or distribute copies of it under certain conditions."
     "Type \"show copying\" to see the conditions."];
    
    FxAttachment* attachment = [[FxAttachment alloc] init];
    [attachment setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.gif"];
    NSMutableArray *attachments = [NSMutableArray array];
    [attachments addObject:attachment];
    [event setMAttachments:attachments];
    [attachment release];
    
    // @todo back to test [add the same recipient object but change the value after added, and see what happen?]
    NSMutableArray *participants = [NSMutableArray array];
    FxRecipient* recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 007"];
    [recipient setRecipNumAddr:@"jame@porn.com"];
    [recipient setRecipType:kFxRecipientTO];
    [participants addObject:recipient];
    [recipient release];
    recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 069"];
    [recipient setRecipNumAddr:@"jame@pornxx.com"];
    [recipient setRecipType:kFxRecipientCC];
    [participants addObject:recipient];
    [recipient release];
    [event setMParticipants:participants];
    
    IMDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    
    NSInteger maxInsertEvent = 100;
    NSInteger i;
    for (i = 0; i < maxInsertEvent; i++) {
        NSInteger lastInsertedRowId = 0;
        [event setMMessage:[NSString stringWithFormat:@"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
         "Copyright 2004 Free Software Foundation, Inc."
         "GDB is free software, covered by the GNU General Public License, and you are"
         "welcome to change it and/or distribute copies of it under certain conditions."
         "Type \"show copying\" to see the %d conditions.", i]];
        [dao insertEvent:event];
        
        lastInsertedRowId = [mDatabaseManager lastInsertRowId];
        
        for (recipient in [event mParticipants]) {
            FxRecipientWrapper* recipWrapper = [[FxRecipientWrapper alloc] init];
            [recipWrapper setRecipient:recipient];
            [recipWrapper setMIMID:lastInsertedRowId];
            [recipDAO insertRow:recipWrapper];
            [recipWrapper release];
        }
        
        for (attachment in [event mAttachments]) {
            FxAttachmentWrapper* attWrapper = [[FxAttachmentWrapper alloc] init];
            [attWrapper setMIMID:lastInsertedRowId];
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
    GHAssertEquals(attCount, 1*maxInsertEvent, @"Count attachment after insert passed");
    
    i = 0;
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:maxInsertEvent];
    NSMutableArray* eventIdArray = [NSMutableArray array];
    for (FxIMEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event mDirection], [event1 mDirection], @"Compare direction");
        GHAssertEqualStrings([event mUserID], [event1 mUserID], @"Compare user id");
        GHAssertEqualStrings([event mIMServiceID], [event1 mIMServiceID], @"Compare im service id");
        
        NSString* test = [NSString stringWithFormat:@"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
         "Copyright 2004 Free Software Foundation, Inc."
         "GDB is free software, covered by the GNU General Public License, and you are"
         "welcome to change it and/or distribute copies of it under certain conditions."
                          "Type \"show copying\" to see the %d conditions.", i];
        
        GHAssertEqualStrings(test, [event1 mMessage], @"Compare message");
        GHAssertEqualStrings([event mUserDisplayName], [event1 mUserDisplayName], @"Compare user display name");
        i++;
    }
    
    FxIMEvent* tmpEvent = (FxIMEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event mDirection], [tmpEvent mDirection], @"Compare direction");
    GHAssertEqualStrings([event mUserID], [tmpEvent mUserID], @"Compare user id");
    GHAssertEqualStrings([event mIMServiceID], [tmpEvent mIMServiceID], @"Compare im service id");
    GHAssertEqualStrings([event mMessage], [tmpEvent mMessage], @"Compare message");
    GHAssertEqualStrings([event mUserDisplayName], [tmpEvent mUserDisplayName], @"Compare user display name");
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp"
    "GDB is free software, covered by the GNU General Public License, and you are";
    [tmpEvent setMMessage:newUpdate];
    [dao updateEvent:tmpEvent];
    tmpEvent = (FxIMEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event mDirection], [tmpEvent mDirection], @"Compare direction");
    GHAssertEqualStrings([event mUserID], [tmpEvent mUserID], @"Compare user id");
    GHAssertEqualStrings([event mIMServiceID], [tmpEvent mIMServiceID], @"Compare im service id");
    GHAssertEqualStrings(newUpdate, [tmpEvent mMessage], @"Compare message");
    GHAssertEqualStrings([event mUserDisplayName], [tmpEvent mUserDisplayName], @"Compare user display name");
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxInsertEvent, @"Count event after update passed");
    [dao deleteEvent:192039]; // No exception when execute delete sql with not found event id
    [dao deleteEvent:lastEventId];
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxInsertEvent - 1, @"Count event after delete passed");
    
    recipCount = [recipDAO countRow];
    attCount = [attDAO countRow];
    GHAssertEquals(recipCount, (maxInsertEvent - 1) *2, @"Count recipient after delete passed");
    GHAssertEquals(attCount, maxInsertEvent - 1, @"Count attachment after delete passed");
    
    for (NSNumber* number in eventIdArray) {
        [dao deleteEvent:[number intValue]];
    }
    
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

@end

