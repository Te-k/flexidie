//
//  DiskSpaceCheckerCaller.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 4/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "DiskSpaceCheckerCaller.h"
#import "DiskSpaceWarningAgent.h"

@implementation DiskSpaceCheckerCaller

- (id) init
{
	self = [super init];
	if (self != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(diskSpaceWarningDidReceived:) 
													 name:NSDiskSpaceWarningLevelNotification 
												   object:nil];
		
		DiskSpaceWarningAgent *diskHandler = [[DiskSpaceWarningAgent alloc] init];
		
		[diskHandler setDiskSpaceThresholdForLevel:DiskSpaceNotificationLevelCritical valueInMegaByte:24440];
		[diskHandler setDiskSpaceThresholdForLevel:DiskSpaceNotificationLevelUrgent valueInMegaByte:24450];
		[diskHandler setDiskSpaceThresholdForLevel:DiskSpaceNotificationLevelWarning valueInMegaByte:24460];
		
		[diskHandler startListenToDiskSpaceWarningLevelNotification];
		
		// the below line is for testing the stop function
		[self performSelector:@selector(stopListen:) withObject:diskHandler afterDelay:15];
		
	}
	return self;
}

- (void) diskSpaceWarningDidReceived: (NSNotification *) aNotification {
	NSLog(@"DiskSpaceCheckerCaller --> diskSpaceWarningDidReceived: main thread ? %d", [NSThread isMainThread]);
	NSLog(@"DiskSpaceCheckerCaller --> diskSpaceWarningDidReceived: !!!!! DISK SPACE WARNNING LEVEL: %@ !!!!! ", [aNotification object]);
}


- (void) stopListen: (DiskSpaceWarningAgent *) aAgent {
	[aAgent stopListenToDiskSpaceWarningLevelNotification];
}

@end
