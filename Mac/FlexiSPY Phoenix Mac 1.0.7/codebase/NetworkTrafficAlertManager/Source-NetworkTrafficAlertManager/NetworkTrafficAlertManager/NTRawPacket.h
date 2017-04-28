//
//  NTPacket.h
//  NetworkTrafficCaptureManager
//
//  Created by ophat on 10/13/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kNetworkTypeUnknown         = 0,
    kNetworkTypeCellular        = 1,
    kNetworkTypeWired           = 2,
    kNetworkTypeWifi            = 3,
    kNetworkTypeBluetooth       = 4,
    kNetworkTypeUSB             = 5
} NetworkType;

typedef enum {
    kDirectionTypeDownload      = 0,
    kDirectionTypeUpload        = 1
}DirectionType;

@interface NTRawPacket : NSObject {
    NSInteger    mTransportProtocol;
    DirectionType   mDirection;
    NSUInteger   mPort;
    NSString    *mSource;
    NSString    *mDestination;
    NSUInteger   mSize;
    NSString    *mHostname;
    NSInteger    mPacketCount;
}
@property (nonatomic, assign) NSInteger mTransportProtocol;
@property (nonatomic, assign) DirectionType mDirection; 
@property (nonatomic, assign) NSUInteger mPort;
@property (nonatomic, copy) NSString *mSource;
@property (nonatomic, copy) NSString *mDestination;
@property (nonatomic, assign) NSUInteger mSize;
@property (nonatomic, copy) NSString *mHostname;
@property (nonatomic, assign) NSInteger mPacketCount;

+ (BOOL) comparePacket: (NTRawPacket *) aPackage1 with:(NTRawPacket *) aPackage2  ;

@end
