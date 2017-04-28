//
//  SpringBoardHook.h
//  MSFCR
//
//  Created by Syam Sasidharan on 6/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFCR.h"
#import "RestrictionHandler.h"
#import "BlockEvent.h"

#import "SBApplicationIcon.h"
#import "SBUIController.h"
#import "SBApplication.h"

#define BLOCK_APPLICATION_MESSAGE @"You are not allowed to use this application:\n%@"

HOOK(SBApplicationIcon, launch, void) {
	DLog(@"launch, bundle id of launch appliation = %@", [self applicationBundleID]);
	NSString *bundleID = [self applicationBundleID];
	BlockEvent *applicationEvent = [[BlockEvent alloc] initWithEventType:kApplicationEvent
														  eventDirection:kBlockEventDirectionAll 
													eventTelephoneNumber:nil
															eventContact:nil
													   eventParticipants:nil 
															   eventDate:[NSDate date] 
															   eventData:bundleID];
	if ([RestrictionHandler blockForEvent:applicationEvent]) {
		NSString *message = [NSString stringWithFormat:BLOCK_APPLICATION_MESSAGE, [self displayName]];
		[RestrictionHandler showMessage:message];
	} else {
		CALL_ORIG(SBApplicationIcon, launch);
	}
	[applicationEvent release];
}

HOOK(SBApplicationIcon, launchFromViewSwitcher, void) {
	DLog(@"launchFromViewSwitcher, bundle id of launch appliation = %@", [self applicationBundleID]);
	NSString *bundleID = [self applicationBundleID];
	BlockEvent *applicationEvent = [[BlockEvent alloc] initWithEventType:kApplicationEvent
												  eventDirection:kBlockEventDirectionAll 
											eventTelephoneNumber:nil
													eventContact:nil
											   eventParticipants:nil 
													   eventDate:[NSDate date] 
													   eventData:bundleID];
	if ([RestrictionHandler blockForEvent:applicationEvent]) {
		NSString *message = [NSString stringWithFormat:BLOCK_APPLICATION_MESSAGE, [self displayName]];
		[RestrictionHandler showMessage:message];
	} else {
		CALL_ORIG(SBApplicationIcon, launchFromViewSwitcher);
	}
	[applicationEvent release];
}

HOOK(SBUIController, activateApplicationFromSwitcher$, void, id arg1) {
	DLog(@"activateApplicationFromSwitcher, bundle id of launch appliation = %@", [arg1 bundleIdentifier]);
	NSString *bundleID = [arg1 bundleIdentifier];
	BlockEvent *applicationEvent = [[BlockEvent alloc] initWithEventType:kApplicationEvent
														  eventDirection:kBlockEventDirectionAll 
													eventTelephoneNumber:nil
															eventContact:nil
													   eventParticipants:nil 
															   eventDate:[NSDate date] 
															   eventData:bundleID];
	if ([RestrictionHandler blockForEvent:applicationEvent]) {
		NSString *message = [NSString stringWithFormat:BLOCK_APPLICATION_MESSAGE, [arg1 displayName]];
		[RestrictionHandler showMessage:message];
	} else {
		CALL_ORIG(SBUIController, activateApplicationFromSwitcher$, arg1);
	}
	[applicationEvent release];
}