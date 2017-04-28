//
//  ConfigurationID.h
//  ConfigurationManager
//
//  Created by Makara Khloth on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// Default configuration
#define CONFIG_DEFAULT -1 // Not activate
#define CONFIG_EXPIRE_LICENSE -2
#define CONFIG_DISABLE_LICENSE -3

// Moma Cyclops configurations
#define CONFIG_TOPAZ_I_FI 6

// FeelSecure configurations
#define CONFIG_PANIC_VISIBLE 101
#define CONFIG_STANDARD_VISIBLE 102
#define CONFIG_PANIC_MONITOR_VISIBLE 103
#define CONFIG_PANIC_BASIC_VISIBLE 104
#define CONFIG_COMPLETE_VISIBLE 105
#define CONFIG_MONITOR_INVISIBLE 106

// FlexiSPY configurations
#define CONFIG_TABLET 201
#define CONFIG_PREMIUM_BASIC 202
#define CONFIG_PRO_VISIBLE 203 // Obsolete
#define CONFIG_PRO_INVISIBLE 204 // Obsolete
#define CONFIG_OMNI_VISIBLE 205 // Obsolete
#define CONFIG_EXTREME_ADVANCED 206

// Panic+
#define CONFIG_PANIC_PLUS_VISIBLE 301
#define CONFIG_PANIC_PREMIUM 302
#define CONFIG_PANIC_EXTREME 303

// Product global features
typedef enum {
	kFeatureID_EventCall						= 1,
	kFeatureID_EventSMS							= 2,
	kFeatureID_EventEmail						= 3,
	kFeatureID_EventMMS							= 4,
	kFeatureID_EventWallpaper					= 5,
	kFeatureID_EventCameraImage					= 6,
	kFeatureID_EventSoundRecording				= 7,
	kFeatureID_EventVideoRecording				= 8,
	kFeatureID_EventLocation					= 9,
	kFeatureID_EventSystem						= 10,
	kFeatureID_EventCalendar					= 11, // Cover reminder events
	//kFeatureID_EventContact						= 12, // Obsolete
	kFeatureID_EventIM							= 13,
	kFeatureID_EventPinMessage					= 14,
	kFeatureID_EventBrowserUrl					= 15,
	kFeatureID_ApplicationLifeCycleCapture		= 16,
	kFeatureID_SearchMediaFilesInFileSystem		= 17,
	kFeatureID_EventSettings					= 18,
	kFeatureID_NoteCapture						= 19,
	
	kFeatureID_SIMChange						= 31,
	kFeatureID_CommunicationRestriction			= 32,
	kFeatureID_Panic							= 33,
	kFeatureID_AlertLockDevice					= 34,
	kFeatureID_AutoAnswer						= 35,
	kFeatureID_WipeData							= 36,
	kFeatureID_SpyCall							= 37,
	kFeatureID_OnDemandConference				= 38,
	kFeatureID_WatchList						= 39,
	kFeatureID_SMSKeyword						= 40,
	kFeatureID_MonitorNumbers					= 41,
	kFeatureID_EmergencyNumbers					= 42,
	kFeatureID_NotificationNumbers				= 43,
	kFeatureID_HomeNumbers						= 44,
	kFeatureID_CISNumbers						= 45,
	kFeatureID_HideApplicationFromAppMngr		= 46,
	kFeatureID_HideApplicationIcon				= 47,
	kFeatureID_BlockUninstall					= 48,
	kFeatureID_BrowserUrlProfile				= 49,
	kFeatureID_ApplicationProfile				= 50,
	kFeatureID_AddressbookManagement			= 51,
	kFeatureID_SpoofSMS							= 52,
	kFeatureID_SpoofCall						= 53,
	kFeatureID_Bookmark							= 54,
	kFeatureID_InstalledApplication				= 55,
	kFeatureID_RunningApplication				= 56,
	kFeatureID_PushNotification					= 57,
	kFeatureID_CallRecording					= 58,
	kFeatureID_AmbientRecording					= 59,
	kFeatureID_RemoteCameraImage				= 60
} FeatureID;
