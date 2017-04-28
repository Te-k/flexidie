//
//  SyncTimeManager.m
//  SyncTimeManager
//
//  Created by Makara Khloth on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncTimeManager.h"
#import "TimeZoneNotifier.h"
#import "SyncTime.h"
#import "SyncTimeUtils.h"
#import "SyncTimeDelegate.h"
#import "EventDelegate.h"
#import "DataDelivery.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"
#import "GetTime.h"
#import "FxSystemEvent.h"
#import "GetTimeResponse.h"
#import "DateTimeFormat.h"

@interface SyncTimeManager (private)
- (void) timeTzChanged;
- (void) deliverGetTime;
- (DeliveryRequest *) getTimeRequest;
- (void) prerelease;
@end

@implementation SyncTimeManager

@synthesize mEventDelegate;
@synthesize mSyncTime;
@synthesize mServerClientDiffTimeInterval;
@synthesize mIsSync;

@synthesize mTimeSyncingDelegate;
@synthesize mTimeSyncingSelector;

- (id) initWithDDM: (id <DataDelivery>) aDDM {
	if ((self = [super init])) {
		mDDM = aDDM;
		mSyncTimeDelegates = [[NSMutableArray alloc] init];
		mTimeTzNotifier = [[TimeZoneNotifier alloc] init];
		[mTimeTzNotifier setMDelegate:self];
		[mTimeTzNotifier setMSelector:@selector(timeTzChanged)];
		if ([mDDM isRequestPendingForCaller:kDDC_SyncTimeManager]) {
			[mDDM registerCaller:kDDC_SyncTimeManager withListener:self];
		}
	}
	return (self);
}

- (void) appendSyncTimeDelegate: (id <SyncTimeDelegate>) aSyncTimeDelegate {
	BOOL alreadyAdded = NO;
	for (id <SyncTimeDelegate> delegate in mSyncTimeDelegates) {
		if (delegate == aSyncTimeDelegate) {
			alreadyAdded = YES;
			break;
		}
	}
	if (!alreadyAdded && aSyncTimeDelegate) {
		[mSyncTimeDelegates addObject:aSyncTimeDelegate];
	}
	//DLog (@"aSyncTimeDelegate = %@ is already added = %d", aSyncTimeDelegate, alreadyAdded);
}

- (void) removeSyncTimeDelegate: (id <SyncTimeDelegate>) aSyncTimeDelegate {
	[mSyncTimeDelegates removeObject:aSyncTimeDelegate];
}

- (void) syncTime {
	//DLog (@"Begin to sync the time with server")
	[self deliverGetTime];
	if ([mTimeSyncingDelegate respondsToSelector:mTimeSyncingSelector]) {
		[mTimeSyncingDelegate performSelector:mTimeSyncingSelector withObject:nil];
	}
}

- (void) startMonitorTimeTz {
	[mTimeTzNotifier start];
}

- (void) stopMonitorTimeTz {
	[self setMIsSync:NO];
	[mTimeTzNotifier stop];
}

- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog (@"============== SYNCED TIME REQUEST FINISHED ==================")
	DLog (@"status code %d", [aResponse mStatusCode])
	DLog (@"status message %@", [aResponse mStatusMessage])	
	DLog (@"echo command code %d", [aResponse mEchoCommandCode])
	DLog (@"============== ============================= ==================")
	
	if ([aResponse mSuccess]) {
		[self setMIsSync:YES];
		GetTimeResponse *getTimeResponse = (GetTimeResponse *)[aResponse mCSMReponse];
		DLog (@"(getTimeResponse) Time = %@, Time zone = %@, Representation = %d", [getTimeResponse currentMobileTime],
			  [getTimeResponse timeZone], [getTimeResponse representation]);
		
		SyncTime *syncTime = [[[SyncTime alloc] init] autorelease];
		[syncTime setMTime:[getTimeResponse currentMobileTime]]; // Server time
		[syncTime setMTimeZone:[getTimeResponse timeZone]];
		[syncTime setMTimeZoneRep:(TimeZoneSyncRepresentation)[getTimeResponse representation]];
		
		[self setMSyncTime:syncTime];
		//DLog (@"New server time after sync = %@", syncTime);
	} else {
		[self setMIsSync:NO];
		// Requirement: retry every one minute if fail
		[self performSelector:@selector(syncTime)
				   withObject:nil
				   afterDelay:60];
	}

	// For preventing caller remove itself with syncTimeSuccess or syncTimeError call back
	NSArray *delegates = [NSArray arrayWithArray:mSyncTimeDelegates];
	DLog(@"SyncTime delegates %@", delegates)
	
	// Inform its delegate	
	//for (id <SyncTimeDelegate> delegate in mSyncTimeDelegates) {
	for (id <SyncTimeDelegate> delegate in delegates) {
		if ([aResponse mSuccess] && [delegate respondsToSelector:@selector(syncTimeSuccess)]) {
			DLog (@"Sync time success")
			[delegate performSelector:@selector(syncTimeSuccess)];
		}
		if (![aResponse mSuccess] && [delegate respondsToSelector:@selector(syncTimeError:error:)]) {
			DLog (@"Sync time fail")
			NSError *error = [NSError errorWithDomain:@"Sync time error" code:[aResponse mStatusCode] userInfo:nil];
			[delegate performSelector:@selector(syncTimeError:error:)
						   withObject:[NSNumber numberWithInt:[aResponse mDDMStatus]]
						   withObject:error];
		}		
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	//
}

- (void) timeTzChanged {
	DLog(@"Time or time zone have changed")
	[self setMIsSync:NO];
	[self syncTime];
}

- (void) deliverGetTime {
	DeliveryRequest* request = [self getTimeRequest];
	if (![mDDM isRequestIsPending:request]) {
		GetTime* getTime = [[GetTime alloc] init];
		[request setMCommandCode:[getTime getCommand]];
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:getTime];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
		[getTime release];
	}
}

- (DeliveryRequest *) getTimeRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_SyncTimeManager];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMMaxRetry:0];
    [request setMEDPType:kEDPTypeGetTime];
    [request setMRetryTimeout:30];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return (request);
}

- (void) prerelease {
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(syncTime)
											   object:nil];
}

- (void) release {
	[self prerelease];
	[super release];
}

- (void) dealloc {
	[self stopMonitorTimeTz];
	[mSyncTimeDelegates release];
	[mTimeTzNotifier release];
	[mSyncTime release];
	[super dealloc];
}

@end
