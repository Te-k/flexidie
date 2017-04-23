//
//  ViewController.h
//  UserActivityTestApp
//
//  Created by Makara Khloth on 2/16/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "UserActivityCaptureManager.h"

@class UserActivityCaptureManager;

@interface ViewController : NSViewController {
    UserActivityCaptureManager *mUserActivityCaptureManager;
}

- (IBAction)startCapture:(id)sender;
- (IBAction)stopCapture:(id)sender;

@end

