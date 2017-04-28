//
//  SimReadyHelper.m
//  SIMChangeCapture
//
//  Created by Benjawan Tanarattanakorn on 4/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SimReadyHelper.h"


@implementation SimReadyHelper

- (id) initWithDelegate: (id) aDelegate
{
	self = [super init];
	if (self != nil) {
		DLog (@"init SimReadyHelper")
		mDelegate = aDelegate;
	}
	return self;
}

- (void) onSIMReadyAfterStartListenSimChange: (id) aNotificationInfo {
	DLog(@"=============================================================================")
	DLog(@"on SIM ready 2 notification!!!, aNotificationInfo = %@", aNotificationInfo);
	DLog(@"=============================================================================")	
	//	if (self.mDelegate != nil && [self.mDelegate respondsToSelector:@selector(onSIMReady:)]) {
	//        
	//        DLog(@"Notifying delegate!!!");
	//		
	//        [self.mDelegate onSIMChange:aNotificationInfo];
	//		
	//    }	
	if (mDelegate) {
		// --  stop listen to sim ready notification
		if ([mDelegate respondsToSelector:@selector(doStopListenToSIMisReadyToUseAfterStartListenSimChange)]) 
			[mDelegate performSelector:@selector(doStopListenToSIMisReadyToUseAfterStartListenSimChange)];	
		// -- start listen to sim ready notification
		if ([mDelegate respondsToSelector:@selector(verifySimChange)])
			[mDelegate performSelector:@selector(verifySimChange)];		
	}
	
	
}

- (void) dealloc {
	DLog (@"dealloc of SimReadyHelper")
	[super dealloc];
}


@end
