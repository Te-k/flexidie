/** 
 - Project name: MediaThumbnail
 - Class name: ImageThumbnailCreatorOpeartion
 - Version: 1.0
 - Purpose: 
 - Copy right: 15/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

@class ImageThumbnailCreator;
@class MediaInfo;

@interface ImageThumbnailCreatorOperation : NSOperation {
@private
	// These values are created in 'init' method
	NSString				*mInputPath;			// own in init
	NSString				*mOutputPath;			// own in init
	NSThread				*mThread;				// own in init

	ImageThumbnailCreator	*mImageThumbnailCreator;
}


@property (nonatomic, copy) NSString *mInputPath;
@property (nonatomic, copy) NSString *mOutputPath;
@property (retain) NSThread *mThread;
@property (nonatomic, readonly, assign) ImageThumbnailCreator *mImageThumbnailCreator; // property is 'assign' because the creator will live lonber than the operation

- (id) initWithInputPath: (NSString *) aInputPath 
			  outputPath: (NSString *) aOutputPath
   imageThumbnailCreator: (ImageThumbnailCreator *) aImageThumbnailCreator
	 threadToRunCallback: (NSThread *) aThread;

@end
