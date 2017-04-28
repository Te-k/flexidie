//
//  AppScreenShotRuleStorage.h
//  AppScreenShotManager
//
//  Created by ophat on 4/4/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASSDatabase.h"

@class AppScreenRule;
@interface AppScreenShotRuleStorage : NSObject{
    ASSDatabase * mASSDatabase;
}
@property(nonatomic,retain) ASSDatabase * mASSDatabase;

- (void) storeRule: (NSArray *) aRule;
- (NSDictionary *) getAllRules;
- (AppScreenRule *) getRuleWithID: (NSInteger) aID;
- (void) clearRules;


@end


