/** 
 - Project name: MediaThumbnail
 - Class name: VideoThumbnailCreator
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class MediaInfo;

@protocol MediaThumbnailDelegate;

@interface VideoThumbnailCreator : NSObject {
@private
	NSString					*mOutputDirectory;						// own
	id <MediaThumbnailDelegate> mDelegate;	
}


@property (nonatomic, assign) id <MediaThumbnailDelegate> mDelegate;	// note that delegate here is the owner of 
																		// MediaThumbnailManagerImp who is its owner
@property (nonatomic, copy) NSString* mOutputDirectory;


- (void) createThumbnail: (PHAsset *) inputAsset
				delegate: (id <MediaThumbnailDelegate>) delegate;
- (void) callDelegate: (NSDictionary *) aVideoInfo;

@end
