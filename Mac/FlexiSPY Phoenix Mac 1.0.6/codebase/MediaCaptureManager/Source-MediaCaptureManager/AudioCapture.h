/**
 - Project name :  MediaCaptureManager
 - Class name   :  AudioCapture
 - Version      :  1.0  
 - Purpose      :  For MediaCaptureManager Component
 - Copy right   :  14/2/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MediaThumbnailDelegate.h"
#ifdef IOS_ENTERPRISE
#import "MediaThumbnailManager-E.h"
#else
#import "MediaThumbnailManager.h"
#endif
#import "EventDelegate.h"

@interface AudioCapture : NSObject <MediaThumbnailDelegate> {
	id <EventDelegate>	mEventDelegate;
	id <MediaThumbnailManager> mMediaThumbnailManager;
	NSMutableArray *mAudioCaptureQueue;
	BOOL mIsBusy;
}

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate 
	andMediaThumbnailManager: (id <MediaThumbnailManager>) aMediaThumbnailManager;

- (void) addPathToAudioQueue: (NSString *) aAudioPath;
- (void) processAudioCaptureQueue;
- (void) removeProcessedPathFromAudioCaptureQueue;

@end
