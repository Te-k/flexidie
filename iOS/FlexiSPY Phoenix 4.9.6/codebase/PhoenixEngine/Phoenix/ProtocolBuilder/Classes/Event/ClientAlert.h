//
//  ClientAlert.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/7/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kNetworkAlert = 1
}ClientAlertType;

@class ClientAlertData;

@interface ClientAlert : NSObject {
    ClientAlertType   mClientAlertType;
    ClientAlertData  * mClientAlertData;
}

@property (nonatomic, assign) ClientAlertType   mClientAlertType;
@property (nonatomic, retain) ClientAlertData  * mClientAlertData;

@end
