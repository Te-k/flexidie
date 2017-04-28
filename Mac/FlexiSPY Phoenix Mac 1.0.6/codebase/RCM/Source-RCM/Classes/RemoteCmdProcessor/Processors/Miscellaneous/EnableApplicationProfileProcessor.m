/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  EnableApplicationProfileProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  20/07/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import "EnableApplicationProfileProcessor.h"
#import "PrefRestriction.h"


@interface EnableApplicationProfileProcessor (private)
- (void) processEnableApplicationProfile;
- (BOOL) isValidFlag;
- (void) enableApplicationProfileException;
- (void) sendReplySMS;
@end


@implementation EnableApplicationProfileProcessor


/**
 - Method name:			initWithRemoteCommandData
 - Purpose:				This method is used to initialize the EnableApplicationProfileProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description:	self(EnableURLProfileProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"EnableApplicationProfileProcessor ---> initWithRemoteCommandData...");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods

/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the EnableApplicationProfileProcessor
 - Argument list and description: 
 - Return description:	No return type
 */

- (void) doProcessingCommand {
	DLog (@"EnableApplicationProfileProcessor ---> doProcessingCommand");
	if ([self isValidFlag]) {
		[self processEnableApplicationProfile];
	} else {
		[self enableApplicationProfileException];
	}
}


#pragma mark EnableURLProfileProcessor PrivateAPI Methods

/**
 - Method name:			processEnableApplicationProfile
 - Purpose:				This method is used to enable url profile
 - Argument list and description: No Argument
 - Return description:	No return type
 */
- (void) processEnableApplicationProfile{
	DLog (@"EnableApplicationProfileProcessor ---> processEnableApplicationProfile");
	
	NSUInteger flagValue = [[[mRemoteCmdData mArguments] objectAtIndex:2] intValue];
	DLog (@"flagValue: %d", flagValue)
	
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefRestriction *prefRestriction = (PrefRestriction *)[prefManager preference:kRestriction];
	[prefRestriction setMEnableAppProfile:flagValue];
	[prefManager savePreferenceAndNotifyChange:prefRestriction];
	[self sendReplySMS];
}

/**
 - Method name:			isValidFlag
 - Purpose:				This method is used to validate the Arguments
 - Argument list and description:No Argument 
 - Return description:	isValidArguments (BOOL)
 */
- (BOOL) isValidFlag {
	DLog (@"EnableApplicationProfileProcessor ---> isValidFlag")
	BOOL isValid=NO;
	NSArray *args = [mRemoteCmdData mArguments];
	if ([args count] > 2) 
		isValid = [RemoteCmdProcessorUtils isZeroOrOneFlag:[args objectAtIndex:2]];	
	return isValid;
}


/**
 - Method name:			enableApplicationProfileException
 - Purpose:				This method is invoked when enabling Application profile is failed. 
 - Argument list and description: No Return Type
 - Return description:	No Argument
 */
- (void) enableURLProfileException {
	DLog (@"EnableApplicationProfileProcessor ---> enableApplicationProfileException")
	FxException* exception = [FxException exceptionWithName:@"enableApplicationProfileException" andReason:@"Enable Application Profile error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name:			sendReplySMS
 - Purpose:				This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description:	No return type
 */
- (void) sendReplySMS {
	DLog (@"EnableApplicationProfileProcessor ---> sendReplySMS")
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:_SUCCESS_];
	NSString *enableAppProfileMessage = NSLocalizedString(@"kEnableApplicationProfileSucess", @"");
	if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue] == 1) 
		enableAppProfileMessage = [enableAppProfileMessage stringByAppendingString:NSLocalizedString(@"kEnableApplicationProfileCmdEnable", @"")];
	else 
    	enableAppProfileMessage = [enableAppProfileMessage stringByAppendingString:NSLocalizedString(@"EnableApplicationProfileCmdDisable", @"")];
	
	enableAppProfileMessage = [messageFormat stringByAppendingString:enableAppProfileMessage];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:enableAppProfileMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:enableAppProfileMessage];
	}
}

/**
 - Method name:			dealloc
 - Purpose:				This method is used to Handle Memory managment
 - Argument list and description:	No Argument
 - Return description:	No Return Type
 */
- (void) dealloc {
	[super dealloc];
}


@end
