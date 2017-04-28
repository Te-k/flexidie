//
//  PageInfo.m
//  PageVisitedCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PageInfo.h"

@implementation PageInfo

@synthesize mUrl;
@synthesize mTitle;
@synthesize mApplication;
@synthesize mApplicationID;

- (instancetype) init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) dealloc {
    [mUrl release];
    [mTitle release];
    [mApplication release];
    [mApplicationID release];
    [super dealloc];
}

@end
