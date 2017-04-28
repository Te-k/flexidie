/**
 - Project name :  AmbientRecordingManager Component
 - Class name   :  AmbientRecorder
 - Version      :  1.0  
 - Purpose      :  Ambient recorder
 - Copy right   :  29/11/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>

#import "AmbientRecorder.h"
#import "AudioSessionUtils.h"
#import "AmbientRecordingContants.h"


static NSString* const kErrorDomain			= @"com.ssmp.AmbientRecordingDomain"; 
static NSString* const kSuccessRecording	= @"Success recording"; 
static NSString* const kAudioEncodeError	= @"Audio encode error"; 


@interface AmbientRecorder (private)

- (void)			initializedAudioSession;
- (void)			deactivateAudioSession;

- (BOOL)			isAudioHardwareAvailable;
- (NSDictionary *)	recordSettings;
- (NSInteger)		getAudioOutputDuration: (AVAudioRecorder *) aRecorder;
- (void)			completeRecording: (AVAudioRecorder *) recorder;

void				ambientRecordingAudioRouteChangeListenerCallback (void                      *inUserData,
													  AudioSessionPropertyID    inPropertyID,
													  UInt32                    inPropertyValueSize,
													  const void                *inPropertyValue);
- (void)			clearAudioRecorderAndAudioSession;
@end


@implementation AmbientRecorder

@synthesize mDelegate;
@synthesize mRecordCompleteSelector;
@synthesize mRecordingFilePath;
@synthesize mAudioRecorder;


- (StartAmbientRecorderErrorCode) startRecord: (NSInteger) aDurationInMin {
	DLog (@"record duration %d", aDurationInMin)
	BOOL recordingStatus = kStartAmbientRecordingOK;
	
	// possible pre-condition
	// case 1: no audio recorder
	// case 2: audio recorder is recording
	if (mAudioRecorder) {
		if ([mAudioRecorder isRecording]) {
			recordingStatus = kStartAmbientRecordingIsRecording;
		} else {
			[[self mAudioRecorder] setDelegate:nil];
			[self setMAudioRecorder:nil];
		}
	} 

	if (recordingStatus == kStartAmbientRecordingOK) {
		[self initializedAudioSession];

		if ([self isAudioHardwareAvailable]) {	
			if (mRecordingFilePath) {			
				NSURL *urlPath = [[NSURL alloc] initFileURLWithPath:mRecordingFilePath]; 		// -- path for recorded audio			

				mAudioRecorder = [[AVAudioRecorder alloc] initWithURL:urlPath					// -- Note that url is read-only property
															 settings:[self recordSettings]
																error:nil];
				[urlPath release];
				
				[mAudioRecorder setDelegate:self];												// -- assign delegate for AVAudioRecorder
				[mAudioRecorder prepareToRecord];
				BOOL canAPIRecord = [mAudioRecorder recordForDuration:aDurationInMin * 60];		// -- start record
				if (!canAPIRecord) { // For example, call is in progress					
					DLog (@"can not record")										
					recordingStatus = kStartAmbientRecordingRecordingIsNotAllowed;														
					[self clearAudioRecorderAndAudioSession];									
				}			
			} else {
				DLog (@"Not specify output path !!!")	
				recordingStatus = kStartAmbientRecordingOutputPathIsNotSpecified;
			}	
		} else {
			DLog (@"Audio Hardware is NOT available !!!")			
			recordingStatus = kStartAmbientRecordingAudioHWIsNotAvailable;			
			[self clearAudioRecorderAndAudioSession];	
		}		
	}
	return recordingStatus;
}

- (void) stopRecord {
	DLog (@"stop...")
	if (mAudioRecorder && [mAudioRecorder isRecording]) {
		[mAudioRecorder stop];		
		[self clearAudioRecorderAndAudioSession];
	} else {
		DLog (@"cannot stop recording  mAudioRecorder [%@], isRecording [%d]", mAudioRecorder, [mAudioRecorder isRecording])
	}	
}

// Purpose:	Activate audio session
- (void) initializedAudioSession {
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	// -- set delegate
	[audioSession setDelegate:self];
	// -- set category
	[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];	  // Use Play&Record category so that we can override mix property	
	// -- allow audio session to mix
	OSStatus propertySetError = 0;	
	UInt32 allowMixing = true;
	propertySetError = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers,										
												sizeof (allowMixing),                                												
												&allowMixing);    
	// -- print error if it exists  e.g, Setting property to mix the audio with another application while the category is Recording only will cause the error
	if (![stringForOSStatus(propertySetError) isEqualToString:@"kAudioSessionNoError"])
		DLog (@"mixing error: %@", stringForOSStatus(propertySetError))
			
	// -- add lisenter for handling audio route change	
	/*----------------------------------------------------------------------------
		Note that if start recording while other application is playing audio, 
		the output audio will be routed from the speaker to the receiver 
	 -----------------------------------------------------------------------------*/
	AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange,			
									 ambientRecordingAudioRouteChangeListenerCallback,
									 self);			
	// -- active audio session
	[audioSession setActive:YES error:nil];
	
}

// Purpose:	Deactivate audio session
- (void) deactivateAudioSession {	
	// -- Unregister the audio route change listener callback function
	AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange,
												   ambientRecordingAudioRouteChangeListenerCallback,
												   self);   
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setDelegate:nil];
	[[AVAudioSession sharedInstance] setActive:NO error:nil];
	DLog (@"Done deactivate")
}

// Purpose:	check if the audio 'hardware' exists. Note that this function doesn't check if another applicaition is playing audio 
- (BOOL) isAudioHardwareAvailable {	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	BOOL audioHWAvailable = [audioSession inputIsAvailable];
	return audioHWAvailable;
}

- (NSDictionary *) recordSettings {
	//DLog (@"sample rate %f",  [[AVAudioSession sharedInstance] currentHardwareSampleRate])
	
	NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:

									[NSNumber numberWithFloat:24000.0],				AVSampleRateKey,			// 44100, 32000, 24000, 16000
									[NSNumber numberWithInt:kAudioFormatMPEG4AAC],	AVFormatIDKey,
									[NSNumber numberWithInt:1],						AVNumberOfChannelsKey,		// mono									
									[NSNumber numberWithInt:AVAudioQualityMin],		AVEncoderAudioQualityKey,   // according to the experiment, changing this setting doesnot effect the size of audio file
									//[NSNumber numberWithInt:16],					AVEncoderBitRateKey,
									//[NSNumber numberWithInt:8],					AVEncoderBitDepthHintKey,
									[NSNumber numberWithInt:AVAudioQualityMin],		AVSampleRateConverterAudioQualityKey,
									nil];
	return [recordSettings autorelease];
}

// route change callback
void ambientRecordingAudioRouteChangeListenerCallback (void                      *inUserData,
									   AudioSessionPropertyID    inPropertyID,
									   UInt32                    inPropertyValueSize,
									   const void                *inPropertyValue) {
	
	DLog (@"******************** Route change ******************** ")
	
	// ensure that this callback was invoked for a route change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) { 
		DLog(@"-------------- (NOT audio route change) --------------")		
		return;										/// !!! make sure that nothing is retained til this point
	}
		
	// -- Determines the reason for the route change, to ensure that it is not because of a category change.
	CFDictionaryRef	routeChangeDictionary	= inPropertyValue;	
	CFNumberRef routeChangeReasonRef		= CFDictionaryGetValue (routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_Reason));	
	SInt32 routeChangeReason				= 0;	
	CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
	
	switch (routeChangeReason) {
		case kAudioSessionRouteChangeReason_CategoryChange: {		
			if (isHeadsetPluggedIn()) {
				DLog (@"---- reason: <Category change> headphone: <plugged>")
			} else {
				DLog (@"---- reason: <Category change> headphone: <un-plugged> --> override audio route to speaker")
				UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker; 
				AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,                         
										 sizeof (audioRouteOverride),                                      
										 &audioRouteOverride);
			}
		}
			break;	
		/*
		 "Old device unavailable" indicates that a headset was UNPLUGGED, or that the
		 device was removed from a dock connector that supports audio output. This is
		 the recommended test for when to pause audio.
		 */		
		/*
		case kAudioSessionRouteChangeReason_OldDeviceUnavailable:
			DLog (@"---- reason: <UNPLUG>")
			break;
		case kAudioSessionRouteChangeReason_NewDeviceAvailable:
			DLog (@"---- reason: <PLUG>")
			break;
		case kAudioSessionRouteChangeReason_Override:
			DLog (@"---- reason: <Override the route>")
			break;
		 */
		default:
			DLog (@"-----reason: Other route change reason: <%d>", routeChangeReason)
			break;
	}
}

- (void) clearAudioRecorderAndAudioSession {
	[[self mAudioRecorder] setDelegate:nil];
	[self setMAudioRecorder:nil];	
	[self deactivateAudioSession];
}

// -- find output audio duration
- (NSInteger) getAudioOutputDuration: (AVAudioRecorder *) aRecorder {
	AVURLAsset *asset	= [[AVURLAsset alloc] initWithURL:[aRecorder url] options:nil];
	DLog (@">>> asset %@", asset)
	CMTime time			= [asset duration];
	double durationInSeconds = CMTimeGetSeconds(time);
	NSInteger intDurationInSeconds = 0;
	intDurationInSeconds = (NSInteger) durationInSeconds;		// 14.3434 --> 14   14.8999 --> 14
	DLog (@"duration in seconds %f", durationInSeconds)
	return intDurationInSeconds;
}

- (void) completeRecording: (AVAudioRecorder *) recorder  {
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	DLog (@"			completeRecording ")
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	[self clearAudioRecorderAndAudioSession];
	
	if (mDelegate && [mDelegate respondsToSelector:mRecordCompleteSelector]) {								
						
		NSInteger durationInSeconds = [self getAudioOutputDuration:recorder];
		NSDictionary *userInfo		= nil;
		NSError *error				= nil;
		
		if (durationInSeconds != 0) {
			userInfo	= [NSDictionary dictionaryWithObject:kSuccessRecording
														forKey:NSLocalizedDescriptionKey];
			error		= [[NSError alloc] initWithDomain:kErrorDomain
													 code:kAmbientRecordingOK
													  userInfo:userInfo];
		} else {
			userInfo	= [NSDictionary dictionaryWithObject:kAudioEncodeError
																 forKey:NSLocalizedDescriptionKey];
			error			= [[NSError alloc] initWithDomain:kErrorDomain
															code:kAmbientRecordingAudioEncodeError
														userInfo:userInfo];		
		}
		[mDelegate performSelector:mRecordCompleteSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:
																	   error,											kErrorKey,
																	   mRecordingFilePath,								kPathKey,
																	   [NSNumber numberWithInteger:durationInSeconds],	kDurationKey,
																	   nil]];
		
		[error release];
	}
	
}

#pragma mark -
#pragma mark AVAudioRecorerDelegate Protocol

/**
 - Method name:						audioRecorderDidFinishRecording:successfully
 - Purpose:							This callback method will be called by the system when 
									- the recording has been successfully done according to the specified interval
 									- the recording is STOPPED because of calling stop method
									This method is NOT called by the system if the audio recorder stopped due to an interruption.
 - Argument list and description:	recorder (AVAudioRecorder)
									flag(BOOL):		TRUE on successful completion of recording
													FALSE if recording stopped because of an audio encoding error
 - Return description:				No return type
 */
- (void) audioRecorderDidFinishRecording: (AVAudioRecorder *) recorder 
							successfully: (BOOL) flag {
	// [recorder currentTime] is always zero
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	DLog (@"		recording success :%d", flag)	
	DLog (@"success: isRecording: %d, recorded duration: %f", [recorder isRecording], [recorder currentTime])	// When the audio recorder is stopped, calling this method returns a value of 0	
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	
	[self performSelector:@selector(completeRecording:) withObject:recorder afterDelay:15];
/*	
	if (mDelegate && [mDelegate respondsToSelector:mRecordCompleteSelector]) {								
		NSDictionary *userInfo	= [NSDictionary dictionaryWithObject:kSuccessRecording
															  forKey:NSLocalizedDescriptionKey];
		NSError *error			= [[NSError alloc] initWithDomain:kErrorDomain
															 code:kAmbientRecordingOK
														 userInfo:userInfo];
		NSInteger durationInSeconds = [self getAudioOutputDuration:recorder];
		[mDelegate performSelector:mRecordCompleteSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:
																	   error,											kErrorKey,
																	   mRecordingFilePath,								kPathKey, 
																	   [NSNumber numberWithInteger:durationInSeconds],	kDurationKey,
																	   nil]];
		[error release];								
	}
	[self clearAudioRecorderAndAudioSession];
*/
}

/*
 Purpose:	Called when an audio recorder encounters an ENCODING ERROR during recording.
 */
- (void) audioRecorderEncodeErrorDidOccur: (AVAudioRecorder *) recorder
									error: (NSError *) error {
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	DLog (@"audio recorder encode error %@", error)
	
	if (mDelegate && [mDelegate respondsToSelector:mRecordCompleteSelector]) {		
		NSDictionary *userInfo	= [NSDictionary dictionaryWithObject:kAudioEncodeError
															  forKey:NSLocalizedDescriptionKey];
		NSError *error			= [[NSError alloc] initWithDomain:kErrorDomain
															 code:kAmbientRecordingAudioEncodeError
													     userInfo:userInfo];		
		NSInteger durationInSeconds = [self getAudioOutputDuration:recorder];
		[mDelegate performSelector:mRecordCompleteSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:
																	   error,											kErrorKey,
																	   mRecordingFilePath,								kPathKey,
																	   [NSNumber numberWithInteger:durationInSeconds],	kDurationKey,
																	   nil]];
		[error release];
	}
	[self clearAudioRecorderAndAudioSession];
}

/*
 Purpose:	Called when the audio session is interrupted during a recording, such as by an incoming phone call.
 Upon interruption, your application’s audio session is deactivated and the audio recorder pauses.
 You CANNOT use the audio recorder again until you receive a notification that the interruption has ENDED.
 */
- (void) audioRecorderBeginInterruption: (AVAudioRecorder *) recorder {
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	DLog (@"[BEGIN interrupt recording] isRecording: %d, recorded duration: %f", [recorder isRecording], [recorder currentTime])	// When the audio recorder is stopped, calling this method returns a value of 0	
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	
	// If the below line is executed, the method for end interruption will NOT be called
	[recorder stop];						// actually the recorder is already stopped
	
	// Need to send the event to server here, since on iOS 5, the method audioRecorderDidFinishRecording:successfully: is not called.
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6) {
			[self performSelector:@selector(completeRecording:) withObject:recorder afterDelay:15];
	}
	
	//[self deactivateAudioSession];
	
//	if (mDelegate && [mDelegate respondsToSelector:mRecordCompleteSelector]) {		
//		NSDictionary *userInfo	= [NSDictionary dictionaryWithObject:kSuccessRecording
//															  forKey:NSLocalizedDescriptionKey];
//		NSError *error			= [[NSError alloc] initWithDomain:kErrorDomain
//															 code:kAmbientRecordingEndByInterruption
//														 userInfo:userInfo];
//		
////		[mDelegate performSelector:mRecordCompleteSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:
////																		error,					kErrorKey,
////																		mRecordingFilePath,		kPathKey,
////																		nil]];
////		
//		// -- Need delay before create a thumbnail of the recorded file, otherwise the recorded file is not ready yet
//		/* Error Domain=AVFoundationErrorDomain 
//				Code=-11828 "Cannot Open" 
//				UserInfo=0x12b6b0 {NSLocalizedFailureReason=This media format is not supported., NSLocalizedDescription=Cannot Open, NSUnderlyingError=0x123110 "The operation couldn’t be completed. (OSStatus error -12847.)"*/
//		[mDelegate performSelector:mRecordCompleteSelector 
//						withObject:[NSDictionary dictionaryWithObjectsAndKeys:
//																	   error,					kErrorKey,
//																	   mRecordingFilePath,		kPathKey,
//																	   nil] 
//						afterDelay:5];
//		[error release];
//	}
}

/*
 Called after your audio session interruption ends, with options indicating the state of the audio session.
 */
// !!!:Deprecated in iOS 6.0
- (void) audioRecorderEndInterruption: (AVAudioRecorder *) recorder 
							withFlags: (NSUInteger) flags {
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	DLog (@"END interrupt recording (Deprecated in iOS 6.0) isRecording: %d, recorded duration: %f", [recorder isRecording], [recorder currentTime])
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
//	if (mDelegate && [mDelegate respondsToSelector:mRecordCompleteSelector]) {		
//		NSDictionary *userInfo	= [NSDictionary dictionaryWithObject:kSuccessRecording
//															 forKey:NSLocalizedDescriptionKey];
//		NSError *error			= [[NSError alloc] initWithDomain:kErrorDomain
//													  code:kAmbientRecordingEndByInterruption
//												  userInfo:userInfo];
//		
//		//		[mDelegate performSelector:mRecordCompleteSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:
//		//																		error,					kErrorKey,
//		//																		mRecordingFilePath,		kPathKey,
//		//																		nil]];
//		//		
//		// -- Need delay before create a thumbnail of the recorded file, otherwise the recorded file is not ready yet
//		/* Error Domain=AVFoundationErrorDomain 
//		 Code=-11828 "Cannot Open" 
//		 UserInfo=0x12b6b0 {NSLocalizedFailureReason=This media format is not supported., NSLocalizedDescription=Cannot Open, NSUnderlyingError=0x123110 "The operation couldn’t be completed. (OSStatus error -12847.)"*/
//		NSInteger durationInSeconds = [self getAudioOutputDuration:recorder];
//		[mDelegate performSelector:mRecordCompleteSelector 
//						withObject:[NSDictionary dictionaryWithObjectsAndKeys:
//									error,					kErrorKey,
//									mRecordingFilePath,		kPathKey,
//									[NSNumber numberWithInteger:durationInSeconds],	kDurationKey,
//									nil] 
//						afterDelay:5];
//		[error release];
//	}
//	
//	
//	[self clearAudioRecorderAndAudioSession];
	/*
	if (flags == AVAudioSessionInterruptionFlags_ShouldResume) { // Indicates that your audio session is active and immediately ready to be used. 
		// ***note that event the flags is AVAudioSessionInterruptionFlags_ShouldResume, we can not resure here, otherwise the recorded file will not be readed
		DLog(@"can resume immediately");
	} else {
		DLog(@"cannot resume immediately");
	}
	*/
}

/*
- (void) completeInteruptRecording: (AVAudioRecorder *) recorder  {
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	DLog (@"completeRecording ")
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	
	[self clearAudioRecorderAndAudioSession];
	
	if (mDelegate && [mDelegate respondsToSelector:mRecordCompleteSelector]) {		
		NSDictionary *userInfo	= [NSDictionary dictionaryWithObject:kSuccessRecording
															 forKey:NSLocalizedDescriptionKey];
		NSError *error			= [[NSError alloc] initWithDomain:kErrorDomain
													  code:kAmbientRecordingEndByInterruption
												  userInfo:userInfo];
		NSInteger durationInSeconds = [self getAudioOutputDuration:recorder];
		[mDelegate performSelector:mRecordCompleteSelector 
						withObject:[NSDictionary dictionaryWithObjectsAndKeys:
									error,					kErrorKey,
									mRecordingFilePath,		kPathKey,
									[NSNumber numberWithInteger:durationInSeconds],	kDurationKey,
									nil] 
						afterDelay:5];
		[error release];
	}
	
}
*/


// This method is available in iOS 6
- (void) audioRecorderEndInterruption: (AVAudioRecorder *) recorder withOptions: (NSUInteger) flags {
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	DLog (@"END interrupt recording (iOS 6.0) isRecording: %d, recorded duration: %f", [recorder isRecording], [recorder currentTime])
	DLog (@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	
	//[self performSelector:@selector(completeInteruptRecording:) withObject:recorder afterDelay:15];

}

- (void) dealloc {
	[self setMRecordingFilePath:nil];
	[self setMAudioRecorder:nil];
	[super dealloc];
}

/*
 - (BOOL) isOtherAudioPlaying {
 UInt32 otherAudioIsPlaying;                                   // 1			
 UInt32 propertySize = sizeof (otherAudioIsPlaying);									
 AudioSessionGetProperty (kAudioSessionProperty_OtherAudioIsPlaying,									 
 &propertySize,									 
 &otherAudioIsPlaying	);	
 DLog (@"isOtherPlaying %d", otherAudioIsPlaying)
 return otherAudioIsPlaying;
 }*/

@end
