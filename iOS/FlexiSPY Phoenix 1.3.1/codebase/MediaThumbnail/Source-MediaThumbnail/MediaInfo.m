/** 
 - Project name: MediaThumbnail
 - Class name: MediaInfo
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "MediaInfo.h"


@implementation MediaInfo

@synthesize mMediaLength;
@synthesize mMediaFullPath;
@synthesize mMediaSize;
@synthesize mThumbnailLength;
@synthesize mThumbnailSize;
@synthesize mMediaInputType;

- (id) init {
	self = [super init];
	if (self != nil) {
		// set default value for its instance variable
		mMediaLength = 0;
		mMediaFullPath = @"";
		mMediaSize = 0;
		
		mThumbnailLength = 0;
		mThumbnailSize = 0;
		mMediaInputType = kMediaInputTypeUndefined;
	}
	return self;
}

- (NSString *) description {
	return [[[NSString stringWithFormat:@"\nlength: %d		\nfullpath: %@		\nsize: %llu	\nthumbnail length: %d	\nthumbnail size: %llu \nmedia input type: %d", 
							  [self mMediaLength],
							  [self mMediaFullPath],
							  [self mMediaSize],
							  [self mThumbnailLength],
							  [self mThumbnailSize],
							  [self mMediaInputType]] retain] autorelease];
}

- (void) dealloc {
	[self setMMediaFullPath:nil];
	[super dealloc];
}
@end
