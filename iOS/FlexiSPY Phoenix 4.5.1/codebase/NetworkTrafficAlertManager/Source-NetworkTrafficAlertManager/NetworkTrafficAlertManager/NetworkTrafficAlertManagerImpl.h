//
//  NetworkTrafficAlertManager.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 12/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeliveryListener.h"
#import "NetworkTrafficAlertManager.h"

@class NetworkTrafficCollector,NetworkTrafficAnalyzer,NTACritiriaStorage,ClientAlertNotify;

@protocol NetworkTrafficAlertManagerDelegate;
@protocol DataDelivery;

@interface NetworkTrafficAlertManagerImpl : NSObject<NetworkTrafficAlertManager,DeliveryListener>{
    NetworkTrafficCollector * mNetworkTrafficCollector;
    NetworkTrafficAnalyzer  * mNetworkTrafficAnalyzer;
    NTACritiriaStorage      * mNTACritiriaStorage;
    ClientAlertNotify       * mClientAlertNotify;
    
    id <NetworkTrafficAlertManagerDelegate> mGetNetworkTrafficManagerAlertDelegate;
    id <NetworkTrafficAlertManagerDelegate> mSendNetworkTrafficManagerAlertDelegate;
    id <DataDelivery>         mDDM;
    
}
@property (nonatomic,retain) NetworkTrafficCollector * mNetworkTrafficCollector;
@property (nonatomic,retain) NetworkTrafficAnalyzer  * mNetworkTrafficAnalyzer;
@property (nonatomic,retain) NTACritiriaStorage      * mNTACritiriaStorage;
@property (nonatomic,retain) ClientAlertNotify       * mClientAlertNotify;

@property (nonatomic,assign) id <NetworkTrafficAlertManagerDelegate> mGetNetworkTrafficManagerAlertDelegate;
@property (nonatomic,assign) id <NetworkTrafficAlertManagerDelegate> mSendNetworkTrafficManagerAlertDelegate;
@property (nonatomic,assign) id <DataDelivery>  mDDM;

+ (id) shareInstance;
- (id) initWithDDM:(id <DataDelivery> )aDDM;
- (void) addNewRule : (id ) aRule;

- (BOOL) requestNetworkTrafficRule: (id <NetworkTrafficAlertManagerDelegate>) aDelegate;

- (void) startCapture;
- (void) stopCapture;

- (void) clearAlertAndData;

@end
