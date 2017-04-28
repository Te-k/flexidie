//
//  MultiThreadTestAppAppDelegate.h
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 10/10/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MultiThreadTestAppViewController;

@interface MultiThreadTestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MultiThreadTestAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MultiThreadTestAppViewController *viewController;

@end

