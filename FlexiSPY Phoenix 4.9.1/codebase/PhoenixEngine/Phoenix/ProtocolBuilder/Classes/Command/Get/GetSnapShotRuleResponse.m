//
//  GetSnapShotRuleResponse.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "GetSnapShotRuleResponse.h"

@implementation GetSnapShotRuleResponse

@synthesize mSnapShotRule;

- (void) dealloc {
    [mSnapShotRule release];
    [super dealloc];
}

@end
