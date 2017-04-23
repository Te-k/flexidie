//
//  NetworkConnectionCaptureManager.h
//  NetworkConnectionCaptureManager
//
//  Created by ophat on 11/24/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventCapture.h"

@class NetworkConnectionCaptureNotify;
@interface NetworkConnectionCaptureManager : NSObject <EventCapture>{
    NetworkConnectionCaptureNotify * mNetCap;
    id <EventDelegate> mEventDelegate;
}
@property (nonatomic,retain) NetworkConnectionCaptureNotify * mNetCap;

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate ;
- (void) unregisterEventDelegate;

- (void) startCapture;
- (void) stopCapture;
@end