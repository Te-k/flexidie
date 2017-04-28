//
//  TestEmailMacOSDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 2/12/15.
//
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxEmailMacOSEvent.h"
#import "FxRecipient.h"
#import "FxRecipientWrapper.h"
#import "FxAttachment.h"
#import "FxAttachmentWrapper.h"
#import "EmailMacOSDAO.h"
#import "RecipientDAO.h"
#import "AttachmentDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestEmailMacOSDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestEmailMacOSDAO

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
    FxEmailMacOSEvent* event = [[FxEmailMacOSEvent alloc] init];
    [event setDateTime:kEventDateTime];
    [event setMDirection:kEventDirectionOut];
    [event setMUserLogonName:@"Ophat"];
    [event setMApplicationID:@"com.kbak.kmobile"];
    [event setMApplicationName:@"KBank Mobile"];
    [event setMTitle:@"iTune Connect"];
    [event setMEmailServiceType:kEmailServiceTypeYahoo];
    [event setMSenderEmail:@"helloworld@apple.com"];
    [event setMSenderName:@"Mr. A and MR M'c B"];
    [event setMSubject:@"Hello B, introduction"];
    [event setMBody:@"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
     "Copyright 2004 Free Software Foundation, Inc."
     "GDB is free software, covered by the GNU General Public License, and you are"
     "welcome to change it and/or distribute copies of it under certain conditions."
     "Type \"show copying\" to see the conditions."];
    
    FxAttachment* attachment = [[FxAttachment alloc] init];
    [attachment setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.gif"];
    [event setMAttachments:[NSArray arrayWithObject:attachment]];
    [attachment release];
    
    NSMutableArray *recipients = [NSMutableArray array];
    FxRecipient* recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 007"];
    [recipient setRecipNumAddr:@"jame@porn.com"];
    [recipient setRecipType:kFxRecipientTO];
    [recipients addObject:recipient];
    [recipient release];
    recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 069"];
    [recipient setRecipNumAddr:@"jame@pornxx.com"];
    [recipient setRecipType:kFxRecipientCC];
    [recipients addObject:recipient];
    [recipient release];
    
    [event setMRecipients:recipients];
    
    EmailMacOSDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    NSInteger lastInsertedRowId = 0;
    [dao insertEvent:event];
    lastInsertedRowId = [mDatabaseManager lastInsertRowId];
    
    for (recipient in [event mRecipients]) {
        FxRecipientWrapper* recipWrapper = [[FxRecipientWrapper alloc] init];
        [recipWrapper setRecipient:recipient];
        [recipWrapper setEmailId:lastInsertedRowId];
        [recipDAO insertRow:recipWrapper];
        [recipWrapper release];
    }
    
    for (attachment in [event mAttachments]) {
        FxAttachmentWrapper* attWrapper = [[FxAttachmentWrapper alloc] init];
        [attWrapper setEmailId:lastInsertedRowId];
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
    for (FxEmailMacOSEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event mDirection], [event1 mDirection], @"Compare direction");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application id");
        GHAssertEqualStrings([event mApplicationName], [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEquals([event mEmailServiceType], [event1 mEmailServiceType], @"Compare email service type");
        GHAssertEqualStrings([event mSenderEmail], [event1 mSenderEmail], @"Compare sender email");
        GHAssertEqualStrings([event mSenderName], [event1 mSenderName], @"Compare sender name");
        GHAssertEqualStrings([event mBody], [event1 mBody], @"Compare body");
        GHAssertEqualStrings([event mSubject], [event1 mSubject], @"Compare subject");
    }
    
    FxEmailMacOSEvent* tmpEvent = (FxEmailMacOSEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event mDirection], [tmpEvent mDirection], @"Compare direction");
    GHAssertEqualStrings([event mUserLogonName], [tmpEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tmpEvent mApplicationID], @"Compare application id");
    GHAssertEqualStrings([event mApplicationName], [tmpEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tmpEvent mTitle], @"Compare title");
    GHAssertEquals([event mEmailServiceType], [tmpEvent mEmailServiceType], @"Compare email service type");
    GHAssertEqualStrings([event mSenderEmail], [tmpEvent mSenderEmail], @"Compare sender email");
    GHAssertEqualStrings([event mSenderName], [tmpEvent mSenderName], @"Compare sender name");
    GHAssertEqualStrings([event mBody], [tmpEvent mBody], @"Compare body");
    GHAssertEqualStrings([event mSubject], [tmpEvent mSubject], @"Compare subject");
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp"
    "GDB is free software, covered by the GNU General Public License, and you are";
    [tmpEvent setMBody:newUpdate];
    [dao updateEvent:tmpEvent];
    tmpEvent = (FxEmailMacOSEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event mDirection], [tmpEvent mDirection], @"Compare direction");
    GHAssertEqualStrings([event mUserLogonName], [tmpEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tmpEvent mApplicationID], @"Compare application id");
    GHAssertEqualStrings([event mApplicationName], [tmpEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tmpEvent mTitle], @"Compare title");
    GHAssertEquals([event mEmailServiceType], [tmpEvent mEmailServiceType], @"Compare email service type");
    GHAssertEqualStrings([event mSenderEmail], [tmpEvent mSenderEmail], @"Compare sender email");
    GHAssertEqualStrings([event mSenderName], [tmpEvent mSenderName], @"Compare sender name");
    GHAssertEqualStrings(newUpdate, [tmpEvent mBody], @"Compare body");
    GHAssertEqualStrings([event mSubject], [tmpEvent mSubject], @"Compare subject");
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after update passed");
    [dao deleteEvent:192039]; // No exception when execute delete sql with not found event id
    [dao deleteEvent:lastEventId];
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    // Trigger testing...
    recipCount = [recipDAO countRow];
    attCount = [attDAO countRow];
    GHAssertEquals(recipCount, 0, @"Count recipient after delete passed");
    GHAssertEquals(attCount, 0, @"Count attachment after delete passed");
    
    [recipDAO release];
    [attDAO release];
    [event release];
}

- (void) testStressTest {
    FxEmailMacOSEvent* event = [[FxEmailMacOSEvent alloc] init];
    [event setDateTime:kEventDateTime];
    [event setMDirection:kEventDirectionOut];
    [event setMUserLogonName:@"Ophat"];
    [event setMApplicationID:@"com.kbak.kmobile"];
    [event setMApplicationName:@"KBank Mobile"];
    [event setMTitle:@"iTune Connect"];
    [event setMEmailServiceType:kEmailServiceTypeLiveHotmail];
    [event setMSenderEmail:@"helloworld@apple.com"];
    [event setMSenderName:@"Mr. A and MR M'c B"];
    [event setMSubject:@"Hello B, introduction"];
    [event setMBody:@"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
     "Copyright 2004 Free Software Foundation, Inc."
     "GDB is free software, covered by the GNU General Public License, and you are"
     "welcome to change it and/or distribute copies of it under certain conditions."
     "Type \"show copying\" to see the conditions."];
    
    FxAttachment* attachment = [[FxAttachment alloc] init];
    [attachment setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.gif"];
    [event setMAttachments:[NSArray arrayWithObject:attachment]];
    [attachment release];
    
    NSMutableArray *recipients = [NSMutableArray array];
    FxRecipient* recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 007"];
    [recipient setRecipNumAddr:@"jame@porn.com"];
    [recipient setRecipType:kFxRecipientTO];
    [recipients addObject:recipient];
    [recipient release];
    recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 069"];
    [recipient setRecipNumAddr:@"jame@pornxx.com"];
    [recipient setRecipType:kFxRecipientCC];
    [recipients addObject:recipient];
    [recipient release];
    
    [event setMRecipients:recipients];
    
    EmailMacOSDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    RecipientDAO* recipDAO = [[RecipientDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    AttachmentDAO* attDAO = [[AttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    
    NSInteger maxInsertEvent = 1000;
    NSInteger i;
    for (i = 0; i < maxInsertEvent; i++) {
        NSInteger lastInsertedRowId = 0;
        [event setMBody:[NSString stringWithFormat:@"GNU gdb %d.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
                           "Copyright 2004 Free Software Foundation, Inc."
                           "GDB is free software, covered by the GNU General Public License, and you are"
                           "welcome to change it and/or distribute copies of it under certain conditions."
                           "Type \"show copying\" to see the conditions.", i]];
        [dao insertEvent:event];
        lastInsertedRowId = [mDatabaseManager lastInsertRowId];
        
        for (recipient in [event mRecipients]) {
            FxRecipientWrapper* recipWrapper = [[FxRecipientWrapper alloc] init];
            [recipWrapper setRecipient:recipient];
            [recipWrapper setEmailId:lastInsertedRowId];
            [recipDAO insertRow:recipWrapper];
            [recipWrapper release];
        }
        
        for (attachment in [event mAttachments]) {
            FxAttachmentWrapper* attWrapper = [[FxAttachmentWrapper alloc] init];
            [attWrapper setEmailId:lastInsertedRowId];
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
    for (FxEmailMacOSEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event mDirection], [event1 mDirection], @"Compare direction");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application id");
        GHAssertEqualStrings([event mApplicationName], [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEquals([event mEmailServiceType], [event1 mEmailServiceType], @"Compare email service type");
        GHAssertEqualStrings([event mSenderEmail], [event1 mSenderEmail], @"Compare sender email");
        GHAssertEqualStrings([event mSenderName], [event1 mSenderName], @"Compare sender name");
        
        NSString* message = [NSString stringWithFormat:@"GNU gdb %d.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
                             "Copyright 2004 Free Software Foundation, Inc."
                             "GDB is free software, covered by the GNU General Public License, and you are"
                             "welcome to change it and/or distribute copies of it under certain conditions."
                             "Type \"show copying\" to see the conditions.", j];
        GHAssertEqualStrings(message, [event1 mBody], @"Compare body");
        GHAssertEqualStrings([event mSubject], [event1 mSubject], @"Compare subject");
        j++;
    }
    
    FxEmailMacOSEvent* tmpEvent = (FxEmailMacOSEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event mDirection], [tmpEvent mDirection], @"Compare direction");
    GHAssertEqualStrings([event mUserLogonName], [tmpEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tmpEvent mApplicationID], @"Compare application id");
    GHAssertEqualStrings([event mApplicationName], [tmpEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tmpEvent mTitle], @"Compare title");
    GHAssertEquals([event mEmailServiceType], [tmpEvent mEmailServiceType], @"Compare email service type");
    GHAssertEqualStrings([event mSenderEmail], [tmpEvent mSenderEmail], @"Compare sender email");
    GHAssertEqualStrings([event mSenderName], [tmpEvent mSenderName], @"Compare sender name");
    GHAssertEqualStrings([event mBody], [tmpEvent mBody], @"Compare body");
    GHAssertEqualStrings([event mSubject], [tmpEvent mSubject], @"Compare subject");
    NSString* newUpdate = @"/hello/world/application/documents/Test/112112-thumbnail.bmp"
    "GDB is free software, covered by the GNU General Public License, and you are";
    [tmpEvent setMBody:newUpdate];
    [tmpEvent setMEmailServiceType:kEmailServiceTypeAOL];
    [dao updateEvent:tmpEvent];
    tmpEvent = (FxEmailMacOSEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tmpEvent dateTime], @"Compare date time");
    GHAssertEquals([event mDirection], [tmpEvent mDirection], @"Compare direction");
    GHAssertEqualStrings([event mUserLogonName], [tmpEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tmpEvent mApplicationID], @"Compare application id");
    GHAssertEqualStrings([event mApplicationName], [tmpEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tmpEvent mTitle], @"Compare title");
    GHAssertEquals(kEmailServiceTypeAOL, [tmpEvent mEmailServiceType], @"Compare email service type");
    GHAssertEqualStrings([event mSenderEmail], [tmpEvent mSenderEmail], @"Compare sender email");
    GHAssertEqualStrings([event mSenderName], [tmpEvent mSenderName], @"Compare sender name");
    GHAssertEqualStrings(newUpdate, [tmpEvent mBody], @"Compare body");
    GHAssertEqualStrings([event mSubject], [tmpEvent mSubject], @"Compare subject");
    
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
