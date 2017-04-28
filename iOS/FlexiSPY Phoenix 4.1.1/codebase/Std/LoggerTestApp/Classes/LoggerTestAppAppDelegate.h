//
//  LoggerTestAppAppDelegate.h
//  LoggerTestApp
//
//  Created by Syam Sasidharan on 11/7/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoggerTestAppViewController;

@interface LoggerTestAppAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet LoggerTestAppViewController *viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) LoggerTestAppViewController *viewController;

@end

