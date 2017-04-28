//
//  TestPhoneInfo3AppDelegate.h
//  TestPhoneInfo3
//
//  Created by Dominique  Mayrand on 11/4/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestPhoneInfo3ViewController;

@interface TestPhoneInfo3AppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet TestPhoneInfo3ViewController *viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) TestPhoneInfo3ViewController *viewController;

@end

