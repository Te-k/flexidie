//
//  AmbientRecordCaptureManager.m
//  AmbientRecordCaptureManager
//
//  Created by ophat on 6/9/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "AmbientRecordingManagerForMac.h"
#import "AmbientRecorder.h"

#import "AmbientRecordingContants.h"

@implementation AmbientRecordingManagerForMac
@synthesize mRecorder,mPath;

-(id) initWithFilePath:(NSString *)aPath withEventDelegate: (id <EventDelegate>) aEventDelegate {
    if (self = [super init]) {
        mRecorder = [[AmbientRecorder alloc]init];
        [mRecorder setMEventDelegate:aEventDelegate];
        [self setMPath:aPath];
    }
    return self;
}

#pragma mark - Ambient recording protocol -

- (NSInteger) startRecord: (NSInteger) aDurationInMinute ambientRecordingDelegate: (id <AmbientRecordingDelegate>) aAmbientRecordingDelegate {
    DLog(@"#### AmbientRecordingManagerForMac startRecord %d", (int)aDurationInMinute);
    [mRecorder startRecordingWithPath:[self mPath] minute:(int)aDurationInMinute withDelegate:aAmbientRecordingDelegate];

    return (kStartAmbientRecordingOK);
}

- (void) stopRecording {
    [mRecorder stopRecording];
}

- (BOOL) isRecording {
    return [mRecorder isRecording];
}

#pragma mark - Private methods -

-(void)dealloc{
    [mPath release];
    [mRecorder release];
    [super dealloc];
}
@end
