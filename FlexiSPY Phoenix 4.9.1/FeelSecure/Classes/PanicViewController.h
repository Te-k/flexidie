//
//  PanicViewController.h
//  FeelSecure
//
//  Created by Makara Khloth on 8/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppUIConnection.h"
#import "MessagePortIPCReader.h"

// Features
@class CameraCaptureManager;
@class CameraCaptureManagerUIUtils;
@class FeelSecureSettingsNotificationHelper;

@class AudioPlayer;

@interface PanicViewController : UIViewController <AppUIConnectionDelegate, UIAlertViewDelegate, MessagePortIPCDelegate> {
@private
	UIView		*mOverlayView;
	UIImageView	*mFeelSecureLogo;
	UIImageView	*mRadarView;
	UILabel		*mSendingLocLabel;
	UILabel		*mServerSyncTimeLabel;
	UILabel		*mBlackOutLabel;
	
	// Features
	CameraCaptureManager	*mCameraCaptureManager;
	CameraCaptureManagerUIUtils	*mCCMUtils;
	//FeelSecureSettingsNotificationHelper	*mFeelSecureSettingsNotificationHelper;
	AudioPlayer				*mAudioPlayer;
	MessagePortIPCReader	*mMessageReader;
	
	NSTimeInterval	mXDiffTimeInterval;
	BOOL			mPanicStart;
	
	
	UIAlertView		*mAlert;
}

@property (nonatomic, readonly) CameraCaptureManager *mCameraCaptureManager;
@property (nonatomic, readonly) CameraCaptureManagerUIUtils *mCCMUtils;
//@property (nonatomic, readonly) FeelSecureSettingsNotificationHelper *mFeelSecureSettingsNotificationHelper;

@property (nonatomic, retain) UIView *mOverlayView;
@property (nonatomic, retain) UIImageView *mFeelSecureLogo;
@property (nonatomic, retain) UIImageView *mRadarView;
@property (nonatomic, retain) UILabel *mSendingLocLabel;
@property (nonatomic, retain) UILabel *mServerSyncTimeLabel;
@property (nonatomic, retain) UILabel *mBlackOutLabel;

@property (nonatomic, assign) NSTimeInterval mXDiffTimeInterval;

- (void) cameraDidStartCapture;
- (void) cameraDidStopCapture;

- (void) feelSecureSettingsBundleDidLaunch;

@end
