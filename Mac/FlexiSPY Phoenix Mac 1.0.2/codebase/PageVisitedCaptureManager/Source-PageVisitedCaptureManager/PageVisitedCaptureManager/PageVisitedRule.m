//
//  PageVisitedRule.m
//  PageVisitedCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PageVisitedRule.h"


@implementation PageVisitedRule
@synthesize mDomainNames;
@synthesize mKeywords;
@synthesize mPageTitles;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [mDomainNames release];
    [mKeywords release];
    [mPageTitles release];
    [super dealloc];
}

@end
