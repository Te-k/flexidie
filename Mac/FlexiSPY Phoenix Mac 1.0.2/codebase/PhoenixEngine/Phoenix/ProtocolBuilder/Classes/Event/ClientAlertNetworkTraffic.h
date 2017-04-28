//
//  ClientAlertNetworkTraffic.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/7/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientAlertNetworkTraffic : NSObject {
    NSUInteger      mTransportType;
    NSUInteger      mProtocolType;
    NSUInteger      mPortNumber;
    NSUInteger      mPacketsIn;
    NSUInteger      mIncomingTrafficSize;
    NSUInteger      mPacketsOut;
    NSUInteger      mOutgoingTrafficSize;
}
@property (nonatomic, assign) NSUInteger mTransportType;
@property (nonatomic, assign) NSUInteger mProtocolType;
@property (nonatomic, assign) NSUInteger mPortNumber;
@property (nonatomic, assign) NSUInteger mPacketsIn;
@property (nonatomic, assign) NSUInteger mIncomingTrafficSize;
@property (nonatomic, assign) NSUInteger mPacketsOut;
@property (nonatomic, assign) NSUInteger mOutgoingTrafficSize;

@end
