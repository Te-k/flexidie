//
//  main.m
//  UserActivityMonitorAgent
//
//  Created by Makara Khloth on 6/4/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UAMAManager.h"

#import "DebugStatus.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        UAMAManager *uamaManager = [[UAMAManager alloc] init];
        [uamaManager startActivityMonitor];
        DLog(@"User activity monitor start...");
        
        CFRunLoopRun();
        
        DLog(@"User Activity Monitor Agent Exit...");
        
        [uamaManager release];
        
    }
    return 0;
}
