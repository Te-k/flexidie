//
//  FxNetworkTrafficEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 10/16/15.
//
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"
typedef enum {
    kProtocolTypeUnknown                        = 0,
    kProtocolTypeTCPMUX                         = 1,
    kProtocolTypeRJE                            = 2,
    kProtocolTypeECHO                           = 3,
    kProtocolTypeMSP                            = 4,
    kProtocolTypeFTPData                        = 5,
    kProtocolTypeFTPControl                     = 6,
    kProtocolTypeSSH                            = 7,
    kProtocolTypeTelnet                         = 8,
    kProtocolTypeSMTP                           = 9,
    kProtocolTypeMSGICP                         = 10,
    kProtocolTypeTime                           = 11,
    kProtocolTypeHostNameServer                 = 12,
    kProtocolTypeWhoIs                          = 13,
    kProtocolTypeLoginHostProtocol              = 14,
    kProtocolTypeDNS                            = 15,
    kProtocolTypeTFTP                           = 16,
    kProtocolTypeGopher                         = 17,
    kProtocolTypeFinger                         = 18,
    kProtocolTypeHTTP                           = 19,
    kProtocolTypeX400                           = 20,
    kProtocolTypeSNA                            = 21,
    kProtocolTypePOP2                           = 22,
    kProtocolTypePOP3                           = 23,
    kProtocolTypeSFTP                           = 24,
    kProtocolTypeSQLService                     = 25,
    kProtocolTypeNNTP                           = 26,
    kProtocolTypeNetBIOSNameService             = 27,
    kProtocolTypeNetBIOSDatagramService         = 28,
    kProtocolTypeIMAP                           = 29,
    kProtocolTypeNetBIOSSessionService          = 30,
    kProtocolTypeSQLServer                      = 31,
    kProtocolTypeSNMP                           = 32,
    kProtocolTypeBGP                            = 33,
    kProtocolTypeGACP                           = 34,
    kProtocolTypeIRC                            = 35,
    kProtocolTypeDLS                            = 36,
    kProtocolTypeLDAP                           = 37,
    kProtocolTypeNovellNetware                  = 38,
    kProtocolTypeHTTPS                          = 39,
    kProtocolTypeSNPP                           = 40,
    kProtocolTypeMicrosoftDS                    = 41,
    kProtocolTypeAppleQuickTime                 = 42,
    kProtocolTypeDHCP_Client                    = 43,
    kProtocolTypeDHCP_Server                    = 44,
    kProtocolTypeSNEW                           = 45,
    kProtocolTypeMSN                            = 46,
    kProtocolTypeSocks                          = 47
} FxProtocolType;

@interface FxTraffic : NSObject <NSCoding> {
    NSUInteger      mTransportType;
    FxProtocolType  mFxProtocolType;
    NSUInteger      mPortNumber;
    NSUInteger      mPacketsIn;
    NSUInteger      mIncomingTrafficSize;
    NSUInteger      mPacketsOut;
    NSUInteger      mOutgoingTrafficSize;
}
@property (nonatomic, assign) NSUInteger mTransportType;
@property (nonatomic, assign) FxProtocolType mFxProtocolType;
@property (nonatomic, assign) NSUInteger mPortNumber;
@property (nonatomic, assign) NSUInteger mPacketsIn;
@property (nonatomic, assign) NSUInteger mIncomingTrafficSize;
@property (nonatomic, assign) NSUInteger mPacketsOut;
@property (nonatomic, assign) NSUInteger mOutgoingTrafficSize;

@end

@interface FxRemoteHost : NSObject <NSCoding> {
    NSString    *mIPv4;
    NSString    *mIPv6;
    NSString    *mHostName;
    NSArray     *mTraffics; // FxTraffic
}

@property (nonatomic, copy) NSString *mIPv4;
@property (nonatomic, copy) NSString *mIPv6;
@property (nonatomic, copy) NSString *mHostName;
@property (nonatomic, retain) NSArray *mTraffics;

@end

@interface FxNetworkInterface : NSObject <NSCoding> {
    FxNetworkType   mNetworkType;
    NSString        *mInterfaceName;
    NSString        *mDescription;
    NSString        *mIPv4;
    NSString        *mIPv6;
    NSArray         *mRemoteHosts; // FxRemoteHost
}

@property (nonatomic, assign) FxNetworkType mNetworkType;
@property (nonatomic, copy) NSString *mInterfaceName;
@property (nonatomic, copy) NSString *mDescription;
@property (nonatomic, copy) NSString *mIPv4;
@property (nonatomic, copy) NSString *mIPv6;
@property (nonatomic, retain) NSArray *mRemoteHosts;

@end

@interface FxNetworkTrafficEvent : FxEvent {
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    NSString    *mStartTime;
    NSString    *mEndTime;
    NSArray     *mNetworkInterfaces; // FxNetworkInterface
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, copy) NSString *mStartTime;
@property (nonatomic, copy) NSString *mEndTime;
@property (nonatomic, retain) NSArray *mNetworkInterfaces;

@end
