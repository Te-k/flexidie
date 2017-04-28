//
//  FirefoxUploadFilePanelMonitor.h
//  InternetFileTransferManager
//
//  Created by Makara Khloth on 10/20/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

@class NSEvent;

@interface FirefoxUploadFilePanelMonitor : NSObject {
@private
    AXUIElementRef mFirefoxProcess;
    AXObserverRef mFirefoxObserver;
    
    id mDelegate;
    SEL mSelector;
    
    BOOL mIsPanelAppear;
    
    NSEvent *mDraggedEventMonitor;
    NSUInteger mPBCountOfRecentChange;
}

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

@property (nonatomic, assign) BOOL mIsPanelAppear;
@property (nonatomic, retain) NSEvent *mDraggedEventMonitor;
@property (assign) NSUInteger mPBCountOfRecentChange;

- (void) startMonitor;
- (void) stopMonitor;

@end
