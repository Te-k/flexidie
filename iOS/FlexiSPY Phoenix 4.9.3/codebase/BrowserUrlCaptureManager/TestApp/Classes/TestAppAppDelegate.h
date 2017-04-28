//
//  TestAppAppDelegate.h
//  TestApp
//
//  Created by Suttiporn Nitipitayanusad on 4/27/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventCenter.h"

@class BrowserUrlCaptureManager;
@class IMessageCaptureManager;

@interface TestAppAppDelegate : NSObject <UIApplicationDelegate, EventDelegate> {
    UIWindow *window;
	UITextView *mTextView;
	BrowserUrlCaptureManager *mBrowserUrlCaptureManager;
	IMessageCaptureManager *mIMessageCaptureManager;
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITextView *mTextView;


@end

