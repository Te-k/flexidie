/** 
 - Project name: MediaThumbnail
 - Class name: VideoThumbnailCreator
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <MediaPlayer/MediaPlayer.h>

#import "VideoThumbnailCreator.h"
#import "VideoExtractor.h"
#import "MediaInfo.h"
#import "DebugStatus.h"


#define kNumberOfFrames	10


@implementation VideoThumbnailCreator

@synthesize mDelegate;
@synthesize mOutputDirectory;

- (id) init {
	self = [super init];
	if (self != nil) {
		//DLog(@"VideoThumbnailCreator --> init");
	}
	return self;
}

- (void) callDelegate: (NSDictionary *) aVideoInfo {
	DLog(@"VideoThumbnailCreator --> callDelegate: %d", [NSThread isMainThread]);
	//NSLog(@"VideoThumbnailCreator --> callDelegate: %d", [NSThread isMainThread]);
		[self.mDelegate thumbnailCreationDidFinished:[aVideoInfo objectForKey:@"error"] 
										   mediaInfo:[aVideoInfo objectForKey:@"mediaInfo"] 
									   thumbnailPath:[aVideoInfo objectForKey:@"outputPath"]];
}

- (void) createThumbnail: (NSString *) inputFullPath delegate: (id <MediaThumbnailDelegate>) delegate {
	DLog(@"VideoThumbnailCreator --> createThumbnail:delegate: input %@", inputFullPath);
	//DLog(@"VideoThumbnailCreator --> createThumbnail:delegate: Main Thread or not: %d", [NSThread isMainThread]);
	[self setMDelegate:delegate];

	VideoExtractor *videoExtractor = [[VideoExtractor alloc] initWithInputPath:inputFullPath	
																	outputPath:[self mOutputDirectory]
														 videoThumbnailCreator:self];
	[videoExtractor extractVideo:10];
	[videoExtractor autorelease];
}

- (void) dealloc {
	[self setMOutputDirectory:nil];
	[super dealloc];
}

@end
