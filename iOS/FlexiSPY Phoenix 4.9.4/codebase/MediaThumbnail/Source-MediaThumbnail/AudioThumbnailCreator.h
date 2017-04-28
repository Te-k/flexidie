/** 
 - Project name: MediaThumbnail
 - Class name: AudioThumbnailCreator
 - Version: 1.0
 - Purpose: 
 - Copy right: 16/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "MediaThumbnailDelegate.h"


@class MediaInfo;


@protocol MediaThumbnailDelegate;


@interface AudioThumbnailCreator : NSObject {
@private
	NSString					*mOutputDirectory;			// own
	NSOperationQueue			*mAudioOPQueue;
	
	id <MediaThumbnailDelegate> mDelegate;
	NSInteger					mCount;
	
}


@property (nonatomic, assign)	id <MediaThumbnailDelegate> mDelegate;		// note that delegate here is its owner (MediaThumbnailManagerImp)
@property (nonatomic, copy)		NSString					*mOutputDirectory;
@property (nonatomic, readonly) NSOperationQueue			*mAudioOPQueue;

- (id) initWithQueue: (NSOperationQueue *) aQueue;
- (void) createThumbnail: (NSString *) aInputFullPath 
				delegate: (id <MediaThumbnailDelegate>) aDelegate;
- (void) callDelegate: (NSDictionary *) aAudioInfo;

@end
