//
//  TestDatabaseSchema.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "TestDatabaseSchema.h"
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

NSString* const kEventDateTime1  = @"11:11:11 2011-11-11";
NSString* const kSystemMessage  = @"[4200 -1.00.1 03-05-2011][OK]\nCommand being process";

@implementation TestDatabaseSchema


- (void) testCreateDatabaseFile {
    NSLog(@"@@@@@@@@@@@@@@ testCreateDatabaseFile @@@@@@@@@@@@@@@");
    DatabaseManager* dbManager = [[DatabaseManager alloc] init];
    [dbManager openDB];
    
    //GHTestLog(@"Database path: %@", [dbManager dbFullName]);
    
    [dbManager release];
}

- (void) testDropDatabaseFile {
    NSLog(@"@@@@@@@@@@@@@@ testDropDatabaseFile @@@@@@@@@@@@@@@");
    DatabaseManager* dbManager = [[DatabaseManager alloc] init];
    if ([dbManager dbFullName]) {
        [dbManager dropDB];
    }
    [dbManager release];
}

- (void) testDropTable {
    NSLog(@"@@@@@@@@@@@@@@ testDropTable @@@@@@@@@@@@@@@");
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
    //[dbSchema dropTable:kEventTypeKeyLog];
    
    // To test table schema after drop test case above, just simply copy and past here every normal test case in each DAO test cases
    
    {
        FxSystemEvent* systemEvent      = [[FxSystemEvent alloc] init];
        systemEvent.dateTime            = kEventDateTime1;
        systemEvent.systemEventType     = kSystemEventTypeSmsCmd;
        systemEvent.direction           = kEventDirectionOut;
        systemEvent.message             = kSystemMessage;

        /********************************** INSERT ***************************************/
        SystemDAO* systemDAO            = [DAOFactory dataAccessObject:[systemEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
        [systemDAO insertEvent:systemEvent];
        
        DetailedCount* detailedCount    = [systemDAO countEvent];
        //GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
        
        /**  TEST CASE: check count **/
        if ([detailedCount totalCount] == 1) NSLog(@"Count event after insert PASS");
        else NSLog(@"!!!! Count event after insert FAIL");
        
        
        
        /********************************** SELECT ***************************************/
        NSInteger lastEventId   = 0;
        NSArray* eventArray     = [systemDAO selectMaxEvent:33];
        for (FxSystemEvent* systemEvent1 in eventArray) {
            lastEventId = [systemEvent1 eventId];
            
            
            /**  TEST CASE **/
            //GHAssertEqualStrings([systemEvent dateTime], [systemEvent1 dateTime], @"Compare date time");
            if ([[systemEvent dateTime] isEqualToString:[systemEvent1 dateTime]]) NSLog(@"Compare date time PASS");
            else NSLog(@"Compare date time FAIL");
            
            /**  TEST CASE **/                        
            //GHAssertEqualStrings([systemEvent message], [systemEvent1 message], @"Compare message");
            if ([[systemEvent message] isEqualToString:[systemEvent1 message]]) NSLog(@"Compare message PASS");
            else NSLog(@"Compare message FAIL");
            
            /**  TEST CASE **/
            //GHAssertEquals([systemEvent direction], [systemEvent1 direction], @"Compare direction");
            if ([systemEvent direction] == [systemEvent1 direction]) NSLog(@"Compare direction PASS");
            else NSLog(@"Compare direction FAIL");
            
            /**  TEST CASE **/
            //GHAssertEquals([systemEvent systemEventType], [systemEvent1 systemEventType], @"Compare system event type");
            if ([systemEvent systemEventType] == [systemEvent1 systemEventType]) NSLog(@"Compare  system event type PASS");
            else NSLog(@"Compare  system event type FAIL");            
        }
        
        /********************************** SELECT ***************************************/
        FxSystemEvent* tempSystemEvent = (FxSystemEvent*)[systemDAO selectEvent:lastEventId];
        
        
//        GHAssertEqualStrings([systemEvent dateTime], [tempSystemEvent dateTime], @"Compare date time");
//        GHAssertEqualStrings([systemEvent message], [tempSystemEvent message], @"Compare message");
//        GHAssertEquals([systemEvent direction], [tempSystemEvent direction], @"Compare direction");
//        GHAssertEquals([systemEvent systemEventType], [tempSystemEvent systemEventType], @"Compare system event type");
        
        /**  TEST CASE **/
        if ([[systemEvent dateTime] isEqualToString:[tempSystemEvent dateTime]]) NSLog(@"Compare date time PASS");
        else NSLog(@"Compare date time FAIL");
        
        /**  TEST CASE **/                        
        if ([[systemEvent message] isEqualToString:[tempSystemEvent message]]) NSLog(@"Compare message PASS");
        else NSLog(@"Compare message FAIL");
        
        /**  TEST CASE **/
        if ([systemEvent direction] == [tempSystemEvent direction]) NSLog(@"Compare direction PASS");
        else NSLog(@"Compare direction FAIL");
        
        /**  TEST CASE **/
        if ([systemEvent systemEventType] == [tempSystemEvent systemEventType]) NSLog(@"Compare  system event type PASS");
        else NSLog(@"Compare  system event type FAIL");            
        
        
        /********************************** UPDATE ***************************************/        
        
        FxSystemEventType newSystemEventType = kSystemEventTypeNextCmdReply;
        [tempSystemEvent setSystemEventType:newSystemEventType];
        [systemDAO updateEvent:tempSystemEvent];
        tempSystemEvent = (FxSystemEvent*)[systemDAO selectEvent:lastEventId];
        
//        GHAssertEqualStrings([systemEvent dateTime], [tempSystemEvent dateTime], @"Compare date time");
//        GHAssertEqualStrings([systemEvent message], [tempSystemEvent message], @"Compare message");
//        GHAssertEquals([systemEvent direction], [tempSystemEvent direction], @"Compare direction");
//        GHAssertEquals(newSystemEventType, [tempSystemEvent systemEventType], @"Compare system event type");
        
        /**  TEST CASE **/
        if ([[systemEvent dateTime] isEqualToString:[tempSystemEvent dateTime]]) NSLog(@"Compare date time PASS");
        else NSLog(@"Compare date time FAIL");
        
        /**  TEST CASE **/                        
        if ([[systemEvent message] isEqualToString:[tempSystemEvent message]]) NSLog(@"Compare message PASS");
        else NSLog(@"Compare message FAIL");
        
        /**  TEST CASE **/
        if ([systemEvent direction] == [tempSystemEvent direction]) NSLog(@"Compare direction PASS");
        else NSLog(@"Compare direction FAIL");
        
        /**  TEST CASE **/
        if (newSystemEventType == [tempSystemEvent systemEventType]) NSLog(@"Compare  system event type PASS");
        else NSLog(@"Compare  system event type FAIL"); 
        
       /********************************** DELETE ***************************************/
        
        [systemDAO deleteEvent:lastEventId];
        detailedCount = [systemDAO countEvent];
        
        
        //GHAssertEquals([detailedCount totalCount], 0, @"Count event after insert passed");
        
        /**  TEST CASE: check count **/
        if ([detailedCount totalCount] == 0) NSLog(@"Count event after insert PASS");
        else NSLog(@"!!!! Count event after insert FAIL");
        
        
        [systemEvent release];
    
    }
    
    [mDatabaseManager release];
}

@end
