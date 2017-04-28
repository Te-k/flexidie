//
//  RestrictionHandler.m
//  MSFCR
//
//  Created by Syam Sasidharan on 6/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RestrictionHandler.h"
#import "RestrictionManagerUtils.h"
#import "RestrictionHeaders.h"
#import "RestrictionManagerHelper.h"
#import "BlockEvent.h"

#import "MessagePortIPCSender.h"
#import "DefStd.h"
#import "SpringBoardServices.h"

#import "SpringBoard.h"
#import "SBApplication.h"
#import "SBUIController.h"

#import <UIKit/UIApplication.h>

static RestrictionHandler *_RestrictionHandler = nil;

@interface RestrictionHandler (private)
- (void) allAlertViewDismissed: (NSNotification *) aNotification;
- (void) relaunchFeelSecure: (SBApplication *) aSBFeelSecureApplication;
@end


@implementation RestrictionHandler

+ (id) sharedRestrictionHandler {
	if (_RestrictionHandler == nil) {
		_RestrictionHandler = [[RestrictionHandler alloc] init];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:_RestrictionHandler
			   selector:@selector(allAlertViewDismissed:)
				   name:@"RestrictionManagerHelperAllAlertViewDismissed"
				 object:nil];
	}
	return (_RestrictionHandler);
}

+ (void) showBlockMessage {
	[RestrictionManagerHelper showBlockMessage:[RestrictionHandler lastBlockCause]];
}

+ (void) showMessage: (NSString *) aMessage {
	[RestrictionManagerHelper showMessage:aMessage];
}

+ (BOOL) blockForEvent: (id) aEvent {
    return ([[RestrictionManagerUtils sharedRestrictionManagerUtils] blockEvent:aEvent]);
}

+ (NSInteger) lastBlockCause {
	//DLog (@"The last known blocking cause is = %d", [[RestrictionManagerUtils sharedRestrictionManagerUtils] mLastBlockCause]);
	return ([[RestrictionManagerUtils sharedRestrictionManagerUtils] mLastBlockCause]);
}

+ (NSDate *) blockEventDate {
	return ([[RestrictionManagerUtils sharedRestrictionManagerUtils] blockEventDate]);
}

- (void) allAlertViewDismissed: (NSNotification *) aNotification {
	//DLog (@"All alert views are dismissed");
	NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
	if ([identifier isEqualToString:kSPRINGBOARDAPPIDENTIFIER]) {
		NSInteger alertDismiss = 188;
		NSData *sData = [NSData dataWithBytes:&alertDismiss length:sizeof(NSInteger)];
		MessagePortIPCSender *messageSender = [[MessagePortIPCSender alloc] initWithPortName:kAllBlockAlertViewDismissMessagePort];
		[messageSender writeDataToPort:sData];
		NSData *rData = [messageSender mReturnData];
		//DLog (@"sData = %@, rData = %@", sData, rData);
		if ([sData isEqualToData:rData]) {
			// Trick to bring application to active all the time after call when panic is active
							
			SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
			//DLog (@"SpringBoard UI application = %@", sb);
			SBApplication *fsApp = [sb _accessibilityFrontMostApplication];
			//DLog (@"SB Feelsecure application = %@", fsApp);
			
			BlockEvent *blockEvent = [[RestrictionManagerUtils sharedRestrictionManagerUtils] mLastBlockEvent];
			
			if ([[fsApp bundleIdentifier] isEqualToString:@"com.app.ssmp"] &&
				[blockEvent mType] == kCallEvent && [blockEvent mDirection] == kBlockEventDirectionIn) {
				/*
				 Note: Alert blocking is dismissed after 3 seconds; the issue of panic not resume after unapproved
				 incoming call does not appear in Iphone 4, IOS 4.2.1 as report in issue tracking thus auto dismiss
				 dialog may be help the issue fixed in Iphone 4, IOS 4.2.1 but issue is still in IOS 5.1.1; this lead
				 to assume that issue is happen in IOS 5.1.1 now
				 */
				
				if ([[[UIDevice currentDevice] systemVersion] intValue] == 5) {
					// Simulate menu button
					[sb menuButtonDown:nil];
					[sb menuButtonUp:nil];
					
					[self performSelector:@selector(relaunchFeelSecure:) withObject:fsApp afterDelay:1.0];
				}
			}
		}
		[messageSender release];
	}
}

- (void) relaunchFeelSecure: (SBApplication *) aSBFeelSecureApplication {
	// Relaunch FeelSecure application
	
	// 1) Cause spring board hang
//	NSInteger error = SBSLaunchApplicationWithIdentifier((CFStringRef)@"com.app.ssmp", YES);
//	DLog(@"Relaunch FeelSecure application got error: %d", error);
//	if (error) {
//		CFStringRef errorStr = SBSApplicationLaunchingErrorString(error);
//		DLog(@"Convert relaunch FeelSeucre error to string errorStr: %@", (NSString *)errorStr);
//		CFRelease(errorStr);
//	}
	
	// 2) OK
	Class $SBUIController = objc_getClass("SBUIController");
	[[$SBUIController sharedInstance] activateApplicationAnimated:aSBFeelSecureApplication];
}

- (void) dealloc {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:_RestrictionHandler
				  name:@"RestrictionManagerHelperAllAlertViewDismissed"
				object:nil];
	[super dealloc];
	_RestrictionHandler = nil;
}

@end
