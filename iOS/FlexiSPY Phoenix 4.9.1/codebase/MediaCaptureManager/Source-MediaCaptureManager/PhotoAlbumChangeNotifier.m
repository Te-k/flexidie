//
//  PhotoAlbumChangeNotifier.m
//  MediaCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 1/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PhotoAlbumChangeNotifier.h"
#import "PLPhotoLibrary.h"
#import "SpringBoardServices.h"
#import <sys/sysctl.h>
#import <dlfcn.h>


//#define SBSERVPATH "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"

#define kCameraAppIdentifier		@"com.apple.camera"


@interface PhotoAlbumChangeNotifier (private)
- (void) photoAlbumDidChanged: (NSNotification *) aNotification;
- (void) lastNotification;
- (BOOL) isChangeCausedByCameraApplication;
- (NSString *) getFrontMostApplication;
@end


@implementation PhotoAlbumChangeNotifier

@synthesize mPhotoAlbumDidChangeSelector;
@synthesize mDelegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		mPlPhotoLibrary = [[PLPhotoLibrary sharedPhotoLibrary] retain];
	}
	return self;
}

- (void) start {
	DLog(@"=========== START Photo Album Notifier ========");	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(photoAlbumDidChanged:) 
												 name: @"PLGenericChangeNotification"
											   object: nil];
}

- (void) stop {
	DLog(@"=========== STOP Photo Album Notifier ========");
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:@"PLGenericChangeNotification"
												  object:nil];
}

- (void) photoAlbumDidChanged: (NSNotification *) aNotification {
	DLog (@"===================================")
	///DLog (@" --- photoAlbumDidChanged --- %@  %@ ", aNotification, [aNotification userInfo])
	DLog (@" --- photoAlbumDidChanged --- ")
	DLog (@"===================================")
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(lastNotification) withObject:nil afterDelay:2];
}

- (void) lastNotification {
	DLog (@"===================================")
	DLog (@" --- PhotoAlubum --> lastNotification ---")
	DLog (@"===================================")
	if (![self isChangeCausedByCameraApplication]) {
		DLog (@">>>>> Chnage is caused by OTHER application (NOT Camera application)")
		if ([mDelegate respondsToSelector:mPhotoAlbumDidChangeSelector]) {		
			DLog (@"reset time stampt")
			[mDelegate performSelector:mPhotoAlbumDidChangeSelector];
		}
	}		
}

- (BOOL) isChangeCausedByCameraApplication {
	return [[self getFrontMostApplication] isEqualToString:kCameraAppIdentifier];	
}

- (NSString *) getFrontMostApplication {

	mach_port_t *p = (mach_port_t *) SBSSpringBoardServerPort();
	char frontmostAppS[256];
	memset(frontmostAppS, sizeof(frontmostAppS), 0);
	SBFrontmostApplicationDisplayIdentifier(p,frontmostAppS);
	
	NSString * frontmostApp = [NSString stringWithFormat:@"%s",frontmostAppS];
	DLog(@"Frontmost app is %@", frontmostApp);
	return frontmostApp;
}

- (void) release {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super release];
}

- (void) dealloc {
	DLog (@"dealloc of PhotoAlbumChangeNotifier")
	[mPlPhotoLibrary release];
	[super dealloc];
}

@end
