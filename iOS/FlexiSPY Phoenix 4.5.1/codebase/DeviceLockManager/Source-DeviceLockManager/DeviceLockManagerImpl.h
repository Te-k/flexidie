//
//  DeviceLockManagerImpl.h
//  DeviceLockManager
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeviceLockManager.h"
#import "EventDelegate.h"
#import "AudioPlayer.h"
#import "LocationManagerDelegate.h"

@class DeviceLockOption;
@class LocationManagerImpl;
@protocol PreferenceManager;
@protocol EventDelegate;
@class DeviceLockUtils;
@class AudioPlayer;
@protocol SMSSender;
@protocol AudioPlayerDelegate;




@interface DeviceLockManagerImpl : NSObject <DeviceLockManager, EventDelegate, AudioPlayerDelegate, UndetermineLocationDelegate> {
@private
	id <PreferenceManager>			mPrefManager;			// this can be set via property, or setPreferences: method
	DeviceLockOption				*mDeviceLockOption;		// this can be set via property, or setDeviceLockOption: method
	DeviceLockUtils					*mDeviceLockUtils;		// for communicate with MS

	id <EventDelegate>				mEventDelegate;			// not own
	
	LocationManagerImpl				*mLocationManager;		// own
	AudioPlayer						*mAudioPlayer;			// own
	id <SMSSender>					mSMSSender;				// not own
	NSInteger						mAlertLockCounter;

	// for testing purpose
	//BOOL							mIsLock;
}


@property (nonatomic, retain) DeviceLockOption *mDeviceLockOption;
@property (nonatomic, assign) id <PreferenceManager> mPrefManager;
@property (nonatomic, assign) id <EventDelegate> mEventDelegate;
@property (nonatomic, assign) id <SMSSender> mSMSSender;

// redefine method to conform to the protocol DeviceLockManager
- (void) lockDevice;
- (void) unlockDevice;
- (BOOL) isDeviceLock;
- (void) setDeviceLockOption: (DeviceLockOption *) aDeviceLockOption;
- (void) setPreferences: (id <PreferenceManager>) aPrefManager;

@end
