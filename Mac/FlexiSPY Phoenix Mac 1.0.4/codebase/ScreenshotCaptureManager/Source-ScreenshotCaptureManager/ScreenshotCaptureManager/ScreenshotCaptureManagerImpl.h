//
//  ScreenshotCaptureManagerImpl.h
//  ScreenshotCaptureManager
//
//  Created by Makara Khloth on 2/13/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ScreenshotCaptureManager.h"
#import "EventCapture.h"

@class ScreenshotFIDStore, ScreenshotTaker;

@interface ScreenshotCaptureManagerImpl : NSObject <EventCapture, ScreenshotCaptureManager> {
    id <EventDelegate> mEventDelegate;
    
    id <ScreenshotCaptureDelegate> mOnDemandScreenshotDelegate;
    id <ScreenshotCaptureDelegate> mScheduleScreenshotDelegate;
    
    ScreenshotFIDStore  *mScreenshotFIDStore;
    ScreenshotTaker     *mScreenshotTaker;
}

- (id) initWithScreenshotFolder: (NSString *) aScreenshotFolder;

@end
