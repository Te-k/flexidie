//
//  TestPanicAppDelegate.h
//  TestPanic
//
//  Created by Dominique  Mayrand on 11/16/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestPanicViewController;

@interface TestPanicAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestPanicViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestPanicViewController *viewController;

@end

