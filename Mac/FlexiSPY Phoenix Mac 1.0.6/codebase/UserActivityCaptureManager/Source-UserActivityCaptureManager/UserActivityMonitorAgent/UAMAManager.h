//
//  UAMAManager.h
//  UserActivityCaptureManager
//
//  Created by Makara Khloth on 6/4/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UAMAManager : NSObject {
    pid_t mPPID;
}

@property (nonatomic, assign) pid_t mPPID;

- (void) startActivityMonitor;
- (void) stopActivityMonitor;

@end
