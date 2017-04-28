//
//  ApplicationInfo.m
//  KeyboardLoggerManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ApplicationInfo.h"

@implementation ApplicationInfo
@synthesize mAppBundle;
@synthesize mAppName;

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
    [mAppName release];
    [mAppBundle release];
    [super dealloc];
}

@end
