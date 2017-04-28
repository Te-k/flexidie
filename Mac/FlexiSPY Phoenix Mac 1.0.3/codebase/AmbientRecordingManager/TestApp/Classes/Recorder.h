//
//  Recorder.h
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 11/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmbientRecordingManager.h"
#import "EventDelegate.h"

@class AmbientRecordingManagerImpl;


@interface Recorder : NSObject <EventDelegate, AmbientRecordingDelegate> {
	AmbientRecordingManagerImpl		*mAmbientRecordingManagerImpl;
}

- (void) testStartRecord;
- (void) testStartRecordWhilePreviosRecIsInProgress;
- (void) testStartRecordWithLongInterval;
- (void) testStopRecordingBeforeCompleteInterval;
- (void) testIsRecording;
	
@end
