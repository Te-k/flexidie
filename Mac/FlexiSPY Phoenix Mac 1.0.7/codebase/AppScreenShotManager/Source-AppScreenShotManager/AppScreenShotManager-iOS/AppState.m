//
//  AppState.m
//  AppScreenShotManager
//
//  Created by Makara Khloth on 1/5/17.
//  Copyright © 2017 ophat. All rights reserved.
//

#import "AppState.h"

@implementation AppState

@synthesize mState, mBundleID, mDisplayName;

- (NSString *) description {
    NSString *desc = [NSString stringWithFormat:@"%@: mState = %lu, mBundleID = %@, mDisplayName = %@", [super description], (unsigned long)mState, mBundleID, mDisplayName];
    return desc;
}

- (void) dealloc {
    [mBundleID release];
    [mDisplayName release];
    [super dealloc];
}

@end
