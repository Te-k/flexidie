//
//  MailCaptureTestAppAppDelegate.h
//  MailCaptureTestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 1/9/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MailCaptureTestAppViewController;

@interface MailCaptureTestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MailCaptureTestAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MailCaptureTestAppViewController *viewController;

@end

