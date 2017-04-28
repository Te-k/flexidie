//
//  UnitTestAppForMacUnitTest.m
//  UnitTestAppForMacUnitTest
//
//  Created by Benjawan Tanarattanakorn on 10/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "UnitTestAppForMacUnitTest.h"

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

@implementation UnitTestAppForMacUnitTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}


- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

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
        STAssertEquals([detailedCount totalCount], (NSInteger)1, @"Count event after insert passed");
        
        /********************************** SELECT ***************************************/
        NSInteger lastEventId   = 0;
        NSArray* eventArray     = [systemDAO selectMaxEvent:33];
        for (FxSystemEvent* systemEvent1 in eventArray) {
            lastEventId = [systemEvent1 eventId];

            STAssertEqualObjects([systemEvent dateTime], [systemEvent1 dateTime], @"Compare date time");
            STAssertEqualObjects([systemEvent message], [systemEvent1 message], @"Compare message");
            STAssertEquals([systemEvent direction], [systemEvent1 direction], @"Compare direction");
            STAssertEquals([systemEvent systemEventType], [systemEvent1 systemEventType], @"Compare system event type");
        }
        
        /********************************** SELECT ***************************************/
        FxSystemEvent* tempSystemEvent = (FxSystemEvent*)[systemDAO selectEvent:lastEventId];
        
        STAssertEqualObjects([systemEvent dateTime], [tempSystemEvent dateTime], @"Compare date time");
        STAssertEqualObjects([systemEvent message], [tempSystemEvent message], @"Compare message");
        STAssertEquals([systemEvent direction], [tempSystemEvent direction], @"Compare direction");
        STAssertEquals([systemEvent systemEventType], [tempSystemEvent systemEventType], @"Compare system event type");

        
        /********************************** UPDATE ***************************************/        
        FxSystemEventType newSystemEventType = kSystemEventTypeNextCmdReply;
        [tempSystemEvent setSystemEventType:newSystemEventType];
        [systemDAO updateEvent:tempSystemEvent];
        tempSystemEvent = (FxSystemEvent*)[systemDAO selectEvent:lastEventId];
        
        STAssertEqualObjects([systemEvent dateTime], [tempSystemEvent dateTime], @"Compare date time");
        STAssertEqualObjects([systemEvent message], [tempSystemEvent message], @"Compare message");
        STAssertEquals([systemEvent direction], [tempSystemEvent direction], @"Compare direction");
        STAssertEquals(newSystemEventType, [tempSystemEvent systemEventType], @"Compare system event type");
            
        /********************************** DELETE ***************************************/
        [systemDAO deleteEvent:lastEventId];
        detailedCount = [systemDAO countEvent];
                
        STAssertEquals([detailedCount totalCount], (NSInteger)0, @"Count event after insert passed");
             
        [systemEvent release];
    }
    
    [mDatabaseManager release];
}



@end
