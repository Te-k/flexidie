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
@synthesize mApplicationName;
@synthesize mApplicationID;
@synthesize mPID;

@synthesize mFirefoxPlacesPath;

- (instancetype) init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) copyWithZone:(NSZone *)zone {
    PageInfo *mycopy = [[PageInfo allocWithZone:zone] init];
    mycopy.mUrl = [self.mUrl copyWithZone:zone];
    mycopy.mTitle = [self.mTitle copyWithZone:zone];
    mycopy.mApplicationName = [self.mApplicationName copyWithZone:zone];
    mycopy.mApplicationID = [self.mApplicationID copyWithZone:zone];
    mycopy.mPID = self.mPID;
    mycopy.mFirefoxPlacesPath = [self.mFirefoxPlacesPath copyWithZone:zone];
    return mycopy;
}

- (void) dealloc {
    [mUrl release];
    [mTitle release];
    [mApplicationName release];
    [mApplicationID release];
    [mFirefoxPlacesPath release];
    [super dealloc];
}

@end
