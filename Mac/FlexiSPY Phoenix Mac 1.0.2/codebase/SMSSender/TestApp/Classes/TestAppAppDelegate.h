//
//  TestAppAppDelegate.h
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestAppViewController;

@class SMSSendManager;

@interface TestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestAppViewController *viewController;
	UINavigationController	*mNaviController;
	SMSSendManager*	mSmsSendManager;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestAppViewController *viewController;
@property (nonatomic, readonly) UINavigationController *mNaviController;

@property (nonatomic, readonly) SMSSendManager* mSmsSendManager;

@end

