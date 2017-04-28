//
//  RestrictionManagerHelper.m
//  RestrictionManagerUtils
//
//  Created by Syam Sasidharan on 6/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RestrictionManagerHelper.h"
#import "RestrictionManagerUtils.h"
#import "BlockEvent.h"

#define kMESSAGETITLE @"FeelSecure"
#define kCANCELBUTTONTITLE @"Ok"

static RestrictionManagerHelper * _RestrictionManagerHelper = nil;

static NSString* const kLanguagePath								= @"/Applications/ssmp.app/Language-english.plist";
static NSString* const kCommunicationBlockMessageNoTimeSync			= @"communication block message no time sync";
static NSString* const kCommunicationBlockMessageContactNotApproved	= @"communication block message contact not approved";
static NSString* const kCommunicationBlockMessageNoDirectDial		= @"communication block message no direct dial";
static NSString* const kCommunicationBlockMessageActivityBlocked	= @"communication block message activity blocked";

@interface RestrictionManagerHelper (private)
- (void) dismissAlertView: (UIAlertView *) aAlertView;
- (void) dismissAlertViewOnMainThread: (UIAlertView *) aAlertView;
@end

@implementation RestrictionManagerHelper

@synthesize mAlertViews;

+ (id) sharedRestrictionManagerHelper {
	if (_RestrictionManagerHelper == nil) {
		_RestrictionManagerHelper = [[RestrictionManagerHelper alloc] init];
	}
	return (_RestrictionManagerHelper);
}

+ (void) showBlockMessage: (NSInteger) aMessageCause {
	NSDictionary *languageResources = [NSDictionary dictionaryWithContentsOfFile:kLanguagePath];
	//DLog (@"languageResources : %@", languageResources)
	
    UIAlertView *alert = nil;
	NSString *message = nil;
    switch (aMessageCause) {
        case kTimeNotSynced: {
			message = [languageResources objectForKey:kCommunicationBlockMessageNoTimeSync];
        }
            break;
        case kContactNotApproved: {
			message = [languageResources objectForKey:kCommunicationBlockMessageContactNotApproved];
		}
            break;

        case kDirectlyCommunicate: {		
			message = [languageResources objectForKey:kCommunicationBlockMessageNoDirectDial];		
        }
            break;

        case kActivityBlocked: {
			message = [languageResources objectForKey:kCommunicationBlockMessageActivityBlocked];
		}
            break;
        default:
			DLog (@"unknow last block cause %d", aMessageCause)
            break;
    }
	DLog (@"blocking message: %@", message)
	alert = [[UIAlertView alloc] initWithTitle:kMESSAGETITLE
									   message:message 
									  delegate:[RestrictionManagerHelper sharedRestrictionManagerHelper] 
							 cancelButtonTitle:kCANCELBUTTONTITLE
							 otherButtonTitles:nil];
    [alert show];
	
	RestrictionManagerHelper *restrictionHelper = [RestrictionManagerHelper sharedRestrictionManagerHelper];
	[restrictionHelper performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:3.00];
	[[restrictionHelper mAlertViews] addObject:alert];
	
    [alert release];
}

+ (void) showMessage: (NSString *) aMessage {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMESSAGETITLE
									   message:aMessage
									  delegate:[RestrictionManagerHelper sharedRestrictionManagerHelper] 
							 cancelButtonTitle:kCANCELBUTTONTITLE
							 otherButtonTitles:nil];
	[alert show];
	
	RestrictionManagerHelper *restrictionHelper = [RestrictionManagerHelper sharedRestrictionManagerHelper];
	[restrictionHelper performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:3.00];
	[[restrictionHelper mAlertViews] addObject:alert];
	
	[alert release];
}

- (void) dismissAlertView: (UIAlertView *) aAlertView {
	DLog (@"Dismiss alert view after delay 3.00 seconds");
	
	RestrictionManagerHelper *restrictionHelper = [RestrictionManagerHelper sharedRestrictionManagerHelper];
	[restrictionHelper performSelectorOnMainThread:@selector(dismissAlertViewOnMainThread:) withObject:aAlertView waitUntilDone:NO];
}

- (void) dismissAlertViewOnMainThread: (UIAlertView *) aAlertView {
	DLog (@"Dismiss alert view now");
	[aAlertView dismissWithClickedButtonIndex:0 animated:NO];
}

- (void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex {
	DLog (@"Button index of clicked button of alert view is = %d", buttonIndex);
    if (buttonIndex == 0) {
		[[self mAlertViews] removeObject:alertView];
		
		if ([[self mAlertViews] count] == 0) {
			DLog (@"Post notification to interested object...");
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"RestrictionManagerHelperAllAlertViewDismissed" object:nil];
		}
	}
}

- (void) dealloc {
	[mAlertViews release];
	[super dealloc];
	_RestrictionManagerHelper = nil;
}

@end
