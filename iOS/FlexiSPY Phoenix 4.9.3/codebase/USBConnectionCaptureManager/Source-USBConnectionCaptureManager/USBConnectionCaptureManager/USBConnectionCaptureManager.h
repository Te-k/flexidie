//
//  USBConnectionCaptureManager.h
//  USBConnectionCaptureManager
//
//  Created by ophat on 2/4/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"

@class USBDetection;

@interface USBConnectionCaptureManager : NSObject <EventCapture> {
    id <EventDelegate> mDelegate;
    USBDetection* mUSBDetector;
}

@property(nonatomic, assign) id <EventDelegate> mDelegate;

- (void) startCapture;
- (void) stopCapture;

@end
