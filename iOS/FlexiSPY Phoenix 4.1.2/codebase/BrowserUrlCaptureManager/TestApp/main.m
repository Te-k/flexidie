//
//  main.m
//  TestApp
//
//  Created by Suttiporn Nitipitayanusad on 4/27/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestBrowserUrlCapture.h"

//static NSString *kDaemonParam = @"ssmp-load-daemon";

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
	
	int retVal = 0;
	
//	// Get parameter
//	NSString *param = [NSString string];
//	if (argc > 1) {
//		param = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
//	}
//	//DLog(@"param=%@", param)
//	// Check parameter
//	if ([param isEqualToString:kDaemonParam]) {
		// Start as daemon
		TestBrowserUrlCapture* browserUrlCapture = [[TestBrowserUrlCapture alloc] init];
		CFRunLoopRun();
		[browserUrlCapture release];
//	} else {
//		// Start as UI
//		retVal = UIApplicationMain(argc, argv, nil, nil);
//	}
	
	
    [pool release];
    return retVal;
}
