//
//  TestAppAppDelegate.m
//  TestApp
//
//  Created by vervata on 9/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "TestAppAppDelegate.h"
#import "MacInfoTest.h"

@implementation TestAppAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	MacInfoTest *test = [[MacInfoTest alloc] init];
	[test testGetMacInfo];		
}

@end
