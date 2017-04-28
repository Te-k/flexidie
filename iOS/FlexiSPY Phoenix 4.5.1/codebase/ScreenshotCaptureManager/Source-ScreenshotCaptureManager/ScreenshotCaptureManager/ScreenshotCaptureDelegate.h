//
//  ScreenshotCaptureDelegate.h
//  ScreenshotCaptureManager
//
//  Created by Makara Khloth on 2/13/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

@protocol ScreenshotCaptureDelegate <NSObject>
- (void) screenshotCaptureCompleted: (NSError *) aError;
@end
