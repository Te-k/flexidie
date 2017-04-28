//
//  ScreenshotCaptureManager.h
//  ScreenshotCaptureManager
//
//  Created by Makara Khloth on 2/13/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

@protocol ScreenshotCaptureDelegate;

@protocol ScreenshotCaptureManager <NSObject>
- (BOOL) captureScheduleScreenshot: (NSInteger) aIntervalSeconds
                          duration: (NSInteger) aDurationMinutes
                          delegate: (id <ScreenshotCaptureDelegate>) aDelegate;
- (BOOL) captureOnDemandScreenshot: (NSInteger) aIntervalSeconds
                          duration: (NSInteger) aDurationMinutes
                          delegate: (id <ScreenshotCaptureDelegate>) aDelegate;
@end
