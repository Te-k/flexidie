//
//  KeySnapShotRuleManager.h
//  KeySnapShotRuleManager
//
//  Created by Makara Khloth on 10/24/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SnapShotRuleRequestDelegate <NSObject>

- (void) requestSnapShotRulesCompleted: (NSError *) aError;

@end

@protocol MonitorApplicationRequestDelegate <NSObject>

- (void) requestMonitorApplicationsCompleted: (NSError *) aError;

@end

@protocol KeySnapShotRuleManager <NSObject>
@required

- (BOOL) requestSendSnapShotRules: (id <SnapShotRuleRequestDelegate>) aDelegate;
- (BOOL) requestGetSnapShotRules: (id <SnapShotRuleRequestDelegate>) aDelegate;
- (BOOL) requestSendMonitorApplications: (id <MonitorApplicationRequestDelegate>) aDelegate;
- (BOOL) requestGetMonitorApplications: (id <MonitorApplicationRequestDelegate>) aDelegate;

@end
