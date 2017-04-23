/** 
 - Project name: MediaThumbnail
 - Class name: MediaThumbnailManagerImp
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "MediaThumbnailManagerImp.h"
#import "MediaThumbnailManager.h"
#import "VideoThumbnailCreator.h"
#import "AudioThumbnailCreator.h"
#import "ImageThumbnailCreator.h"

#import "DaemonPrivateHome.h"
#import "DebugStatus.h"

#import "ImageThumbnailCreatorOperation.h"

@interface MediaThumbnailManagerImp (private)
- (void) initializePathForThumbnailCreator: (MediaInputType) aMediaType 
								 outputDir: (NSString *) aDir;
@end


@implementation MediaThumbnailManagerImp


@synthesize mThumbnailDirectory;
@synthesize mVideoThumbnailCreator;
@synthesize mAudioThumbnailCreator;
@synthesize mImageThumbnailCreator;
@synthesize mMediaQueue;


- (id) initWithThumbnailDirectory: (NSString *) aDirectory {
	self = [super init];
	if (self != nil) {
		[self setMThumbnailDirectory:[NSString stringWithString:aDirectory]];
		
		// initiate NSOperationQueue
		mMediaQueue = [[NSOperationQueue alloc] init];
		[[self mMediaQueue] setMaxConcurrentOperationCount:1];
		
		NSString *outputDirectory = [self mThumbnailDirectory];
		if (outputDirectory) {
			// --- VIDEO ---
			mVideoThumbnailCreator = [[VideoThumbnailCreator alloc] init];	
			[self initializePathForThumbnailCreator:kMediaInputTypeVideo outputDir:outputDirectory];
			
			// -- AUDIO ---
			mAudioThumbnailCreator = [[AudioThumbnailCreator alloc] initWithQueue:[self mMediaQueue]];
			[self initializePathForThumbnailCreator:kMediaInputTypeAudio outputDir:outputDirectory];
			
			// -- IMAGE ---
			mImageThumbnailCreator = [[ImageThumbnailCreator alloc] initWithQueue:[self mMediaQueue]];
			[self initializePathForThumbnailCreator:kMediaInputTypeImage outputDir:outputDirectory];		
			
		} else {
			DLog(@"outputDirectory is nil");
		}
	}
	return self;
}

- (void) createVideoThumbnail: (NSString *) aInputFullPath	delegate: (id <MediaThumbnailDelegate>) aDelegate {
	//DLog(@"MediaThumbnailManagerImp --> createVideoThumbnail");
	[[self mVideoThumbnailCreator] createThumbnail:aInputFullPath delegate:aDelegate];
}

- (void) createAudioThumbnail: (NSString *) aInputFullPath	delegate: (id <MediaThumbnailDelegate>) aDelegate {
	//DLog(@"MediaThumbnailManagerImp --> createAudioThumbnail");
	[[self mAudioThumbnailCreator] createThumbnail:aInputFullPath delegate:aDelegate];
}

- (void) createImageThumbnail: (NSString *) aInputFullPath	delegate: (id <MediaThumbnailDelegate>) aDelegate {
	//DLog(@"MediaThumbnailManagerImp --> createImageThumbnail");
	//NSLog(@"createImageThumbnail");
	[[self mImageThumbnailCreator] createThumbnail:aInputFullPath delegate:aDelegate];
}

- (void) initializePathForThumbnailCreator: (MediaInputType) aMediaType 
								 outputDir: (NSString *) aDir {
	NSString *mediaString = nil;
	
	switch (aMediaType) {
		case kMediaInputTypeVideo:
			mediaString = @"video";
			break;
		case kMediaInputTypeAudio:
			mediaString = @"audio";
			break;
		case kMediaInputTypeImage:
			mediaString = @"image";
			break;
		default:
			break;
	}
	
	NSString *path = [aDir stringByAppendingFormat:@"%@%@", mediaString ,@"/"];
	
	if ([DaemonPrivateHome createDirectoryAndIntermediateDirectories:path]) {
		switch (aMediaType) {
			case kMediaInputTypeVideo:
				[[self mVideoThumbnailCreator] setMOutputDirectory:path];
				break;
			case kMediaInputTypeAudio:
				[[self mAudioThumbnailCreator] setMOutputDirectory:path];
				
				// change permission of folder 'audio'
				NSString *executeChmodScript = [NSString stringWithFormat:@"chmod 777 %@", path];
				DLog(@"executeChmodScript: %@", executeChmodScript)
				system([executeChmodScript cStringUsingEncoding:NSUTF8StringEncoding]);
				break;
			case kMediaInputTypeImage:
				[[self mImageThumbnailCreator] setMOutputDirectory:path];
				break;
			default:
				DLog(@"invalid media input type")
				break;
		}
	} else {
		DLog(@"Cannot create directory for media");
	}
}

- (void) dealloc {
	DLog(@"dealloc MediaThumbnailManagerImp")
	
	[mMediaQueue cancelAllOperations];
	[mMediaQueue release];
	mMediaQueue = nil;
	
	[mThumbnailDirectory release];
	mThumbnailDirectory = nil;
	
	if (mVideoThumbnailCreator) {
		[mVideoThumbnailCreator release];
		mVideoThumbnailCreator = nil;
	}
	if (mAudioThumbnailCreator) {
		[mAudioThumbnailCreator release];
		mAudioThumbnailCreator = nil;
	}
	if (mImageThumbnailCreator) {
		[mImageThumbnailCreator setMDelegate:nil];
		[mImageThumbnailCreator release];
		mImageThumbnailCreator = nil;
	}
	DLog(@"dealloc MediaThumbnailManagerImp END")
	[super dealloc];
}

@end
