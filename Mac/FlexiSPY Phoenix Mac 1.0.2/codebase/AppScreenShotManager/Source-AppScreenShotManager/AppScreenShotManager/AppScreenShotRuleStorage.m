//
//  AppScreenShotRuleStorage.m
//  AppScreenShotManager
//
//  Created by ophat on 4/4/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "AppScreenShotRuleStorage.h"
#import "FxDatabase.h"

@implementation AppScreenShotRuleStorage
@synthesize mASSDatabase;

- (id)init{
    self = [super init];
    if (self) {
        mASSDatabase = [[ASSDatabase alloc] init];     // This will create the database if it doesn't exist
    }
    return self;
}

- (void) storeRule: (NSArray *) aRule {
    [[self mASSDatabase] deleteAllRules];
    [[self mASSDatabase] insertRules:aRule];
}

- (NSDictionary *) getAllRules {
    return [[self mASSDatabase] selectAllRules];
}

- (AppScreenRule *) getRuleWithID: (NSInteger) aID {
    return [[self mASSDatabase] selectRuleWithID:aID];
}

- (void) clearRules{
    [[self mASSDatabase] deleteAllRules];
}

- (void)dealloc {
    [mASSDatabase release];
    mASSDatabase = nil;
    [super dealloc];
}

@end
