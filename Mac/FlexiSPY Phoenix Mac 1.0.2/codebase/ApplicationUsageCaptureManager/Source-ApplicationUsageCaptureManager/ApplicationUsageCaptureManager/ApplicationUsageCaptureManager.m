//
//  ApplicationUsageCaptureManager.m
//  ApplicationUsageCaptureManager
//
//  Created by ophat on 2/5/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "ApplicationUsageCaptureManager.h"
#import "ApplicationUsage.h"

@interface ApplicationUsageCaptureManager (private)
- (void) applicationUsageEventDetected: (FxEvent *) aEvent;
@end

@implementation ApplicationUsageCaptureManager

-(id)init{
    if ((self = [super init])) {
        mAUsage = [[ApplicationUsage alloc]init];
        [mAUsage setMDelegate:self];
        [mAUsage setMSelector:@selector(applicationUsageEventDetected:)];
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
    [mAUsage startCapture];
}
-(void)stopCapture{
    [mAUsage stopCapture];
}

- (void) applicationUsageEventDetected: (FxEvent *) aEvent {
    DLog(@"AppUsage event: %@", aEvent);
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        [mEventDelegate eventFinished:aEvent];
    }
}

-(void)dealloc{
    [mAUsage release];
    [super dealloc];
}

@end
