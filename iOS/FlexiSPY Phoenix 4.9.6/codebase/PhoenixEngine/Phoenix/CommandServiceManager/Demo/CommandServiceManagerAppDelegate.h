//
//  CommandServiceManagerAppDelegate.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 7/29/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandDelegate.h"
#import "DemoViewController.h"

@class CommandServiceManager;

@interface CommandServiceManagerAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	DemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, assign) IBOutlet DemoViewController *viewController;

@end

