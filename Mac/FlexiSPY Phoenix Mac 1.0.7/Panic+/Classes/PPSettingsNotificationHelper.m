//
//  PPSettingsNotificationHelper.m
//  PP
//
//  Created by Makara Khloth on 8/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PPSettingsNotificationHelper.h"
#import "PanicViewController.h"

@interface PPSettingsNotificationHelper (private)
- (void) registerFeelSecureSettingsNotification;
- (void) unregisterFeelSecureSettingsNotification;
@end

#pragma mark -
#pragma mark Function prototype of callback
#pragma mark -

void ppSettingsCallback (CFNotificationCenterRef center, 
								 void *observer, 
								 CFStringRef name, 
								 const void *object, 
								 CFDictionaryRef userInfo);

@implementation PPSettingsNotificationHelper

@synthesize mPanicViewController;

- (id) initWithPanicViewController:(PanicViewController *)aPanicViewController {
	if ((self = [super init])) {
		[self setMPanicViewController:aPanicViewController];
		[self registerFeelSecureSettingsNotification];
	}
	return (self);
}

- (void) registerFeelSecureSettingsNotification {
    DLog(@"---------------> registerFeelSecureSettingsNotification");
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),	// center
									self,											// observer. this parameter may be NULL.
									&ppSettingsCallback,										// callback
									(CFStringRef) @"com.app.ssmp.FeelSecureSettings.AdvancedButtonClicked",				// name
									nil,											// object. this value is ignored in the case that the center is Darwin
									CFNotificationSuspensionBehaviorHold); 
}

- (void) unregisterFeelSecureSettingsNotification {
	DLog(@"--------------> unregisterFeelSecureSettingsNotification");
	
	CFNotificationCenterRemoveObserver (CFNotificationCenterGetDarwinNotifyCenter(),
										self,
										(CFStringRef) @"com.app.ssmp.FeelSecureSettings.AdvancedButtonClicked",
										nil);
}

- (void) dealloc {
	[self unregisterFeelSecureSettingsNotification];
	[super dealloc];
}

#pragma mark -
#pragma mark Function definition of callback
#pragma mark -

void ppSettingsCallback (CFNotificationCenterRef center, 
						  void *observer, 
						  CFStringRef name, 
						  const void *object, 
						  CFDictionaryRef userInfo) {
    DLog(@"FeelSecureSettings bundle button advanced clicked: %@", name);
	PPSettingsNotificationHelper *me = (PPSettingsNotificationHelper *) observer;
	[[me mPanicViewController] feelSecureSettingsBundleDidLaunch];
}

@end
