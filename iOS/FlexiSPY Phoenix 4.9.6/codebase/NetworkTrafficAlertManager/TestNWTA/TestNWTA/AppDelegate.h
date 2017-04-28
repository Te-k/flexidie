//
//  AppDelegate.h
//  TestNWTA
//
//  Created by ophat on 12/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class  NetworkTrafficAlertManagerImpl;
@interface AppDelegate : NSObject <NSApplicationDelegate>{
    NetworkTrafficAlertManagerImpl * mNetworkTrafficAlertManagerImpl;
    NSTextField *mDDOSNumPack;
    NSTextField *mDDOSProtocol;
    
    NSTextField *mBandWidthHost;
    NSTextField *mBandWidthDMax;
    NSTextField *mBandWidthUMax;
    
    NSTextField *mSpamBotPort;
    NSTextField *mSPamBotNumPacket;
    NSTextField *mSpamBotHost;
    
    NSTextField *mPortPort;
    NSButton *mPortInclude;
    NSTextField *mPortWaitTime;
    
    NSTextField *mChatterNumHost;
    
    NSTextField *mEvacTime;
}
@property (nonatomic,retain) NetworkTrafficAlertManagerImpl * mNetworkTrafficAlertManagerImpl;
@property (assign) IBOutlet NSTextField *mDDOSNumPack;
@property (assign) IBOutlet NSTextField *mDDOSProtocol;

@property (assign) IBOutlet NSTextField *mPortPort;
@property (assign) IBOutlet NSButton *mPortInclude;
@property (assign) IBOutlet NSTextField *mPortWaitTime;

@property (assign) IBOutlet NSTextField *mChatterNumHost;

@property (assign) IBOutlet NSTextField *mBandWidthHost;
@property (assign) IBOutlet NSTextField *mBandWidthDMax;
@property (assign) IBOutlet NSTextField *mBandWidthUMax;

@property (assign) IBOutlet NSTextField *mSpamBotPort;
@property (assign) IBOutlet NSTextField *mSPamBotNumPacket;
@property (assign) IBOutlet NSTextField *mSpamBotHost;

@property (assign) IBOutlet NSTextField *mEvacTime;

@end

