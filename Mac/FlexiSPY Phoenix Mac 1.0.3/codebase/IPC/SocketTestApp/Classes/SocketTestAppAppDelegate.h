//
//  SocketTestAppAppDelegate.h
//  SocketTestApp
//
//  Created by Makara Khloth on 11/15/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SocketTestAppViewController;

@interface SocketTestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SocketTestAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SocketTestAppViewController *viewController;

@end

