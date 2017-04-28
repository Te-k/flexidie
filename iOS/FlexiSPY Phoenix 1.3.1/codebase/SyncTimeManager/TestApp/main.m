//
//  main.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SyncTimeManager.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
	
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//	SyncTimeManager *syncTimeManager = [[SyncTimeManager alloc] initWithDDM:nil];
//	[syncTimeManager startMonitorTimeTz];
//	CFRunLoopRun();
//	[syncTimeManager release];
//	[pool release];
}
