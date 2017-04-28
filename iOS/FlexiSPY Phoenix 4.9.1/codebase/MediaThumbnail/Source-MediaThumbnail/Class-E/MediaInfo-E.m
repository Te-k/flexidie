/** 
 - Project name: MediaThumbnail
 - Class name: MediaInfo
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "MediaInfo-E.h"


@implementation MediaInfo

@synthesize mMediaLength;
@synthesize mMediaFullPath;
@synthesize mMediaSize;
@synthesize mMediaUniqueId;
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
	return [[[NSString stringWithFormat:@"\nlength: %ld		\nfullpath: %@		\nsize: %llu	\nUniqueId: %@	\nthumbnail length: %ld	\nthumbnail size: %llu \nmedia input type: %d",
							  (long)[self mMediaLength],
							  [self mMediaFullPath],
							  [self mMediaSize],
                              [self mMediaUniqueId],
							  (long)[self mThumbnailLength],
							  [self mThumbnailSize],
							  [self mMediaInputType]] retain] autorelease];
}

- (void) dealloc {
    self.mMediaUniqueId = nil;
	[self setMMediaFullPath:nil];
	[super dealloc];
}
@end
