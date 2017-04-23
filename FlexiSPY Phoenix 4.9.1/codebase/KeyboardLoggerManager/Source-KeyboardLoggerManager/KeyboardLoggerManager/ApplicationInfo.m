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

- (id)copyWithZone:(NSZone *)zone {
    ApplicationInfo *myCopy = [[[self class] allocWithZone:zone] init];
    if (myCopy) {
        myCopy.mAppBundle = self.mAppBundle;
        myCopy.mAppName = self.mAppName;
        
    }
    return myCopy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.mAppBundle];
    [aCoder encodeObject:self.mAppName];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.mAppBundle = [aDecoder decodeObject];
        self.mAppName = [aDecoder decodeObject];
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
