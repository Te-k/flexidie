//
//  SecurityToolTestAppAppDelegate.h
//  SecurityToolTestApp
//
//  Created by admin on 10/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SecurityToolTestAppViewController;

@interface SecurityToolTestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SecurityToolTestAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SecurityToolTestAppViewController *viewController;

@end

