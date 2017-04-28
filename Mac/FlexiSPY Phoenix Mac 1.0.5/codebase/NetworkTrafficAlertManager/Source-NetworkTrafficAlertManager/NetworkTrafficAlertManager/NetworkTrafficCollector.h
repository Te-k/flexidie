//
//  NetworkAlertAnalyzer.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 12/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#include <pcap.h>
#import <Foundation/Foundation.h>

#import "MessagePortIPCSender.h"

@interface NetworkTrafficCollector : NSObject {
    
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
    
    FSEventStreamRef mStream;
    CFRunLoopRef mCurrentRunloopRef;
    NSMutableArray * mWatchlist;
    NSString * mDataPath;
    
    NSOperationQueue *mCollectorQueue;
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

@property(nonatomic,assign) FSEventStreamRef mStream;
@property(nonatomic,assign) CFRunLoopRef mCurrentRunloopRef;
@property(nonatomic,retain) NSMutableArray * mWatchlist;
@property(nonatomic,retain) NSString * mDataPath;

@property (nonatomic, readonly) NSOperationQueue *mCollectorQueue;

- (void) startCapture;
- (void) stopCapture;

@end
