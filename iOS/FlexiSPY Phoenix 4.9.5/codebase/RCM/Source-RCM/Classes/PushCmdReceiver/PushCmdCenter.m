//
//  PushCmdCenter.m
//  RCM
//
//  Created by Makara Khloth on 7/17/15.
//
//

#import "PushCmdCenter.h"
#import "RemoteCmdManager.h"
#import "PushCmd.h"

@implementation PushCmdCenter

- (id) initWithRCM: (id <RemoteCmdManager>) aRCM {
    if ((self = [super init])) {
        mRCM = aRCM;
    }
    return (self);
}

- (void) remoteCommandPushRecieved: (id) aPushCommand {
    PushCmd *push = [[[PushCmd alloc] init] autorelease];
    [push setMPushMessage:aPushCommand];
    [mRCM processPushCommand:push];
}

@end
