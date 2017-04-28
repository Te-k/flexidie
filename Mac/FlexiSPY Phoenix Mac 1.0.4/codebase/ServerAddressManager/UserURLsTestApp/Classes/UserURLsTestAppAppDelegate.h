//
//  UserURLsTestAppAppDelegate.h
//  UserURLsTestApp
//
//  Created by Benjawan Tanarattanakorn on 12/20/54 BE.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserURLsTestAppViewController;

@interface UserURLsTestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UserURLsTestAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UserURLsTestAppViewController *viewController;

@end

