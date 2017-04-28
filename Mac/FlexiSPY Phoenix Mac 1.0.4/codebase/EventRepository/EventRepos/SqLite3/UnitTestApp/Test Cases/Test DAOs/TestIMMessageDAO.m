//
//  TestIMMessageDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 2/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "DAOFactory.h"
#import "IMMessageDAO.h"
#import "IMMessageAttachmentDAO.h"

#import "FxIMMessageEvent.h"
#import "FxIMGeoTag.h"
#import "FxAttachment.h"
#import "FxAttachmentWrapper.h"

static NSString * const kEventDateTime = @"11:11:11 2011-11-11";

@interface TestIMMessageDAO : GHTestCase {
@private
    DatabaseManager*    mDatabaseManager;
}
@end

@implementation TestIMMessageDAO

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
    FxIMMessageEvent* imMessageEvent = [[FxIMMessageEvent alloc] init];
    imMessageEvent.dateTime = kEventDateTime;
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
    IMMessageAttachmentDAO *imMessageAttachmentDAO = [[IMMessageAttachmentDAO alloc] initWithSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [imMessageDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event before insert passed");
    [imMessageDAO insertEvent:imMessageEvent];
    NSInteger lastInsertRow = [mDatabaseManager lastInsertRowId];
    for (FxAttachment *attachment in [imMessageEvent mAttachments]) {
        FxAttachmentWrapper *att = [[FxAttachmentWrapper alloc] init];
        [att setAttachment:attachment];
        [att setMIMID:lastInsertRow];
        [imMessageAttachmentDAO insertRow:att];
        [att release];
    }
    detailedCount = [imMessageDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    GHAssertEquals([imMessageAttachmentDAO countRow], (NSInteger)[[imMessageEvent mAttachments] count], @"Count contact id after insert passed");
    
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
        
        NSArray *attachmentWrappers = [imMessageAttachmentDAO selectRowWithIMMessageID:lastEventId];
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
    GHAssertEquals([imMessageAttachmentDAO countRow], 0, @"Count contact id after insert passed");
    
    [imMessageEvent release];
}

- (void) testStressTest {
    FxIMMessageEvent* imMessageEvent = [[FxIMMessageEvent alloc] init];
    imMessageEvent.dateTime = kEventDateTime;
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
    NSInteger maxEventTest = 100;
    for (NSInteger i = 0; i < maxEventTest; i++) {
        NSString *conversationID = [NSString stringWithFormat:@"-023jlkef- %d", i];
        imMessageEvent.mConversationID = conversationID;
        [imMessageDAO insertEvent:imMessageEvent];
        NSInteger lastInsertRow = [mDatabaseManager lastInsertRowId];
        for (FxAttachment *attachment in [imMessageEvent mAttachments]) {
            FxAttachmentWrapper *att = [[FxAttachmentWrapper alloc] init];
            [att setAttachment:attachment];
            [att setMIMID:lastInsertRow];
            [imConvsAttachmentDAO insertRow:att];
        }
    }
    detailedCount = [imMessageDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    GHAssertEquals([imConvsAttachmentDAO countRow], (NSInteger)([[imMessageEvent mAttachments] count] * maxEventTest), @"Count contact id after insert passed");
    
    NSInteger lastEventId = 0;
    NSInteger i = 0;
    NSMutableArray *eventIDArray = [NSMutableArray arrayWithCapacity:maxEventTest];
    NSArray* eventArray = [imMessageDAO selectMaxEvent:maxEventTest];
    for (FxIMMessageEvent* imMessageEvent1 in eventArray) {
        lastEventId = [imMessageEvent1 eventId];
        [eventIDArray addObject:[NSNumber numberWithInt:lastEventId]];
        GHAssertEqualStrings([imMessageEvent dateTime], [imMessageEvent1 dateTime], @"Compare date time");
        GHAssertEquals([imMessageEvent mDirection], [imMessageEvent1 mDirection], @"Compare direction");
        GHAssertEquals([imMessageEvent mServiceID], [imMessageEvent1 mServiceID], @"Compare service id");
        NSString *conversationID = [NSString stringWithFormat:@"-023jlkef- %d", i];
        GHAssertEqualStrings(conversationID, [imMessageEvent1 mConversationID], @"Compare conversation id");
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
        i++;
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
    
    for (NSNumber *eventID in eventIDArray) {
        [imMessageDAO deleteEvent:[eventID intValue]];
    }
    detailedCount = [imMessageDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
    GHAssertEquals([imConvsAttachmentDAO countRow], 0, @"Count contact id after insert passed");
    
    [imMessageEvent release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
