/**
 - Project name :  AmbientRecordingManager Component
 - Class name   :  AmbientRecordingManagerImpl
 - Version      :  1.0  
 - Purpose      :  Ambient record manager
 - Copy right   :  29/11/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */


#import <Foundation/Foundation.h>

#import "AmbientRecordingManager.h"
#import "MediaThumbnailDelegate.h"


@class MediaThumbnailManagerImp;
@class AmbientRecorder;


@interface AmbientRecordingManagerImpl : NSObject <AmbientRecordingManager, MediaThumbnailDelegate> {
@private
	id <EventDelegate>				mEventDelegate;
	id <AmbientRecordingDelegate>	mAmbientRecordingDelegate;
	MediaThumbnailManagerImp		*mMediaThumbnailManagerImp;			// retain
	AmbientRecorder					*mAmbientRecorder;					// retain
	NSString						*mOutputDirectory;					// retain
	NSError							*mAmbientRecordingError;			// retain
	
	BOOL							mIsCreatingThumbnail;
}

//@property (nonatomic, assign) id <AmbientRecordingDelegate> mAmbientRecordingDelegate;

- (id)		initWithEventDelegate: (id <EventDelegate>) aEventDelegate outputPath: (NSString *) aOutputDirectory;

- (void)	ambientRecordCompleted: (NSDictionary *) aRecordingResult;

- (void) prerelease;

@end
