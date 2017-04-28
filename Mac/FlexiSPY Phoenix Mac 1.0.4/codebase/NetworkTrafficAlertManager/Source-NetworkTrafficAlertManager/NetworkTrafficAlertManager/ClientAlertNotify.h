//
//  ClientAlertNotify.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/14/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeliveryListener.h"

@class NTACritiriaStorage;
@protocol DataDelivery;

@interface ClientAlertNotify : NSObject <DeliveryListener> {
     NTACritiriaStorage * mStore;
     NSMutableArray * mTemp_Keys;
     NSMutableArray * mKeys;
     id <DataDelivery>  mDDM;
    
}
@property (nonatomic,retain) NTACritiriaStorage * mStore;
@property (nonatomic,retain) NSMutableArray * mTemp_Keys;
@property (nonatomic,retain) NSMutableArray * mKeys;
@property (nonatomic,assign) id <DataDelivery>  mDDM;

- (id) init;
- (void) readyToSendClientAlert;

@end
