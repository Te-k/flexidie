//
//  CPUUsage.m
//  TestApp
//
//  Created by Makara Khloth on 9/13/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CPUUsage.h"
#import "SystemUtilsImpl.h"

@implementation CPUUsage

- (void) cpuUsage: (id) aCaller {
	NSLog(@"CPU usage aCaller = %@", aCaller);
	SystemUtilsImpl *systemUtils = [[SystemUtilsImpl alloc] init];
	id <SystemUtils> sysUtils = systemUtils;
	float cpuUsage = [sysUtils cpuUsage];
	NSLog(@"CPU usage now = %f", cpuUsage);
	[systemUtils release];
}

@end
