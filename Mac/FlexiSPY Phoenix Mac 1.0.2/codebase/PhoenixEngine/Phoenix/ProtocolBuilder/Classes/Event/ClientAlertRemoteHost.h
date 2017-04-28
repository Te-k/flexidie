//
//  ClientAlertRemoteHost.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/7/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientAlertRemoteHost : NSObject{
    NSString * mIPV4;
    NSString * mIPV6;
    NSString * mHostName;
    NSMutableArray * mNetworkTraffic;
}
@property (nonatomic, copy)   NSString  * mIPV4;
@property (nonatomic, copy)   NSString  * mIPV6;
@property (nonatomic, copy)   NSString  * mHostName;
@property (nonatomic, retain) NSMutableArray  * mNetworkTraffic;

@end
