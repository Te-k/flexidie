//
//  SMSCaptureTestAppAppDelegate.h
//  SMSCaptureTestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 11/28/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMSCaptureTestAppViewController;

@interface SMSCaptureTestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SMSCaptureTestAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SMSCaptureTestAppViewController *viewController;

@end

