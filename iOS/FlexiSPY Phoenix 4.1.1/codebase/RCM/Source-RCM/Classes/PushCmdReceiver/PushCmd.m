//
//  PushCmd.m
//  RCM
//
//  Created by Makara Khloth on 7/17/15.
//
//

#import "PushCmd.h"

@implementation PushCmd
@synthesize mPushMessage;

- (void) dealloc {
    [mPushMessage release];
    [super dealloc];
}

@end
