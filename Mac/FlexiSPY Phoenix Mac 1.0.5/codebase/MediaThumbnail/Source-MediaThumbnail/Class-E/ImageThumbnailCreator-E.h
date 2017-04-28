/** 
 - Project name: MediaThumbnail
 - Class name: ImageThumbnailCreator
 - Version: 1.0
 - Purpose: 
 - Copy right: 15/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class MediaInfo;

@protocol MediaThumbnailDelegate;

@interface ImageThumbnailCreator : NSObject {
@private
	NSString					*mOutputDirectory;		// own
	NSOperationQueue			*mImageOPQueue;
	
	id <MediaThumbnailDelegate> mDelegate;
}

@property (nonatomic, assign) id <MediaThumbnailDelegate> mDelegate;	// note that delegate here is the owner of 
																		// MediaThumbnailManagerImp who is its owner
@property (nonatomic, copy) NSString* mOutputDirectory;
@property (nonatomic, readonly) NSOperationQueue *mImageOPQueue;

- (id) initWithQueue: (NSOperationQueue *) aQueue;
- (void) createThumbnail: (PHAsset *) inputAsset
				delegate: (id <MediaThumbnailDelegate>) delegate;
- (void) callDelegate: (NSDictionary *) aImageInfo;

@end
