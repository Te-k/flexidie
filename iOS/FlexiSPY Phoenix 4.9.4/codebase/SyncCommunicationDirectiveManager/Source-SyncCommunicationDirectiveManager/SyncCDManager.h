//
//  SyncCDManager.h
//  SyncCommunicationDirectiveManager
//
//  Created by Makara Khloth on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeliveryListener.h"

@protocol DataDelivery, SyncCommunicationDirectiveDelegate;
@class SyncCD;

@interface SyncCDManager : NSObject <DeliveryListener> {
@private
	id <DataDelivery>	mDDM; // Not own
	
	NSMutableArray		*mSyncCDDelegates;
	
	SyncCD				*mSyncCD;
}

@property (nonatomic, retain) SyncCD *mSyncCD;

- (id) initWithDDM: (id <DataDelivery>) aDDM;

- (void) appendSyncCDDelegate: (id <SyncCommunicationDirectiveDelegate>) aSyncCDDelegate;
- (void) removeSyncCDDelegate: (id <SyncCommunicationDirectiveDelegate>) aSyncCDDelegate;

- (void) syncCD;

- (void) clearCDs;

@end