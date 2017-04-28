//
//  ActivationAppDelegate.h
//  Activation
//
//  Created by Pichaya Srifar on 11/1/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivationViewController;

@interface ActivationAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ActivationViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ActivationViewController *viewController;

@end

