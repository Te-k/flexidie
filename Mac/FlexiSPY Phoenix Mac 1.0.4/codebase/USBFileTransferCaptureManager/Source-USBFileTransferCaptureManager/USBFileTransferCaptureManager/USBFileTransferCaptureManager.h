//
//  USBFileTransferCaptureManager.h
//  USBFileTransferCaptureManager
//
//  Created by ophat on 2/4/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"

@class USBFileTransferDetection;

@interface USBFileTransferCaptureManager : NSObject <EventCapture> {
    USBFileTransferDetection * mDetector;
    
    id <EventDelegate> mEventDelegate;
}

-(void)startCapture;
-(void)stopCapture;

@end