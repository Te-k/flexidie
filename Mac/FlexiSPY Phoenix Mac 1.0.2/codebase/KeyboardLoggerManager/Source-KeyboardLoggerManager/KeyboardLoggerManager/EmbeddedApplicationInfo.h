//
//  EmbeddedApplicationInfo.h
//  KeyboardLoggerManager
//
//  Created by Makara Khloth on 4/28/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "ApplicationInfo.h"

@interface EmbeddedApplicationInfo : ApplicationInfo {
@private
    pid_t mPID;
    ProcessSerialNumber mPSN;
    pid_t mRemotePID;
}

@property (nonatomic, assign) pid_t mPID;
@property (nonatomic, assign) ProcessSerialNumber mPSN;
@property (nonatomic, assign) pid_t mRemotePID;
@end
