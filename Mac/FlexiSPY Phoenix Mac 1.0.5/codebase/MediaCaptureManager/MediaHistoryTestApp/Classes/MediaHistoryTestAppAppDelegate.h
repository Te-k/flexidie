//
//  MediaHistoryTestAppAppDelegate.h
//  MediaHistoryTestApp
//
//  Created by Benjawan Tanarattanakorn on 3/15/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatabaseViewController;


@interface MediaHistoryTestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	DatabaseViewController *mDBVC;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet DatabaseViewController *mDBVC;

@end

