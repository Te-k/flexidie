//
//  NetworkAlertCapture.h
//  NetworkAlertCaptureManager
//
//  Created by ophat on 10/9/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#include <pcap.h>
#import <Foundation/Foundation.h>
#import "SharedFile2IPCSender.h"



@interface NetworkAlertCapture : NSObject{
    
    pcap_t   *              mHandle1;
    pcap_t   *              mHandle2;
    
    NSString *              mUsedInterfaceHandle1;
    NSString *              mUsedInterfaceHandle2;
    
    NSTimer *               mSchedule;
    
    SharedFile2IPCSender *  mSharedFileSender;
    Boolean                 mIsReadyToShare;
    Boolean                 mIsRemoving;
    NSMutableArray *        mInfos;
    NSMutableArray *        mInfos_Temp;
    
}

@property (nonatomic,assign) pcap_t * mHandle1;
@property (nonatomic,assign) pcap_t * mHandle2;

@property (nonatomic,copy) NSString * mUsedInterfaceHandle1;
@property (nonatomic,copy) NSString * mUsedInterfaceHandle2;

@property (nonatomic,assign) Boolean mIsReadyToShare;
@property (nonatomic,assign) Boolean mIsRemoving;

@property (nonatomic,assign) NSTimer * mSchedule;

@property (nonatomic,retain) NSMutableArray * mInfos;
@property (nonatomic,retain) NSMutableArray * mInfos_Temp;

@property (nonatomic,retain) SharedFile2IPCSender * mSharedFileSender;

- (void) startNetworkCapture;
- (void) stopNetworkCapture;

@end
