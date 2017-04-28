//
//  AppAgentCaller.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 4/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AppAgentCaller.h"
#import "AppAgentManager.h"

@implementation AppAgentCaller

- (id) init
{
	self = [super init];
	if (self != nil) {
		AppAgentManager *manager = [[AppAgentManager alloc] initWithEventDelegate:nil];
		
		[manager setThresholdInMegabyteForDiskSpaceCriticalLevel:24440];
		[manager setThresholdInMegabyteForDiskSpaceUrgentLevel:24450];
		[manager setThresholdInMegabyteForDiskSpaceWarningLevel:24460];
		
		NSLog(@"before start");
		
		[manager startListenDiskSpaceWarningLevel];
		[self performSelector:@selector(stopListen:) withObject:manager afterDelay:10];

	}
	return self;
}

- (void) stopListen: (AppAgentManager *) aAgent {
	[aAgent stopListenDiskSpaceWarningLevel];
}
@end
