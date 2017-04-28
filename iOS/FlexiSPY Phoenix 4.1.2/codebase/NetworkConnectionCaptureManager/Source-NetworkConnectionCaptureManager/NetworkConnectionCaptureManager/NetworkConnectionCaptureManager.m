//
//  NetworkConnectionCaptureManager.m
//  NetworkConnectionCaptureManager
//
//  Created by ophat on 11/24/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "NetworkConnectionCaptureManager.h"
#import "NetworkConnectionCaptureNotify.h"

@implementation NetworkConnectionCaptureManager
@synthesize mNetCap;

#pragma mark #Init
-(id) init{
    if (self = [super init]) {
        mNetCap = [[NetworkConnectionCaptureNotify alloc]init];
        [mNetCap setMDelegate:self];
        [mNetCap setMSelector:@selector(NetworkConnectionEventDetected:)];
        [mNetCap setMThread:[NSThread currentThread]];
    }
    return self;
}

#pragma mark #Reg/UnReg
- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    mEventDelegate = aEventDelegate;
}

- (void) unregisterEventDelegate {
    mEventDelegate = nil;
}

#pragma mark #start/stop
- (void) startCapture{
    DLog(@"NetworkConnectionCaptureManager ==> startCapture");
    [mNetCap startCapture];
}

- (void) stopCapture{
    DLog(@"NetworkConnectionCaptureManager ==> stopCapture");
    [mNetCap stopCapture];
}

#pragma mark #event
- (void) NetworkConnectionEventDetected: (FxEvent *) aEvent {
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        NSLog(@"NetworkConnectionEventDetected event: %@", aEvent);
        [mEventDelegate eventFinished:aEvent];
    }
}


#pragma mark #Destroy
-(void) dealloc{
    [mNetCap release];
    [super dealloc];
}
@end

