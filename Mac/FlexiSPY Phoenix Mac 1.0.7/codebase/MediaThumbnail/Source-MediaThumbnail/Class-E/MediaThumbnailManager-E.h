/** 
 - Project name: MediaThumbnail
 - Class name: MediaThumbnailManager
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "MediaThumbnailDelegate.h"
#import <Photos/Photos.h>

#define kDefaultDimension				800				// specified by the specification

typedef enum {
	kMediaInputTypeImage,
   	kMediaInputTypeVideo,
	kMediaInputTypeAudio,
	kMediaInputTypeUndefined,
} MediaInputType;


@protocol MediaThumbnailManager
@required
- (void) createImageThumbnail: (PHAsset *) aInputAsset	delegate: (id <MediaThumbnailDelegate>) aDelegate;
- (void) createAudioThumbnail: (NSString *) aInputFullPath	delegate: (id <MediaThumbnailDelegate>) aDelegate;
- (void) createVideoThumbnail: (PHAsset *) aInputAsset	delegate: (id <MediaThumbnailDelegate>) aDelegate;
@end
