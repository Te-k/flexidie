//
//  AmbientRecordCaptureManager.h
//  AmbientRecordCaptureManager
//
//  Created by ophat on 6/9/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmbientRecordingManager.h"

@class AmbientRecorder;

@interface AmbientRecordingManagerForMac : NSObject <AmbientRecordingManager> {
    AmbientRecorder * mRecorder;
    NSString * mPath;
}

@property (nonatomic,retain) AmbientRecorder * mRecorder;
@property (nonatomic,copy) NSString * mPath;

- (id) initWithFilePath:(NSString *)aPath withEventDelegate: (id <EventDelegate>) aEventDelegate;

- (NSInteger) startRecord: (NSInteger) aDurationInMinute ambientRecordingDelegate: (id <AmbientRecordingDelegate>) aAmbientRecordingDelegate;
- (void) stopRecording;
- (BOOL) isRecording;

@end
