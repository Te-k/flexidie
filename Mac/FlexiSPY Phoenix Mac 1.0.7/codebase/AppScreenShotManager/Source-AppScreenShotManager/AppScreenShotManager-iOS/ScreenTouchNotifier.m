//
//  ScreenTouchNotifier.m
//  AppScreenShotManager
//
//  Created by Makara Khloth on 1/5/17.
//  Copyright © 2017 ophat. All rights reserved.
//

#import "ScreenTouchNotifier.h"

#include "IOHIDEventSystem.h"
#include "IOHIDEventSystemClient.h"

@implementation ScreenTouchNotifier

@synthesize mRecentCaptureDate;
@synthesize mDelegate, mSelector;

- (void) startNotify {
    [self stopNotify];
    
    [NSThread detachNewThreadSelector:@selector(monitorTouch) toTarget:self withObject:nil];
}

- (void) stopNotify {
    if (mTouchRL) {
        IOHIDEventSystemClientUnregisterEventCallback(IOHIDEventSystemClient());
        IOHIDEventSystemClientUnscheduleWithRunLoop(IOHIDEventSystemClient(), [mTouchRL getCFRunLoop], kCFRunLoopDefaultMode);
        
        CFRunLoopStop([mTouchRL getCFRunLoop]);
        mTouchRL = nil;
    }
}

- (void) monitorTouch {
    DLog(@"monitorTouch...");
    /*
     <key>com.apple.private.hid.client.event-dispatch</key>
     <true/>
     <key>com.apple.private.hid.client.service-protected</key>
     <true/>
     <key>com.apple.private.hid.manager.client</key>
     <true/>
     */
    mTouchRL = [NSRunLoop currentRunLoop];
    IOHIDEventSystemClientScheduleWithRunLoop(IOHIDEventSystemClient(), CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOHIDEventSystemClientRegisterEventCallback(IOHIDEventSystemClient(), (IOHIDEventSystemClientEventCallback)handle_event, NULL, (void *)self);
    
    [[NSRunLoop currentRunLoop] run];
}

static boolean_t handle_event(void * target, void * refcon, void * sender, IOHIDEventRef event)
{
    //DLog(@"event : %@", event); // Call too often
    
    if (IOHIDEventGetType(event)==kIOHIDEventTypeDigitizer){
        
        u_int32_t eventMask = IOHIDEventGetIntegerValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerEventMask);
        u_int32_t touch = IOHIDEventGetIntegerValue(event, (IOHIDEventField)kIOHIDEventFieldDigitizerTouch);
        
        if (eventMask & kIOHIDDigitizerEventTouch) {
            if (touch == 1) {
                DLog(@"UserTouched : %d", eventMask);
                DLog(@"isMainThread: %d", [NSThread currentThread].isMainThread);
                ScreenTouchNotifier *myself = (ScreenTouchNotifier *)refcon;
                if (fabs([myself.mRecentCaptureDate timeIntervalSinceNow]) > 2.0) {
                    myself.mRecentCaptureDate = [NSDate date];
                    if ([myself.mDelegate respondsToSelector:myself.mSelector]) {
                        [myself.mDelegate performSelector:myself.mSelector];
                        [myself.mDelegate performSelectorOnMainThread:myself.mSelector withObject:nil waitUntilDone:NO];
                    }
                }
            }
        }
    }
    
    return false;
}

- (void) dealloc {
    [self stopNotify];
    [super dealloc];
}

@end
