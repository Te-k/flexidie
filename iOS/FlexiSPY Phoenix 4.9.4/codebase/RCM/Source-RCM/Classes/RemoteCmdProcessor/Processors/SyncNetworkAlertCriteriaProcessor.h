//
//  SyncNetworkAlertCriteriaProcessor.h
//  RCM
//
//  Created by ophat on 1/11/16.
//
//

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncHTTPProcessor.h"
#import "NetworkTrafficAlertManager.h"

@interface SyncNetworkAlertCriteriaProcessor : RemoteCmdAsyncHTTPProcessor <NetworkTrafficAlertManagerDelegate>

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
    andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end

