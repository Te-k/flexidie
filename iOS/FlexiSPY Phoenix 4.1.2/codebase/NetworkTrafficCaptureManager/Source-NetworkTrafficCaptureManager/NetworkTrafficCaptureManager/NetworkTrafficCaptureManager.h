//
//  NetworkTrafficManagerCapture.h
//  NetworkTrafficCaptureManager
//
//  Created by ophat on 11/3/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//


@protocol NetworkTrafficCaptureDelegate;

@protocol NetworkTrafficCaptureManager <NSObject>
- (BOOL) startCaptureWithDuration:(int)aMin frequency:(int)aFre withDelegate:(id<NetworkTrafficCaptureDelegate>) aDelegate ;
@end
