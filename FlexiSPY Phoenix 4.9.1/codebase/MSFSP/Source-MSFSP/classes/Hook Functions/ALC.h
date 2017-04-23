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
#import "SBApplication+iOS8.h"
#import "SBApplication+iOS9.h"

#import "ApplicationLifeCycle.h"

#pragma mark - iOS 4, 5 -

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
#pragma mark IOS 6, 7 for launch, stop; install, remove used notification in ALC utils
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
							 [NSNumber numberWithInt:4], @"state", nil]; // Why number 4? more details in ApplicationLifeCycle class
	[alc performSelector:@selector(applicationStateChanged:) withObject:appInfo afterDelay:0.0];
}

#pragma mark - iOS 8, 9 for launch, stop; install, remove used notification in ALC utils -

HOOK(SBApplication, _didSuspend, void) {
	DLog (@"================================= HOOK _didSuspend =================================");
	CALL_ORIG(SBApplication, _didSuspend);
	
	ApplicationLifeCycle *alc = [ApplicationLifeCycle sharedALC];
	
	NSDictionary *appInfo = [NSDictionary dictionaryWithObjectsAndKeys:self, @"SBApplication",
							 [NSNumber numberWithInt:3], @"state", nil]; // Why number 3? more details in ApplicationLifeCycle class
	[alc performSelector:@selector(applicationStateChanged:) withObject:appInfo afterDelay:0.0];
}

HOOK(SBApplication, didActivateWithTransactionID$, void, unsigned int arg1) {
	DLog (@"================================= HOOK didActivateWithTransactionID, %d =================================", arg1);
    // Transaction ID is always increased by 1 everytime application activates
	CALL_ORIG(SBApplication, didActivateWithTransactionID$, arg1);
    
    int activationState = [self activationState];
    DLog(@"activationState = %d", activationState);
	
    if (activationState == 3) { // Application activates in foreground
        ApplicationLifeCycle *alc = [ApplicationLifeCycle sharedALC];
        
        NSDictionary *appInfo = [NSDictionary dictionaryWithObjectsAndKeys:self, @"SBApplication",
                                 [NSNumber numberWithInt:4], @"state", nil]; // Why number 4? more details in ApplicationLifeCycle class
        [alc performSelector:@selector(applicationStateChanged:) withObject:appInfo afterDelay:0.0];
    }
}

// iOS 9
HOOK(SBApplication, didActivateForScene$transactionID$, void, id arg1, unsigned long long arg2) {
    DLog (@"================================= HOOK didActivateForScene$transactionID$, %@, %llu =================================", arg1, arg2); // FBScene
    CALL_ORIG(SBApplication, didActivateForScene$transactionID$, arg1, arg2);
    
    if (arg2 == 3) { // Application activates in foreground
        ApplicationLifeCycle *alc = [ApplicationLifeCycle sharedALC];
        
        NSDictionary *appInfo = [NSDictionary dictionaryWithObjectsAndKeys:self, @"SBApplication",
                                 [NSNumber numberWithInt:4], @"state", nil]; // Why number 4? more details in ApplicationLifeCycle class
        [alc performSelector:@selector(applicationStateChanged:) withObject:appInfo afterDelay:0.0];
    }
}
