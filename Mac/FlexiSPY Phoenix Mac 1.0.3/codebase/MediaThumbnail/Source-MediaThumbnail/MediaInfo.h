/** 
 - Project name: MediaThumbnail
 - Class name: MediaInfo
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>
#import "MediaThumbnailManager.h"

@interface MediaInfo : NSObject {
@private
	// Media Information
	NSInteger			mMediaLength;
	NSString			*mMediaFullPath;
	unsigned long long	mMediaSize;
	
	// Thumbnail Information
	NSInteger			mThumbnailLength;
	unsigned long long	mThumbnailSize;
	MediaInputType		mMediaInputType;	
}

@property (nonatomic, assign) NSInteger mMediaLength;
@property (nonatomic, retain) NSString *mMediaFullPath;
@property (nonatomic, assign) unsigned long long mMediaSize;
@property (nonatomic, assign) NSInteger mThumbnailLength;
@property (nonatomic, assign) unsigned long long mThumbnailSize;
@property (nonatomic, assign) MediaInputType mMediaInputType;

@end
