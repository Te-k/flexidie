//
//  WallpaperChangedNotifier.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 1/3/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "WallpaperChangedNotifier.h"
#import "MediaUtils.h"


static WallpaperChangedNotifier *_wpChangedNotifier	= nil;

@implementation WallpaperChangedNotifier


+ (id) sharedInstance {
	if (_wpChangedNotifier == nil)
		_wpChangedNotifier = [[WallpaperChangedNotifier alloc] init];	
	DLog (@">> WallpaperChangedNotifier sharedInstance created !!!!")
	return (_wpChangedNotifier);
}

- (void) wallpaperDidChange: (NSNotification *) notification {
	DLog (@"!!!!!!!!!!!!		wallpaperDidChange	!!!!!!!!!!!!	%@", notification)
	if ([[notification name] isEqualToString:@"SBWallpaperDidChangeNotification"]) {
		MediaUtils *mediaUtils = [[MediaUtils alloc] init];
		[mediaUtils parallelCheckWallpaperiOS7];
		[mediaUtils release];								
	}
}
- (void) registerWallpaperChangedNotification {
	DLog (@"******************** registerWallpaperChangedNotification ************************")
	[[NSNotificationCenter defaultCenter] addObserver:self	
											 selector:@selector(wallpaperDidChange:) 
												 name:@"SBWallpaperDidChangeNotification"
											   object:nil];	
}

- (void) unregisterWallpaperChangedNotification {
	DLog (@"******************** UnregisterWallpaperChangedNotification ************************")
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) dealloc {
	[super dealloc];
	
	DLog (@">> WallpaperChangedNotifier dealloc")
	[self unregisterWallpaperChangedNotification];
}
@end
