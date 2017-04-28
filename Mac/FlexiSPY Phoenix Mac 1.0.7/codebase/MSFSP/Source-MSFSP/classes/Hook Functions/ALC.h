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

// iOS 8 - This method call multiple time when app come to foreground (not used)
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

// iOS 9 - This method call multiple time when app come to foreground (not used)
HOOK(SBApplication, didActivateForScene$transactionID$, void, id arg1, unsigned long long arg2) {
    DLog (@"================================= HOOK didActivateForScene$transactionID$, %@, %llu =================================", arg1, arg2); // FBScene
    CALL_ORIG(SBApplication, didActivateForScene$transactionID$, arg1, arg2);
    
    unsigned long long transactionID = arg2;
    int activationState = [self activationState];
    DLog(@"activationState = %d", activationState);
    
    //Start cature from transactionID equal to 5 to prevent capturing app did launch for multiple times
    if (transactionID >= 5 && activationState == 3) { // Application activates in foreground
        ApplicationLifeCycle *alc = [ApplicationLifeCycle sharedALC];
        
        NSDictionary *appInfo = [NSDictionary dictionaryWithObjectsAndKeys:self, @"SBApplication",
                                 [NSNumber numberWithInt:4], @"state", nil]; // Why number 4? more details in ApplicationLifeCycle class
        [alc performSelector:@selector(applicationStateChanged:) withObject:appInfo afterDelay:0.0];
    }
}

// iOS 8 + 9 - This method call one time only when app come to foreground
HOOK(SBApplication, willActivate, void) {
    CALL_ORIG(SBApplication, willActivate);
    
    int activationState = [self activationState];
    
    DLog(@"activationState = %d", activationState);
    
    ApplicationLifeCycle *alc = [ApplicationLifeCycle sharedALC];
    
    DLog (@"bundleIdentifier - %@", [self bundleIdentifier]);
    
    NSDictionary *appInfo = [NSDictionary dictionaryWithObjectsAndKeys:self, @"SBApplication",
                             [NSNumber numberWithInt:4], @"state", nil]; // Why number 4? more details in ApplicationLifeCycle class
    [alc performSelector:@selector(applicationStateChanged:) withObject:appInfo afterDelay:0.0];
}

// iOS 8 - For capture when kill app from app switching
HOOK(SBApplication, didExitWithType$terminationReason$, void, int arg1, int arg2) {
    DLog (@"================================= HOOK didExitWithType$terminationReason$, %d, %d =================================", arg1, arg2); // FBScene
    
    int activationState = [self activationState];
    DLog(@"activationState = %d", activationState);

    CALL_ORIG(SBApplication, didExitWithType$terminationReason$, arg1, arg2);
    
    if (activationState == 3) { // Application activates in foreground
        ApplicationLifeCycle *alc = [ApplicationLifeCycle sharedALC];
        
        NSDictionary *appInfo = [NSDictionary dictionaryWithObjectsAndKeys:self, @"SBApplication",
                                 [NSNumber numberWithInt:3], @"state", nil]; // Why number 3? more details in ApplicationLifeCycle class
        [alc performSelector:@selector(applicationStateChanged:) withObject:appInfo afterDelay:0.0];
    }
}

// iOS 9 - For capture when kill app from app switching
HOOK(SBApplication, didExitWithContext$, void, id arg1) {
    DLog (@"================================= HOOK didExitWithContext$, %@, =================================", arg1); // FBScene
    
    int activationState = [self activationState];
    DLog(@"activationState = %d", activationState);
    
    CALL_ORIG(SBApplication, didExitWithContext$, arg1);
    
    if (activationState == 3) { // Application activates in foreground
        ApplicationLifeCycle *alc = [ApplicationLifeCycle sharedALC];
        
        NSDictionary *appInfo = [NSDictionary dictionaryWithObjectsAndKeys:self, @"SBApplication",
                                 [NSNumber numberWithInt:3], @"state", nil]; // Why number 3? more details in ApplicationLifeCycle class
        [alc performSelector:@selector(applicationStateChanged:) withObject:appInfo afterDelay:0.0];
    }
}
