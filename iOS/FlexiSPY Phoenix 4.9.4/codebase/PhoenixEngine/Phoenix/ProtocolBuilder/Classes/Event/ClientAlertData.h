//
//  AlertData.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/7/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    kUnknown    = 0,
    kDDOS_Bot   = 1,
    kSPAM_Bot   = 2,
    kBandwidth  = 3,
    kChatter    = 4,
    kPort       = 5
}AlertDataType;

@class EvaluationFrame;

@interface ClientAlertData : NSObject{
    AlertDataType   mClientAlertDataType;
    NSInteger       mClientAlertCriteriaID;
    NSInteger       mSequenceNum;
    NSInteger       mClientAlertStatus;
    NSString      * mClientAlertTime;
    NSString      * mClientAlertTimeZone;
    EvaluationFrame *mEvaluationFrame;
}

@property (nonatomic, assign) AlertDataType    mClientAlertDataType;
@property (nonatomic, assign) NSInteger   mClientAlertCriteriaID;
@property (nonatomic, assign) NSInteger   mSequenceNum;
@property (nonatomic, assign) NSInteger   mClientAlertStatus;
@property (nonatomic, copy)   NSString  * mClientAlertTime;
@property (nonatomic, copy)   NSString  * mClientAlertTimeZone;
@property (nonatomic, retain) EvaluationFrame  * mEvaluationFrame;

@end
