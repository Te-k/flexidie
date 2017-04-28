/** 
 - Project name: MediaThumbnail
 - Class name: MediaThumbnailManager
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "MediaThumbnailDelegate.h"

typedef enum {
	kMediaInputTypeImage,
   	kMediaInputTypeVideo,
	kMediaInputTypeAudio,
	kMediaInputTypeUndefined,
} MediaInputType;


@protocol MediaThumbnailManager
@required
- (void) createImageThumbnail: (NSString *) aInputFullPath	delegate: (id <MediaThumbnailDelegate>) aDelegate;
- (void) createAudioThumbnail: (NSString *) aInputFullPath	delegate: (id <MediaThumbnailDelegate>) aDelegate;
- (void) createVideoThumbnail: (NSString *) aInputFullPath	delegate: (id <MediaThumbnailDelegate>) aDelegate;
@end
