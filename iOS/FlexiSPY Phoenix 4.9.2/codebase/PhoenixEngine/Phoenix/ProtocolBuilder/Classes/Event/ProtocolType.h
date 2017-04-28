//
//  protocolType.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/8/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

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
} ProtocolType;