//
//  NetworkAlertAnalyzer.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 12/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#include <pcap.h>
#import <Foundation/Foundation.h>

#import "SharedFile2IPCReader.h"
#import "MessagePortIPCSender.h"

@interface NetworkTrafficCollector : NSObject<SharedFile2IPCDelegate> {
    
    NSString *          mEn0IP;
    NSString *          mEn1IP;
    
    NSString *          mStartTime;
    NSString *          mEndTime;
    

    CFRunLoopRef        mCFRunLoop1;
    CFRunLoopSourceRef  mCFRunLoopSrc1;
    CFRunLoopRef        mCFRunLoop2;
    CFRunLoopSourceRef  mCFRunLoopSrc2;
    
    id                  mDelegate;
    SEL                 mSelector;
    NSThread            *mThread;
    Boolean             mIsPcapStart;
    
    NSMutableArray * mIPToRevert;
    NSMutableArray * mHostnames;
    
    SharedFile2IPCReader * mSharedFileReader;
}

@property (nonatomic,retain) NSThread *mThread;
@property (nonatomic,assign) id       mDelegate;
@property (nonatomic,assign) SEL      mSelector;
@property (nonatomic,assign) Boolean  mIsPcapStart;

@property (nonatomic,copy) NSString * mStartTime;
@property (nonatomic,copy) NSString * mEndTime;
@property (nonatomic,copy) NSString * mEn0IP;
@property (nonatomic,copy) NSString * mEn1IP;

@property(nonatomic,assign) CFRunLoopRef mCFRunLoop1;
@property(nonatomic,assign) CFRunLoopSourceRef mCFRunLoopSrc1;
@property(nonatomic,assign) CFRunLoopRef mCFRunLoop2;
@property(nonatomic,assign) CFRunLoopSourceRef mCFRunLoopSrc2;

@property (nonatomic,retain) NSMutableArray * mIPToRevert;
@property (nonatomic,retain) NSMutableArray * mHostnames;

@property (nonatomic,retain) SharedFile2IPCReader * mSharedFileReader;

- (void) startCapture;
- (void) stopCapture;

@end
