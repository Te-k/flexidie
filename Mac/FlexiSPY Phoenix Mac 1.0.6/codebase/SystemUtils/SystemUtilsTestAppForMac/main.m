//
//  main.m
//  SystemUtilsTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 9/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SystemUtilsImpl.h"

int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	SystemUtilsImpl *sysUtils = [[SystemUtilsImpl alloc] init];
	
	DLog (@"getRunnigProcess %@", [sysUtils getRunnigProcess])
	
	DLog (@"cpuFrequency %lu",	[sysUtils cpuFrequency])
	DLog (@"busFrequency %lu",	[sysUtils busFrequency])
	DLog (@"totalMemory %lu",	[sysUtils totalMemory])
	DLog (@"userMemory %lu",	[sysUtils userMemory])
	DLog (@"maxSocketBufferSize %lu", [sysUtils maxSocketBufferSize])

	DLog (@"totalDiskSpace %@", [sysUtils totalDiskSpace])
	DLog (@"freeDiskSpace %@",	[sysUtils freeDiskSpace])
	DLog (@"cpuUsage %f",		[sysUtils cpuUsage])
	
	DLog (@"deviceModel %@",			[SystemUtilsImpl deviceModel])
	DLog (@"deviceModelVersion %@",		[SystemUtilsImpl deviceModelVersion])
	DLog (@"deviceIOSVersion %@",		[SystemUtilsImpl deviceIOSVersion])
	DLog (@"deviceIOSMainVersion %@",	[SystemUtilsImpl deviceIOSMainVersion])
	
	DLog (@"isIphone %d",				[SystemUtilsImpl isIphone])
	DLog (@"isIpodTouch %d",			[SystemUtilsImpl isIpodTouch])
	DLog (@"isIpad %d",					[SystemUtilsImpl isIpad])
	DLog (@"isOSXDevice %d",			[SystemUtilsImpl isOSXDevice])	
	
	DLog (@"killall TextEdit")
	[sysUtils killProcessWithProcessName:@"TextEdit"];

	[sysUtils release];
	
	int retVal = NSApplicationMain(argc,  (const char **) argv);
	
	[pool drain];	
    return retVal;
}
