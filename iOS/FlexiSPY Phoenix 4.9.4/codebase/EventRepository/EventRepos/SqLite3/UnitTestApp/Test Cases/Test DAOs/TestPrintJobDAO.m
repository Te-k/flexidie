//
//  TestPrintJobDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 11/16/15.
//
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxPrintJobEvent.h"
#import "PrintJobDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestPrintJobDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestPrintJobDAO

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
    FxPrintJobEvent* event = [[FxPrintJobEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mJobID = @"123294";
    event.mOwnerName = @"Makara";
    event.mPrinter = @"HP Laser Jet";
    event.mDocumentName = @"SpyCall.m";
    event.mSubmitTime = kEventDateTime;
    event.mTotalPage = 1;
    event.mTotalByte = 10000;
    event.mPathToData = @"/Users/makara/Desktop/SpyCall.m";
    
    PrintJobDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxPrintJobEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([event mApplicationName], [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEqualStrings([event mJobID], [event1 mJobID], @"Compare job id");
        GHAssertEqualStrings([event mOwnerName], [event1 mOwnerName], @"Compare ower name");
        GHAssertEqualStrings([event mPrinter], [event1 mPrinter], @"Compare printer name");
        GHAssertEqualStrings([event mDocumentName], [event1 mDocumentName], @"Compare document name");
        GHAssertEqualStrings([event mSubmitTime], [event1 mSubmitTime], @"Compare submit time");
        GHAssertEquals([event mTotalPage], [event1 mTotalPage], @"Compare total page");
        GHAssertEquals([event mTotalByte], [event1 mTotalByte], @"Compare total byte");
        GHAssertEqualStrings([event mPathToData], [event1 mPathToData], @"Compare path to data");
        
        GHAssertEquals(lastEventId, 1, @"Compare lastEventId with 1");
    }
    
    FxPrintJobEvent* tempEvent = (FxPrintJobEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mJobID], [tempEvent mJobID], @"Compare job id");
    GHAssertEqualStrings([event mOwnerName], [tempEvent mOwnerName], @"Compare ower name");
    GHAssertEqualStrings([event mPrinter], [tempEvent mPrinter], @"Compare printer name");
    GHAssertEqualStrings([event mDocumentName], [tempEvent mDocumentName], @"Compare document name");
    GHAssertEqualStrings([event mSubmitTime], [tempEvent mSubmitTime], @"Compare submit time");
    GHAssertEquals([event mTotalPage], [tempEvent mTotalPage], @"Compare total page");
    GHAssertEquals([event mTotalByte], [tempEvent mTotalByte], @"Compare total byte");
    GHAssertEqualStrings([event mPathToData], [tempEvent mPathToData], @"Compare path to data");
    
    NSString *newApplicationID = @"com.scb.mobilescb";
    NSString *newApplicationName = @"SCB Mobile Banking";
    [tempEvent setMApplicationID:newApplicationID];
    [tempEvent setMApplicationName:newApplicationName];
    [dao updateEvent:tempEvent];
    tempEvent = (FxPrintJobEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings(newApplicationID, [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mJobID], [tempEvent mJobID], @"Compare job id");
    GHAssertEqualStrings([event mOwnerName], [tempEvent mOwnerName], @"Compare ower name");
    GHAssertEqualStrings([event mPrinter], [tempEvent mPrinter], @"Compare printer name");
    GHAssertEqualStrings([event mDocumentName], [tempEvent mDocumentName], @"Compare document name");
    GHAssertEqualStrings([event mSubmitTime], [tempEvent mSubmitTime], @"Compare submit time");
    GHAssertEquals([event mTotalPage], [tempEvent mTotalPage], @"Compare total page");
    GHAssertEquals([event mTotalByte], [tempEvent mTotalByte], @"Compare total byte");
    GHAssertEqualStrings([event mPathToData], [tempEvent mPathToData], @"Compare path to data");
    
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [event release];
}

- (void) testStressTest {
    PrintJobDAO* dao = [DAOFactory dataAccessObject:kEventTypePrintJob withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxPrintJobEvent* event = [[FxPrintJobEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mJobID = @"123294";
    event.mOwnerName = @"Makara";
    event.mPrinter = @"HP Laser Jet";
    event.mDocumentName = @"SpyCall.m";
    event.mSubmitTime = kEventDateTime;
    event.mTotalPage = 1;
    event.mTotalByte = 10000;
    event.mPathToData = @"/Users/makara/Desktop/SpyCall.m";
    
    NSInteger maxEventTest = 1000;
    NSInteger j;
    for (j = 0; j < maxEventTest; j++) {
        event.mApplicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", j];
        if (j % 2 == 0) {
            event.mTotalByte = 10001;
        } else {
            event.mTotalByte = 10002;
        }
        [dao insertEvent:event];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    j = 0;
    for (FxPrintJobEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *applicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", j];
        
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings(applicationName, [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEqualStrings([event mJobID], [event1 mJobID], @"Compare job id");
        GHAssertEqualStrings([event mOwnerName], [event1 mOwnerName], @"Compare ower name");
        GHAssertEqualStrings([event mPrinter], [event1 mPrinter], @"Compare printer name");
        GHAssertEqualStrings([event mDocumentName], [event1 mDocumentName], @"Compare document name");
        GHAssertEqualStrings([event mSubmitTime], [event1 mSubmitTime], @"Compare submit time");
        GHAssertEquals([event mTotalPage], [event1 mTotalPage], @"Compare total page");
        if (j % 2 == 0) {
            GHAssertEquals(10001, (int)[event1 mTotalByte], @"Compare total byte");
        } else {
            GHAssertEquals(10002, (int)[event1 mTotalByte], @"Compare total byte");
        }
        GHAssertEqualStrings([event mPathToData], [event1 mPathToData], @"Compare path to data");
        
        j++;
    }
    
    FxPrintJobEvent* tempEvent = (FxPrintJobEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mJobID], [tempEvent mJobID], @"Compare job id");
    GHAssertEqualStrings([event mOwnerName], [tempEvent mOwnerName], @"Compare ower name");
    GHAssertEqualStrings([event mPrinter], [tempEvent mPrinter], @"Compare printer name");
    GHAssertEqualStrings([event mDocumentName], [tempEvent mDocumentName], @"Compare document name");
    GHAssertEqualStrings([event mSubmitTime], [tempEvent mSubmitTime], @"Compare submit time");
    GHAssertEquals([event mTotalPage], [tempEvent mTotalPage], @"Compare total page");
    GHAssertEquals([event mTotalByte], [tempEvent mTotalByte], @"Compare total byte");
    GHAssertEqualStrings([event mPathToData], [tempEvent mPathToData], @"Compare path to data");
    
    NSString *newApplicationName = @"KBank Express";
    [tempEvent setMApplicationName:newApplicationName];
    [dao updateEvent:tempEvent];
    tempEvent = (FxPrintJobEvent *)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mJobID], [tempEvent mJobID], @"Compare job id");
    GHAssertEqualStrings([event mOwnerName], [tempEvent mOwnerName], @"Compare ower name");
    GHAssertEqualStrings([event mPrinter], [tempEvent mPrinter], @"Compare printer name");
    GHAssertEqualStrings([event mDocumentName], [tempEvent mDocumentName], @"Compare document name");
    GHAssertEqualStrings([event mSubmitTime], [tempEvent mSubmitTime], @"Compare submit time");
    GHAssertEquals([event mTotalPage], [tempEvent mTotalPage], @"Compare total page");
    GHAssertEquals([event mTotalByte], [tempEvent mTotalByte], @"Compare total byte");
    GHAssertEqualStrings([event mPathToData], [tempEvent mPathToData], @"Compare path to data");
    
    for (NSNumber* number in eventIdArray) {
        [dao deleteEvent:[number intValue]];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    [eventIdArray release];
    [event release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
