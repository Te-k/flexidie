//
//  PushNotificationManager.h
//  PushNotificationManager
//
//  Created by ophat on 7/17/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PushAsyncController;
@protocol RemoteCommandPush;

@interface PushNotificationManager : NSObject{
    PushAsyncController * mAsync;
    id <RemoteCommandPush> mPushDelegate;
}

@property (nonatomic,assign)PushAsyncController *mAsync;
@property (nonatomic,assign) id <RemoteCommandPush> mPushDelegate;

-(void)startWithServerName:(NSString *)aName port: (int) aPort deviceID: (NSString *) aDeviceID;
-(void)stop;

@end
