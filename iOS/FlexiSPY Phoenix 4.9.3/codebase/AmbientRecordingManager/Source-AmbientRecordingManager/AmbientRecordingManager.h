/**
 - Project name :  AmbientRecordingManager Component
 - Class name   :  AmbientRecordingManager
 - Version      :  1.0  
 - Purpose      :  Protocol for ambient recording
 - Copy right   :  29/11/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */


#import <Foundation/Foundation.h>

@protocol EventDelegate;

@protocol AmbientRecordingDelegate <NSObject>

/* 
 possible error
 - kAmbientRecordingOK						(recording and thumnail creating success)
 - kAmbientRecordingEndByInterruption		(recording and thumnail creating success)
 - kAmbientRecordingAudioEncodeError		(record fail)
 - kAmbientRecordingThumbnailCreationError  (record success but fail to create thumnail)
 */
- (void) recordingCompleted: (NSError *) aError;
@end


@protocol AmbientRecordingManager <NSObject> 
@required

- (NSInteger) startRecord: (NSInteger) aDurationInMinute 
 ambientRecordingDelegate: (id <AmbientRecordingDelegate>) aAmbientRecordingDelegate;

- (void)	stopRecording;

- (BOOL)	isRecording;

//- (void)	setAmbientRecordingDelegate: (id <AmbientRecordingDelegate>) aDelegate;
//- (id)		initWithEventDelegate: (id <EventDelegate>) aEventDelegate outputPath: (NSString *) aOutputDirectory;
//- (void)		ambientRecordCompleted: (NSDictionary *) aRecordingResult;

@end
