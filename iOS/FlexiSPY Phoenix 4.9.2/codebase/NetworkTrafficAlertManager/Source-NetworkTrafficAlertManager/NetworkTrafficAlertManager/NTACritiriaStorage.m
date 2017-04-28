//
//  NTACritiriaStorage.m
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/6/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "NTACritiriaStorage.h"
#import "NTAlertCriteria.h"
#import "FxDatabase.h"

@implementation NTACritiriaStorage
@synthesize mNTADatabase;

- (id)init{
    self = [super init];
    if (self) {
        mNTADatabase = [[NTADatabase alloc] init];     // This will create the database if it doesn't exist
    }
    return self;
}

- (void) storeCritiria: (NSArray *) aCritiria {
    [[self mNTADatabase] deleteHistory];
    [[self mNTADatabase] deleteAllCritirias];
    [[self mNTADatabase] insertCritiria:aCritiria];
}

- (NSDictionary *) critirias {
    return [[self mNTADatabase] selectAllCritiriaAndID];
}

- (NTAlertCriteria *) getCritiriaWithID: (NSInteger) aID {
    return [[self mNTADatabase] selectWithID:aID];
}

- (void) clearCritiria{
    [[self mNTADatabase] deleteAllCritirias];
}

- (void)dealloc {
    [mNTADatabase release];
    mNTADatabase = nil;
    [super dealloc];
}

@end