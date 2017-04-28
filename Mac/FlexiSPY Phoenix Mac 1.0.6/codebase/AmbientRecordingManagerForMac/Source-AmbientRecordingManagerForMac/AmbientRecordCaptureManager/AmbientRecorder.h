//
//  AmbientRecorder.h
//  AmbientRecordCaptureManager
//
//  Created by ophat on 6/9/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

// Quick Time is totally deprecated in macOS 10.12
@protocol EventDelegate, AmbientRecordingDelegate;

@interface AmbientRecorder : NSObject {
    QTCaptureDeviceInput        * mAudioDeviceInput;
    QTCaptureSession            * mSession;
    QTCaptureMovieFileOutput    * mFileOutput;
    QTCaptureDevice             * mAudioDevice;
    
    id <EventDelegate> mEventDelegate;
    id <AmbientRecordingDelegate> mAmbientRecordingDelegate;

    NSString                    *mFullPath;
    int                         mDuration;
}

@property(nonatomic,retain) QTCaptureDeviceInput * mAudioDeviceInput;
@property(nonatomic,retain) QTCaptureSession * mSession;
@property(nonatomic,retain) QTCaptureMovieFileOutput *mFileOutput;
@property(nonatomic,retain) QTCaptureDevice * mAudioDevice;
@property(nonatomic,assign) id <EventDelegate> mEventDelegate;
@property(nonatomic,assign) id <AmbientRecordingDelegate> mAmbientRecordingDelegate;
@property(nonatomic,copy)   NSString *mFullPath;
@property(nonatomic,assign) int mDuration;

- (void) startRecordingWithPath:(NSString *)aPath minute:(int)aMin withDelegate:(id <AmbientRecordingDelegate>) aDelegate;
- (void) stopRecording;
- (BOOL) isRecording;

@end
