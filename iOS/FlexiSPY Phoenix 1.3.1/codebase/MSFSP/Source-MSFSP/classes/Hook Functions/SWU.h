//
//  SW.h
//  MSFSP
//
//  Created by Makara Khloth on 3/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PrefsSUTableView.h"
#import "SBSoftwareUpdateController.h"

#pragma mark -
#pragma mark SpringBoard
#pragma mark -

// Cancel to timer which does force update
HOOK(SBSoftwareUpdateController, _showForcedInstallAlert,void){
	DLog(@"=============== Remove SBSoftwareUpdateController and Cancel All ExistingScheduledForcedInstallAlerts");
	[self _resetAndCancelExistingScheduledForcedInstallAlerts];
}

// Battery below 50%
HOOK(SBSoftwareUpdateController, _handleInstallError$,void,id arg1){
	DLog(@"=============== Remove SBSoftwareUpdateController _handleInstallError");
	//[self _resetAndCancelExistingScheduledForcedInstallAlerts];
}

HOOK(SpringBoard, applicationDidFinishLaunching$, void, UIApplication *app) {
    CALL_ORIG(SpringBoard, applicationDidFinishLaunching$, app);
	DLog(@"Congratulations, you've hooked SpringBoard!");
	
	NSString *plistPreferencesFile = @"/var/mobile/Library/Preferences/com.apple.Preferences.plist";
	NSMutableDictionary *plistPreferences = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPreferencesFile];
	[plistPreferences setValue:[NSNumber numberWithBool:NO] forKey:@"kBadgedForSoftwareUpdateJumpOnceKey"];
	[plistPreferences setValue:[NSNumber numberWithBool:NO] forKey:@"kBadgedForSoftwareUpdateKey"];
	[plistPreferences writeToFile:plistPreferencesFile atomically:YES];
	[plistPreferences release];
}

#pragma mark -
#pragma mark Preferences
#pragma mark -

// Remove install view (User Settings -> General -> Software Update)
HOOK(PrefsSUTableView, setSUState$,void,int arg1){
	int condition = 2; // meaning it's up to date
	CALL_ORIG(PrefsSUTableView,setSUState$,condition);
	for (UIView *view in [self subviews]) {
		if (![view isKindOfClass:[UILabel class]]) {
			DLog(@"=============== Remove Installation View!!!!");
			[view removeFromSuperview];
		}
	}
}

// Remove install view (User bring Software Update view from background)
HOOK(PrefsSUTableView, layoutSubviews,void){
	for (UIView *view in [self subviews]) {
		if (![view isKindOfClass:[UILabel class]]) {
			DLog(@"=============== Remove Installation View!!!!");
			[view removeFromSuperview];
		}
	}
	CALL_ORIG(PrefsSUTableView, layoutSubviews);
}