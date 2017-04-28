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
		//
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
		//
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
		//
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
		//
		kEventTypeRemoteCameraImage				= 31,
		kEventTypeRemoteCameraVideo				= 32,
		kEventTypeVoIP							= 33,
		kEventTypeKeyLog						= 34,
        kEventTypePageVisited                   = 35,
        kEventTypePassword                      = 36,
        kEventTypeUsbConnection                 = 37,
        kEventTypeFileTransfer                  = 38,
        kEventTypeLogon                         = 39,
        
        kEventTypeAppUsage                      = 40,
        kEventTypeEmailMacOS                    = 41,
        kEventTypeIMMacOS                       = 42,
        kEventTypeScreenRecordSnapshot          = 43,
        kEventTypeFileActivity                  = 44,
        kEventTypeNetworkTraffic                = 45,
        kEventTypeNetworkConnectionMacOS        = 46,
        kEventTypePrintJob                      = 47,
        kEventTypeAppScreenShot                 = 48,
		kEventTypeMaxEventType
	} FxEventType;

typedef enum
	{
		kEventDirectionUnknown		= 0,
		kEventDirectionIn			= 1,
		kEventDirectionOut			= 2,
		kEventDirectionMissedCall	= 3,
		kEventDirectionLocalIM		= 4
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
		kSystemEventTypePushCmdReply				= 22,
        kSystemEventTypeMediaNotFound               = 23,
        kSystemEventTypeSecurity                    = 24,
        kSystemEventTypeCallRecording               = 25,
        kSystemEventTypePasswordGrabber             = 26,
        kSystemEventTypeAmbientRecording            = 27
	} FxSystemEventType;

typedef enum
	{
		kGPSTechUnknown			= 0,
		kGPSTechCellInfo		= 1,
		kGPSTechIntegrated		= 2,
		kGPSTechAssisted		= 3,
		kGPSTechBluetooth		= 4,
		kGPSTechNetworkBased	= 5,
		kGPSTechWifi			= 6,
		kGPSTechCellular		= 7
	} FxGPSTechType;

typedef enum
	{
		kGPSCallingModuleCoreTrigger		= 1,
		kGPSCallingModulePanic				= 2,
		kGPSCallingModuleAlert				= 3,
		kGPSCallingModuleRemoteCommand		= 4,
		kGPSCallingModuleGeoStamping		= 5
	} FxGPSCallingModule;

typedef enum
	{
		kGPSProviderUnknown	= 0,
		kGPSProviderGoogle	= 1
	} FxGPSProvider;

typedef enum {
	kIMServiceUnknown			= 0,
	//
	kIMServiceBBM				= 1,
	kIMServiceWhatsApp			= 2,
	kIMServiceGoogleTalk		= 3,
	kIMServiceYahooMessenger	= 4,
	kIMServiceSkype				= 5,
	kIMServiceiMessage			= 6,
	kIMServiceLINE				= 7,
	kIMServiceFacebook			= 8,
	kIMServiceAIM				= 9,
	kIMServiceICQ				= 10,
	//
	kIMServiceWindowLiveMessenger	= 11,
	kIMServiceTencentQQ				= 12,
	kIMServiceJabber				= 13,
	kIMServiceOviByNokia			= 14,
	kIMServiceTigerText				= 15,
	kIMServiceViber					= 16,
	kIMServiceChatOn				= 17,
	kIMServiceTango					= 18,
	kIMServiceWeChat				= 19,
	kIMServiceKIKMessenger			= 20,
	//
	kIMServiceVoxer					= 21,
	kIMServiceeCubieMessenger		= 22,
	kIMServiceCamfrog				= 23,
	kIMServicePaltalk				= 24,
	kIMServiceHyves					= 25,
	kIMServiceMXit					= 26,
	kIMServiceIMVU					= 27,
	kIMServiceIBMLotusSametime		= 28,
	kIMServiceGizmo5				= 29,
	kIMServiceiChat					= 30,
    kIMServiceSnapchat				= 31,
    kIMServiceGoogleHangouts        = 32,
    kIMServiceSlingshot             = 33,
    kIMServiceTrillian              = 34,
    kIMServiceTelegram              = 35,
    kIMServiceTinder                = 36,
    kIMServiceInstagram             = 37
} FxIMServiceID;

typedef enum {
	kIMMessageNone			= 0,
	kIMMessageText			= 1,
	kIMMessageSticker		= 8,
	kIMMessageContact		= 16,
	kIMMessageShareLocation	= 32,
    kIMMessageHidden        = 64
} FxIMMessageRepresentation;

typedef enum {
	kIMClientUnknown			= 0,
	//
	kIMClientBBM				= 1,
	kIMClientWhatsApp			= 2,
	kIMClientGoogleTalk			= 3,
	kIMClientYahooMessenger		= 4,
	kIMClientSkype				= 5,
	kIMClientSkypeForIpad		= 6,
	kIMClientiMessage			= 7,
	kIMClientLINE				= 8,
	kIMClientFacebook			= 9,
	kIMClientFacebookMessenger	= 10,
	//
	kIMClientAIM				= 11,
	kIMClientICQ				= 12,
	kIMClientWindowLiveMessenger= 13,
	kIMClientTencentQQ			= 14,
	kIMClientJabber				= 15,
	kIMClientOviByNokia			= 16,
	kIMClientTigerText			= 17,
	kIMClientViber				= 18,
	kIMClientChatOn				= 19,
	kIMClientTango				= 20,
	//
	kIMClientWeChat				= 21,
	kIMClientKIKMessenger		= 22,
	kIMClientVoxer				= 23,
	kIMClienteCubieMessenger	= 24,
	kIMClientCamfrog			= 25,
	kIMClientPaltalk			= 26,
	kIMClientHyves				= 27,
	kIMClientMXit				= 28,
	kIMClientIMVU				= 29,
	kIMClientIBMLotusSametime	= 30,
	//
	kIMClientGizmo5				= 31,
	kIMClientiChat				= 32,
    kIMSnapchat                 = 33,
    kIMGoogleHangouts           = 34
} FxIMClientID;

typedef enum {
    kNetworkTypeUnknown         = 0,
    kNetworkTypeCellular        = 1,
    kNetworkTypeWired           = 2,
    kNetworkTypeWifi            = 3,
    kNetworkTypeBluetooth       = 4,
    kNetworkTypeUSB             = 5
} FxNetworkType;
