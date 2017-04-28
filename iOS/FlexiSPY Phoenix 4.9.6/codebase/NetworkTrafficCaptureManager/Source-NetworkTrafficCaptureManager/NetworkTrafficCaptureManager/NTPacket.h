//
//  NTPacket.h
//  NetworkTrafficCaptureManager
//
//  Created by ophat on 10/13/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTPacket : NSObject {
    NSInteger    mTransportProtocol;
    NSUInteger   mDirection;
    NSUInteger   mInterface;
    NSString    *mInterfaceName;
    NSUInteger   mPort;
    NSString    *mSource;
    NSString    *mDestination;
    NSUInteger   mSize;
    NSString    *mHostname;
    NSInteger    mPacketCount;
    
}
@property (nonatomic, assign) NSInteger mTransportProtocol;
@property (nonatomic, assign) NSUInteger mDirection;
@property (nonatomic, assign) NSUInteger mInterface;
@property (nonatomic, copy) NSString *mInterfaceName;
@property (nonatomic, assign) NSUInteger mPort;
@property (nonatomic, copy) NSString *mSource;
@property (nonatomic, copy) NSString *mDestination;
@property (nonatomic, assign) NSUInteger mSize;
@property (nonatomic, copy) NSString *mHostname;
@property (nonatomic, assign) NSInteger mPacketCount;
+ (BOOL) comparePacket: (NTPacket *) aPackage1 with:(NTPacket *) aPackage2  ;
+ (void) printDetail:(NSMutableArray *) aArray;

@end
