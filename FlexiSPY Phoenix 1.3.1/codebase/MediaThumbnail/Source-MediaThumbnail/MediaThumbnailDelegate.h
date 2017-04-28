/** 
 - Project name: MediaThumbnail
 - Class name: MediaThumbnailDelegate
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>


@class MediaInfo;


@protocol MediaThumbnailDelegate <NSObject>
@required
- (void) thumbnailCreationDidFinished: (NSError *) aError
							mediaInfo: (MediaInfo *) aMedia
						thumbnailPath: (id) aPaths;

@end
