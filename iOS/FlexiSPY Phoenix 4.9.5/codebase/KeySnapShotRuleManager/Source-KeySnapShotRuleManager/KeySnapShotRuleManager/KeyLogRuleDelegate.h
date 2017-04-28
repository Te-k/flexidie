//
//  KeyLogRuleDelegate.h
//  KeySnapShotRuleManager
//
//  Created by Ophat Phuetkasickonphasutha on 12/2/13.
//  Copyright 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KeyLogRuleDelegate <NSObject>

- (void) keyLogRuleChanged: (NSDictionary *) aKeyLogRuleInfo;
- (void) monitorApplicationChanged: (NSDictionary *) aMonitorApplicationInfo;

@end
