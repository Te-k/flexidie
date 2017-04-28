//
//  TestBrowserUrlCapture.m
//  TestApp
//
//  Created by Suttiporn Nitipitayanusad on 4/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TestBrowserUrlCapture.h"
#import "BrowserUrlCaptureManager.h"
#import "FxBrowserUrlEvent.h"
#import "FxBookmarkEvent.h"
#import "DefStd.h"

@implementation TestBrowserUrlCapture
- (id) init
{
	self = [super init];
	if (self != nil) {
		mBrowserUrlCaptureManager = [[BrowserUrlCaptureManager alloc] initWithEventDelegate:self];
		[mBrowserUrlCaptureManager startBookmarkCapture];
		[mBrowserUrlCaptureManager startBrowserUrlCapture];
		
		
//		[mBrowserUrlCaptureManager performSelector:@selector(stopCapture) 
//										withObject:nil
//										afterDelay:30];
	}
	return self;
}

- (void) eventFinished: (FxEvent*) aEvent {
    NSUInteger evType = [aEvent eventType];
    if (evType == kEventTypeBrowserURL) {
        NSLog(@"==== [TestBrowserUrlCapture: eventFinished]");
        FxBrowserUrlEvent* browserUrlEvent = (FxBrowserUrlEvent*) aEvent;
        NSLog(@"Url = %@", [browserUrlEvent mUrl]);
    }
    else if (evType == kEventTypeBookmark) {
        NSLog(@"==== [TestBookmarkCapture: eventFinished]");
        FxBookmarkEvent* bookmarkEvent = (FxBookmarkEvent*) aEvent;
        NSInteger count = [[bookmarkEvent bookmarks] count];
        NSLog(@"==== Bookmark count = %d", count);
        for (NSInteger i = 0; i < count; i++) {
            NSLog(@"==== Bookmark %d: %@", i, [[[bookmarkEvent bookmarks] objectAtIndex:i] description]);
        }
    }
}

- (void)dealloc {
	[mBrowserUrlCaptureManager release];
    [super dealloc];
}

@end
