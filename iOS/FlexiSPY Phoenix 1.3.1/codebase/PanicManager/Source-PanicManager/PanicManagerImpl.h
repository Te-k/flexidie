//
//  PanicManagerImpl.h
//  PanicManager
//
//  Created by Makara Khloth on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PanicManager.h"
#import "PanicButtonDelegate.h"
#import "EventDelegate.h"
#import "LocationManagerDelegate.h"
#import "AudioPlayer.h"

@protocol TelephonyNotificationManager, PreferenceManager, LocationManager, SMSSender;
@class LocationManagerImpl, CameraCaptureManager, PanicOption, AudioPlayer, CameraCaptureManagerDUtils, SpringBoardNotificationHelper;

@interface PanicManagerImpl : NSObject <PanicManager, PanicButtonDelegate, EventDelegate, UndetermineLocationDelegate, AudioPlayerDelegate> {
@private
	id <EventDelegate>		mEventDelegate;								// Not own
	id <TelephonyNotificationManager>	mTelephonyNotificationManager;	// Not own
	id <PreferenceManager>	mPreferenceManager;							// Not own
	id <SMSSender>			mSMSSender;									// Not own
	LocationManagerImpl		*mLocationManager;
	CameraCaptureManager	*mCameraCaptureManager;						// Not own
	AudioPlayer				*mAudioPlayer;								// Not own
	CameraCaptureManagerDUtils	*mCCMDUtils;							// Not own
	
	PanicOption		*mPanicOption;
	PanicMode		mPanicMode;
	NSInteger		mPanicCounter;
	
	BOOL			mIsPanic;		// keep status if the panic is started or stopped.
	BOOL			mIsPanicCameraOn;
	
	SpringBoardNotificationHelper *mSbnHelper;
}

@property (nonatomic, assign) id <EventDelegate> mEventDelegate;
@property (nonatomic, assign) id <TelephonyNotificationManager> mTelephonyNotificationManager;
@property (nonatomic, assign) id <PreferenceManager> mPreferenceManager;
@property (nonatomic, assign) id <SMSSender> mSMSSender;
@property (nonatomic, readonly) id <LocationManager> mLocationManager;
@property (nonatomic, assign) CameraCaptureManager *mCameraCaptureManager;
@property (nonatomic, readonly) AudioPlayer *mAudioPlayer;
@property (nonatomic, assign) CameraCaptureManagerDUtils *mCCMDUtils;

@property (nonatomic, retain) PanicOption *mPanicOption;
@property (nonatomic, assign) PanicMode mPanicMode;

+ (void) clearPanicStatus;

@end
