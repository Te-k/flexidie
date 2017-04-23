//
//  TestFileTransferDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxFileTransferEvent.h"
#import "FileTransferDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestFileTransferDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestFileTransferDAO

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
    FxFileTransferEvent* event = [[FxFileTransferEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mDirection = kEventDirectionIn;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mTransferType = kFileTransferTypeUSB;
    event.mSourcePath = @"/Volumes/disk1/file.txt";
    event.mDestinationPath = @"/Users/makara/Desktop/file.txt";
    event.mFileName = @"file.txt";
    event.mFileSize = 40000;
    
    FileTransferDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    GHAssertEquals([detailedCount inCount], 1, @"Count incoming event after insert passed");
    GHAssertEquals([detailedCount outCount], 0, @"Count outgoing event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxFileTransferEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event mDirection], [event1 mDirection], @"Compare direction");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([event mApplicationName], [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEquals([event mTransferType], [event1 mTransferType], @"Compare transfer type");
        GHAssertEqualStrings([event mSourcePath], [event1 mSourcePath], @"Compare source path");
        GHAssertEqualStrings([event mDestinationPath], [event1 mDestinationPath], @"Compare destination path");
        GHAssertEqualStrings([event mFileName], [event1 mFileName], @"Compare file name");
        GHAssertEquals([event mFileSize], [event1 mFileSize], @"Compare file size");
        
        GHAssertEquals(lastEventId, 1, @"Compare lastEventId with 1");
    }
    FxFileTransferEvent* tempEvent = (FxFileTransferEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEquals([event mDirection], [tempEvent mDirection], @"Compare direction");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals([event mTransferType], [tempEvent mTransferType], @"Compare transfer type");
    GHAssertEqualStrings([event mSourcePath], [tempEvent mSourcePath], @"Compare source path");
    GHAssertEqualStrings([event mDestinationPath], [tempEvent mDestinationPath], @"Compare destination path");
    GHAssertEqualStrings([event mFileName], [tempEvent mFileName], @"Compare file name");
    GHAssertEquals([event mFileSize], [tempEvent mFileSize], @"Compare file size");
    
    NSString *newSourcePath = @"/Volumes/disk0/customers.xls";
    NSString *newDestinationPath = @"/Users/makara/Desktop/customers.xls";
    [tempEvent setMSourcePath:newSourcePath];
    [tempEvent setMDestinationPath:newDestinationPath];
    [dao updateEvent:tempEvent];
    tempEvent = (FxFileTransferEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEquals([event mDirection], [tempEvent mDirection], @"Compare direction");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals([event mTransferType], [tempEvent mTransferType], @"Compare transfer type");
    GHAssertEqualStrings(newSourcePath, [tempEvent mSourcePath], @"Compare source path");
    GHAssertEqualStrings(newDestinationPath, [tempEvent mDestinationPath], @"Compare destination path");
    GHAssertEqualStrings([event mFileName], [tempEvent mFileName], @"Compare file name");
    GHAssertEquals([event mFileSize], [tempEvent mFileSize], @"Compare file size");
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    GHAssertEquals([detailedCount outCount], 0, @"Count outgoing event after delete passed");
    
    [event release];
}

- (void) testStressTest {
    FileTransferDAO* dao = [DAOFactory dataAccessObject:kEventTypeFileTransfer withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxFileTransferEvent* event = [[FxFileTransferEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mDirection = kEventDirectionIn;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mTransferType = kFileTransferTypeUSB;
    event.mSourcePath = @"/Volumes/disk1/file.txt";
    event.mDestinationPath = @"/Users/makara/Desktop/file.txt";
    event.mFileName = @"file.txt";
    event.mFileSize = 40000;
    
    NSInteger maxEventTest = 1000;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        event.mApplicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        if (i % 2 == 0) {
            event.mDirection = kEventDirectionIn;
        } else {
            event.mDirection = kEventDirectionOut;
        }
        [dao insertEvent:event];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    GHAssertEquals([detailedCount inCount], maxEventTest/2, @"Count incoming event after insert passed");
    GHAssertEquals([detailedCount outCount], maxEventTest/2, @"Count outgoing event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxFileTransferEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *applicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        if (i % 2 == 0) {
            GHAssertEquals(kEventDirectionIn, [event1 mDirection], @"Compare direction");
        } else {
            GHAssertEquals(kEventDirectionOut, [event1 mDirection], @"Compare direction");
        }
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings(applicationName, [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEquals([event mTransferType], [event1 mTransferType], @"Compare transfer type");
        GHAssertEqualStrings([event mSourcePath], [event1 mSourcePath], @"Compare source path");
        GHAssertEqualStrings([event mDestinationPath], [event1 mDestinationPath], @"Compare destination path");
        GHAssertEqualStrings([event mFileName], [event1 mFileName], @"Compare file name");
        GHAssertEquals([event mFileSize], [event1 mFileSize], @"Compare file size");
        i++;
    }
    FxFileTransferEvent* tempEvent = (FxFileTransferEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    if (--i % 2 == 0) {
        GHAssertEquals(kEventDirectionIn, [tempEvent mDirection], @"Compare direction");
    } else {
        GHAssertEquals(kEventDirectionOut, [tempEvent mDirection], @"Compare direction");
    }
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals([event mTransferType], [tempEvent mTransferType], @"Compare transfer type");
    GHAssertEqualStrings([event mSourcePath], [tempEvent mSourcePath], @"Compare source path");
    GHAssertEqualStrings([event mDestinationPath], [tempEvent mDestinationPath], @"Compare destination path");
    GHAssertEqualStrings([event mFileName], [tempEvent mFileName], @"Compare file name");
    GHAssertEquals([event mFileSize], [tempEvent mFileSize], @"Compare file size");
    
    NSString *newSourcePath = @"/Volumes/disk0/customers.xls";
    NSString *newDestinationPath = @"/Users/makara/Desktop/customers.xls";
    [tempEvent setMSourcePath:newSourcePath];
    [tempEvent setMDestinationPath:newDestinationPath];
    [dao updateEvent:tempEvent];
    tempEvent = (FxFileTransferEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEquals([event mDirection], [tempEvent mDirection], @"Compare direction");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals([event mTransferType], [tempEvent mTransferType], @"Compare transfer type");
    GHAssertEqualStrings(newSourcePath, [tempEvent mSourcePath], @"Compare source path");
    GHAssertEqualStrings(newDestinationPath, [tempEvent mDestinationPath], @"Compare destination path");
    GHAssertEqualStrings([event mFileName], [tempEvent mFileName], @"Compare file name");
    GHAssertEquals([event mFileSize], [tempEvent mFileSize], @"Compare file size");
    for (NSNumber* number in eventIdArray) {
        [dao deleteEvent:[number intValue]];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    GHAssertEquals([detailedCount inCount], 0, @"Count incoming event after delete passed");
    GHAssertEquals([detailedCount outCount], 0, @"Count outgoing event after delete passed");
    [eventIdArray release];
    [event release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
