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
    
    // To test table schema after drop test case above, just simply copy and past here every normal test case in each DAO test cases
    // @"11:11:11 2015-11-11"
    
    {
        FxMediaEvent* event = [[FxMediaEvent alloc] init];
        event.dateTime = @"11:11:11 2015-11-11";
        [event setFullPath:@"/Users/Makara/Projects/test/heroine.png"];
        [event setEventType:kEventTypeCameraImage];
        [event setMDuration:20];
        MediaDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
        
        FxThumbnailEvent* thumbnail = [[FxThumbnailEvent alloc] init];
        [thumbnail setActualSize:20008];
        [thumbnail setActualDuration:0];
        [thumbnail setFullPath:@"/Applications/UnitestApp/private/thumbnails/heroine-thumb.jpg"];
        
        [event addThumbnailEvent:thumbnail];
        [thumbnail release];
        
        FxGPSTag* gpsTag = [[FxGPSTag alloc] init];
        [gpsTag setLatitude:93.087760];
        [gpsTag setLongitude:923.836398];
        [gpsTag setAltitude:62.98];
        [gpsTag setCellId:345];
        [gpsTag setAreaCode:@"342"];
        [gpsTag setNetworkId:@"45"];
        [gpsTag setCountryCode:@"512"];
        
        [event setMGPSTag:gpsTag];
        [gpsTag release];
        
        FxCallTag* callTag = [[FxCallTag alloc] init];
        [callTag setDirection:(FxEventDirection)kEventDirectionOut];
        [callTag setDuration:23];
        [callTag setContactNumber:@"0873246246823"];
        [callTag setContactName:@"R. Mr'cm ""CamKh"];
        
        [event setMCallTag:callTag];
        [callTag release];
        
        FxVoIPCallTag *voipCallTag = [[[FxVoIPCallTag alloc] init] autorelease];
        voipCallTag.direction = kEventDirectionIn;
        voipCallTag.duration = 45;
        voipCallTag.ownerNumberAddr = @"iphonedev22@gmail.com";
        voipCallTag.ownerName = @"Dev 22";
        voipCallTag.category = kVoIPCategoryWhatsApp;
        voipCallTag.isMonitor = kFxVoIPMonitorNO;
        
        NSMutableArray *recipients = [NSMutableArray array];
        FxRecipient *recipient1 = [[[FxRecipient alloc] init] autorelease];
        recipient1.recipNumAddr = @"0860843742";
        recipient1.recipContactName = @"Makara Khloth";
        recipient1.recipType = kFxRecipientTO;
        recipient1.mStatusMessage = @"I love my son";
        recipient1.mPicture = [@"HelloWorld" dataUsingEncoding:NSUTF8StringEncoding];
        [recipients addObject:recipient1];
        
        FxRecipient *recipient2 = [[[FxRecipient alloc] init] autorelease];
        recipient2.recipNumAddr = @"+85515706886";
        recipient2.recipContactName = @"Piseth Khloth";
        recipient2.recipType = kFxRecipientCC;
        [recipients addObject:recipient2];
        
        voipCallTag.recipients = recipients;
        
        event.mVoIPCallTag = voipCallTag;
        
        // Insert media
        [dao insertEvent:event];
        
        // Any thumbnail use the same DAO so just hard code 'kEventTypeCameraImageThumbnail' here
        ThumbnailDAO* thDAO = [DAOFactory dataAccessObject:kEventTypeCameraImageThumbnail withSqlite3:[mDatabaseManager sqlite3db]];
        
        NSInteger mediaDBId = [mDatabaseManager lastInsertRowId];
        
        // Insert thumbnail
        for (thumbnail in [event thumbnailEvents]) {
            [thumbnail setPairId:mediaDBId];
            [thDAO insertEvent:thumbnail];
        }
        
        // Insert gps tag
        GPSTagDAO* gpsTagDAO = [[GPSTagDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
        gpsTag = [event mGPSTag];
        [gpsTag setDbId:mediaDBId];
        [gpsTagDAO insertRow:gpsTag];
        
        // Insert call tag
        CallTagDAO* callTagDAO = [[CallTagDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
        callTag = [event mCallTag];
        [callTag setDbId:mediaDBId];
        [callTagDAO insertRow:callTag];
        
        // Insert voip call tag
        VoIPCallTagDAO *voipCallTagDAO = [[[VoIPCallTagDAO alloc] initWithSqlite3:mDatabaseManager.sqlite3db] autorelease];
        event.mVoIPCallTag.dbId = mediaDBId;
        [voipCallTagDAO insertRow:event.mVoIPCallTag];
        
        DetailedCount* detailedCount = [dao countEvent];
        GHAssertEquals([detailedCount totalCount], 1, @"Count media event after insert passed");
        
        detailedCount = [thDAO countEvent];
        GHAssertEquals([detailedCount totalCount], 1, @"Count thumbnail event after insert passed");
        
        GHAssertEquals([gpsTagDAO countRow], 1, @"Count gps tag after insert passed");
        GHAssertEquals([callTagDAO countRow], 1, @"Count call tag after insert passed");
        GHAssertEquals([voipCallTagDAO countRow], 1, @"Count voip call tag after insert passed");
        
        NSInteger lastEventId = 0;
        NSArray* eventArray = [dao selectMaxEvent:33];
        for (FxMediaEvent* event1 in eventArray) {
            lastEventId = [event1 eventId];
            GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
            GHAssertEquals([event eventType], [event1 eventType], @"Compare media type");
            GHAssertEqualStrings([event fullPath], [event1 fullPath], @"Compare media full path");
            GHAssertEquals([event mDuration], [event1 mDuration], @"Compare duration");
            
            thumbnail = (FxThumbnailEvent*)[thDAO selectEvent:[event1 eventId]];
            FxThumbnailEvent* tempThumb = [[event thumbnailEvents] objectAtIndex:0];
            GHAssertEqualStrings([thumbnail fullPath], [tempThumb fullPath], @"Compare thumbnail full path");
            GHAssertEquals([thumbnail actualSize], [tempThumb actualSize], @"Compare thumbnail actual size");
            GHAssertEquals([thumbnail actualDuration], [tempThumb actualDuration], @"Compare thumbnail actual duration");
            
            NSInteger indexThumbnail = 0;
            for (FxThumbnailEvent* thumb1 in [event thumbnailEvents]) {
                FxThumbnailEvent* thumb2 = [[event thumbnailEvents] objectAtIndex:indexThumbnail];
                GHAssertEqualStrings([thumbnail fullPath], [thumb2 fullPath], @"Compare thumbnail full path");
                GHAssertEquals([thumbnail actualSize], [thumb2 actualSize], @"Compare thumbnail actual size");
                GHAssertEquals([thumbnail actualDuration], [thumb2 actualDuration], @"Compare thumbnail actual duration");
                indexThumbnail++;
            }
        }
        
        FxMediaEvent* tempEvent = (FxMediaEvent*)[dao selectEvent:lastEventId];
        
        GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
        GHAssertEquals([event eventType], [tempEvent eventType], @"Compare media type");
        GHAssertEqualStrings([event fullPath], [tempEvent fullPath], @"Compare media full path");
        GHAssertEquals([event mDuration], [tempEvent mDuration], @"Compare duration");
        NSString* newUpdate = @"12:12:12 2012-12-12";
        [tempEvent setDateTime:newUpdate];
        [dao updateEvent:tempEvent];
        tempEvent = (FxMediaEvent*)[dao selectEvent:lastEventId];
        GHAssertEqualStrings(newUpdate, [tempEvent dateTime], @"Compare date time");
        GHAssertEquals([event eventType], [tempEvent eventType], @"Compare media type");
        GHAssertEqualStrings([event fullPath], [tempEvent fullPath], @"Compare full path");
        GHAssertEquals([event mDuration], [tempEvent mDuration], @"Compare duration");
        
        detailedCount = [dao countEvent];
        GHAssertEquals([detailedCount totalCount], 0, @"Count media event after update passed"); // Because of update the delivered flag in above statements
        
        detailedCount = [thDAO countEvent]; // Delete by trigger
        GHAssertEquals([detailedCount totalCount], 0, @"Count thumbnail event after update passed");
        
        GHAssertEquals([gpsTagDAO countRow], 1, @"Count gps tag after update passed");
        GHAssertEquals([callTagDAO countRow], 1, @"Count call tag after update passed");
        GHAssertEquals([voipCallTagDAO countRow], 1, @"Count voip call tag after update passed");
        
        // Test trigger too
        [dao updateMediaEvent:lastEventId];
        detailedCount = [thDAO countEvent];
        GHAssertEquals([detailedCount totalCount], 0, @"Count thumbnail event after update passed");
        
        [dao deleteEvent:lastEventId];
        detailedCount = [dao countEvent];
        GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
        
        
        GHAssertEquals([gpsTagDAO countRow], 0, @"Count gps tag after delete passed");
        GHAssertEquals([callTagDAO countRow], 0, @"Count call tag after delete passed");
        GHAssertEquals([voipCallTagDAO countRow], 0, @"Count voip call tag after delete passed");
        
        [gpsTagDAO release];
        [callTagDAO release];
        [event release];
    }
    
    [mDatabaseManager release];
}

@end
