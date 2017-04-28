//
//  MailAppCapture.h
//  MailCaptureManagerForMac
//
//  Created by ophat on 5/27/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MailAppCapture : NSObject{
    FSEventStreamRef      mStream;
    CFRunLoopRef          mCurrentRunloopRef;
    
    NSMutableArray      * mHistory;
    NSMutableArray      * mWatchlist;
    NSString            * mCurrentUserName;
    NSString            * mAttachPath;
    SEL                   mSelector;
    id                    mDelegate;
    NSThread            * mThread;

}

@property(nonatomic,assign) FSEventStreamRef mStream;
@property(nonatomic,assign) CFRunLoopRef mCurrentRunloopRef;
@property(nonatomic,retain) NSMutableArray * mWatchlist;
@property(nonatomic,retain) NSMutableArray * mHistory;
@property(nonatomic,copy)   NSString * mCurrentUserName;
@property(nonatomic,copy)   NSString * mAttachPath;
@property(nonatomic,assign) id mDelegate;
@property(nonatomic,assign) SEL mSelector;
@property(nonatomic,retain) NSThread * mThread;

-(void) startCapture;
-(void) stopCapture;

@end
