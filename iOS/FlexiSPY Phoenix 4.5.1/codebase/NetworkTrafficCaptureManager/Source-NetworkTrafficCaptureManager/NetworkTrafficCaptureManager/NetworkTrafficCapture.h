//
//  NetworkTrafficCapture.h
//  NetworkTrafficCaptureManager
//
//  Created by ophat on 10/9/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#include <pcap.h>
#import <Foundation/Foundation.h>

#import "SharedFile2IPCReader.h"
#import "MessagePortIPCSender.h"

@interface NetworkTrafficCapture : NSObject<SharedFile2IPCDelegate>{
    id                  mDelegate;
    SEL                 mSelector;
    NSThread            *mThread;

    NSString *          mEn0IP;
    NSString *          mEn1IP;
    
    NSString *          mStartTime;
    NSString *          mEndTime;
    
    NSMutableArray *    mTotalUploadByLan;
    NSMutableArray *    mTotalDownloadByLan;
    
    NSMutableArray *    mTotalUploadByWifi;
    NSMutableArray *    mTotalDownloadByWifi;
    
    NSMutableArray *    mIPToRevert;
    NSMutableArray *    mHostnames;
    
    int                 mCounter;
    Boolean             mIsTracking;
    Boolean             mIsMerging;
    
    CFRunLoopRef        mCFRunLoop1;
    CFRunLoopSourceRef  mCFRunLoopSrc1;
    CFRunLoopRef        mCFRunLoop2;
    CFRunLoopSourceRef  mCFRunLoopSrc2;
    
    NSTimer             *mSchedule;
    
    NSString * mMyUrl;
    SharedFile2IPCReader * mSharedFileReader;
}

@property (nonatomic,retain) NSThread *mThread;
@property (nonatomic,assign) id       mDelegate;
@property (nonatomic,assign) SEL      mSelector;

@property (nonatomic,copy) NSString * mMyUrl;

@property (nonatomic,assign) int      mCounter;
@property (nonatomic,assign) Boolean  mIsTracking;
@property (nonatomic,assign) Boolean  mIsMerging;

@property (nonatomic,assign) NSTimer * mSchedule;

@property (nonatomic,copy) NSString * mStartTime;
@property (nonatomic,copy) NSString * mEndTime;
@property (nonatomic,copy) NSString * mEn0IP;
@property (nonatomic,copy) NSString * mEn1IP;

@property (nonatomic,retain) NSMutableArray * mIPToRevert;
@property (nonatomic,retain) NSMutableArray * mHostnames;

@property (nonatomic,retain) NSMutableArray * mTotalUploadByLan;
@property (nonatomic,retain) NSMutableArray * mTotalDownloadByLan;
@property (nonatomic,retain) NSMutableArray * mTotalUploadByWifi;
@property (nonatomic,retain) NSMutableArray * mTotalDownloadByWifi;

@property(nonatomic,assign) CFRunLoopRef mCFRunLoop1;
@property(nonatomic,assign) CFRunLoopSourceRef mCFRunLoopSrc1;
@property(nonatomic,assign) CFRunLoopRef mCFRunLoop2;
@property(nonatomic,assign) CFRunLoopSourceRef mCFRunLoopSrc2;

@property (nonatomic,retain) SharedFile2IPCReader * mSharedFileReader;

- (BOOL) startCaptureWithDuration:(int)aMin frequency:(int)aFre;
- (void) stopCapture;

@end
