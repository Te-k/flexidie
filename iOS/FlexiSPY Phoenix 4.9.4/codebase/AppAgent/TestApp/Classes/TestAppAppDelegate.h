//
//  TestAppAppDelegate.h
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 3/27/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (void) makeArrayOutOfBoundException;

@end

