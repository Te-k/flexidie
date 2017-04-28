//
//  BrowserUploadFilePanelMonitor.h
//  InternetFileTransferManager
//
//  Created by Makara Khloth on 10/20/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

@class NSEvent;

@interface BrowserUploadFilePanelMonitor : NSObject {
@private
    AXUIElementRef mBrowserProcess;
    AXObserverRef mBrowserObserver;
    
    id mDelegate;
    SEL mSelector;
    
    BOOL mIsPanelAppear;
    
    NSEvent *mDraggedEventMonitor;
    NSUInteger mPBCountOfRecentChange;
    
    NSString *mTargetBundleIdentifier;
}

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

@property (nonatomic, assign) BOOL mIsPanelAppear;
@property (nonatomic, retain) NSEvent *mDraggedEventMonitor;
@property (assign) NSUInteger mPBCountOfRecentChange;

@property (nonatomic, copy) NSString *mTargetBundleIdentifier;

- (id)initWithTargetBundleIdentifier:(NSString *)aBundleIdentifier;

- (void) startMonitor;
- (void) stopMonitor;

@end
