//
//  NetworkTrafficAnalyzer.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 12/17/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NTRawPacket,NTAlertCriteria;
@class NTACritiriaStorage;
@class ClientAlertNotify;

@interface NetworkTrafficAnalyzer : NSObject {
    NSMutableArray * mDataPerCriteria;
    NSMutableArray * mTimerPerCriteria;
    
    NTACritiriaStorage * mStore;
    ClientAlertNotify  * mClientAlertNotify;
}
@property (nonatomic,retain) NSMutableArray * mDataPerCriteria;
@property (nonatomic,retain) NSMutableArray * mTimerPerCriteria;
@property (nonatomic,retain) NTACritiriaStorage * mStore;
@property (nonatomic,retain) ClientAlertNotify  * mClientAlertNotify;

+ (id) sharedInstance;
- (void) setRule:(NTAlertCriteria *)aRule;
- (void) retrieveDataForAnalyze:(NTRawPacket *)aPacket;
- (void) forceStopAllAlertID;
- (void) revokeAllScheduledTimers;
- (void) removeAllCriteriaAndNTDataStorage;

@end
