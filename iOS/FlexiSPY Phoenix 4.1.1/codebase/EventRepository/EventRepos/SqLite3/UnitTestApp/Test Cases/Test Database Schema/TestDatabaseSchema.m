//
//  TestDatabaseSchema.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

#import "DatabaseManager.h"
#import "DatabaseSchema.h"

#import "DAOFactory.h"
#import "CallLogDAO.h"
#import "CallTagDAO.h"
#import "EmailDAO.h"
#import "RecipientDAO.h"
#import "AttachmentDAO.h"
#import "EventBaseDAO.h"
#import "GPSTagDAO.h"
#import "LocationDAO.h"
#import "MediaDAO.h"
#import "ThumbnailDAO.h"
#import "MMSDAO.h"
#import "PanicDAO.h"
#import "SMSDAO.h"
#import "SystemDAO.h"
#import "IMDAO.h"
#import "SettingsDAO.h"
#import "BrowserUrlDAO.h"
#import "BookmarksDAO.h"
#import "BookmarkDAO.h"
#import "ApplicationLifeCycleDAO.h"
#import "IMAccountDAO.h"
#import "IMContactDAO.h"
#import "IMConversationDAO.h"
#import "IMConversationContactDAO.h"
#import "IMMessageDAO.h"
#import "IMMessageAttachmentDAO.h"
#import "VoIPDAO.h"
#import "KeyLogDAO.h"
#import "PasswordDAO.h"
#import "AppPasswordDAO.h"
#import "UsbConnectionDAO.h"
#import "FileTransferDAO.h"
#import "LogonDAO.h"
#import "ApplicationUsageDAO.h"
#import "IMMacOSDAO.h"
#import "EmailMacOSDAO.h"
#import "ScreenshotDAO.h"
#import "FileActivityDAO.h"
#import "NetworkTrafficDAO.h"
#import "NetworkConnectionMacOSDAO.h"
#import "PrintJobDAO.h"

#import "DetailedCount.h"
#import "FxRecipient.h"
#import "FxRecipientWrapper.h"
#import "FxAttachment.h"
#import "FxAttachmentWrapper.h"
#import "EventBaseWrapper.h"
#import "FxBookmarkWrapper.h"

#import "FxCallLogEvent.h"
#import "FxCallTag.h"
#import "FxEmailEvent.h"
#import "FxGPSTag.h"
#import "FxLocationEvent.h"
#import "MediaEvent.h"
#import "ThumbnailEvent.h"
#import "FxMmsEvent.h"
#import "FxPanicEvent.h"
#import "FxSmsEvent.h"
#import "FxSystemEvent.h"
#import "FxIMEvent.h"
#import "FxSettingsEvent.h"
#import "FxBrowserUrlEvent.h"
#import "FxBookmarkEvent.h"
#import "FxApplicationLifeCycleEvent.h"
#import "FxIMAccountEvent.h"
#import "FxIMContactEvent.h"
#import "FxIMConversationEvent.h"
#import "FxIMMessageEvent.h"
#import "FxIMGeoTag.h"
#import "FxVoIPEvent.h"
#import "FxKeyLogEvent.h"
#import "FxPasswordEvent.h"
#import "FxUSBConnectionEvent.h"
#import "FxFileTransferEvent.h"
#import "FxLogonEvent.h"
#import "FxApplicationUsageEvent.h"
#import "FxIMMacOSEvent.h"
#import "FxEmailMacOSEvent.h"
#import "FxScreenshotEvent.h"
#import "FxFileActivityEvent.h"
#import "FxNetworkTrafficEvent.h"
#import "FxNetworkConnectionMacOSEvent.h"
#import "FxPrintJobEvent.h"

@interface TestDatabaseSchema : GHTestCase { }
@end

@implementation TestDatabaseSchema

- (void) testCreateDatabaseFile {
    DatabaseManager* dbManager = [[DatabaseManager alloc] init];
    [dbManager openDB];
    
    GHTestLog(@"Database path: %@", [dbManager dbFullName]);
    
    [dbManager release];
}

- (void) testDropDatabaseFile {
    DatabaseManager* dbManager = [[DatabaseManager alloc] init];
    if ([dbManager dbFullName]) {
        [dbManager dropDB];
    }
    [dbManager release];
}

- (void) testDropTable {
    DatabaseManager* mDatabaseManager = [[DatabaseManager alloc] init];
    [mDatabaseManager dropDB];
    DatabaseSchema* dbSchema = [mDatabaseManager databaseSchema];
    
    [dbSchema dropTable:kEventTypePanic];
    [dbSchema dropTable:kEventTypeCallLog];
    [dbSchema dropTable:kEventTypeSms];
    [dbSchema dropTable:kEventTypeMail];
    [dbSchema dropTable:kEventTypeVideo];
    [dbSchema dropTable:kEventTypeCameraImageThumbnail];
    [dbSchema dropTable:kEventTypeMms];
    [dbSchema dropTable:kEventTypeSystem];
    [dbSchema dropTable:kEventTypeLocation];
    [dbSchema dropTable:kEventTypeCallLog];
    [dbSchema dropTable:kEventTypeSettings];
    [dbSchema dropTable:kEventTypeIM];
    [dbSchema dropTable:kEventTypeBrowserURL];
    [dbSchema dropTable:kEventTypeBookmark];
    [dbSchema dropTable:kEventTypeApplicationLifeCycle];
    [dbSchema dropTable:kEventTypeIMMessage];
    [dbSchema dropTable:kEventTypeIMContact];
    [dbSchema dropTable:kEventTypeIMAccount];
    [dbSchema dropTable:kEventTypeIMConversation];
    [dbSchema dropTable:kEventTypeVoIP];
    [dbSchema dropTable:kEventTypeKeyLog];
    [dbSchema dropTable:kEventTypePassword];
    [dbSchema dropTable:kEventTypeUsbConnection];
    [dbSchema dropTable:kEventTypeFileTransfer];
    [dbSchema dropTable:kEventTypeLogon];
    [dbSchema dropTable:kEventTypeAppUsage];
    [dbSchema dropTable:kEventTypeIMMacOS];
    [dbSchema dropTable:kEventTypeEmailMacOS];
    [dbSchema dropTable:kEventTypeScreenRecordSnapshot];
    [dbSchema dropTable:kEventTypeFileActivity];
    [dbSchema dropTable:kEventTypeNetworkTraffic];
    [dbSchema dropTable:kEventTypeNetworkConnectionMacOS];
    [dbSchema dropTable:kEventTypePrintJob];
    
    // To test table schema after drop test case above, just simply copy and past here every normal test case in each DAO test cases
    // @"11:11:11 2015-11-11"
    
    {
        FxPrintJobEvent* event = [[FxPrintJobEvent alloc] init];
        event.dateTime = @"11:11:11 2015-11-11";
        event.mUserLogonName = @"Ophat";
        event.mApplicationID = @"com.kbak.kmobile";
        event.mApplicationName = @"KBank Mobile";
        event.mTitle = @"iTune Connect";
        event.mJobID = @"123294";
        event.mOwnerName = @"Makara";
        event.mPrinter = @"HP Laser Jet";
        event.mDocumentName = @"SpyCall.m";
        event.mSubmitTime = @"11:11:11 2015-11-11";
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
    
    [mDatabaseManager release];
}

@end
