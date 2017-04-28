/**
 - Project name :  MediaCaptureManager
 - Class name   :  VideoCapture
 - Version      :  1.0  
 - Purpose      :  For MediaCaptureManager Component
 - Copy right   :  14/2/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#ifdef IOS_ENTERPRISE
#import "MediaThumbnailManager-E.h"
#else
#import "MediaThumbnailManager.h"
#endif
#import "MediaThumbnailDelegate.h"
#import "EventDelegate.h"

@interface VideoCapture : NSObject <MediaThumbnailDelegate> {
	id <EventDelegate>	mEventDelegate;
	id <MediaThumbnailManager> mMediaThumbnailManager;
	NSMutableArray *mVideoCaptureQueue;
	BOOL mIsBusy;
}

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate 
	andMediaThumbnailManager: (id <MediaThumbnailManager>) aMediaThumbnailManager;

- (void) addPathToVideoQueue: (NSString *) aVideoPath;
- (void) processVideoCaptureQueue;
- (void) removeProcessedPathFromVideoCaptureQueue;

@end
