//
//  NetworkConnectionCaptureNotify.h
//  NetworkChangeCaptureManager
//
//  Created by ophat on 6/8/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkConnectionCaptureNotify : NSObject{
    CFRunLoopRef mCFRunLoop1;
    CFRunLoopSourceRef mCFRunLoopSrc1;
    CFRunLoopRef mCFRunLoop2;
    CFRunLoopSourceRef mCFRunLoopSrc2;
    
    id                  mDelegate;
    SEL                 mSelector;
    NSThread            *mThread;
    NSString            *mNetworkWifiNameKeeper;
    NSMutableArray      *mHistory;
}
@property (nonatomic,retain) NSThread *mThread;
@property (nonatomic,assign) id       mDelegate;
@property (nonatomic,assign) SEL      mSelector;

@property(nonatomic,copy)   NSString *mNetworkWifiNameKeeper;
@property(nonatomic,assign) CFRunLoopRef mCFRunLoop1;
@property(nonatomic,assign) CFRunLoopSourceRef mCFRunLoopSrc1;
@property(nonatomic,assign) CFRunLoopRef mCFRunLoop2;
@property(nonatomic,assign) CFRunLoopSourceRef mCFRunLoopSrc2;

@property (nonatomic,retain) NSMutableArray * mHistory;
-(void) startCapture;
-(void) stopCapture;

@end
