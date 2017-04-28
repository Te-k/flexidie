//
//  MediaCaptureTestAppAppDelegate.h
//  MediaCaptureTestApp
//
//  Created by Prasad Malekudiyi Balakrishn on 2/9/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MediaCaptureTestAppViewController;

@interface MediaCaptureTestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MediaCaptureTestAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MediaCaptureTestAppViewController *viewController;

@end

