//
//  ASSDatabase.h
//  AppScreenShotManager
//
//  Created by ophat on 4/4/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxDatabase;
@class AppScreenRule;

@interface ASSDatabase : NSObject {
     FxDatabase *mFxDatabase;
}
@property (nonatomic, readonly, retain) FxDatabase *mFxDatabase;

- (BOOL) insertRules: (NSArray *) aRules;
- (BOOL) insert: (AppScreenRule *) aRule;
- (NSDictionary *) selectAllRules;
- (AppScreenRule *) selectRuleWithID: (NSInteger) aID;
- (void) deleteRule: (NSInteger) aID;
- (void) deleteAllRules;
- (NSInteger) count;

@end
