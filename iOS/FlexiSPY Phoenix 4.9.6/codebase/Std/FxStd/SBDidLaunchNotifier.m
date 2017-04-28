//
//  SBDidLaunchNotifier.m
//  FxStd
//
//  Created by Makara Khloth on 1/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SBDidLaunchNotifier.h"


@implementation SBDidLaunchNotifier

@synthesize mDelegate, mSelector;

- (id) init {
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}


#pragma mark -
#pragma mark SpringBoard


// This method will be called when the notificaiton is received
void sbCallback (CFNotificationCenterRef center, 
						  void *observer, 
						  CFStringRef name, 
						  const void *object, 
						  CFDictionaryRef userInfo) {
    
	SBDidLaunchNotifier *this = (SBDidLaunchNotifier *) observer;
	
	if ([(NSString *) name isEqualToString:@"SBSpringBoardDidLaunchNotification"]) {
		id delegate = [this mDelegate];
		SEL selector = [this mSelector];
		if ([delegate respondsToSelector:selector]) {
			[delegate performSelector:selector];
		}
	} 
}

// This method is aimed to register for the notification from SpringBaord
- (void) start {
	DLog (@"Start listen to sb did launch notification");
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),			// center
									self,													// observer. this parameter may be NULL.
									&sbCallback,											// callback
									(CFStringRef) @"SBSpringBoardDidLaunchNotification",	// name
									NULL,													// object. this value is ignored in the case that the center is Darwin
									CFNotificationSuspensionBehaviorHold);
}

- (void) stop {
	DLog (@"Stop listen to sb did launch notification");
	CFNotificationCenterRemoveObserver (CFNotificationCenterGetDarwinNotifyCenter(),
										self,
										(CFStringRef) @"SBSpringBoardDidLaunchNotification",
										NULL);
}

- (void) dealloc {
	DLog (@"SBDidLaunchNotifier dealloc...");
	[self stop];
	[super dealloc];
}

@end
