//
//  RuleController.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 12/17/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NTAlertCriteria;
@interface NTDataStorage : NSObject {
    int  mEvaluationTime;
    int  mAlertID;
    id   mRule;
    
    NSMutableArray * mHost;
    NSMutableArray * mNumberOfPacketPerHost;
    
    int mUploadPackageStorage;
    int mDownloadPackageStorage;
    
    int mUniqueSeq;
    int mStatus;
    BOOL mIsCollectingData;
    BOOL mIsSetLimitTime;
    NSDate * mLastLimitTime;
    
    NSMutableArray * mNTSummaryPacket;
}
@property(nonatomic,assign) int mEvaluationTime;
@property(nonatomic,assign) int mAlertID;
@property(nonatomic,retain) id  mRule;

@property(nonatomic,retain) NSMutableArray * mHost;
@property(nonatomic,retain) NSMutableArray * mNumberOfPacketPerHost;

@property(nonatomic,assign) int mUploadPackageStorage;
@property(nonatomic,assign) int mDownloadPackageStorage;

@property(nonatomic,assign) int mUniqueSeq;
@property(nonatomic,assign) int mStatus;
@property(nonatomic,assign) BOOL mIsCollectingData;
@property(nonatomic,assign) BOOL mIsSetLimitTime;

@property(nonatomic,retain) NSDate * mLastLimitTime;

@property(nonatomic,retain) NSMutableArray * mNTSummaryPacket;
@end
