//
//  TestAppAppDelegate.h
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 11/28/54 BE.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestAppViewController;

@interface TestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}


@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

