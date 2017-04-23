//
//  NetworkAlertCapture.h
//  NetworkAlertCaptureManager
//
//  Created by ophat on 10/9/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#include <pcap.h>
#import <Foundation/Foundation.h>

@interface NetworkAlertCapture : NSObject{
    pcap_t   *              mHandle1;
    pcap_t   *              mHandle2;
    
    NSString *              mUsedInterfaceHandle1;
    NSString *              mUsedInterfaceHandle2;
    
    NSTimer *               mSchedule;
    
    Boolean                 mIsRemoving;
    NSMutableArray *        mInfos;
    NSString *              mSavePath;
}

@property (nonatomic,assign) pcap_t * mHandle1;
@property (nonatomic,assign) pcap_t * mHandle2;

@property (nonatomic,copy) NSString * mUsedInterfaceHandle1;
@property (nonatomic,copy) NSString * mUsedInterfaceHandle2;

@property (nonatomic,assign) NSTimer * mSchedule;

@property (atomic,retain) NSMutableArray * mInfos;

@property (nonatomic,copy) NSString * mSavePath;

- (void) startNetworkCapture;
- (void) stopNetworkCapture;

@end
