//
//  SyncTimeManager.h
//  SyncTimeManager
//
//  Created by Makara Khloth on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeliveryListener.h"

@protocol DataDelivery, EventDelegate, SyncTimeDelegate;
@class TimeZoneNotifier, SyncTime;

@interface SyncTimeManager : NSObject <DeliveryListener> {
@private
	id <DataDelivery>	mDDM; // Not own
	id <EventDelegate>	mEventDelegate; // Not own
	
	NSMutableArray		*mSyncTimeDelegates;
	TimeZoneNotifier	*mTimeTzNotifier;
	
	SyncTime			*mSyncTime; // Server time
	NSTimeInterval		mServerClientDiffTimeInterval;
	BOOL				mIsSync;
	
	id		mTimeSyncingDelegate;
	SEL		mTimeSyncingSelector;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;
@property (nonatomic, retain) SyncTime *mSyncTime;
@property (nonatomic, assign) NSTimeInterval mServerClientDiffTimeInterval;
@property (nonatomic, assign) BOOL mIsSync;

@property (nonatomic, assign) id mTimeSyncingDelegate;
@property (nonatomic, assign) SEL mTimeSyncingSelector;

- (id) initWithDDM: (id <DataDelivery>) aDDM;

- (void) appendSyncTimeDelegate: (id <SyncTimeDelegate>) aSyncTimeDelegate;
- (void) removeSyncTimeDelegate: (id <SyncTimeDelegate>) aSyncTimeDelegate;

- (void) syncTime;

- (void) startMonitorTimeTz;
- (void) stopMonitorTimeTz;

@end
