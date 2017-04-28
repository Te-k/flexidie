//
//  TestMediaDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "MediaDAO.h"
#import "ThumbnailDAO.h"
#import "CallTagDAO.h"
#import "VoIPCallTagDAO.h"
#import "GPSTagDAO.h"

#import "FxMediaEvent.h"
#import "FxThumbnailEvent.h"
#import "FxCallTag.h"
#import "FxVoIPCallTag.h"
#import "FxGPSTag.h"
#import "FxRecipient.h"

NSString* const kEventDateTime4  = @"11:11:11 2011-11-11";

@interface TestMediaDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestMediaDAO

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
    FxMediaEvent* event = [[FxMediaEvent alloc] init];
    event.dateTime = kEventDateTime4;
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

- (void) testStressTest {
    FxMediaEvent* event = [[FxMediaEvent alloc] init];
    event.dateTime = kEventDateTime4;
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
    
    // Any thumbnail use the same DAO so just hard code 'kEventTypeCameraImageThumbnail' here
    ThumbnailDAO* thDAO = [DAOFactory dataAccessObject:kEventTypeCameraImageThumbnail withSqlite3:[mDatabaseManager sqlite3db]];
    
    GPSTagDAO* gpsTagDAO = [[GPSTagDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    
    CallTagDAO* callTagDAO = [[CallTagDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    
    VoIPCallTagDAO *voipCallTagDAO = [[[VoIPCallTagDAO alloc] initWithSqlite3:mDatabaseManager.sqlite3db] autorelease];
    
    NSInteger maxInsertRow = 100;
    NSInteger i;
    for (i = 0; i < maxInsertRow; i++) {
        // Insert media
        [event setFullPath:[NSString stringWithFormat:@"/Users/Makara/Projects/test/heroine_%d.png", i]];
        [dao insertEvent:event];
        NSInteger mediaDBId = [mDatabaseManager lastInsertRowId];
        
        // Insert thumbnail
        for (thumbnail in [event thumbnailEvents]) {
            [thumbnail setPairId:mediaDBId];
            [thumbnail setActualDuration:i];
            [thDAO insertEvent:thumbnail];
        }
        
        // Insert gps tag
        gpsTag = [event mGPSTag];
        [gpsTag setDbId:mediaDBId];
        [gpsTag setCellId:i];
        [gpsTagDAO insertRow:gpsTag];
        
        // Insert call tag
        callTag = [event mCallTag];
        [callTag setDbId:mediaDBId];
        [callTag setDuration:i];
        [callTagDAO insertRow:callTag];
        
        // Insert voip call tag
        event.mVoIPCallTag.dbId = mediaDBId;
        event.mVoIPCallTag.duration = i;
        [voipCallTagDAO insertRow:event.mVoIPCallTag];
    }
    
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxInsertRow, @"Count media event after insert passed");
    
    detailedCount = [thDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxInsertRow, @"Count thumbnail event after insert passed");
    
    GHAssertEquals([gpsTagDAO countRow], maxInsertRow, @"Count gps tag after insert passed");
    GHAssertEquals([callTagDAO countRow], maxInsertRow, @"Count call tag after insert passed");
    GHAssertEquals([voipCallTagDAO countRow], maxInsertRow, @"Count voip call tag after insert passed");
    
    NSInteger lastEventId = 0;
    NSUInteger j = 0;
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    NSArray* eventArray = [dao selectMaxEvent:maxInsertRow];
    for (FxMediaEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event eventType], [event1 eventType], @"Compare media type");
        GHAssertEquals([event mDuration], [event1 mDuration], @"Compare duration");
        NSString* tmp = [NSString stringWithFormat:@"/Users/Makara/Projects/test/heroine_%d.png", j];
        GHAssertEqualStrings(tmp, [event1 fullPath], @"Compare media full path");
        
        thumbnail = (FxThumbnailEvent*)[thDAO selectEvent:[event1 eventId]];
        FxThumbnailEvent* tempThumb = [[event thumbnailEvents] objectAtIndex:0];
        GHAssertEqualStrings([thumbnail fullPath], [tempThumb fullPath], @"Compare thumbnail full path");
        GHAssertEquals([thumbnail actualSize], [tempThumb actualSize], @"Compare thumbnail actual size");
        GHAssertEquals([thumbnail actualDuration], j, @"Compare thumbnail actual duration");
        
        NSUInteger indexThumbnail = 0;
        for (FxThumbnailEvent* thumb1 in [event1 thumbnailEvents]) {
            FxThumbnailEvent* thumb2 = [[event thumbnailEvents] objectAtIndex:indexThumbnail];
            GHAssertEqualStrings([thumbnail fullPath], [thumb2 fullPath], @"Compare thumbnail full path");
            GHAssertEquals([thumbnail actualSize], [thumb2 actualSize], @"Compare thumbnail actual size");
            GHAssertEquals([thumbnail actualDuration], indexThumbnail, @"Compare thumbnail actual duration");
            indexThumbnail++;
        }
        j++;
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
    GHAssertEquals([detailedCount totalCount], maxInsertRow - 1, @"Count media event after update passed"); // Because of update the delivered flag in above 
    
    detailedCount = [thDAO countEvent]; // Delete by trigger
    GHAssertEquals([detailedCount totalCount], maxInsertRow - 1, @"Count thumbnail event after update passed");
    
    GHAssertEquals([gpsTagDAO countRow], maxInsertRow, @"Count gps tag after update passed");
    GHAssertEquals([callTagDAO countRow], maxInsertRow, @"Count call tag after update passed");
    GHAssertEquals([voipCallTagDAO countRow], maxInsertRow, @"Count voip call tag after update passed");
    
    // Test trigger too
    [dao updateMediaEvent:lastEventId];
    detailedCount = [thDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxInsertRow - 1, @"Count thumbnail event after update passed");
    
    for (NSNumber* eventId in eventIdArray) {
        [dao updateMediaEvent:[eventId intValue]];
        [dao deleteEvent:[eventId intValue]];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    detailedCount = [thDAO countEvent]; // Delete by trigger
    GHAssertEquals([detailedCount totalCount], 0, @"Count thumbnail event after update passed");
    
    
    GHAssertEquals([gpsTagDAO countRow], 0, @"Count gps tag after delete passed");
    GHAssertEquals([callTagDAO countRow], 0, @"Count call tag after delete passed");
    GHAssertEquals([voipCallTagDAO countRow], 0, @"Count voip call tag after delete passed");
    
    [eventIdArray release];
    [gpsTagDAO release];
    [callTagDAO release];
    [event release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
