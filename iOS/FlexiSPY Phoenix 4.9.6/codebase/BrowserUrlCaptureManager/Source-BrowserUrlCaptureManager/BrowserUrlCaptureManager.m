//
//  BrowserUrlCaptureManager.m
//  BrowserUrlCaptureManager
//
//  Created by Suttiporn Nitipitayanusad on 4/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BrowserUrlCaptureManager.h"
#import "DefStd.h"
#import "EventCenter.h"
#import "BookmarkCapture.h"
#import "BrowserUrlCapture.h"

@implementation BrowserUrlCaptureManager

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate {
	if (self = [super init]) {
		mBookmarkCapture = [[BookmarkCapture alloc] initWithEventDelegate: aEventDelegate];
		mBrowserCapture = [[BrowserUrlCapture alloc] initWithEventDelegate: aEventDelegate];
	}
	return self;
}

- (void) startBookmarkCapture {
	[mBookmarkCapture startCapture];
}

- (void) stopBookmarkCapture {
	[mBookmarkCapture stopCapture];
}

- (void) startBrowserUrlCapture {
	[mBrowserCapture startCapture];
}

- (void) stopBrowserUrlCapture {
	[mBrowserCapture stopCapture];
}

- (void) dealloc {
	[mBookmarkCapture release];
	[mBrowserCapture release];
	[super dealloc];
}

@end
