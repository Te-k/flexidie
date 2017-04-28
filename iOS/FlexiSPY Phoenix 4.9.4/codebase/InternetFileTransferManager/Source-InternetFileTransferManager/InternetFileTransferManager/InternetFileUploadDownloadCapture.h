//
//  InternetFileUploadDownloadCapture.h
//  InternetFileTransferManager
//
//  Created by ophat on 9/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class FirefoxGetInfo;

@interface InternetFileUploadDownloadCapture : NSObject{
    NSThread            * mThread;
    FSEventStreamRef      mStream;
    CFRunLoopRef          mCurrentRunloopRef;
    NSMutableArray      * mWatchlist;
    NSString            * watchPath;
    id  mDelegate;
    SEL mSelector;
}
@property (nonatomic, retain) NSThread *mThread;
@property (nonatomic, assign) FSEventStreamRef mStream;
@property (nonatomic, assign) CFRunLoopRef mCurrentRunloopRef;
@property (nonatomic, retain) NSMutableArray * mWatchlist;
@property (nonatomic, copy)   NSString * watchPath;
@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;


-(id)initWithWatchPath:(NSString *)aPath;
-(void)startCapture;
-(void)stopCapture;

@end
