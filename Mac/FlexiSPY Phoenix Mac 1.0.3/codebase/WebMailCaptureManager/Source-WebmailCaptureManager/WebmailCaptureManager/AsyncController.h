//
//  AsyncController.h
//  WebmailCaptureManager
//
//  Created by ophat on 4/23/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@class AsyncSocket;

@interface AsyncController : NSObject{
    AsyncSocket *listenSocket;
    NSMutableArray *connectedSockets;
    NSString * mMyKey;
}
@property (nonatomic,copy)NSString * mMyKey;

-(void)startServer;
-(void)stopServer;

@end

