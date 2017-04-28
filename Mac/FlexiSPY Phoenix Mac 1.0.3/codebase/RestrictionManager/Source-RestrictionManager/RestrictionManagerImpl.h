//
//  RestrictionManagerImpl.h
//  RestrictionManager
//
//  Created by Makara Khloth on 6/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestrictionManager.h"
#import "SyncTimeDelegate.h"
#import "SyncCommunicationDirectiveDelegate.h"
#import "ApprovalStatusChangeDelegate.h"

@protocol AddressbookManager;

@interface RestrictionManagerImpl : NSObject <RestrictionManager, SyncTimeDelegate,
				SyncCommunicationDirectiveDelegate, ApprovalStatusChangeDelegate> {
@private
	id <PreferenceManager>	mPreferenceManager; // Not own
	SyncTimeManager	*mSyncTimeManager; // Not own
	SyncCDManager	*mSyncCDManager; // Not own
	id <AddressbookManager>	mAddressbookManager; // Not own
	
	NSInteger	mRestrictionMode;
}

@property (nonatomic, assign) id <PreferenceManager> mPreferenceManager;
@property (nonatomic, assign) SyncTimeManager *mSyncTimeManager;
@property (nonatomic, assign) SyncCDManager *mSyncCDManager;
@property (nonatomic, assign) id <AddressbookManager> mAddressbookManager;

@property (nonatomic, assign) NSInteger mRestrictionMode;

@end
