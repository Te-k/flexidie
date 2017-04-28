//
//  USBConnectionCaptureManager.m
//  USBConnectionCaptureManager
//
//  Created by ophat on 2/4/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "USBConnectionCaptureManager.h"
#import "USBDetection.h"

@interface USBConnectionCaptureManager (private)
- (void) usbEventDetected: (FxEvent *) aEvent;
@end

@implementation USBConnectionCaptureManager
@synthesize mDelegate;

-(id)init{
    
    if ((self = [super init])) {
        mUSBDetector = [[USBDetection alloc]init];
        [mUSBDetector setMDelegate:self];
        [mUSBDetector setMSelector:@selector(usbEventDetected:)];
    }
    return self;
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    [self setMDelegate:aEventDelegate];
}

- (void) unregisterEventDelegate {
    [self setMDelegate:nil];
}

-(void)startCapture{
    [mUSBDetector stopCapture];
    [mUSBDetector startCapture];
}

-(void)stopCapture{
    [mUSBDetector stopCapture];
}

- (void) usbEventDetected: (FxEvent *) aEvent {
    DLog(@"Usb event: %@", aEvent);
    if ([mDelegate respondsToSelector:@selector(eventFinished:)]) {
        [mDelegate eventFinished:aEvent];
    }
}

- (void) dealloc {
    [mUSBDetector release];
    [super dealloc];
}

@end
