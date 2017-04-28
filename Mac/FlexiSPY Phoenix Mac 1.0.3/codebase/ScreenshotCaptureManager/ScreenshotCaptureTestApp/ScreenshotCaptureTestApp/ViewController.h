//
//  ViewController.h
//  ScreenshotCaptureTestApp
//
//  Created by Makara Khloth on 2/13/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ScreenshotCaptureManagerImpl;

@interface ViewController : NSViewController {
    ScreenshotCaptureManagerImpl *mScreenshotCaptureManager;
}

@end

