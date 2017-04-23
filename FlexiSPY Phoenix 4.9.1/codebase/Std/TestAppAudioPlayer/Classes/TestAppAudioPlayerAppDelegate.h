//
//  TestAppAudioPlayerAppDelegate.h
//  TestAppAudioPlayer
//
//  Created by Benjawan Tanarattanakorn on 8/20/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestAppAudioPlayerViewController;

@interface TestAppAudioPlayerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestAppAudioPlayerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestAppAudioPlayerViewController *viewController;

@end

