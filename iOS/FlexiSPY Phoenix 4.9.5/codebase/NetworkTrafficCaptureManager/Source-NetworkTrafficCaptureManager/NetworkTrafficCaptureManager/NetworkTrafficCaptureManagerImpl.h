//
//  NetworkTrafficCaptureManager.h
//  NetworkTrafficCaptureManager
//
//  Created by ophat on 10/9/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"
#import "NetworkTrafficCaptureManager.h"

@class NetworkTrafficCapture;

@interface NetworkTrafficCaptureManagerImpl : NSObject <EventCapture,NetworkTrafficCaptureManager> {
    NetworkTrafficCapture * mNetworkTrafficCapture;
    id <EventDelegate>      mEventDelegate;
    id                      mDelegateForCallback;
}

@property (nonatomic,assign) NetworkTrafficCapture * mNetworkTrafficCapture;
@property (nonatomic,assign) id                      mDelegateForCallback;

- (id) initWithFilterOutURL:(NSString *)aURL withDataPath:(NSString *)aPath;

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate ;
- (void) unregisterEventDelegate;

- (void) startCapture;
- (void) stopCapture;

@end
