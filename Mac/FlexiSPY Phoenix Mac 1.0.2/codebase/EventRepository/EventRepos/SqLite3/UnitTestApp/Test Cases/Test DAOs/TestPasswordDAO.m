//
//  TestPasswordDAO.m
//  UnitTestApp
//
//  Created by Makara on 2/25/14.
//
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxPasswordEvent.h"
#import "PasswordDAO.h"
#import "AppPasswordDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestPasswordDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestPasswordDAO

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
    FxPasswordEvent* passwordEvent = [[FxPasswordEvent alloc] init];
    passwordEvent.dateTime = kEventDateTime;
    passwordEvent.mApplicationID = @"com.kbak.kmobile";
    passwordEvent.mApplicationName = @"KBank Mobile";
    passwordEvent.mApplicationType = kPasswordApplicationTypeNativeMail;
    
    NSMutableArray *appPwds = [NSMutableArray arrayWithCapacity:3];
    
    FxAppPwd *appPwd = [[FxAppPwd alloc] init];
    [appPwd setMAccountName:@"Ben"];
    [appPwd setMUserName:@"benjawan"];
    [appPwd setMPassword:@"tcpip123"];
    [appPwds addObject:appPwd];
    [appPwd release];
    
    appPwd = [[FxAppPwd alloc] init];
    [appPwd setMAccountName:@"Bill"];
    [appPwd setMUserName:@"ophat"];
    [appPwd setMPassword:@"tcpip*123"];
    [appPwds addObject:appPwd];
    [appPwd release];
    
    appPwd = [[FxAppPwd alloc] init];
    [appPwd setMAccountName:@"Mak"];
    [appPwd setMUserName:@"makara"];
    [appPwd setMPassword:@"tcp!p*123"];
    [appPwds addObject:appPwd];
    [appPwd release];
    
    [passwordEvent setMAppPwds:appPwds];

    PasswordDAO* passwordDAO = [DAOFactory dataAccessObject:[passwordEvent eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [passwordDAO insertEvent:passwordEvent];
    DetailedCount* detailedCount = [passwordDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    AppPasswordDAO *appPwdDAO = [[AppPasswordDAO alloc] initWithSQLite3:[mDatabaseManager sqlite3db]];
    for (FxAppPwd *appPwd in [passwordEvent mAppPwds]) {
        [appPwd setMPasswordID:1];
        [appPwdDAO insertRow:appPwd];
    }
    GHAssertEquals([appPwdDAO countRow], 3, @"Count app pwd after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [passwordDAO selectMaxEvent:33];
    for (FxPasswordEvent* passwordEvent1 in eventArray) {
        lastEventId = [passwordEvent1 eventId];
        GHAssertEqualStrings([passwordEvent dateTime], [passwordEvent1 dateTime], @"Compare date time");
        GHAssertEqualStrings([passwordEvent mApplicationID], [passwordEvent1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([passwordEvent mApplicationName], [passwordEvent1 mApplicationName], @"Compare application name");
        GHAssertEquals([passwordEvent mApplicationType], [passwordEvent1 mApplicationType], @"Compare application type");
        
        GHAssertEquals(lastEventId, 1, @"Compare lastEventId with 1");
        NSArray *appPwds1 = [appPwdDAO selectMaxRow:lastEventId];
        for (NSInteger i = 0; i < [appPwds1 count] && i <[appPwds count]; i++) {
            FxAppPwd *appPwd = [appPwds objectAtIndex:i];
            FxAppPwd *appPwd1 = [appPwds1 objectAtIndex:i];
            GHAssertEqualStrings([appPwd mAccountName], [appPwd1 mAccountName], @"Compare account name");
            GHAssertEqualStrings([appPwd mUserName], [appPwd1 mUserName], @"Compare user name");
            GHAssertEqualStrings([appPwd mPassword], [appPwd1 mPassword], @"Compare password");
        }
    }
    FxPasswordEvent* tempPasswordEvent = (FxPasswordEvent*)[passwordDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([passwordEvent dateTime], [tempPasswordEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([passwordEvent mApplicationID], [tempPasswordEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([passwordEvent mApplicationName], [tempPasswordEvent mApplicationName], @"Compare application name");
    GHAssertEquals([passwordEvent mApplicationType], [tempPasswordEvent mApplicationType], @"Compare application type");
    
    NSString *newApplicationID = @"com.scb.mobilescb";
    NSString *newApplicationName = @"SCB Mobile Banking";
    [tempPasswordEvent setMApplicationID:newApplicationID];
    [tempPasswordEvent setMApplicationName:newApplicationName];
    [passwordDAO updateEvent:tempPasswordEvent];
    tempPasswordEvent = (FxPasswordEvent*)[passwordDAO selectEvent:lastEventId];
    GHAssertEqualStrings([passwordEvent dateTime], [tempPasswordEvent dateTime], @"Compare date time");
    GHAssertEqualStrings(newApplicationID, [tempPasswordEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempPasswordEvent mApplicationName], @"Compare application name");
    GHAssertEquals([passwordEvent mApplicationType], [tempPasswordEvent mApplicationType], @"Compare application type");
    [passwordDAO deleteEvent:lastEventId];
    detailedCount = [passwordDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    GHAssertEquals([appPwdDAO countRow], 0, @"Count app pwd after delete pwd event passed");
    
    [appPwdDAO release];
    [passwordEvent release];
}

- (void) testStressTest {
    PasswordDAO* passwordDAO = [DAOFactory dataAccessObject:kEventTypePassword withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [passwordDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxPasswordEvent* passwordEvent = [[FxPasswordEvent alloc] init];
    passwordEvent.dateTime = kEventDateTime;
    passwordEvent.mApplicationID = @"com.kbak.kmobile";
    passwordEvent.mApplicationName = @"KBank Mobile";
    passwordEvent.mApplicationType = kPasswordApplicationTypeNoneNativeMail;
    
    NSInteger maxEventTest = 1000;
    NSInteger i;
    for (i = 0; i < maxEventTest; i++) {
        passwordEvent.mApplicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        [passwordDAO insertEvent:passwordEvent];
    }
    detailedCount = [passwordDAO countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [passwordDAO selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    i = 0;
    for (FxPasswordEvent* passwordEvent1 in eventArray) {
        lastEventId = [passwordEvent1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *applicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", i];
        
        GHAssertEqualStrings([passwordEvent dateTime], [passwordEvent1 dateTime], @"Compare date time");
        GHAssertEqualStrings([passwordEvent mApplicationID], [passwordEvent1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings(applicationName, [passwordEvent1 mApplicationName], @"Compare application name");
        GHAssertEquals([passwordEvent mApplicationType], [passwordEvent1 mApplicationType], @"Compare application type");
        
        i++;
    }
    FxPasswordEvent* tempPasswordEvent = (FxPasswordEvent*)[passwordDAO selectEvent:lastEventId];
    
    GHAssertEqualStrings([passwordEvent dateTime], [tempPasswordEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([passwordEvent mApplicationID], [tempPasswordEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([passwordEvent mApplicationName], [tempPasswordEvent mApplicationName], @"Compare application name");
    GHAssertEquals([passwordEvent mApplicationType], [tempPasswordEvent mApplicationType], @"Compare application type");
    NSString *newApplicationName = @"KBank Express";
    [tempPasswordEvent setMApplicationName:newApplicationName];
    [passwordDAO updateEvent:tempPasswordEvent];
    tempPasswordEvent = (FxPasswordEvent*)[passwordDAO selectEvent:lastEventId];
    GHAssertEqualStrings([passwordEvent dateTime], [tempPasswordEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([passwordEvent mApplicationID], [tempPasswordEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempPasswordEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([passwordEvent mApplicationType], [tempPasswordEvent mApplicationType], @"Compare application type");
    for (NSNumber* number in eventIdArray) {
        [passwordDAO deleteEvent:[number intValue]];
    }
    detailedCount = [passwordDAO countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    [eventIdArray release];
    [passwordEvent release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end