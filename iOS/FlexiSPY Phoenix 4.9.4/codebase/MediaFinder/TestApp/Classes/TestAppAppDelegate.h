//
//  TestAppAppDelegate.h
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestAppViewController;

@class MediaFinder;

@interface TestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestAppViewController *viewController;
	
@private
	MediaFinder *mMediaFinder;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestAppViewController *viewController;

@end

