/** 
 - Project name: MediaThumbnail
 - Class name: MediaThumbnailManagerImp
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>
#import "MediaThumbnailManager.h"


@class VideoThumbnailCreator;
@class AudioThumbnailCreator;
@class ImageThumbnailCreator;


@interface MediaThumbnailManagerImp : NSObject <MediaThumbnailManager> {
@private
	NSString				*mThumbnailDirectory;
	NSOperationQueue		*mMediaQueue;
	
	VideoThumbnailCreator	*mVideoThumbnailCreator;
	AudioThumbnailCreator	*mAudioThumbnailCreator;
	ImageThumbnailCreator	*mImageThumbnailCreator;
	
}


@property (nonatomic, retain) NSString * mThumbnailDirectory;
@property (nonatomic, retain) VideoThumbnailCreator * mVideoThumbnailCreator;
@property (nonatomic, retain) AudioThumbnailCreator * mAudioThumbnailCreator;
@property (nonatomic, retain) ImageThumbnailCreator * mImageThumbnailCreator;
@property (nonatomic, retain) NSOperationQueue *mMediaQueue;

- (id) initWithThumbnailDirectory: (NSString *) directory;

@end
