//
//  FileActivityNotify.h
//  FileActivityCaptureManager
//
//  Created by ophat on 9/22/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface FileActivityNotify : NSObject {
    NSThread * mThread;
    FSEventStreamRef mStream;
    CFRunLoopRef mCurrentRunloopRef;
    
    NSMutableArray * mWatchlist;
    NSMutableArray * mExcludePath;
    NSMutableArray * mAction;
    
    NSString * mCurrentUserName;
    NSMutableArray * mHistory;
    id  mDelegate;
    SEL mSelector;
}
@property(nonatomic,retain) NSThread * mThread;
@property(nonatomic,assign) FSEventStreamRef mStream;
@property(nonatomic,assign) CFRunLoopRef mCurrentRunloopRef;
@property(nonatomic,retain) NSMutableArray * mWatchlist;
@property(atomic,retain) NSMutableArray * mHistory;
@property(atomic,retain) NSMutableArray * mExcludePath;
@property(atomic,retain) NSMutableArray * mAction;
@property(nonatomic,copy) NSString * mCurrentUserName;
@property(nonatomic, assign) id mDelegate;
@property(nonatomic, assign) SEL mSelector;

-(void) startCapture;
-(void) stopCapture;

@end
