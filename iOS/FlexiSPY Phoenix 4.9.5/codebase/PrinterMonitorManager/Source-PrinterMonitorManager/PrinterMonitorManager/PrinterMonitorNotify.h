//
//  PrinterMonitorNotify.h
//  PrinterMonitorManager
//
//  Created by ophat on 11/12/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrinterMonitorNotify : NSObject{
    FSEventStreamRef mStream;
    CFRunLoopRef mCurrentRunloopRef;
    
    NSMutableArray * mWatchlist;
    
    NSMutableArray * mJobID;
    NSMutableArray * mJobPath;
    NSMutableArray * mAppID;
    NSMutableArray * mAppName;
    
    NSMutableArray * mHistory;
    id  mDelegate;
    SEL mSelector;
}
@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

@property(nonatomic,assign) FSEventStreamRef mStream;
@property(nonatomic,assign) CFRunLoopRef mCurrentRunloopRef;
@property(nonatomic,retain) NSMutableArray * mWatchlist;

@property(nonatomic,retain) NSMutableArray * mJobID;
@property(nonatomic,retain) NSMutableArray * mJobPath;
@property(nonatomic,retain) NSMutableArray * mAppID;
@property(nonatomic,retain) NSMutableArray * mAppName;

@property(nonatomic,retain) NSMutableArray * mHistory;

-(void) startCapture;
-(void) stopCapture;

@end
