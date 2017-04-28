//
//  TestAppAppDelegate.h
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/5/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
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

