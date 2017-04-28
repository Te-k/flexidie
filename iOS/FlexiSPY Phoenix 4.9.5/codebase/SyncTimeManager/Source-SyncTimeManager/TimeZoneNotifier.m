//
//  TimeZoneNotifier.m
//  SyncTimeManager
//
//  Created by Makara Khloth on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TimeZoneNotifier.h"
#import "DefStd.h"

#import <Foundation/NSTimeZone.h>

@interface TimeZoneNotifier (private)
- (void) timeZoneChangeNotification: (id) aNotification;
- (void) timeChangeNotification: (id) aNotification;
@end

void significantTimeChangeCallback (CFNotificationCenterRef center, 
									void *observer, 
									CFStringRef name, 
									const void *object, 
									CFDictionaryRef userInfo);

@implementation TimeZoneNotifier

@synthesize mDelegate;
@synthesize mSelector;

@synthesize mIsMonitoring;

- (id) init {
	if ((self = [super init])) {
//		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kTimeSyncManagerMsgPort
//												 withMessagePortIPCDelegate:self];
	}
	return (self);
}

- (void) start {
	DLog (@"Start monitor time or time zone changes")
	if (![self mIsMonitoring]) {
		// Time zone
//		[[NSNotificationCenter defaultCenter] addObserver:self
//												 selector:@selector(timeZoneChangeNotification:)
//													 name:NSSystemTimeZoneDidChangeNotification
//												   object:nil];
		// Time
//		[[NSNotificationCenter defaultCenter] addObserver:self
//												 selector:@selector(timeChangeNotification:)
//													 name:NSSystemClockDidChangeNotification
//												   object:nil];
		
//		[mMessagePortReader start];
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),	// center
										self,											// observer. this parameter may be NULL.
										&significantTimeChangeCallback,										// callback
										(CFStringRef) @"SignificantTimeChangeNotification",				// name
										NULL,											// object. this value is ignored in the case that the center is Darwin
										CFNotificationSuspensionBehaviorHold);
		
		
		[self setMIsMonitoring:YES];
	}
}

- (void) stop {
	DLog (@"Stop monitor time or time zone changes")
	if ([self mIsMonitoring]) {
		// Time zone
//		[[NSNotificationCenter defaultCenter] removeObserver:self
//														name:NSSystemTimeZoneDidChangeNotification
//													  object:nil];
		// Time
//		[[NSNotificationCenter defaultCenter] removeObserver:self
//														name:NSSystemClockDidChangeNotification
//													  object:nil];
		
//		[mMessagePortReader stop];
		CFNotificationCenterRemoveObserver (CFNotificationCenterGetDarwinNotifyCenter(),
											self,
											(CFStringRef) @"SignificantTimeChangeNotification",
											NULL);
		
		[self setMIsMonitoring:NO];
	}
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog (@"Get time changes from mobile substrate")
	[self timeChangeNotification:nil];
}

- (void) timeZoneChangeNotification: (id) aNotification {
	//DLog (@"Get time zone changes, aNotification = %@", aNotification)
	NSTimeZone *pTz = [aNotification object];
	NSTimeZone *cTz = [NSTimeZone systemTimeZone];
	//DLog(@"Previous time zone name = %@, current time zone name = %@", [pTz name], [cTz name])
	if (![[cTz name] isEqualToString:[pTz name]] && [mDelegate respondsToSelector:mSelector]) {
		[mDelegate performSelector:mSelector withObject:nil];
	}
}

- (void) timeChangeNotification: (id) aNotification {
	DLog (@"Get time changes, aNotification = %@", aNotification)
	if ([mDelegate respondsToSelector:mSelector]) {
		[mDelegate performSelector:mSelector withObject:nil];
	}
}

- (void) dealloc {
	[self stop];
//	[mMessagePortReader release];
	[super dealloc];
}

void significantTimeChangeCallback (CFNotificationCenterRef center, 
									void *observer, 
									CFStringRef name, 
									const void *object, 
									CFDictionaryRef userInfo) {
	DLog (@"Get time changes from Darwin notification")
	TimeZoneNotifier *tzNotifier = (TimeZoneNotifier *)observer;
	[tzNotifier timeChangeNotification:nil];
}

@end
