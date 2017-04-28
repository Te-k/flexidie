/**
 - Project name :  AmbientRecordingManager Component
 - Class name   :  
 - Version      :  1.0  
 - Purpose      :  Constants for Ambient record component
 - Copy right   :  29/11/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>

static NSString* const kErrorKey						= @"ErrorKey"; 
static NSString* const kPathKey							= @"PathKey"; 
static NSString* const kDurationKey						= @"DurationKey"; 

// Error code that can be sent back with the method in protocal AmbientRecordingDelegate
typedef enum {
	kAmbientRecordingOK								= 0,			// success
	kAmbientRecordingEndByInterruption				= 1,			// success
	kAmbientRecordingAudioEncodeError				= 2,	
	kAmbientRecordingThumbnailCreationError			= 3
} AmbientRecordingErrorCode;

// Error codes that can be returned from startRecord:ambientRecordingDelegate
typedef enum {
	kStartAmbientRecordingOK						= 0, 
	kStartAmbientRecordingIsRecording				= 1, 
	kStartAmbientRecordingAudioHWIsNotAvailable		= 2, 
	kStartAmbientRecordingRecordingIsNotAllowed		= 3,
	kStartAmbientRecordingOutputPathIsNotSpecified	= 4
} StartAmbientRecorderErrorCode;