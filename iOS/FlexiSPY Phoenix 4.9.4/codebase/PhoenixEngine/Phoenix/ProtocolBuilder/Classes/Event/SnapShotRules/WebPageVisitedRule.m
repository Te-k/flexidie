//
//  WebPageVisitedRule.m
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import "WebPageVisitedRule.h"

@implementation WebPageVisitedRule

@synthesize mDomainNames, mKeywords, mPageTitles;

- (void) dealloc {
    [mDomainNames release];
    [mKeywords release];
    [mPageTitles release];
    [super dealloc];
}

@end
