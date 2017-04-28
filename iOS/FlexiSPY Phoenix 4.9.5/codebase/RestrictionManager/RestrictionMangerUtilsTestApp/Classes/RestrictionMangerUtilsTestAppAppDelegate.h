//
//  RestrictionMangerUtilsTestAppAppDelegate.h
//  RestrictionMangerUtilsTestApp
//
//  Created by Syam Sasidharan on 6/18/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RestrictionMangerUtilsTestAppViewController;
@class RestrictionCriteriaChecker;

@interface RestrictionMangerUtilsTestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RestrictionMangerUtilsTestAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RestrictionMangerUtilsTestAppViewController *viewController;

@end

