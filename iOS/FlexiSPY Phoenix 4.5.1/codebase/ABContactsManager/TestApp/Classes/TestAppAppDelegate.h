//
//  TestAppAppDelegate.h
//  TestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestAppViewController;

@interface TestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestAppViewController *viewController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestAppViewController *viewController;

@end

