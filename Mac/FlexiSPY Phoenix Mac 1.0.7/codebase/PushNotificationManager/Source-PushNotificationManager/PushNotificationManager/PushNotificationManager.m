//
//  PushNotificationManager.m
//  PushNotificationManager
//
//  Created by ophat on 7/17/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "PushNotificationManager.h"
#import "PushAsyncController.h"
#import "RemoteCommandPush.h"

@interface PushNotificationManager (private)
- (void) handlePushNotificationCommand: (id) aPushCommand;
@end

@implementation PushNotificationManager

@synthesize mAsync;
@synthesize mPushDelegate;

- (id)init {
    if((self = [super init])){
        mAsync = [[PushAsyncController alloc]init];
        [mAsync setMDelegate:self];
        [mAsync setMSelector:@selector(handlePushNotificationCommand:)];
    }
    return self;
}

-(void)startWithServerName:(NSString *)aName port: (int) aPort deviceID: (NSString *) aDeviceID {
    [mAsync startWithServerName:aName port:aPort deviceID:aDeviceID];
}

-(void)stop{
    [mAsync stop];
}

- (void) handlePushNotificationCommand: (id) aPushCommand {
    if ([mPushDelegate respondsToSelector:@selector(remoteCommandPushRecieved:)]) {
        [mPushDelegate remoteCommandPushRecieved:aPushCommand];
    }
}

-(void)dealloc{
    [mAsync stop];
    [mAsync release];
    [super dealloc];
}
@end
