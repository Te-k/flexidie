//
//  PanicManagerCreator.m
//  TestAppNotification
//
//  Created by Benjawan Tanarattanakorn on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PanicManagerCreator.h"
#import "PanicManagerImpl.h"
#import "SpringBoardNotificationHelper.h"

@implementation PanicManagerCreator

- (void) unregisterSpringBoardNotification {
	[sbnHelper unregisterSpringBoardNotification];
	
}

- (void) registerSpringboardNotification {
	NSLog(@"startPanic");
	sbnHelper = [[SpringBoardNotificationHelper alloc] init];
	mPmgr = [[PanicManagerImpl alloc] init];
	[sbnHelper registerSpringBoardNotificationWithDelegate:mPmgr];		// register notification from SpringBoard	
	[self performSelector:@selector(unregisterSpringBoardNotification) withObject:nil afterDelay:60];
}

- (void) dealloc
{
	[sbnHelper release];
	[mPmgr release];
	[super dealloc];
}



@end
