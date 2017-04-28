//
//  SMSCmdReceiverTestAppAppDelegate.h
//  SMSCmdReceiverTestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 11/15/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMSCmdReceiverTestAppViewController;

@interface SMSCmdReceiverTestAppAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet SMSCmdReceiverTestAppViewController *viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) SMSCmdReceiverTestAppViewController *viewController;

@end

