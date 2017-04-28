//
//  UIViewController+More.h
//  FeelSecure
//
//  Created by Makara Khloth on 8/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIViewController (More)
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
@end
