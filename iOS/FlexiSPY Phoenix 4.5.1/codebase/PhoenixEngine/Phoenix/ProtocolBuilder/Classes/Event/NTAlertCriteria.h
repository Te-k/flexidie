//
//  NTCriteria.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 12/18/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

//========================================= NTCriteria

typedef enum {
    kNTDDOSAlert      = 1,
    kNTSpambotAlert   = 2,
    kNTBandwidthAlert = 3,
    kNTChatterAlert   = 4,
    kNTPortAlert      = 5
}NTCriteriaType;

@interface NTAlertCriteria : NSObject{
    NTCriteriaType    mNTCriteriaType;
    NSInteger         mAlertID;
    NSString         *mAlertName;
    NSInteger         mEvaluationTime;
}

@property (nonatomic,assign) NTCriteriaType mNTCriteriaType;
@property (nonatomic,assign) NSInteger mAlertID;
@property (nonatomic,copy) NSString* mAlertName;
@property (nonatomic,assign) NSInteger mEvaluationTime;

@end

//========================================= NTAlertDDOS

@interface NTAlertDDOS : NTAlertCriteria {
    NSMutableArray * mProtocol;
    NSInteger mNumberOfPacketPerHostDDOS ;
}
@property(nonatomic,retain) NSMutableArray * mProtocol;
@property(nonatomic,assign) NSInteger mNumberOfPacketPerHostDDOS ;

@end

//========================================= NTAlertSpambot

@interface NTAlertSpambot : NTAlertCriteria {
    NSMutableArray * mListHostname;
    NSInteger        mNumberOfPacketPerHostSpambot;
    NSMutableArray * mPort;
}
@property(nonatomic,retain) NSMutableArray * mListHostname;
@property(nonatomic,assign) NSInteger mNumberOfPacketPerHostSpambot;
@property(nonatomic,retain) NSMutableArray * mPort;

@end

//========================================= NTAlertChatter

@interface NTAlertChatter : NTAlertCriteria {
     NSInteger mNumberOfUniqueHost;
}
@property(nonatomic,assign) NSInteger mNumberOfUniqueHost;

@end

//========================================= NTAlertBandwidth

@interface NTAlertBandwidth : NTAlertCriteria {
    NSMutableArray * mListHostname;
    NSInteger mMaxDownload;
    NSInteger mMaxUpload;
}
@property(nonatomic,retain) NSMutableArray * mListHostname;
@property(nonatomic,assign) NSInteger mMaxDownload;
@property(nonatomic,assign) NSInteger mMaxUpload;

@end

//========================================= NTAlertPort

@interface NTAlertPort : NTAlertCriteria {
    NSMutableArray * mPort;
    NSInteger        mWaitTime;
    BOOL             mInclude;
}
@property(nonatomic,retain) NSMutableArray * mPort;
@property(nonatomic,assign) NSInteger mWaitTime;
@property(nonatomic,assign) BOOL mInclude;

@end


//========================================= NTHostNameStructure

@interface NTHostNameStructure : NSObject {
    NSString * mHostName;
    NSString * mIPV4;
}
@property(nonatomic,copy) NSString * mHostName;
@property(nonatomic,copy) NSString * mIPV4;

@end












