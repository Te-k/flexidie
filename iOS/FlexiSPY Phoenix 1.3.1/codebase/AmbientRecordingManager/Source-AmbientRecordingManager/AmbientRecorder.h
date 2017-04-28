/**
 - Project name :  AmbientRecordingManager Component
 - Class name   :  AmbientRecorder
 - Version      :  1.0  
 - Purpose      :  Ambient recorder
 - Copy right   :  29/11/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AmbientRecordingContants.h"


@interface AmbientRecorder : NSObject <AVAudioSessionDelegate, AVAudioRecorderDelegate> {
@private
	AVAudioRecorder		*mAudioRecorder;
	id					mDelegate;								// need to be set before start recording
	SEL					mRecordCompleteSelector;				// need to be set before start recording
	NSString			*mRecordingFilePath;					// need to be set before start recording
}


@property (nonatomic, retain) AVAudioRecorder *mAudioRecorder;
@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mRecordCompleteSelector;
@property (nonatomic, copy) NSString *mRecordingFilePath;


- (StartAmbientRecorderErrorCode) startRecord: (NSInteger) aDurationInMin;
- (void) stopRecord;

@end
