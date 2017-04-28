//
//  main.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileSubstrateDummy.h"
#import "DeviceLockUtilsCaller.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
	DLog(@"main")
	// Mimi mobile substrate
	//MobileSubstrateDummy *ms = [[MobileSubstrateDummy alloc] init];
	//[ms start];
	
	DeviceLockUtilsCaller *caller = [[DeviceLockUtilsCaller alloc] init];
	
	int number = 0;
	scanf("%d", &number);	// wait for input from a user 
	DLog(@"input %d", number)
	if (number == 1) {
		DLog (@">> send lock command")
		[caller sendLockCommand];
	} else if (number == 2) {
		DLog (@">> send unlock command")
		[caller sendUnlockCommand];
	}
	DLog(@"end")
	CFRunLoopRun();
    [pool release];
    return retVal;
}
