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
    
    // To test table schema after drop test case above, just simply copy and past here every normal test case in each DAO test cases
    // 20-09-2011 11:08:11 AM
    
    {
        FxIMMessageEvent* imMessageEvent = [[FxIMMessageEvent alloc] init];
        imMessageEvent.dateTime = @"20-09-2011 11:08:11";
        imMessageEvent.mDirection = kEventDirectionIn;
        imMessageEvent.mServiceID = kIMServiceBBM;
        imMessageEvent.mConversationID = @"-023jlkef-";
        imMessageEvent.mUserID = @"kh_makara";
        FxIMGeoTag *userPlace = [[FxIMGeoTag alloc] init];
        userPlace.mPlaceName = @"Baan Rajaprarop";
        userPlace.mLongitude = 10.9223234;
        userPlace.mLatitude = 102.78797097;
        userPlace.mAltitude = 0.09877;
        userPlace.mHorAccuracy = 0.000;
        [imMessageEvent setMUserLocation:userPlace];
        [userPlace release];
        userPlace = nil;
        imMessageEvent.mRepresentationOfMessage = kIMMessageText;
        imMessageEvent.mMessage = @"Hello hello HelLo";
        FxIMGeoTag *sharePlace = [[FxIMGeoTag alloc] init];
        sharePlace.mPlaceName = @"Baan Rajaprarop";
        sharePlace.mLongitude = 10.9223234;
        sharePlace.mLatitude = 102.78797097;
        sharePlace.mAltitude = 0.09877;
        sharePlace.mHorAccuracy = 0.000;
        [imMessageEvent setMShareLocation:sharePlace];
        [sharePlace release];
        sharePlace = nil;
        
        NSMutableArray *attachments = [NSMutableArray arrayWithCapacity:2];
        FxAttachment* attachment = [[FxAttachment alloc] init];
        [attachment setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.gif"];
        [attachments addObject:attachment];
        // Thumbnail is nil
        [attachment release];
        
        attachment = [[FxAttachment alloc] init];
        [attachment setFullPath:@"/hello/world/application/documents/Test/112113-thumbnail.gif"];
        [attachments addObject:attachment];
        // Thumbnail is nil
        [attachment release];
        
        [imMessageEvent setMAttachments:attachments];
        
        IMMessageDAO* imMessageDAO = [DAOFactory dataAccessObject:[imMessageEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
        IMMessageAttachmentDAO *imConvsAttachmentDAO = [[IMMessageAttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
        DetailedCount* detailedCount = [imMessageDAO countEvent];
        GHAssertEquals([detailedCount totalCount], 0, @"Count event before insert passed");
        [imMessageDAO insertEvent:imMessageEvent];
        NSInteger lastInsertRow = [mDatabaseManager lastInsertRowId];
        for (FxAttachment *attachment in [imMessageEvent mAttachments]) {
            FxAttachmentWrapper *att = [[FxAttachmentWrapper alloc] init];
            [att setAttachment:attachment];
            [att setMIMID:lastInsertRow];
            [imConvsAttachmentDAO insertRow:att];
        }
        detailedCount = [imMessageDAO countEvent];
        GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
        GHAssertEquals([imConvsAttachmentDAO countRow], (NSInteger)[[imMessageEvent mAttachments] count], @"Count contact id after insert passed");
        
        NSInteger lastEventId = 0;
        NSArray* eventArray = [imMessageDAO selectMaxEvent:33];
        for (FxIMMessageEvent* imMessageEvent1 in eventArray) {
            lastEventId = [imMessageEvent1 eventId];
            GHAssertEqualStrings([imMessageEvent dateTime], [imMessageEvent1 dateTime], @"Compare date time");
            GHAssertEquals([imMessageEvent mDirection], [imMessageEvent1 mDirection], @"Compare direction");
            GHAssertEquals([imMessageEvent mServiceID], [imMessageEvent1 mServiceID], @"Compare service id");
            GHAssertEqualStrings([imMessageEvent mConversationID], [imMessageEvent1 mConversationID], @"Compare conversation id");
            GHAssertEqualStrings([imMessageEvent mUserID], [imMessageEvent1 mUserID], @"Compare user id");
            
            GHAssertEqualStrings([[imMessageEvent mUserLocation] mPlaceName], [[imMessageEvent1 mUserLocation] mPlaceName], @"Compare user place name");
            GHAssertEquals([[imMessageEvent mUserLocation] mLongitude], [[imMessageEvent1 mUserLocation] mLongitude], @"Compare user place longitude");
            GHAssertEquals([[imMessageEvent mUserLocation] mLatitude], [[imMessageEvent1 mUserLocation] mLatitude], @"Compare user place latitude");
            GHAssertEquals([[imMessageEvent mUserLocation] mAltitude], [[imMessageEvent1 mUserLocation] mAltitude], @"Compare user place altitude");
            GHAssertEquals([[imMessageEvent mUserLocation] mHorAccuracy], [[imMessageEvent1 mUserLocation] mHorAccuracy], @"Compare user place hor accuracy");
            GHAssertEquals([imMessageEvent mRepresentationOfMessage], [imMessageEvent1 mRepresentationOfMessage], @"Compare representation of message");
            GHAssertEqualStrings([imMessageEvent mMessage], [imMessageEvent1 mMessage], @"Compare message");
            GHAssertEqualStrings([[imMessageEvent mShareLocation] mPlaceName], [[imMessageEvent1 mShareLocation] mPlaceName], @"Compare share place name");
            GHAssertEquals([[imMessageEvent mShareLocation] mLongitude], [[imMessageEvent1 mShareLocation] mLongitude], @"Compare share place longitude");
            GHAssertEquals([[imMessageEvent mShareLocation] mLatitude], [[imMessageEvent1 mShareLocation] mLatitude], @"Compare share place latitude");
            GHAssertEquals([[imMessageEvent mShareLocation] mAltitude], [[imMessageEvent1 mShareLocation] mAltitude], @"Compare share place altitude");
            GHAssertEquals([[imMessageEvent mShareLocation] mHorAccuracy], [[imMessageEvent1 mShareLocation] mHorAccuracy], @"Compare share place hor accuracy");
            
            NSArray *attachmentWrappers = [imConvsAttachmentDAO selectRowWithIMMessageID:lastEventId];
            NSInteger index = 0;
            for (FxAttachmentWrapper *attWrapper in attachmentWrappers) {
                GHAssertEqualStrings([[attWrapper attachment] fullPath], [[attWrapper attachment] fullPath], @"Compare full path");
                NSData *data1 = [[attWrapper attachment] mThumbnail];
                NSData *data2 = [NSData data];
                GHAssertTrue([data1 isEqualToData:data2], @"Compare thumbnail");
                index++;
            }
        }
        FxIMMessageEvent* tempIMMessageEvent = (FxIMMessageEvent *)[imMessageDAO selectEvent:lastEventId];
        
        GHAssertEqualStrings([imMessageEvent dateTime], [tempIMMessageEvent dateTime], @"Compare date time");
        GHAssertEquals([imMessageEvent mDirection], [tempIMMessageEvent mDirection], @"Compare direction");
        GHAssertEquals([imMessageEvent mServiceID], [tempIMMessageEvent mServiceID], @"Compare service id");
        GHAssertEqualStrings([imMessageEvent mConversationID], [tempIMMessageEvent mConversationID], @"Compare conversation id");
        GHAssertEqualStrings([imMessageEvent mUserID], [tempIMMessageEvent mUserID], @"Compare user id");
        
        GHAssertEqualStrings([[imMessageEvent mUserLocation] mPlaceName], [[tempIMMessageEvent mUserLocation] mPlaceName], @"Compare user place name");
        GHAssertEquals([[imMessageEvent mUserLocation] mLongitude], [[tempIMMessageEvent mUserLocation] mLongitude], @"Compare user place longitude");
        GHAssertEquals([[imMessageEvent mUserLocation] mLatitude], [[tempIMMessageEvent mUserLocation] mLatitude], @"Compare user place latitude");
        GHAssertEquals([[imMessageEvent mUserLocation] mAltitude], [[tempIMMessageEvent mUserLocation] mAltitude], @"Compare user place altitude");
        GHAssertEquals([[imMessageEvent mUserLocation] mHorAccuracy], [[tempIMMessageEvent mUserLocation] mHorAccuracy], @"Compare user place hor accuracy");
        GHAssertEquals([imMessageEvent mRepresentationOfMessage], [tempIMMessageEvent mRepresentationOfMessage], @"Compare representation of message");
        GHAssertEqualStrings([imMessageEvent mMessage], [tempIMMessageEvent mMessage], @"Compare message");
        GHAssertEqualStrings([[imMessageEvent mShareLocation] mPlaceName], [[tempIMMessageEvent mShareLocation] mPlaceName], @"Compare share place name");
        GHAssertEquals([[imMessageEvent mShareLocation] mLongitude], [[tempIMMessageEvent mShareLocation] mLongitude], @"Compare share place longitude");
        GHAssertEquals([[imMessageEvent mShareLocation] mLatitude], [[tempIMMessageEvent mShareLocation] mLatitude], @"Compare share place latitude");
        GHAssertEquals([[imMessageEvent mShareLocation] mAltitude], [[tempIMMessageEvent mShareLocation] mAltitude], @"Compare share place altitude");
        GHAssertEquals([[imMessageEvent mShareLocation] mHorAccuracy], [[tempIMMessageEvent mShareLocation] mHorAccuracy], @"Compare share place hor accuracy");
        
        NSString *newConversationID = @"Where is the hell?";
        [tempIMMessageEvent setMConversationID:newConversationID];
        [imMessageDAO updateEvent:tempIMMessageEvent];
        tempIMMessageEvent = (FxIMMessageEvent *)[imMessageDAO selectEvent:lastEventId];
        GHAssertEqualStrings([imMessageEvent dateTime], [tempIMMessageEvent dateTime], @"Compare date time");
        GHAssertEquals([imMessageEvent mDirection], [tempIMMessageEvent mDirection], @"Compare direction");
        GHAssertEquals([imMessageEvent mServiceID], [tempIMMessageEvent mServiceID], @"Compare service id");
        GHAssertEqualStrings(newConversationID, [tempIMMessageEvent mConversationID], @"Compare conversation id");
        GHAssertEqualStrings([imMessageEvent mUserID], [tempIMMessageEvent mUserID], @"Compare user id");
        
        GHAssertEqualStrings([[imMessageEvent mUserLocation] mPlaceName], [[tempIMMessageEvent mUserLocation] mPlaceName], @"Compare user place name");
        GHAssertEquals([[imMessageEvent mUserLocation] mLongitude], [[tempIMMessageEvent mUserLocation] mLongitude], @"Compare user place longitude");
        GHAssertEquals([[imMessageEvent mUserLocation] mLatitude], [[tempIMMessageEvent mUserLocation] mLatitude], @"Compare user place latitude");
        GHAssertEquals([[imMessageEvent mUserLocation] mAltitude], [[tempIMMessageEvent mUserLocation] mAltitude], @"Compare user place altitude");
        GHAssertEquals([[imMessageEvent mUserLocation] mHorAccuracy], [[tempIMMessageEvent mUserLocation] mHorAccuracy], @"Compare user place hor accuracy");
        GHAssertEquals([imMessageEvent mRepresentationOfMessage], [tempIMMessageEvent mRepresentationOfMessage], @"Compare representation of message");
        GHAssertEqualStrings([imMessageEvent mMessage], [tempIMMessageEvent mMessage], @"Compare message");
        GHAssertEqualStrings([[imMessageEvent mShareLocation] mPlaceName], [[tempIMMessageEvent mShareLocation] mPlaceName], @"Compare share place name");
        GHAssertEquals([[imMessageEvent mShareLocation] mLongitude], [[tempIMMessageEvent mShareLocation] mLongitude], @"Compare share place longitude");
        GHAssertEquals([[imMessageEvent mShareLocation] mLatitude], [[tempIMMessageEvent mShareLocation] mLatitude], @"Compare share place latitude");
        GHAssertEquals([[imMessageEvent mShareLocation] mAltitude], [[tempIMMessageEvent mShareLocation] mAltitude], @"Compare share place altitude");
        GHAssertEquals([[imMessageEvent mShareLocation] mHorAccuracy], [[tempIMMessageEvent mShareLocation] mHorAccuracy], @"Compare share place hor accuracy");
        
        [imMessageDAO deleteEvent:lastEventId];
        detailedCount = [imMessageDAO countEvent];
        GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
        GHAssertEquals([imConvsAttachmentDAO countRow], 0, @"Count contact id after insert passed");
        
        [imMessageEvent release];
    }
}

@end
