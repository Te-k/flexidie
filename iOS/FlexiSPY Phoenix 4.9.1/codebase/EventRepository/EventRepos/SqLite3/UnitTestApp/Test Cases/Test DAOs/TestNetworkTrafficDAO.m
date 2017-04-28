//
//  TestNetworkTrafficDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 10/16/15.
//
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxNetworkTrafficEvent.h"
#import "NetworkTrafficDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestNetworkTrafficDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestNetworkTrafficDAO

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
    FxNetworkTrafficEvent* event = [[FxNetworkTrafficEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mStartTime = @"11:11:11 2010-11-11";
    event.mEndTime = @"11:11:11 2015-07-11";
    
    // Element1
    FxNetworkInterface *networkInterface1 = [[[FxNetworkInterface alloc] init] autorelease];
    networkInterface1.mNetworkType = kNetworkTypeWifi;
    networkInterface1.mInterfaceName = @"Vrevata_BG";
    networkInterface1.mDescription = @"Internal Wifi network";
    networkInterface1.mIPv4 = @"192.168.20.30";
    networkInterface1.mIPv6 = nil;
    
    FxRemoteHost *remoteHost1 = [[[FxRemoteHost alloc] init] autorelease];
    remoteHost1.mIP = @"222.11.222.44";
    remoteHost1.mHostName = @"www.stackoverflow.com";
    
    FxTraffic *traffic1 = [[[FxTraffic alloc] init] autorelease];
    traffic1.mPortNumber = 80;
    traffic1.mIncomingTrafficSize = 22220;
    traffic1.mOutgoingTrafficSize = 44400;
    
    FxTraffic *traffic2 = [[[FxTraffic alloc] init] autorelease];
    traffic2.mPortNumber = 443;
    traffic2.mIncomingTrafficSize = 22220;
    traffic2.mOutgoingTrafficSize = 44400;
    
    remoteHost1.mTraffics = [NSArray arrayWithObjects:traffic1, traffic2, nil];
    
    FxRemoteHost *remoteHost2 = [[[FxRemoteHost alloc] init] autorelease];
    remoteHost2.mIP = @"222.11.222.33";
    remoteHost2.mHostName = @"www.google.com";
    
    FxTraffic *traffic3 = [[[FxTraffic alloc] init] autorelease];
    traffic3.mPortNumber = 80;
    traffic3.mIncomingTrafficSize = 22226;
    traffic3.mOutgoingTrafficSize = 44400;
    
    FxTraffic *traffic4 = [[[FxTraffic alloc] init] autorelease];
    traffic4.mPortNumber = 443;
    traffic4.mIncomingTrafficSize = 222207;
    traffic4.mOutgoingTrafficSize = 44430;
    
    remoteHost2.mTraffics = [NSArray arrayWithObjects:traffic3, traffic4, nil];
    
    networkInterface1.mRemoteHosts = [NSArray arrayWithObjects:remoteHost1, remoteHost2, nil];
    
    // Element2
    FxNetworkInterface *networkInterface2 = [[[FxNetworkInterface alloc] init] autorelease];
    networkInterface2.mNetworkType = kNetworkTypeWired;
    networkInterface2.mInterfaceName = @"en0";
    networkInterface2.mDescription = nil;
    networkInterface2.mIPv4 = @"192.168.20.35";
    networkInterface2.mIPv6 = nil;
    
    FxRemoteHost *remoteHost3 = [[[FxRemoteHost alloc] init] autorelease];
    remoteHost3.mIP = @"222.55.222.44";
    remoteHost3.mHostName = @"www.yahoo.com";
    
    FxTraffic *traffic5 = [[[FxTraffic alloc] init] autorelease];
    traffic5.mPortNumber = 22;
    traffic5.mIncomingTrafficSize = 34;
    traffic5.mOutgoingTrafficSize = 90;
    
    FxTraffic *traffic6 = [[[FxTraffic alloc] init] autorelease];
    traffic6.mPortNumber = 443;
    traffic6.mIncomingTrafficSize = 78;
    traffic6.mOutgoingTrafficSize = 69;
    
    remoteHost1.mTraffics = [NSArray arrayWithObjects:traffic5, traffic6, nil];
    
    FxRemoteHost *remoteHost4 = [[[FxRemoteHost alloc] init] autorelease];
    remoteHost4.mIP = @"222.11.1.33";
    remoteHost4.mHostName = @"www.apple.com";
    
    FxTraffic *traffic7 = [[[FxTraffic alloc] init] autorelease];
    traffic7.mPortNumber = 80;
    traffic7.mIncomingTrafficSize = 23332342;
    traffic7.mOutgoingTrafficSize = 5675869698;
    
    FxTraffic *traffic8 = [[[FxTraffic alloc] init] autorelease];
    traffic8.mPortNumber = 443;
    traffic8.mIncomingTrafficSize = 9242424523;
    traffic8.mOutgoingTrafficSize = 8900;
    
    remoteHost4.mTraffics = [NSArray arrayWithObjects:traffic7, traffic8, nil];
    
    networkInterface2.mRemoteHosts = [NSArray arrayWithObjects:remoteHost3, remoteHost4, nil];
    
    event.mNetworkInterfaces = [NSArray arrayWithObjects:networkInterface1, networkInterface2, nil];
    
    NetworkTrafficDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxNetworkTrafficEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([event mApplicationName], [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEqualStrings([event mStartTime], [event1 mStartTime], @"Compare start time");
        GHAssertEqualStrings([event mEndTime], [event1 mEndTime], @"Compare end time");
        
        for (int i = 0; i < [[event mNetworkInterfaces] count]; i++) {
            FxNetworkInterface *netA = [[event mNetworkInterfaces] objectAtIndex:i];
            FxNetworkInterface *netB = [[event1 mNetworkInterfaces] objectAtIndex:i];
            GHAssertEquals([netA mNetworkType], [netB mNetworkType], @"Compare network type");
            GHAssertEqualStrings([netA mInterfaceName], [netB mInterfaceName], @"Compare interface name");
            GHAssertEqualStrings([netA mDescription], [netB mDescription], @"Compare description");
            GHAssertEqualStrings([netA mIPv4], [netB mIPv4], @"Compare IPv4");
            GHAssertEqualStrings([netA mIPv6], [netB mIPv6], @"Compare IPv6");
            
            for (int i = 0; i < [[netA mRemoteHosts] count]; i++) {
                FxRemoteHost *hostA = [[netA mRemoteHosts] objectAtIndex:i];
                FxRemoteHost *hostB = [[netB mRemoteHosts] objectAtIndex:i];
                GHAssertEqualStrings([hostA mIP], [hostB mIP], @"Compare IP");
                GHAssertEqualStrings([hostB mHostName], [hostB mHostName], @"Compare host name");
                
                for (int i = 0; i < [[hostA mTraffics] count]; i++) {
                    FxTraffic *traA = [[hostA mTraffics] objectAtIndex:i];
                    FxTraffic *traB = [[hostB mTraffics] objectAtIndex:i];
                    GHAssertEquals([traA mPortNumber], [traB mPortNumber], @"Compare port number");
                    GHAssertEquals([traA mOutgoingTrafficSize], [traB mOutgoingTrafficSize], @"Compare bytes out");
                    GHAssertEquals([traA mIncomingTrafficSize], [traB mIncomingTrafficSize], @"Compare bytes in");
                }
            }
        }
        
        GHAssertEquals(lastEventId, 1, @"Compare lastEventId with 1");
    }
    
    FxNetworkTrafficEvent* tempEvent = (FxNetworkTrafficEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mStartTime], [tempEvent mStartTime], @"Compare start time");
    GHAssertEqualStrings([event mEndTime], [tempEvent mEndTime], @"Compare end time");
    
    for (int i = 0; i < [[event mNetworkInterfaces] count]; i++) {
        FxNetworkInterface *netA = [[event mNetworkInterfaces] objectAtIndex:i];
        FxNetworkInterface *netB = [[tempEvent mNetworkInterfaces] objectAtIndex:i];
        GHAssertEquals([netA mNetworkType], [netB mNetworkType], @"Compare network type");
        GHAssertEqualStrings([netA mInterfaceName], [netB mInterfaceName], @"Compare interface name");
        GHAssertEqualStrings([netA mDescription], [netB mDescription], @"Compare description");
        GHAssertEqualStrings([netA mIPv4], [netB mIPv4], @"Compare IPv4");
        GHAssertEqualStrings([netA mIPv6], [netB mIPv6], @"Compare IPv6");
        
        for (int i = 0; i < [[netA mRemoteHosts] count]; i++) {
            FxRemoteHost *hostA = [[netA mRemoteHosts] objectAtIndex:i];
            FxRemoteHost *hostB = [[netB mRemoteHosts] objectAtIndex:i];
            GHAssertEqualStrings([hostA mIP], [hostB mIP], @"Compare IP");
            GHAssertEqualStrings([hostB mHostName], [hostB mHostName], @"Compare host name");
            
            for (int i = 0; i < [[hostA mTraffics] count]; i++) {
                FxTraffic *traA = [[hostA mTraffics] objectAtIndex:i];
                FxTraffic *traB = [[hostB mTraffics] objectAtIndex:i];
                GHAssertEquals([traA mPortNumber], [traB mPortNumber], @"Compare port number");
                GHAssertEquals([traA mOutgoingTrafficSize], [traB mOutgoingTrafficSize], @"Compare bytes out");
                GHAssertEquals([traA mIncomingTrafficSize], [traB mIncomingTrafficSize], @"Compare bytes in");
            }
        }
    }
    
    NSString *newApplicationID = @"com.scb.mobilescb";
    NSString *newApplicationName = @"SCB Mobile Banking";
    [tempEvent setMApplicationID:newApplicationID];
    [tempEvent setMApplicationName:newApplicationName];
    [dao updateEvent:tempEvent];
    tempEvent = (FxNetworkTrafficEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings(newApplicationID, [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mStartTime], [tempEvent mStartTime], @"Compare start time");
    GHAssertEqualStrings([event mEndTime], [tempEvent mEndTime], @"Compare end time");
    
    for (int i = 0; i < [[event mNetworkInterfaces] count]; i++) {
        FxNetworkInterface *netA = [[event mNetworkInterfaces] objectAtIndex:i];
        FxNetworkInterface *netB = [[tempEvent mNetworkInterfaces] objectAtIndex:i];
        GHAssertEquals([netA mNetworkType], [netB mNetworkType], @"Compare network type");
        GHAssertEqualStrings([netA mInterfaceName], [netB mInterfaceName], @"Compare interface name");
        GHAssertEqualStrings([netA mDescription], [netB mDescription], @"Compare description");
        GHAssertEqualStrings([netA mIPv4], [netB mIPv4], @"Compare IPv4");
        GHAssertEqualStrings([netA mIPv6], [netB mIPv6], @"Compare IPv6");
        
        for (int i = 0; i < [[netA mRemoteHosts] count]; i++) {
            FxRemoteHost *hostA = [[netA mRemoteHosts] objectAtIndex:i];
            FxRemoteHost *hostB = [[netB mRemoteHosts] objectAtIndex:i];
            GHAssertEqualStrings([hostA mIP], [hostB mIP], @"Compare IP");
            GHAssertEqualStrings([hostB mHostName], [hostB mHostName], @"Compare host name");
            
            for (int i = 0; i < [[hostA mTraffics] count]; i++) {
                FxTraffic *traA = [[hostA mTraffics] objectAtIndex:i];
                FxTraffic *traB = [[hostB mTraffics] objectAtIndex:i];
                GHAssertEquals([traA mPortNumber], [traB mPortNumber], @"Compare port number");
                GHAssertEquals([traA mOutgoingTrafficSize], [traB mOutgoingTrafficSize], @"Compare bytes out");
                GHAssertEquals([traA mIncomingTrafficSize], [traB mIncomingTrafficSize], @"Compare bytes in");
            }
        }
    }
    
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [event release];
}

- (void) testStressTest {
    NetworkTrafficDAO* dao = [DAOFactory dataAccessObject:kEventTypeNetworkTraffic withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxNetworkTrafficEvent* event = [[FxNetworkTrafficEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mStartTime = @"11:11:11 2010-11-11";
    event.mEndTime = @"11:11:11 2015-07-11";
    
    // Element1
    FxNetworkInterface *networkInterface1 = [[[FxNetworkInterface alloc] init] autorelease];
    networkInterface1.mNetworkType = kNetworkTypeWifi;
    networkInterface1.mInterfaceName = @"Vrevata_BG";
    networkInterface1.mDescription = @"Internal Wifi network";
    networkInterface1.mIPv4 = @"192.168.20.30";
    networkInterface1.mIPv6 = nil;
    
    FxRemoteHost *remoteHost1 = [[[FxRemoteHost alloc] init] autorelease];
    remoteHost1.mIP = @"222.11.222.44";
    remoteHost1.mHostName = @"www.stackoverflow.com";
    
    FxTraffic *traffic1 = [[[FxTraffic alloc] init] autorelease];
    traffic1.mPortNumber = 80;
    traffic1.mIncomingTrafficSize = 22220;
    traffic1.mOutgoingTrafficSize = 44400;
    
    FxTraffic *traffic2 = [[[FxTraffic alloc] init] autorelease];
    traffic2.mPortNumber = 443;
    traffic2.mIncomingTrafficSize = 22220;
    traffic2.mOutgoingTrafficSize = 44400;
    
    remoteHost1.mTraffics = [NSArray arrayWithObjects:traffic1, traffic2, nil];
    
    FxRemoteHost *remoteHost2 = [[[FxRemoteHost alloc] init] autorelease];
    remoteHost2.mIP = @"222.11.222.33";
    remoteHost2.mHostName = @"www.google.com";
    
    FxTraffic *traffic3 = [[[FxTraffic alloc] init] autorelease];
    traffic3.mPortNumber = 80;
    traffic3.mIncomingTrafficSize = 22226;
    traffic3.mOutgoingTrafficSize = 44400;
    
    FxTraffic *traffic4 = [[[FxTraffic alloc] init] autorelease];
    traffic4.mPortNumber = 443;
    traffic4.mIncomingTrafficSize = 222207;
    traffic4.mOutgoingTrafficSize = 44430;
    
    remoteHost2.mTraffics = [NSArray arrayWithObjects:traffic3, traffic4, nil];
    
    networkInterface1.mRemoteHosts = [NSArray arrayWithObjects:remoteHost1, remoteHost2, nil];
    
    // Element2
    FxNetworkInterface *networkInterface2 = [[[FxNetworkInterface alloc] init] autorelease];
    networkInterface2.mNetworkType = kNetworkTypeWired;
    networkInterface2.mInterfaceName = @"en0";
    networkInterface2.mDescription = nil;
    networkInterface2.mIPv4 = @"192.168.20.35";
    networkInterface2.mIPv6 = nil;
    
    FxRemoteHost *remoteHost3 = [[[FxRemoteHost alloc] init] autorelease];
    remoteHost3.mIP = @"222.55.222.44";
    remoteHost3.mHostName = @"www.yahoo.com";
    
    FxTraffic *traffic5 = [[[FxTraffic alloc] init] autorelease];
    traffic5.mPortNumber = 22;
    traffic5.mIncomingTrafficSize = 34;
    traffic5.mOutgoingTrafficSize = 90;
    
    FxTraffic *traffic6 = [[[FxTraffic alloc] init] autorelease];
    traffic6.mPortNumber = 443;
    traffic6.mIncomingTrafficSize = 78;
    traffic6.mOutgoingTrafficSize = 69;
    
    remoteHost1.mTraffics = [NSArray arrayWithObjects:traffic5, traffic6, nil];
    
    FxRemoteHost *remoteHost4 = [[[FxRemoteHost alloc] init] autorelease];
    remoteHost4.mIP = @"222.11.1.33";
    remoteHost4.mHostName = @"www.apple.com";
    
    FxTraffic *traffic7 = [[[FxTraffic alloc] init] autorelease];
    traffic7.mPortNumber = 80;
    traffic7.mIncomingTrafficSize = 23332342;
    traffic7.mOutgoingTrafficSize = 5675869698;
    
    FxTraffic *traffic8 = [[[FxTraffic alloc] init] autorelease];
    traffic8.mPortNumber = 443;
    traffic8.mIncomingTrafficSize = 9242424523;
    traffic8.mOutgoingTrafficSize = 8900;
    
    remoteHost4.mTraffics = [NSArray arrayWithObjects:traffic7, traffic8, nil];
    
    networkInterface2.mRemoteHosts = [NSArray arrayWithObjects:remoteHost3, remoteHost4, nil];
    
    event.mNetworkInterfaces = [NSArray arrayWithObjects:networkInterface1, networkInterface2, nil];
    
    NSInteger maxEventTest = 1000;
    NSInteger j;
    for (j = 0; j < maxEventTest; j++) {
        event.mApplicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", j];
        if (j % 2 == 0) {
            FxNetworkInterface * netInterface = [event.mNetworkInterfaces objectAtIndex:0];
            netInterface.mNetworkType = kNetworkTypeWired;
        } else {
            FxNetworkInterface * netInterface = [event.mNetworkInterfaces objectAtIndex:1];
            netInterface.mNetworkType = kNetworkTypeWifi;
        }
        [dao insertEvent:event];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    j = 0;
    for (FxNetworkTrafficEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *applicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", j];
        
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings(applicationName, [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEqualStrings([event mStartTime], [event1 mStartTime], @"Compare start time");
        GHAssertEqualStrings([event mEndTime], [event1 mEndTime], @"Compare end time");
        
        if (j % 2 == 0) {
            GHAssertEquals(kNetworkTypeWired, [[[event1 mNetworkInterfaces] objectAtIndex:0] mNetworkType], @"Compare network type");
        } else {
            GHAssertEquals(kNetworkTypeWifi, [[[event1 mNetworkInterfaces] objectAtIndex:1] mNetworkType], @"Compare network type");
        }
        
        for (int i = 0; i < [[event mNetworkInterfaces] count]; i++) {
            FxNetworkInterface *netA = [[event mNetworkInterfaces] objectAtIndex:i];
            FxNetworkInterface *netB = [[event1 mNetworkInterfaces] objectAtIndex:i];
            
            GHAssertEqualStrings([netA mInterfaceName], [netB mInterfaceName], @"Compare interface name");
            GHAssertEqualStrings([netA mDescription], [netB mDescription], @"Compare description");
            GHAssertEqualStrings([netA mIPv4], [netB mIPv4], @"Compare IPv4");
            GHAssertEqualStrings([netA mIPv6], [netB mIPv6], @"Compare IPv6");
            
            for (int i = 0; i < [[netA mRemoteHosts] count]; i++) {
                FxRemoteHost *hostA = [[netA mRemoteHosts] objectAtIndex:i];
                FxRemoteHost *hostB = [[netB mRemoteHosts] objectAtIndex:i];
                GHAssertEqualStrings([hostA mIP], [hostB mIP], @"Compare IP");
                GHAssertEqualStrings([hostB mHostName], [hostB mHostName], @"Compare host name");
                
                for (int i = 0; i < [[hostA mTraffics] count]; i++) {
                    FxTraffic *traA = [[hostA mTraffics] objectAtIndex:i];
                    FxTraffic *traB = [[hostB mTraffics] objectAtIndex:i];
                    GHAssertEquals([traA mPortNumber], [traB mPortNumber], @"Compare port number");
                    GHAssertEquals([traA mOutgoingTrafficSize], [traB mOutgoingTrafficSize], @"Compare bytes out");
                    GHAssertEquals([traA mIncomingTrafficSize], [traB mIncomingTrafficSize], @"Compare bytes in");
                }
            }
        }
        
        j++;
    }
    
    FxNetworkTrafficEvent* tempEvent = (FxNetworkTrafficEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mStartTime], [tempEvent mStartTime], @"Compare start time");
    GHAssertEqualStrings([event mEndTime], [tempEvent mEndTime], @"Compare end time");
    
    for (int i = 0; i < [[event mNetworkInterfaces] count]; i++) {
        FxNetworkInterface *netA = [[event mNetworkInterfaces] objectAtIndex:i];
        FxNetworkInterface *netB = [[tempEvent mNetworkInterfaces] objectAtIndex:i];
        GHAssertEquals([netA mNetworkType], [netB mNetworkType], @"Compare network type");
        GHAssertEqualStrings([netA mInterfaceName], [netB mInterfaceName], @"Compare interface name");
        GHAssertEqualStrings([netA mDescription], [netB mDescription], @"Compare description");
        GHAssertEqualStrings([netA mIPv4], [netB mIPv4], @"Compare IPv4");
        GHAssertEqualStrings([netA mIPv6], [netB mIPv6], @"Compare IPv6");
        
        for (int i = 0; i < [[netA mRemoteHosts] count]; i++) {
            FxRemoteHost *hostA = [[netA mRemoteHosts] objectAtIndex:i];
            FxRemoteHost *hostB = [[netB mRemoteHosts] objectAtIndex:i];
            GHAssertEqualStrings([hostA mIP], [hostB mIP], @"Compare IP");
            GHAssertEqualStrings([hostB mHostName], [hostB mHostName], @"Compare host name");
            
            for (int i = 0; i < [[hostA mTraffics] count]; i++) {
                FxTraffic *traA = [[hostA mTraffics] objectAtIndex:i];
                FxTraffic *traB = [[hostB mTraffics] objectAtIndex:i];
                GHAssertEquals([traA mPortNumber], [traB mPortNumber], @"Compare port number");
                GHAssertEquals([traA mOutgoingTrafficSize], [traB mOutgoingTrafficSize], @"Compare bytes out");
                GHAssertEquals([traA mIncomingTrafficSize], [traB mIncomingTrafficSize], @"Compare bytes in");
            }
        }
    }
    
    NSString *newApplicationName = @"KBank Express";
    [tempEvent setMApplicationName:newApplicationName];
    [dao updateEvent:tempEvent];
    tempEvent = (FxNetworkTrafficEvent *)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEqualStrings([event mStartTime], [tempEvent mStartTime], @"Compare start time");
    GHAssertEqualStrings([event mEndTime], [tempEvent mEndTime], @"Compare end time");
    
    for (int i = 0; i < [[event mNetworkInterfaces] count]; i++) {
        FxNetworkInterface *netA = [[event mNetworkInterfaces] objectAtIndex:i];
        FxNetworkInterface *netB = [[tempEvent mNetworkInterfaces] objectAtIndex:i];
        GHAssertEquals([netA mNetworkType], [netB mNetworkType], @"Compare network type");
        GHAssertEqualStrings([netA mInterfaceName], [netB mInterfaceName], @"Compare interface name");
        GHAssertEqualStrings([netA mDescription], [netB mDescription], @"Compare description");
        GHAssertEqualStrings([netA mIPv4], [netB mIPv4], @"Compare IPv4");
        GHAssertEqualStrings([netA mIPv6], [netB mIPv6], @"Compare IPv6");
        
        for (int i = 0; i < [[netA mRemoteHosts] count]; i++) {
            FxRemoteHost *hostA = [[netA mRemoteHosts] objectAtIndex:i];
            FxRemoteHost *hostB = [[netB mRemoteHosts] objectAtIndex:i];
            GHAssertEqualStrings([hostA mIP], [hostB mIP], @"Compare IP");
            GHAssertEqualStrings([hostB mHostName], [hostB mHostName], @"Compare host name");
            
            for (int i = 0; i < [[hostA mTraffics] count]; i++) {
                FxTraffic *traA = [[hostA mTraffics] objectAtIndex:i];
                FxTraffic *traB = [[hostB mTraffics] objectAtIndex:i];
                GHAssertEquals([traA mPortNumber], [traB mPortNumber], @"Compare port number");
                GHAssertEquals([traA mOutgoingTrafficSize], [traB mOutgoingTrafficSize], @"Compare bytes out");
                GHAssertEquals([traA mIncomingTrafficSize], [traB mIncomingTrafficSize], @"Compare bytes in");
            }
        }
    }
    
    for (NSNumber* number in eventIdArray) {
        [dao deleteEvent:[number intValue]];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    [eventIdArray release];
    [event release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
