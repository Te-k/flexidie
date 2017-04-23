//
//  USBFileTransferCaptureManager.m
//  USBFileTransferCaptureManager
//
//  Created by ophat on 2/4/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "USBFileTransferCaptureManager.h"
#import "USBFileTransferDetection.h"

@interface USBFileTransferCaptureManager (private)
- (void) fileTransferEventDetected: (FxEvent *) aEvent;
@end

@implementation USBFileTransferCaptureManager

-(id)init{
    if ((self = [super init])) {
        mDetector = [[USBFileTransferDetection alloc]init];
        [mDetector setMDelegate:self];
        [mDetector setMSelector:@selector(fileTransferEventDetected:)];
    }
    return self;
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    mEventDelegate = aEventDelegate;
}

- (void) unregisterEventDelegate {
    mEventDelegate = nil;
}

-(void)startCapture{
    [mDetector startCapture];
}

-(void)stopCapture{
    [mDetector stopCapture];
}

- (void) fileTransferEventDetected: (FxEvent *) aEvent {
    DLog(@"File transfer event: %@", aEvent);
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        [mEventDelegate eventFinished:aEvent];
    }
}

-(void)dealloc{
    [mDetector release];
    [super dealloc];
}

@end
