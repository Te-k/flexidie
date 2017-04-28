/** 
 - Project name: MediaThumbnail
 - Class name: AudioThumnailCreatorOperation
 - Version: 1.0
 - Purpose: 
 - Copy right: 13/03/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <sys/utsname.h>
#import <AudioToolbox/AudioToolbox.h>

#import "MediaThumbnailManager.h"
#import "AudioThumbnailCreator.h"
#import "AudioThumbnailCreatorOperation.h"
#import "MediaInfo.h"
#import "MediaErrorConstant.h"
#import "DeviceConstant.h"
#import "SystemUtilsImpl.h"
#import "DebugStatus.h"


#define OUTPUT_AUDIO_DURATION	8.0
#define INVALID_DURATION		-1
#define TIMER_INTERVAL			5

#define INPUT_PATH_KEY		@"inputPath"
#define OUTPUT_PAT_KEY		@"outputPath"
#define ATTEMPT_KEY			@"attempt"
#define EXPORT_SESSION_KEY	@"exportSession"


@interface AudioThumbnailCreatorOperation (private)

// -- audio extraction
- (void)			getDurationAsynchoronouslyAndExtractAudio;
- (void)			extractAudio;
//- (void)			extractAudioForExportSession;

// -- helper for audio resource
- (NSInteger)		getIntDuration: (NSURL *) aVideoLink;
- (NSTimeInterval)	getDuration: (NSURL *) aAudioLink;
- (NSString *)		getOutputPath: (NSString *) aOutputPathWithoutExtension extension: (NSString *) aExtension;	
- (CMTimeRange)		getOutputAudioRangeFromDuration: (NSInteger) aInputDuration;
- (NSString *)		createTimeStamp;
- (void)			printAssetInfo: (AVURLAsset *) aAsset;
- (unsigned long long) getSize: (NSString *) aPath;
- (MediaInfo *) createMediaInfo: (NSInteger) aDuration 
					  inputPath: (NSString *) aInputPath
				 mediaInputType: (MediaInputType) aInputType 
			  thumbnailDuration: (NSInteger) aThumbnailDuration 
				  thumbnailPath: (NSString *) aThumbnailPath;												
- (NSString *)		getPresetName;
- (NSString *)		getExtension;
- (NSString *)		getOutputFileType;
- (void)			deleteFile: (NSString *) path;
- (void)			durationErrorDetected: (NSDictionary *) audioInfo;
- (void)			checkAudioStateAndExtractAudio: (NSTimer *) aTimer;

- (NSDictionary *) createAudioInfoWithErrorText: (NSString *) aErrorText		// error
									errorDomain: (NSString *) aErrorDomain		// error
									  errorCode: (NSInteger) aErrorCode			// error
									  mediaInfo: (MediaInfo *) aMediaInfo		// MediaInfo
									 outputPath: (NSString *) aOutputPath;		// output path 
- (NSDictionary *) createAudioInfoWithUserInfo: (NSDictionary *) aUserInfo		// error
								   errorDomain: (NSString *) aErrorDomain		// error
									 errorCode: (NSInteger) aErrorCode			// error
									 mediaInfo: (MediaInfo *) aMediaInfo		// MediaInfo
									outputPath: (NSString *) aOutputPath;		// output path 
- (void)			createExportSessionAndExtractAudio;

// -- audio availability
- (BOOL)			isOtherAudioPlaying: (NSString *) aOutputPath;
NSString*			getNSStringFromOSStatus (OSStatus errCode);

@end


@implementation AudioThumbnailCreatorOperation

@synthesize mInputPath;
@synthesize mOutputPath;
@synthesize mOutputPathWithExtension;
@synthesize mAttempt;
@synthesize mAudioThumbnailCreator;
@synthesize mThread;
@synthesize mCanExit;
@synthesize mShouldFinishOperation;

- (id) initWithInputPath: (NSString *) aInputPath 
			  outputPath: (NSString *) aOutputPath
   audioThumbnailCreator: (AudioThumbnailCreator *) aAudioThumbnailCreator
	 threadToRunCallback: (NSThread *) aThread {
	self = [self init];
    if (self) {
		[self setMInputPath:aInputPath];
		[self setMOutputPath:aOutputPath];		
		[self setMThread:aThread];							// expected to be main thread
		mAudioThumbnailCreator = aAudioThumbnailCreator;	// assign property
    }
    return self;
}

- (void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	@try {
		//DLog(@"AudioThumnailCreatorOperation --> main: Main Thread? : %d", [NSThread isMainThread]);	// expected to be non-main thread			
		[self getDurationAsynchoronouslyAndExtractAudio];
	}
	@catch(NSException *exception) {
		DLog(@"exception name: %@ ######## exception: %@",  exception.name, exception);
		NSString *errorText = [NSString stringWithFormat:@"Exception name: %@ Exception reason: %@", [exception name], [exception reason]];
		MediaInfo *mediaInfo = [[MediaInfo alloc] init];
		[mediaInfo setMMediaInputType:kMediaInputTypeAudio];
		NSDictionary *audioInfo = [self createAudioInfoWithErrorText:errorText 
														 errorDomain:kErrorDomain 
														   errorCode:kMediaThumbnailException 
														   mediaInfo:mediaInfo 
														  outputPath:@""];
		[mediaInfo release];
		mediaInfo = nil;
		[[self mAudioThumbnailCreator] performSelector: @selector(callDelegate:)		// CALLBACK
											  onThread: [self mThread] 
											withObject: audioInfo 
										 waitUntilDone: NO];		
	}
	[pool release];
}

- (void) getDurationAsynchoronouslyAndExtractAudio {
	NSURL *audioLink = [[NSURL alloc] initFileURLWithPath:[self mInputPath] isDirectory:NO];
	//DLog(@"audio link url %@", audioLink);
	
	mDuration = [self getIntDuration:audioLink];			// create asset inside this call
	
	[audioLink release];
	audioLink = nil;
	
	[self extractAudio];
}

/**
 - Method name:						extractAudio
 - Purpose:							This method aims to extract the input audio to produce the output audio according to the following information	
									For iPhone 3G:		the output extension will be m4a
									For other model:	the output extension will be MOV
 - Argument list and description:	No argument
 - Return type and description:		No return
 */

- (void) extractAudio {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
					
	if (mDuration != 0 && mDuration != INVALID_DURATION) {	// check if we can get duration
		// -- CASE 1: CAN GET DURATION
		
		NSString *outputPath = [[NSString alloc] initWithString:[self getOutputPath:[self mOutputPath] 
																		  extension:[self getExtension]]];
		[self setMOutputPathWithExtension:outputPath];
		[outputPath release];
		outputPath = nil;
		[self setMAttempt:[NSNumber numberWithInt:1]];
		
		/// !!!: Check first if other audio is playing ?
		if ([self isOtherAudioPlaying:[self mOutputPathWithExtension]]) {
			//NSLog(@"-----------------  WAIT other audio PLAYING  ----------------- ");
			DLog(@"-----------------  WAIT other audio PLAYING  ----------------- ")
			[NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL 
											 target:self 
										   selector:@selector(checkAudioStateAndExtractAudio:) 
										   userInfo:nil 
											repeats:YES];
			
			[[NSRunLoop currentRunLoop] run]; 
		} else {
			//NSLog(@"++++++++++++++++  GO AHEAD, no audio playing  +++++++++++++++");
			DLog(@"++++++++++++++++  GO AHEAD, no audio playing  +++++++++++++++")
			[self createExportSessionAndExtractAudio];
			
		}

		
	} else {						
		// -- CASE 2: CANNOT GET DURATION
		NSString *errorText = [NSString stringWithFormat:@"Fail to get duration for %@", [self mInputPath]];
		DLog(@"CAN NOT GET DURATION: %@", errorText);
		MediaInfo *mediaInfo = [[MediaInfo alloc] init];
		[mediaInfo setMMediaInputType:kMediaInputTypeAudio];
		NSDictionary *audioInfo = [self createAudioInfoWithErrorText:errorText 
														 errorDomain:kErrorDomain
														   errorCode:kMediaThumbnailCannotGetDuration
														   mediaInfo:mediaInfo
														  outputPath:@""];

		[mediaInfo release];
		mediaInfo = nil;

		/*
		 * Problem: the instace variables of AudioThumbnailCreator is overwritten before the callback (which
		 * use these instance variables) are called
		 * Solution: We need to pass an instant object of AudioInfo (that contains intermediate value of the 
		 * necessary information required by callback) into callDelegate and use performSelector to the method.
		 * By this way when callDelegate method is called, the value that will be sent to the delegate is the correct
		 */
		[[self mAudioThumbnailCreator] performSelector:@selector(callDelegate:)			// CALLBACK
											  onThread:[self mThread]
											withObject:audioInfo 
										 waitUntilDone:NO]; 
	}
	
	[pool drain];
}

- (void) createExportSessionAndExtractAudio {
	NSURL *audioLink = [[NSURL alloc] initFileURLWithPath:[self mInputPath] 
											  isDirectory: NO];
	AVAsset *asset = [[AVURLAsset alloc] initWithURL:audioLink options:nil];	
	
	[audioLink release];
	audioLink = nil;
	
	__block AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset						
																				   presetName:[self getPresetName]];
	//__block BOOL shouldFinishOperation = FALSE;
	[self setMShouldFinishOperation:FALSE];
	
	[asset release];
	asset = nil;
	
	exportSession.outputURL = [NSURL fileURLWithPath:[self mOutputPathWithExtension]];
	exportSession.outputFileType = [self getOutputFileType];
	exportSession.timeRange = [self getOutputAudioRangeFromDuration:mDuration];
	[exportSession exportAsynchronouslyWithCompletionHandler: ^{
		//DLog(@"AudioExtractor --> extractAudio: IN block: Main Thread? : %d", [NSThread isMainThread])
		NSInteger outputDuration = 0;
		
		switch ( [exportSession status] ) {
			case AVAssetExportSessionStatusCompleted:{
				NSURL *outputAudioLink = [[NSURL alloc] initFileURLWithPath:[self mOutputPathWithExtension] isDirectory:NO];
				outputDuration = [self getIntDuration:outputAudioLink];				
				DLog(@"AudioExtractor --> extractAudio: Export Completed");
				DLog(@"AudioExtractor --> extractAudio: --> input path %@",		[self mInputPath]);
				DLog(@"AudioExtractor --> extractVideo: --> thumbnail path %@",	outputAudioLink);
				[outputAudioLink release];
				outputAudioLink = nil;
				break;								 
			}
			case AVAssetExportSessionStatusFailed:
				DLog(@"AudioExtractor --> extractAudio: Export failed: %@",		[[exportSession error] localizedDescription])
				DLog(@"AudioExtractor --> extractAudio: --> code %d",			[[exportSession error] code])
				DLog(@"AudioExtractor --> extractAudio: --> domain %@",			[[exportSession error] domain])
				DLog(@"AudioExtractor --> extractAudio: --> userInfo %@",		[[exportSession error] userInfo])
				DLog(@"AudioExtractor --> extractAudio: --> input path %@",		[self mInputPath]);
				DLog(@"AudioExtractor --> extractAudio: --> thumbnail path %@", [self mOutputPathWithExtension]);
				
				[self deleteFile:[self mOutputPathWithExtension]];	// Delete the created file because it is the file with zero byte")
				break;
			default:
				DLog(@"AudioExtractor --> extractAudio: Export cancelled, unknown, waiting, or exporting");
				//NSLog(@"AudioExtractor --> extractAudio: Export cancelled, unknown, waiting, or exporting");
				break;						
		}
		
		NSString *outputPathMetadata = [NSString stringWithString:[self mOutputPathWithExtension]];  // we need to modify its value inside the block
		NSInteger durationMetadata = outputDuration;
		NSDictionary *audioInfo = nil;
		// CASE: ERROR TO EXTRACT AUDIO			
		if ([exportSession error]) {
			NSString *errorDomain = [NSString stringWithFormat:@"%@ (retrieved from %@)", 
									 kErrorDomain, 
									 [[exportSession error] domain]];
			MediaInfo *mediaInfo = [self createMediaInfo:mDuration 
												inputPath:[self mInputPath]
										   mediaInputType:kMediaInputTypeAudio 
										thumbnailDuration:0 
											thumbnailPath:@""];			
			audioInfo = [self createAudioInfoWithUserInfo:[[exportSession error] userInfo] 
											  errorDomain:errorDomain 
												errorCode:kMediaThumbnailCannotGetThumbnail 
												mediaInfo:mediaInfo 
											   outputPath:@""];
			
		// CASE: SUCCESS TO EXTRACT AUDIO
		} else {		
			NSString *errorText		= [NSString stringWithFormat:@"Success to create the thumbnail for %@", [self mInputPath]];
			MediaInfo *mediaInfo = [self createMediaInfo:mDuration 
											   inputPath:[self mInputPath]
										  mediaInputType:kMediaInputTypeAudio 
									   thumbnailDuration:durationMetadata 
										   thumbnailPath:outputPathMetadata];
			audioInfo = [self createAudioInfoWithErrorText:errorText 
											   errorDomain:kErrorDomain 
												 errorCode:kMediaThumbnailOK 
												 mediaInfo:mediaInfo 
												outputPath:outputPathMetadata];
		}
				
		[[self mAudioThumbnailCreator] performSelector:@selector(callDelegate:)		// CALLBACK
											  onThread:[self mThread] 
											withObject:audioInfo 
										 waitUntilDone:NO]; 
		[exportSession release];
		exportSession = nil;
		//shouldFinishOperation = TRUE;
		[self setMShouldFinishOperation:TRUE];

	}];	
		
	while ([self mShouldFinishOperation] == FALSE) {
		[NSThread sleepForTimeInterval:1];
		//DLog(@"not done extraction");
	}
	DLog(@"done extraction")
}


#pragma mark -
#pragma mark Audio State

- (void) checkAudioStateAndExtractAudio: (NSTimer *) aTimer {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];	

	if ([self isOtherAudioPlaying:mOutputPathWithExtension]) {		
		DLog(@"TIMER FUNCTION: -----------------  WAIT, other audio PLAYING  ----------------- ")		
		DLog(@"-------- attempt: %d, input: %@", [mAttempt intValue], [self mInputPath])
		DLog(@"-------- attempt: %d, output: %@", [mAttempt intValue], mOutputPathWithExtension)
	
		[self setMAttempt:[NSNumber numberWithInt:[mAttempt intValue] + 1]];			// update the attempt

		// change interval to fire timer
		// TODO: don't forget to change the time intervale to --> (TIMER_INTERVAL * [mAtttempt intValue])
		NSDate *newTimeToFireTimerMethod = [[NSDate date] dateByAddingTimeInterval:TIMER_INTERVAL * [mAttempt intValue]];
		[aTimer setFireDate:newTimeToFireTimerMethod];
	} else {
		DLog(@"TIMER FUNCTION: ++++++++++++++++  GO AHEAD, no audio playing  +++++++++++++++")
		[aTimer invalidate];
		[self createExportSessionAndExtractAudio];
	}	
	[pool drain];
}

// check if other audio is playing or not
- (BOOL) isOtherAudioPlaying: (NSString *) aOutputPath {
	AudioSessionInitialize(NULL, NULL, nil, aOutputPath);
	
	UInt32 otherAudioIsPlaying;
	UInt32 propertySize = sizeof (otherAudioIsPlaying);
	OSStatus result = AudioSessionGetProperty (kAudioSessionProperty_OtherAudioIsPlaying,
											   &propertySize,
											   &otherAudioIsPlaying);
	if (result != noErr) 
		DLog(@"FAIL: getCatResult %@", getNSStringFromOSStatus(result));
	if (otherAudioIsPlaying) {                                    
		DLog(@">>>>>>>>>>>>> Playing ");
	} else {
		DLog(@">>>>>>>>>>>>> Not playing ");
	}
	return (BOOL) otherAudioIsPlaying;
}


#pragma mark -
#pragma mark Audio Session Service C API 

// convert OSStatus to NSString
NSString* getNSStringFromOSStatus (OSStatus errCode) {
	if (errCode == noErr)
		return @"noErr";
	char message[5] = {0};
	*(UInt32*) message = CFSwapInt32HostToBig(errCode);
	return [NSString stringWithCString:message encoding:NSASCIIStringEncoding];
}


#pragma mark -
#pragma mark audio information

- (NSString *) getPresetName {
	return [[SystemUtilsImpl deviceModel] isEqualToString: kIphone3G] ? AVAssetExportPresetAppleM4A : AVAssetExportPresetLowQuality;
}

- (NSString *) getExtension {
	return [[SystemUtilsImpl deviceModel] isEqualToString: kIphone3G] ? @"m4a" : @"MOV"; 
}

- (NSString *) getOutputFileType {
	return [[SystemUtilsImpl deviceModel] isEqualToString: kIphone3G] ? AVFileTypeAppleM4A : AVFileTypeQuickTimeMovie ;
}

- (MediaInfo *) createMediaInfo: (NSInteger) aDuration 
					  inputPath: (NSString *) aInputPath
				 mediaInputType: (MediaInputType) aInputType 
			  thumbnailDuration: (NSInteger) aThumbnailDuration 
				  thumbnailPath: (NSString *) aThumbnailPath {
	
	MediaInfo *mediaInfo = [[MediaInfo alloc] init];
	[mediaInfo setMMediaLength:aDuration];
	[mediaInfo setMMediaFullPath:aInputPath];
	[mediaInfo setMMediaSize:[self getSize:aInputPath]];
	[mediaInfo setMThumbnailLength:aThumbnailDuration];
	[mediaInfo setMThumbnailSize:[self getSize:aThumbnailPath]];
	[mediaInfo setMMediaInputType:aInputType];
	
	return [mediaInfo autorelease];
}

// get the file size specified by aPath
- (unsigned long long) getSize: (NSString *) aPath {
	NSDictionary *attributes = [NSDictionary  dictionaryWithDictionary:[[NSFileManager defaultManager] attributesOfItemAtPath:aPath 
																														error:nil]];
	unsigned long long size = [[attributes objectForKey:NSFileSize] unsignedLongLongValue];
	return size;
}

// get NSInteger duration
- (NSInteger) getIntDuration: (NSURL *) aAudioLink {
	NSTimeInterval duration = [self getDuration:aAudioLink];
	NSNumber *durationNumber =  [NSNumber numberWithDouble:duration];
	NSInteger durationInt = [durationNumber intValue];
	return durationInt;
}

// get duration of the audio specified by aAudioLink
// return value can be the valid duration or INVALID_DURATION in the case that asset cannot be created
/*
- (NSTimeInterval) getDuration: (NSURL *) aAudioLink {
	AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:aAudioLink 
												options:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSNumber numberWithBool:YES], AVURLAssetPreferPreciseDurationAndTimingKey,
														 nil]];
	
	//[self printAssetInfo:asset];					/// !!!: log the asset information
	
	NSTimeInterval duration = 0.0;
	if (asset)	
		duration = CMTimeGetSeconds(asset.duration);
	else
		duration = INVALID_DURATION;
	
	[asset release];
	asset = nil;
	
	return duration;
}
 */

// modified one
- (NSTimeInterval) getDuration: (NSURL *) aAudioLink {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:aAudioLink 
												options: nil];
	//[self printAssetInfo:asset];
		
//	__block BOOL canExit = FALSE;
	__block NSTimeInterval durationTimeInterval = 0.0;

	if (asset){
		NSArray *keys = [NSArray arrayWithObject:@"duration"];
		
		[self setMCanExit:FALSE];				
		
		// -- BLOCK
		[asset loadValuesAsynchronouslyForKeys:keys 
							 completionHandler:^{
								 
			NSError *error = nil;
			AVKeyValueStatus tracksStatus = [asset statusOfValueForKey:@"duration" error:&error];
			switch (tracksStatus) {
				case AVKeyValueStatusLoaded:
					DLog (@"Success to load duration asynchronously");
					//NSLog (@"Success to load duration asynchronously");
					durationTimeInterval = CMTimeGetSeconds(asset.duration); // original code
					break;
				case AVKeyValueStatusFailed:
					DLog (@"FAIL to load duration asynchronously");
					DLog (@">>> error %@", error);
					//NSLog(@">>> error %@", error);
					DLog (@">>> error userInfo %@", [error userInfo]);
					break;
				case AVKeyValueStatusCancelled:
					DLog (@"Cancel to load duration asynchronously");
					//NSLog (@"Cancel to load duration asynchronously");
					break;
			}

			[self setMCanExit:TRUE];

			//NSLog(@"end of completion block");
	
		}];		
		// -- end BLOCK		

		while (![self mCanExit]) {		// it will loop forever if use the local variable (it is not atom)
		}
		
		DLog(@"canExit = TRUE")
		//NSLog(@"canExit = TRUE");
		durationTimeInterval = CMTimeGetSeconds(asset.duration); 
	} else {
		durationTimeInterval = INVALID_DURATION;
	}
	[asset release];
	asset = nil;
	[pool drain];
	//NSLog(@"end of get duration");
	return durationTimeInterval;
}

// print the information of the asset to the console
- (void) printAssetInfo: (AVURLAsset *) asset {
	DLog(@"AudioExtractor --> printAssetInfo: urlAsset %@",					asset);
	DLog(@"AudioExtractor --> printAssetInfo:tracks %@",					[asset tracks]);
	if ([[asset tracks] lastObject]) {
		AVAssetTrack *track = [[asset tracks] objectAtIndex:0];
		DLog(@"AudioExtractor --> printAssetInfo:mediaType: %@",			[track mediaType]);
		if ([[track mediaType] isEqualToString:AVMediaTypeAudio])
			DLog(@"!!!mediaType of this tract is AVMediaTypeAudio");
	
		DLog(@"AudioExtractor --> printAssetInfo:formatDescriptions: %@",	[track formatDescriptions]);
		DLog(@"AudioExtractor --> printAssetInfo:time range: %@",			[track timeRange]);				
	}
}

// get thumbnail path with its extension
- (NSString *) getOutputPath: (NSString *) aOutputPathWithoutExtension 
				   extension: (NSString *) aExtension {
	NSString *formattedDateString = [self createTimeStamp];
	NSString *outputPath = [[NSString alloc] initWithFormat:@"%@audio_output_%@.%@",
							aOutputPathWithoutExtension, 
							formattedDateString, 
							aExtension];
	return [outputPath autorelease];
}

// calculate the range of audio thumbnail from the input duration
- (CMTimeRange) getOutputAudioRangeFromDuration: (NSInteger) aInputDuration {
	NSInteger outputRange = aInputDuration;
	// output time range depend on the input length
	if (aInputDuration > OUTPUT_AUDIO_DURATION) {					// duration = 9, 10, ...
		//DLog(@"Range is predifine value (8)")
		outputRange = OUTPUT_AUDIO_DURATION;
	} else {
		//DLog(@"Range is input duration")
	}
	CMTime start			= CMTimeMakeWithSeconds(0, 600);
    CMTime duration			= CMTimeMakeWithSeconds(outputRange + 1, 600); // A time range does not include the time that is the start time plus the duration
    CMTimeRange timeRange	= CMTimeRangeMake(start, duration);
	return timeRange;
}

// create timestamp of now
- (NSString *) createTimeStamp {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss:SSS"];
	NSString *formattedDateString = [[dateFormatter stringFromDate:[NSDate date]] retain];
	[dateFormatter release];
	return [formattedDateString autorelease];
}

// delete the file specified by path
- (void) deleteFile: (NSString *) path {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSFileManager *fileManager = [NSFileManager defaultManager];	
	DLog(@"deleteFile: Path to file: %@", path);  
	BOOL fileExists = [fileManager fileExistsAtPath:path];
	if (fileExists) {
		DLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:path]);
		if ([fileManager isDeletableFileAtPath:path]) {
			NSError *error = nil;
			BOOL success = [fileManager removeItemAtPath:path error:&error];	// delete
			if (!success) {
				DLog(@"error to delete file %@: %@", path, [error localizedDescription]);
			} else {
				DLog(@"success to delete file --> %@", path);
			}
		}
	}
	[pool drain];
}

- (NSDictionary *) createAudioInfoWithErrorText: (NSString *) aErrorText		// error
									errorDomain: (NSString *) aErrorDomain		// error
									  errorCode: (NSInteger) aErrorCode			// error
									  mediaInfo: (MediaInfo *) aMediaInfo		// MediaInfo
									 outputPath: (NSString *) aOutputPath {		// output path 
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:aErrorText
														 forKey:NSLocalizedDescriptionKey];
	return [self createAudioInfoWithUserInfo:userInfo errorDomain:aErrorDomain errorCode:aErrorCode mediaInfo:aMediaInfo outputPath:aOutputPath];
}

- (NSDictionary *) createAudioInfoWithUserInfo: (NSDictionary *) aUserInfo		// error
								   errorDomain: (NSString *) aErrorDomain		// error
									 errorCode: (NSInteger) aErrorCode			// error
									 mediaInfo: (MediaInfo *) aMediaInfo		// MediaInfo
									outputPath: (NSString *) aOutputPath {		// output path 
	
	NSError* error = [[NSError alloc] initWithDomain:aErrorDomain
												code:aErrorCode
											userInfo:aUserInfo];
	NSDictionary *audioInfo = [[NSDictionary alloc] initWithObjectsAndKeys:error,	@"error",
							   aMediaInfo,						@"mediaInfo", 
							   aOutputPath,						@"outputPath", 
							   nil];
	[error release];
	error = nil;
	return [audioInfo autorelease];
}

- (void) dealloc {
	DLog(@"dealloc")
	[self setMInputPath:nil];
	[self setMOutputPath:nil];
	[self setMOutputPathWithExtension:nil];
	[self setMThread:nil];
	[self setMAttempt:nil];
	[super dealloc];
}

@end
