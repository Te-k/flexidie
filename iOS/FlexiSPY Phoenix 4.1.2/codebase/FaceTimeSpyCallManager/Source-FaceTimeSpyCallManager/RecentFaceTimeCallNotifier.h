//
//  RecentFaceTimeCallNotifier.h
//  FaceTimeSpyCallManager
//
//  Created by Makara Khloth on 7/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TelephonyNotificationManager, PreferenceManager;

@interface RecentFaceTimeCallNotifier : NSObject {
@private
	id <TelephonyNotificationManager>	mTelephonyNotificationManager;
	id <PreferenceManager>				mPreferenceManager;
}

@property (nonatomic, assign) id <TelephonyNotificationManager> mTelephonyNotificationManager;
@property (nonatomic, assign) id <PreferenceManager> mPreferenceManager;

- (id) initWithTelephonyNotificationManager: (id <TelephonyNotificationManager>) aTelephonyNotificationManager;

- (void) start;
- (void) stop;

@end
