/** 
 - Project name: MediaThumbnail
 - Class name: AudioThumbnailCreator
 - Version: 1.0
 - Purpose: 
 - Copy right: 16/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "AudioThumbnailCreator.h"
#import "MediaInfo.h"
#import "AudioThumbnailCreatorOperation.h"
#import "DebugStatus.h"


@implementation AudioThumbnailCreator

@synthesize mDelegate;
@synthesize mOutputDirectory;
@synthesize mAudioOPQueue;

- (id) initWithQueue: (NSOperationQueue *) aQueue {
	self = [super init];
	if (self != nil) {
		mAudioOPQueue   = aQueue;				/// !!!: the queue is an assign property
		mCount			= 0;
	}
	return self;
}

- (void) callDelegateNow: (NSDictionary *) aAudioInfo {
	DLog(@"AudioThumbnailCreator --> callDelegateNOW: %d", [NSThread isMainThread]);

	[self.mDelegate thumbnailCreationDidFinished:[aAudioInfo objectForKey:@"error"] 
									   mediaInfo:[aAudioInfo objectForKey:@"mediaInfo"] 
								   thumbnailPath:[aAudioInfo objectForKey:@"outputPath"]];
}

- (void) callDelegate: (NSDictionary *) aAudioInfo {
	DLog(@"AudioThumbnailCreator --> callDelegate: %d", [NSThread isMainThread]);
	//NSLog(@"AudioThumbnailCreator --> callDelegate: %d", [NSThread isMainThread]);
	if (!aAudioInfo) 
		aAudioInfo = [NSDictionary dictionary];
	
	[self performSelector:@selector(callDelegateNow:) withObject:aAudioInfo afterDelay:0.1];
}

- (void) createThumbnail: (NSString *) aInputFullPath delegate: (id <MediaThumbnailDelegate>) aDelegate {
	//NSLog(@"AudioThumbnailCreator --> createThumbnail:delegate: Main Thread? : %d", [NSThread isMainThread]);	
	//DLog(@"AudioThumbnailCreator --> createThumbnail:delegate: Main Thread? : %d", [NSThread isMainThread]);	
	DLog(@"mCount %d", mCount = mCount + 1)
	
	[self setMDelegate:aDelegate];
	
	NSThread *thread = [NSThread currentThread];			// expected to be main thread

	AudioThumbnailCreatorOperation *audioThumbnailOP = [[AudioThumbnailCreatorOperation alloc] initWithInputPath:aInputFullPath
																									  outputPath:[self mOutputDirectory]
																						   audioThumbnailCreator:self
																							 threadToRunCallback:thread];
//	__block NSInteger blockID = mCount;
//	__block NSString* blockInputFullPath = [NSString stringWithString:aInputFullPath];

//	[audioThumbnailOP setCompletionBlock:^{
//		DLog(@"============================ AUDIO OPERATION COMPLETED %d %@--------------------------------- ", blockID, blockInputFullPath);
//	}]; // End block
	
	[mAudioOPQueue addOperation:audioThumbnailOP];
	
	[audioThumbnailOP release];
}

- (void) dealloc {	
	DLog(@"dealloc");
	[self setMOutputDirectory:nil];
	[super dealloc];
}

@end
