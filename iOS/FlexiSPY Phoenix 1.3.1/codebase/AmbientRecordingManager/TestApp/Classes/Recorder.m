//
//  Recorder.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 11/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Recorder.h"
#import "AmbientRecordingManagerImpl.h"
#import "DebugStatus.h"
#import "AmbientRecordingContants.h"

@implementation Recorder

- (id) init
{
	self = [super init];
	if (self != nil) {
		mAmbientRecordingManagerImpl = [[AmbientRecordingManagerImpl alloc] initWithEventDelegate:self outputPath:@"/tmp/"];
		//[mAmbientRecordingManagerImpl setMAmbientRecordingDelegate:self];
		//[mAmbientRecordingManagerImpl setAmbientRecordingDelegate:self];
	}
	return self;
}

- (void) testStartRecord {
	DLog (@"... start recording >>>>>")
	StartAmbientRecorderErrorCode code = [mAmbientRecordingManagerImpl startRecord:10 ambientRecordingDelegate:self];
	DLog (@"StartAmbientRecorderErrorCode: %d", code )
}

- (void) testStartRecordWhilePreviosRecIsInProgress {
	DLog (@"... start recording 2")
	StartAmbientRecorderErrorCode code = [mAmbientRecordingManagerImpl startRecord:10 ambientRecordingDelegate:self];
	DLog (@"StartAmbientRecorderErrorCode: %d", code )
	
	[self performSelector:@selector(testStartRecord) withObject:nil afterDelay:3];
}

- (void) testStartRecordWithLongInterval {
	DLog (@"... start recording 3")
	StartAmbientRecorderErrorCode code = [mAmbientRecordingManagerImpl startRecord:18 ambientRecordingDelegate:self];
	DLog (@"StartAmbientRecorderErrorCode: %d", code )
}

- (void) testStopRecordingBeforeCompleteInterval {
	DLog (@"... start recording 4")
	StartAmbientRecorderErrorCode code = [mAmbientRecordingManagerImpl startRecord:10 ambientRecordingDelegate:self];
	DLog (@"StartAmbientRecorderErrorCode: %d", code )
	
	[mAmbientRecordingManagerImpl performSelector:@selector(stopRecording) withObject:nil afterDelay:5];
}

- (void) testIsRecording {
	DLog (@"... start recording 5")
	StartAmbientRecorderErrorCode code = [mAmbientRecordingManagerImpl startRecord:10 ambientRecordingDelegate:self];
	DLog (@"StartAmbientRecorderErrorCode: %d", code )


	
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:3];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:4];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:5];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:6];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:7];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:8];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:9];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:10];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:11];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:12];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:13];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:14];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:15];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:16];
	[mAmbientRecordingManagerImpl performSelector:@selector(isRecording) withObject:nil afterDelay:17];

}

- (void) eventFinished: (FxEvent*) aEvent {
	DLog (@"############# evnet delegate --> eventFinished %@", aEvent)
}

- (void) recordingCompleted: (NSError *) aError {
	DLog (@"############# ambient recording delegate recordingCompleted %@", aError)
}

@end
