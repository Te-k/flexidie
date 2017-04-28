//
//  ScreenshotTaker.h
//  ScreenshotCaptureManager
//
//  Created by Makara Khloth on 2/13/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenshotTaker : NSObject {
    id mDelegate;
    SEL mSelector;
    
    NSThread *mThreadA;
    NSRunLoop *mRunLoopOfScheduleThread;
    
    NSString *mScreenshotFolder;
    
    BOOL mLockScreen;
}

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

@property (readonly) NSThread* mThreadA;

@property (retain) NSString *mScreenshotFolder;

@property (assign) BOOL mLockScreen;

@property (assign) NSRunLoop *mRunLoopOfScheduleThread;

- (id) initWithScreenshotFolder: (NSString *) aScreenshotFolder;

- (void) takeScreenshot: (NSInteger) aInterval
               duration: (NSInteger) aDuration
                frameID: (NSUInteger) aFrameID
                 module: (NSInteger) aModule;
- (void) stopTakeScheduleScreenshot;

@end
