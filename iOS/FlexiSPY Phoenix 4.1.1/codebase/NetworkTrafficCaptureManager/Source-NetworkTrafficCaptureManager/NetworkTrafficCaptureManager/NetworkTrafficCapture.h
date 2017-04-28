//
//  NetworkTrafficCapture.h
//  NetworkTrafficCaptureManager
//
//  Created by ophat on 10/9/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#include <pcap.h>
#import <Foundation/Foundation.h>


@interface NetworkTrafficCapture : NSObject{
    
    pcap_t   *          mHandle1;
    pcap_t   *          mHandle2;
    
    NSString *          mUsedInterfaceHandle1;
    NSString *          mUsedInterfaceHandle2;
    
    NSString *          mEn0IP;
    NSString *          mEn1IP;
   
    NSString *          mStartTime;
    NSString *          mEndTime;
    
    NSString *          mMyUrl;
   
    NSMutableArray *    mTotalUploadByLan;
    NSMutableArray *    mTotalDownloadByLan;

    NSMutableArray *    mTotalUploadByWifi;
    NSMutableArray *    mTotalDownloadByWifi;
    
    int                 mCounter;
    Boolean             mIsTracking;
    Boolean             mShouldStop;
    Boolean             mIsMerging;
    
    CFRunLoopRef        mCFRunLoop1;
    CFRunLoopSourceRef  mCFRunLoopSrc1;
    CFRunLoopRef        mCFRunLoop2;
    CFRunLoopSourceRef  mCFRunLoopSrc2;
    
    id                  mDelegate;
    SEL                 mSelector;
    NSThread            *mThread;
    
    NSTimer             *mSchedule;
    
}

@property (nonatomic,retain) NSThread *mThread;
@property (nonatomic,assign) id       mDelegate;
@property (nonatomic,assign) SEL      mSelector;

@property (nonatomic,assign) int      mCounter;
@property (nonatomic,assign) Boolean  mIsTracking;
@property (nonatomic,assign) Boolean  mShouldStop;
@property (nonatomic,assign) Boolean  mIsMerging;
@property (nonatomic,assign) pcap_t * mHandle1;
@property (nonatomic,assign) pcap_t * mHandle2;

@property (nonatomic,assign) NSTimer        * mSchedule;

@property (nonatomic,copy) NSString * mUsedInterfaceHandle1;
@property (nonatomic,copy) NSString * mUsedInterfaceHandle2;

@property (nonatomic,copy) NSString * mStartTime;
@property (nonatomic,copy) NSString * mEndTime;
@property (nonatomic,copy) NSString * mEn0IP;
@property (nonatomic,copy) NSString * mEn1IP;
@property (nonatomic,copy) NSString * mMyUrl;

@property (nonatomic,retain) NSMutableArray * mTotalUploadByLan;
@property (nonatomic,retain) NSMutableArray * mTotalDownloadByLan;
@property (nonatomic,retain) NSMutableArray * mTotalUploadByWifi;
@property (nonatomic,retain) NSMutableArray * mTotalDownloadByWifi;

@property(nonatomic,assign) CFRunLoopRef mCFRunLoop1;
@property(nonatomic,assign) CFRunLoopSourceRef mCFRunLoopSrc1;
@property(nonatomic,assign) CFRunLoopRef mCFRunLoop2;
@property(nonatomic,assign) CFRunLoopSourceRef mCFRunLoopSrc2;

- (BOOL) startCaptureWithDuration:(int)aMin frequency:(int)aFre;
- (void) stopCapture;

@end
