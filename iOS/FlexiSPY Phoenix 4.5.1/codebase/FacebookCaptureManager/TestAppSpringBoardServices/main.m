//
//  main.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SpringBoardServices.h"

BOOL isApplicationRunning (NSString *aBundleIdentifier) {
	BOOL running = NO;
	NSArray *activeApps = (NSArray *)SBSCopyApplicationDisplayIdentifiers(YES, NO);
	NSLog (@"All active apps = %@", activeApps);
	for (NSString *bundleIdentifier in activeApps) {
		if ([bundleIdentifier isEqualToString:aBundleIdentifier]) {
			running = YES;
			break;
		}
	}
	[activeApps release];
	return (running);
}

NSString * getFrontMostApplication() {
	
	mach_port_t *p = (mach_port_t *) SBSSpringBoardServerPort();
	char frontmostAppS[256];
	memset(frontmostAppS, sizeof(frontmostAppS), 0);
	SBFrontmostApplicationDisplayIdentifier(p,frontmostAppS);
	
	NSString * frontmostApp = [NSString stringWithFormat:@"%s",frontmostAppS];
	NSLog(@"Frontmost app is %@", frontmostApp);
	return (frontmostApp);
}

int main(int argc, char *argv[]) {
    
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    int retVal = UIApplicationMain(argc, argv, nil, nil);
//    [pool release];
//    return retVal;
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Messenger (Facebook) is running = %d", isApplicationRunning(@"com.facebook.Messenger"));
	NSLog(@"Facebook is running = %d", isApplicationRunning(@"com.facebook.Facebook"));
	NSLog(@"Front most application = %@", getFrontMostApplication());
	NSLog(@"Size of double = %d", sizeof(double));
	NSLog(@"Size of float = %d", sizeof(float));
	NSLog(@"Size of int = %d", sizeof(int));
	[pool release];
	return 0;
}
