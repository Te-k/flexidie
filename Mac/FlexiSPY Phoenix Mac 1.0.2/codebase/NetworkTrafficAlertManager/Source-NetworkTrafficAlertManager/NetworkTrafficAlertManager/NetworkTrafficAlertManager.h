//
//  NetworkTrafficAlertManager.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 12/17/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

@protocol NetworkTrafficAlertManagerDelegate <NSObject>
@optional
    - (void) requestNetworkTrafficRuleCompleted: (NSError *) aError; 
@end

@protocol NetworkTrafficAlertManager <NSObject>
@optional
- (BOOL) requestNetworkTrafficRule: (id <NetworkTrafficAlertManagerDelegate>) aDelegate;
- (void) resetNetworkTrafficRules;
@end


