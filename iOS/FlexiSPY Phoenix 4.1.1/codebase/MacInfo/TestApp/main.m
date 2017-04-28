//
//  main.m
//  TestApp
//
//  Created by vervata on 9/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MacInfoTest.h"

int main(int argc, char *argv[])
{

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	MacInfoTest *test = [[MacInfoTest alloc] init];
	[test testGetMacInfo];		

	[pool drain];
	
	return 0;
   // return NSApplicationMain(argc,  (const char **) argv);
}
