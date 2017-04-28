/**
 - Project name :  LocationManager Component
 - Class name   :  TestAppAppDelegate
 - Version      :  1.0  
 - Purpose      :  For LocationManager Component
 - Copy right   :  1/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <UIKit/UIKit.h>

@class TestAppViewController;

@interface TestAppAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet TestAppViewController *viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) TestAppViewController *viewController;

@end

