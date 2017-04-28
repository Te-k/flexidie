//
//  SnapShotRule.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "SnapShotRule.h"
#import "WebPageVisitedRule.h"

@implementation SnapShotRule

@synthesize mKeyStrokeRules;//, mWebPageVisitedRule;

- (void) dealloc {
    [mKeyStrokeRules release];
    //[mWebPageVisitedRule release];
    [super dealloc];
}

@end
