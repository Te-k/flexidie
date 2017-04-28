//
//  USBFileTransferDetection.h
//  USBFileTransferManager
//
//  Created by ophat on 2/4/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Cocoa/Cocoa.h>

@interface USBFileTransferDetection : NSObject{
    FSEventStreamRef    mStreamRef;
    CFRunLoopRef        mCurrentRunloopRef;
    NSMutableArray      *mPathsToWatch;
    NSString            *mRecentFilePath;
    unsigned long long  mRecentFileSize;
    
    id  mDelegate;
    SEL mSelector;
}

@property(nonatomic,retain) NSMutableArray *mPathsToWatch;
@property(nonatomic,assign) FSEventStreamRef mStreamRef;
@property(nonatomic,assign) CFRunLoopRef mCurrentRunloopRef;
@property(nonatomic,copy) NSString *mRecentFilePath;
@property(nonatomic,assign) unsigned long long mRecentFileSize;

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

-(void)startCapture;
-(void)stopCapture;

@end
