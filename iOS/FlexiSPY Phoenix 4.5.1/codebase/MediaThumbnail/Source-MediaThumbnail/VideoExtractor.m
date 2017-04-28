/** 
 - Project name: MediaThumbnail
 - Class name: VideoExtractor
 - Version: 1.0
 - Purpose: 
 - Copy right: 22/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>

#import "VideoExtractor.h"
#import "VideoThumbnailCreator.h"
#import "MediaErrorConstant.h"
#import "MediaInfo.h"
#import "DebugStatus.h"

#import "IndexGenerator.h"

#define kInvalidDuration -1


@interface VideoExtractor (private)

- (NSInteger) getIntDuration: (NSURL *) aVideoLink;
- (NSTimeInterval) getDuration: (NSURL *) aVideoLink;
- (NSString *) getOutputPath;
- (NSString *) createTimeStamp;
- (NSArray *) getTimeIntervalForDuration: (NSInteger) aDurationInt 
							frameNumbers: (NSInteger) aNumberOfFrame;
- (NSInteger) getFrameInterval: (NSInteger) aDurationInt 
				 numberOfFrame: (NSInteger) aNumberOfFrame;
- (void) getFrame: (NSInteger) aNumberOfFrame;
- (unsigned long long) getSize: (NSString *) aPath;

@end


@implementation VideoExtractor

@synthesize mInputPath;
@synthesize mOutputPath;
@synthesize mVideoThumbnailCreator;

- (id) initWithInputPath: (NSString *) aInputPath 
			  outputPath: (NSString *) aOutputPath
   videoThumbnailCreator: (VideoThumbnailCreator *) aVideoThumbnailCreator {
	self = [self init];
    if (self) {
		DLog(@"VideoExtractor -->initWithInputPath:outputPath:videoThumbnailCreator: Main Thread? : %d", [NSThread isMainThread]);
		
		[self setMInputPath:aInputPath];
		[self setMOutputPath:aOutputPath];
		mVideoThumbnailCreator = aVideoThumbnailCreator;  // assign property
    }
    return self;
}

- (void) extractVideo: (NSInteger) aNumberOfFrame {
	DLog(@"VideoExtractor --> extractVideo: Main Thread? : %d", [NSThread isMainThread]);
	
	NSInteger durationInt = 0;

	BOOL isInputExist = [[NSFileManager defaultManager] fileExistsAtPath:[self mInputPath]];

	// STEP 1: Ensure that the input video exists
	if ([self mInputPath] && isInputExist) {
		
		// -- CASE: File Found
		NSURL	*videoLink = [NSURL fileURLWithPath:[self mInputPath]];
		durationInt = [self getIntDuration:videoLink];
		DLog(@"VideoThumbnailCreatorOperation --> extractVideo: video link %@", videoLink);
		DLog(@"VideoThumbnailCreatorOperation --> extractVideo: duration %d", durationInt);
		
		// STEP 2: Check if the duration can be generated
		if ((durationInt != 0)  && (durationInt != kInvalidDuration)) {
			// -- CASE: Can Get Duration
			
			// create NSArray of time interval to extract frames
			NSArray *timeIntervals = [self getTimeIntervalForDuration:durationInt frameNumbers:aNumberOfFrame];
			DLog(@"timeIntervals.count %lu", (unsigned long)[timeIntervals count]);
						
			// create asset
			AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoLink options:nil];
			mAVAssetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];	// own
			mAVAssetImageGenerator.appliesPreferredTrackTransform = TRUE;
			[asset release];
			asset = nil;
			
			NSMutableArray *framesPath = [[NSMutableArray alloc] init];				// own, keep the paths of output frame
			NSThread *thread = [[NSThread currentThread] retain];					// own
			//mThread = [[NSThread currentThread] retain];
			
			// This value will be changed in the block to keep track when to finish generating thumbnails for each video
			__block NSInteger actualNumberOfImage = 0;
			__block BOOL isExtractAllFramesSuccess = FALSE;
			__block NSInteger errorCode;
			
			// BEGIN BLOCK ====================================================================================
			AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, 
															   CGImageRef im, 
															   CMTime actualTime, 
															   AVAssetImageGeneratorResult result, 
															   NSError *error){	
				
				//DLog(@"in video block: Main Thread? : %d", [NSThread isMainThread]);
				actualNumberOfImage += 1;
				DLog(@"VideoExtractor --> extractVideo: actualNumberOfImage %d", actualNumberOfImage);
				
				// ******************************** POOL 1 ******************************************************
				NSAutoreleasePool *pool1 = [[NSAutoreleasePool alloc] init];
				
				switch (result) {
					case AVAssetImageGeneratorSucceeded: {
						//DLog(@"can generate IMAGE from video");
						
						// ******************************** POOL 2 ******************************************************
						NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
						UIImage *thumbImg = [[UIImage imageWithCGImage:im] retain];	
						if (thumbImg) {
							isExtractAllFramesSuccess = TRUE;
							
							DLog(@"can generate THUMBNAIL from video");
							NSData *imgData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(thumbImg, 1)];
							[thumbImg release];
							thumbImg = nil;
							
							NSString *outputPath = [self getOutputPath];
							DLog(@"output path: %@", outputPath);
							
							[framesPath addObject:outputPath];
							
							[imgData writeToFile:outputPath atomically:NO];		
							[imgData release];
							imgData = nil;
						} else {
							DLog(@"cannot generate THUMBNAIL");
							isExtractAllFramesSuccess = FALSE;
						}
						[pool2 drain];
						// ******************************** END OF POOL 2 ******************************************************
						break;
					}
					case AVAssetImageGeneratorFailed:
						DLog(@"cannot generate thumbnail, error:%@", error);
						isExtractAllFramesSuccess = FALSE;
						break;
					case AVAssetImageGeneratorCancelled:
						DLog(@"generating thumbnail is cancelled, error:%@", error);
						isExtractAllFramesSuccess = FALSE;
						break;
					default:
						break;
				}
				
				DLog (@"actualNumberOfImage = %d", actualNumberOfImage);
				DLog (@"[timeIntervals count] %d", [timeIntervals count])
				
				// This condition will be called when all thumbnails for this video are extracted
				if (actualNumberOfImage == [timeIntervals count]) {
					//DLog("GONNA CALL DELEGATE for %@", [self mInputPath]);
					
					NSArray *finalFramesPath = nil;
					NSString *errorText = nil;
					MediaInfo *mediaInfo = [[MediaInfo alloc] init];
					
					// CASE: CAN GET THUMBNAIL
					if (isExtractAllFramesSuccess == TRUE) {
						errorCode = kMediaThumbnailOK;
						errorText = [NSString stringWithFormat:@"Success to get duration and create the thumbnail for %@", [self mInputPath]];	// ERROR
																	
						finalFramesPath = [[NSArray alloc] initWithArray:framesPath];							// OUTPUT PATH
	
						[mediaInfo setMThumbnailLength:0];														
						[mediaInfo setMThumbnailSize:[self getSize:[finalFramesPath objectAtIndex:0]]];
						
					// CASE: CANNOT GET THUMBNAIL, BUT CANGET DUATION
					} else { 
						errorCode = kMediaThumbnailCannotGetThumbnail;
						errorText = [NSString stringWithFormat:@"Fail to get frame for %@", [self mInputPath]]; // ERROR												
						
						// Send the frame paths even there is no image in the array or not all frames are in the array
						finalFramesPath = [[NSArray alloc] initWithArray:framesPath];							// OUTPUT PATH

					}
					[mediaInfo setMMediaSize:[self getSize:[self mInputPath]]];
					[mediaInfo setMMediaLength:durationInt];
					[mediaInfo setMMediaFullPath:[self mInputPath]];
					[mediaInfo setMMediaInputType:kMediaInputTypeVideo];
					
					[framesPath release];
					
					NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorText
																		 forKey:NSLocalizedDescriptionKey];
					NSError *error = [[NSError alloc] initWithDomain:kErrorDomain
																code:errorCode
															userInfo:userInfo];
									
					NSDictionary *videoInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error", 
																					mediaInfo, @"mediaInfo", 
																					finalFramesPath, @"outputPath", nil];
					[mediaInfo release];
					mediaInfo = nil;
					[error release];
					error = nil;
					[finalFramesPath release];
					finalFramesPath = nil;
					
					DLog(@"GONNA CALL CALLBACK")
					[self performSelector:@selector(errorDetected:) onThread:thread withObject:videoInfo waitUntilDone:NO];
				}
				
				// ******************************** END OF POOL 1 ******************************************************
				[pool1 drain];
				
				
			}; // END BLOCK			
			// END BLOCK ====================================================================================
			
			CGSize maxSize = CGSizeMake(0, kDefaultDimension);
			mAVAssetImageGenerator.maximumSize = maxSize;
			
			[mAVAssetImageGenerator generateCGImagesAsynchronouslyForTimes:timeIntervals completionHandler:handler];
            
			[thread autorelease];
		} else {
			// -- CASE: Cannot Get Duration
			
			DLog(@"AudioExtractor --> getFrame: Cannot Get Duration !! %@", [self mInputPath]);
			NSArray *finalFramesPath = [[NSArray alloc] init];									// OUTPUT PATH
			
			NSString *errorText = [NSString stringWithFormat:@"Fail to get duration for %@", [self mInputPath]];	
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorText
																 forKey:NSLocalizedDescriptionKey];
			
			NSError *error = [[NSError alloc] initWithDomain:kErrorDomain
														code:kMediaThumbnailCannotGetDuration	// ERROR
													userInfo:userInfo];
			
			MediaInfo *mediaInfo = [[MediaInfo alloc] init];									
			[mediaInfo setMMediaInputType:kMediaInputTypeVideo];
			NSDictionary *videoInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error", 
									   mediaInfo, @"mediaInfo", 
									   finalFramesPath, @"outputPath", nil];
			[mediaInfo release];
			mediaInfo = nil;
			[error release];
			error = nil;
			[finalFramesPath release];
			finalFramesPath = nil;
			[self performSelector:@selector(errorDetected:) withObject:videoInfo afterDelay:0.1];			
		}		
	} else {		
		// -- CASE: File Not Found
		DLog(@"AudioExtractor --> getFrame: File not found !! %@", [self mInputPath]);
				
		NSArray *finalFramesPath = [[NSArray alloc] init];										// OUTPUT PATH
		
		NSString *errorText = [NSString stringWithFormat:@"Input file not found %@", [self mInputPath]];
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorText
															 forKey:NSLocalizedDescriptionKey];
		
		NSError *error = [[NSError alloc] initWithDomain:kErrorDomain							// ERROR
													code:kMediaThumbnailFileNotFound
												userInfo:userInfo];		
		
		MediaInfo *mediaInfo = [[MediaInfo alloc] init];											// MEDIA INFO: the default values of MediaInfo are provided
		[mediaInfo setMMediaInputType:kMediaInputTypeVideo];
		NSDictionary *videoInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, @"error", 
																			mediaInfo, @"mediaInfo", 
																			finalFramesPath, @"outputPath", nil];
		[mediaInfo release];
		mediaInfo = nil;
		[error release];
		error = nil;
		[finalFramesPath release];
		finalFramesPath = nil;
		[self performSelector:@selector(errorDetected:) withObject:videoInfo afterDelay:0.1];
	}
}

- (NSArray *) getTimeIntervalForDuration: (NSInteger) aDurationInt 
							frameNumbers: (NSInteger) aNumberOfFrame {
	NSInteger timeAt = 0;
	NSMutableArray *timeIntervals = [[NSMutableArray alloc] init];
	for (int i = 0; (i < aNumberOfFrame) && (timeAt < aDurationInt); i++) {		// frame 0 - frame 9 (at most)				
		timeAt = i * [self getFrameInterval:aDurationInt numberOfFrame:aNumberOfFrame];
		//DLog(@"frame no.: %d time at %d", i, timeAt);
		CMTime thumbTime = CMTimeMakeWithSeconds(timeAt, 600);
		[timeIntervals addObject:[NSValue valueWithCMTime:thumbTime]];					
	}
	NSArray *timeIntervalReturned = [[NSArray alloc] initWithArray:timeIntervals];
	[timeIntervals release];
	timeIntervals = nil;
	return [timeIntervalReturned autorelease];
}

- (unsigned long long) getSize: (NSString *) aPath {
	NSDictionary *attributes = [NSDictionary  dictionaryWithDictionary:
								[[NSFileManager defaultManager] attributesOfItemAtPath:aPath error:nil]];
	unsigned long long size = [[attributes objectForKey:NSFileSize] unsignedLongLongValue];
	return size;
}

- (NSInteger) getIntDuration: (NSURL *) aVideoLink {
	NSTimeInterval duration = [self getDuration:aVideoLink];
	NSNumber *durationNumber =  [NSNumber numberWithDouble:duration];
	NSInteger durationInt = [durationNumber intValue];
	return durationInt;
}

- (NSTimeInterval) getDuration: (NSURL *) aVideoLink {
	DLog(@"video in getDuration %@", aVideoLink);
	AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:aVideoLink 
												options:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSNumber numberWithBool:YES], AVURLAssetPreferPreciseDurationAndTimingKey,
														 nil]];
	NSTimeInterval duration = 0.0;
	if (asset)	duration = CMTimeGetSeconds(asset.duration);
	else		duration = kInvalidDuration;
	
	[asset release];
	asset = nil;
	
	if (isnan(duration)) {
		DLog(@"getDuration: NAN duration");
		duration = 0;
	} 
	DLog(@"duration: %f", duration);
    
    if (duration > 0.0 && duration < 1.0) {
        // TIME-LAPSE videos almost have duration < 1.0
        duration = ceil(duration); // https://en.wikipedia.org/wiki/Floor_and_ceiling_functions
        DLog(@"Ceiling, duration: %f", duration);
    }
	return duration;
}

- (NSInteger) getFrameInterval: (NSInteger) aDurationInt 
				 numberOfFrame: (NSInteger) aNumberOfFrame{
	NSInteger frameInterval = floor(aDurationInt/aNumberOfFrame);
	if (frameInterval == 0) frameInterval = 1;
	//DLog(@"frame interval = %d", frameInterval);
	return frameInterval;
}

- (NSString *) getOutputPath {
	NSString *formattedDateString = [self createTimeStamp];
	NSString *outputPath = [[NSString alloc] initWithFormat:@"%@video_output_%@_%lu.jpg",[self mOutputPath], formattedDateString, (unsigned long)[IndexGenerator sharedIndexGenerator].mIndex];
	DLog(@"output path: %@", outputPath);
	return [outputPath autorelease];
}

- (NSString *) createTimeStamp {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss:SS"];
	NSString *formattedDateString = [[dateFormatter stringFromDate:[NSDate date]] retain];
	[dateFormatter release];
	return [formattedDateString autorelease];
}

- (void) errorDetected: (NSDictionary *) videoInfo {	
	//DLog("errorDetected")
	[[self mVideoThumbnailCreator] callDelegate: videoInfo];	
}

- (void) dealloc {
	//NSLog(@"dealloc of VideoExtractor");
	[self setMInputPath:nil];
	[self setMOutputPath:nil];
	[mAVAssetImageGenerator release];
	mAVAssetImageGenerator = nil;
	[super dealloc];
}

@end
