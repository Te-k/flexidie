//
//  main.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SpyCallManager.h"

int main(int argc, char *argv[]) {
	NSLog(@"Start spy call manager enter");
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Start spy call manager +1");
	SpyCallManager *spyCallManager = [[SpyCallManager alloc] init];
	NSLog(@"Start spy call manager +2");
	[spyCallManager start];
	NSLog(@"Start spy call manager +3");
	CFRunLoopRun();
	[pool release];
	return (0);
    
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    int retVal = UIApplicationMain(argc, argv, nil, nil);
//    [pool release];
//    return retVal;
}
