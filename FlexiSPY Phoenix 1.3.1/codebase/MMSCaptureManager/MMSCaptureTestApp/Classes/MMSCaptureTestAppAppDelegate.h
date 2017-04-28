//
//  MMSCaptureTestAppAppDelegate.h
//  MMSCaptureTestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 1/31/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMSCaptureTestAppViewController;

@interface MMSCaptureTestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MMSCaptureTestAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MMSCaptureTestAppViewController *viewController;

@end

