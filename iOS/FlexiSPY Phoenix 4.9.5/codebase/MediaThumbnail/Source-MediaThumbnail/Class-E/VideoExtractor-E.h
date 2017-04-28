/** 
 - Project name: MediaThumbnail
 - Class name: VideoExtractor
 - Version: 1.0
 - Purpose: 
 - Copy right: 22/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class VideoThumbnailCreator;
@class AVAssetImageGenerator;

@interface VideoExtractor : NSObject {
@private
	PHAsset				*mInputAsset;				// own
	NSString				*mOutputPath;				// own
	AVAssetImageGenerator	*mAVAssetImageGenerator;	// needed to be instance variable
	
	VideoThumbnailCreator	*mVideoThumbnailCreator;
	
}

@property (nonatomic, copy) PHAsset *mInputAsset;
@property (nonatomic, copy) NSString *mOutputPath;
@property (nonatomic, readonly, assign) VideoThumbnailCreator *mVideoThumbnailCreator; // property is 'assign' because the creator will live longer than the operation

- (id) initWithInputAsset: (PHAsset *) aInputAsset
			  outputPath: (NSString *) aOutputPath
   videoThumbnailCreator: (VideoThumbnailCreator *) aVideoThumbnailCreator;
- (void) extractVideo: (NSInteger) aNumberOfFrame;

@end
