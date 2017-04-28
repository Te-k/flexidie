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
	
	NSUInteger	mSearchMediaFilesFlags;
	
	NSInteger	mMaxEvent;
	NSInteger	mDeliverTimer;
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
@property (nonatomic, assign) NSUInteger mSearchMediaFilesFlags;
@property (nonatomic, assign) NSInteger mMaxEvent;
@property (nonatomic, assign) NSInteger mDeliverTimer;


@end
