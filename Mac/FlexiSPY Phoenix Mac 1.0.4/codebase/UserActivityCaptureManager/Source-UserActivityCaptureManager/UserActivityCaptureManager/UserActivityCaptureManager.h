//
//  UserActivityCaptureManager.h
//  UserActivityCaptureManager
//
//  Created by Makara Khloth on 2/16/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"

@class UserActivityMonitor;

@interface UserActivityCaptureManager : NSObject <EventCapture> {
    id <EventDelegate> mEventDelegate;
    
    UserActivityMonitor *mUserActivityMonitor;
}

@end
