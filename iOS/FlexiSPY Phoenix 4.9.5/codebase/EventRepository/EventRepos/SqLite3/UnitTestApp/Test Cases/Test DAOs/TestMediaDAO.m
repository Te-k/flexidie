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
#import "GPSTagDAO.h"

#import "MediaEvent.h"
#import "ThumbnailEvent.h"
#import "FxCallTag.h"
#import "FxGPSTag.h"

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
    MediaEvent* event = [[MediaEvent alloc] init];
    event.dateTime = kEventDateTime4;
    [event setFullPath:@"/Users/Makara/Projects/test/heroine.png"];
    [event setEventType:kEventTypeCameraImage];
    [event setMDuration:20];
    MediaDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    
    ThumbnailEvent* thumbnail = [[ThumbnailEvent alloc] init];
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
    
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count media event after insert passed");
    
    detailedCount = [thDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count thumbnail event after insert passed");
    
    GHAssertEquals([gpsTagDAO countRow], 1, @"Count gps tag after insert passed");
    GHAssertEquals([callTagDAO countRow], 1, @"Count call tag event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (MediaEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event eventType], [event1 eventType], @"Compare media type");
        GHAssertEqualStrings([event fullPath], [event1 fullPath], @"Compare media full path");
        GHAssertEquals([event mDuration], [event1 mDuration], @"Compare duration");
        
        thumbnail = (ThumbnailEvent*)[thDAO selectEvent:[event1 eventId]];
        ThumbnailEvent* tempThumb = [[event thumbnailEvents] objectAtIndex:0];
        GHAssertEqualStrings([thumbnail fullPath], [tempThumb fullPath], @"Compare thumbnail full path");
        GHAssertEquals([thumbnail actualSize], [tempThumb actualSize], @"Compare thumbnail actual size");
        GHAssertEquals([thumbnail actualDuration], [tempThumb actualDuration], @"Compare thumbnail actual duration");
        
        NSInteger indexThumbnail = 0;
        for (ThumbnailEvent* thumb1 in [event thumbnailEvents]) {
            ThumbnailEvent* thumb2 = [[event thumbnailEvents] objectAtIndex:indexThumbnail];
            GHAssertEqualStrings([thumbnail fullPath], [thumb2 fullPath], @"Compare thumbnail full path");
            GHAssertEquals([thumbnail actualSize], [thumb2 actualSize], @"Compare thumbnail actual size");
            GHAssertEquals([thumbnail actualDuration], [thumb2 actualDuration], @"Compare thumbnail actual duration");
            indexThumbnail++;
        }
    }
    
    MediaEvent* tempEvent = (MediaEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEquals([event eventType], [tempEvent eventType], @"Compare media type");
    GHAssertEqualStrings([event fullPath], [tempEvent fullPath], @"Compare media full path");
    GHAssertEquals([event mDuration], [tempEvent mDuration], @"Compare duration");
    NSString* newUpdate = @"12:12:12 2012-12-12";
    [tempEvent setDateTime:newUpdate];
    [dao updateEvent:tempEvent];
    tempEvent = (MediaEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings(newUpdate, [tempEvent dateTime], @"Compare date time");
    GHAssertEquals([event eventType], [tempEvent eventType], @"Compare media type");
    GHAssertEqualStrings([event fullPath], [tempEvent fullPath], @"Compare full path");
    GHAssertEquals([event mDuration], [tempEvent mDuration], @"Compare duration");
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count media event after update passed"); // Because of update the delivered flag in above statements
    
    detailedCount = [thDAO countEvent]; // Delete by trigger
    GHAssertEquals([detailedCount totalCount], 0, @"Count thumbnail event after update passed");
    
    GHAssertEquals([gpsTagDAO countRow], 1, @"Count gps tag after update passed");
    GHAssertEquals([callTagDAO countRow], 1, @"Count call tag event after update passed");
    
    // Test trigger too
    [dao updateMediaEvent:lastEventId];
    detailedCount = [thDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count thumbnail event after update passed");
    
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    
    GHAssertEquals([gpsTagDAO countRow], 0, @"Count gps tag after delete passed");
    GHAssertEquals([callTagDAO countRow], 0, @"Count call tag event after delete passed");
    
    [gpsTagDAO release];
    [callTagDAO release];
    [event release];
}

- (void) testStressTest {
    MediaEvent* event = [[MediaEvent alloc] init];
    event.dateTime = kEventDateTime4;
    [event setFullPath:@"/Users/Makara/Projects/test/heroine.png"];
    [event setEventType:kEventTypeCameraImage];
    [event setMDuration:20];
    MediaDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    
    ThumbnailEvent* thumbnail = [[ThumbnailEvent alloc] init];
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
    
    // Any thumbnail use the same DAO so just hard code 'kEventTypeCameraImageThumbnail' here
    ThumbnailDAO* thDAO = [DAOFactory dataAccessObject:kEventTypeCameraImageThumbnail withSqlite3:[mDatabaseManager sqlite3db]];
    
    GPSTagDAO* gpsTagDAO = [[GPSTagDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    
    CallTagDAO* callTagDAO = [[CallTagDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    
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
    }
    
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxInsertRow, @"Count media event after insert passed");
    
    detailedCount = [thDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxInsertRow, @"Count thumbnail event after insert passed");
    
    GHAssertEquals([gpsTagDAO countRow], maxInsertRow, @"Count gps tag after insert passed");
    GHAssertEquals([callTagDAO countRow], maxInsertRow, @"Count call tag event after insert passed");
    
    NSInteger lastEventId = 0;
    NSUInteger j = 0;
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    NSArray* eventArray = [dao selectMaxEvent:maxInsertRow];
    for (MediaEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEquals([event eventType], [event1 eventType], @"Compare media type");
        GHAssertEquals([event mDuration], [event1 mDuration], @"Compare duration");
        NSString* tmp = [NSString stringWithFormat:@"/Users/Makara/Projects/test/heroine_%d.png", j];
        GHAssertEqualStrings(tmp, [event1 fullPath], @"Compare media full path");
        
        thumbnail = (ThumbnailEvent*)[thDAO selectEvent:[event1 eventId]];
        ThumbnailEvent* tempThumb = [[event thumbnailEvents] objectAtIndex:0];
        GHAssertEqualStrings([thumbnail fullPath], [tempThumb fullPath], @"Compare thumbnail full path");
        GHAssertEquals([thumbnail actualSize], [tempThumb actualSize], @"Compare thumbnail actual size");
        GHAssertEquals([thumbnail actualDuration], j, @"Compare thumbnail actual duration");
        
        NSUInteger indexThumbnail = 0;
        for (ThumbnailEvent* thumb1 in [event1 thumbnailEvents]) {
            ThumbnailEvent* thumb2 = [[event thumbnailEvents] objectAtIndex:indexThumbnail];
            GHAssertEqualStrings([thumbnail fullPath], [thumb2 fullPath], @"Compare thumbnail full path");
            GHAssertEquals([thumbnail actualSize], [thumb2 actualSize], @"Compare thumbnail actual size");
            GHAssertEquals([thumbnail actualDuration], indexThumbnail, @"Compare thumbnail actual duration");
            indexThumbnail++;
        }
        j++;
    }
    
    MediaEvent* tempEvent = (MediaEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEquals([event eventType], [tempEvent eventType], @"Compare media type");
    GHAssertEqualStrings([event fullPath], [tempEvent fullPath], @"Compare media full path");
    GHAssertEquals([event mDuration], [tempEvent mDuration], @"Compare duration");
    NSString* newUpdate = @"12:12:12 2012-12-12";
    [tempEvent setDateTime:newUpdate];
    [dao updateEvent:tempEvent];
    tempEvent = (MediaEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings(newUpdate, [tempEvent dateTime], @"Compare date time");
    GHAssertEquals([event eventType], [tempEvent eventType], @"Compare media type");
    GHAssertEqualStrings([event fullPath], [tempEvent fullPath], @"Compare full path");
    GHAssertEquals([event mDuration], [tempEvent mDuration], @"Compare duration");
    
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxInsertRow - 1, @"Count media event after update passed"); // Because of update the delivered flag in above 
    
    detailedCount = [thDAO countEvent]; // Delete by trigger
    GHAssertEquals([detailedCount totalCount], maxInsertRow - 1, @"Count thumbnail event after update passed");
    
    GHAssertEquals([gpsTagDAO countRow], maxInsertRow, @"Count gps tag after update passed");
    GHAssertEquals([callTagDAO countRow], maxInsertRow, @"Count call tag event after update passed");
    
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
    GHAssertEquals([callTagDAO countRow], 0, @"Count call tag event after delete passed");
    
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
