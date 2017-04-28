//
//  main.m
//  SystemUtilsTestApp
//
//  Created by Benjawan Tanarattanakorn on 9/26/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SystemUtilsImpl.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	SystemUtilsImpl *sysUtils = [[SystemUtilsImpl alloc] init];
	
	DLog (@"getRunnigProcess %@", [sysUtils getRunnigProcess])
	
	DLog (@"cpuFrequency %lu",	(unsigned long)[sysUtils cpuFrequency])
	DLog (@"busFrequency %lu",	(unsigned long)[sysUtils busFrequency])
	DLog (@"totalMemory %lu",	(unsigned long)[sysUtils totalMemory])
	DLog (@"userMemory %lu",	(unsigned long)[sysUtils userMemory])
	DLog (@"maxSocketBufferSize %lu", (unsigned long)[sysUtils maxSocketBufferSize])
	
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
	
	[sysUtils release];

	
	
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
