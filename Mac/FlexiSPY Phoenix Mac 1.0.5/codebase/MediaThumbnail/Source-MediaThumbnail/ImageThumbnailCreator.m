/** 
 - Project name: MediaThumbnail
 - Class name: ImageThumbnailCreator
 - Version: 1.0
 - Purpose: 
 - Copy right: 15/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "ImageThumbnailCreator.h"
#import "ImageThumbnailCreatorOperation.h"
#import "MediaInfo.h"
#import "DebugStatus.h"

@interface ImageThumbnailCreator (private) 
- (void) callDelegate: (NSDictionary *) aImageInfo;
@end

@implementation ImageThumbnailCreator

@synthesize mDelegate;
@synthesize mOutputDirectory;
@synthesize mImageOPQueue;

- (id) initWithQueue: (NSOperationQueue *) aQueue {
	self = [super init];
	if (self != nil) {
		//DLog(@"ImageThumbnailCreator --> initWithQueue");
		mImageOPQueue =	aQueue;
	}
	return self;
}

- (void) callDelegate: (NSDictionary *) aImageInfo {
	//DLog(@"ImageThumbnailCreator --> callDelegate: %d", [NSThread isMainThread]);
	//DLog(@"callDelegate %@", aImageInfo);
	if ([[self mDelegate] respondsToSelector:@selector(thumbnailCreationDidFinished:mediaInfo:thumbnailPath:)]) {
		
		[[self mDelegate] thumbnailCreationDidFinished:[aImageInfo objectForKey:@"error"] 
											 mediaInfo:[aImageInfo objectForKey:@"mediaInfo"] 
										 thumbnailPath:[aImageInfo objectForKey:@"outputPath"]];
	}
}

- (void) createThumbnail: (NSString *) inputFullPath delegate: (id <MediaThumbnailDelegate>) aDelegate {
	//DLog(@"ImageThumbnailCreator --> createThumbnail:delegate: Main Thread?: %d", [NSThread isMainThread]);
	//DLog(@"createThumbnail %@", inputFullPath);
	[self setMDelegate:aDelegate];
	NSThread *thread = [NSThread currentThread];
	
	ImageThumbnailCreatorOperation  *imageThumbnailOP = [[ImageThumbnailCreatorOperation alloc] initWithInputPath:inputFullPath	
																									   outputPath:[self mOutputDirectory]
																							imageThumbnailCreator:self
																							  threadToRunCallback:thread];	
//	[imageThumbnailOP setCompletionBlock:^{
		
//		DLog(@"complete operation");
//		DLog(@"----------------------------------------------------------------------");
//		DLog(@"ImageThumbnailCreatorOperation COMPLETE %@", inputFullPath);
//		DLog(@"----------------------------------------------------------------------");
//	}];
	[mImageOPQueue addOperation:imageThumbnailOP];
	[imageThumbnailOP autorelease];
}

- (void) dealloc {
	DLog (@"dealloc of ImageCreator")
	[self setMOutputDirectory:nil];
	[super dealloc];
}

@end
