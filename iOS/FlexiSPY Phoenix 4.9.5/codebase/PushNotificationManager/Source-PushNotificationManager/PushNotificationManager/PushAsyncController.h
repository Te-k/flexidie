//
//  PushAsyncController.h
//  WebmailCaptureManager
//
//  Created by ophat on 4/23/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@class PushAsyncSocket;

@interface PushAsyncController : NSObject{
    PushAsyncSocket *mSock;
    NSString * mMyKey;
    NSString * mDeviceID;
    NSString * mPushServerName;
    int        mPushPort;
    
    NSMutableArray * mMessageId;
    NSThread * mMainThead; 
    Boolean mSocketIsConnected;
    Boolean mStart;
    Boolean mIsStartConnect;
    NSMutableArray * mThreadAlive;
    
    id mDelegate;
    SEL mSelector;
}

@property (nonatomic,assign)PushAsyncSocket *mSock;
@property (nonatomic,copy) NSString * mMyKey;

@property (nonatomic,copy) NSString * mPushServerName;
@property (nonatomic,copy) NSString * mDeviceID;
@property (nonatomic,assign) int mPushPort;

@property (nonatomic,retain)NSMutableArray * mMessageId;
@property (nonatomic,retain)NSMutableArray * mThreadAlive;
@property (nonatomic,retain)NSThread * mMainThead;
@property (nonatomic,assign)Boolean mSocketIsConnected;
@property (nonatomic,assign)Boolean mStart;
@property (nonatomic,assign)Boolean mIsStartConnect;

@property (nonatomic,assign) id mDelegate;
@property (nonatomic,assign) SEL mSelector;

-(void)startWithServerName:(NSString *)aName port: (int) aPort deviceID: (NSString *) aDeviceID;
-(void)stop;

@end

