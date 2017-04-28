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
#import "VoIPCallTagDAO.h"
#import "GPSTagDAO.h"
#import "EmailDAO.h"
#import "RecipientDAO.h"
#import "AttachmentDAO.h"
#import "EventBaseDAO.h"
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
#import "AppScreenShotDAO.h"
#import "PageVisitedDAO.h"

#import "DetailedCount.h"
#import "FxRecipient.h"
#import "FxRecipientWrapper.h"
#import "FxAttachment.h"
#import "FxAttachmentWrapper.h"
#import "EventBaseWrapper.h"
#import "FxBookmarkWrapper.h"

#import "FxCallLogEvent.h"
#import "FxEmailEvent.h"
#import "FxCallTag.h"
#import "FxVoIPCallTag.h"
#import "FxGPSTag.h"
#import "FxLocationEvent.h"
#import "FxMediaEvent.h"
#import "FxThumbnailEvent.h"
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
#import "FxAppScreenShotEvent.h"
#import "FxPageVisitedEvent.h"

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
    [dbSchema dropTable:kEventTypeAppScreenShot];
    [dbSchema dropTable:kEventTypePageVisited];
    
    // To test table schema after drop test case above, just simply copy and past here every normal test case in each DAO test cases
    // @"11:11:11 2015-11-11"
    
    {
        FxPageVisitedEvent* event = [[FxPageVisitedEvent alloc] init];
        event.dateTime = @"11:11:11 2015-11-11";
        event.mUserName = @"Ophat";
        event.mApplicationID = @"com.kbak.kmobile";
        event.mApplication = @"KBank Mobile";
        event.mTitle = @"iTune Connect";
        event.mActualDisplayData = @"";
        event.mRawData = @"";
        event.mUrl = @"";
        event.mBrowserScreenshotPath = @"/var/mobile/safari.png";
        event.mBrowsingStartTime = @"11:11:11 2015-11-11";
        event.mBrowsingEndTime = @"11:11:11 2015-11-11";
        event.mBrowsingDuration = 0;
        
        PageVisitedDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
        [dao insertEvent:event];
        DetailedCount* detailedCount = [dao countEvent];
        GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
        
        NSInteger lastEventId = 0;
        NSArray* eventArray = [dao selectMaxEvent:33];
        for (FxPageVisitedEvent* event1 in eventArray) {
            lastEventId = [event1 eventId];
            GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
            GHAssertEqualStrings([event mUserName], [event1 mUserName], @"Compare user logon name");
            GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
            GHAssertEqualStrings([event mApplication], [event1 mApplication], @"Compare application name");
            GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
            GHAssertEqualStrings([event mActualDisplayData], [event1 mActualDisplayData], @"Compare display data");
            GHAssertEqualStrings([event mRawData], [event1 mRawData], @"Compare raw data");
            GHAssertEqualStrings([event mUrl], [event1 mUrl], @"Compare url");
            GHAssertEqualStrings([event mBrowserScreenshotPath], [event1 mBrowserScreenshotPath], @"Compare browser screenshot path");
            GHAssertEqualStrings([event mBrowsingStartTime], [event1 mBrowsingStartTime], @"Compare browsing start time");
            GHAssertEqualStrings([event mBrowsingEndTime], [event1 mBrowsingEndTime], @"Compare browsing end time");
            GHAssertEquals([event mBrowsingDuration], [event1 mBrowsingDuration], @"Compare browsing duration");
            
            GHAssertEquals(lastEventId, 1, @"Compare lastEventId with 1");
        }
        
        FxPageVisitedEvent* tempEvent = (FxPageVisitedEvent *)[dao selectEvent:lastEventId];
        
        GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserName], [tempEvent mUserName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([event mApplication], [tempEvent mApplication], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
        GHAssertEqualStrings([event mActualDisplayData], [tempEvent mActualDisplayData], @"Compare display data");
        GHAssertEqualStrings([event mRawData], [tempEvent mRawData], @"Compare raw data");
        GHAssertEqualStrings([event mUrl], [tempEvent mUrl], @"Compare url");
        GHAssertEqualStrings([event mBrowserScreenshotPath], [tempEvent mBrowserScreenshotPath], @"Compare browser screenshot path");
        GHAssertEqualStrings([event mBrowsingStartTime], [tempEvent mBrowsingStartTime], @"Compare browsing start time");
        GHAssertEqualStrings([event mBrowsingEndTime], [tempEvent mBrowsingEndTime], @"Compare browsing end time");
        GHAssertEquals([event mBrowsingDuration], [tempEvent mBrowsingDuration], @"Compare browsing duration");
        
        NSString *newApplicationID = @"com.scb.mobilescb";
        NSString *newApplicationName = @"SCB Mobile Banking";
        [tempEvent setMApplicationID:newApplicationID];
        [tempEvent setMApplication:newApplicationName];
        [tempEvent setMTitle:@"/User/Desktop/2015-02-03 14:20:11.jpg"];
        [tempEvent setMUrl:@"https://portal.vervata.com/projects/mobileproducts/Phoenix%20Protocol%20Specs/Phoenix%20Protocol%208/Structured%20Commands/Application%20Category.aspx"];
        [tempEvent setMBrowsingDuration:7];
        [dao updateEvent:tempEvent];
        tempEvent = (FxPageVisitedEvent *)[dao selectEvent:lastEventId];
        GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserName], [tempEvent mUserName], @"Compare user logon name");
        GHAssertEqualStrings(newApplicationID, [tempEvent mApplicationID], @"Compare application ID");
        GHAssertEqualStrings(newApplicationName, [tempEvent mApplication], @"Compare application name");
        GHAssertEqualStrings(@"/User/Desktop/2015-02-03 14:20:11.jpg", [tempEvent mTitle], @"Compare title");
        GHAssertEqualStrings([event mActualDisplayData], [tempEvent mActualDisplayData], @"Compare display data");
        GHAssertEqualStrings([event mRawData], [tempEvent mRawData], @"Compare raw data");
        GHAssertEqualStrings(@"https://portal.vervata.com/projects/mobileproducts/Phoenix%20Protocol%20Specs/Phoenix%20Protocol%208/Structured%20Commands/Application%20Category.aspx", [tempEvent mUrl], @"Compare url");
        GHAssertEqualStrings([event mBrowserScreenshotPath], [tempEvent mBrowserScreenshotPath], @"Compare browser screenshot path");
        GHAssertEqualStrings([event mBrowsingStartTime], [tempEvent mBrowsingStartTime], @"Compare browsing start time");
        GHAssertEqualStrings([event mBrowsingEndTime], [tempEvent mBrowsingEndTime], @"Compare browsing end time");
        GHAssertEquals((NSUInteger)7, [tempEvent mBrowsingDuration], @"Compare browsing duration");
        [dao deleteEvent:lastEventId];
        detailedCount = [dao countEvent];
        GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
        
        [event release];
    }
    
    [mDatabaseManager release];
}

@end
