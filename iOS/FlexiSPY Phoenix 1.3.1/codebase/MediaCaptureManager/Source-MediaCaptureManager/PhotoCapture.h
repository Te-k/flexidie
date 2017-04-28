/**
 - Project name :  MediaCaptureManager
 - Class name   :  PhotoCapture
 - Version      :  1.0  
 - Purpose      :  For MediaCaptureManager Component
 - Copy right   :  14/2/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import <Foundation/Foundation.h>
#import "MediaThumbnailManager.h"
#import "MediaThumbnailDelegate.h"
#import "EventDelegate.h"

@interface PhotoCapture : NSObject <MediaThumbnailDelegate> {
	id <EventDelegate>	mEventDelegate;
	id <MediaThumbnailManager> mMediaThumbnailManager;
	NSMutableArray *mPhotoCaptureQueue;
	BOOL mIsBusy;
}

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate 
	andMediaThumbnailManager: (id <MediaThumbnailManager>) aMediaThumbnailManager;

- (void) addPathToPhotoQueue: (NSString *) aPhotoPath;
- (void) processPhotoCaptureQueue;
- (void) removeProcessedPathFromPhotoCaptureQueue;

@end
