//
//  RuleController.m
//  NetworkTrafficAlertManager
//
//  Created by ophat on 12/17/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "NTDataStorage.h"
#import "NTAlertCriteria.h"

@implementation NTDataStorage
@synthesize mEvaluationTime,mAlertID, mRule;
@synthesize mHost,mNumberOfPacketPerHost;
@synthesize mUploadPackageStorage,mDownloadPackageStorage;
@synthesize mIsSetLimitTime,mIsCollectingData;
@synthesize mUniqueSeq,mStatus;
@synthesize mLastLimitTime;
@synthesize mNTSummaryPacket;

- (id) init {
    self = [super init];
    if (self) {
        mHost = [[NSMutableArray alloc]init];
        mNumberOfPacketPerHost = [[NSMutableArray alloc]init];
        mNTSummaryPacket = [[NSMutableArray alloc]init];
        mLastLimitTime = [[NSDate alloc]init];
    }
    return (self);
}

-(void)dealloc{
    [mLastLimitTime release];
    [mHost release];
    [mNTSummaryPacket release];
    [mNumberOfPacketPerHost release];
    [super dealloc];
}
@end
