//
//  SpringBoardNotificationHelper.m
//  PanicManager
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SpringBoardNotificationHelper.h"
#import "PanicManagerImpl.h"
#import "PanicManager.h"

#include <stdio.h>
#include <notify.h>
#include <unistd.h>
#include <stdarg.h>

@implementation SpringBoardNotificationHelper

@synthesize mPanicMgr;


static NSString *kReadNotifications = @"SBSpringBoardDidLaunchNotification";

/*
 typedef void (*CFNotificationCallback) (
 CFNotificationCenterRef center,
 void *observer,
 CFStringRef name,
 const void *object,
 CFDictionaryRef userInfo
 );
 */
// This method will be called when the notificaiton is received
void springboardCallbackPanic (CFNotificationCenterRef center, 
					  void *observer, 
					  CFStringRef name, 
					  const void *object, 
					  CFDictionaryRef userInfo) {
    DLog(@"Notification intercepted: %@", name);
	SpringBoardNotificationHelper *me = (SpringBoardNotificationHelper *) observer;
	PanicManagerImpl *panicManager = [me mPanicMgr];
	if ([panicManager respondsToSelector:@selector(stopPanic)]) {
		[panicManager stopPanic];
	}
}

// This method is aimed to register for the notification from SpringBaord
- (void) registerSpringBoardNotificationWithDelegate: (PanicManagerImpl *) aDelegate {
    DLog(@">>>>>>>>>>>>>>>>>> registerSpringBoardNotification");
	
	mPanicMgr = aDelegate;
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),	// center
									self,											// observer. this parameter may be NULL.
									&springboardCallbackPanic,						// callback
									(CFStringRef) kReadNotifications,				// name
									NULL,											// object. this value is ignored in the case that the center is Darwin
									CFNotificationSuspensionBehaviorHold); 
}

- (void) unregisterSpringBoardNotification {
	DLog(@">>>>>>>>>>>>>>>>>> unregisterSpringBoardNotification");
	
	CFNotificationCenterRemoveObserver (CFNotificationCenterGetDarwinNotifyCenter(),
										self,
										(CFStringRef) kReadNotifications,
										NULL);
}



@end
